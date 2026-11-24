<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="affichage.PageConsulte" %>
<%@ page import="paie.recrutement.Candidatureslib" %>
<%@ page import="constante.ConstanteEtat" %>
<%@ page import="paie.recrutement.RecrutementAccess" %>
<% try{ 
    UserEJB u = (user.UserEJB)session.getValue("u");
    RecrutementAccess.verifier(u);
    String lien = (String) session.getValue("lien");

    Candidatureslib o = new Candidatureslib();
    o.setNomTable("candidatures_score_lib");
    PageConsulte pc = new PageConsulte(o, request, u);
    pc.setTitre("Fiche d'un candidature");
    String id = pc.getBase().getTuppleID();
    o = (Candidatureslib) pc.getBase();
    pc.getChampByName("id").setLibelle("Id");
    pc.getChampByName("idcandidat").setLibelle("Id Candidat");
     pc.getChampByName("idcandidatlib").setLibelle("Nom & pr&eacute;nom");
    pc.getChampByName("idoffreemploie").setLibelle("Id Offre d'emploi");
     pc.getChampByName("idoffreemploielib").setLibelle("Offre d'emploi");
    pc.getChampByName("dateapplication").setLibelle("Date d'application");
    pc.getChampByName("scorequalification").setLibelle("Score du candidat");
    pc.getChampByName("scoreminimum").setLibelle("Score minimum du poste");
    pc.getChampByName("remarque").setLibelle("Remarque");
    pc.getChampByName("raisonrefus").setLibelle("Raison du refus");
    pc.getChampByName("etatlib").setLibelle("&Eacute;tat");
    pc.getChampByName("idcandidat").setLien(lien+"?but=paie/recrutement/candidat-fiche.jsp","id=");
    pc.getChampByName("idoffreemploie").setLien(lien+"?but=paie/recrutement/offreemploi-fiche.jsp","id=");
    pc.getChampByName("etat").setVisible(false);
    pc.getChampByName("raisonrefus").setVisible(false);

    String[] ordre = {"id","idcandidat","idoffreemploie","dateapplication","scorequalification","scoreminimum","remarque","raisonrefus","etatlib"};
    pc.setOrdre(ordre);

    String pageRetour = ".jsp";
    String pageModif = "paie/recrutement/candidature-saisie.jsp&acte=update";
    String pageApresDelete = "paie/recrutement/candidature-liste.jsp";
    String pageActuel = "paie/recrutement/candidature-fiche.jsp";
    String classe = "paie.recrutement.Candidatures";

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
                      <% if (o.getEtat() == ConstanteEtat.getEtatCreer()) {%>
                        <% if (!"dg".equalsIgnoreCase(u.getUser().getIdrole())) { %>
                             <a class="btn btn-warning pull-right"  href="<%= lien + "?but="+ pageModif +"&id=" + id %>" style="margin-right: 10px">Modifier</a>
                        <% }%>
                        <a  class="pull-right" href="<%= lien + "?but=apresTarif.jsp&id=" + id+"&acte=delete&bute="+pageApresDelete+"&classe="+classe %>"><button class="btn btn-danger">Supprimer</button></a>
                         <% if (o.getScorequalification() == null || o.getScoreminimum() == null || o.getScorequalification() < o.getScoreminimum()) { %>
                         <div class="alert alert-danger">
                             <% if (o.getScorequalification() == null) { %>
                             Score du candidat non renseigné.
                             <% } else if (o.getScoreminimum() == null) { %>
                             Score minimum non configuré dans la fiche de poste.
                             <% } else { %>
                             Candidat non qualifié : son score (<%=o.getScorequalification()%>) est inférieur au minimum du poste (<%=o.getScoreminimum()%>).
                             <% } %>
                         </div>
                         <% } else { %>
                         <a class="btn btn-primary pull-right" href="<%= lien + "?but=paie/recrutement/apresCandidature.jsp&acte=retenir&id=" + id + "&bute=" + pageActuel %>" style="margin-right: 10px">Retenir le candidat</a>
                         <% } %>
                         <a class="btn btn-success pull-right"
                           href="<%= lien + "?but=paie/recrutement/apresCandidature.jsp&id=" + id + "&acte=refuser&bute=" + pageActuel + "&classe="+classe%>"
                           style="margin-right: 10px">
                            Refuser
                        </a>
                         <% }%>
                         <% if (o.getEtat() >= ConstanteEtat.getEtatValider()) {%>
                         <a class="btn btn-success pull-right" 
                            href="<%= lien + "?but=entretient/entretient-saisie.jsp&idCandidature=" + id %>" 
                            style="margin-right: 10px">
                             Enregistrer un entretient
                            </a>
                          <% }%>
                        
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
<script language="JavaScript"> alert('Impossible de charger la fiche candidature. Consultez le journal WildFly pour le détail.');
    history.back();
</script>
<% }%>

