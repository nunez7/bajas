<%-- 
    Document   : submodulo19
    Created on : 10/12/2021, 12:50:25 PM
    Author     : raul_
--%>

<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="mx.edu.utdelacosta.*"%>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
 <% 
    HttpSession sesion = request.getSession();
        Usuario usuario = (Usuario) sesion.getAttribute("usuario");
        if((!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Director") && !usuario.getRol().equals("Academia")) || (sesion.getAttribute("usuario") == null)){
            response.sendRedirect("../login.jsp?modulo=17&tab=1");
        }
        
        int cvePersona = usuario.getCvePersona();
        Carrera carrera = new Carrera(usuario.getCveCarrera());
        carrera.construir();
        String division =  carrera.getDivision();
        
        Datos siest = new Datos();
        //consulta para traerse las solicitudes de baja
        ArrayList<CustomHashMap> datos = siest.ejecutarConsulta("SELECT DISTINCT(be.cve_baja_estatus) as cvebajaestatus, CONCAT(p.nombre, ' ',p.apellido_paterno, ' ',p.apellido_materno ) AS nombrecompleto, "
                + "a.matricula, tb.tipo as tipobaja, cb.causa as causa, bs.motivo, bs.comentario, "
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
                + "ON ag.cve_alumno = a.cve_alumno "
                + "RIGHT JOIN grupo g "
                + "ON g.cve_grupo = ag.cve_grupo "
                + "INNER JOIN carrera c "
                + "ON c.cve_carrera = g.cve_carrera "
                + "INNER JOIN division d "
                + "ON d.cve_division = c.cve_division "
                + "WHERE be.activo = 'True' "
                + "AND sb.cve_situacion_baja = 1 "
                + "AND d.nombre ='" + carrera.getDivision() + "' ORDER BY fecha DESC ");
if(!datos.isEmpty())
{
 %>
<form>
    <table>
        <thead>
            <tr>
                <th>No.</th>
                <th>Nombre</th>
                <th>Matricula</th>
                <th>Grupo</th>
                <th>Carrera</th>
                <th>Acciones</th>
            </tr>
        </thead>
        <tbody>
            <%
                boolean alt = false;
                int n = 0;
            for (CustomHashMap dato : datos) {
            int cveAlumno = dato.getInt("cve_alumno");
            Alumno alumno = new Alumno(cveAlumno);
            String grupo = alumno.getLastGrupo().getNombre();
            //cve_solicitud_baja
            int cveBajaSolicitud = dato.getInt("cve_baja_solicitud");
            System.out.println("BajaSolicitud: " + cveBajaSolicitud);
            %>
            <tr class="<%if (alt) {
                    out.print("alt");
                }
                alt = !alt;%> division">
                <td class="index"><%=++n%></td>
                <td><%=dato.getString("nombrecompleto")%></td>
                <td><%=dato.getString("matricula") %></td>
                <td><%=grupo%></td>
                <td><%=dato.getString("carrera")%></td>
                <td>
                    <input type="button" id="cancelarSolicitud" data-cve="<%=cveBajaSolicitud%>" data-cveAlumno="<%=cveAlumno %>" class="cancelar" value="Cancelar"/>
                    <input type="button" id="cancelarSolicitud" data-cve="<%=cveBajaSolicitud%>" data-cveAlumno="<%=cveAlumno %>" class="cancelar" value="Aceptar"/>
                </td>
            </tr>
            <tr class="subdivision">
                <td colspan="6">
                    <a id="mostrar-<%=dato.getInt("cve_alumno")%>" href="modales/tutoriaIndividual.jsp?cveAlumno=<%=dato.getInt("cve_alumno")%>" class="dexter-modal" title="Mostrar detalles">
                        <u>Ver Tutorías individuales</u>
                    </a>
                </td>
            </tr>
            
            <%
                    //llave de cierre del for datos
                }
            %>
        </tbody>
    </table>
</form>
<p><strong>Para ver tutorías indiviales dar clic en el enlace</strong></p>

<script> 
    $(".cancelar").click(function (e) {
        e.preventDefault();
        $('input[type="button"]').attr('disabled','disabled');
        var estatus = null;
        var valorBoton = $(this).val(); //se trae el valor del boton 
        var comentario = null;
        if(valorBoton === "Cancelar"){
            estatus = "rechazada";
            while (comentario === null || comentario.trim() === ""){
                comentario = prompt("Escribe el comentario del rechazo", "");
            }
        }else{
            comentario = "Solicitud aceptada";
            estatus = "aceptada";
        }
        
        var cveBajaSolicitud = $(this).attr("data-cve");
        var cveAlumno = $(this).attr("data-cveAlumno");
        var parametros = {
            cveBajaSolicitud : cveBajaSolicitud,
            comentario : comentario,
            estatus: estatus,
            cvePersona : <%=cvePersona%>,
            cveAlumno : cveAlumno,
            action : "estatusDirector"
        };
        
        $.post("bajaAlumno", parametros, res).fail(error);
            function res(data) {
                var datos = data.split("-");
                if (datos[0] === "401") {
                    mensaje("No se encontro la ruta");
                } else if (datos[0] === "201") {
                    mensaje("Datos guardados");
                    location.href = "?modulo=17&tab=19";
                } else {
                    mensaje("Ocurrió un error :(");
                }
            }
            function error(data) {
                mensaje("¡Ups!.. Ocurrio un error al procesar los datos :-(");
                console.log(data);
            } 
    }); 
    
    //inicializa el modal de tutorías individuales.
    start_modal();
</script>
<% } else { %>
    <div class="tabla" style="display:block;">
       <div class="correct"  style="display:block;"> 
            <b>No hay solicitudes de baja.</b> 
       </div> 
    </div>
<%
    }
%>
