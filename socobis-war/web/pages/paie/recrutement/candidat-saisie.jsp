<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.TypeObjet" %>
<%@ page import="paie.recrutement.Candidat" %>
<%@ page import="paie.recrutement.RecrutementAccess" %>
<%@ page import="user.UserEJB" %>
<%@ page import="java.util.LinkedHashMap" %>

<%
    try {
        UserEJB utilisateur = (UserEJB) session.getValue("u");
        RecrutementAccess.verifier(utilisateur);
        String classe = "paie.recrutement.Candidat";
        String nomTable = "CANDIDAT";
        String apres = "paie/recrutement/candidat-fiche.jsp";
        String acte = "update".equalsIgnoreCase(request.getParameter("acte")) ? "update" : "insert";

        Candidat candidat = new Candidat();
        PageInsert pageInsert = new PageInsert(candidat, request, utilisateur);
        pageInsert.setLien((String) session.getValue("lien"));
        pageInsert.setTitre("update".equals(acte) ? "Modification d'un candidat" : "Saisie d'un nouveau candidat");

        Liste[] listes = new Liste[1];
        TypeObjet direction = new TypeObjet();
        direction.setNomTable("log_direction");
        listes[0] = new Liste("direction", direction, "val", "id");
        pageInsert.getFormu().changerEnChamp(listes);

        pageInsert.getFormu().getChamp("idfonction").setPageAppelComplete("paie.edition.PaieFonction", "id", "PAIE_FONCTIONLIBELLE");

        pageInsert.getFormu().getChamp("nom").setLibelle("Nom");
        pageInsert.getFormu().getChamp("prenom").setLibelle("Prénom");
        pageInsert.getFormu().getChamp("email").setLibelle("Adresse email");
        pageInsert.getFormu().getChamp("telephone").setLibelle("Téléphone");
        pageInsert.getFormu().getChamp("adresse").setLibelle("Adresse");
        pageInsert.getFormu().getChamp("direction").setLibelle("Lieu / magasin");
        pageInsert.getFormu().getChamp("idfonction").setLibelle("Poste recherché");
        pageInsert.getFormu().getChamp("compte").setLibelle("Compte");
        pageInsert.getFormu().getChamp("remarque").setLibelle("Remarque");

        LinkedHashMap<String, String[]> rubriques = new LinkedHashMap<String, String[]>();
        rubriques.put("Informations du candidat", new String[]{
            "nom", "prenom", "telephone", "email", "adresse", "compte",
            "direction", "idfonction", "remarque"
        });
        pageInsert.getFormu().setRubrique(rubriques);

        String[] ordre = {
            "nom", "prenom", "telephone", "email", "adresse", "compte",
            "direction", "idfonction", "remarque"
        };
        pageInsert.getFormu().setOrdre(ordre);
        pageInsert.preparerDataFormu();
        pageInsert.getFormu().makeHtmlInsertTabIndex();
%>
<div class="content-wrapper">
    <h1><%=pageInsert.getTitre()%></h1>
    <form action="<%=pageInsert.getLien()%>?but=apresTarif.jsp" method="post" name="CANDIDAT" id="CANDIDAT">
        <%=pageInsert.getFormu().getHtmlInsert()%>
        <%=pageInsert.getHtmlAddOnPopup()%>
        <input name="acte" type="hidden" value="<%=acte%>">
        <input name="bute" type="hidden" value="<%=apres%>">
        <input name="classe" type="hidden" value="<%=classe%>">
        <input name="nomtable" type="hidden" value="<%=nomTable%>">
    </form>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<script>alert('Impossible de charger le formulaire candidat. Consultez le journal WildFly pour le détail.'); history.back();</script>
<% } %>
