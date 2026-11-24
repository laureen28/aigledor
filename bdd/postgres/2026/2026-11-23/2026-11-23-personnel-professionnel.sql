CREATE SEQUENCE IF NOT EXISTS public.seq_personnel;

CREATE OR REPLACE FUNCTION public.get_seq_personnelle()
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT nextval('public.seq_personnel')::NUMERIC;
$$;

CREATE TABLE IF NOT EXISTS public.personnel_professionnel (
    idpersonnel VARCHAR(50) PRIMARY KEY
        REFERENCES public.personnel(id),
    idposte VARCHAR(50),
    idmagasin VARCHAR(50),
    dateembauche DATE NOT NULL DEFAULT CURRENT_DATE,
    datedebauche DATE,
    actif BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS public.personnel_mouvement (
    id BIGSERIAL PRIMARY KEY,
    idpersonnel VARCHAR(50) NOT NULL
        REFERENCES public.personnel(id),
    typeevenement VARCHAR(20) NOT NULL
        CHECK (typeevenement IN ('EMBAUCHE', 'MOUVEMENT', 'MODIFICATION', 'DEBAUCHE')),
    date_mouvement DATE NOT NULL DEFAULT CURRENT_DATE,
    ancien_idposte VARCHAR(50),
    nouveau_idposte VARCHAR(50),
    ancien_idmagasin VARCHAR(50),
    nouveau_idmagasin VARCHAR(50),
    remarque TEXT,
    utilisateur VARCHAR(255) NOT NULL,
    donnees_avant JSONB,
    donnees_apres JSONB
);

CREATE OR REPLACE VIEW public.personnel_complet AS
SELECT
    p.id,
    p.nom,
    p.telephone,
    p.mail,
    p.adresse,
    p.remarque,
    p.compte,
    pp.idposte,
    poste.val AS poste,
    pp.idmagasin,
    magasin.val AS magasin,
    pp.dateembauche,
    pp.datedebauche,
    COALESCE(pp.actif, TRUE) AS actif
FROM public.personnel p
LEFT JOIN public.personnel_professionnel pp ON pp.idpersonnel = p.id
LEFT JOIN public.poste poste ON poste.id::VARCHAR = pp.idposte
LEFT JOIN public.magasin2 magasin ON magasin.id::VARCHAR = pp.idmagasin;

CREATE OR REPLACE VIEW public.personnel_mouvement_lib AS
SELECT
    mouvement.id::VARCHAR AS id,
    mouvement.idpersonnel,
    personnel.nom,
    personnel.telephone,
    mouvement.typeevenement,
    mouvement.date_mouvement,
    mouvement.ancien_idposte,
    ancien_poste.val AS ancien_poste,
    mouvement.nouveau_idposte,
    nouveau_poste.val AS nouveau_poste,
    mouvement.ancien_idmagasin,
    ancien_magasin.val AS ancien_magasin,
    mouvement.nouveau_idmagasin,
    nouveau_magasin.val AS nouveau_magasin,
    mouvement.remarque,
    mouvement.utilisateur,
    mouvement.donnees_avant::TEXT AS donnees_avant,
    mouvement.donnees_apres::TEXT AS donnees_apres
FROM public.personnel_mouvement mouvement
JOIN public.personnel personnel ON personnel.id = mouvement.idpersonnel
LEFT JOIN public.poste ancien_poste ON ancien_poste.id::VARCHAR = mouvement.ancien_idposte
LEFT JOIN public.poste nouveau_poste ON nouveau_poste.id::VARCHAR = mouvement.nouveau_idposte
LEFT JOIN public.magasin2 ancien_magasin ON ancien_magasin.id::VARCHAR = mouvement.ancien_idmagasin
LEFT JOIN public.magasin2 nouveau_magasin ON nouveau_magasin.id::VARCHAR = mouvement.nouveau_idmagasin;

UPDATE public.menudynamique
SET href = 'module.jsp?but=personnel/personnel-mouvement-liste.jsp'
WHERE id = 'MENDYN261120005';
