<%-- 
    Document   : informes
    Created on : 11/02/2019, 12:04:49 PM
    Author     : nunez-pc
--%>
<%@page import="mx.edu.utdelacosta.RequestParamParser"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@ page contentType="text/html; charset=utf-8" language="java" %>
<%
    HttpSession sesion = request.getSession();
    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("../login.jsp");
    } else {
        Usuario usuario = (Usuario) sesion.getAttribute("usuario");
        RequestParamParser parser = new RequestParamParser(request);
        int tab = parser.getIntParameter("tab", 0);
        int cveModulo = parser.getIntParameter("modulo", 0);
        String rol = usuario.getRol();

        if (!rol.equals("Administrador") && !rol.equals("Profesor") && !rol.equals("Academia") && !rol.equals("Director")) {
            response.sendRedirect("../login.jsp");
        }
        int cvePersona;
        try {
            cvePersona = (Integer) sesion.getAttribute("cvePersona");
        } catch (Exception e) {
            cvePersona = usuario.getCvePersona();
        }
%>
<ul class="imagenes">
    <%
    if(usuario.getRol().equals("Director") || usuario.getRol().equals("Administrador") || cvePersona==71){
    %>
    <li>
        <a href="#" class="reporteTi" data-p="reporteMecasut">
            <figure><img src="public/img/grafica2.png" title="Reporte Mecasut"/></figure>
            <figcaption>Mecasut</figcaption>
        </a>
    </li>
    <%
    }
    %>
    <li>
        <a href="#" class="reporteTi" data-p="reporteTutoriaInd">
            <figure><img src="public/img/graficaMensual.png" title="Reporte de tutoría individual"/></figure>
            <figcaption>Tutoría individual</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteTutoriaGrup">
            <figure><img src="public/img/grafica_division.png" title="Reporte de tutoría grupal"/></figure>
            <figcaption>Tutoría grupal</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteCalAnterior">
            <figure><img src="public/img/table.png" title="Reporte de calificaciones anteriores"/></figure>
            <figcaption>Calificaciones anteriores</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteCitas">
            <figure><img src="public/img/calendar.png" title="Reporte de citas"/></figure>
            <figcaption>Citas</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteAtendidos">
            <figure><img src="public/img/sinDato.png" title="Reporte de alumnos atendidos"/></figure>
            <figcaption>Atendidos</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteDatoAlumno">
            <figure><img src="public/img/alumnos10.png" title="Datos del alumno"/></figure>
            <figcaption>Entrevista inicial</figcaption>
        </a>
    </li> 
    <li>
        <a href="#" class="reporteTi" data-p="reporteTestContestado">
            <figure><img src="public/img/lista.png" title="Reporte de test contestados"/></figure>
            <figcaption>Test contestado</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteEvaluacionDocente">
            <figure><img src="public/img/grafica_general.png" title="Evaluación docente"/></figure>
            <figcaption>Evaluación docente</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reportePagos">
            <figure><img src="public/img/pago.png" title="Reporte de pagos"/></figure>
            <figcaption>Pagos</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteAdeudos">
            <figure><img src="public/img/adeudo.png" title="Reporte de adeudos"/></figure>
            <figcaption>Adeudos</figcaption>
        </a>
    </li>
     <li>
        <a href="#" class="reporteTi" data-p="reporteSinInscribir">
            <figure><img src="public/img/grafica4.png" title="Reporte de alumnos Sin inscribir"/></figure>
            <figcaption>Sin inscribir</figcaption>
        </a>
    </li> 
    <li>
        <a href="#" class="reporteTi" data-p="reporteInscritosExtrac">
            <figure><img src="public/img/list.png" title="Inscritos en extracurricular"/></figure>
            <figcaption>Inscritos extracurricular</figcaption>
        </a>
    </li> 
    <li>
        <a href="#" class="reporteTi" data-p="reporteAsistenciaExtrac">
            <figure><img src="public/img/table.png" title="Reporte de asistencia extracurricular"/></figure>
            <figcaption>Asistencia extracurricular</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteUsuarios">
            <figure><img src="public/img/curso.png" title="Reporte de usuarios"/></figure>
            <figcaption>Usuarios</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteHaAccedido">
            <figure><img src="public/img/user.png" title="Reporte datos de contacto"/></figure>
            <figcaption>Datos de contacto</figcaption>
        </a>
    </li>
    <li>
        <a href="#" class="reporteTi" data-p="reporteBajas">
            <figure><img src="public/img/sinDato.png" title="Reporte de alumnos atendidos"/></figure>
            <figcaption>Bajas</figcaption>
        </a>
    </li>
</ul>
<script>
    $("a.reporteTi").on("click", function (e) {
        e.preventDefault();
        var reporte = $(this).attr("data-p");
        cargarContenido("#content", "modulos/tutorias/" + reporte + ".jsp?modulo=<%=cveModulo%>&tab=<%=tab%>");
    });
</script>
<%
    }
%>