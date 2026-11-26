package paie.recrutement;

import bean.CGenUtil;
import bean.ClassEtat;
import reporting.mail.Mail;
import reporting.mail.MailRappel;
import reporting.utilitaire.ConstanteCR;
import personnel.PersonnelGestionService;
import utilitaire.UtilDB;
import utils.ConstanteAxelle;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;

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
            Candidatures candidature = chargerCandidature(c, this.getId());
            if (candidature.getEtat() != constante.ConstanteEtat.getEtatCreer()) {
                throw new Exception("Seule une candidature créée peut être retenue.");
            }
            verifierQualification(c, candidature);

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

    public String embaucher(String utilisateur) throws Exception {
        Connection c = null;
        try {
            if (this.getId() == null || this.getId().trim().isEmpty()) {
                throw new Exception("Identifiant de candidature manquant.");
            }
            if (utilisateur == null || utilisateur.trim().isEmpty()) {
                throw new Exception("Utilisateur non identifié.");
            }

            c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            Candidatures candidature = chargerCandidature(c, this.getId());
            int etatValider = constante.ConstanteEtat.getEtatValider();
            if (candidature.getEtat() != constante.ConstanteEtat.getEtatCreer()
                    && candidature.getEtat() != etatValider) {
                throw new Exception("Seule une candidature créée ou retenue peut être embauchée.");
            }
            verifierQualification(c, candidature);

            Candidat candidat = chargerCandidat(c, candidature.getIdcandidat());
            if (candidat.getIdpersonnel() != null && !candidat.getIdpersonnel().trim().isEmpty()) {
                throw new Exception("Une fiche personnelle existe déjà pour ce candidat.");
            }
            try (PreparedStatement query = c.prepareStatement(
                    "SELECT 1 FROM public.candidatures WHERE idcandidat = ? AND etat = 13 LIMIT 1")) {
                query.setString(1, candidat.getId());
                try (ResultSet result = query.executeQuery()) {
                    if (result.next()) {
                        throw new Exception("Ce candidat a déjà été embauché sur une autre candidature.");
                    }
                }
            }

            Date dateEmbauche = Date.valueOf(LocalDate.now().plusDays(7));
            String idPersonnel = new PersonnelGestionService().creerDepuisEmbauche(
                    c, candidat.getNom(), candidat.getPrenom(), candidat.getTelephone(),
                    candidat.getEmail(), candidat.getAdresse(), candidat.getRemarque(),
                    candidat.getCompte(), candidat.getIdposte(), candidat.getIdmagasin(),
                    dateEmbauche, utilisateur);

            try (PreparedStatement update = c.prepareStatement(
                    "UPDATE public.candidat SET idpersonnel = ? WHERE id = ? " +
                    "AND (idpersonnel IS NULL OR BTRIM(idpersonnel) = '')")) {
                update.setString(1, idPersonnel);
                update.setString(2, candidat.getId());
                if (update.executeUpdate() != 1) {
                    throw new Exception("Le lien vers la fiche personnelle n'a pas pu être enregistré.");
                }
            }

            candidature.setEtat(13);
            candidature.updateToTableWithHisto(utilisateur, c);
            c.commit();
            return idPersonnel;
        } catch (Exception e) {
            if (c != null) {
                try {
                    c.rollback();
                } catch (Exception rollbackError) {
                    e.addSuppressed(rollbackError);
                }
            }
            throw e;
        } finally {
            if (c != null) {
                c.close();
            }
        }
    }

    private Candidatures chargerCandidature(Connection connection, String id) throws Exception {
        Candidatures candidature = new Candidatures();
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT id, idcandidat, idoffreemploie, dateapplication, remarque, raisonrefus, scorequalification, etat " +
                "FROM public.candidatures WHERE id = ? FOR UPDATE")) {
            statement.setString(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) throw new Exception("Candidature introuvable.");
                candidature.setId(result.getString("id"));
                candidature.setIdcandidat(result.getString("idcandidat"));
                candidature.setIdoffreemploie(result.getString("idoffreemploie"));
                candidature.setDateapplication(result.getDate("dateapplication"));
                candidature.setRemarque(result.getString("remarque"));
                candidature.setRaisonrefus(result.getString("raisonrefus"));
                double score = result.getDouble("scorequalification");
                candidature.setScorequalification(result.wasNull() ? null : score);
                candidature.setEtat(result.getInt("etat"));
            }
        }
        return candidature;
    }

    private Candidat chargerCandidat(Connection connection, String id) throws Exception {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT id, nom, prenom, email, telephone, adresse, idqualification, remarque, " +
                "idposte, idmagasin, idpersonnel, direction, compte FROM public.candidat WHERE id = ? FOR UPDATE")) {
            statement.setString(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) throw new Exception("Candidat introuvable.");
                Candidat candidat = new Candidat();
                candidat.setId(result.getString("id"));
                candidat.setNom(result.getString("nom"));
                candidat.setPrenom(result.getString("prenom"));
                candidat.setEmail(result.getString("email"));
                candidat.setTelephone(result.getString("telephone"));
                candidat.setAdresse(result.getString("adresse"));
                candidat.setIdqualification(result.getString("idqualification"));
                candidat.setRemarque(result.getString("remarque"));
                candidat.setIdposte(result.getString("idposte"));
                candidat.setIdmagasin(result.getString("idmagasin"));
                candidat.setIdpersonnel(result.getString("idpersonnel"));
                candidat.setDirection(result.getString("direction"));
                candidat.setCompte(result.getString("compte"));
                return candidat;
            }
        }
    }

    private void verifierQualification(Connection connection, Candidatures candidature) throws Exception {
        if (candidature.getScorequalification() == null) {
            throw new Exception("Le score du candidat n'est pas renseigné.");
        }
        if (candidature.getScorequalification() < 0) {
            throw new Exception("Le score du candidat ne peut pas être négatif.");
        }
        if (Double.isNaN(candidature.getScorequalification()) || Double.isInfinite(candidature.getScorequalification())) {
            throw new Exception("Le score du candidat doit être un nombre décimal valide.");
        }
        if (candidature.getIdcandidat() == null || candidature.getIdcandidat().trim().isEmpty()) {
            throw new Exception("Aucun candidat n'est associé à cette candidature.");
        }

        String idPoste;
        try (PreparedStatement candidat = connection.prepareStatement(
                "SELECT idposte FROM public.candidat WHERE id = ? FOR SHARE")) {
            candidat.setString(1, candidature.getIdcandidat());
            try (ResultSet result = candidat.executeQuery()) {
                if (!result.next()) {
                    throw new Exception("Le candidat associé à cette candidature est introuvable.");
                }
                idPoste = result.getString("idposte");
            }
        }
        if (idPoste == null || idPoste.trim().isEmpty()) {
            throw new Exception("Aucun poste n'est associé au candidat.");
        }

        BigDecimal seuil;
        try (PreparedStatement poste = connection.prepareStatement(
                "SELECT scoreminimum FROM public.poste WHERE id::VARCHAR = ? FOR SHARE")) {
            poste.setString(1, idPoste);
            try (ResultSet result = poste.executeQuery()) {
                if (!result.next()) {
                    throw new Exception("Le poste choisi par le candidat est introuvable.");
                }
                seuil = result.getBigDecimal("scoreminimum");
            }
        }
        if (seuil == null) {
            throw new Exception("Le score minimum n'est pas renseigné sur le poste choisi.");
        }
        if (seuil.signum() < 0) {
            throw new Exception("Le score minimum ne peut pas être négatif.");
        }
        BigDecimal score = BigDecimal.valueOf(candidature.getScorequalification());
        if (score.compareTo(seuil) < 0) {
            throw new Exception("Candidat non retenu : son score (" + candidature.getScorequalification()
                    + ") est inférieur au minimum requis pour ce poste (" + seuil + ").");
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

