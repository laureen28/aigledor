<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="affichage.PageConsulte" %>
<%@ page import="paie.recrutement.Candidat" %>
<%@ page import="paie.recrutement.RecrutementAccess" %>

<% try{ 
    UserEJB u = (user.UserEJB)session.getValue("u");
    RecrutementAccess.verifier(u);
    String lien = (String) session.getValue("lien");

    Candidat o = new Candidat();
    o.setNomTable("CANDIDAT");
    PageConsulte pc = new PageConsulte(o, request, u);
    pc.setTitre("Fiche d'un candidat");
    String id = pc.getBase().getTuppleID();

    pc.getChampByName("id").setLibelle("Id");
    pc.getChampByName("nom").setLibelle("Nom");
    pc.getChampByName("prenom").setLibelle("Pr&eacute;nom");
    pc.getChampByName("email").setLibelle("Email");
    pc.getChampByName("telephone").setLibelle("T&eacute;l&eacute;phone");
    pc.getChampByName("email").setLibelle("Adresse email");
    pc.getChampByName("idposte").setLibelle("Poste recherch&eacute;");
    pc.getChampByName("idmagasin").setLibelle("Magasin souhait&eacute;");
    pc.getChampByName("idpersonnel").setLibelle("Identifiant de la fiche personnelle");
    pc.getChampByName("idpersonnel").setLien(lien + "?but=personnel/personnel-fiche.jsp", "id=");

    String[] ordre = {
        "id","nom","prenom","adresse","telephone","idposte","idmagasin",
        "idqualification","remarque","idpersonnel"
    };
    pc.setOrdre(ordre);

    String pageRetour = ".jsp";
    String pageModif = "paie/recrutement/candidat-saisie.jsp&acte=update";
    String pageApresDelete = "paie/recrutement/candidat-liste.jsp";
    String classe = "paie.recrutement.Candidat";

%>

<div class="content-wrapper">

<h1 class="box-title"><a href=<%= lien + "?but=" + pageRetour%>> <i class="fa fa-angle-left"></i></a><%=pc.getTitre()%></h1>

<div class="row m-0">
    <div class="col-md-3"></div>
    <div class="col-md-6">
        <div class="box-fiche">
            <div class="box">
                <div class="box-body">
                    <%
                        out.println(pc.getHtml());
                    %>
                    <br/>
                    <div class="box-footer">
                        <% if (!"dg".equalsIgnoreCase(u.getUser().getIdrole())) { %>
                        <% }%>
                        <a class="btn btn-secondary pull-right" href="<%= lien + "?but="+ pageModif +"&id=" + id %>" style="margin-right: 10px">Modifier</a>
                        <a class="btn btn-danger pull-left" href="<%= lien + "?but=apresTarif.jsp&id=" + id+"&acte=delete&bute="+pageApresDelete+"&classe="+classe %>">Supprimer</a>
                        <a class="btn btn-default pull-right" href="<%=lien%>?but=paie/recrutement/candidat-liste.jsp" style="margin-right:10px">Liste des candidats</a>
                        <a class="btn btn-primary pull-right" href="<%=lien%>?but=paie/recrutement/candidature-liste.jsp" style="margin-right:10px">Candidatures</a>
                    </div>
                    <br/>
                </div>
            </div>
        </div>
    </div>
</div>

<% } catch (Exception e) {
  e.printStackTrace();
%>
<script language="JavaScript"> alert('Impossible de charger la fiche candidat. Consultez le journal WildFly pour le détail.');
    history.back();
</script>
<% }%>

