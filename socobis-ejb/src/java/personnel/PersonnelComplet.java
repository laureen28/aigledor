package personnel;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;

public class PersonnelComplet extends ClassMAPTable {
    private String id;
    private String nom;
    private String telephone;
    private String mail;
    private String adresse;
    private String remarque;
    private String compte;
    private String idposte;
    private String poste;
    private String idmagasin;
    private String magasin;
    private Date dateembauche;
    private Date datedebauche;
    private boolean actif;

    public PersonnelComplet() {
        setNomTable("PERSONNEL_COMPLET");
        setMode("select");
    }

    @Override
    public void construirePK(Connection connection) {
        throw new UnsupportedOperationException("La vue personnel_complet est en lecture seule.");
    }

    @Override
    public String getTuppleID() { return id; }
    @Override
    public String getAttributIDName() { return "id"; }
    @Override
    public String[] getMotCles() { return new String[]{"id", "nom", "telephone", "mail"}; }
    @Override
    public String[] getValMotCles() { return getMotCles(); }


    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    public String getMail() { return mail; }
    public void setMail(String mail) { this.mail = mail; }
    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }
    public String getRemarque() { return remarque; }
    public void setRemarque(String remarque) { this.remarque = remarque; }
    public String getCompte() { return compte; }
    public void setCompte(String compte) { this.compte = compte; }
    public String getIdposte() { return idposte; }
    public void setIdposte(String idposte) { this.idposte = idposte; }
    public String getPoste() { return poste; }
    public void setPoste(String poste) { this.poste = poste; }
    public String getIdmagasin() { return idmagasin; }
    public void setIdmagasin(String idmagasin) { this.idmagasin = idmagasin; }
    public String getMagasin() { return magasin; }
    public void setMagasin(String magasin) { this.magasin = magasin; }
    public Date getDateembauche() { return dateembauche; }
    public void setDateembauche(Date dateembauche) { this.dateembauche = dateembauche; }
    public Date getDatedebauche() { return datedebauche; }
    public void setDatedebauche(Date datedebauche) { this.datedebauche = datedebauche; }
    public boolean getActif() { return actif; }
    public void setActif(boolean actif) { this.actif = actif; }
}