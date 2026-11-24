<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="affichage.PageRecherche" %>
<%@ page import="bean.ClassMAPTable" %>
<%@ page import="paie.employe.MouvementPersonnelHistorique" %>
<%@ page import="paie.employe.EmployeComplet" %>
<%@ page import="paie.recrutement.RecrutementAccess" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="java.net.URLEncoder" %>

<%!
    private String escapeHtml(String value) {
        if (value == null) {
            return "";
        }
        StringBuilder escaped = new StringBuilder(value.length());
        for (int i = 0; i < value.length(); i++) {
            char character = value.charAt(i);
            switch (character) {
                case '&':
                    escaped.append("&amp;");
                    break;
                case '<':
                    escaped.append("&lt;");
                    break;
                case '>':
                    escaped.append("&gt;");
                    break;
                case '"':
                    escaped.append("&quot;");
                    break;
                case '\'':
                    escaped.append("&#39;");
                    break;
                default:
                    escaped.append(character);
            }
        }
        return escaped.toString();
    }

    private String displayValue(String value) {
        return value == null || value.trim().isEmpty() ? "—" : escapeHtml(value);
    }
%>

<%
    try {
        MouvementPersonnelHistorique historique = new MouvementPersonnelHistorique();
        String[] criteres = {"matricule", "nom", "prenom", "typeevenement", "nouveau_departement", "nouvelle_direction", "nouveau_service"};
        String[] intervalles = {"date_mouvement"};
        String[] colonnes = {
            "idpersonnel", "matricule", "nom", "prenom", "typeevenement", "date_mouvement",
            "ancienne_fonction", "nouvelle_fonction", "ancien_service", "nouveau_service",
            "ancien_departement", "nouveau_departement", "ancienne_direction", "nouvelle_direction",
            "date_depart", "donnees_avant", "donnees_apres"
        };
        PageRecherche recherche = new PageRecherche(historique, request, criteres, intervalles, 3, colonnes, colonnes.length);
        user.UserEJB utilisateur = (user.UserEJB) session.getValue("u");
        recherche.setUtilisateur(utilisateur);
        recherche.setLien((String) session.getValue("lien"));
        recherche.setApres("paie/employe/mouvement-personnel.jsp");
        String restriction = "";
        MapUtilisateur mapUtilisateur = utilisateur.getUser();
        boolean agent = "agent".equalsIgnoreCase(mapUtilisateur.getIdrole());
        if (agent) {
            EmployeComplet employe = new EmployeComplet().getEmployeByRefUser(mapUtilisateur.getTuppleID());
            if (employe == null || employe.getId() == null) {
                throw new Exception("Aucun dossier personnel n'est associé à cet utilisateur.");
            }
            restriction = " AND idpersonnel = '" + employe.getId().replace("'", "''") + "'";
        } else {
            RecrutementAccess.verifier(utilisateur);
        }
        recherche.setAWhere(restriction + " ORDER BY date_mouvement DESC NULLS LAST, id DESC");

        recherche.getFormu().getChamp("matricule").setLibelle("Matricule");
        recherche.getFormu().getChamp("nom").setLibelle("Nom");
        recherche.getFormu().getChamp("prenom").setLibelle("Prénom");
        recherche.getFormu().getChamp("typeevenement").setLibelle("Type d'événement");
        recherche.getFormu().getChamp("nouveau_departement").setLibelle("Département");
        recherche.getFormu().getChamp("nouvelle_direction").setLibelle("Magasin / lieu");
        recherche.getFormu().getChamp("nouveau_service").setLibelle("Service");
        recherche.getFormu().getChamp("date_mouvement1").setLibelle("Date du mouvement (début)");
        recherche.getFormu().getChamp("date_mouvement2").setLibelle("Date du mouvement (fin)");

        recherche.creerObjetPage(colonnes, new String[0]);
        ClassMAPTable[] resultats = recherche.getListe();
        String lien = recherche.getLien();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Embauche, mouvements et départs du personnel</h1>
    </section>
    <section class="content">
        <div class="row" style="margin-bottom: 15px;">
            <div class="col-md-12">
                <% if (!agent) { %>
                <a class="btn btn-primary" href="<%=escapeHtml(lien)%>?but=paie/employe/infopersonnel-saisie.jsp">
                    <i class="fa fa-user-plus"></i> Embaucher un employé
                </a>
                <a class="btn btn-default" href="<%=escapeHtml(lien)%>?but=paie/avancement/avancement-saisie.jsp">
                    <i class="fa fa-exchange"></i> Saisir un mouvement de poste
                </a>
                <% } %>
            </div>
        </div>

        <form action="<%=escapeHtml(lien)%>?but=paie/employe/mouvement-personnel.jsp" method="post" name="historiquePersonnel" id="historiquePersonnel">
            <%=recherche.getFormu().getHtmlEnsemble()%>
        </form>

        <div class="table-responsive">
            <table class="table table-bordered table-striped">
                <thead>
                <tr>
                    <th>Matricule</th>
                    <th>Nom</th>
                    <th>Événement</th>
                    <th>Date</th>
                    <th>Ancien poste</th>
                    <th>Nouveau poste</th>
                    <th>Ancien département</th>
                    <th>Nouveau département</th>
                    <th>Ancien service</th>
                    <th>Nouveau service</th>
                    <th>Ancien magasin / lieu</th>
                    <th>Nouveau magasin / lieu</th>
                    <th>Date de débauche</th>
                    <th>Détails des données</th>
                    <th>Action</th>
                </tr>
                </thead>
                <tbody>
                <%
                    if (resultats != null && resultats.length > 0) {
                        for (ClassMAPTable resultat : resultats) {
                            MouvementPersonnelHistorique ligne = (MouvementPersonnelHistorique) resultat;
                            String identifiant = URLEncoder.encode(ligne.getIdpersonnel() == null ? "" : ligne.getIdpersonnel(), "UTF-8");
                            boolean situation = "SITUATION".equalsIgnoreCase(ligne.getTypeevenement());
                            boolean enPoste = situation && ligne.getDate_depart() == null;
                %>
                <tr>
                    <td><%=displayValue(ligne.getMatricule())%></td>
                    <td><%=displayValue(ligne.getNom())%> <%=displayValue(ligne.getPrenom())%></td>
                    <td><%=displayValue(ligne.getTypeevenement())%></td>
                    <td><%=ligne.getDate_mouvement() == null ? "—" : ligne.getDate_mouvement()%></td>
                    <td><%=displayValue(ligne.getAncienne_fonction())%></td>
                    <td><%=displayValue(ligne.getNouvelle_fonction())%></td>
                    <td><%=displayValue(ligne.getAncien_departement())%></td>
                    <td><%=displayValue(ligne.getNouveau_departement())%></td>
                    <td><%=displayValue(ligne.getAncien_service())%></td>
                    <td><%=displayValue(ligne.getNouveau_service())%></td>
                    <td><%=displayValue(ligne.getAncienne_direction())%></td>
                    <td><%=displayValue(ligne.getNouvelle_direction())%></td>
                    <td><%=ligne.getDate_depart() == null ? "—" : ligne.getDate_depart()%></td>
                    <td>
                        <% if (!agent && (ligne.getDonnees_avant() != null || ligne.getDonnees_apres() != null)) { %>
                        <details>
                            <summary>Avant / après</summary>
                            <% if (ligne.getDonnees_avant() != null) { %>
                            <strong>Avant</strong>
                            <pre><%=escapeHtml(ligne.getDonnees_avant())%></pre>
                            <% } %>
                            <% if (ligne.getDonnees_apres() != null) { %>
                            <strong>Après</strong>
                            <pre><%=escapeHtml(ligne.getDonnees_apres())%></pre>
                            <% } %>
                        </details>
                        <% } else { %>
                        —
                        <% } %>
                    </td>
                    <td>
                        <% if (enPoste && !agent) { %>
                        <a class="btn btn-danger btn-xs" href="<%=escapeHtml(lien)%>?but=paie/employe/personnelnonvalide-saisie.jsp&id=<%=identifiant%>">
                            Débaucher
                        </a>
                        <a class="btn btn-warning btn-xs" href="<%=escapeHtml(lien)%>?but=paie/employe/infopersonnel-saisie.jsp&id=<%=identifiant%>&amp;acte=update">
                            Modifier
                        </a>
                        <a class="btn btn-default btn-xs" href="<%=escapeHtml(lien)%>?but=paie/avancement/avancement-saisie.jsp&amp;id=<%=identifiant%>">
                            Changer le poste
                        </a>
                        <% } else if (situation && ligne.getDate_depart() != null) { %>
                        Débauché
                        <% } else { %>
                        —
                        <% } %>
                    </td>
                </tr>
                <%
                        }
                    } else {
                %>
                <tr>
                    <td colspan="15" class="text-center">Aucun mouvement du personnel trouvé.</td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <%=recherche.getBasPage()%>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<script>
    alert('<%=escapeHtml(e.getMessage())%>');
    history.back();
</script>
<% } %>
