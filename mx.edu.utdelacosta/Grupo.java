/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package mx.edu.utdelacosta;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Norbert
 */
public class Grupo implements Serializable{

    private int cveGrupo;
    private int capacidadMaxima;
    private int cveTurno;
    private int cveCarrera;
    private int cvePeriodo;
    private int consecutivo;
    private int cveProfesor;
    private int cveCuatrimestre;
    private String nombre;
    private boolean activo;
    private Turno turno;
    private ArrayList<Materia> materias = new ArrayList<>();

    public Grupo() {
        turno = new Turno();
    }

    public Grupo(int cveGrupo, int cveCarrera, String nombre) {
        this.cveGrupo = cveGrupo;
        this.cveCarrera = cveCarrera;
        this.nombre = nombre;
    }

    public Grupo(int cveGrupo) {
        this.cveGrupo = cveGrupo;
        this.construir();
    }

    public static Grupo construir(int cveGrupo) {
        Grupo grupo = new Grupo(cveGrupo);
        grupo.construir();

        return grupo;
    }
    
    //conexion a base de datos
    Datos siest = new Datos();

    public void construir() {
        try {
            ArrayList<CustomHashMap> datosGrupo = new Datos().ejecutarConsulta("SELECT cve_grupo, cve_carrera, "
                    + "cve_periodo, consecutivo, capacidad_maxima, "
                    + "cve_turno, nombre, cve_profesor, cve_cuatrimestre, activo "
                    + "FROM grupo WHERE cve_grupo=" + this.cveGrupo);
            if (!datosGrupo.isEmpty()) {
                CustomHashMap g = datosGrupo.get(0);

                this.cveTurno = g.getInt("cve_turno");
                this.cveCarrera = g.getInt("cve_carrera");
                this.cvePeriodo = g.getInt("cve_periodo");
                this.consecutivo =g.getInt("consecutivo");
                this.cveProfesor = g.getInt("cve_profesor");
                this.cveCuatrimestre = g.getInt("cve_cuatrimestre");
                this.nombre = g.getString("nombre");
                this.activo = g.getBoolean("activo");
                this.turno = Turno.construir(g.getInt("cve_turno"));
            } else {
                this.turno = new Turno();
                System.out.println("No se encontró al grupo con clave " + cveGrupo);
            }
        } catch (ErrorGeneral ex) {
            Logger.getLogger(Grupo.class.getName()).log(Level.SEVERE, null, ex);
            System.out.println("-- Error : " + ex.getMensaje());
            System.out.println("   El error se dió desde la clase " + Grupo.class);
        } catch (Exception ex) {
            Logger.getLogger(Grupo.class.getName()).log(Level.SEVERE, null, ex);
            System.out.println("-- Error : " + ex.getMessage());
            System.out.println("   El error se dió desde la clase " + Grupo.class);
        }
    }

    public void nuevoGrupo(int cveCarrera, int cvePeriodo, int cveTurno, int cveCuatrimestre) {
        Datos dexter = new Datos();
        dexter.iniciarTransaccion();
        dexter.serializarSentencia("call genera_grupo(" + cveCarrera + ", " + cvePeriodo + ", " + cveTurno + ", " + cveCuatrimestre + ");");
        dexter.finalizarTransaccion();
    }
    
    public void modificarGrupo(int cveGrupo, int cvePeriodo, int cveCuatrimestre, boolean estado, String nombre){
        Datos dexter = new Datos();
        dexter.iniciarTransaccion();
        dexter.serializarSentencia("UPDATE grupo SET cve_periodo="+cvePeriodo+" , cve_cuatrimestre="+cveCuatrimestre+", "
                + "activo= '"+estado+"', nombre='"+nombre+"' WHERE cve_grupo="+cveGrupo+"; ");
        dexter.finalizarTransaccion();
    }
           

    public int getNuevoGrupo(int cveCarrera, int cvePeriodo, int cveTurno, int cveCuatrimestre) {
        Datos dexter = new Datos();
        dexter.iniciarTransaccion();
        dexter.serializarSentencia("call genera_grupo(" + cveCarrera + ", " + cvePeriodo + ", " + cveTurno + ", " + cveCuatrimestre + ");");
        dexter.finalizarTransaccion();

        return 0;
    }

    public ArrayList getAlumnos(int cveGrupo) throws ErrorGeneral {
        ArrayList<CustomHashMap> alumnos = new Datos().ejecutarConsulta("SELECT a.cve_alumno AS cve_alumno, CONCAT(p.apellido_paterno ,' ', p.apellido_materno , ' ' , p.nombre) AS nombre_completo,"
                + "ag.activo, a.matricula "
                + " FROM grupo g"
                + " INNER JOIN alumno_grupo ag ON ag.cve_grupo = g.cve_grupo"
                + " INNER JOIN alumno a ON ag.cve_alumno = a.cve_alumno"
                + " INNER JOIN persona p ON p.cve_persona = a.cve_persona"
                + " WHERE g.cve_grupo = " + cveGrupo + " AND a.activo = true "
                //  + "AND ag.activo != 'False' "
                + " ORDER BY p.apellido_paterno, p.apellido_materno, p.nombre");
        return alumnos;
    }

    public String getNombreTutor() throws ErrorGeneral {
        String t = "Sin tutor";
        ArrayList<CustomHashMap> tutor = new Datos().ejecutarConsulta("SELECT "
                + "CONCAT(ne.abreviatura,' ',p.nombre,' ',p.apellido_paterno,' ',p.apellido_materno) AS nombre "
                + "FROM grupo g "
                + "INNER JOIN profesor pr ON pr.cve_profesor=g.cve_profesor "
                + "INNER JOIN persona p ON p.cve_persona=pr.cve_persona "
                + "INNER JOIN nivel_estudio ne ON ne.cve_nivel_estudio=p.cve_nivel_estudio "
                + "WHERE g.cve_grupo=" + this.cveGrupo);
        if (!tutor.isEmpty()) {
            t = tutor.get(0).getString("nombre");
        }
        return t;
    }

    public void setActivo(boolean activo) {
        this.activo = activo;
    }

    public void setCapacidadMaxima(int capacidadMaxima) {
        this.capacidadMaxima = capacidadMaxima;
    }

    public void setConsecutivo(int consecutivo) {
        this.consecutivo = consecutivo;
    }

    public void setCveCarrera(int cveCarrera) {
        this.cveCarrera = cveCarrera;
    }

    public void setCveCuatrimestre(int cveCuatrimestre) {
        this.cveCuatrimestre = cveCuatrimestre;
    }

    public void setCveGrupo(int cveGrupo) {
        this.cveGrupo = cveGrupo;
    }

    public void setCvePeriodo(int cvePeriodo) {
        this.cvePeriodo = cvePeriodo;
    }

    public void setCveProfesor(int cveProfesor) {
        this.cveProfesor = cveProfesor;
    }

    public void setCveTurno(int cveTurno) {
        this.cveTurno = cveTurno;
    }

    /**
     * *******************************************************
     */
    public int getCapacidadMaxima() {
        return capacidadMaxima;
    }

    public int getCveGrupo() {
        return cveGrupo;
    }

    public String getNombre() {
        return nombre;
    }

    public int getConsecutivo() {
        return consecutivo;
    }

    public int getCveCarrera() {
        return cveCarrera;
    }

    public int getCveCuatrimestre() {
        return cveCuatrimestre;
    }

    public int getCvePeriodo() {
        return cvePeriodo;
    }

    public int getCveProfesor() {
        return cveProfesor;
    }

    public int getCveTurno() {
        return cveTurno;
    }

    public boolean isActivo() {
        return activo;
    }

    public Turno getTurno() {
        return turno;
    }

    public void setTurno(Turno turno) {
        this.turno = turno;
    }

    public ArrayList<Materia> getMaterias() {
        try {
            ArrayList<CustomHashMap> listaMaterias = new Datos().ejecutarConsulta("SELECT ch.cve_materia"
                    + " FROM carga_horaria ch"
                    + " INNER JOIN materia m ON m.cve_materia = ch.cve_materia"
                    + " WHERE ch.activo = true AND ch.cve_grupo = " + this.cveGrupo + " AND m.calificacion = true "
                    + " ORDER BY m.nombre");
            for (CustomHashMap lm : listaMaterias) {
                Materia m = Materia.construir(lm.getInt("cve_materia"));
                this.materias.add(m);
            }
        } catch (ErrorGeneral ex) {
            System.out.println("--- Ocurrió un error al procesar los datos: " + ex.getMensaje());
            System.out.println(" El error se dió desde la clase " + Grupo.class);
            Logger.getLogger(Grupo.class.getName()).log(Level.SEVERE, null, ex);
        }

        return this.materias;
    }

    public void setMaterias(ArrayList<Materia> materias) {
        this.materias = materias;
    }
    
    public int getTutorGrupo(int cveGrupo) throws ErrorGeneral {
        ArrayList<CustomHashMap> tutor = siest.ejecutarConsulta("SELECT p.cve_persona "
            + "FROM grupo g "
            + "INNER JOIN profesor pr ON pr.cve_profesor=g.cve_profesor " 
            + "INNER JOIN persona p ON p.cve_persona=pr.cve_persona " 
            + "INNER JOIN nivel_estudio ne ON ne.cve_nivel_estudio=p.cve_nivel_estudio " 
            + "WHERE g.cve_grupo=" + cveGrupo);
        int cvePersona = tutor.get(0).getInt("cve_persona");
    return cvePersona;
    }
}
