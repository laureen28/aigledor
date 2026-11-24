package paie.recrutement;

import bean.CGenUtil;
import bean.ClassEtat;
import reporting.mail.Mail;
import reporting.mail.MailRappel;
import reporting.utilitaire.ConstanteCR;
import utilitaire.UtilDB;
import utils.ConstanteAxelle;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class Candidatures extends ClassEtat {
    private String id;
    private String idcandidat;
    private String idoffreemploie;
    private Date dateapplication;
    private String remarque;
    private String raisonrefus;
    private Double scorequalification;

    public Double getScorequalification() {
        return scorequalification;
    }

    public void setScorequalification(Double scorequalification) {
        this.scorequalification = scorequalification;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIdcandidat() {
        return idcandidat;
    }

    public void setIdcandidat(String idcandidat) {
        this.idcandidat = idcandidat;
    }

    public String getIdoffreemploie() {
        return idoffreemploie;
    }

    public void setIdoffreemploie(String idoffreemploie) {
        this.idoffreemploie = idoffreemploie;
    }

    public Date getDateapplication() {
        return dateapplication;
    }

    public void setDateapplication(Date dateapplication) {
        this.dateapplication = dateapplication;
    }

    public String getRemarque() {
        return remarque;
    }

    public void setRemarque(String remarque) {
        this.remarque = remarque;
    }

    public String getRaisonrefus() {
        return raisonrefus;
    }

    public void setRaisonrefus(String raisonrefus) {
        this.raisonrefus = raisonrefus;
    }



    public Candidatures() throws Exception {
        this.setNomTable("CANDIDATURES");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("CDT","getseq_candidatures");
        this.setId(makePK(c));
    }

    @Override
    public String getTuppleID() {
        return id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    public void retenir(String utilisateur) throws Exception {
        Connection c = null;
        try {
            if (this.getId() == null || this.getId().trim().isEmpty()) {
                throw new Exception("Identifiant de candidature manquant.");
            }
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);

            Candidatures critere = new Candidatures();
            Candidatures[] candidatures = (Candidatures[]) CGenUtil.rechercher(
                    critere, null, null, c,
                    " AND id = '" + this.getId().replace("'", "''") + "'"
            );
            if (candidatures == null || candidatures.length == 0) {
                throw new Exception("Candidature introuvable.");
            }

            Candidatures candidature = candidatures[0];
            if (candidature.getEtat() != constante.ConstanteEtat.getEtatCreer()) {
                throw new Exception("Seule une candidature créée peut être retenue.");
            }
            if (candidature.getScorequalification() == null) {
                throw new Exception("Le score du candidat n'est pas renseigné.");
            }
            if (candidature.getScorequalification() < 0) {
                throw new Exception("Le score du candidat ne peut pas être négatif.");
            }
            if (Double.isNaN(candidature.getScorequalification()) || Double.isInfinite(candidature.getScorequalification())) {
                throw new Exception("Le score du candidat doit être un nombre décimal valide.");
            }
            if (candidature.getIdoffreemploie() == null || candidature.getIdoffreemploie().trim().isEmpty()) {
                throw new Exception("Aucune offre n'est associée à cette candidature.");
            }

            OffreEmploi offreCritere = new OffreEmploi();
            OffreEmploi[] offres = (OffreEmploi[]) CGenUtil.rechercher(
                    offreCritere, null, null, c,
                    " AND id = '" + candidature.getIdoffreemploie().replace("'", "''") + "'"
            );
            if (offres == null || offres.length == 0) {
                throw new Exception("L'offre d'emploi associée à cette candidature est introuvable.");
            }
            if (offres[0].getIdficheposte() == null || offres[0].getIdficheposte().trim().isEmpty()) {
                throw new Exception("L'offre n'est associée à aucune fiche de poste.");
            }

            BigDecimal seuil;
            try (PreparedStatement poste = c.prepareStatement(
                    "SELECT scoreminimum FROM public.fiche_poste WHERE id = ?")) {
                poste.setString(1, offres[0].getIdficheposte());
                try (ResultSet result = poste.executeQuery()) {
                    if (!result.next()) {
                        throw new Exception("La fiche de poste associée à cette offre est introuvable.");
                    }
                    seuil = result.getBigDecimal("scoreminimum");
                }
            }
            if (seuil == null) {
                throw new Exception("Le score minimum n'est pas renseigné sur la fiche de poste.");
            }
            if (seuil.signum() < 0) {
                throw new Exception("Le score minimum ne peut pas être négatif.");
            }
            BigDecimal score = BigDecimal.valueOf(candidature.getScorequalification());
            if (score.compareTo(seuil) < 0) {
                throw new Exception("Candidat non retenu : son score (" + candidature.getScorequalification()
                        + ") est inférieur au minimum requis pour ce poste (" + seuil + ").");
            }

            candidature.setEtat(constante.ConstanteEtat.getEtatValider());
            candidature.updateToTableWithHisto(utilisateur, c);
            c.commit();
        } catch (Exception e) {
            if (c != null) {
                c.rollback();
            }
            throw e;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }


    public void refuser(String u) throws Exception {
        Connection c = null;
        try {
            if (c == null){
                UtilDB util = new UtilDB();
                c = util.GetConn();
                c.setAutoCommit(false);
            }
            Candidatures candidatures = new Candidatures();
            candidatures.setId(this.getId());
            Candidatures[] candidatures1 = (Candidatures[]) CGenUtil.rechercher(candidatures, null, null, "");
            if (candidatures1.length > 0) {
                candidatures = candidatures1[0];
                if (candidatures.getEtat() > -1){
                    candidatures.setEtat(-1);
                    candidatures.updateToTableWithHisto(u, c);
                    Candidat candidat = new Candidat();
                    candidat.setId(candidatures.getIdcandidat());
                    Candidat[] candidats = (Candidat[]) CGenUtil.rechercher(candidat, null, null, "");
                    if (candidats.length > 0){
                        candidat = candidats[0];
                    } else {
                        throw new Exception("Candidat non trouve!");
                    }

                    MailRappel mailRappel = new MailRappel();
                    mailRappel.setNom("Axelle");
                    mailRappel.setTitre("Suite à votre candidature - Réponse négative");
                    String[] contacts = new String[]{
                            ConstanteAxelle.addresse1,
                            ConstanteAxelle.addresse2,
                    };
                    mailRappel.setContacts(contacts);
                    String[] paragraphes = new String[] {
                            "Nous vous remercions pour l'intéret que vous avez porté à notre entreprise ainsi que pour le temps consacré à votre candidature.",

                            "Après une analyse attentive de votre profil, nous regrettons de vous informer que votre candidature n'a pas été retenue pour ce poste.",

                            "Nous avons recu un grand nombre de candidatures et avons sélectionné des profils correspondant davantage aux critères spécifiques du poste.",

                            "Nous vous encourageons à consulter régulièrement nos futures opportunités et à postuler de nouveau si une offre correspond à votre profil.",

                            "Nous vous souhaitons une bonne continuation et plein succès dans vos projets professionnels."
                    };
                    mailRappel.setParagraphe(paragraphes);
                    String message = mailRappel.genererMailRappel();

                    Mail mail = new Mail(ConstanteCR.getMailRapport()[0], ConstanteCR.getMailRapport()[1], "Refus", message);
                    mail.setTo(candidat.getEmail());
                    mail.send();
                } else {
                    throw new Exception("Candidature deja refuser");
                }
            } else {
                throw new Exception("Candidature introuvable!");
            }
        } catch (Exception e) {
            throw new Exception(e);
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }
}

