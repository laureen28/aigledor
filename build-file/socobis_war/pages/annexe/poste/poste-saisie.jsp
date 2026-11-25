

<%--
    Document   : produit-fiche
    Created on : 21 mars 2024, 09:44:57
    Author     : Angela
--%>

<%@page import="annexe.Poste"%>
<%@page import="affichage.PageInsert"%>
<%@page import="user.UserEJB"%>

<%
    try{
        UserEJB u = (user.UserEJB) session.getValue("u");
        String  mapping = "annexe.Poste",
                nomtable = "POSTE",
                apres = "annexe/poste/poste-fiche.jsp",
                titre = "Insertion d'un Poste";
        String acte = "update".equalsIgnoreCase(request.getParameter("acte")) ? "update" : "insert";
        if ("update".equals(acte)){
            titre = "Modification d’un Poste";
        }
        Poste poste = new Poste();
        poste.setNomTable(nomtable);
        PageInsert pi = new PageInsert(poste, request, u);
        pi.setLien((String) session.getValue("lien"));
        pi.getFormu().getChamp("val").setLibelle("D&eacute;signation");
        pi.getFormu().getChamp("desce").setLibelle("Description");
        pi.getFormu().getChamp("scoreminimum").setLibelle("Score minimum requis pour l'embauche");
        pi.getFormu().getChamp("scoreminimum").setType("number");
        pi.getFormu().getChamp("scoreminimum").setAutre("step='any' min='0' required");
        pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <h1> <%=titre%></h1>

    <form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post" name="<%=nomtable%>" id="<%=nomtable%>">
        <%
            pi.getFormu().makeHtmlInsertTabIndex();
            out.println(pi.getFormu().getHtmlInsert());
            out.println(pi.getHtmlAddOnPopup());
        %>
        <input name="acte" type="hidden" id="nature" value="<%=acte%>">
        <input name="bute" type="hidden" id="bute" value="<%=apres%>">
        <input name="classe" type="hidden" id="classe" value="<%=mapping%>">
        <input name="nomtable" type="hidden" id="nomtable" value="<%=nomtable%>">
    </form>
</div>

<%
} catch (Exception e) {
    e.printStackTrace();
%>
<script language="JavaScript"> alert('<%=e.getMessage()%>');
history.back();</script>

<% }%>
