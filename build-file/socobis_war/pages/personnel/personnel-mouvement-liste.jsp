<%@page import="affichage.PageRecherche"%>
<%@page import="personnel.PersonnelMouvementLib"%>
<%
    try {
        PersonnelMouvementLib mouvement = new PersonnelMouvementLib();
        String[] criteres = {"idpersonnel", "nom", "typeevenement"};
        String[] colonnes = {"date_mouvement", "typeevenement", "idpersonnel", "nom",
                "ancien_poste", "nouveau_poste", "ancien_magasin", "nouveau_magasin",
                "remarque", "utilisateur"};
        String[] entetes = {"Date", "Événement", "ID personnel", "Nom", "Ancien poste",
                "Nouveau poste", "Ancien magasin", "Nouveau magasin", "Remarque", "Utilisateur"};
        PageRecherche pageRecherche = new PageRecherche(mouvement, request, criteres, new String[0], 3, colonnes, colonnes.length);
        pageRecherche.setTitre("Historique des mouvements du personnel");
        pageRecherche.setUtilisateur((user.UserEJB) session.getValue("u"));
        pageRecherche.setLien((String) session.getValue("lien"));
        pageRecherche.setApres("personnel/personnel-mouvement-liste.jsp");
        pageRecherche.creerObjetPage(colonnes, null);
        pageRecherche.getTableau().setLibelleAffiche(entetes);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><%=pageRecherche.getTitre()%></h1>
    </section>
    <section class="content">
        <a class="btn btn-default" href="<%=pageRecherche.getLien()%>?but=personnel/personnel-liste.jsp">Retour à la liste du personnel</a>
        <form action="<%=pageRecherche.getLien()%>?but=<%=pageRecherche.getApres()%>" method="post">
            <%=pageRecherche.getFormu().getHtmlEnsemble()%>
        </form>
        <%=pageRecherche.getTableauRecap().getHtml()%>
        <br>
        <%=pageRecherche.getTableau().getHtml()%>
        <%=pageRecherche.getBasPage()%>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="alert alert-danger">Impossible de charger l'historique RH. Vérifiez la migration RH et le journal WildFly.</div>
<% } %>
