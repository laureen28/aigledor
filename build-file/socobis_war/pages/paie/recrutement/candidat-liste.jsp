<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageRecherche"%>
<%@ page import="paie.recrutement.Candidat" %>
<%@ page import="affichage.Liste"%>
<%@ page import="bean.TypeObjet" %>
<%@ page import="paie.recrutement.RecrutementAccess" %>
<%@ page import="user.UserEJB" %>

<% try{ 
    RecrutementAccess.verifier((UserEJB) session.getValue("u"));
    Candidat o = new Candidat();
    o.setNomTable("CANDIDAT");
    
    // 7 colonnes
    String[] listeCrt = {"id","nom","prenom","email","telephone","idqualification","remarque"};
    String[] libEntete = {"id","nom","prenom","email","telephone","idqualification","remarque"};
    
    PageRecherche pr = new PageRecherche(o, request, listeCrt, libEntete, libEntete.length);
    pr.setTitre("Liste des candidats");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("paie/recrutement/candidat-liste.jsp");
    
    Liste[] liste = new Liste[0];
    pr.getFormu().changerEnChamp(liste);
    pr.getFormu().getChamp("id").setLibelle("Id");
    pr.getFormu().getChamp("nom").setLibelle("Nom");
    pr.getFormu().getChamp("prenom").setLibelle("Prénom");
    pr.getFormu().getChamp("email").setLibelle("Email");
    pr.getFormu().getChamp("telephone").setLibelle("Téléphone");
    // CORRECTION ICI : idqualification au lieu de idqualifcation
    pr.getFormu().getChamp("idqualification").setLibelle("Qualification");
    pr.getFormu().getChamp("remarque").setLibelle("Remarque");
    
    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);

    String[] lienTableau = {pr.getLien() + "?but=paie/recrutement/candidat-fiche.jsp"};
    String[] colonneLien = {"id"};
    String[] attributLien = {"id"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setColonneLien(colonneLien);
    pr.getTableau().setAttLien(attributLien);

    // CORRECTION ICI : 7 libellés pour 7 colonnes
    String[] libEnteteAffiche = {"Id", "Nom", "Prénom", "Email", "Téléphone", "Qualification", "Remarque"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
    
    pr.getFormu().setAnotherButton(
            "                <a class=\"btn btn-primary pull-right  btn-small\" href=\"module.jsp?but=paie/recrutement/candidat-saisie.jsp\">\n" +
                    "                    <i class=\"material-symbols-rounded\">add</i> Saisir un nouveau candidat\n" +
                    "                </a>" +
                    "                <a class=\"btn btn-default pull-right btn-small\" href=\"module.jsp?but=paie/recrutement/candidature-liste.jsp\" style=\"margin-right:8px\">\n" +
                    "                    Liste des candidatures\n" +
                    "                </a>"
    );
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1><%= pr.getTitre() %></h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post">
            <%
                out.println(pr.getFormu().getHtmlEnsemble());
            %>
        </form>
        <%
            out.println(pr.getTableauRecap().getHtml());
        %>
        <br>
        <%
            out.println(pr.getTableau().getHtml());
            out.println(pr.getBasPage());
        %>
    </section>
</div>

<% } catch (Exception e) {
  e.printStackTrace();
%>
<script language="JavaScript"> alert('Impossible de charger la liste des candidats. Consultez le journal WildFly pour le détail.');
    history.back();
</script>
<% }%>