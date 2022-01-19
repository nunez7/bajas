/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package mx.edu.utdelacosta;

import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Darel, nunez7
 */
public class Carrera {

    private int cveCarrera;
    private String division;
    private String unidadAcademica;
    private String nombre;
    private int anioCreacion;
    private String abreviatura;
    private NivelEstudio nivelEstudio;
    private int cveSiguiente;
    private int idTitulacion;
    private String nombreTitulacion;

    public Carrera(int cveCarrera) {
        this.cveCarrera = cveCarrera;
    }
    
    public Carrera(){}

    public Carrera(int cveCarrera, String nombre, String division, String unidadAcademica) {
        this.cveCarrera = cveCarrera;
        this.nombre = nombre;
        this.division = division;
        this.unidadAcademica = unidadAcademica;
    }

    public Carrera(int cveCarrera, String nombre, String division, String unidadAcademica, String abreviatura) {
        this(cveCarrera, nombre, division, unidadAcademica);
        this.abreviatura = abreviatura;
    }

    public void construir() {
        try {
            ArrayList<CustomHashMap> datos = new Datos().ejecutarConsulta("SELECT c.cve_carrera, d.nombre AS division, ua.nombre AS unidad_academica, "
                    + "c.nombre AS carrera, c.anio_creacion AS anio_creacion, c.abreviatura, cve_nivel_estudio, "
                    + "COALESCE(c.cve_siguiente, 0)AS cve_siguiente, COALESCE(c.id_titulacion, 0)AS id_titulacion, COALESCE(c.nombre_titulacion, '')AS nombre_titulacion "
                    + "FROM carrera c "
                    + "INNER JOIN division d ON d.cve_division=c.cve_division "
                    + "INNER JOIN unidad_academica ua ON ua.cve_unidad_academica=d.cve_unidad_academica "
                    + "WHERE c.cve_carrera="+ this.cveCarrera);
            if (!datos.isEmpty()) {
                CustomHashMap d = datos.get(0);
                this.division = d.getString("division");
                this.unidadAcademica = d.getString("unidad_academica");
                this.nombre = d.getString("carrera");
                this.anioCreacion = d.getInt("anio_creacion");
                this.abreviatura = d.getString("abreviatura");
                this.nivelEstudio = NivelEstudio.construir(d.getInt("cve_nivel_estudio"));
                this.cveSiguiente = d.getInt("cve_siguiente");
                this.idTitulacion = d.getInt("id_titulacion");
                this.nombreTitulacion = d.getString("nombre_titulacion");
            } else {
                System.out.println("No se encontró la carrera con clave " + cveCarrera);
            }
        } catch (ErrorGeneral ex) {
            Logger.getLogger(Carrera.class.getName()).log(Level.SEVERE, null, ex);
            System.out.println("-- Error : " + ex.getMensaje());
            System.out.println("   El error se dió desde la clase " + Carrera.class);
        }
    }

    public ArrayList<CustomHashMap> carreras() {
        ArrayList<CustomHashMap> carreras = null;
        try {
            carreras = new Datos().ejecutarConsulta("SELECT c.*"
                    + " FROM carrera c"
                    + " WHERE c.activo = true "
                    + " ORDER BY c.cve_nivel_estudio, c.nombre");
        } catch (ErrorGeneral ex) {
            Logger.getLogger(Carrera.class.getName()).log(Level.SEVERE, null, ex);
        }
        return carreras;
    }

    public ArrayList getGrupos(int cveCarrera, int cvePeriodo) {
        ArrayList<CustomHashMap> grupos = null;
        try {
            grupos = new Datos().ejecutarConsulta("SELECT g.*"
                    + " FROM grupo g"
                    + " INNER JOIN cuatrimestre c ON g.cve_cuatrimestre = c.cve_cuatrimestre"
                    + " WHERE g.cve_carrera = " + cveCarrera + " AND g.activo = true AND g.cve_periodo = " + cvePeriodo
                    + " ORDER BY c.consecutivo, g.consecutivo");
        } catch (ErrorGeneral ex) {
            Logger.getLogger(Carrera.class.getName()).log(Level.SEVERE, null, ex);
        }
        return grupos;
    }
    
    public Persona getDirectorCarrera (int cveCarrera) {
        Persona persona = null;
        ArrayList<CustomHashMap> director = null;
        try{
            director = new Datos().ejecutarConsulta("SELECT dv.cve_director FROM carrera c " 
                   + "INNER JOIN division d "   
                   +  "ON c.cve_division=d.cve_division "
                   +  "INNER JOIN director_division dv " 
                   +  "ON dv.cve_division=d.cve_division " 
                   +  "WHERE c.cve_carrera ="+cveCarrera 
                   +  "AND dv.activo = 'True' " 
                   +  "AND dv.cve_turno = 1");
            if(!director.isEmpty()){
                persona = new Persona(director.get(0).getInt("cve_director"));
                persona.construir();
            }
        } catch (ErrorGeneral ex) {
            Logger.getLogger(Carrera.class.getName()).log(Level.SEVERE, null, ex);
        }
        return persona;
    }

    /*
     * Mutators ----------------------------------------------------------------
     */
    public void setAbreviatura(String abreviatura) {
        this.abreviatura = abreviatura;
    }

    public void setAnioCreacion(int anioCreacion) {
        this.anioCreacion = anioCreacion;
    }

    public void setCveCarrera(int cveCarrera) {
        this.cveCarrera = cveCarrera;
    }

    public void setDivision(String division) {
        this.division = division;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public void setUnidadAcademica(String unidadAcademica) {
        this.unidadAcademica = unidadAcademica;
    }

    public void setNombreTitulacion(String nombreTitulacion) {
        this.nombreTitulacion = nombreTitulacion;
    }

    public void setIdTitulacion(int idTitulacion) {
        this.idTitulacion = idTitulacion;
    }
    

    /*
     * Accesors ----------------------------------------------------------------
     */
    public String getAbreviatura() {
        return abreviatura;
    }

    public int getAnioCreacion() {
        return anioCreacion;
    }

    public int getCveCarrera() {
        return cveCarrera;
    }

    public String getDivision() {
        return division;
    }

    public String getNombre() {
        return nombre;
    }

    public String getUnidadAcademica() {
        return unidadAcademica;
    }

    public NivelEstudio getNivelEstudio() {
        return nivelEstudio;
    }

    public void setNivelEstudio(NivelEstudio nivelEstudio) {
        this.nivelEstudio = nivelEstudio;
    }

    public int getCveSiguiente() {
        return cveSiguiente;
    }

    public void setCveSiguiente(int cveSiguiente) {
        this.cveSiguiente = cveSiguiente;
    }

    public int getIdTitulacion() {
        return idTitulacion;
    }
    
    public String getNombreTitulacion() {
        return nombreTitulacion;
    }
    
    public String getAbreviaturaCarreraTitulacion(){
        String nombreCarrera = getNombre();
        
        String abr = "TSU";
        
        switch(nombreCarrera.charAt(0)){
            case 'I':
                abr = "ING";
                break;
            case 'L':
                abr = "LIC";
                break;
        }
        return abr;
    }
    
    @Override
    public String toString() {
        return getNombre();
    }

    /*
     * Métodos de retorno
     */
}
