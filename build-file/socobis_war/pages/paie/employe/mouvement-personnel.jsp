<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String destination = request.getContextPath()
            + "/pages/module.jsp?but=personnel/personnel-mouvement-liste.jsp";
    String idPersonnel = request.getParameter("idpersonnel");
    if (idPersonnel == null || idPersonnel.trim().isEmpty()) {
        idPersonnel = request.getParameter("id");
    }
    if (idPersonnel != null && !idPersonnel.trim().isEmpty()) {
        destination += "&idpersonnel=" + java.net.URLEncoder.encode(idPersonnel, "UTF-8");
    }
    response.sendRedirect(destination);
    return;
%>
