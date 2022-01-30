<%-- 
    Document   : submodulo9
    Created on : 14/12/2021, 08:50:40 PM
    Author     : raul_
--%>

<%@page import="mx.edu.utdelacosta.Configuracion"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
    HttpSession sesion = request.getSession();
    Usuario usuario = (Usuario) sesion.getAttribute("usuario");
    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("../../login.jsp");
    } else {
        //conexión a base de datos
        Datos siest = new Datos();
        //clave de persona del usuario logueado 
        int cvePersona = usuario.getCvePersona();
        int cvePeriodo = usuario.getCvePeriodo();
        ArrayList<CustomHashMap> periodo = siest.ejecutarConsulta("SELECT TO_CHAR(fecha_inicio, 'DD/MM/YYYY') AS inicio, TO_CHAR(fecha_fin, 'DD/MM/YYYY') AS fin FROM periodo WHERE cve_periodo="+cvePeriodo);
        String fechaInicio = periodo.get(0).getString("inicio");
        String fechaFin = periodo.get(0).getString("fin");
        ArrayList<CustomHashMap> datos = siest.ejecutarConsulta("SELECT DISTINCT(be.cve_baja_estatus) as cvebajaestatus, CONCAT(p.nombre, ' ',p.apellido_paterno, ' ',p.apellido_materno ) AS nombrecompleto, "
                    + "a.matricula, tb.tipo as tipobaja, cb.causa as causa, bs.motivo, bs.comentario, g.nombre as grupo, "
                    + "TO_CHAR(bs.fecha_alta, 'DD/MM/YYYY') as fecha, sb.descripcion as estado, c.nombre as carrera, a.cve_alumno, bs.cve_baja_solicitud "
                    + "FROM baja_solicitud bs "
                    + "INNER JOIN alumno a "
                    + "ON bs.cve_alumno = a.cve_alumno "
                    + "LEFT JOIN persona p "
                    + "ON a.cve_persona = p.cve_persona "
                    + "INNER JOIN tipo_baja tb "
                    + "ON bs.cve_tipo_baja = tb.cve_tipo_baja "
                    + "INNER JOIN causa_baja cb "
                    + "ON bs.cve_causa_baja = cb.cve_causa_baja "
                    + "INNER JOIN baja_estatus be "
                    + "ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
                    + "LEFT JOIN situacion_baja sb "
                    + "ON be.cve_situacion_baja = sb.cve_situacion_baja "
                    + "RIGHT JOIN alumno_grupo ag "
                    + "ON ag.cve_alumno = a.cve_alumno AND ag.cve_periodo=bs.cve_periodo "
                    + "RIGHT JOIN grupo g "
                    + "ON g.cve_grupo = ag.cve_grupo "
                    + "INNER JOIN carrera c "
                    + "ON c.cve_carrera = g.cve_carrera "
                    + "INNER JOIN division d "
                    + "ON d.cve_division = c.cve_division "
                    + "WHERE be.activo = 'True' "
                    + "AND sb.cve_situacion_baja = 5 "
                    + "AND bs.cve_periodo = "+usuario.getCvePeriodo()+" "
                    + "ORDER BY c.nombre DESC");
        
%>
<br />
<div class="tablaScroll">
    <form>
        <fieldset>
            <table class="datos">
                <thead>
                    <tr>
                        <th>No</th>
                        <th colspan="2">Nombre</th>
                        <th>Matricula</th> 
                        <th>Grupo</th>
                        <th>Carrera</th>
                        <th>Fecha de baja</th> 
                        <th>Motivo</th> 
                        <th>Acciones</th>
                    </tr>
                </thead>
                <%  
                    int n = 0;
                    boolean alt = false;
                    for (CustomHashMap dato : datos) {
                %>
                <tbody>
                    <%
                        
                        n++;
                    %>
                    <tr class="<%out.print(alt == true ? "alt" : "");
                    alt = !alt;%>">
                        <td class="index"><%=n%></td>
                        <td colspan="2"><%=dato.getString("nombrecompleto")%></td>
                        <td><%=dato.getString("matricula")%> </td>
                        <td><%=dato.getString("grupo")%> </td>
                        <td><%=dato.getString("carrera")%> </td>
                        <td><%=dato.getString("fecha")%></td>
                        <td><%=dato.getString("motivo")%></td>
                        <td>
                            <input type="button" id="imprimirBaja" data-cve="<%=dato.getInt("cve_baja_solicitud")%>" data-cveAlumno="<%=dato.getInt("cve_alumno")%>" class="imprimir" value="Imprimir"/>
                        </td>
                    </tr>
                    <%
                        }
                    %>
                </tbody>
            </table>
        </fieldset>
    </form>
    <div class="barra-herramientas">
    <ul>
        <li>
            <a title="Imprimir reporte" 
               href="../../dexter/reportes/alumno/reporteGeneralBajasAlumno.jsp" 
               target="_blank" >
                <dt><img alt="Imprimir" src="<%=Configuracion.URL_TEMA%>imagenes/icons/imprimir.png" /></dt>
                <dd>Imprimir reporte</dd>
            </a>
        </li>                       
    </ul>
    </div>
</div>
<script>
    
    $(".imprimir").click(function (e) {
        console.log("entro a la funcion");
        e.preventDefault();
        var cveBajaSolicitud = $(this).attr("data-cve");
        var cveAlumno = $(this).attr("data-cveAlumno");
        window.open("../../dexter/reportes/alumno/solicitudBaja.jsp?cveBajaSolicitud="+cveBajaSolicitud+"&cveAlumno="+cveAlumno,"_blank");
    });
</script>
<%
    //llave de cierre de if de usuario
    }
%>


