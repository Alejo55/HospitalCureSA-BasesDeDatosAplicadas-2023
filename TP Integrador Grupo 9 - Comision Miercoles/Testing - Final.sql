use CURESA
go

set nocount on
go

/********************************************************************/
/*						PRUEBAS INSERTAR PACIENTE					*/
/********************************************************************/

exec persona.InsertarPaciente 'Juan', 'Pérez', 'González', '19900515', 'DNI', 12345678, 'Masculino', 'Hombre', 'Argentina', 'juan_foto.jpg', 'juan@example.com', '(705) 896-8293', NULL, NULL, '20231015', '20231015', 'admin'	
exec persona.InsertarPaciente 'Ana', 'Gómez', 'López', '19850220', 'DNI', 98765432, 'Femenino', 'Mujer', 'Argentina', 'ana_foto.jpg', 'ana@example.com', '(762) 123-9361', NULL, NULL, '20231015', '20231015', 'admin'    
exec persona.InsertarPaciente 'Carlos', 'Fernández', 'Pérez', '19950810', 'DNI', 55512346, 'Masculino', 'Hombre', 'Argentina', 'carlos_foto.jpg', 'carlos@example.com', '(690) 831-8690', NULL, NULL, '20231015', '20231015', 'admin'	 
exec persona.InsertarPaciente 'María', 'López', 'Gutiérrez', '19801205', 'DNI', 99988871, 'Femenino', 'Mujer', 'Argentina', 'maria_foto.jpg', 'maria@example.com', '(366) 555-1957', NULL, NULL, '20231015', '20231015', 'admin'	
exec persona.InsertarPaciente 'Roberto', 'Sánchez', 'Rodríguez', '19880430', 'DNI', 45678390, 'Masculino', 'Hombre', 'Argentina', 'roberto_foto.jpg', 'roberto@example.com', '(216) 3001-9991', NULL, NULL, '20231015', '20231015', 'admin'
exec persona.InsertarPaciente 'Anibal', 'Soriano', 'Mercau', '19600415', 'DNI', 12349712, 'Masculino', 'Hombre', 'Argentina', 'anibal_foto.jpg', 'anibal@example.com', '(216) 3001-9910', NULL, NULL, '20231015', '20231015', 'admin'

select * from persona.Paciente

go

/********************************************************************/
/*						PRUEBAS MODIFICAR PACIENTE					*/
/********************************************************************/

select * from persona.Paciente where idHistoriaClinica=3
exec persona.ModificarPaciente 3, 'Carlos', 'Fernández', 'Pérez', '19950810', 'DNI', 55512346, 'Masculino', 'Hombre', 'Argentina', 'carlos_foto.jpg', 'carlos@example.com', '(690) 831-8690', '111', NULL, '20231015', '20231015', 'admin'	 --puse telAlternativo
select * from persona.Paciente where idHistoriaClinica=3

go

/********************************************************************/
/*						PRUEBAS ELIMINAR PACIENTE					*/
/********************************************************************/

exec persona.EliminarPaciente 5 --activo en 0
select * from persona.Paciente where idHistoriaClinica=5

go

/********************************************************************/
/*						PRUEBAS INSERTAR USUARIO					*/
/********************************************************************/

exec persona.InsertarUsuario 'Bokita', '20231015', 1
exec persona.InsertarUsuario 'LaSeptima', '20231015', 2
exec persona.InsertarUsuario 'ElUnicoGrande', '20231015', 3
exec persona.InsertarUsuario 'Xeneize', '20231015', 4
exec persona.InsertarUsuario 'Fernet', '20231015', 5

select * from persona.Usuario

go

/********************************************************************/
/*						PRUEBAS MODIFICAR USUARIO					*/
/********************************************************************/

exec persona.ModificarUsuario 12345678, 'Bokitaaa', '20231015', 1 --cambio contraseña
exec persona.ModificarUsuario 12345678, 'Bokitaaa', '20231015', 5 --error: Nuevo ID de Historia Clinica ya pertence a otro Usuario.
exec persona.ModificarUsuario 55512346, 'ElUnicoGrande', '20231015', 2000 --error: El nuevo ID de Historia Clinica no existe para ningun Paciente.
exec persona.ModificarUsuario 55512346, 'ElUnicoGrande', '20231015', 6 --correcta asignacion de nueva FK

select * from persona.Usuario

--ejecutar lo siguiente ya que es necesario para el ejemplo de finalizarAlianzaPrestador (vuelvo a asignar la FK q tenia al principio, y x lo tanto se recalcula PK)
exec persona.ModificarUsuario 12349712, 'ElUnicoGrande', '20231015', 3 

go

/********************************************************************/
/*						PRUEBAS ELIMINAR USUARIO					*/
/********************************************************************/

exec persona.EliminarUsuario 45678390
select * from persona.Usuario where idUsuario=45678390

go

/********************************************************************/
/*						PRUEBAS INSERTAR DOMICILIO					*/
/********************************************************************/

exec persona.InsertarDomicilio 'Avenida Rivadavia', 123, 2, 'A', '1000', 'Argentina', 'Buenos Aires', 'Haedo', 1
exec persona.InsertarDomicilio 'San Martín', 456, NULL, NULL, '2000', 'Argentina', 'Santa Fe', 'Rosario', 2
exec persona.insertarDomicilio 'Belgrano', 789, NULL, NULL, '3000', 'Argentina', 'Córdoba', 'Villa Carlos Paz', 3
exec persona.insertarDomicilio 'Sarmiento', 101, 3, 'C', '4000', 'Argentina', 'Mendoza', 'Godoy Cruz', 4
exec persona.insertarDomicilio 'Independencia', 555, NULL, NULL, '5000', 'Argentina', 'San Juan', 'Caucete', 5

select * from persona.Domicilio

go

/********************************************************************/
/*						PRUEBAS MODIFICAR DOMICILIO					*/
/********************************************************************/

exec persona.ModificarDomicilio 3, 'Belgrano', 789, 5, 'A', '3000', 'Argentina', 'Córdoba', 'Villa Carlos Paz', 3 --le modifico piso y depto
select * from persona.Domicilio where idDomicilio=3

go

/********************************************************************/
/*						PRUEBAS ELIMINAR DOMICILIO					*/
/********************************************************************/

exec persona.EliminarDomicilio 5
select * from persona.Domicilio where idDomicilio=5

go

/********************************************************************/
/*						PRUEBAS INSERTAR PRESTADOR					*/
/********************************************************************/

exec prestacion.insertarPrestador 'Galeno', 'Galeno 220'
exec prestacion.insertarPrestador 'Galeno', 'Galeno 330'
exec prestacion.InsertarPrestador 'Avalian', 'Integral 200'
exec prestacion.InsertarPrestador 'Avalian', 'Integral 204'

select * from prestacion.Prestador

go

/********************************************************************/
/*						PRUEBAS MODIFICAR PRESTADOR					*/
/********************************************************************/

exec prestacion.ModificarPrestador 2, 'Galeno', 'Galeno 440' --cambio plan
select * from prestacion.Prestador where idPrestador=2

go

/********************************************************************/
/*						PRUEBAS ELIMINAR PRESTADOR					*/
/********************************************************************/

exec prestacion.EliminarPrestador 4
select * from prestacion.Prestador where idPrestador=4

go

/********************************************************************/
/*						PRUEBAS INSERTAR COBERTURA					*/
/********************************************************************/

exec prestacion.insertarCobertura 'credencial1.jpg', 123456, '20231015', 1, 1
exec prestacion.insertarCobertura 'credencial2.jpg', 789012, '20231015', 2, 2
exec prestacion.insertarCobertura 'credencial3.jpg', 345678, '20231015', 3, 3
exec prestacion.insertarCobertura 'credencial4.jpg', 901234, '20231015', 4, 1
exec prestacion.insertarCobertura 'credencial5.jpg', 567890, '20231015', 5, 2

select * from prestacion.Cobertura

go

/********************************************************************/
/*						PRUEBAS MODIFICAR COBERTURA					*/
/********************************************************************/

exec prestacion.ModificarCobertura 4, 'credencial4.jpg', 901234, '20231015', 4, 3 --cambio el prestador
select * from prestacion.Cobertura where idCobertura=4

go

/********************************************************************/
/*						PRUEBAS ELIMINAR COBERTURA					*/
/********************************************************************/

exec prestacion.EliminarCobertura 5
select * from prestacion.Cobertura where idCobertura=5

go

/********************************************************************/
/*						PRUEBAS INSERTAR ESTUDIO					*/
/********************************************************************/

exec examen.insertarEstudio	'20231015', 'Radiología', 'Radiografía de tórax', 0, 80, 120.00, 'resultado1.pdf', 'imagen1.jpg', 'Galeno', 'Galeno 220'
exec examen.insertarEstudio	'20231016', 'Laboratorio', 'Análisis de sangre', 1, 75, 50.00, 'resultado2.pdf', 'imagen2.jpg', 'Galeno', 'Galeno 220'
exec examen.insertarEstudio	'20231017', 'Radiología', 'Tomografía computarizada', 1, 70, 200.00, 'resultado3.pdf', 'imagen3.jpg', 'Galeno', 'Galeno 440'
exec examen.insertarEstudio	'20231018', 'Cardiología', 'Electrocardiograma', 0, 85, 75.00, 'resultado4.pdf', 'imagen4.jpg', 'Avalian', 'Integral 200'
exec examen.insertarEstudio	'20231019', 'Laboratorio', 'Examen de orina', 1, 90, 35.00, 'resultado5.pdf', 'imagen5.jpg', 'Avalian', 'Integral 205' --error: No existe coincidencia para el nombre y plan de prestador ingresados. (no existe Integral 205)
exec examen.insertarEstudio	'20231019', 'Laboratorio', 'Examen de orina', 1, 90, 35.00, 'resultado5.pdf', 'imagen5.jpg', 'Avalian', 'Integral 204' 

select * from examen.Estudio

go

/********************************************************************/
/*						PRUEBAS MODIFICAR ESTUDIO					*/
/********************************************************************/

exec examen.ModificarEstudio 1, '20231015', 'Radiología', 'Radiografía de tórax', 0, 80, 135.00, 'resultado1.pdf', 'imagen1.jpg', null, 'Galeno', 'Galeno 220' --aumento importe
exec examen.ModificarEstudio 1, '20231015', 'Radiología', 'Radiografía de tórax', 0, 80, 135.00, 'resultado1.pdf', 'imagen1.jpg', 1, 'Galeno', 'Galeno 220' --correcta vinculacion estudio y paciente
exec examen.ModificarEstudio 2, '20231016', 'Laboratorio', 'Análisis de sangre', 1, 75, 50.00, 'resultado2.pdf', 'imagen2.jpg', 2, 'Galeno', 'Galeno 220' --incorrecta vinculacion estudio y paciente
exec examen.ModificarEstudio 2, '20231016', 'Laboratorio', 'Análisis de sangre', 1, 75, 50.00, 'resultado2.pdf', 'imagen2.jpg', null, 'Galeno', 'Galeno 440' --cambio plan del estudio
exec examen.ModificarEstudio 3, '20231016', 'Laboratorio', 'Análisis de sangre', 1, 75, 50.00, 'resultado2.pdf', 'imagen2.jpg', 8, 'Galeno', 'Galeno 440' --nombre y plan del prestador asociado al estudio no se corresponden con el del paciente


select * from examen.Estudio

go

/********************************************************************/
/*						PRUEBAS ELIMINAR ESTUDIO					*/
/********************************************************************/

exec examen.EliminarEstudio 5
select * from examen.Estudio where idEstudio=5

go

/********************************************************************/
/*					PRUEBAS INSERTAR TIPO TURNO						*/
/********************************************************************/

exec turno.insertarTipoTurno 'Rafa' --probamos constraint check
exec turno.insertarTipoTurno 'Presencial'
exec turno.insertarTipoTurno 'Virtual'

select * from turno.TipoTurno

go

/********************************************************************/
/*					PRUEBAS MODIFICAR TIPO TURNO					*/
/********************************************************************/

exec turno.ModificarTipoTurno 1, 'Rafa' --prueba caso invalido
exec turno.ModificarTipoTurno 2, 'Presencial' --luego deberia borrarse

select * from turno.TipoTurno

go

/********************************************************************/
/*					PRUEBAS ELIMINAR TIPO TURNO						*/
/********************************************************************/

exec turno.EliminarTipoTurno 2
select * from turno.TipoTurno

go

/********************************************************************/
/*					PRUEBAS INSERTAR ESTADO TURNO					*/
/********************************************************************/

exec turno.insertarEstadoTurno 'Apus' --pongo a prueba constraint check
exec turno.insertarEstadoTurno 'Disponible'
exec turno.insertarEstadoTurno 'Pendiente'
exec turno.insertarEstadoTurno 'Atendido'
exec turno.insertarEstadoTurno 'Ausente'
exec turno.insertarEstadoTurno 'Cancelado'

select * from turno.EstadoTurno

go

/********************************************************************/
/*					PRUEBAS MODIFICAR ESTADO TURNO					*/
/********************************************************************/

exec turno.ModificarEstadoTurno 5, 'Marge' --prueba caso invalido
exec turno.ModificarEstadoTurno 5, 'Disponible' --luego borrar

select * from turno.EstadoTurno

go

/********************************************************************/
/*					PRUEBAS ELIMINAR ESTADO TURNO					*/
/********************************************************************/

exec turno.EliminarEstadoTurno 5
select * from turno.EstadoTurno

go

/********************************************************************/
/*					PRUEBAS INSERTAR ESPECIALIDAD					*/
/********************************************************************/

exec especialista.InsertarEspecialidad 'Radiologia'
exec especialista.InsertarEspecialidad 'Cardiologia'
exec especialista.InsertarEspecialidad 'Endocrinologia'
exec especialista.InsertarEspecialidad 'Ginecologia'
exec especialista.InsertarEspecialidad 'Kinesiologia'

select * from especialista.Especialidad

go

/********************************************************************/
/*					PRUEBAS MODIFICAR ESPECIALIDAD					*/
/********************************************************************/

exec especialista.ModificarEspecialidad 4, 'Urologia' --cambio nombre
select * from especialista.Especialidad where idEspecialidad=4

go

/********************************************************************/
/*					PRUEBAS ELIMINAR ESPECIALIDAD					*/
/********************************************************************/

exec especialista.EliminarEspecialidad 5
select * from especialista.Especialidad where idEspecialidad=5

go

/********************************************************************/
/*						PRUEBAS INSERTAR MEDICO						*/
/********************************************************************/

exec especialista.insertarMedico 'María', 'González', 12345, 1
exec especialista.insertarMedico 'Juan', 'Pérez', 67890, 2
exec especialista.insertarMedico 'Ana', 'López', 54321, 3
exec especialista.insertarMedico 'Carlos', 'Martínez', 98765, 4
exec especialista.insertarMedico 'Sofía', 'Rodríguez', 24680, 5
exec especialista.insertarMedico 'Luis', 'Fernández', 13579, 1

select * from especialista.Medico

go

/********************************************************************/
/*						PRUEBAS MODIFICAR MEDICO					*/
/********************************************************************/

exec especialista.ModificarMedico 6, 'Luis', 'Fernández', 13579, 3 --cambio su especialidad
select * from especialista.medico where idMedico=6

go

/********************************************************************/
/*						PRUEBAS ELIMINAR MEDICO						*/
/********************************************************************/

exec especialista.EliminarMedico 5
select * from especialista.Medico where idMedico=5

go

/********************************************************************/
/*					PRUEBAS INSERTAR SEDE ATENCION					*/
/********************************************************************/

exec sede.InsertarSedeAtencion 'Sede Central', 'Calle Principal 123'
exec sede.InsertarSedeAtencion 'Sede Norte', 'Avenida Norte 456'
exec sede.InsertarSedeAtencion 'Sede Sur', 'Avenida Sur 789'

select * from sede.SedeAtencion

go

/********************************************************************/
/*					PRUEBAS MODIFICAR SEDE ATENCION					*/
/********************************************************************/

exec sede.ModificarSedeAtencion 2, 'Sede Norte', 'Avenida Norte 159' --cambio direccion
select * from sede.SedeAtencion where idSede=2

go

/********************************************************************/
/*					PRUEBAS ELIMINAR SEDE ATENCION					*/
/********************************************************************/

exec sede.EliminarSedeAtencion 3
select * from sede.SedeAtencion where idSede=3

go

/********************************************************************/
/*					PRUEBAS INSERTAR DIAS X SEDE					*/
/********************************************************************/

exec sede.InsertarDiasXSede 1, 1, 'Lunes', '08:00:00', '17:30:00'
exec sede.InsertarDiasXSede 1, 1, 'Miercoles', '08:00:00', '17:30:00'
exec sede.InsertarDiasXSede 1, 2, 'Martes', '10:00:00', '15:00:00'
exec sede.InsertarDiasXSede 1, 3, 'Viernes', '16:00:00', '23:00:00'
exec sede.InsertarDiasXSede 2, 4, 'Martes', '08:00:00', '17:30:00'
exec sede.InsertarDiasXSede 2, 4, 'Jueves', '08:00:00', '17:30:00'
exec sede.InsertarDiasXSede 2, 6, 'Sabado', '11:30:00', '22:00:00'

select * from sede.DiasxSede

go

/********************************************************************/
/*					PRUEBAS MODIFICAR DIAS X SEDE					*/
/********************************************************************/

exec sede.ModificarDiasxSede 1, 1, 'Lunes', '08:00:00', '16:00:00' --nueva hora fin
select * from sede.DiasxSede where idSede=1 and idMedico=1 and dia = 'Lunes'

go

/********************************************************************/
/*					PRUEBAS ELIMINAR DIAS X SEDE					*/
/********************************************************************/

exec sede.EliminarDiasxSede 2, 4, 'Jueves'
select * from sede.DiasxSede where idSede=2 and idMedico=4 and dia='Jueves'

go

/********************************************************************/
/*				PRUEBAS INSERTAR RESERVA TURNO MEDICO				*/
/********************************************************************/

exec turno.InsertarReservaTurnoMedico '20231018', '10:00:00', 1, 1, 'Lunes', 1 --error: no coincide fecha con dia semana
exec turno.InsertarReservaTurnoMedico '20231016', '20:00:00', 1, 1, 'Lunes', 1 --error: horario no posible para dicha combinacion
exec turno.InsertarReservaTurnoMedico '20231019', '10:00:00', 1, 1, 'Jueves', 1 --error: dia y fecha coincidentes, pero no con el dia de atencion del medico
exec turno.InsertarReservaTurnoMedico '20231016', '15:00:00', 1, 1, 'Lunes', 1 
exec turno.InsertarReservaTurnoMedico '20231020', '19:00:00', 3, 1, 'Viernes', 1 
exec turno.InsertarReservaTurnoMedico '20231017', '09:00:00', 4, 2, 'Martes', 1 
exec turno.InsertarReservaTurnoMedico '20231021', '15:00:00', 6, 2, 'Sabado', 1

go

/********************************************************************/
/*				PRUEBAS MODIFICAR RESERVA TURNO MEDICO				*/
/********************************************************************/

exec turno.ModificarReservaTurnoMedico 1, '20231016', '15:00:00', 1, 1, 'Lunes', 2, 1, 1 --toma el turno el paciente 1 y el estado del turno pasa a ser 2(Pendiente) 
exec turno.ModificarReservaTurnoMedico 2, '20231020', '19:00:00', 3, 1, 'Viernes', 2, 1, 4 --toma el turno el paciente 4 y el estado del turno pasa a ser 2(Pendiente) 
exec turno.ModificarReservaTurnoMedico 3, '20231017', '09:00:00', 4, 2, 'Martes', 2, 1, 3 --toma el turno el paciente 3 y el estado del turno pasa a ser 2(Pendiente) 
exec turno.ModificarReservaTurnoMedico 1, '20231016', '15:00:00', 1, 1, 'Lunes', 3, 1, 1 -- el paciente 1 es atendido y el estado del turno pasa a ser 3(Atendido) 

select * from turno.ReservaTurnoMedico

go

/********************************************************************/
/*				PRUEBAS ELIMINAR RESERVA TURNO MEDICO				*/
/********************************************************************/

exec turno.EliminarReservaTurnoMedico 4
select * from turno.ReservaTurnoMedico where idTurno=4

go

/********************************************************************/
/*				PRUEBAS FINALIZAR ALIANZA PRESTADOR					*/
/********************************************************************/

--Vamos a finalizar alianza con el prestador cuyo id es 3
--X como fueron ingresados los datos, los pacientes 3 y 4 deberian verse afectados

--Vemos el prestador 3
select * from prestacion.Prestador where idPrestador=3

--Vemos los estudios asociados al prestador
select * from examen.Estudio where idPrestador=3

--Vemos los pacientes vinculados a la prestadora
select paciente.idHistoriaClinica, paciente.activo as ActivoPaciente
		, usuario.activo as ActivoUsuario, domicilio.activo as ActivoDomicilio
		, cobertura.activo as ActivoCobertura
from persona.Paciente paciente
inner join persona.Usuario usuario on paciente.idHistoriaClinica=usuario.idHistoriaClinica
inner join persona.Domicilio domicilio on paciente.idHistoriaClinica=domicilio.idHistoriaClinica
inner join prestacion.Cobertura cobertura on paciente.idHistoriaClinica=cobertura.idHistoriaClinica
where cobertura.idPrestador=3

--Vemos las reservas de los pacientes vinculados a esa prestadora
select * from turno.ReservaTurnoMedico where idHistoriaClinica=3 or idHistoriaClinica=4

--EJECUCION DEL SP
exec prestacion.FinalizarAlianzaPrestador 3

--Volver a ejecutar las consultas anteriores y comparar con lo obtenido previamente

/********************************************************************/
/*				PRUEBAS IMPORTACION DE DATOS						*/
/********************************************************************/

-- Modificar ruta del PATH donde se alojan los archivos a importar
GO
EXEC sp_set_session_context '@PATH', 'C:\Importar\';

/********************************************************************/
/*				IMPORTAR ESPECIALIDADES Y MEDICOS					*/
/********************************************************************/
GO
EXEC especialista.ProcesarMedicos
SELECT * FROM especialista.Especialidad
SELECT * FROM especialista.Medico

/********************************************************************/
/*				IMPORTAR SEDES DE ATENCION							*/
/********************************************************************/
GO
EXEC sede.ProcesarSedeAtencion
SELECT * FROM sede.SedeAtencion

/********************************************************************/
/*					IMPORTAR PRESTADORES							*/
/********************************************************************/
GO
EXEC prestacion.ProcesarPrestadores
SELECT * FROM prestacion.Prestador

/********************************************************************/
/*				IMPORTAR PACIENTES Y DOMICILIOS						*/
/********************************************************************/
GO
EXEC persona.ProcesarPacientes
SELECT * FROM persona.Paciente
SELECT * FROM persona.Domicilio

/********************************************************************/
/*					IMPORTAR ESTUDIOS								*/
/********************************************************************/
GO
EXEC examen.ProcesarEstudios
SELECT * FROM examen.Estudio

/********************************************************************/
/*				OBTENER TURNOS MEDICOS								*/
/********************************************************************/
GO
--Turno Medico Valido (Prestador Valido y Rango Fecha Valido)
EXEC turno.getTurnosMedicos 
	@nombrePrestador = 'Galeno',
	@fechaDesde = '2023-10-01',
	@fechaHasta = '2023-10-31'

--Turno Medico Invalido (Prestador Invalido)
EXEC turno.getTurnosMedicos 
	@nombrePrestador = 'Union Personal',
	@fechaDesde = '2023-10-01',
	@fechaHasta = '2023-10-31'
--Turno Medico Invalido (Rango de Fecha Invalido)
EXEC turno.getTurnosMedicos 
	@nombrePrestador = 'Galeno',
	@fechaDesde = '2023-10-20',
	@fechaHasta = '2023-10-31'
