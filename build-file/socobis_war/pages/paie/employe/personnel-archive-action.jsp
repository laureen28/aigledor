<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="paie.employe.EmployeArchiveService" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>

<%!
    private String escapeArchiveMessage(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("'", "\\'").replace("\r", " ").replace("\n", " ");
    }
%>
<%
    try {
        if (!"POST".equalsIgnoreCase(request.getMethod())) {
            throw new Exception("Cette action doit être envoyée par formulaire.");
        }
        UserEJB utilisateur = (UserEJB) session.getValue("u");
        if (utilisateur == null) {
            throw new Exception("Session utilisateur expirée.");
        }
        MapUtilisateur mapUtilisateur = utilisateur.getUser();
        String role = mapUtilisateur.getIdrole();
        if (!"rh".equalsIgnoreCase(role) && !"admin".equalsIgnoreCase(role)
                && !"dg".equalsIgnoreCase(role) && !"superadmin".equalsIgnoreCase(role)) {
            throw new Exception("Vous n'êtes pas autorisé à archiver un dossier personnel.");
        }

        new EmployeArchiveService().archiver(
                request.getParameter("id"),
                mapUtilisateur.getTuppleID()
        );
%>
<script>
    alert('Le dossier a été archivé. Il reste conservé dans l’historique.');
    document.location.replace('<%=escapeArchiveMessage((String) session.getValue("lien"))%>?but=paie/employe/mouvement-personnel.jsp');
</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<script>
    alert('<%=escapeArchiveMessage(e.getMessage())%>');
    history.back();
</script>
<% } %>
