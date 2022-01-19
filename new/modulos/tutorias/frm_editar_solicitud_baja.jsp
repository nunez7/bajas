<%-- 
    Document   : frm_editar_solicitud_baja
    Created on : 3/12/2021, 09:54:12 AM
    Author     : raul_
--%>

<%@page import="java.util.*"%>
<%@page import="mx.edu.utdelacosta.Datos"%>
<%@page import="mx.edu.utdelacosta.RequestParamParser"%>
<%@page import="mx.edu.utdelacosta.Usuario"%>
<%@page import="mx.edu.utdelacosta.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%
    HttpSession sesion = request.getSession();
    RequestParamParser parser = new RequestParamParser(request);
    Usuario usuario = (Usuario) sesion.getAttribute("usuario");
    if (usuario == null || !usuario.getRol().equals("Profesor")) {
        response.sendRedirect("../login.jsp");
    } else {
        //cvePersona en este caso el usuario que se logueo
        int tutor = usuario.getCvePersona();
        //cveBajaSolicitud enviada por parametro de url
        int cveBajaSolicitud = parser.getIntParameter("cveBajaSolicitud", 0);
        //conexion a b;ase de datos
        Datos siest = new Datos();
        //se trae la bajaSolicitus seleccionada
        ArrayList<CustomHashMap> solicitud = siest.ejecutarConsulta("SELECT bs.cve_tipo_baja as tipoBaja, bs.motivo as descripcion, TO_CHAR(bs.fecha_alta, 'DD/MM/YYYY') as fecha, bs.cve_alumno as alumno, bs.asistio_clase "
                + "FROM baja_solicitud bs "
                + "INNER JOIN baja_estatus be "
                + "ON bs.cve_baja_solicitud=be.cve_baja_solicitud "
                + "WHERE bs.cve_baja_solicitud=" + cveBajaSolicitud);

        int cveAlumno = solicitud.get(0).getInt("alumno");
        //para extraer la cvePersona del alumno
        Alumno alumno = new Alumno(cveAlumno);
        alumno.construir();
        int cvePersona = alumno.getCvePersona();

        CarearFecha cf = new CarearFecha();
        String fechaHoy = cf.hoy();
        String horaHoy = cf.getHoraHoy();
        Periodo p = new Periodo(usuario.getCvePeriodo());
        String fechaIn = p.getFechaInicio();
%>

<form id="frm-actualizar-baja"> 
    <legend>Edición</legend>
    <ol>
        <li class="container">
            <div class="row">
                <div class="col-md-4">
                    <label>Fecha</label>
                    <input type="text" id="fechaAlta" class="form-control" value="<%=solicitud.get(0).getString("fecha")%>" disabled>
                </div>
                <div class="col-md-4">
                    <label>Tipo de baja</label>
                    <select id="cveTipoBaja" class="form-control" disabled>
                        <%
                            if (solicitud.get(0).getInt("tipobaja") == 1) {
                        %>
                        <option value="">Temporal</option>
                        <%
                        } else {
                        %>
                        <option value="">Definitiva</option>
                        <%
                            }
                        %>
                    </select>
                </div>
            </div>
        </li>
        <li class="container">
            <div class="row">
                <div class="col-md-6">
                    <label>Motivo</label> <br>
                    <textarea id="motivoBs" rows="2" cols="150" maxlength="500" style="resize:none;"readonly><%=solicitud.get(0).getString("descripcion")%></textarea>
                </div>
                <div class="col-md-6">
                    <label>Seguimiento </label> <br>
                    <textarea id="comentario"  rows="2" cols="150" maxlength="500" style="resize:none;" value="" placeholder="" title="Comentarios del tutor"></textarea>
                </div>
            </div>
        </li>
        <li class="container">
            <div class="row">
                <div class="col-md-3">
                    <label>Fecha asistio a clases</label>
                    <input type="date"  id="fechaAsistioClase" class="form-control" value="<%=solicitud.get(0).get("asistio_clase")%>">
                </div>
            </div>
        </li>
    </ol>
</form>
<!-- se despliega si el tutor quiere registrar una tutoria -->
<form id="frm-guardarTutoria">
    <ol>
        <li>
        <legend>Tutoría</legend>
        <div class="row">
            <div class="col-md-3">
                <label for="fecha_atendio">Fecha</label>
                <input type="date" name="fechaAtendio" id="fecha_atendio" class="form-control" value="<%=fechaHoy%>" max="<%=fechaHoy%>" title="Fecha de atenci&oacute;n"/> &nbsp;&nbsp;&nbsp;
            </div>
            <div class="col-md-3">
                <label for="fecha_atendio">Hora</label>
                <input type="time" name="horaAtendio" id="hora_atendio" class="form-control" value="<%=horaHoy%>" title="Hora de atenci&oacute;n" />
            </div>
            <input type="hidden" name="cveAlumno" id="cveAlumno" value="<%=cveAlumno%>">
        </div>
        </li>
        <li>
            <label>Motivo(s)</label>
            <br />
            <%
                //conexion a base de datos
                ArrayList<CustomHashMap> motivos = siest.ejecutarConsulta("SELECT cve_motivo_consulta, "
                        + "descripcion, cve_rol "
                        + "FROM motivo_consulta "
                        + "WHERE cve_rol = 2 AND activo =true "
                        + "ORDER BY descripcion");
                for (CustomHashMap m : motivos) {
            %>
            <div class="form-check form-check-inline">
                <input type="checkbox"
                       value="<%=m.getInt("cve_motivo_consulta")%>" data-mot="<%=m.getString("descripcion")%>" 
                       id="cm<%=m.getInt("cve_motivo_consulta")%>" class="check_motivo">
                <label class="form-check-label" for="cm<%=m.getInt("cve_motivo_consulta")%>"><%=m.getString("descripcion")%></label>
            </div>
            <%
                }
            %>
        </li>
        <li>	   
            <label for="objetivo">Objetivo</label>
            <textarea id="objetivo" name="objetivo" rows="2" cols="60" maxlength="150" style="resize:none;" placeholder="Dependiendo de la problem&aacute;tica..." title="Objetivo" required></textarea>
        </li>
        <li>
            <label>Descripci&oacute;n</label>
            <br />
            <table>
                <tr>
                    <th>Valoraci&oacute;n del profesor</th>
                    <th>Descripci&oacute;n de la problem&aacute;tica</th>
                </tr>
                <%
                    for (CustomHashMap mo : motivos) {
                %>
                <tr>
                    <td><%=mo.getString("descripcion")%></td>
                    <td id="motivo-table">
                        <textarea style="resize:none;" disabled id="motdesc-<%=mo.getInt("cve_motivo_consulta")%>" name="com-motivo-<%=mo.getInt("cve_motivo_consulta")%>" cols="80" maxlength="400"></textarea>
                    </td>
                </tr>
                <%
                    }
                %>
            </table>
        </li>
        <li>
            <label for="acuerdos">Acuerdos y compromisos</label>
            <textarea id="acuerdos" name="diagnostico" rows="3" cols="80" maxlength="500" style="resize:none;" placeholder="De la tutor&iacute;a..." required  title="Acuerdos y compromiso"></textarea>
        </li>
        <li>
            <div class="row">
                <div class="col-md-3">
                    <label for="userP">Usuario /matricula</label>
                    <input type="text" id="user" class="form-control" placeholder="Usuario" value="" readonly />
                </div>
                <div class="col-md-3">
                    <label>Contrase&ntilde;a</label>
                    <input type="password" class="form-control" id="password" required placeholder="Contrase&ntilde;a" />
                    <input type="hidden" name="estado" id="contra" value="False" />
                    <input type="hidden" name="cveServicio" value="1" />
                    <input type="hidden" name="observacion" id="observacion" value="Ninguna" />
                    <input type="hidden" name="motivo" id="motivo" value="" />
                    <input type="hidden" name="motivoCanalizo" id="motivoCanalizo" value="" />
                    <input type="hidden" name="cveAtendido" id="cveAtendido" value="<%=cvePersona%>" />
                </div>
                <div class="col-md-6">
                    <label>Nivel de atenci&oacute;n por alerta de deserci&oacute;n</label><br />
                    <%
                        ArrayList<CustomHashMap> nivelesDesercion = siest.ejecutarConsulta("SELECT cve_nivel_desercion, descripcion FROM nivel_desercion WHERE activo=true");
                        for (CustomHashMap nd : nivelesDesercion) {
                    %>
                    <div class="form-check form-check-inline">
                        <input class="form-check-input cnd" <%if (nd.getString("descripcion").equals("Bajo")) {%>checked<%}%> 
                               type="radio" name="nivelDesercion" id="nd-<%=nd.getInt("cve_nivel_desercion")%>" 
                               value="<%=nd.getInt("cve_nivel_desercion")%>" required>
                        <label class="form-check-label" for="nd-<%=nd.getInt("cve_nivel_desercion")%>">
                            <%=nd.getString("descripcion")%>
                        </label>
                    </div>
                    <%
                        }
                    %>
                </div>
            </div>
        </li>
        <li class="derecha">	
            <input type="submit" id="rechazar" value="Rechazar">
            <input type="submit" id="aceptar" value="Aceptar">
        </li>
    </ol>
</form>

<script>

    //funcion para cuando cambie un campo del formulario de la solicitud de baja
    $("#comentario, #fechaAsistioClase").change(function (e) {
        e.preventDefault();
        var parametros = {
            cveBajaSolicitud: <%=cveBajaSolicitud%>,
            comentario: $("#comentario").val(),
            fechaAsistio: $("#fechaAsistioClase").val(),
            action: 'editar'
        };

        $.post("../bajaAlumno", parametros, res).fail(error);
        function res(data) {
            var datos = data.split("-");
            if (datos [0] === "401") {
                mensaje("no se encontro la ruta");
            } else if (datos[0] === "201") {
                console.log("Se actualizo la solicitud");//mensaje que será enviado
                //location.href = "?modulo=192&tab=245";
            } else {
                console.log("Algo salió feo :( -- " + data);
            }
        }
    });

    //envio del formulario 
    $("#frm-guardarTutoria").submit(function (e) {
        e.preventDefault();
        $('input[type="submit"]').prop('disabled', true);
        //se trael el valor del boton presionado
        var action = $(this).find("input[type=submit]:focus").val();
        var estatus = "rechazada";

        var seleccionados = $('input:checkbox:checked').length;
        if (seleccionados <= 0)
        {
            mensajeInfo("Selecciona por lo menos un motivo");
            return false;
        }
        //Recorremos los inputs checados
        recorrerInputs();
        $.post("../ConsultaServicio", $(this).serialize(), res).fail(error);
        function res(data) {
            var datos = data.split("-");
            if (datos[1] === "queryok") {
                mensaje("Ya se registro la cita");
            } else if (datos[1] === "created") {
                //para registar en la tabla baja_solicitud_tutoría
                var cveConsultaServicio = parseInt(datos[2]);
                var parametros = {
                    cveBajaSolicitud: <%=cveBajaSolicitud%>,
                    cveConsultaServicio: cveConsultaServicio,
                    action: "bajaSolicitudTutoria"
                };
                $.post("../bajaAlumno", parametros, res).fail(error);
                function res(data) {
                    var datos = data.split("-");
                    if (datos[0] === "401") {
                        mensaje("no se encontro la ruta");
                    } else if (datos[0] === "201") {
                        if (action.trim() === "Rechazar") {
                            estatusSolicitud(estatus);
                        } else {
                            estatus = "aceptada";
                            estatusSolicitud(estatus);
                        }
                    } else {
                        console.log("Algo salió feo :( -- " + data);
                    }
                }
            } else {
                console.log("error al ingresar la tutoria");
                alert("Ocurrió un error al procesar los datos. " + datos[1]);
            }
        }
    });

    function estatusSolicitud(estatus) {
        var parametros = {
            cveBajaSolicitud: <%=cveBajaSolicitud%>,
            cveAlumno: <%=cveAlumno%>,
            comentario: $("#comentario").val(),
            cvePersona: $("#cvePersona").val(),
            estatus: estatus,
            action: "estatusProfesor"
        };
        $.post("../bajaAlumno", parametros, res).fail(error);
        function res(data) {
            var datos = data.split("-");
            if (datos[0] === "401") {
                mensaje("no se encontro la ruta");
            } else if (datos[0] === "201") {
                mensaje("Datos guardados");
                location.href = "?modulo=192&tab=245";
            } else {
                console.log("Algo salió feo :( -- " + data);
            }
        }
    }
    
    //funcion para obtener el usuario del alumno
    $.post("../obtenerUsuario", "cvePersona=<%=cvePersona%>", res).fail(error);
    function res(data) {
        var datos = data.split("._.");
        if (datos[1] === "alumnono") {
            mensajeInfo("El alumno no cuenta con usuario y contrase&ntilde;a");
        } else if (datos[0] === "ok") {
            $("#user").val(datos[1]);
        } else {
            console.log("Algo sali&oacute; feo :( -- " + data);
        }
    }


    //función para recorrer los input
    function recorrerInputs() {
        var selected = '';
        var motivos = '';
        $('input[type=checkbox].check_motivo').each(function () {
            if (this.checked) {
                selected += $(this).val() + '-';
            }
        });
        $('.check_motivo').each(function () {
            if ($(this).is(":checked")) {
                motivos += $(this).attr("data-mot") + ", ";
            }
        });
        //eliminamos el ultimo guin (-).
        selected = selected.substring(0, selected.length - 1);
        //Eliminamos la , y espacio
        motivos = motivos.substring(0, motivos.length - 2);
        $("#motivo").val(selected);
        $("#motivoCanalizo").val(motivos);
    }

    //para checar cual motivo esta seleccionado y habilitarlo
    $(".check_motivo").click(function () {
        var valor = $(this).val();
        if ($(this).prop('checked')) {
            $("#motdesc-" + valor).removeAttr("disabled");
        } else {
            $("#motdesc-" + valor).attr("disabled", true);
        }
    });

    //Haremos una funcion para si pierde el foco el campo contrase&ntilde;a se verifique si es valida
    $("#password").focusout(function () {
        var valor = $(this).val();
        var user = $("#user").val();
        if (user !== "") {
            var datos = {
                user: user,
                password: valor
            };
            $.post("../verificarUC", datos, res).fail(error);
            function res(data) {
                var datos = data.split("._.");
                if (datos[1] === "1") {
                    mensaje("La contrase&ntilde;a es correcta");
                    $("#password").css({
                        "border": "green 1px solid"
                    });
                    $("#contra").val("True");
                } else if (datos[1] === "0") {
                    mensajeInfo("La contrase&ntilde;a es incorrecta");
                    $("#password").css({
                        "border": "red 1px solid"
                    });
                    $("#contra").val("False");
                } else {
                    console.log("Algo sali&oacute; feo :( -- " + data);
                }
            }
        }
    });
    function error(data) {
        mensajeError("Algo sali&oacute; mal :( ");
        console.log(data);
    }

</script>
<%
    }
%>