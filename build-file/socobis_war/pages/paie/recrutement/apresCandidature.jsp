<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.*" %>
<%@ page import="produits.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.*" %>
<%@ page import="affichage.*" %>
<%@ page import="faturefournisseur.DepenseSaisie" %>
<%@ page import="faturefournisseur.DepenseFilleSaisie" %>
<%@ page import="paie.recrutement.Candidatures" %>
<%@ page import="paie.recrutement.RecrutementAccess" %>

<%!
    private String escapeJavaScript(String value) {
        if (value == null) return "Erreur inconnue.";
        return value.replace("\\", "\\\\").replace("'", "\\'")
                .replace("\r", "\\r").replace("\n", "\\n").replace("</", "<\\/");
    }
%>
<%  try {
    String[] tId;
    String nomtable = request.getParameter("nomtable");
    String lien = (String) session.getValue("lien");
    UserEJB u = (UserEJB) session.getAttribute("u");
    RecrutementAccess.verifier(u);
    String acte = request.getParameter("acte");
    String bute = request.getParameter("bute");
    String classe = request.getParameter("classe");
    String id = request.getParameter("id");
    ClassMAPTable candidature = null;

    if (acte != null && acte.compareToIgnoreCase("refuser") == 0) {
        candidature = (ClassMAPTable) (Class.forName(classe).newInstance());
        Candidatures candidatures = (Candidatures) candidature;
        candidatures.setId(id);
        candidatures.refuser(u.getUser().getTuppleID());
         %>
<script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=id%>");</script>
<%
    } else if (acte != null && acte.equalsIgnoreCase("retenir")) {
        Candidatures candidatures = new Candidatures();
        candidatures.setId(id);
        candidatures.retenir(u.getUser().getTuppleID());
%>
<script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=id%>");</script>
<% } else if (acte != null && acte.equalsIgnoreCase("embaucher")) {
        Candidatures candidatures = new Candidatures();
        candidatures.setId(id);
        String idPersonnel = candidatures.embaucher(u.getUser().getTuppleID());
        String destination = lien + "?but=personnel/personnel-fiche.jsp&id="
                + java.net.URLEncoder.encode(idPersonnel, "UTF-8");
        response.sendRedirect(destination);
        return;
<% }

} catch (Exception e) {
    e.printStackTrace(); %>
<script language="JavaScript"> alert('<%=escapeJavaScript(e.getMessage())%>');history.back();</script>
<% } %>