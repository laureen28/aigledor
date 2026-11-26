<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="personnel.PersonnelMouvementLib" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>

<%!
    private String mouvementHtml(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    private String mouvementValeur(String value) {
        return value == null || value.trim().isEmpty() ? "—" : mouvementHtml(value);
    }
%>
<%
    String idpersonnel = request.getParameter("idpersonnel");
    String nom = request.getParameter("nom");
    String typeevenement = request.getParameter("typeevenement");
    idpersonnel = idpersonnel == null ? "" : idpersonnel.trim();
    nom = nom == null ? "" : nom.trim();
    typeevenement = typeevenement == null ? "" : typeevenement.trim();

    List<PersonnelMouvementLib> mouvements = new ArrayList<PersonnelMouvementLib>();
    String erreur = null;
    try {
        if (session.getAttribute("u") == null) {
            throw new IllegalStateException("Session utilisateur absente. Veuillez vous reconnecter.");
        }

        StringBuilder sql = new StringBuilder(
                "SELECT id, idpersonnel, nom, typeevenement, date_mouvement, " +
                "ancien_poste, nouveau_poste, ancien_magasin, nouveau_magasin, remarque, utilisateur " +
                "FROM public.personnel_mouvement_lib WHERE 1 = 1");
        List<String> parametres = new ArrayList<String>();
        if (!idpersonnel.isEmpty()) {
            sql.append(" AND idpersonnel = ?");
            parametres.add(idpersonnel);
        }
        if (!nom.isEmpty()) {
            sql.append(" AND nom ILIKE ?");
            parametres.add("%" + nom + "%");
        }
        if (!typeevenement.isEmpty()) {
            sql.append(" AND typeevenement = ?");
            parametres.add(typeevenement);
        }
        sql.append(" ORDER BY date_mouvement DESC, id DESC");

        try (Connection connection = new UtilDB().GetConn();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < parametres.size(); i++) {
                statement.setString(i + 1, parametres.get(i));
            }
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    PersonnelMouvementLib mouvement = new PersonnelMouvementLib();
                    mouvement.setId(result.getString("id"));
                    mouvement.setIdpersonnel(result.getString("idpersonnel"));
                    mouvement.setNom(result.getString("nom"));
                    mouvement.setTypeevenement(result.getString("typeevenement"));
                    mouvement.setDate_mouvement(result.getDate("date_mouvement"));
                    mouvement.setAncien_poste(result.getString("ancien_poste"));
                    mouvement.setNouveau_poste(result.getString("nouveau_poste"));
                    mouvement.setAncien_magasin(result.getString("ancien_magasin"));
                    mouvement.setNouveau_magasin(result.getString("nouveau_magasin"));
                    mouvement.setRemarque(result.getString("remarque"));
                    mouvement.setUtilisateur(result.getString("utilisateur"));
                    mouvements.add(mouvement);
                }
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
        erreur = e.getMessage() == null ? e.getClass().getSimpleName() : e.getMessage();
    }
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Historique des mouvements du personnel</h1>
    </section>
    <section class="content">
        <% if (erreur != null) { %>
        <div class="alert alert-danger">
            Impossible de charger l'historique RH : <%= mouvementHtml(erreur) %>
            Vérifiez notamment que la migration du 23-11-2026 a été exécutée.
        </div>
        <% } else { %>
        <form action="module.jsp" method="get" class="form-inline">
            <input type="hidden" name="but" value="personnel/personnel-mouvement-liste.jsp">
            <div class="form-group">
                <label for="idpersonnel">Id personnel</label>
                <input class="form-control" type="text" id="idpersonnel" name="idpersonnel"
                       value="<%= mouvementHtml(idpersonnel) %>">
            </div>
            <div class="form-group">
                <label for="nom">Nom</label>
                <input class="form-control" type="text" id="nom" name="nom"
                       value="<%= mouvementHtml(nom) %>">
            </div>
            <div class="form-group">
                <label for="typeevenement">Événement</label>
                <select class="form-control" id="typeevenement" name="typeevenement">
                    <option value="">Tous</option>
                    <%
                        String[] types = {"EMBAUCHE", "MOUVEMENT", "MODIFICATION", "DEBAUCHE"};
                        for (String type : types) {
                    %>
                    <option value="<%= type %>" <%= type.equals(typeevenement) ? "selected" : "" %>><%= type %></option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">Filtrer</button>
            <a class="btn btn-default" href="module.jsp?but=personnel/personnel-mouvement-liste.jsp">Réinitialiser</a>
        </form>

        <div class="table-responsive" style="margin-top: 20px;">
            <table class="table table-bordered table-striped">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Id personnel</th>
                        <th>Nom</th>
                        <th>Événement</th>
                        <th>Ancien poste</th>
                        <th>Nouveau poste</th>
                        <th>Ancien magasin</th>
                        <th>Nouveau magasin</th>
                        <th>Remarque</th>
                        <th>Utilisateur</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (mouvements.isEmpty()) { %>
                    <tr><td colspan="10">Aucun mouvement trouvé.</td></tr>
                    <% } else {
                        for (PersonnelMouvementLib mouvement : mouvements) {
                    %>
                    <tr>
                        <td><%= mouvement.getDate_mouvement() == null ? "—" : mouvement.getDate_mouvement() %></td>
                        <td><%= mouvementValeur(mouvement.getIdpersonnel()) %></td>
                        <td><%= mouvementValeur(mouvement.getNom()) %></td>
                        <td><%= mouvementValeur(mouvement.getTypeevenement()) %></td>
                        <td><%= mouvementValeur(mouvement.getAncien_poste()) %></td>
                        <td><%= mouvementValeur(mouvement.getNouveau_poste()) %></td>
                        <td><%= mouvementValeur(mouvement.getAncien_magasin()) %></td>
                        <td><%= mouvementValeur(mouvement.getNouveau_magasin()) %></td>
                        <td><%= mouvementValeur(mouvement.getRemarque()) %></td>
                        <td><%= mouvementValeur(mouvement.getUtilisateur()) %></td>
                    </tr>
                    <%  }
                    } %>
                </tbody>
            </table>
        </div>
        <% } %>
    </section>
</div>
