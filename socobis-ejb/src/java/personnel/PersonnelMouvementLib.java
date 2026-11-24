package personnel;

import bean.ClassMAPTable;

import java.sql.Connection;
import java.sql.Date;

public class PersonnelMouvementLib extends ClassMAPTable {
    private String id;
    private String idpersonnel;
    private String nom;
    private String telephone;
    private String typeevenement;
    private Date date_mouvement;
    private String ancien_poste;
    private String nouveau_poste;
    private String ancien_magasin;
    private String nouveau_magasin;
    private String remarque;
    private String utilisateur;
    private String donnees_avant;
    private String donnees_apres;

    public PersonnelMouvementLib() {
        setNomTable("PERSONNEL_MOUVEMENT_LIB");
        setMode("select");
    }

    @Override
    public void construirePK(Connection connection) {
        throw new UnsupportedOperationException("La vue historique est en lecture seule.");
    }

    @Override
    public String getTuppleID() { return id; }

    @Override
    public String getAttributIDName() { return "id"; }

    @Override
    public String[] getMotCles() { return new String[]{"id", "idpersonnel", "nom", "telephone", "typeevenement"}; }

    @Override
    public String[] getValMotCles() { return getMotCles(); }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getIdpersonnel() { return idpersonnel; }
    public void setIdpersonnel(String idpersonnel) { this.idpersonnel = idpersonnel; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    public String getTypeevenement() { return typeevenement; }
    public void setTypeevenement(String typeevenement) { this.typeevenement = typeevenement; }
    public Date getDate_mouvement() { return date_mouvement; }
    public void setDate_mouvement(Date date_mouvement) { this.date_mouvement = date_mouvement; }
    public String getAncien_poste() { return ancien_poste; }
    public void setAncien_poste(String ancien_poste) { this.ancien_poste = ancien_poste; }
    public String getNouveau_poste() { return nouveau_poste; }
    public void setNouveau_poste(String nouveau_poste) { this.nouveau_poste = nouveau_poste; }
    public String getAncien_magasin() { return ancien_magasin; }
    public void setAncien_magasin(String ancien_magasin) { this.ancien_magasin = ancien_magasin; }
    public String getNouveau_magasin() { return nouveau_magasin; }
    public void setNouveau_magasin(String nouveau_magasin) { this.nouveau_magasin = nouveau_magasin; }
    public String getRemarque() { return remarque; }
    public void setRemarque(String remarque) { this.remarque = remarque; }
    public String getUtilisateur() { return utilisateur; }
    public void setUtilisateur(String utilisateur) { this.utilisateur = utilisateur; }
    public String getDonnees_avant() { return donnees_avant; }
    public void setDonnees_avant(String donnees_avant) { this.donnees_avant = donnees_avant; }
    public String getDonnees_apres() { return donnees_apres; }
    public void setDonnees_apres(String donnees_apres) { this.donnees_apres = donnees_apres; }
}
