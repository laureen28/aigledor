package paie.recrutement;

import bean.ClassMAPTable;
import java.sql.Connection;

public class Candidat extends ClassMAPTable {
    private String id;
    private String nom;
    private String prenom; 
    private String email;
    private String telephone;
    private String adresse;
    private String idqualification;
    private String remarque;
    private String idfonction; 
    private String direction;  
    private String compte;     

    public Candidat() throws Exception {
        this.setNomTable("CANDIDAT");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("CAN", "getseq_candidat");
        this.setId(makePK(c));
    }

    @Override
    public String getTuppleID() { return id; }
    @Override
    public String getAttributIDName() { return "id"; }

    @Override
    public String[] getMotCles() {
        return new String[]{"id", "nom", "prenom"};
    }

    @Override
    public String[] getValMotCles() {
        return new String[]{"id", "nom", "prenom"};
    }


    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }
    public String getIdqualification() { return idqualification; }
    public void setIdqualification(String idqualification) { this.idqualification = idqualification; }
    public String getRemarque() { return remarque; }
    public void setRemarque(String remarque) { this.remarque = remarque; }
    public String getIdfonction() { return idfonction; }
    public void setIdfonction(String idfonction) { this.idfonction = idfonction; }
    public String getDirection() { return direction; }
    public void setDirection(String direction) { this.direction = direction; }
    public String getCompte() { return compte; }
    public void setCompte(String compte) { this.compte = compte; }
}