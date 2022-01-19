package mx.edu.utdelacosta.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import mx.edu.utdelacosta.*;

/**
 *
 * @author Kompanhero, @update nunez7
 */
@WebServlet(name = "BajaAlumno", urlPatterns = {"/bajaAlumno"})
public class BajaAlumno extends HttpServlet {
    
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
    }

    @Override
    public void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
            processRequest(request, response);
        HttpSession sesion = request.getSession();
        PrintWriter salida = response.getWriter();
        RequestParamParser parser = new RequestParamParser(request);
        
        if (sesion.getAttribute("usuario") == null) {
            response.sendRedirect("login.jsp");
        } else {
            try{
                Usuario usuario = (Usuario) sesion.getAttribute("usuario");
                Datos dexter = new Datos();
                
                BajaSolicitud bajaSolicitud = new BajaSolicitud();
                Grupo grupo = new Grupo();
                String accion = parser.getStringParameter("action", null);
                int cveAlumno = 0;
                int cvePersona = 0;
                int cvePeriodo = 0;
                int cveTipoBaja = 0;
                int cveCausaBaja = 0;
                int cveGrupo = 0;
                String motivo = "";
                String comentario = "";
                String estatus = "";
                int cveBajaSolicitud = 0;
                System.out.println("Accion: " + accion);
                switch(accion) {
                    case "solicitud": 
                        cveAlumno = (Integer) sesion.getAttribute("cveAlumno");
                        cvePeriodo = parser.getIntParameter("cvePeriodo", 0);
                        cveTipoBaja = parser.getIntParameter("cveTipoBaja", 0);
                        cveCausaBaja = parser.getIntParameter("cveCausaBaja", 0);
                        motivo = parser.getStringParameter("motivo", null);
                        comentario = parser.getStringParameter("comentario", null);
                        cveGrupo = parser.getIntParameter("cveGrupo", 0);
                        int cve_tutor = grupo.getTutorGrupo(cveGrupo);//trae la cve_persona del tutor del grupo
                        //guarda la solicitud de baja en "baja_solicitud"
                        bajaSolicitud.guardarSolicitud(cveAlumno, cvePeriodo, cveTipoBaja, cveCausaBaja, motivo, comentario); 
                        //guarda el estatus de la baja en "baja_estatus"
                        bajaSolicitud.guardarBajaEstatus(cve_tutor, cveGrupo, cveAlumno, cveTipoBaja); 
                        salida.write("201-save");
                        break;
                    case "cancelar":
                        int cveBajaEstatus = parser.getIntParameter("cveBajaEstatus", 0);
                        bajaSolicitud.cancelarSolicitud(cveBajaEstatus);
                        salida.write("201-save");
                        break;
                    case "editar":
                        cveBajaSolicitud = parser.getIntParameter("cveBajaSolicitud", 0);
                        String comentarioTutor = parser.getStringParameter("comentario", null);
                        String fechaAsistio = parser.getStringParameter("fechaAsistio", null);
                        bajaSolicitud.editarSolicitud(cveBajaSolicitud, comentarioTutor, fechaAsistio);
                        salida.write("201-save");
                        break;
                    case "estatusProfesor" :
                        cveAlumno = parser.getIntParameter("cveAlumno", 0);
                        //cvePersona = parser.getIntParameter("cvePersona", 0);
                        cveBajaSolicitud = parser.getIntParameter("cveBajaSolicitud", 0);
                        comentario = parser.getStringParameter("comentario", null);
                        estatus = parser.getStringParameter("estatus", null);
                        //cambia activo a "false" en el registro baja_estatus al rechazar la solicitud
                        bajaSolicitud.estatusProfesor(cveBajaSolicitud, cveAlumno, comentario, estatus);
                        salida.write("201-save");
                        break;
                    case "bajaSolicitudTutoria":
                        cveBajaSolicitud = parser.getIntParameter("cveBajaSolicitud", 0);
                        int cveConsultaServicio = parser.getIntParameter("cveConsultaServicio", 0);
                        bajaSolicitud.bajaSolicitudTutoria(cveBajaSolicitud, cveConsultaServicio);
                        salida.write("201-save");
                        break;
                    case "estatusDirector" : 
                        cveBajaSolicitud = parser.getIntParameter("cveBajaSolicitud", 0);
                        comentario = parser.getStringParameter("comentario", null);
                        estatus = parser.getStringParameter("estatus", null);
                        //clave del director
                        cvePersona = parser.getIntParameter("cvePersona", 0);
                        //cambiara los estatus pasados a false 
                        cveAlumno = parser.getIntParameter("cveAlumno", 0);
                        bajaSolicitud.desativarEstatus(cveBajaSolicitud);
                        //se insertará el nuevo estatus de la baja 
                        bajaSolicitud.estatusDirector(cveBajaSolicitud, cvePersona, comentario, estatus, cveAlumno);
                        salida.write("201-save");
                        break;
                    case "estatusEscolares" :
                        cveBajaSolicitud = parser.getIntParameter("cveBajaSolicitud", 0);
                        comentario = parser.getStringParameter("comentario", null);
                        estatus = parser.getStringParameter("estatus", null);
                        //clave del director
                        cvePersona = parser.getIntParameter("cvePersona", 0);
                        //cambiara los estatus pasados a false 
                        cveAlumno = parser.getIntParameter("cveAlumno", 0);
                        //cambiara los estatus pasados a false 
                        bajaSolicitud.desativarEstatus(cveBajaSolicitud);
                        bajaSolicitud.estatusEscolares(cveBajaSolicitud, cvePersona, comentario, estatus, cveAlumno);
                        salida.write("201-save");
                        break;
                    case "registroBaja" :
                        cveAlumno = parser.getIntParameter("cveAlumno", 0);
                        cvePeriodo = parser.getIntParameter("cvePeriodo", 0);
                        cveTipoBaja = parser.getIntParameter("cveTipoBaja", 0);
                        cveCausaBaja = parser.getIntParameter("cveCausaBaja", 0);
                        motivo = parser.getStringParameter("motivo", null);
                        comentario = parser.getStringParameter("comentario", null);
                        cvePersona = parser.getIntParameter("cvePersona", 0);
                        String fechaAsistioClase = parser.getStringParameter("fechaAsistioClase", null);
                        //guarda la solicitud de baja en "baja_solicitud"
                        bajaSolicitud.generarBajaTutor(cveAlumno, cvePeriodo, cveTipoBaja, cveCausaBaja, motivo, comentario, cvePersona, fechaAsistioClase); 
                        salida.write("201-save");
                        break;
                    case "noBajas" :
                        cveAlumno = parser.getIntParameter("cveAlumno", 0);
                        int claveAlumno = 0;
                        System.out.println("cveAlumno: " + cveAlumno);
                        //conexión a base de datos 
                        Datos siest = new Datos();
                        ArrayList<CustomHashMap> tipos = siest.ejecutarConsulta("SELECT CAST(COUNT(bs.cve_baja_solicitud)AS INTEGER) AS bajas " 
                                + " FROM baja_solicitud bs " 
                                + " INNER JOIN baja_estatus be ON bs.cve_baja_solicitud = be.cve_baja_solicitud " 
                                + " INNER JOIN situacion_baja sb ON sb.cve_situacion_baja = be.cve_situacion_baja " 
                                + " WHERE bs.cve_alumno =" + cveAlumno  
                                + " AND sb.cve_situacion_baja = '5'");
                        claveAlumno = tipos.get(0).getInt("bajas");
                        System.out.println("Bajas: " + claveAlumno);
                        salida.write("201-"+claveAlumno);
                        break;
                }
                salida.flush();
            } catch (ErrorGeneral ex) {
                Logger.getLogger(BajaAlumno.class.getName()).log(Level.SEVERE, null, ex);
            }
             
        }
    }

    @Override
    public void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("index.jsp?modulo=12&tab=1");
    }
}
