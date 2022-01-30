--se crea tabla de baja_solicitud
CREATE TABLE baja_solicitud (
	cve_baja_solicitud SERIAL PRIMARY KEY,
	cve_alumno INTEGER,
	cve_periodo INTEGER,
	cve_tipo_baja INTEGER,
	cve_causa_baja INTEGER,
	motivo CHARACTER VARYING (350),
	comentario CHARACTER VARYING (350),
	asistio_clase DATE,
	fecha_alta TIMESTAMP,
	CONSTRAINT fk_cve_alumno FOREIGN KEY (cve_alumno) REFERENCES alumno(cve_alumno),
	CONSTRAINT fk_cve_periodo FOREIGN KEY (cve_periodo) REFERENCES periodo(cve_periodo),
	CONSTRAINT fk_cve_tipo_baja FOREIGN KEY (cve_tipo_baja) REFERENCES tipo_baja(cve_tipo_baja),
	CONSTRAINT fk_cve_causa_baja FOREIGN KEY (cve_causa_baja) REFERENCES causa_baja(cve_causa_baja)
);

--creamos tabla situacion_baja
CREATE TABLE situacion_baja (
	cve_situacion_baja serial PRIMARY KEY,
	descripcion CHARACTER VARYING(100), 
	activo BOOLEAN
);
--se crea tabla de baja_estatus
CREATE TABLE baja_estatus(
	cve_baja_estatus SERIAL PRIMARY KEY,
	cve_baja_solicitud INTEGER,
	cve_persona INTEGER,
	cve_situacion_baja INTEGER,
	comentario CHARACTER VARYING(350),
	fecha_alta TIMESTAMP,
	activo boolean,
	CONSTRAINT fk_cve_baja_solicitud FOREIGN KEY (cve_baja_solicitud) REFERENCES baja_solicitud(cve_baja_solicitud),
	CONSTRAINT fk_cve_persona FOREIGN KEY (cve_persona) REFERENCES persona (cve_persona),
	CONSTRAINT fk_cve_situacion_baja FOREIGN KEY (cve_situacion_baja) REFERENCES situacion_baja(cve_situacion_baja)
);


-- se insertan las situacion de la baja para la tabla baja_estatus
INSERT INTO situacion_baja (descripcion, activo)
VALUES ('Aceptado por profesor', 'True'),
		('Rechazado por profesor', 'True'),
		('Aceptado por director', 'True'),
		('Rechazado por director', 'True'),
		('Aceptado por escolares', 'True'),
		('Enviada', 'True'), 
	    ('Rechazado por escolares', 'True'),
		('Cancelada', 'True'),
		('Desecha por escolares','True');
		

--creación del modulo de solicitudes de baja en módulo de tutorias
--Se da de alta el módulo solicitudes de baja en la tabla módulo 
INSERT INTO modulo (cve_subproceso, nombre, descripcion, plantilla, activo, cve_modulo_padre)
VALUES (8, 'Solicitudes de baja', null, 'tutorias/solicitudesBaja.jsp', 'True', 192);
--se da de alta el rol del modulo en modulo_rol
INSERT INTO modulo_rol (cve_modulo, cve_rol, cve_accion, activo)
VALUES (245, 2, 8, 'True');
--se da de alta el submodulo y se cambia el orden de los consecutivos
--SELECT * FROM submodulo where cve_modulo_padre = 192 order by consecutivo
--inserto cve_submodulo_hijo 245 (solicitudes de baja) con el consecutivo 7 y modulo_padre 192 (módulo de tutorías)
INSERT INTO submodulo (cve_modulo_padre, cve_modulo_hijo, activo, consecutivo)
VALUES (192, 245, 'True', 7);
--actualizo el cve_modulo_hijo 196 a consecutivo 6
UPDATE submodulo SET consecutivo = 6 WHERE cve_modulo_hijo = 196;
--actualizo el cve_modulo_hijo 245 a consecutivo 8
UPDATE submodulo SET consecutivo = 8 WHERE cve_modulo_hijo = 245;
--actualizo el cve_modulo_hijo 197 a consecutivo 9
UPDATE submodulo SET consecutivo = 9 WHERE cve_modulo_hijo = 197;
--actualizo el cve_modulo_hijo 199 a consecutivo 10
UPDATE submodulo SET consecutivo = 10 WHERE cve_modulo_hijo = 199;
--actualizo el cve_modulo_hijo 200 a consecutivo 8
UPDATE submodulo SET consecutivo = 11 WHERE cve_modulo_hijo = 200;

--creamos el módulo de generar baja en panel de tutorias
INSERT INTO modulo (cve_subproceso, nombre, descripcion, plantilla, activo, cve_modulo_padre)
VALUES (8, 'Generar baja', null, 'tutorias/generarBaja.jsp', 'True', 192);
--se da de alta el rol del modulo en modulo_rol
INSERT INTO modulo_rol (cve_modulo, cve_rol, cve_accion, activo)
VALUES (246, 2, 8, 'True');
--inserto cve_submodulo_hijo 246 (Generar baja) con el consecutivo 7 y modulo_padre 192 (módulo de tutorías)
INSERT INTO submodulo (cve_modulo_padre, cve_modulo_hijo, activo, consecutivo)
VALUES (192, 246, 'True', 7)

--creamos la tabla solicitud-tutoría
CREATE TABLE baja_solicitud_tutoria (
	cve_baja_solicitud_tutoria SERIAL PRIMARY KEY,
	cve_baja_solicitud INTEGER,
	cve_consulta_servicio INTEGER,
	CONSTRAINT fk_cve_baja_solicitud FOREIGN KEY (cve_baja_solicitud) REFERENCES baja_solicitud(cve_baja_solicitud),
	CONSTRAINT fk_cve_consulta_servicio FOREIGN KEY (cve_consulta_servicio) REFERENCES consulta_servicio(cve_consulta_servicio)
)

--se actualizan y crean las causas de la baja 
UPDATE causa_baja SET causa = 'Motivos personales (problemas de salud)' WHERE cve_causa_baja = 13;
UPDATE causa_baja SET causa = 'Motivos personales (problemas familiares)' WHERE cve_causa_baja = 34;
UPDATE causa_baja SET causa = 'Motivos personales (matrimonio)' WHERE cve_causa_baja = 35;
UPDATE causa_baja SET causa = 'Cambio de institución' WHERE cve_causa_baja = 8;
UPDATE causa_baja SET causa = 'Motivos personales (problemas de salud)' WHERE cve_causa_baja = 13;
UPDATE causa_baja SET activo = 'false' WHERE cve_causa_baja = 5;
UPDATE causa_baja SET activo = 'false' WHERE cve_causa_baja = 28;
UPDATE causa_baja SET causa = 'Otra: (Especificar)' WHERE cve_causa_baja = 36;
INSERT INTO causa_baja (causa, preestablecida, activo, abreviatura)
VALUES ('Defunción','true', 'true','df'),
		('Incompatibilidad de horarios', 'true','true','ih');
UPDATE causa_baja set causa='Otra (Especificar):' WHERE cve_causa_baja=36;

