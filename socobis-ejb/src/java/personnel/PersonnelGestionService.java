package personnel;

import utilitaire.UtilDB;
import java.sql.*;

public class PersonnelGestionService {

    public PersonnelComplet lire(String id) throws Exception {
        if (id == null || id.trim().isEmpty()) throw new Exception("Identifiant manquant.");
        try (Connection connection = new UtilDB().GetConn();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT * FROM public.personnel_complet WHERE id = ?")) {
            statement.setString(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) throw new Exception("Personnel introuvable.");
                PersonnelComplet p = new PersonnelComplet();
                p.setId(result.getString("id"));
                p.setNom(result.getString("nom"));
                p.setTelephone(result.getString("telephone"));
                p.setMail(result.getString("mail"));
                p.setAdresse(result.getString("adresse"));
                p.setRemarque(result.getString("remarque"));
                p.setCompte(result.getString("compte"));
                p.setIdposte(result.getString("idposte"));
                p.setPoste(result.getString("poste"));
                p.setIdmagasin(result.getString("idmagasin"));
                p.setMagasin(result.getString("magasin"));
                p.setDateembauche(result.getDate("dateembauche"));
                p.setDatedebauche(result.getDate("datedebauche"));
                p.setActif(result.getBoolean("actif"));
                return p;
            }
        }
    }

    public String enregistrer(String id, String nom, String telephone, String mail,
            String adresse, String remarque, String compte, String idposte,
            String idmagasin, String dateEmbauche, String utilisateur) throws Exception {
        if (nom == null || nom.trim().isEmpty()) throw new Exception("Le nom est obligatoire.");
        if (utilisateur == null || utilisateur.trim().isEmpty()) throw new Exception("Utilisateur non identifié.");
        if (idposte == null || idposte.trim().isEmpty()) throw new Exception("Le poste est obligatoire.");
        if (idmagasin == null || idmagasin.trim().isEmpty()) throw new Exception("Le magasin est obligatoire.");
        
        Date embauche;
        try {
            embauche = Date.valueOf(dateEmbauche);
        } catch (Exception e) {
            throw new Exception("Date d'embauche invalide.", e);
        }

        Connection connection = null;
        try {
            connection = new UtilDB().GetConn();
            connection.setAutoCommit(false);

            boolean nouveau = id == null || id.trim().isEmpty();
            String ancienPoste = null, ancienMagasin = null, avant = null;
            
            if (nouveau) {
                Personnel p = new Personnel();
                p.construirePK(connection);
                id = p.getId();
                try (PreparedStatement insert = connection.prepareStatement(
                        "INSERT INTO public.personnel (id, nom, telephone, mail, adresse, remarque, compte) VALUES (?, ?, ?, ?, ?, ?, ?)")) {
                    insert.setString(1, id);
                    insert.setString(2, nom.trim());
                    insert.setString(3, blankToNull(telephone));
                    insert.setString(4, blankToNull(mail));
                    insert.setString(5, blankToNull(adresse));
                    insert.setString(6, blankToNull(remarque));
                    insert.setString(7, blankToNull(compte));
                    insert.executeUpdate();
                }
            } else {
                verrouillerPersonnel(connection, id);
                avant = snapshot(connection, id);
                String[] affectation = lireAffectation(connection, id, true);
                if (affectation != null) {
                    ancienPoste = affectation[0];
                    ancienMagasin = affectation[1];
                }
                try (PreparedStatement update = connection.prepareStatement(
                        "UPDATE public.personnel SET nom=?, telephone=?, mail=?, adresse=?, remarque=?, compte=? WHERE id=?")) {
                    update.setString(1, nom.trim());
                    update.setString(2, blankToNull(telephone));
                    update.setString(3, blankToNull(mail));
                    update.setString(4, blankToNull(adresse));
                    update.setString(5, blankToNull(remarque));
                    update.setString(6, blankToNull(compte));
                    update.setString(7, id);
                    if (update.executeUpdate() != 1) throw new Exception("Personnel introuvable.");
                }
            }


            try (PreparedStatement upsert = connection.prepareStatement(
                    "INSERT INTO public.personnel_professionnel (idpersonnel, idposte, idmagasin, dateembauche, actif) " +
                    "VALUES (?, ?, ?, ?, TRUE) " +
                    "ON CONFLICT (idpersonnel) DO UPDATE SET idposte=EXCLUDED.idposte, idmagasin=EXCLUDED.idmagasin, " +
                    "dateembauche=COALESCE(personnel_professionnel.dateembauche, EXCLUDED.dateembauche)")) {
                upsert.setString(1, id);
                upsert.setString(2, idposte);
                upsert.setString(3, idmagasin);
                upsert.setDate(4, embauche);
                upsert.executeUpdate();
            }

            String apres = snapshot(connection, id);
            String type = nouveau ? "EMBAUCHE" : (!equal(ancienPoste, idposte) || !equal(ancienMagasin, idmagasin)) ? "MOUVEMENT" : "MODIFICATION";
            insererMouvement(connection, id, type, nouveau ? embauche : new Date(System.currentTimeMillis()),
                    ancienPoste, idposte, ancienMagasin, idmagasin, remarque, utilisateur, avant, apres);
            
            connection.commit();
            return id;
        } catch (Exception e) {
            if (connection != null) try { connection.rollback(); } catch (SQLException ex) { e.addSuppressed(ex); }
            throw e;
        } finally {
            if (connection != null) connection.close();
        }
    }

    public void debaucher(String id, String dateDebauche, String remarque, String utilisateur) throws Exception {
        if (id == null || id.trim().isEmpty()) throw new Exception("Identifiant manquant.");
        if (utilisateur == null || utilisateur.trim().isEmpty()) throw new Exception("Utilisateur non identifié.");
        
        Date date;
        try {
            date = Date.valueOf(dateDebauche);
        } catch (Exception e) {
            throw new Exception("Date de débauche invalide.", e);
        }

        Connection connection = null;
        try {
            connection = new UtilDB().GetConn();
            connection.setAutoCommit(false);
            verrouillerPersonnel(connection, id);
            

            Date embauche = null;
            try (PreparedStatement ps = connection.prepareStatement("SELECT dateembauche FROM personnel_professionnel WHERE idpersonnel = ?")) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) embauche = rs.getDate("dateembauche");
                }
            }
            if (embauche != null && date.before(embauche)) {
                throw new Exception("La date de débauche ne peut pas être antérieure à la date d'embauche.");
            }

            String avant = snapshot(connection, id);
            String[] affectation = lireAffectation(connection, id, true);
            if (affectation == null || "false".equals(affectation[2])) {
                throw new Exception("Ce personnel est déjà débauché ou introuvable.");
            }
            
            try (PreparedStatement update = connection.prepareStatement(
                    "UPDATE public.personnel_professionnel SET actif = FALSE, datedebauche = ? WHERE idpersonnel = ? AND actif = TRUE")) {
                update.setDate(1, date);
                update.setString(2, id);
                if (update.executeUpdate() != 1) throw new Exception("Le personnel est déjà débauché.");
            }
            
            String apres = snapshot(connection, id);
            insererMouvement(connection, id, "DEBAUCHE", date, affectation[0], null, affectation[1], null, remarque, utilisateur, avant, apres);
            connection.commit();
        } catch (Exception e) {
            if (connection != null) try { connection.rollback(); } catch (SQLException ex) { e.addSuppressed(ex); }
            throw e;
        } finally {
            if (connection != null) connection.close();
        }
    }

    // Méthodes privées (inchangées, sauf verrouillerPersonnel)
    private void verrouillerPersonnel(Connection connection, String id) throws Exception {
        try (PreparedStatement statement = connection.prepareStatement("SELECT id FROM public.personnel WHERE id = ? FOR UPDATE")) {
            statement.setString(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) throw new Exception("Personnel introuvable.");
            }
        }
    }

    private String[] lireAffectation(Connection connection, String id, boolean lock) throws Exception {
        String sql = "SELECT idposte, idmagasin, actif FROM public.personnel_professionnel WHERE idpersonnel = ?" + (lock ? " FOR UPDATE" : "");
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) return null;
                return new String[]{result.getString("idposte"), result.getString("idmagasin"), String.valueOf(result.getBoolean("actif"))};
            }
        }
    }

    private String snapshot(Connection connection, String id) throws Exception {
        try (PreparedStatement statement = connection.prepareStatement(
                "SELECT jsonb_build_object('personnel', to_jsonb(p), 'professionnel', to_jsonb(pp))::TEXT " +
                "FROM public.personnel p LEFT JOIN public.personnel_professionnel pp ON pp.idpersonnel = p.id WHERE p.id = ?")) {
            statement.setString(1, id);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) throw new Exception("Impossible de lire le dossier.");
                return result.getString(1);
            }
        }
    }

    private void insererMouvement(Connection connection, String id, String type, Date date,
            String ancienPoste, String nouveauPoste, String ancienMagasin, String nouveauMagasin,
            String remarque, String utilisateur, String avant, String apres) throws Exception {
        try (PreparedStatement statement = connection.prepareStatement(
                "INSERT INTO public.personnel_mouvement (idpersonnel, typeevenement, date_mouvement, ancien_idposte, nouveau_idposte, " +
                "ancien_idmagasin, nouveau_idmagasin, remarque, utilisateur, donnees_avant, donnees_apres) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?::JSONB, ?::JSONB)")) {
            statement.setString(1, id);
            statement.setString(2, type);
            statement.setDate(3, date);
            statement.setString(4, ancienPoste);
            statement.setString(5, nouveauPoste);
            statement.setString(6, ancienMagasin);
            statement.setString(7, nouveauMagasin);
            statement.setString(8, blankToNull(remarque));
            statement.setString(9, utilisateur);
            statement.setString(10, avant);
            statement.setString(11, apres);
            statement.executeUpdate();
        }
    }

    private String blankToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }

    private boolean equal(String left, String right) {
        return left == null ? right == null || right.trim().isEmpty() : left.equals(right == null ? null : right.trim());
    }
}