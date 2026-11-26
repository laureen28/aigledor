<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="bean.TypeObjet" %>
<%@ page import="annexe.Poste" %>
<%@ page import="magasin.Magasin" %>
<%@ page import="personnel.PersonnelComplet" %>
<%@ page import="personnel.PersonnelGestionService" %>
<%@ page import="java.sql.Date" %>

<%!
    private String personnelEscape(String value) {
        if (value == null) return "";
        return value.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }

    private String personnelErrorMessage(Exception error) {
        String message = error.getMessage();
        return error.getClass().getSimpleName()
                + (message == null || message.trim().isEmpty() ? "" : ": " + message);
    }
%>
<%
    try {
        String id = request.getParameter("id");
        boolean modification = id != null && !id.trim().isEmpty();
        PersonnelComplet personnel = modification ? new PersonnelGestionService().lire(id) : null;
        TypeObjet[] postes = (TypeObjet[]) CGenUtil.rechercher(new Poste(), null, null, null, " ORDER BY val");
        Magasin[] magasins = (Magasin[]) CGenUtil.rechercher(new Magasin(), null, null, null, " ORDER BY val");
        String lien = (String) session.getValue("lien");
        String dateEmbauche = personnel != null && personnel.getDateembauche() != null
                ? personnel.getDateembauche().toString() : new Date(System.currentTimeMillis()).toString();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><%=modification ? "Modifier une fiche personnelle" : "Créer une fiche personnelle"%></h1>
    </section>
    <section class="content">
        <form action="<%=personnelEscape(lien)%>?but=personnel/personnel-action.jsp" method="post">
            <input type="hidden" name="id" value="<%=personnelEscape(id)%>">
            <div class="row">
                <div class="col-md-6 form-group">
                    <label for="nom">Nom *</label>
                    <input class="form-control" id="nom" name="nom" required value="<%=personnelEscape(personnel == null ? null : personnel.getNom())%>">
                </div>
                <div class="col-md-6 form-group">
                    <label for="prenom">Prénom</label>
                    <input class="form-control" id="prenom" name="prenom" value="<%=personnelEscape(personnel == null ? null : personnel.getPrenom())%>">
                </div>
                <div class="col-md-6 form-group">
                    <label for="telephone">Téléphone</label>
                    <input class="form-control" id="telephone" name="telephone" value="<%=personnelEscape(personnel == null ? null : personnel.getTelephone())%>">
                </div>
                <div class="col-md-6 form-group">
                    <label for="mail">Adresse e-mail</label>
                    <input class="form-control" id="mail" name="mail" type="email" value="<%=personnelEscape(personnel == null ? null : personnel.getMail())%>">
                </div>
                <div class="col-md-6 form-group">
                    <label for="adresse">Adresse</label>
                    <input class="form-control" id="adresse" name="adresse" value="<%=personnelEscape(personnel == null ? null : personnel.getAdresse())%>">
                </div>
                <div class="col-md-6 form-group">
                    <label for="compte">Compte</label>
                    <input class="form-control" id="compte" name="compte" value="<%=personnelEscape(personnel == null ? null : personnel.getCompte())%>">
                </div>
                <div class="col-md-6 form-group">
                    <label for="remarque">Remarque</label>
                    <input class="form-control" id="remarque" name="remarque" value="<%=personnelEscape(personnel == null ? null : personnel.getRemarque())%>">
                </div>
                <div class="col-md-6 form-group">
                    <label for="idmagasin">Magasin de travail *</label>
                    <select class="form-control" id="idmagasin" name="idmagasin" required>
                        <option value="">Choisir un magasin</option>
                        <% if (magasins != null) for (Magasin magasin : magasins) { %>
                        <option value="<%=personnelEscape(magasin.getId())%>" <%=personnel != null && magasin.getId().equals(personnel.getIdmagasin()) ? "selected" : ""%>><%=personnelEscape(magasin.getVal())%></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-6 form-group">
                    <label for="idposte">Poste *</label>
                    <select class="form-control" id="idposte" name="idposte" required>
                        <option value="">Choisir un poste</option>
                        <% if (postes != null) for (TypeObjet poste : postes) { %>
                        <option value="<%=personnelEscape(poste.getId())%>" <%=personnel != null && poste.getId().equals(personnel.getIdposte()) ? "selected" : ""%>><%=personnelEscape(poste.getVal())%></option>
                        <% } %>
                    </select>
                </div>
                <div class="col-md-6 form-group">
                    <label for="dateembauche">Date d'embauche *</label>
                    <input class="form-control" id="dateembauche" name="dateembauche" type="date" required value="<%=dateEmbauche%>">
                </div>
            </div>
            <button type="submit" class="btn btn-primary"><%=modification ? "Enregistrer les modifications" : "Enregistrer"%></button>
            <a class="btn btn-default" href="<%=personnelEscape(lien)%>?but=personnel/personnel-liste.jsp">Annuler</a>
        </form>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="content-wrapper">
    <div class="alert alert-danger">
        Impossible de charger le formulaire du personnel :
        <%=personnelEscape(personnelErrorMessage(e))%>
    </div>
</div>
<% } %>
