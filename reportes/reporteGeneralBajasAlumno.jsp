<%-- 
    Document   : reporteGeneralBajasAlumno
    Created on : 20/12/2021, 06:49:41 PM
    Author     : raul_
--%>

<%@page import="mx.edu.utdelacosta.Periodo"%>
<%@page import="mx.edu.utdelacosta.ParserDate"%>
<%@page import="mx.edu.utdelacosta.CarearFecha"%>
<%@page import="mx.edu.utdelacosta.Configuracion"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
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
                + "AND sb.cve_situacion_baja = 5 AND bs.cve_periodo = " + usuario.getCvePeriodo() + " "
                + "ORDER BY c.nombre DESC");
        CarearFecha cf = new CarearFecha();

        ParserDate pd = new ParserDate();
        String fechaHoy = pd.tradicionalMesAbreviado(cf.hoy());
        Periodo period = new Periodo(usuario.getCvePeriodo());
        period.construir();
%>
<style>
    body {
        width: 700px;
        margin: 0 auto;
    }
</style>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <link href="../../temas/defecto/report.css" type="text/css" rel="stylesheet" media="all" />
        <title>SIEST: Bajas</title>
    </head>
    <body>
        <div id="encabezado">
            <img src="../../<%=Configuracion.URL_TEMA%>imagenes/logoutc.jpg" style="float:left" />
        </div>
            <h1>Bajas de alumnos de <%=pd.periodo(period.getFechaInicio(), period.getFechaFin()) %></h1>
        <div class="datos">
            <span>
                <p><strong>Fecha:</strong> <%=fechaHoy%></p>
            </span>
            <br>
            <br>
        </div>
        <table class="datos" id="datos">
            <thead>
                <tr>
                    <th>No</th>
                    <th colspan="2">Nombre</th>
                    <th>Matricula</th> 
                    <th>Grupo</th>
                    <th>Carrera</th>
                    <th>Fecha de baja</th> 
                    <th>Motivo</th> 
                </tr>
            </thead>
            <%                    int n = 0;
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
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        <script>
            window.print();
        </script>
    </body>
</html>


<%
        //llave de cierre de if de usuario
    }
%>
