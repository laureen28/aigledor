<%@page import="affichage.PageRecherche"%>
<%@page import="personnel.PersonnelComplet"%>
<%
    try {
        PersonnelComplet personnel = new PersonnelComplet();
        String[] criteres = {"id", "nom", "telephone", "poste", "magasin"};
        String[] colonnes = {"id", "nom", "telephone", "poste", "magasin", "dateembauche", "datedebauche", "actif"};
        String[] entetes = {"ID", "Nom", "Téléphone", "Poste", "Magasin", "Date d'embauche", "Date de débauche", "Actif"};
        PageRecherche pageRecherche = new PageRecherche(personnel, request, criteres, new String[0], 3, colonnes, colonnes.length);
        pageRecherche.setTitre("Liste du personnel");
        pageRecherche.setUtilisateur((user.UserEJB) session.getValue("u"));
        pageRecherche.setLien((String) session.getValue("lien"));
        pageRecherche.setApres("personnel/personnel-liste.jsp");
        pageRecherche.creerObjetPage(colonnes, null);
        pageRecherche.getTableau().setLien(new String[]{pageRecherche.getLien() + "?but=personnel/personnel-fiche.jsp"});
        pageRecherche.getTableau().setColonneLien(new String[]{"id"});
        pageRecherche.getTableau().setLibelleAffiche(entetes);
%>
<div class="content-wrapper">
    <section class="content-header"><h1><%=pageRecherche.getTitre()%></h1></section>
    <section class="content">
        <a class="btn btn-primary" href="<%=pageRecherche.getLien()%>?but=personnel/personnel-saisie.jsp">
            <i class="fa fa-user-plus"></i> Embaucher / saisir un personnel
        </a>
        <a class="btn btn-default" href="<%=pageRecherche.getLien()%>?but=personnel/personnel-mouvement-liste.jsp">
            <i class="fa fa-history"></i> Historique des mouvements
        </a>
        <form action="<%=pageRecherche.getLien()%>?but=<%=pageRecherche.getApres()%>" method="post">
            <%=pageRecherche.getFormu().getHtmlEnsemble()%>
        </form>
        <%=pageRecherche.getTableauRecap().getHtml()%>
        <br>
        <%=pageRecherche.getTableau().getHtml()%>
        <%=pageRecherche.getBasPage()%>
    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace(); %>
<div class="alert alert-danger">Impossible de charger la liste.</div>
<% } %>