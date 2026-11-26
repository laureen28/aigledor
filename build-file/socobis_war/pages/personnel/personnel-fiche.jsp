<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageConsulte" %>
<%@ page import="personnel.PersonnelComplet" %>
<%@ page import="personnel.PersonnelGestionService" %>
<%@ page import="user.UserEJB" %>

<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String id = request.getParameter("id");
        
        PersonnelComplet p = new PersonnelGestionService().lire(id);
        PageConsulte pc = new PageConsulte(p, request, u);
        pc.setTitre("Fiche personnelle");
        
        pc.getChampByName("id").setLibelle("ID");
        pc.getChampByName("nom").setLibelle("Nom");
        pc.getChampByName("prenom").setLibelle("Prénom");
        pc.getChampByName("telephone").setLibelle("Téléphone");
        pc.getChampByName("mail").setLibelle("Email");
        pc.getChampByName("adresse").setLibelle("Adresse");
        pc.getChampByName("compte").setLibelle("Compte");
        pc.getChampByName("poste").setLibelle("Poste");
        pc.getChampByName("magasin").setLibelle("Magasin");
        pc.getChampByName("dateembauche").setLibelle("Date d'embauche");
        pc.getChampByName("datedebauche").setLibelle("Date de débauche");
        pc.getChampByName("actif").setLibelle("Statut");
        pc.getChampByName("remarque").setLibelle("Remarque");

        String[] ordre = {"id", "nom", "prenom", "telephone", "mail", "adresse", "compte", "poste", "magasin", "dateembauche", "datedebauche", "actif", "remarque"};
        pc.setOrdre(ordre);

        String pageModif = "personnel/personnel-formulaire.jsp&id=" + id;
        String pageApresDelete = "personnel/personnel-liste.jsp";
        String classe = "personnel.Personnel";
%>
<div class="content-wrapper">
    <h1 class="box-title"><a href="<%=lien%>?but=personnel/personnel-liste.jsp"><i class="fa fa-angle-left"></i></a> <%=pc.getTitre()%></h1>
    <div class="row m-0">
        <div class="col-md-3"></div>
        <div class="col-md-6">
            <div class="box-fiche">
                <div class="box">
                    <div class="box-body">
                        <% out.println(pc.getHtml()); %>
                        <br/>
                        <div class="box-footer">
                            <% if (p.getActif()) { %>
                            <a class="btn btn-warning pull-right" href="<%=lien%>?but=<%=pageModif%>" style="margin-right: 10px">Modifier</a>
                            <a class="btn btn-danger pull-right" href="<%=lien%>?but=personnel/personnel-debaucher.jsp&id=<%=id%>" style="margin-right: 10px">Débaucher</a>
                            <% } %>
                            <a class="btn btn-default pull-right" href="<%=lien%>?but=personnel/personnel-mouvement-liste.jsp&idpersonnel=<%=id%>" style="margin-right: 10px">Historique</a>
                            <a class="btn btn-default pull-left" href="<%=lien%>?but=personnel/personnel-liste.jsp">Retour à la liste</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<% } catch (Exception e) {
    e.printStackTrace(); %>
<script>alert('Impossible de charger la fiche personnelle.'); history.back();</script>
<% } %>