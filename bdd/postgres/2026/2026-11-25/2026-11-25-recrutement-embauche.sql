ALTER TABLE public.candidat
    ADD COLUMN IF NOT EXISTS idposte VARCHAR(50),
    ADD COLUMN IF NOT EXISTS idmagasin VARCHAR(50),
    ADD COLUMN IF NOT EXISTS idpersonnel VARCHAR(50);

ALTER TABLE public.poste
    ADD COLUMN IF NOT EXISTS scoreminimum NUMERIC;

ALTER TABLE public.personnel
    ADD COLUMN IF NOT EXISTS prenom VARCHAR(255);

UPDATE public.candidat
SET idpersonnel = NULL
WHERE BTRIM(idpersonnel) = '';

CREATE UNIQUE INDEX IF NOT EXISTS uq_candidat_idpersonnel
    ON public.candidat (idpersonnel)
    WHERE idpersonnel IS NOT NULL AND BTRIM(idpersonnel) <> '';

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
    COALESCE(pp.actif, TRUE) AS actif,
    p.prenom
FROM public.personnel p
LEFT JOIN public.personnel_professionnel pp ON pp.idpersonnel = p.id
LEFT JOIN public.poste poste ON poste.id::VARCHAR = pp.idposte
LEFT JOIN public.magasin2 magasin ON magasin.id::VARCHAR = pp.idmagasin;

CREATE OR REPLACE VIEW public.candidatures_score_lib AS
SELECT
    cl.*,
    c.scorequalification,
    poste.scoreminimum
FROM public.candidatureslib cl
JOIN public.candidatures c ON c.id = cl.id
LEFT JOIN public.candidat candidat ON candidat.id = c.idcandidat
LEFT JOIN public.poste poste ON poste.id::VARCHAR = candidat.idposte;
