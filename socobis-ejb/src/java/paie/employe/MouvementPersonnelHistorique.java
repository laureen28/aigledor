package paie.employe;

import bean.ClassMAPTable;

import java.sql.Connection;
import java.sql.Date;

public class MouvementPersonnelHistorique extends ClassMAPTable {

    private String id;
    private String idpersonnel;
    private String matricule;
    private String nom;
    private String prenom;
    private String typeevenement;
    private String ancienne_direction;
    private String nouvelle_direction;
    private String ancien_service;
    private String nouveau_service;
    private String ancien_departement;
    private String nouveau_departement;
    private String ancienne_fonction;
    private String nouvelle_fonction;
    private String donnees_avant;
    private String donnees_apres;
    private Date date_mouvement;
    private Date date_depart;

    public MouvementPersonnelHistorique() {
        setNomTable("PAIE_MOUVEMENT_PERSONNEL_HISTORIQUE_COMPLET");
        setMode("select");
    }

    @Override
    public void construirePK(Connection connection) throws Exception {
        throw new UnsupportedOperationException("La vue d'historique est en lecture seule.");
    }

    @Override
    public String getTuppleID() {
        return id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    @Override
    public String[] getMotCles() {
        return new String[]{"id", "idpersonnel", "matricule", "nom", "prenom"};
    }

    @Override
    public String[] getValMotCles() {
        return new String[]{"id", "idpersonnel", "matricule", "nom", "prenom"};
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIdpersonnel() {
        return idpersonnel;
    }

    public void setIdpersonnel(String idpersonnel) {
        this.idpersonnel = idpersonnel;
    }

    public String getMatricule() {
        return matricule;
    }

    public void setMatricule(String matricule) {
        this.matricule = matricule;
    }

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public String getTypeevenement() {
        return typeevenement;
    }

    public void setTypeevenement(String typeevenement) {
        this.typeevenement = typeevenement;
    }

    public String getAncienne_direction() {
        return ancienne_direction;
    }

    public void setAncienne_direction(String ancienne_direction) {
        this.ancienne_direction = ancienne_direction;
    }

    public String getNouvelle_direction() {
        return nouvelle_direction;
    }

    public void setNouvelle_direction(String nouvelle_direction) {
        this.nouvelle_direction = nouvelle_direction;
    }

    public String getAncien_service() {
        return ancien_service;
    }

    public void setAncien_service(String ancien_service) {
        this.ancien_service = ancien_service;
    }

    public String getNouveau_service() {
        return nouveau_service;
    }

    public void setNouveau_service(String nouveau_service) {
        this.nouveau_service = nouveau_service;
    }

    public String getAncien_departement() {
        return ancien_departement;
    }

    public void setAncien_departement(String ancien_departement) {
        this.ancien_departement = ancien_departement;
    }

    public String getNouveau_departement() {
        return nouveau_departement;
    }

    public void setNouveau_departement(String nouveau_departement) {
        this.nouveau_departement = nouveau_departement;
    }

    public String getAncienne_fonction() {
        return ancienne_fonction;
    }

    public void setAncienne_fonction(String ancienne_fonction) {
        this.ancienne_fonction = ancienne_fonction;
    }

    public String getNouvelle_fonction() {
        return nouvelle_fonction;
    }

    public void setNouvelle_fonction(String nouvelle_fonction) {
        this.nouvelle_fonction = nouvelle_fonction;
    }

    public String getDonnees_avant() {
        return donnees_avant;
    }

    public void setDonnees_avant(String donnees_avant) {
        this.donnees_avant = donnees_avant;
    }

    public String getDonnees_apres() {
        return donnees_apres;
    }

    public void setDonnees_apres(String donnees_apres) {
        this.donnees_apres = donnees_apres;
    }

    public Date getDate_mouvement() {
        return date_mouvement;
    }

    public void setDate_mouvement(Date date_mouvement) {
        this.date_mouvement = date_mouvement;
    }

    public Date getDate_depart() {
        return date_depart;
    }

    public void setDate_depart(Date date_depart) {
        this.date_depart = date_depart;
    }
}
