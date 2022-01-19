<%-- 
    Document   : submodulo13
    Created on : 24/11/2021, 10:54:16 AM
    Author     : raul_
--%>
<%@page import="mx.edu.utdelacosta.ParserDate"%>
<%@page import="mx.edu.utdelacosta.Alumno"%>
<%@page import="mx.edu.utdelacosta.CarearFecha"%>
<%@page import="java.util.ArrayList"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="mx.edu.utdelacosta.CustomHashMap"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
HttpSession sesion = request.getSession();
    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("../../login.jsp?modulo=23&tab=1");
    } else {
        int cveAlumno;
        try {
            cveAlumno = (Integer) sesion.getAttribute("cveAlumno");
        } catch (Exception e) {
            cveAlumno = 0;
        }
        Alumno alumno = new Alumno(cveAlumno);
        alumno.construir();
        //conexion a base de datos
        Datos siest = new Datos();
        //consulta que trae las causas de las bajas (causa_baja)
        ArrayList<CustomHashMap> causas = siest.ejecutarConsulta("SELECT cve_causa_baja, causa "
                + "FROM causa_baja where activo = 'True'");
        //consulta para saber que tipo de baja será si temporal o definitiva
        ArrayList<CustomHashMap> tipos = siest.ejecutarConsulta("SELECT bs.cve_baja_solicitud "
            + "FROM baja_solicitud bs "
            + "INNER JOIN baja_estatus be "
            + "ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
            + "INNER JOIN situacion_baja sb "
            + "ON sb.cve_situacion_baja = be.cve_situacion_baja "
            + "WHERE bs.cve_alumno =" + cveAlumno   
           // + "AND be.activo = 'True' "
            + "AND sb.cve_situacion_baja = '5'");
        
        //consulta para traer el grupo actual del alumno
        
        ArrayList<CustomHashMap> grupos = siest.ejecutarConsulta("SELECT g.cve_grupo, g.nombre "
            + "FROM alumno_grupo ag "
            + "INNER JOIN periodo p "
            + "ON ag.cve_periodo = p.cve_periodo "
            + "INNER JOIN grupo g "
            + "ON ag.cve_grupo = g.cve_grupo "
            + "WHERE ag.cve_alumno =" + cveAlumno + " ORDER BY ag.cve_periodo DESC LIMIT 1"); 
        
        //el método siguiente trae la clave del periodo 
        String matricula = alumno.getMatricula();
        int periodo = alumno.getLastGrupo().getCvePeriodo();
        int cveGrupo = grupos.get(0).getInt("cve_grupo");
        
        //consulta que trae si hay solicitudes de baja del alumno
        /*
        ArrayList<CustomHashMap> solicitudes = siest.ejecutarConsulta("SELECT CAST(COUNT(bs.cve_baja_solicitud) as INTEGER) as solicitudes "
            + "FROM baja_solicitud bs "
            + "INNER JOIN baja_estatus be "
            + "ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
            + "WHERE cve_alumno =" +cveAlumno
            + "AND NOT be.cve_situacion_baja = 5");
        
        int solicitud = solicitudes.get(0).getInt("solicitudes");
        */
        
        ArrayList<CustomHashMap> totalSolicitudes = siest.ejecutarConsulta("SELECT CAST(COUNT(bs.cve_baja_solicitud) AS INTEGER) as bajas FROM baja_solicitud bs "
                    + "INNER JOIN baja_estatus be "
                    + "ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
                    + "WHERE cve_alumno =" + cveAlumno
                    + " AND be.activo = 'True' "
                    + "AND be.cve_situacion_baja NOT IN (9)");
        int solicitudesTotal = totalSolicitudes.get(0).getInt("bajas");
        
        //consulta que trae si hay solicitudes de baja del alumno las que son activas
        ArrayList<CustomHashMap> solicitudesTodas = siest.ejecutarConsulta("SELECT CAST(COUNT(bs.cve_baja_solicitud) as INTEGER) as solicitudes "
            + "FROM baja_solicitud bs "
            + "INNER JOIN baja_estatus be "
            + "ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
            + "WHERE bs.cve_alumno=" + cveAlumno + " AND be.activo = 'True' ");
        int todasSolicitudes = solicitudesTodas.get(0).getInt("solicitudes");
%>
            <form method="post" action="" id="solicitud-baja-form" class="tablaScroll">
                <fieldset>
                    <legend>Solicitud de baja</legend>
                    <ol>
                        <li>
                            <label>Tipo de baja: </label>
                            <input type="hidden" name="cveAlumno" id="cveAlumno" value="<%=cveAlumno %>">
                            <input type="hidden" name="cvePeriodo" id="cvePeriodo" value="<%=periodo %>">
                            <input type="hidden" name="cveGrupo" id="cveGrupo" value="<%=cveGrupo %>">
                            <input type="hidden" id="matricula" value="<%=matricula %>">
                            <input type="hidden" name="action" id="action" value="solicitud">
                            <select name="cveTipoBaja" id="cveTipoBaja" required title="Tipo de baja">
                                <%
                                    if(tipos.size() == 0){
                                %>
                                    <option value="1">Temporal</option>
                                <%
                                    } else {
                                %>
                                    <option value="2">Definitiva</option>
                                <% 
                                    //cierre de else
                                    }
                                %>
                            </select>
                        </li>
                        <li>
                            <label for="causaBaja">Causa de la baja: </label>
                            <select name="cveCausaBaja" id="cveCausaBaja" required title="Selecciona una causa">
                                <option value="">Seleccione...</option>
                                <%
                                    //iteramos las causas que se encontraron en la consulta (causas)
                                    for(CustomHashMap causa : causas) {
                                %>
                                <option value="<%=causa.getInt("cve_causa_baja")%>"> <%=causa.getString("causa")%></option>
                                <%

                                    }
                                %>
                            </select>
                        </li>
                        <li>
                            <label for="motivo">Motivo de la baja:</label>
                            <textarea id="motivo" name="motivo" rows="2" cols="80" maxlength="350" style="resize:none;" required title="Motivo" placeholder="Escribe el motivo de la baja"></textarea>
                        </li>
                        <li>
                            <label for="comentario">Comentario</label>
                            <textarea id="comentario" name="comentario" rows="2" cols="80" maxlength="350" style="resize:none;" title="Comentario" placeholder="Escribe un comentario si tienes uno."></textarea>
                        </li>
                        <li>
                            <label>&nbsp;</label>
                            <input type="submit" name="salicitudBaja" value=" Enviar " />
                        </li>
                        <p><strong> La primera baja es temporal, la segunda es definitiva.</strong></p>
                    </ol>
                </fieldset>
            </form>
<%
    if(todasSolicitudes > 0 ){
    //datos de la solicitud de baja
    ArrayList<CustomHashMap> datos = siest.ejecutarConsulta("SELECT be.cve_baja_estatus as cvebajaestatus, CONCAT(p.nombre, ' ',p.apellido_paterno, ' ',p.apellido_materno ) AS nombrecompleto, "
            + "a.matricula, tb.tipo as tipobaja, cb.causa as causa, bs.motivo, bs.comentario, TO_CHAR(bs.fecha_alta, 'DD/MM/YYYY') as fecha, sb.descripcion as estado "
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
            + "WHERE be.activo = 'True' "
            + "AND bs.cve_alumno =" + cveAlumno
            + "ORDER BY bs.fecha_alta DESC ");
    //traemos los datos de la solicitud 

%>                    
<!-- se mostrara si el usuario tiene solicitudes de baja -->
        <form class="tablaScroll">
            <fieldset class="si">
                <legend>Solicitudes</legend>
                    <table class="datos">
                        <thead>
                            <tr>
                                <th>No.</th>
                                <th>Causa</th>
                                <th>Motivo</th>
                                <th>Tipo de baja</th>
                                <th>Fecha</th>
                                <th>Estado</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                int n = 0;
                                for(CustomHashMap d : datos){
                                String estado = d.getString("estado");
                            %>
                            <tr>
                                <td><%=++n %></td>
                                <td><%=d.getString("causa") %></td>
                                <td><%=d.getString("motivo") %></td>
                                <td><%=d.get("tipobaja") %></td>
                                <td><%=d.getString("fecha") %></td>
                                <td><%=d.getString("estado") %></td>
                                <%
                                 if(estado.equals("Enviada")){  
                                %>
                                <td> <input type="button" id="cancelarSolicitud" data-id="<%=d.getInt("cvebajaestatus") %>" class="eliminar" value="Cancelar"/></td>
                                <% 
                                    } else{
                                %>
                                    <td></td>
                                <% 
                                    }
                                %>
                            </tr>
                            <% 
                            }
                            %>
                        </tbody>
                    </table>
            </fieldset>
        </form>
        <%
            //llave que cierra el if de las solicitudes
            }
        %>                
        
<script>
    //para validar cuando bloquear el formulario
        if(<%=solicitudesTotal %> > 0 ){ 
            $('input[type="submit"]').attr('disabled','disabled');
            $("#cveTipoBaja").attr('disabled','disabled');
            $("#cveCausaBaja").attr('disabled','disabled');
            $("#motivo").attr('disabled','disabled');
            $("#comentario").attr('disabled','disabled');
        }
        
    //función para cancelar la solicitud
    $('.eliminar').click(function (e) {
        e.preventDefault();
        mensaje("Enviando...");
        var cveBajaEstatus = $(this).data("id");
        $('input[type="button"]').attr('disabled','disabled');
        var parametros = {
            cveBajaEstatus: cveBajaEstatus,
            action : 'cancelar'
        };
        
        $.post("bajaAlumno", parametros, res).fail(error);
        function res(data) {
            var datos = data.split("-");
            if(datos[0] === "401"){
                mensaje("");
            } else if (datos[0] === "201") {
                mensaje("Solicitud cancelada");//mensaje que será enviado
                location.href = "?modulo=23&tab=13";
            } else {
                console.log("Algo salió feo :( -- " + data);
            }
        }
    });
    
    $("#solicitud-baja-form").submit(function (e){
        e.preventDefault();
        var contrasenia = null;
        while (contrasenia === null || contrasenia.trim() === ""){
                contrasenia = prompt("Valide su contraseña", "");
        }
        if($("#matricula").val() !== ""){
            var datos = {
                user : $("#matricula").val(),
                password : contrasenia
            };
            console.log(datos);
            $.post("verificarUC", datos, res).fail(error);
            function res(data) {
                var datos = data.split("._.");
                if (datos[1] === "1") {
                    mensaje("La contrase&ntilde;a es correcta");
                    mensaje("Enviando...");
                    $('input[type="submit"]').attr('disabled','disabled');
                    //this.seralizable es para traer todos los datos del formulario.
                    var parametros = {
                        cveAlumno : <%=cveAlumno%>,
                        cvePeriodo : $("#cvePeriodo").val(),
                        cveTipoBaja : $("#cveTipoBaja").val(),
                        cveCausaBaja : $("#cveCausaBaja").val(),
                        cveGrupo : <%=cveGrupo %>,
                        motivo : $("#motivo").val(),
                        comentario : $("#comentario").val(),
                        action : 'solicitud'
                    };
                    $.post("bajaAlumno", parametros, res).fail(error);
                    function res(data) {
                        var datos = data.split("-");
                        if(datos[0] === "401"){
                            mensaje(""); //mesaje que será enviado
                        } else if (datos[0] === "201") {
                            mensaje("Solicitud enviada");//mensaje que será enviado
                            location.href = "?modulo=23&tab=13";
                        } else {
                            console.log("Algo salió feo :( -- " + data);
                        }
                    }
                    function error(data){
                        mensaje("Algo salió mal :( ");
                        $('input[type="submit"]').attr('disabled','disabled');
                    }
                } else if (datos[1] === "0") {
                    mensajeInfo("La contrase&ntilde;a es incorrecta");
                    location.href = "?modulo=23&tab=13";
                } else {
                    console.log("Algo sali&oacute; feo :( -- " + data);
                }
            }
        }
        
        
        /*
        mensaje("Enviando...");
        $('input[type="submit"]').attr('disabled','disabled');
        //this.seralizable es para traer todos los datos del formulario.
        $.post("bajaAlumno", $(this).serialize(), res).fail(error);
        function res(data) {
            var datos = data.split("-");
            if(datos[0] === "401"){
                mensaje(""); //mesaje que será enviado
            } else if (datos[0] === "201") {
                mensaje("Solicitud enviada");//mensaje que será enviado
                location.href = "?modulo=23&tab=13";
            } else {
                console.log("Algo salió feo :( -- " + data);
            }
        }
        function error(data){
            mensaje("Algo salió mal :( ");
            $('input[type="submit"]').attr('disabled','disabled');
        }
        */
    });
    
    //envia el formulario a guardar los datos
    /*
    $("#solicitud-baja-form").submit(function (e){
        e.preventDefault();
        mensaje("Enviando...");
        $('input[type="submit"]').attr('disabled','disabled');
        //this.seralizable es para traer todos los datos del formulario.
        $.post("bajaAlumno", $(this).serialize(), res).fail(error);
        function res(data) {
            var datos = data.split("-");
            if(datos[0] === "401"){
                mensaje(""); //mesaje que será enviado
            } else if (datos[0] === "201") {
                mensaje("Solicitud enviada");//mensaje que será enviado
                location.href = "?modulo=23&tab=13";
            } else {
                console.log("Algo salió feo :( -- " + data);
            }
        }
        function error(data){
            mensaje("Algo salió mal :( ");
            $('input[type="submit"]').attr('disabled','disabled');
        }
    });
     */
</script>

<% 
    //finaliza else de la session del usuario
    }
%>