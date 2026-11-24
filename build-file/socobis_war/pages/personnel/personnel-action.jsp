<%@ page import="personnel.PersonnelGestionService" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB utilisateur = (UserEJB) session.getValue("u");
        if (utilisateur == null || utilisateur.getUser() == null) throw new Exception("Session expirée.");
        String login = utilisateur.getUser().getLoginuser();
        String acte = request.getParameter("acte");
        String id = request.getParameter("id");
        PersonnelGestionService service = new PersonnelGestionService();
        
        if ("debaucher".equals(acte)) {
            service.debaucher(id, request.getParameter("dateDebauche"), request.getParameter("remarque"), login);
        } else {
            id = service.enregistrer(id, request.getParameter("nom"), request.getParameter("telephone"),
                    request.getParameter("mail"), request.getParameter("adresse"), request.getParameter("remarque"),
                    request.getParameter("compte"), request.getParameter("idposte"), request.getParameter("idmagasin"),
                    request.getParameter("dateembauche"), login);
        }
        response.sendRedirect(session.getValue("lien") + "?but=personnel/personnel-fiche.jsp&id=" + java.net.URLEncoder.encode(id, "UTF-8"));
        return;
    } catch (Exception e) {
        e.printStackTrace();
        response.sendError(500, "L'opération a échoué. Consultez le journal WildFly.");
    }
%>