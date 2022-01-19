<%-- 
    Document   : tutoriaIndividual
    Created on : 26/10/2015, 11:31:22 AM
    Author     : nunez7
--%>
<%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*, java.text.*"%>
<%
HttpSession sesion = request.getSession();
        Usuario usuario = (Usuario) sesion.getAttribute("usuario");
        RequestParamParser parser = new RequestParamParser(request);
if(sesion.getAttribute("usuario") == null)
{
        response.sendRedirect("../../login.jsp?modulo=25&tab=1");		
}
else
{
//conexion a base de datos
Datos siest = new Datos();
int cveAlumno = parser.getIntParameter("cveAlumno", 0);
Alumno a = new Alumno(cveAlumno);
        a.construir();
/*
 ArrayList<CustomHashMap> tutoriaAlumno = new Datos().ejecutarConsulta("SELECT CONVERT(VARCHAR, ti.fecha_registro, 103) AS fecha, "
 + "ti.puntos_importantes, ti.acuerdos, ti.observaciones, ti.nivel, (p.apellido_paterno+' '+p.apellido_materno+' '+p.nombre)AS atendio "
 + "FROM tutoria_individual ti "
 + "INNER JOIN persona p ON p.cve_persona=ti.cve_persona "
 + "WHERE ti.cve_alumno ="+cveAlumno+" AND ti.activo='True' "
 + "ORDER BY ti.fecha_registro DESC"); */
 
 ArrayList<CustomHashMap> tutoriaAlumno = siest.ejecutarConsulta("SELECT cs.cve_historial_servicio, cs.cve_consulta_servicio, "
                        + "TO_CHAR (hs.fecha_agendo, 'dd/mm/yyyy') AS fecha_atencion, hs.motivo_canalizo, cs.objetivo, cs.observacion, "
                        + "cs.diagnostico, CONCAT(p.apellido_paterno,' ',p.apellido_materno,' ',p.nombre)AS atendio, a.cve_alumno, hs.activo, "
                        + "COALESCE(cs.objetivo, '')AS objetivo, COALESCE(nd.descripcion, 'Baja')AS nivel_desercion "
                        + "FROM historial_servicio hs "
                        + "INNER JOIN consulta_servicio cs ON hs.cve_historial_servicio= cs.cve_historial_servicio "
                        + "INNER JOIN alumno a ON a.cve_persona=hs.cve_persona "
                        + "INNER JOIN persona p ON p.cve_persona=cs.cve_atendio "
                        + "LEFT JOIN nivel_desercion nd ON nd.cve_nivel_desercion=cs.cve_nivel_desercion "
                        + "WHERE a.cve_alumno=" + cveAlumno + " AND hs.cve_tipo_servicio=1 "
                        + "ORDER BY cs.fecha_atendio DESC");

 
%>
<form action="" class="modal">
    <fieldset>
        <legend>Tutorías individuales de <%=a.getNombreCompleto()%></legend>
        <br />
        <table class="datos">
            <thead>
                <tr>
                    <th>No.</th>
                        <th>Atendió</th>
                        <th>Fecha de atención</th>
                        <th>Motivos</th>
                        <th>Observaciones</th>
                </tr>
            </thead>
            <tbody>
                <%
                int n = 0;
                if(tutoriaAlumno.isEmpty()){
                %>
                <tr>
                    <td colspan="6">No ha tenido tutorías</td>
                </tr>
                <%
                }else{boolean alt = false;
                for(CustomHashMap ti: tutoriaAlumno){
                %>
                 <%
                     String observaciones = "";
                            if (ti.getString("observacion").equals("Ninguna")) {
                                ArrayList<CustomHashMap> comentarios = siest.ejecutarConsulta("SELECT COALESCE(comentario, '')AS comentario "
                                        + "FROM motivo_consulta_servicio WHERE cve_consulta_servicio=" + ti.getInt("cve_consulta_servicio"));
                                for (CustomHashMap c : comentarios) {
                                    observaciones += c.getString("comentario") + ", ";
                                }
                            }
                    %>
                    <tr>
                        <td>
                            <%=++n%>
                        </td>
                        <td><%=ti.getString("atendio")%></td>
                        <td><%=ti.getString("fecha_atencion")%></td>
                        <td><%=ti.getString("motivo_canalizo")%></td>
                        <td><%=ti.getString("observacion").equals("Ninguna") ? observaciones : ti.getString("observacion")%></td>
                    </tr>
                <%
                    //cierre de for tutoriaAlumno
                    }
                //cierre de else
                }
                %>
            </tbody>
        </table>
    </fieldset>
</form>
<%
}
%>