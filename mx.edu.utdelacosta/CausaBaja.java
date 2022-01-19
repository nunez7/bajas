/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package mx.edu.utdelacosta;

import java.util.ArrayList;

/**
 *
 * @author raul_
 */
public class CausaBaja {
    
    private int cveCausaBaja;
    private String causaBaja;
    
    Datos siest = null;
    
    public CausaBaja(){
        siest = new Datos();
    }
    
    public int getCveCausaBaja() {
        return cveCausaBaja;
    }

    public void setCveCausaBaja(int cveCausaBaja) {
        this.cveCausaBaja = cveCausaBaja;
    }

    public String getCausaBaja() {
        return causaBaja;
    }

    public void setCausaBaja(String causaBaja) {
        this.causaBaja = causaBaja;
    }

    public ArrayList<CustomHashMap> getCausaBaja (int cveCausaBaja) throws ErrorGeneral {
        ArrayList<CustomHashMap> causaBaja = siest.ejecutarConsulta("SELECT causa FROM causa_baja "
                + "WHERE cve_causa_baja = "+cveCausaBaja+ " AND activo = 'True");
        return causaBaja;
    }
    
    
    
}


