<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%
    String destination = request.getContextPath()
            + "/pages/module.jsp?but=personnel/personnel-formulaire.jsp"
            + "&currentMenu=MENDYN261120004";
    String id = request.getParameter("id");
    if (id != null && !id.trim().isEmpty()) {
        destination += "&id=" + java.net.URLEncoder.encode(id, "UTF-8");
    }
    response.sendRedirect(destination);
    return;
%>
