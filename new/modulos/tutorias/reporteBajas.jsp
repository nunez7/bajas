<%-- 
    Document   : reporteBajas
    Created on : 30/12/2021, 04:49:42 PM
    Author     : raul_
--%>

<%@page import="mx.edu.utdelacosta.ParserDate"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.Persona"%>
<%@page import="mx.edu.utdelacosta.Periodo"%>
<%@page import="mx.edu.utdelacosta.RequestParamParser"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Usuario usuario = (Usuario) sesion.getAttribute("usuario");
    RequestParamParser parser = new RequestParamParser(request);
    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("../login.jsp");
    }
    String rol = usuario.getRol();
    if (!rol.equals("Administrador") && !rol.equals("Profesor") && !rol.equals("Director") && !rol.equals("Academia")) {
        response.sendRedirect("../login.jsp");
    }
    int tab = parser.getIntParameter("tab", 0);
    int cveModulo = parser.getIntParameter("modulo", 0);

    Periodo p = new Periodo(usuario.getCvePeriodo());
    String fechaIn = p.getFechaInicio();
    String fechaFi = p.getFechaFin();
    String fechaInicio;
    try {
        if (parser.getStringParameter("fechaInicio", null) != null) {
            fechaInicio = parser.getStringParameter("fechaInicio", null);
            sesion.setAttribute("fechaInicio", fechaInicio);
        } else {
            fechaInicio = (String) sesion.getAttribute("fechaInicio");
        }
    } catch (Exception e) {
        fechaInicio = fechaIn;
    }
    if (fechaInicio == null) {
        fechaInicio = fechaIn;
    }
    String fechaFin;
    try {
        if (parser.getStringParameter("fechaFin", null) != null) {
            fechaFin = parser.getStringParameter("fechaFin", null);
            sesion.setAttribute("fechaFin", fechaFin);
        } else {
            fechaFin = (String) sesion.getAttribute("fechaFin");
        }
    } catch (Exception e) {
        fechaFin = fechaFi;
    }
    if (fechaFin == null) {
        fechaFin = fechaFi;
    }
    int cvePersona = 0;
    try {
        cvePersona = (Integer) sesion.getAttribute("cvePersona");
    } catch (Exception e) {
        cvePersona = usuario.getCvePersona();
    }
    Persona persona = new Persona(cvePersona);
    String email = persona.getEmail();
    
    Datos siest = new Datos();
   
    int cveAlumno;
    try {
        if (parser.getIntParameter("cveAlumno", 0) > 0) {
            cveAlumno = parser.getIntParameter("cveAlumno", 0);
            sesion.setAttribute("cveAlumno", cveAlumno);
        } else {
            cveAlumno = (Integer) sesion.getAttribute("cveAlumno");
        }
    } catch (Exception e) {
        cveAlumno = 0;
    }
%>
<script src="public/js/excelexport.min.js"></script>
<form method="post" id="rporte" class="formReportes">
    <ol class="miOl">
        <li class="centrar">
            <p>Universidad Tecnológica de la Costa</p>
            <p>Carretera Santiago Entronque Internacional No. 15 Km. 5</p>
            <p>R.F.C. UTC0206053R1</p>
            <p>Reporte de solicitudes de Baja</p>
        </li>
        <li>
            <div class="table-responsive-md">
                <table id="datos">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th>Nombre</th>
                            <th>Matricula</th>
                            <th>Grupo</th>
                            <th>Tipo de baja</th>
                            <th>Causa</th>
                            <th>Estatus</th>
                        </tr>
                    </thead>
                    <%
                        int n = 0;
                        ArrayList<CustomHashMap> bajas = null;
                        if(usuario.getRol().equals("Director")){
                            bajas = siest.ejecutarConsulta("SELECT DISTINCT(be.cve_baja_estatus) as cvebajaestatus, CONCAT(p.nombre, ' ',p.apellido_paterno, ' ',p.apellido_materno ) AS nombrecompleto, "
                                    +"a.matricula, tb.tipo as tipobaja, cb.causa as causa, bs.motivo, bs.comentario, g.nombre as grupo, "
                                    +"TO_CHAR(bs.fecha_alta, 'DD/MM/YYYY') as fecha, sb.descripcion as estado "
                                    +"FROM baja_solicitud bs "
                                    +"INNER JOIN alumno a ON bs.cve_alumno = a.cve_alumno "
                                    +"LEFT JOIN persona p ON a.cve_persona = p.cve_persona "
                                    +"INNER JOIN tipo_baja tb ON bs.cve_tipo_baja = tb.cve_tipo_baja "
                                    +"INNER JOIN causa_baja cb ON bs.cve_causa_baja = cb.cve_causa_baja "
                                    +"INNER JOIN baja_estatus be ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
                                    +"LEFT JOIN situacion_baja sb ON be.cve_situacion_baja = sb.cve_situacion_baja "
                                    +"RIGHT JOIN alumno_grupo ag ON ag.cve_alumno = a.cve_alumno "
                                    +"RIGHT JOIN grupo g ON g.cve_grupo = ag.cve_grupo "
                                    +"INNER JOIN turno t ON t.cve_turno = g.cve_turno "
                                    +"INNER JOIN carrera c ON c.cve_carrera=g.cve_carrera "
                                    +"INNER JOIN director_division dv ON dv.cve_division=c.cve_division AND dv.cve_turno=t.cve_turno "
                                    +"WHERE be.activo = 'True' AND g.cve_periodo =" + usuario.getCvePeriodo() +"  AND g.activo = 'True' "
                                    +"AND dv.activo = 'True' AND dv.cve_director =" + cvePersona);
                        } else {
                            bajas = siest.ejecutarConsulta("SELECT DISTINCT(be.cve_baja_estatus) as cvebajaestatus, CONCAT(p.nombre, ' ',p.apellido_paterno, ' ',p.apellido_materno ) AS nombrecompleto, "
                                    +"a.matricula, tb.tipo as tipobaja, cb.causa as causa, bs.motivo, bs.comentario, g.nombre as grupo, "
                                    +"TO_CHAR(bs.fecha_alta, 'DD/MM/YYYY') as fecha, sb.descripcion as estado "
                                    +"FROM baja_solicitud bs "
                                    +"INNER JOIN alumno a ON bs.cve_alumno = a.cve_alumno "
                                    +"LEFT JOIN persona p ON a.cve_persona = p.cve_persona "
                                    +"INNER JOIN tipo_baja tb ON bs.cve_tipo_baja = tb.cve_tipo_baja "
                                    +"INNER JOIN causa_baja cb ON bs.cve_causa_baja = cb.cve_causa_baja "
                                    +"INNER JOIN baja_estatus be ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
                                    +"LEFT JOIN situacion_baja sb ON be.cve_situacion_baja = sb.cve_situacion_baja "
                                    +"RIGHT JOIN alumno_grupo ag ON ag.cve_alumno = a.cve_alumno "
                                    +"RIGHT JOIN grupo g ON g.cve_grupo = ag.cve_grupo "
                                    +"INNER JOIN turno t ON t.cve_turno = g.cve_turno "
                                    +"INNER JOIN profesor pf ON g.cve_profesor = pf.cve_profesor "
                                    +"INNER JOIN persona per ON per.cve_persona = pf.cve_persona "
                                    +"WHERE be.activo = 'True' AND per.cve_persona =" + cvePersona
                                    +"AND g.cve_periodo =" + usuario.getCvePeriodo());
                        }
                        for (CustomHashMap baja : bajas) {
                    %>
                    <tr>
                        <td class="index"><%=++n%></td>
                        <td><%=baja.getString("nombrecompleto")%></td>
                        <td><%=baja.getString("matricula") %></td>
                        <td><%=baja.getString("grupo") %></td>
                        <td><%=baja.getString("tipobaja") %></td>
                        <td><%=baja.getString("causa")%></td>
                        <td><%=baja.getString("estado")%></td>
                    </tr>	
                    <%
                        }
                    %>
                    </tbody> 
                </table>
            </div>
        </li>
        <li id="herramientas">
          <!--  <label class="text-muted">* Si requieres enviar por correo alguna tutoría llena los campos</label>
            <div class="row form-group">
                <div class="col-md-4">
                    <label for="de">Tu correo (de)</label> 
                    <input type="email" class="form-control" id="de" value="<%=email%>" />
                </div>
                <div class="col-md-4">
                    <label for="para">Destinatario (para)</label> 
                    <input type="email" class="form-control" id="para" />
                </div>
            </div> -->
            <div class="row d-flex justify-content-end mt-3">
                <div class="col-md-4">
                    
                </div>
                <div class="col-md-4">
                    <input type="button" id="aexcel" value="A excel">
                </div>
                <div class="col-md-4">
                    <input type="button" id="imprimirR" value="Imprimir">
                </div>
            </div>
          <%
          if(rol.equals("Administrador")){
          %>  <div class="row mt-3 d-flex justify-content-end">
                <div class="col-md-4">
                    <input type="button" id="eliminar" value="Eliminar">
                </div>
            </div>
                <%
                }
                %>
        </li>
    </ol>
</form>
<script>
    //función para enviar a excel
    $("#aexcel").on("click", function () {
        $("#datos").battatech_excelexport({
            containerid: "datos"
            , datatype: 'table', worksheetName: "Tutoria"
        });
    });
    //función para imprimir el reporte 
    $("#imprimirR").on("click", function () {
        window.print();
    });
    //función para cuando el grupo cargue nuevamente el reporte
    $(".reporte").on("change", function () {
        var fechaInicio = $("#fechaInicio").val();
        var fechaFin = $("#fechaFin").val();
        var cveAlumno = $("#cveAlumno option:selected").val();
        var cveGrupo = $("#cveGrupo option:selected").val();
        cargarContenido("#content", "modulos/tutorias/reporteBajas.jsp?modulo=<%=cveModulo%>&tab=<%=tab%>&cveGrupo=" + cveGrupo + "&cveAlumno=" + cveAlumno + "&fechaInicio=" + fechaInicio + "&fechaFin=" + fechaFin);
    });
</script>