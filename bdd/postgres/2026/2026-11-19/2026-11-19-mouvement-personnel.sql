CREATE TABLE IF NOT EXISTS public.paie_personnel_historique (
    id BIGSERIAL PRIMARY KEY,
    idpersonnel VARCHAR(50) NOT NULL,
    typeevenement VARCHAR(30) NOT NULL,
    table_source VARCHAR(64) NOT NULL,
    date_mouvement TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    utilisateur VARCHAR(255) NOT NULL DEFAULT current_user,
    donnees_avant JSONB,
    donnees_apres JSONB
);

CREATE OR REPLACE FUNCTION public.capture_paie_personnel_historique()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    personnel_id VARCHAR(50);
    donnees_avant JSONB;
    donnees_apres JSONB;
BEGIN
    IF TG_OP = 'INSERT' AND TG_TABLE_NAME = 'log_personnel' THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE' AND to_jsonb(OLD) = to_jsonb(NEW) THEN
        RETURN NEW;
    END IF;

    personnel_id := NEW.id::VARCHAR;

    IF TG_OP = 'UPDATE' THEN
        SELECT jsonb_build_object(
            'personnel',
            CASE WHEN TG_TABLE_NAME = 'log_personnel' THEN to_jsonb(OLD) ELSE to_jsonb(lp) END,
            'paie',
            CASE WHEN TG_TABLE_NAME = 'paie_info_personnel' THEN to_jsonb(OLD) ELSE to_jsonb(pip) END
        )
        INTO donnees_avant
        FROM (SELECT 1) AS source
        LEFT JOIN public.log_personnel lp ON lp.id::VARCHAR = personnel_id
        LEFT JOIN public.paie_info_personnel pip ON pip.id::VARCHAR = personnel_id;
    END IF;

    SELECT jsonb_build_object(
        'personnel', to_jsonb(lp),
        'paie', to_jsonb(pip)
    )
    INTO donnees_apres
    FROM (SELECT 1) AS source
    LEFT JOIN public.log_personnel lp ON lp.id::VARCHAR = personnel_id
    LEFT JOIN public.paie_info_personnel pip ON pip.id::VARCHAR = personnel_id;

    INSERT INTO public.paie_personnel_historique (
        idpersonnel, typeevenement, table_source, donnees_avant, donnees_apres
    )
    VALUES (
        personnel_id,
        CASE WHEN TG_OP = 'INSERT' THEN 'EMBAUCHE' ELSE 'MODIFICATION' END,
        TG_TABLE_NAME,
        donnees_avant,
        donnees_apres
    );

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_paie_personnel_historique_log ON public.log_personnel;
CREATE TRIGGER trg_paie_personnel_historique_log
AFTER INSERT OR UPDATE ON public.log_personnel
FOR EACH ROW EXECUTE PROCEDURE public.capture_paie_personnel_historique();

DROP TRIGGER IF EXISTS trg_paie_personnel_historique_info ON public.paie_info_personnel;
CREATE TRIGGER trg_paie_personnel_historique_info
AFTER INSERT OR UPDATE ON public.paie_info_personnel
FOR EACH ROW EXECUTE PROCEDURE public.capture_paie_personnel_historique();

INSERT INTO public.paie_personnel_historique (
    idpersonnel, typeevenement, table_source, date_mouvement, donnees_apres
)
SELECT
    p.id::VARCHAR,
    'BASELINE',
    'migration',
    COALESCE(p.dateembauche::TIMESTAMPTZ, clock_timestamp()),
    jsonb_build_object('personnel', to_jsonb(lp), 'paie', to_jsonb(p))
FROM public.paie_info_personnel p
JOIN public.log_personnel lp ON lp.id::VARCHAR = p.id::VARCHAR
WHERE NOT EXISTS (
    SELECT 1
    FROM public.paie_personnel_historique h
    WHERE h.idpersonnel = p.id::VARCHAR
      AND h.typeevenement = 'BASELINE'
      AND h.table_source = 'migration'
);

CREATE OR REPLACE VIEW public.paie_mouvement_personnel_historique AS
WITH avancements AS (
    SELECT
        av.id,
        av.id_logpers AS idpersonnel,
        av.date_application AS date_mouvement,
        COALESCE(
            (SELECT ld.val::varchar
             FROM public.log_direction ld
             WHERE ld.id::varchar = av.direction::varchar
             LIMIT 1),
            av.direction::varchar
        ) AS direction,
        COALESCE(
            (SELECT ls.desce::varchar
             FROM public.log_service_crt ls
             WHERE ls.val::varchar = av.service::varchar
             LIMIT 1),
            av.service::varchar
        ) AS service,
        COALESCE(av.fonctionlib::varchar, av.idfonction::varchar) AS fonction,
        av.etat
    FROM public.paie_avancement_libelle2 av
    WHERE av.etat = 11
),
mouvements AS (
    SELECT
        avancements.*,
        LAG(direction) OVER (
            PARTITION BY idpersonnel
            ORDER BY date_mouvement NULLS LAST, id
        ) AS ancienne_direction,
        LAG(service) OVER (
            PARTITION BY idpersonnel
            ORDER BY date_mouvement NULLS LAST, id
        ) AS ancien_service,
        LAG(fonction) OVER (
            PARTITION BY idpersonnel
            ORDER BY date_mouvement NULLS LAST, id
        ) AS ancienne_fonction
    FROM avancements
)
SELECT
    ('SITUATION-' || p.id)::varchar AS id,
    p.id::varchar AS idpersonnel,
    p.matricule::varchar AS matricule,
    lp.nom::varchar AS nom,
    lp.prenom::varchar AS prenom,
    'SITUATION'::varchar AS typeevenement,
    COALESCE(p.date_depart, p.dateembauche)::date AS date_mouvement,
    NULL::varchar AS ancienne_direction,
    COALESCE(
        (SELECT ld.val::varchar
         FROM public.log_direction ld
         WHERE ld.id::varchar = lp.direction::varchar
         LIMIT 1),
        lp.direction::varchar
    ) AS nouvelle_direction,
    NULL::varchar AS ancien_service,
    COALESCE(
        (SELECT ls.desce::varchar
         FROM public.log_service_crt ls
         WHERE ls.val::varchar = lp.service::varchar
         LIMIT 1),
        lp.service::varchar
    ) AS nouveau_service,
    NULL::varchar AS ancienne_fonction,
    COALESCE(pf.desce::varchar, p.idfonction::varchar) AS nouvelle_fonction,
    p.date_depart::date AS date_depart,
    NULL::text AS donnees_avant,
    NULL::text AS donnees_apres,
    NULL::varchar AS ancien_departement,
    COALESCE(
        (SELECT dep.val::varchar
         FROM public.departement dep
         WHERE dep.id::varchar = p.iddepartement::varchar
         LIMIT 1),
        p.iddepartement::varchar
    ) AS nouveau_departement
FROM public.paie_info_personnel p
JOIN public.log_personnel lp ON lp.id = p.id
LEFT JOIN public.paie_fonction pf ON pf.id::varchar = p.idfonction::varchar

UNION ALL

SELECT
    ('MOUVEMENT-' || m.id)::varchar AS id,
    m.idpersonnel::varchar AS idpersonnel,
    p.matricule::varchar AS matricule,
    lp.nom::varchar AS nom,
    lp.prenom::varchar AS prenom,
    'MOUVEMENT'::varchar AS typeevenement,
    m.date_mouvement::date AS date_mouvement,
    m.ancienne_direction::varchar AS ancienne_direction,
    m.direction::varchar AS nouvelle_direction,
    m.ancien_service::varchar AS ancien_service,
    m.service::varchar AS nouveau_service,
    m.ancienne_fonction::varchar AS ancienne_fonction,
    m.fonction::varchar AS nouvelle_fonction,
    p.date_depart::date AS date_depart,
    NULL::text AS donnees_avant,
    NULL::text AS donnees_apres,
    NULL::varchar AS ancien_departement,
    NULL::varchar AS nouveau_departement
FROM mouvements m
JOIN public.log_personnel lp ON lp.id::varchar = m.idpersonnel::varchar
LEFT JOIN public.paie_info_personnel p ON p.id::varchar = m.idpersonnel::varchar

UNION ALL

SELECT
    ('DEBAUCHE-' || lpnv.id)::varchar AS id,
    lpnv.idlogpers::varchar AS idpersonnel,
    p.matricule::varchar AS matricule,
    lp.nom::varchar AS nom,
    lp.prenom::varchar AS prenom,
    'DEBAUCHE'::varchar AS typeevenement,
    lpnv.dateapplication::date AS date_mouvement,
    COALESCE(
        (SELECT ld.val::varchar
         FROM public.log_direction ld
         WHERE ld.id::varchar = COALESCE(av.direction, lp.direction)::varchar
         LIMIT 1),
        COALESCE(av.direction, lp.direction)::varchar
    ) AS ancienne_direction,
    NULL::varchar AS nouvelle_direction,
    COALESCE(
        (SELECT ls.desce::varchar
         FROM public.log_service_crt ls
         WHERE ls.val::varchar = COALESCE(av.service, lp.service)::varchar
         LIMIT 1),
        COALESCE(av.service, lp.service)::varchar
    ) AS ancien_service,
    NULL::varchar AS nouveau_service,
    COALESCE(pf.desce::varchar, av.idfonction::varchar, p.idfonction::varchar) AS ancienne_fonction,
    NULL::varchar AS nouvelle_fonction,
    lpnv.dateapplication::date AS date_depart,
    NULL::text AS donnees_avant,
    NULL::text AS donnees_apres,
    COALESCE(
        (SELECT dep.val::varchar
         FROM public.departement dep
         WHERE dep.id::varchar = p.iddepartement::varchar
         LIMIT 1),
        p.iddepartement::varchar
    ) AS ancien_departement,
    NULL::varchar AS nouveau_departement
FROM public.log_personnel_non_valide lpnv
JOIN public.log_personnel lp ON lp.id::varchar = lpnv.idlogpers::varchar
LEFT JOIN public.paie_info_personnel p ON p.id::varchar = lpnv.idlogpers::varchar
LEFT JOIN public.paie_avancement av ON av.id::varchar = lpnv.idavancement::varchar
LEFT JOIN public.paie_fonction pf ON pf.id::varchar = COALESCE(av.idfonction, p.idfonction)::varchar
WHERE lpnv.etat >= 11

UNION ALL

SELECT
    ('AUDIT-' || h.id)::varchar AS id,
    h.idpersonnel::varchar AS idpersonnel,
    COALESCE(h.donnees_apres #>> '{paie,matricule}', h.donnees_avant #>> '{paie,matricule}')::varchar AS matricule,
    COALESCE(h.donnees_apres #>> '{personnel,nom}', h.donnees_avant #>> '{personnel,nom}')::varchar AS nom,
    COALESCE(h.donnees_apres #>> '{personnel,prenom}', h.donnees_avant #>> '{personnel,prenom}')::varchar AS prenom,
    h.typeevenement::varchar AS typeevenement,
    h.date_mouvement::date AS date_mouvement,
    CASE WHEN h.typeevenement IN ('EMBAUCHE', 'BASELINE') THEN NULL ELSE
        COALESCE(
            (SELECT ld.val::varchar
             FROM public.log_direction ld
             WHERE ld.id::varchar = h.donnees_avant #>> '{personnel,direction}'
             LIMIT 1),
            h.donnees_avant #>> '{personnel,direction}'
        )
    END AS ancienne_direction,
    COALESCE(
        (SELECT ld.val::varchar
         FROM public.log_direction ld
         WHERE ld.id::varchar = h.donnees_apres #>> '{personnel,direction}'
         LIMIT 1),
        h.donnees_apres #>> '{personnel,direction}'
    )::varchar AS nouvelle_direction,
    CASE WHEN h.typeevenement IN ('EMBAUCHE', 'BASELINE') THEN NULL ELSE
        COALESCE(
            (SELECT ls.desce::varchar
             FROM public.log_service_crt ls
             WHERE ls.val::varchar = h.donnees_avant #>> '{personnel,service}'
             LIMIT 1),
            h.donnees_avant #>> '{personnel,service}'
        )
    END AS ancien_service,
    COALESCE(
        (SELECT ls.desce::varchar
         FROM public.log_service_crt ls
         WHERE ls.val::varchar = h.donnees_apres #>> '{personnel,service}'
         LIMIT 1),
        h.donnees_apres #>> '{personnel,service}'
    )::varchar AS nouveau_service,
    CASE WHEN h.typeevenement IN ('EMBAUCHE', 'BASELINE') THEN NULL ELSE
        COALESCE(
            (SELECT pf.desce::varchar
             FROM public.paie_fonction pf
             WHERE pf.id::varchar = h.donnees_avant #>> '{paie,idfonction}'
             LIMIT 1),
            h.donnees_avant #>> '{paie,idfonction}'
        )
    END AS ancienne_fonction,
    COALESCE(
        (SELECT pf.desce::varchar
         FROM public.paie_fonction pf
         WHERE pf.id::varchar = h.donnees_apres #>> '{paie,idfonction}'
         LIMIT 1),
        h.donnees_apres #>> '{paie,idfonction}'
    )::varchar AS nouvelle_fonction,
    COALESCE(
        NULLIF(h.donnees_apres #>> '{paie,date_depart}', '')::date,
        NULLIF(h.donnees_avant #>> '{paie,date_depart}', '')::date
    ) AS date_depart,
    h.donnees_avant::text AS donnees_avant,
    h.donnees_apres::text AS donnees_apres,
    CASE WHEN h.typeevenement IN ('EMBAUCHE', 'BASELINE') THEN NULL ELSE
        COALESCE(
            (SELECT dep.val::varchar
             FROM public.departement dep
             WHERE dep.id::varchar = COALESCE(
                 h.donnees_avant #>> '{paie,iddepartement}',
                 h.donnees_avant #>> '{personnel,iddepartement}'
             )
             LIMIT 1),
            COALESCE(
                h.donnees_avant #>> '{paie,iddepartement}',
                h.donnees_avant #>> '{personnel,iddepartement}'
            )
        )
    END AS ancien_departement,
    COALESCE(
        (SELECT dep.val::varchar
         FROM public.departement dep
         WHERE dep.id::varchar = COALESCE(
             h.donnees_apres #>> '{paie,iddepartement}',
             h.donnees_apres #>> '{personnel,iddepartement}'
         )
         LIMIT 1),
        COALESCE(
            h.donnees_apres #>> '{paie,iddepartement}',
            h.donnees_apres #>> '{personnel,iddepartement}'
        )
    )::varchar AS nouveau_departement
FROM public.paie_personnel_historique h;
