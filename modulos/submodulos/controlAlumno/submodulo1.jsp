<%@ page contentType="text/html; charset=utf-8" language="java" import="mx.edu.utdelacosta.*, java.sql.*, java.util.*, java.text.*" errorPage="" %>
<%
    HttpSession sesion = request.getSession();
    Sesion objetoSesion = new Sesion(sesion);

    if (sesion.getAttribute("usuario") == null) {
        response.sendRedirect("../../login.jsp?modulo=12");
    } else {

        Usuario usuario = (Usuario) sesion.getAttribute("usuario");

        if (!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Servicios escolares")) {
            response.sendRedirect("../../login.jsp");
        }

        DecimalFormat decimalFormat = new DecimalFormat("###,###,###,###.0");
        int cveAlumno = objetoSesion.getIntAttribute("cveAlumno", 0);
        Datos siest = new Datos();
%>
<script type="text/javascript" language="javascript">
    start_modal();
    $(document).ready(function () {
        $("#inscrito").hover(function () {
            $('#inscrito').html('¡Generar Baja!');
            //$('#pestana').css({display:'none'});
        }, function () {
            $('#inscrito').html('Inscrito');
        });

        $("#inscrito").click(function (event) {
            if (confirmar('¿Seguro que desea dar de baja este alumno?')) {
                //eliminarAsistencias('<%/*=cveHorario*/%>');
            }
        });
        $('#boton').click(function (event) {
            event.stopPropagation();
            $('#opciones').fadeIn(500);
        });
    });
    function deshacerBaja() {
        location.href = "modulos/submodulos/controlAlumno/terciarios/deshacerBaja.jsp";
    }
</script>

<form method="post" action="" id="editarAlu" class="tablaScroll"> 
    <input type="hidden" name="cveAlumno" value="<%=cveAlumno%>" />
    <input type="hidden" name="cveModulo" value="12" />
    <input type="hidden" name="tab" value="1" />           	
    <fieldset>
        <legend>Información general</legend>
        <ol>                        
            <%
                Alumno alumno = Alumno.construir(cveAlumno);
                ArrayList<CustomHashMap> documentosPrestados = alumno.getDocumentosPrestados();
                if (alumno.getCveAlumno() > 0) {
                    String comentario = "...";
                    ArrayList<CustomHashMap> comentarios = alumno.getComentariosDcumentos();
                    if (!comentarios.isEmpty()) {
                        comentario = comentarios.get(0).getString("comentario");
                    }
            %>
            <input type="hidden" name="cvePersona" value="<%=alumno.getCvePersona()%>" />
            <li>
                <label><strong>Nombre:</strong></label>
                <input type="text" name="nombre" size="30" value="<%=alumno.getNombre()%>" placeholder="Nombre" />
                <input type="text" name="apellidoPaterno" size="20" value="<%=alumno.getApellidoPaterno()%>" placeholder="Apellido paterno" />
                <input type="text" name="apellidoMaterno" size="20" value="<%=alumno.getApellidoMaterno()%>" placeholder="Apellido materno" />

                <!-- Menú de opciones del alumno -->

            <dd style="float:right;" class="menu-opciones">
                <span id="boton" class="gray-button">Opciones</span>
                <ul id="opciones" class="oculto">
                    <%
                        if (alumno.isActivo()) {
                    %>
                    <a class="dexter-modal" href="modales/toAspirante.jsp"><li>Regresar a aspirante</li></a>
                            <%
                            } else {
                            %>
                    <a href="javascript: deshacerBaja()">
                        <li>Deshacer baja</li>
                    </a>
                    <a class="dexter-modal" href="modulos/reinscribirAlumno.jsp?cvePersona=<%=alumno.getCvePersona()%>">
                        <li>Reinscribir</li>
                    </a>
                    <%
                        }
                    %>
                    <a href="reportes/calificaciones/boleta-121105.jsp?cAl=<%=alumno.getCveAlumno()%>&impresora=escolares&servicio=control_alumno" target="_blank">
                        <li>Boleta de calificaciones</li>
                    </a>
                    <a class="dexter-modal" href="modales/historial.jsp?cAl=<%=alumno.getCveAlumno()%>">
                        <li>Historial de calificaciones</li>
                    </a>
                    <a class="dexter-modal" href="modales/inscribirGrupo.jsp?cAl=<%=alumno.getCveAlumno()%>">
                        <li>Inscribir en grupo</li>
                    </a>
                    <a href="modulos/buscarRemisos.jsp" class="dexter-modal">
                        <li>Buscar alumno</li>
                    </a>
                </ul>
            </dd>
            </li>
            <li>
                <label><strong>Estado:</strong></label>
                <label>
                    <%
                        /**
                         * Verificar el estatur del alumno. ¿Alta o baja?*
                         */
                        if (alumno.isActivo()) {
                    %>
                    <span class="verde">Activo</span>
                    <%
                    } else {
                    %>
                    <span class="roja">Baja</span>
                    <%
                        }
                    %>
                </label>
                <%if (alumno.isActivo()) {%><input type="button" id="reinsc-al" value=" Reinscribir " /><%}%>
            </li>
            <li>
            <!-- se agrega el tipo de baja -->
            <%
                if(!alumno.isActivo()){
                    //se trae las bajas del alumno
                    ArrayList<CustomHashMap> tipos = siest.ejecutarConsulta("SELECT bs.cve_baja_solicitud "
                                + "FROM baja_solicitud bs "
                                + "INNER JOIN baja_estatus be "
                                + "ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
                                + "INNER JOIN situacion_baja sb "
                                + "ON sb.cve_situacion_baja = be.cve_situacion_baja "
                                + "WHERE bs.cve_alumno =" + cveAlumno
                                // + "AND be.activo = 'True' "
                                + "AND sb.cve_situacion_baja = '5'");
                    %> 
                    <label><strong>Tipo de baja:</strong></label>
                    <span class="roja"><%=tipos.size() == 1 ? "Temporal":"Definitiva"%></span>
            </li>
        </ol>

        <!-- Información del alumno -->

        <legend>Información del alumno</legend>
        <ol>
            <li>
                <label><strong>Matrícula:</strong></label>
                <input type="text" name="matricula" value="<%=alumno.getMatricula()%>" placeholder="Matrícula" />
            </li>
            <li>
                <h2>Carrera:</h2>
                <fieldset>
                    <%
                        ArrayList<CustomHashMap> carreras = alumno.getCarrerasGrupos();
                        for (CustomHashMap carrera : carreras) {
                    %>
                    <label style="white-space: noWrap">
                        <strong><%=carrera.getString("grupo")%><%=!carrera.getString("fecha_inscripcion").isEmpty() ? " (" + carrera.getString("fecha_inscripcion") + ")" : ""%></strong>- <%=carrera.getString("nombre")%>
                        <select class="aGrupo">
                            <option value="true-<%=carrera.getInt("cve_alumno_grupo")%>-<%=alumno.getCveAlumno()%>" <%if (carrera.getBoolean("activo"))
                                    out.print("selected");%>>Activo</option>
                            <option value="false-<%=carrera.getInt("cve_alumno_grupo")%>-<%=alumno.getCveAlumno()%>" <%if (!carrera.getBoolean("activo"))
                                    out.print("selected");%>>In-activo</option>
                        </select>
                    </label>
                    <%
                        }
                    %>
                </fieldset>
            </li>
            <li>
                <label>&nbsp;</label>
                <input type="submit" name="g.alumno" value=" Guardar cambios " />
            </li>
            <li>
                <label><strong>Requisito de inscripción:</strong></label>
                <span><%out.print(alumno.getEstadoInscripcion().split("-")[0].equals("0") ? "Completo" : alumno.getEstadoInscripcion().split("-")[1]);%></span>
            </li>
            <li>
                <label><strong>Estado de expediente:</strong></label>
                <span><%=alumno.getEstadoExpediente().split("-")[0]%><%out.print((!alumno.getEstadoExpediente().split("-")[0].equals("Completo")) ? alumno.getEstadoExpediente().split("-")[1] : "");%></span><br />
                <label>&nbsp;</label>
                <span style="color: red">Comentarios: <%=comentario%></span>
            </li>
            <li>
                <label><strong>Documentos prestados:</strong></label>
                <span><%out.print(documentosPrestados.size() == 0 ? "No" : "Si");%></span>
            </li>
            <li> 
                <label><strong>Calificación pendiente:</strong></label>
                <span><%out.print(alumno.tieneCalificacionPendiente(alumno.getPenultimoGrupo().getCveGrupo()) == true ? "Si" : "No");%></span>
                <br />
                <%
                    if (!documentosPrestados.isEmpty()) {
                %>
                <table>
                    <thead>
                        <tr>
                            <th>Fecha</th>
                            <th>Documento</th>
                            <th>Prestó</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (CustomHashMap p : documentosPrestados) {
                                Prestamo prestamo = new Prestamo(p.getInt("cve_prestamo"));
                        %>
                        <tr id="dev-<%=p.getInt("cve_documento_prestamo")%>">
                            <td><%=p.getString("fecha_alta")%></td>
                            <td><%=p.getString("documento")%></td>
                            <td><%=prestamo.getPersonaPresto().getNombre()%></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
                <%
                    }
                %>
            </li>
        </ol>
        <legend>Adeudos</legend>
        <ol>
            <%
                if (!alumno.getAdeudos().isEmpty()) {
            %>
            <li>
                <table>
                    <thead>
                        <tr>
                            <th>Concepto</th>
                            <th>Descripcion</th>
                            <th>Costo</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            for (Concepto concepto : alumno.getAdeudosConDescuento()) {
                        %>
                        <tr>
                            <td><%=concepto.getNombre()%></td>
                            <td><%=concepto.getDescripcion()%></td>
                            <td><%=concepto.getPrecio()%></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </li>
            <%
            } else {
            %>
            <li>Sin adeudos</li>
                <%
                    }
                %>
        </ol>
        <legend>Registro de bajas</legend>
        <ol>
            <%
                ArrayList<CustomHashMap> datos = siest.ejecutarConsulta("SELECT be.cve_baja_estatus as cvebajaestatus, CONCAT(p.nombre, ' ',p.apellido_paterno, ' ',p.apellido_materno ) AS nombrecompleto, "
            + "a.matricula, tb.tipo as tipobaja, cb.causa as causa, bs.motivo, bs.comentario, TO_CHAR(bs.fecha_alta, 'DD/MM/YYYY') as fecha, sb.descripcion as estado "
            + "FROM baja_solicitud bs INNER JOIN alumno a "
            + "ON bs.cve_alumno = a.cve_alumno "
            + "LEFT JOIN persona p ON a.cve_persona = p.cve_persona "
            + "INNER JOIN tipo_baja tb ON bs.cve_tipo_baja = tb.cve_tipo_baja " 
            + "INNER JOIN causa_baja cb ON bs.cve_causa_baja = cb.cve_causa_baja "
            + "INNER JOIN baja_estatus be ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
            + "LEFT JOIN situacion_baja sb ON be.cve_situacion_baja = sb.cve_situacion_baja "
            + "WHERE be.activo = 'True' "
            + "AND bs.cve_alumno =" + cveAlumno
            + "ORDER BY bs.fecha_alta DESC ");
            %>
                <% if(datos.size() > 0) { %>
                <li>
                    <table class="datos">
                        <thead>
                            <tr>
                                <th>No.</th>
                                <th>Causa</th>
                                <th>Motivo</th>
                                <th>Tipo de baja</th>
                                <th>Fecha</th>
                                <th>Estado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                int n = 0;
                                for (CustomHashMap d : datos) {
                            %>
                            <tr>
                                <td><%=++n%></td>
                                <td><%=d.getString("causa")%></td>
                                <td><%=d.getString("motivo")%></td>
                                <td><%=d.get("tipobaja")%></td>
                                <td><%=d.getString("fecha")%></td>
                                <td><%=d.getString("estado")%></td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                </li>
                <%
                    //cierre de if para solicitudes de baja
                    } else {
                %>
                <li>Sin bajas</li>
                <%
                    //cierre de else de solicitudes de baja
                    }
                %>
        </ol> 
        <legend>Pagos</legend>
        <ol>
            <%
                ArrayList<CustomHashMap> historiales = alumno.getHistorialPagosDetalle();
                if (!historiales.isEmpty()) {
                    String detalle = "";
            %>
            <li>
                <table>
                    <thead>
                    <th>Nombre</th>
                    <th>Detalle</th>
                    <th>Precio</th>
                    <th>Descuento</th>
                    <th>Cantidad</th>
                    <th>Importe</th>
                    <th>Fecha</th>
                    <th>Folio</th>
                    </thead>
                    <tbody>
                        <%
                            for (CustomHashMap h : historiales) {
                                ArrayList<CustomHashMap> saberConcepto = siest.ejecutarConsulta("SELECT * "
                                        + "FROM concepto_nivel_estudio "
                                        + "WHERE cve_concepto_pago = " + h.getInt("cve_concepto_pago"));
                                ArrayList<CustomHashMap> saberConceptoDos = siest.ejecutarConsulta("SELECT * "
                                        + "FROM concepto_pago_curso "
                                        + "WHERE cve_concepto_pago= " + h.getInt("cve_concepto_pago"));
                                ArrayList<CustomHashMap> detalleConce = null;
                                if (!saberConcepto.isEmpty() || !saberConceptoDos.isEmpty()) {
                                    detalleConce = siest.ejecutarConsulta("((SELECT peri.fecha_inicio, peri.fecha_fin, g.nombre AS grupo, CONCAT('') AS detalle "
                                            + "FROM pago_colegiatura pc "
                                            + "INNER JOIN alumno_grupo ag ON ag.cve_alumno_grupo=pc.cve_alumno_grupo "
                                            + "INNER JOIN detalle_factura df ON df.cve_detalle_factura=pc.cve_detalle_factura "
                                            + "INNER JOIN grupo g ON g.cve_grupo = ag.cve_grupo "
                                            + "INNER JOIN periodo peri ON peri.cve_periodo = g.cve_periodo "
                                            + "WHERE df.cve_detalle_factura= " + h.getInt("cve_detalle_factura") + ") "
                                            + "UNION "
                                            + "(SELECT peri.fecha_inicio, peri.fecha_fin, g.nombre AS grupo, CONCAT('') AS detalle "
                                            + "FROM ec_pago_colegiatura pc "
                                            + "INNER JOIN ec_alumno_grupo ag ON ag.cve_ec_alumno_grupo=pc.cve_ec_alumno_grupo "
                                            + "INNER JOIN detalle_factura df ON df.cve_detalle_factura=pc.cve_detalle_factura "
                                            + "INNER JOIN ec_grupo g ON g.cve_ec_grupo=ag.cve_ec_grupo "
                                            + "INNER JOIN periodo peri ON peri.cve_periodo = g.cve_periodo "
                                            + "WHERE df.cve_detalle_factura= " + h.getInt("cve_detalle_factura") + " ))"
                                            + "ORDER BY fecha_inicio");
                                    if (!detalleConce.isEmpty()) {
                                        detalle = new ParserDate().periodoAbreviado(detalleConce.get(0).get("fecha_inicio").toString(), detalleConce.get(0).get("fecha_fin").toString()) + " " + detalleConce.get(0).getString("grupo");
                                    }
                                } else {
                                    detalleConce = siest.ejecutarConsulta("(SELECT '' AS fecha_inicio, '' AS fecha_fin, gr.nombre AS grupo, "
                                            + "CONCAT(m.abreviatura , ' ' , CAST(coe.consecutivo AS VARCHAR(300)) ,'C. ') AS detalle "
                                            + "FROM pago_nivelacion pn "
                                            + "INNER JOIN nivelacion n ON n.cve_nivelacion = pn.cve_nivelacion "
                                            + "INNER JOIN unidad_tematica ut ON ut.cve_unidad_tematica = n.cve_unidad_tematica "
                                            + "INNER JOIN materia m ON m.cve_materia = ut.cve_materia "
                                            + "INNER JOIN detalle_factura df ON df.cve_detalle_factura = pn.cve_detalle_factura "
                                            + "INNER JOIN carga_horaria ch ON ch.cve_carga_horaria = n.cve_carga_horaria "
                                            + "INNER JOIN grupo gr ON ch.cve_grupo = gr.cve_grupo "
                                            + "INNER JOIN calendario_evaluacion ce ON ce.cve_carga_horaria = ch.cve_carga_horaria "
                                            + "AND ut.cve_unidad_tematica = ce.cve_unidad_tematica "
                                            + "INNER JOIN corte_evaluativo coe ON coe.cve_corte_evaluativo = ce.cve_corte_evaluativo "
                                            + "WHERE df.cve_detalle_factura=" + h.getInt("cve_detalle_factura") + " AND n.cve_tipo_nivelacion=1)"
                                            + "UNION("
                                            + "SELECT '' AS fecha_inicio, '' AS fecha_fin, gr.nombre AS grupo, m.abreviatura AS detalle "
                                            + "FROM pago_nivelacion pn "
                                            + "INNER JOIN nivelacion n ON n.cve_nivelacion = pn.cve_nivelacion "
                                            + "INNER JOIN carga_horaria ch ON ch.cve_carga_horaria = n.cve_carga_horaria "
                                            + "INNER JOIN materia m ON m.cve_materia=ch.cve_materia "
                                            + "INNER JOIN grupo gr ON ch.cve_grupo = gr.cve_grupo "
                                            + "INNER JOIN detalle_factura df ON df.cve_detalle_factura = pn.cve_detalle_factura "
                                            + "WHERE df.cve_detalle_factura=" + h.getInt("cve_detalle_factura") + " AND n.cve_tipo_nivelacion IN (3,4))");
                                    if (!detalleConce.isEmpty()) {
                                        detalle = detalleConce.get(0).getString("detalle") + " " + detalleConce.get(0).getString("grupo");
                                    }
                                }
                        %>
                        <tr>
                            <td><%=h.getString("concepto")%></td>
                            <td><%=detalle%></td>
                            <td>$ <%=decimalFormat.format(h.getDouble("precio"))%></td>
                            <td><%=h.getDouble("descuento")%> %</td>
                            <td><%=h.getInt("cantidad")%></td>
                            <td>$ <%=decimalFormat.format(h.getDouble("importe"))%></td>
                            <td><%=(h.get("fecha_pago")).toString()%></td>
                            <td>S- <%=h.get("folio")%></td>
                        </tr>
                        <%
                            }
                        %>
                    </tbody>
                </table>
            </li>
            <%
            } else {
            %>
            <li>Sin pagos</li>
                <%
                    }
                %>
        </ol>
        <%
        } else {
        %>
        <li>
            Sin resultados
        </li>
        <%
            }
        %>
    </fieldset>
</form>
<p class="nota">*Las notas se muestran en el perfil del alumno.</p>
</div>
</div>

<div id="nvo" style="display:none">     	
    <form>            	
        <fieldset>
            <legend>Nueva beca</legend>
            <div class="error">Error al tratar de guardar</div>
            <ol>
                <li>
                    <label for="nombre">Descripción<em>*</em></label>
                    <input type="text" size="15" maxlength="500" name="nombre" />
                </li>

                <li>
                    <label for="abreviatura">Abreviatura</label>
                    <input type="text" size="07" maxlength="15" name="abreviatura"/>
                </li>

                <li>
                    <label for="tipo">Tipo</label>
                    <label><input type="radio" name="tipo" />Interna</label>
                    <label><input type="radio" name="tipo" />Externa</label>
                </li>

                <li>
                    <label>&nbsp;</label>
                    <input type="submit" name="g.beca" value="Registrar beca"/>
                </li>
            </ol>
        </fieldset>
    </form>
    <script type="text/javascript">
        $(".aGrupo").change(changeStatus);
        function changeStatus() {
            $.post("funciones/bajaAlumnoGrupo.jsp", "estado=" + $(this).val(), res).fail(error);
            function res(data)
            {
                console.log(data);
                if (data.trim() === "ok") {
                    mensaje("Grupo actualizado");
                    location.reload();
                } else {
                    error(data);
                }
            }
        }
        $("#reinsc-al").click(function () {
            var confi = confirm("¿El alumno cumple con los requisitos de reinscripción?");
            if (confi) {
                $.post("funciones/reinscribirAlumno.jsp", "cveAlumno=<%=cveAlumno%>", res).fail(error);
                function res(data) {
                    if (data.trim() === "ok") {
                        mensaje("Alumno reinscrito");
                        location.reload();
                    } else if (data.trim() === "noalumno") {
                        mensajeInfo("Alumno no encontrado");
                    } else {
                        error(data);
                    }
                }
            }
        });
        $("#editarAlu").on("submit", function (e) {
            e.preventDefault();
            $.post("editarAlumno", $(this).serialize(), res).fail(error);
            function res(data)
            {
                console.log(data);
                var dato = data.split("-");
                switch (dato[0]) {
                    case "ok":
                        mensaje("Guardado");
                        console.log("Datos guardados -- " + data);
                        break;
                    case "error":
                        mensaje("Datos no guardados, ocurrio un error!");
                        console.log("Fallo -- " + data);
                        break;
                    default:
                        console.log("Datos no guardados -- " + data);
                        mensaje("Ocurrió un error al procesaro los datos. " + data);
                        break;
                }
            }
        });
        function error(data) {
            console.log(data);
            mensaje("¡Ups! No se pudo conectar con el servidor :(!");
        }
    </script>
    <%
        }
    %>