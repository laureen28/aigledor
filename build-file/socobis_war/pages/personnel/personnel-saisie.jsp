<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.TypeObjet" %>
<%@ page import="personnel.Personnel" %>
<%@ page import="user.UserEJB" %>

<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String classe = "personnel.Personnel";
        String nomTable = "PERSONNEL";
        String apres = "personnel/personnel-fiche.jsp";
        
        Personnel personnel = new Personnel();
        PageInsert pi = new PageInsert(personnel, request, u);
        pi.setLien((String) session.getValue("lien"));
        pi.setTitre("Saisie d'un nouveau personnel");

    
        Liste[] listes = new Liste[2];
        
        TypeObjet poste = new TypeObjet();
        poste.setNomTable("POSTE"); // À adapter selon ta table réelle
        listes[0] = new Liste("idposte", poste, "val", "id");
        
        TypeObjet magasin = new TypeObjet();
        magasin.setNomTable("MAGASIN"); // À adapter
        listes[1] = new Liste("idmagasin", magasin, "val", "id");
        
        pi.getFormu().changerEnChamp(listes);

        
        pi.getFormu().getChamp("nom").setLibelle("Nom *");
        pi.getFormu().getChamp("telephone").setLibelle("Téléphone");
        pi.getFormu().getChamp("mail").setLibelle("Email");
        pi.getFormu().getChamp("adresse").setLibelle("Adresse");
        pi.getFormu().getChamp("compte").setLibelle("Compte");
        pi.getFormu().getChamp("remarque").setLibelle("Remarque");
        pi.getFormu().getChamp("idposte").setLibelle("Poste *");
        pi.getFormu().getChamp("idmagasin").setLibelle("Magasin *");
        pi.getFormu().getChamp("dateembauche").setLibelle("Date d'embauche *");
        pi.getFormu().getChamp("dateembauche").setType("date");

        String[] ordre = {"nom", "telephone", "mail", "adresse", "compte", "remarque", "idposte", "idmagasin", "dateembauche"};
        pi.getFormu().setOrdre(ordre);
        
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>
<div class="content-wrapper">
    <h1><%=pi.getTitre()%></h1>
    <form action="<%=pi.getLien()%>?but=personnel/personnel-action.jsp" method="post" name="<%=nomTable%>" id="<%=nomTable%>">
        <%
            out.println(pi.getFormu().getHtmlInsert());
            out.println(pi.getHtmlAddOnPopup());
        %>
        <input name="acte" type="hidden" value="insert">
        <input name="bute" type="hidden" value="<%=apres%>">
        <input name="classe" type="hidden" value="<%=classe%>">
        <input name="nomtable" type="hidden" value="<%=nomTable%>">
    </form>
</div>
<% } catch (Exception e) {
    e.printStackTrace(); %>
<script>alert('Erreur lors du chargement du formulaire.'); history.back();</script>
<% } %>