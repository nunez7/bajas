 <%@page language="java" contentType="text/html; charset=utf-8" import="mx.edu.utdelacosta.*, java.util.*"%>
 <%
		HttpSession sesion = request.getSession();	
	
	if(sesion.getAttribute("usuario") == null){
		response.sendRedirect("login.jsp");		
	}
	
	Usuario usuario =  (Usuario)sesion.getAttribute("usuario");
	Datos dexter = new Datos();
	if(!usuario.getRol().equals("Administrador") && !usuario.getRol().equals("Servicios escolares")){
            response.sendRedirect("login.jsp");
        }
	
	int cveAlumno;
        int cvePersona = usuario.getCvePersona();
	try{
		cveAlumno = (Integer) sesion.getAttribute("cveAlumno");
	}catch(Exception e){
		cveAlumno = 0;
	}
	
	int cveBaja;
        int cveBajaSolicitud;
	try{
		ArrayList<CustomHashMap> bajaAl = dexter.ejecutarConsulta("SELECT MAX(cve_baja) AS cve_baja FROM baja WHERE cve_alumno = " + cveAlumno);
		cveBaja = bajaAl.get(0).getInt("cve_baja");
                ArrayList<CustomHashMap> solicitudBaja = dexter.ejecutarConsulta("SELECT bs.cve_baja_solicitud FROM baja_solicitud bs "
                            + "INNER JOIN baja_estatus be "
                            + "ON bs.cve_baja_solicitud = be.cve_baja_solicitud "
                            + "WHERE bs.cve_alumno =" +cveAlumno
                            + " AND be.cve_situacion_baja = 5 "
                            + "AND activo = 'true'");
                cveBajaSolicitud = solicitudBaja.get(0).getInt("cve_baja_solicitud");
	}catch(Exception e){
		cveBaja = 0;
                cveBajaSolicitud = 0;
	}
	
	ArrayList<CustomHashMap> usuarioActivo = dexter.ejecutarConsulta("SELECT u.cve_usuario FROM alumno a "
                + "INNER JOIN usuario u ON u.cve_persona=a.cve_persona WHERE a.cve_alumno=" + cveAlumno+" AND u.activo='False'");
        if(cveBajaSolicitud > 0 && cveAlumno > 0){
            dexter.iniciarTransaccion();
            //se desactivan los estatus de la baja 
            dexter.serializarSentencia("UPDATE baja_estatus SET activo = 'false' WHERE cve_baja_solicitud="+cveBajaSolicitud);
            //se inserta el nuevo estatus de la baja
            dexter.serializarSentencia("INSERT INTO baja_estatus (cve_baja_solicitud, cve_persona, cve_situacion_baja, comentario, fecha_alta, activo)"
                    + " VALUES("+cveBajaSolicitud+", "+cvePersona+", 9, 'Desecha por escolares', NOW(), 'True');");
            //se activa el alumno
            dexter.serializarSentencia("UPDATE alumno SET activo = 'True' WHERE cve_alumno = " + cveAlumno);
            //se activa el usuario
            if(!usuarioActivo.isEmpty()){
                    dexter.serializarSentencia("UPDATE usuario SET activo='True' WHERE cve_usuario= " + usuarioActivo.get(0).getInt("cve_usuario"));
            }
            dexter.finalizarTransaccion();
            response.sendRedirect("../../../../index.jsp?modulo=12&tab=1");
        }
	if(cveBaja > 0 && cveAlumno > 0){
		dexter.iniciarTransaccion();
		dexter.serializarSentencia("UPDATE baja SET activa='False' WHERE cve_baja = " + cveBaja);
		dexter.serializarSentencia("UPDATE alumno SET activo = 'True' WHERE cve_alumno = " + cveAlumno);
                if(!usuarioActivo.isEmpty()){
                    dexter.serializarSentencia("UPDATE usuario SET activo='True' WHERE cve_usuario= " + usuarioActivo.get(0).getInt("cve_usuario"));
                }
		dexter.finalizarTransaccion();
		response.sendRedirect("../../../../index.jsp?modulo=12&tab=1");
	}else{
		out.print("<div class=\"error\">El registro de la baja o el alumno no fue encontrado.</div>");
		out.print("<a href=\"../../../../index.jsp?modulo=12&tab=1\">Volver.</a>");
		
	}
%>