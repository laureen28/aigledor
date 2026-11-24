package paie.employe;

import utilitaire.UtilDB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class EmployeArchiveService {

    public void archiver(String idpersonnel, String utilisateur) throws Exception {
        if (idpersonnel == null || idpersonnel.trim().isEmpty()) {
            throw new Exception("Identifiant du personnel manquant.");
        }
        if (utilisateur == null || utilisateur.trim().isEmpty()) {
            throw new Exception("Utilisateur non identifié.");
        }

        Connection connection = null;
        try {
            connection = new UtilDB().GetConn();
            connection.setAutoCommit(false);

            try (PreparedStatement employe = connection.prepareStatement(
                    "SELECT pi.id FROM public.paie_info_personnel pi "
                            + "JOIN public.log_personnel lp ON lp.id = pi.id "
                            + "WHERE pi.id = ? FOR UPDATE OF pi")) {
                employe.setString(1, idpersonnel);
                try (ResultSet result = employe.executeQuery()) {
                    if (!result.next()) {
                        throw new Exception("Dossier personnel introuvable.");
                    }
                }
            }

            try (PreparedStatement insert = connection.prepareStatement(
                    "INSERT INTO public.paie_personnel_archive (idpersonnel, archive_par) "
                            + "VALUES (?, ?) ON CONFLICT (idpersonnel) DO NOTHING")) {
                insert.setString(1, idpersonnel);
                insert.setString(2, utilisateur);
                if (insert.executeUpdate() == 0) {
                    throw new Exception("Ce dossier personnel est déjà archivé.");
                }
            }

            connection.commit();
        } catch (Exception e) {
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackError) {
                    e.addSuppressed(rollbackError);
                }
            }
            throw e;
        } finally {
            if (connection != null) {
                connection.close();
            }
        }
    }
}
