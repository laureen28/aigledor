package annexe;

import bean.TypeObjet;

public class Poste extends TypeObjet {
    private Double scoreminimum;

    public Poste() {
        super.setNomTable("poste");
    }

    public Double getScoreminimum() {
        return scoreminimum;
    }

    public void setScoreminimum(Double scoreminimum) {
        this.scoreminimum = scoreminimum;
    }
}