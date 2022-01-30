<%-- 
    Document   : generarBaja
    Created on : 22/12/2021, 10:14:49 PM
    Author     : raul_
--%>

<%@page import="mx.edu.utdelacosta.Periodo"%>
<%@page import="mx.edu.utdelacosta.CarearFecha"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="mx.edu.utdelacosta.RequestParamParser"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page import="mx.edu.utdelacosta.Sesion"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    HttpSession sesion = request.getSession();
    Sesion objetoSesion = new Sesion(sesion);

    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("../../login.jsp");
    } else {
        Usuario usuario = (Usuario) sesion.getAttribute("usuario");
        int cveGrupo;
        try {
            cveGrupo = (Integer) sesion.getAttribute("cveGrupo");
        } catch (Exception e) {
            cveGrupo = 0;
        }
        RequestParamParser parser = new RequestParamParser(request);
        int cveModulo = parser.getIntParameter("modulo", 0);
        int tab = parser.getIntParameter("tab", 0);
        int cvePersona = objetoSesion.getIntAttribute("cvePersona", usuario.getCvePersona());
        int cvePeriodo = usuario.getCvePeriodo();
        int cveAlumno = 0;
        //conexion a base de datos
        Datos siest = new Datos();
        //causas de la baja
        ArrayList<CustomHashMap> causas = siest.ejecutarConsulta("SELECT cve_causa_baja, causa "
                + "FROM causa_baja where activo = 'True' ORDER BY causa");

        CarearFecha cf = new CarearFecha();
        String fechaHoy = cf.hoy();
%>

<form id="form-gen-baja">
    <legend>Registro de baja</legend>
    <%@include file="lista_grupos.jsp" %>
    <ol class="<%=sesion.getAttribute("cveGrupo") == null ? "d-none" : ""%>" id="registroBaja">
        <li>
            <div class="row">
                <div class="col-md-4">
                    <label for="cvePersona">Alumno</label>
                    <input type="hidden" name="cvePeriodo" value="<%=cvePeriodo %>">
                    <input type="hidden" name="cvePersona" value="<%=cvePersona %>">
                    <input type="hidden" name="action" value="registroBaja">
                    <select name="cveAlumno" id="cvePersona" class="form-control" required title="Selecciona un alumno">
                        <option value="">Seleccione...</option>
                        <%
                            ArrayList<CustomHashMap> alumnos = siest.ejecutarConsulta("SELECT p.cve_persona, a.cve_alumno, CONCAT(p.apellido_paterno , ' ' , p.apellido_materno , ' ' , p.nombre) AS nombre_completo"
                                    + " FROM persona p"
                                    + " INNER JOIN alumno a ON a.cve_persona = p.cve_persona"
                                    + " INNER JOIN alumno_grupo ag ON a.cve_alumno = ag.cve_alumno"
                                    + " INNER JOIN grupo g ON g.cve_grupo = ag.cve_grupo"
                                    + " WHERE ag.cve_grupo=" + cveGrupo + " "
                                    + "ORDER BY p.apellido_paterno, p.apellido_materno, p.nombre");
                            for (CustomHashMap alumno : alumnos) {
                        %>
                        <option value="<%=alumno.getInt("cve_alumno")%>"> <%=alumno.getString("nombre_completo")%></option>
                        <%

                            }
                        %>
                    </select>
                </div>
                <div class="col-md-2 tipoBaja">
                    <label>Tipo de baja </label>
                    <script>
                        $("#cvePersona").change(function () {
                            var parametros = {
                                cveAlumno : $("#cvePersona").val(),
                                action : 'noBajas'
                            };
                            $.post("../bajaAlumno", parametros, res).fail(error);
                            function res(data) {
                                var datos = data.split("-");
                                if(datos[1] === "0"){
                                   $("#cveTipoBaja").remove();
                                   $("#temporal").remove();
                                   $("#definitiva").remove();
                                   $(".tipoBaja").append("<span class='form-control' id='cveTipoBaja'>Temporal</span>");
                                   $(".tipoBaja").append("<input type='hidden' name='cveTipoBaja' id='temporal' value='1'>");
                                   //aqui quiero asignar el valor 
                                } else if (datos[1] > "0") {
                                    //aqui quiero asignar el valor 
                                    $("#cveTipoBaja").remove();
                                    $("#temporal").remove();
                                    $("#definitiva").remove();
                                    $(".tipoBaja").append("<span class='form-control' id='cveTipoBaja'>Definitiva</span>");
                                    $(".tipoBaja").append("<input type='hidden' name='cveTipoBaja' id='definitiva' value='2'>");
                                } else {
                                    console.log("Algo salió feo bajas :( -- " + data);
                                }
                            }
                            function error(data) {
                                mensajeError("Algo sali&oacute; mal bajas :( " + data);
                            }
                        });
                        
                    </script>
                </div>
                <div class="col-md-3">
                    <label>Causa de la baja</label>
                    <select name="cveCausaBaja" id="cveCausaBaja" class="form-control" required required title="Selecciona una causa">
                        <option value="">Seleccione...</option>
                        <%
                            //iteramos las causas que se encontraron en la consulta (causas)
                            for (CustomHashMap causa : causas) {
                        %>
                        <option value="<%=causa.getInt("cve_causa_baja")%>"> <%=causa.getString("causa")%></option>
                        <%
                            //cierre de if de causas de baja
                            }
                        %>
                    </select>
                </div>
                <div class="col-md-3">
                   <label>Fecha asistio a clases</label>
                   <input type="date" id="fechaAsistioClase" name="fechaAsistioClase" value="<%=fechaHoy %>" class="form-control">
                </div>
            </div>
        </li>
        <li>
            <div class="row">
                <div class="col-md-6">
                    <label for="motivo">Motivo de la baja</label>
                    <textarea id="motivo" name="motivo" rows="2" cols="80" maxlength="350" style="resize:none;" required title="Motivo" placeholder="Escribe el motivo de la baja"></textarea>
                </div>
                <div class="col-md-6">
                    <label for="comentario">Comentario de tutor</label>
                    <textarea id="comentario" name="comentario" rows="2" cols="80" maxlength="350" style="resize:none;" required title="Comentario" placeholder="Escribe un comentario.">Ninguno</textarea>
                </div>
            </div>
        </li>
        <li class="derecha">
          <input type="submit" id="enviar" value="Generar baja">
        </li>
    </ol>
</form>
<script>
    $(".cveGrupo").click(function (e) {
        e.preventDefault();
        $("#registroBaja").removeClass("d-none");
        var grupo = $(this).attr("data-g");
        $(".breadcrumb-item").removeClass("active");
        $("#bi" + grupo).addClass("active");
        $("#selectG").addClass("d-none");
        cargarAlumnos(grupo);
    });
    function cargarAlumnos(cveGrupo) {
        $("#cvePersona").load('modulos/tutorias/selectAlumnos.jsp?cveGrupo=' + cveGrupo);
    }
    
    $("#form-gen-baja").submit(function (e){
        e.preventDefault();
        $('input[type="submit"]').attr('disabled','disabled');
        $.post("../bajaAlumno", $(this).serialize(), res).fail(error);
        function res(data) {
            var datos = data.split("-");
            if(datos[0] === "401"){
                mensaje("no se encontro la ruta");
            } else if (datos[0] === "201") {
                mensaje("Baja registrada");//mensaje que será enviado
                location.href = "?modulo=192&tab=246";
            } else {
                console.log("Algo salió feo :( -- " + data);
            }
        }
        function error(data) {
            mensajeError("Algo sali&oacute; mal :( ");
        }
    });
</script>

<% 
   //cierre de else de usuario null 
   }
%>
