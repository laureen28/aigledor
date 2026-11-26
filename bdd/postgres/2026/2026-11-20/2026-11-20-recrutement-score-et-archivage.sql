ALTER TABLE public.candidat
    ADD COLUMN IF NOT EXISTS dateembauche DATE,
    ADD COLUMN IF NOT EXISTS matricule VARCHAR(100),
    ADD COLUMN IF NOT EXISTS idcivilite VARCHAR(50),
    ADD COLUMN IF NOT EXISTS lieu_naissance_commune VARCHAR(500),
    ADD COLUMN IF NOT EXISTS sexe VARCHAR(50),
    ADD COLUMN IF NOT EXISTS numero_cin VARCHAR(100),
    ADD COLUMN IF NOT EXISTS date_cin DATE,
    ADD COLUMN IF NOT EXISTS date_dupl_cin DATE,
    ADD COLUMN IF NOT EXISTS lieu_delivrance_cin VARCHAR(500),
    ADD COLUMN IF NOT EXISTS pere VARCHAR(500),
    ADD COLUMN IF NOT EXISTS mere VARCHAR(500),
    ADD COLUMN IF NOT EXISTS nationalite VARCHAR(150),
    ADD COLUMN IF NOT EXISTS fokotany VARCHAR(500),
    ADD COLUMN IF NOT EXISTS adresse TEXT,
    ADD COLUMN IF NOT EXISTS adresse_ligne1 TEXT,
    ADD COLUMN IF NOT EXISTS adresse_ligne2 TEXT,
    ADD COLUMN IF NOT EXISTS code_postal VARCHAR(50),
    ADD COLUMN IF NOT EXISTS direction VARCHAR(100),
    ADD COLUMN IF NOT EXISTS service VARCHAR(100),
    ADD COLUMN IF NOT EXISTS iddepartement VARCHAR(50),
    ADD COLUMN IF NOT EXISTS situation_matrimonial VARCHAR(50),
    ADD COLUMN IF NOT EXISTS acte_naissance VARCHAR(500),
    ADD COLUMN IF NOT EXISTS nbenfant INTEGER,
    ADD COLUMN IF NOT EXISTS cturgence_nom_prenom VARCHAR(500),
    ADD COLUMN IF NOT EXISTS cturgence_telephone1 VARCHAR(100),
    ADD COLUMN IF NOT EXISTS cturgence_telephone2 VARCHAR(100),
    ADD COLUMN IF NOT EXISTS cturgence_telephone3 VARCHAR(100),
    ADD COLUMN IF NOT EXISTS permis_conduire VARCHAR(100),
    ADD COLUMN IF NOT EXISTS initiale VARCHAR(100),
    ADD COLUMN IF NOT EXISTS idfonction VARCHAR(50),
    ADD COLUMN IF NOT EXISTS idcategorie VARCHAR(50),
    ADD COLUMN IF NOT EXISTS idcategorie_paie VARCHAR(50),
    ADD COLUMN IF NOT EXISTS idqualification VARCHAR(50),
    ADD COLUMN IF NOT EXISTS indicegrade VARCHAR(50),
    ADD COLUMN IF NOT EXISTS indice_fonctionnel VARCHAR(50),
    ADD COLUMN IF NOT EXISTS echelon VARCHAR(50),
    ADD COLUMN IF NOT EXISTS classee VARCHAR(50),
    ADD COLUMN IF NOT EXISTS statut VARCHAR(100),
    ADD COLUMN IF NOT EXISTS ctg VARCHAR(100),
    ADD COLUMN IF NOT EXISTS matricule_patron VARCHAR(100),
    ADD COLUMN IF NOT EXISTS droit_hs VARCHAR(50),
    ADD COLUMN IF NOT EXISTS vehiculee INTEGER,
    ADD COLUMN IF NOT EXISTS salairebase NUMERIC(18, 4),
    ADD COLUMN IF NOT EXISTS tauxhoraire NUMERIC(18, 4),
    ADD COLUMN IF NOT EXISTS numero_cnaps VARCHAR(100),
    ADD COLUMN IF NOT EXISTS numero_ostie VARCHAR(100),
    ADD COLUMN IF NOT EXISTS mode_paiement VARCHAR(50),
    ADD COLUMN IF NOT EXISTS idbanque VARCHAR(50),
    ADD COLUMN IF NOT EXISTS idagence VARCHAR(50),
    ADD COLUMN IF NOT EXISTS banque_numero_compte VARCHAR(100),
    ADD COLUMN IF NOT EXISTS banque_compte_cle VARCHAR(100),
    ADD COLUMN IF NOT EXISTS compte VARCHAR(100),
    ADD COLUMN IF NOT EXISTS idstatut VARCHAR(50),
    ADD COLUMN IF NOT EXISTS retraitecompl INTEGER,
    ADD COLUMN IF NOT EXISTS typecontrat VARCHAR(50),
    ADD COLUMN IF NOT EXISTS debutcontrat DATE,
    ADD COLUMN IF NOT EXISTS fincontrat DATE,
    ADD COLUMN IF NOT EXISTS temporaire INTEGER,
    ADD COLUMN IF NOT EXISTS indesirable INTEGER,
    ADD COLUMN IF NOT EXISTS duree NUMERIC(18, 4),
    ADD COLUMN IF NOT EXISTS region VARCHAR(100),
    ADD COLUMN IF NOT EXISTS formation VARCHAR(500),
    ADD COLUMN IF NOT EXISTS discipline VARCHAR(500),
    ADD COLUMN IF NOT EXISTS anneeexperience VARCHAR(100),
    ADD COLUMN IF NOT EXISTS remarque TEXT;

ALTER TABLE public.candidatures
    ADD COLUMN IF NOT EXISTS scorequalification NUMERIC;

ALTER TABLE public.fiche_poste
    ADD COLUMN IF NOT EXISTS scoreminimum NUMERIC;

CREATE OR REPLACE VIEW public.candidatures_score_lib AS
SELECT
    cl.*,
    c.scorequalification,
    fp.scoreminimum
FROM public.candidatureslib cl
JOIN public.candidatures c ON c.id = cl.id
LEFT JOIN public.offre_emploi o ON o.id = c.idoffreemploie
LEFT JOIN public.fiche_poste fp ON fp.id = o.idficheposte;

CREATE TABLE IF NOT EXISTS public.paie_personnel_archive (
    idpersonnel VARCHAR(50) PRIMARY KEY,
    date_archive TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    archive_par VARCHAR(255) NOT NULL
);

CREATE OR REPLACE VIEW public.paie_mouvement_personnel_historique_complet AS
SELECT historique.*
FROM public.paie_mouvement_personnel_historique historique
WHERE NOT (
    historique.typeevenement = 'SITUATION'
    AND EXISTS (
        SELECT 1
        FROM public.paie_personnel_archive archive
        WHERE archive.idpersonnel = historique.idpersonnel
    )
)
UNION ALL
SELECT
    ('ARCHIVE-' || archive.idpersonnel)::VARCHAR AS id,
    archive.idpersonnel::VARCHAR AS idpersonnel,
    p.matricule::VARCHAR AS matricule,
    lp.nom::VARCHAR AS nom,
    lp.prenom::VARCHAR AS prenom,
    'ARCHIVAGE'::VARCHAR AS typeevenement,
    archive.date_archive::DATE AS date_mouvement,
    COALESCE(
        (SELECT ld.val::VARCHAR FROM public.log_direction ld WHERE ld.id::VARCHAR = lp.direction::VARCHAR LIMIT 1),
        lp.direction::VARCHAR
    ) AS ancienne_direction,
    NULL::VARCHAR AS nouvelle_direction,
    COALESCE(
        (SELECT ls.desce::VARCHAR FROM public.log_service_crt ls WHERE ls.val::VARCHAR = lp.service::VARCHAR LIMIT 1),
        lp.service::VARCHAR
    ) AS ancien_service,
    NULL::VARCHAR AS nouveau_service,
    COALESCE(pf.desce::VARCHAR, p.idfonction::VARCHAR) AS ancienne_fonction,
    NULL::VARCHAR AS nouvelle_fonction,
    p.date_depart::DATE AS date_depart,
    jsonb_build_object('personnel', to_jsonb(lp), 'paie', to_jsonb(p))::TEXT AS donnees_avant,
    NULL::TEXT AS donnees_apres,
    COALESCE(
        (SELECT dep.val::VARCHAR FROM public.departement dep WHERE dep.id::VARCHAR = p.iddepartement::VARCHAR LIMIT 1),
        p.iddepartement::VARCHAR
    ) AS ancien_departement,
    NULL::VARCHAR AS nouveau_departement
FROM public.paie_personnel_archive archive
JOIN public.log_personnel lp ON lp.id::VARCHAR = archive.idpersonnel
LEFT JOIN public.paie_info_personnel p ON p.id::VARCHAR = archive.idpersonnel
LEFT JOIN public.paie_fonction pf ON pf.id::VARCHAR = p.idfonction::VARCHAR;

INSERT INTO public.menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN261120001', 'RH et Recrutement', 'groups', NULL, 12, 1, NULL)
ON CONFLICT (id) DO UPDATE SET
    libelle = EXCLUDED.libelle,
    icone = EXCLUDED.icone,
    href = EXCLUDED.href,
    rang = EXCLUDED.rang,
    niveau = EXCLUDED.niveau,
    id_pere = EXCLUDED.id_pere;

INSERT INTO public.menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES
    ('MENDYN261120002', 'Personnel', 'group', NULL, 1, 2, 'MENDYN261120001'),
    ('MENDYN261120003', 'Liste des employés', 'groups', 'module.jsp?but=personnel/personnel-liste.jsp', 1, 3, 'MENDYN261120002'),
    ('MENDYN261120004', 'Saisir un personnel', 'person_add', 'module.jsp?but=personnel/personnel-formulaire.jsp', 2, 3, 'MENDYN261120002'),
    ('MENDYN261120005', 'Historique et mouvements', 'history', 'module.jsp?but=personnel/personnel-mouvement-liste.jsp', 3, 3, 'MENDYN261120002'),
    ('MENDYN261120006', 'Recrutement', 'work', NULL, 2, 2, 'MENDYN261120001'),
    ('MENDYN261120007', 'Liste des candidats', 'groups', 'module.jsp?but=paie/recrutement/candidat-liste.jsp', 1, 3, 'MENDYN261120006'),
    ('MENDYN261120008', 'Saisir un candidat', 'person_add', 'module.jsp?but=paie/recrutement/candidat-saisie.jsp', 2, 3, 'MENDYN261120006'),
    ('MENDYN261120009', 'Suivi des candidatures', 'assignment', 'module.jsp?but=paie/recrutement/candidature-liste.jsp', 3, 3, 'MENDYN261120006'),
    ('MENDYN261120010', 'Offres d''emploi', 'work', 'module.jsp?but=paie/recrutement/offreemploi-liste.jsp', 4, 3, 'MENDYN261120006')
ON CONFLICT (id) DO UPDATE SET
    libelle = EXCLUDED.libelle,
    icone = EXCLUDED.icone,
    href = EXCLUDED.href,
    rang = EXCLUDED.rang,
    niveau = EXCLUDED.niveau,
    id_pere = EXCLUDED.id_pere;

INSERT INTO public.usermenu (id, idmenu, refuser, idrole, interdit)
VALUES
    ('UMRH26112001', 'MENDYN261120001', '*', NULL, 0),
    ('UMRH26112002', 'MENDYN261120002', '*', NULL, 0),
    ('UMRH26112003', 'MENDYN261120003', '*', NULL, 0),
    ('UMRH26112004', 'MENDYN261120004', '*', NULL, 0),
    ('UMRH26112005', 'MENDYN261120005', '*', NULL, 0),
    ('UMRH26112006', 'MENDYN261120006', '*', NULL, 0),
    ('UMRH26112007', 'MENDYN261120007', '*', NULL, 0),
    ('UMRH26112008', 'MENDYN261120008', '*', NULL, 0),
    ('UMRH26112009', 'MENDYN261120009', '*', NULL, 0),
    ('UMRH26112010', 'MENDYN261120010', '*', NULL, 0)
ON CONFLICT (id) DO UPDATE SET
    idmenu = EXCLUDED.idmenu,
    refuser = EXCLUDED.refuser,
    idrole = EXCLUDED.idrole,
    interdit = EXCLUDED.interdit;
