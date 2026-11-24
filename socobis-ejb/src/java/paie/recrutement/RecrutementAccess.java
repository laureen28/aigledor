package paie.recrutement;

import user.UserEJB;

public final class RecrutementAccess {

    private RecrutementAccess() {
    }

    public static void verifier(UserEJB utilisateur) throws Exception {
        if (utilisateur == null || utilisateur.getUser() == null) {
            throw new Exception("Session utilisateur expirée.");
        }
    }
}
