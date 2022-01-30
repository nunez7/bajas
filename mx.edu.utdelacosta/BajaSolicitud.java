/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package mx.edu.utdelacosta;

import java.io.Serializable;
import java.util.*;

/**
 *
 * @author raul_
 */
public class BajaSolicitud implements Serializable{
    
    private int cveBajaSolicitud;
    private Alumno cveAlumno;
    private int cvePeriodo; 
    private int cveTipoBaja; 
    private int cveCausaBaja; //clase 
    private int cveBajaEstatus;
    private String motivo;
    private String comentario;
    private String asistioClase;
    private BajaEstatus baja_estatus; //clase 
    private Date fechaAlta;
    private Persona persona;
    
    Datos siest = null;
    
    public BajaSolicitud() {
        siest = new Datos();
    }
    
    //metodo para insertar la solicitud 
    public void guardarSolicitud(int cveAlumno, int cvePeriodo, int cveTipoBaja, int cveCausaBaja, String motivo ,String comentario) throws ErrorGeneral{
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO baja_solicitud(cve_alumno, cve_periodo, cve_tipo_baja, cve_causa_baja, motivo, comentario, asistio_clase, fecha_alta)"
            +" VALUES("+ cveAlumno + ", " + cvePeriodo + ", " + cveTipoBaja + ", " + cveCausaBaja + ", '" + motivo + "', '" + comentario + "', NOW(), NOW()); ");
        siest.finalizarTransaccion();
    }
    
    //método para guardar solicitud generada por el tutor
    public void generarBajaTutor (int cveAlumno, int cvePeriodo, int cveTipoBaja, int cveCausaBaja, String motivo ,String comentario, int cvePersona, String fechaAsistio) throws ErrorGeneral {
        int cveBajaSolicitud = 0;
        //guarda en tabla baja_solicitud
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO baja_solicitud(cve_alumno, cve_periodo, cve_tipo_baja, cve_causa_baja, motivo, comentario, asistio_clase, fecha_alta)"
            +" VALUES("+ cveAlumno + ", " + cvePeriodo + ", " + cveTipoBaja + ", " + cveCausaBaja + ", '" + motivo + "', 'Ninguno', '"+ fechaAsistio +"', NOW()); ");
        siest.finalizarTransaccion();
        //trae la cavle del ultimo registro de la tabla baja_solicitud 
        cveBajaSolicitud = siest.identCurrent("baja_solicitud", "cve_baja_solicitud");
        siest.iniciarTransaccion();
        //inserta el estatus de la solicitud en baja_estatus
        siest.serializarSentencia("INSERT INTO baja_estatus(cve_baja_solicitud, cve_persona, cve_situacion_baja, comentario, fecha_alta, activo)" 
              + " VALUES (" + cveBajaSolicitud + "," + cvePersona + ", 1, '" + comentario + "', NOW(), True); ");
        siest.finalizarTransaccion();
        //se envía el correo al director de la carrera
        Alumno alumno = new Alumno(cveAlumno);
            //traemos la clave de la carrera a travez del objeto alumno
            //creamos un objeto de carrera
            Carrera carrera = new Carrera(alumno.getCarreraAlumno().getCveCarrera());
            //creamos un objeto de persona y traemos su e-mail
            Persona director = carrera.getDirectorCarrera(alumno.getCarreraAlumno().getCveCarrera());
            //director.getEmail();
            String contenido = "<p><strong>Hay una nueva solicitud de baja aprobaba por tutor</strong><br />"
                   + "Para más detalles valla a su panel de director apartado solicitudes de baja.</p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", director.getEmail(), "Solicitud de baja", "Solicitud de baja", contenido);
            ec.enviar();
    }
    
    //método para insertar el estatus de la solicitud
    public void guardarBajaEstatus(int cvePersona, int cveGrupo, int cveAlumno, int cveTipoBaja) throws ErrorGeneral {
        int cveBajaSolicitud = 0;
        //trae la cve_baja_solicitud del ultimo registro insertado
        cveBajaSolicitud = siest.identCurrent("baja_solicitud", "cve_baja_solicitud");
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO baja_estatus (cve_baja_solicitud, cve_persona, cve_situacion_baja, comentario, fecha_alta, activo)"
            + " VALUES(" + cveBajaSolicitud + ", " + cvePersona + ", 6, null, NOW(), True ); ");
        siest.finalizarTransaccion();
        Persona persona = new Persona(cvePersona);
        persona.construir(); //para tomar el correo del tutor 
        Alumno alumno = new Alumno(cveAlumno);
        alumno.construir();
        //consulta para traer el tipo de baja
        ArrayList<CustomHashMap> tipos = siest.ejecutarConsulta("SELECT tipo FROM tipo_baja WHERE cve_tipo_baja ="+ cveTipoBaja);
        String tipoBaja = tipos.get(0).getString("tipo");
        String contenido = "<p><strong>El alumno: " + alumno.getNombreCompleto() + " ha solicitado su baja " + tipoBaja + " </strong><br />"
               + "Para revisar la baja, valla al Módulo de tutorías -> Solicitudes de baja </p>";
        EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", persona.getEmail(), "Solicitud de baja", "Solicitud de baja", contenido);
        ec.enviar();
    }
    
    //método para extraer el tutor del grupo
    public String extraerTutorGrupo(int cveGrupo) throws ErrorGeneral{
        ArrayList<CustomHashMap> correoTutor = siest.ejecutarConsulta("SELECT dato "
                + "FROM persona_comunicacion "
                + "WHERE cve_comunicacion = 4 AND cve_persona =" + persona);
        String emailTutor = correoTutor.get(0).getString("dato");
        return emailTutor;
    }
    //método para editar solicitud de baja
    public void editarSolicitud (int cveBajaSolicitud, String comentario, String fechaAsistio) throws ErrorGeneral {
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE baja_solicitud SET asistio_clase ='" + fechaAsistio + "' WHERE cve_baja_solicitud="+cveBajaSolicitud);
        siest.serializarSentencia("UPDATE baja_estatus SET comentario ='" + comentario + "' WHERE cve_baja_solicitud ="+cveBajaSolicitud);
        siest.finalizarTransaccion();
    }
    
    public void cancelarSolicitud(int cveBajaEstatus) throws ErrorGeneral{
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE baja_estatus SET activo = 'false', cve_situacion_baja = 8 WHERE cve_baja_estatus=" + cveBajaEstatus);
        siest.finalizarTransaccion();
    }
    
    public void estatusProfesor(int cveBajaSolicitud, int cveAlumno, String comentario, String estatus) throws ErrorGeneral{
        if(estatus.equals("rechazada")){
            siest.iniciarTransaccion();
            siest.serializarSentencia("UPDATE baja_estatus SET activo = 'False', cve_situacion_baja = 2, comentario ='"+comentario+"' WHERE cve_baja_solicitud="+cveBajaSolicitud);
            siest.finalizarTransaccion();
            Alumno alumno = new Alumno(cveAlumno);
            
            String contenido = "<p><strong> Tu solicitud ha sido rechazada por el tutor.</strong><br />"
                   + "Motivo: "+ comentario +" </p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", alumno.getEmail(), "Solicitud de baja rechazada", "Solicitud de baja rechazada", contenido);
            ec.enviar();
        }
        else{
            siest.iniciarTransaccion();
            siest.serializarSentencia("UPDATE baja_estatus SET cve_situacion_baja = 1, comentario ='"+comentario+"'  WHERE cve_baja_solicitud ="+cveBajaSolicitud);
            siest.finalizarTransaccion();
            Alumno alumno = new Alumno(cveAlumno);
            //traemos la clave de la carrera a travez del objeto alumno
            int cveCarrera = alumno.getCarreraAlumno().getCveCarrera();
            //creamos un objeto de carrera
            Carrera carrera = new Carrera(cveCarrera);
            //creamos un objeto de persona y traemos su e-mail
            Persona director = carrera.getDirectorCarrera(cveCarrera);
            //director.getEmail();
            String contenido = "<p><strong>Hay una nueva solicitud de baja aprobaba por tutor</strong><br />"
                   + "Para más detalles valla a su panel de director apartado solicitudes de baja.</p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", director.getEmail(), "Solicitud de baja", "Solicitud de baja", contenido);
            ec.enviar();
        }
    }
    
    //método que acepta o rechaza la solicitud de baja por el director de la carrera
    public void estatusDirector (int cveBajaSolicitud ,int cvePersona, String comentario, String estatus, int cveAlumno) throws ErrorGeneral {
        if(estatus.equals("rechazada")) {
            siest.iniciarTransaccion();
            siest.serializarSentencia("INSERT INTO baja_estatus (cve_baja_solicitud, cve_persona, cve_situacion_baja, comentario, fecha_alta, activo)"
                    + " VALUES("+cveBajaSolicitud+", "+cvePersona+", 4, '"+comentario+"', NOW(), 'True'); ");
            siest.finalizarTransaccion();
            Alumno alumno = new Alumno(cveAlumno);
            String contenido = "<p><strong> Tu solicitud ha sido rechazada por el director de carrera.</strong><br />"
                   + "Motivo: "+ comentario +" </p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com",  alumno.getEmail(), "Solicitud de baja rechazada", "Solicitud de baja rechazada", contenido);
            ec.enviar();
        }
        else {
            siest.iniciarTransaccion();
            siest.serializarSentencia("INSERT INTO baja_estatus (cve_baja_solicitud, cve_persona, cve_situacion_baja, comentario, fecha_alta, activo)"
                    + " VALUES("+cveBajaSolicitud+", "+cvePersona+", 3, '"+comentario+"', NOW(), 'True');");
            siest.finalizarTransaccion();
            String contenido = "<p><strong>Hay una nueva solicitud de baja aprobaba por el director de carrera.</strong><br />"
                   + " Para más detalles valla a su panel de servicios escolares apartado solicitudes de baja.</p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", "titulacion@utdelacosta.edu.mx", "Solicitud de baja", "Solicitud de baja", contenido);
            ec.enviar();
        }
    }
    
    //método para aceptar o rechazar la solicitud de baja por servicios escolares 
    public void estatusEscolares (int cveBajaSolicitud ,int cvePersona, String comentario, String estatus, int cveAlumno) throws ErrorGeneral {
        if(estatus.equals("rechazada")) {
            siest.iniciarTransaccion();
            siest.serializarSentencia("INSERT INTO baja_estatus (cve_baja_solicitud, cve_persona, cve_situacion_baja, comentario, fecha_alta, activo)"
                    + " VALUES("+cveBajaSolicitud+", "+cvePersona+", 7, '"+comentario+"', NOW(), 'false'); ");
            siest.finalizarTransaccion();
            Alumno alumno = new Alumno(cveAlumno);
            alumno.construir();
            String contenido = "<p><strong> Tu solicitud ha sido rechazada por Servicios Escolares.</strong><br />"
                   + "Motivo: "+ comentario +" </p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", alumno.getEmail(), "Solicitud de baja rechazada", "Solicitud de baja rechazada", contenido);
            ec.enviar();
        }
        else {
            Alumno alumno = new Alumno(cveAlumno);
            alumno.construir();
            //clave de persona del alumno
            int cvePersonaAlumno = alumno.getCvePersona();
            siest.iniciarTransaccion();
            siest.serializarSentencia("INSERT INTO baja_estatus (cve_baja_solicitud, cve_persona, cve_situacion_baja, comentario, fecha_alta, activo)"
                    + " VALUES("+cveBajaSolicitud+", "+cvePersona+", 5, '"+comentario+"', NOW(), 'True');");
            //se da de baja el usuario por la clave de persona del alumno
            siest.serializarSentencia("UPDATE usuario SET activo = 'false' WHERE cve_persona =" + cvePersonaAlumno);
            //se da de baja el alumno por la clave de persona del alumno
            siest.serializarSentencia("UPDATE alumno SET activo = 'false' WHERE cve_persona =" + cvePersonaAlumno);
            siest.finalizarTransaccion();
            String contenido = "<p><strong>Tu baja ha sido aceptada por Servicios Escolares.</strong><br />"
                   + " Puedes pasar por tu documentación a ventanilla.</p>";
            EnviarCorreo ec = new EnviarCorreo("utcsoporte@gmail.com", alumno.getEmail(), "Solicitud de baja", "Solicitud de baja", contenido);
            ec.enviar();
            //proceso para notificar a departamentos de la baja del alumno
            ArrayList<CustomHashMap> director = siest.ejecutarConsulta("SELECT cve_persona FROM baja_estatus WHERE cve_baja_solicitud = "+ cveBajaSolicitud +" AND cve_situacion_baja = 3");
            int cveDirector = director.get(0).getInt("cve_persona");
            Persona direccion = new Persona(cveDirector);
            //trae el correo del director de la carrera
            //direccion.getEmail();
            String contenido1 = "<p><strong>El alumno " + alumno.getNombreCompleto() + ", con matricula " + alumno.getMatricula() + ", del grupo " + alumno.getUltimoGrupo() + ", de la carrera " + alumno.getCarreraAlumno().getNombre() + " .</strong><br />"
                   + " Ha sido dado de baja.</p>";
            EnviarCorreo ev = new EnviarCorreo("utcsoporte@gmail.com", "becas@utdelacosta.edu.mx, becasenfermeria@utdelacosta.edu.mx,efrain@utdelacosta.edu.mx,"+ direccion.getEmail() , "Baja de alumno", "Baja de alumno", contenido1);
            ev.enviar();
        }
    }
    
    //método que desactiva los estatus pasados de la solicitus de baja
    public void desativarEstatus (int cveBajaSolicitud) throws ErrorGeneral {
        siest.iniciarTransaccion();
        siest.serializarSentencia("UPDATE baja_estatus SET activo = 'false' WHERE cve_baja_solicitud="+cveBajaSolicitud);
        siest.finalizarTransaccion();
    }
    
    
    //método para guardar en la tabla bajaSolicitudTutoria
    public void bajaSolicitudTutoria(int cveBajaSolicitud, int cveConsultaServicio) throws ErrorGeneral {
        siest.iniciarTransaccion();
        siest.serializarSentencia("INSERT INTO baja_solicitud_tutoria (cve_baja_solicitud, cve_consulta_servicio) "
                                + "VALUES ("+cveBajaSolicitud +", "+cveConsultaServicio+") ");
        siest.finalizarTransaccion();
    }

    public int getCveBajaSolicitud() {
        return cveBajaSolicitud;
    }

    public void setCveBajaSolicitud(int cveBajaSolicitud) {
        this.cveBajaSolicitud = cveBajaSolicitud;
    }

    public Alumno getCveAlumno() {
        return cveAlumno;
    }

    public void setCveAlumno(Alumno cveAlumno) {
        this.cveAlumno = cveAlumno;
    }

    public int getCvePeriodo() {
        return cvePeriodo;
    }

    public void setCvePeriodo(int cvePeriodo) {
        this.cvePeriodo = cvePeriodo;
    }

    public int getCveTipoBaja() {
        return cveTipoBaja;
    }

    public void setCveTipoBaja(int cveTipoBaja) {
        this.cveTipoBaja = cveTipoBaja;
    }

    public int getCveCausaBaja() {
        return cveCausaBaja;
    }

    public void setCveCausaBaja(int cveCausaBaja) {
        this.cveCausaBaja = cveCausaBaja;
    }

    public int getCveBajaEstatus() {
        return cveBajaEstatus;
    }

    public void setCveBajaEstatus(int cveBajaEstatus) {
        this.cveBajaEstatus = cveBajaEstatus;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String motivo) {
        this.motivo = motivo;
    }

    public String getComentario() {
        return comentario;
    }

    public void setComentario(String comentario) {
        this.comentario = comentario;
    }

    public String getAsistioClase() {
        return asistioClase;
    }

    public void setAsistioClase(String asistioClase) {
        this.asistioClase = asistioClase;
    }

    public BajaEstatus getBaja_estatus() {
        return baja_estatus;
    }

    public void setBaja_estatus(BajaEstatus baja_estatus) {
        this.baja_estatus = baja_estatus;
    }

    public Date getFechaAlta() {
        return fechaAlta;
    }

    public void setFechaAlta(Date fechaAlta) {
        this.fechaAlta = fechaAlta;
    }

    public Persona getPersona() {
        return persona;
    }

    public void setPersona(Persona persona) {
        this.persona = persona;
    }
    
    
    
    
    
}
