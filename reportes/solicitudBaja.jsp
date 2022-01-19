<%-- 
    Document   : solicitudBaja
    Created on : 14/12/2021, 10:34:00 AM
    Author     : raul_
--%>

<%@page import="mx.edu.utdelacosta.Utilidades"%>
<%@page import="mx.edu.utdelacosta.Carrera"%>
<%@page import="mx.edu.utdelacosta.Persona"%>
<%@page import="mx.edu.utdelacosta.RequestParamParser"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="mx.edu.utdelacosta.Alumno"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.Sesion"%>
<%@page import="mx.edu.utdelacosta.ParserDate"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Sesion objetoSesion = new Sesion(sesion);
    RequestParamParser parser = new RequestParamParser(request);
    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("../../login.jsp");
    }else {
        //conexion a base de datos
        Datos siest = new Datos();
            //para crear la clave encriptada
            Utilidades u = new Utilidades();
            int cveAlumno = parser.getIntParameter("cveAlumno", 0);
            //cvePersona = parser.getIntParameter("cvePersona", 0);
            int cveBajaSolicitud = parser.getIntParameter("cveBajaSolicitud", 0);

            Alumno a = new Alumno(cveAlumno);
            a.construir();
            Carrera carrera = new Carrera(a.getCvePersona());
            carrera.construir();
            String claveAlumno = String.valueOf(cveAlumno);
            
            //String sexo = a.getSexo();
            //System.out.println("Sexo: "+sexo);
            String sexo = (a.getSexo() == "null") ? a.getSexo() : "N";
            
            //trae la solicitus de la baja de acuerdo a su clave 
            ArrayList<CustomHashMap> solicitud = siest.ejecutarConsulta("SELECT TO_CHAR(bs.fecha_alta,'DD/MM/YYYY') AS fecha, tb.tipo AS tipo, cb.causa, bs.motivo "
                    + "FROM baja_solicitud bs "
                    + "INNER JOIN tipo_baja tb ON bs.cve_tipo_baja = tb.cve_tipo_baja "
                    + "INNER JOIN causa_baja cb ON cb.cve_causa_baja = bs.cve_causa_baja "
                    + "WHERE bs.cve_baja_solicitud=" + cveBajaSolicitud);
            String fecha = solicitud.get(0).getString("fecha");
            String tipoBaja = solicitud.get(0).getString("tipo");
            String causaBaja = solicitud.get(0).getString("causa");
            String motivo = solicitud.get(0).getString("motivo");
            //cve_persona del tutor 
            ArrayList<CustomHashMap> tutor = siest.ejecutarConsulta("SELECT cve_persona FROM baja_estatus WHERE cve_baja_solicitud =" + cveBajaSolicitud + " AND cve_situacion_baja = 1");
            int cvePersonaTutor = tutor.get(0).getInt("cve_persona");
            Persona tutorNombre = new Persona(cvePersonaTutor);
            String cveTutor = String.valueOf(cvePersonaTutor);
            
            //cve_persona del director de la carrera
            ArrayList<CustomHashMap> director = siest.ejecutarConsulta("SELECT cve_persona FROM baja_estatus WHERE cve_baja_solicitud =" + cveBajaSolicitud + " AND cve_situacion_baja = 3");
            int cvePersonaDirector = director.get(0).getInt("cve_persona");
            Persona directorNombre = new Persona(cvePersonaDirector);
            String cveDirector = String.valueOf(cvePersonaDirector);
            
            //cve_persona de servicios escolares
            ArrayList<CustomHashMap> escolares = siest.ejecutarConsulta("SELECT cve_persona FROM baja_estatus WHERE cve_baja_solicitud =" + cveBajaSolicitud + " AND cve_situacion_baja = 5");
            int cvePersonaEscolares = escolares.get(0).getInt("cve_persona");
            Persona escolaresNombre = new Persona(cvePersonaEscolares);
            String cveEscolares = String.valueOf(cvePersonaEscolares);
%>
<!DOCTYPE html>
<html lang="es">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>SOLICITUD DE BAJA DEL ALUMNO</title>
        <link rel="stylesheet" href="../../temas/defecto/normalize.css" />
        <link rel="stylesheet" href="../../temas/defecto/boleta-121105_escolares.css" />
        <script src="../../js/prefixfree.min.js"></script>
        <script src="../../js/jquery-1.8.2.min.js"></script>
    </head>
    <body>
        <div class="documento-requi-titulacion">
            <!-- Encabezado -->
            <header>
                <table>
                    <tr>
                        <td colspan="3" rowspan="3"><img src="../../temas/defecto/imagenes/logoutc.jpg" alt="Logo UTC" /> </td>
                        <td colspan="4" rowspan="3"><strong>SOLICITUD DE BAJA DEL ALUMNO</strong> <br />Sistema de Gestión de la Calidad</td>
                        <td colspan="3" rowspan="2" class="bold">Fecha de emisión: <br />23/02/2021</td>
                    </tr>
                    <tr>
                    </tr>
                    <tr>
                        <td colspan="3" class="bold">Rev. 04</td>
                    </tr>
                </table>
            </header>
            <section id="datos">
                <table>
                    <tbody>
                        <tr>
                            <td class="bold fondo-gris" colspan="2">Nombre del alumno(a):</td>
                            <td colspan="3"><%=a.getNombreCompleto() %></td>
                            <td class="bold fondo-gris" colspan="2">Matrícula: </td>
                            <td colspan="4"><%=a.getMatricula() %></td>
                        </tr>
                        <tr>
                            <td class="bold fondo-gris" colspan="2">Carrera: </td>
                            <td colspan="3"><%=a.getCarreraAlumno().getNombre() %></td>
                            <td class="bold fondo-gris" colspan="2">Grupo:</td>
                            <td colspan="2"><%=a.getUltimoGrupo() %></td>
                        </tr>
                        <tr>
                            <td class="bold fondo-gris" colspan="2">Fecha de baja:</td>
                            <td colspan="3"><%=fecha %></td>
                            <td class="bold fondo-gris" colspan="2">Sexo: </td>
                            <td colspan="2"><%=sexo %></td>
                        </tr>
                    </tbody>
                </table>
            </section>
            <section>
                <div class="align-content-md-center">
                    <h2>DATOS DE LA BAJA</h2>
                </div>
                <table class="datos">
                    <tbody>
                        <tr>
                            <td class="bold fondo-gris" colspan="2">Tipo de baja:</td>
                            <td><%=tipoBaja%></td>
                        </tr>
                        <tr>
                            <td class="bold fondo-gris" colspan="2">Causa principal de la baja:</td>
                            <td><%=causaBaja%></td>
                        </tr>
                        <tr>
                            <td class="bold fondo-gris" colspan="2">Motivo:</td>
                            <td><%=motivo%></td>
                        </tr>
                    </tbody>
                </table>
            </section>
            <section class="datos">
                <div class="contenedor-requisito">
                    <div class="requisito">
                        <div class="estatus-requisito">
                            <%=tutorNombre.getNombreCompleto() %> <br>
                            <div class="minuscula"><%=tutorNombre.getNombreUsuario()%>-<%=u.encriptar(cveTutor)%></div>
                        </div>
                        <div class="description-requisito">TUTOR DEL GRUPO</div>
                        <div class="title-requisito">Nombre y firma</div>
                    </div>
                    <div class="requisito">
                        <div class="estatus-requisito">
                            <%=directorNombre.getNombreCompleto() %> <br>
                            <div class="minuscula"><%=directorNombre.getNombreUsuario() %>-<%=u.encriptar(cveDirector)%></div>
                        </div>
                        <div class="description-requisito">DIRECCCIÓN DE CARRERA</div>
                        <div class="title-requisito">Nombre y firma</div>
                    </div>
                </div>
                <div class="contenedor-requisito">
                    <div class="requisito">
                        <div class="estatus-requisito">
                            <%=a.getNombreCompleto() %> <br>
                            <div class="minuscula"><%=a.getMatricula() %>-<%=u.encriptar(claveAlumno)%></div>
                        </div>
                        <div class="description-requisito">ALUMNO</div>
                        <div class="title-requisito">Nombre y firma</div>
                    </div>
                    <div class="requisito">
                        <div class="estatus-requisito">
                            <%=escolaresNombre.getNombreCompleto()%> <br>
                            <div class="minuscula"><%=escolaresNombre.getNombreUsuario() %>-<%=u.encriptar(cveEscolares)%></div>
                        </div>
                        <div class="description-requisito">SERVICIOS ESCOLARES</div>
                        <div class="title-requisito">Nombre y firma</div>
                    </div>
                </div>
            </section> 
        </div>
    </body>
    <script>
        window.print();
    </script>
</html>
<%
    }
%>
