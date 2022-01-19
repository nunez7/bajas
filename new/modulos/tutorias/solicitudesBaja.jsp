<%-- 
    Document   : solicitudesBaja
    Created on : 2/12/2021, 01:46:25 PM
    Author     : raul_
--%>

<%@page import="mx.edu.utdelacosta.RequestParamParser"%>
<%@page import="java.util.*"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
    HttpSession sesion = request.getSession();
    Usuario usuario = (Usuario) sesion.getAttribute("usuario");
    RequestParamParser parser = new RequestParamParser(request);
    int tab = parser.getIntParameter("tab", 0);
    int cveModulo = parser.getIntParameter("modulo", 0);
    if(usuario == null || !usuario.getRol().equals("Profesor") )
    {
        response.sendRedirect("../login.jsp");
    }
    //cvePersona en este caso el usuario que se logueo
    int tutor = usuario.getCvePersona();
    //conexion a b;ase de datos
    Datos siest = new Datos();
    //consulta para traer las solicitudes de acuerdo al tutor y que sean activas
    ArrayList<CustomHashMap> solicitudes = siest.ejecutarConsulta("SELECT bs.cve_baja_solicitud, CONCAT(p.apellido_paterno,' ',p.apellido_materno,' ',p.nombre) as nombre,"
        + "bs.motivo, TO_CHAR(bs.fecha_alta, 'DD/MM/YYYY') as fecha "
        + "FROM baja_solicitud bs "
        + "INNER JOIN baja_estatus be "
        + "ON bs.cve_baja_solicitud = be.cve_baja_solicitud " 
        + "INNER JOIN alumno a "
        + "ON bs.cve_alumno = a.cve_alumno "
        + "LEFT JOIN persona p "
        + "ON a.cve_persona = p.cve_persona "
        + "WHERE be.cve_persona =" + tutor + "AND be.cve_situacion_baja = 6 "
        + "AND be.activo = 'True'");
    
if(!solicitudes.isEmpty()){

%>
   
    <ul class="lista">
        <%
            for(CustomHashMap s : solicitudes)
            {
        %>
                <li>
                    <!-- ira la ruta y los parametros para enviar a la otra pestaña -->
                    <a href="" class="mosCon" data-s="<%=s.getInt("cve_baja_solicitud")%>">
                        <span class="fecha"><%=s.getString("fecha")%></span>
                        <h4><%=s.getString("nombre") %></h4>
                        <p class="descripcion"><%=s.getString("motivo") %></p>
                    </a> 
                </li>
        <% 
            //cierra la iteración del for de solicitudes de baja
            }
        %>
    </ul>
    <script>
        $(".mosCon").on("click", function (e) {
            e.preventDefault();
            var cveSolicitudBaja = $(this).attr("data-s");
            cargarContenido("#content", "modulos/tutorias/frm_editar_solicitud_baja.jsp?cveBajaSolicitud="+ cveSolicitudBaja);
        });
    </script>
<% 
    //llave del if de solicitudes
    } else {
%>

<ul class="lista">
    <li>
        <a href="">
            <h4>¡Felicidades!</h4>
            <p class="descripcion">No hay solicitudes de baja</p>
        </a> 
    </li>
</ul>
<%
    }   
%>

