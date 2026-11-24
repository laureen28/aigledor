package paie.recrutement;

public class Candidatureslib extends Candidatures {
    String idcandidatlib;
    String idoffreemploielib;
    String etatLib;
    Double scoreminimum;

    public Candidatureslib() throws Exception {
        this.setNomTable("candidatures_score_lib");
    }

    public String getEtatLib() {
        if (getEtat() == constante.ConstanteEtat.getEtatValider()) return "Retenue";
        return etatLib;
    }
    public void setEtatLib(String etatLib) { 
        this.etatLib = etatLib; 
    }

    public String getIdcandidatlib() { 
        return idcandidatlib; 
    }

    public void setIdcandidatlib(String idcandidatlib) { 
        this.idcandidatlib = idcandidatlib; 
    }

    public String getIdoffreemploielib() { 
        return idoffreemploielib; 
    }

    public void setIdoffreemploielib(String idoffreemploielib) { 
        this.idoffreemploielib = idoffreemploielib; 
    }

    public Double getScoreminimum() { 
        return scoreminimum; 
    }

    public void setScoreminimum(Double scoreminimum) { 
        this.scoreminimum = scoreminimum; 
    }
}