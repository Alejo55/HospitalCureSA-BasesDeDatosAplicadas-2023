/*
BASES DE DATOS APLICADAS

-FECHA DE ENTREGA: 15-11-2023

-GRUPO: 9

-INTEGRANTES:
Agasi, Alejo		DNI 43034043
Giasone, Santiago	DNI 41894276
Violi, Stefania		DNI 40784696
*/


/*
Se presenta un modelo de base de datos a implementar por el hospital Cure SA, para la reserva
de turnos médicos y la visualización de estudios clínicos realizados (ver archivo Clinica Cure
SA.png). El modelo es el esquema inicial, en caso de ser necesario agregue las relaciones/entidades que
sean convenientes.

Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar un
archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es
entregado). Incluya comentarios para indicar qué hace cada módulo de código.

Genere store procedures para manejar la inserción, modificado, borrado (si corresponde,
también debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.

Los nombres de los store procedures NO deben comenzar con “SP”. Genere esquemas para
organizar de forma lógica los componentes del sistema y aplique esto en la creación de objetos.
NO use el esquema “dbo”.
*/



/********************************************************************/
/*					CREACION DE LA BASE DE DATOS					*/
/********************************************************************/

--Si la Base de Datos ya existe, la borramos y volvemos a crear y asi evitar errores al ejecutar script
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'CURESA')
BEGIN
	use master --esto xq si estuviese parado en CURESA, tendria un error
    drop database CURESA
END

go 
create database CURESA

go
use CURESA

go

/********************************************************************/
/*						CREACION DE LOS ESQUEMAS					*/
/********************************************************************/

DROP SCHEMA IF EXISTS persona
go
create schema persona
go
DROP SCHEMA IF EXISTS prestacion
go
create schema prestacion
go
DROP SCHEMA IF EXISTS examen
go
create schema examen
go
DROP SCHEMA IF EXISTS turno
go
create schema turno
go
DROP SCHEMA IF EXISTS especialista
go
create schema especialista
go
DROP SCHEMA IF EXISTS sede
go
create schema sede

go

/********************************************************************/
/*						CREACION DE LAS TABLAS						*/
/********************************************************************/

DROP TABLE IF EXISTS CURESA.persona.Paciente
go

create table persona.Paciente (
idHistoriaClinica int identity(1,1) primary key,
nombre varchar(50) not null,
apellido varchar(50) not null,
apellidoMaterno varchar(50),
fechaNacimiento date,
tipoDocumento char(3) not null,
nroDocumento int not null unique,
sexoBiologico char(9), 
genero char(6), 
nacionalidad varchar(20), 
fotodeperfil varchar(255), 
mail varchar(40), 
telefonoFijo varchar(14),
telefonoAlternativo varchar(14), 
telefonoLaboral varchar(14), 
fechaRegistro date, 
fechaActualizacion date, 
usuarioActualizacion varchar(20),
activo bit
--el campo activo es para saber si está activo o no ese paciente, no estar activo es un borrado logico del paciente
--en ese caso estará en cero, de lo contrario en 1. Por default se crea en 1, paciente activo
)
go

DROP TABLE IF EXISTS CURESA.persona.Usuario
go

create table persona.Usuario (
idUsuario int primary key,
contraseña varchar(20) not null,
fechaCreacion date not null,
idHistoriaClinica int unique,
activo bit,
constraint Fk_HistoriaClinica foreign key(idHistoriaClinica) references persona.Paciente(idHistoriaClinica)
)
go

DROP TABLE IF EXISTS CURESA.persona.Domicilio
go

create table persona.Domicilio (
idDomicilio int identity(1,1) primary key, 
calle varchar(50), 
numero int, 
piso int, 
departamento char(3), 
codigoPostal char(4), 
pais varchar(20), 
provincia varchar(25), 
localidad varchar(50),
idHistoriaClinica int unique,
activo bit,
constraint Fk_HistoriaClinicaDomicilio foreign key(idHistoriaClinica) references persona.Paciente(idHistoriaClinica)
)
go

DROP TABLE IF EXISTS CURESA.prestacion.Prestador
go

create table prestacion.Prestador (
idPrestador int identity(1,1) primary key, 
nombrePrestador varchar(20), 
planPrestador varchar(50),
activo bit --borrado logico porque pueden reestablecerse y ademas borrado fisico generaria problemas porque hay entidades q la referencian
constraint Uq_NombrePrestadorPlanPrestador UNIQUE (nombrePrestador, planPrestador)
)
go

DROP TABLE IF EXISTS CURESA.prestacion.Cobertura
go

create table prestacion.Cobertura(
idCobertura int identity(1,1) primary key,
imagenCredencial varchar(255), 
nroSocio int, 
fechaRegistro date, 
idHistoriaClinica int unique,
idPrestador int,
activo bit,
constraint Fk_HistoriaClinicaCobertura foreign key(idHistoriaClinica) references persona.Paciente(idHistoriaClinica),
constraint Fk_PrestadorCobertura foreign key(idPrestador) references prestacion.Prestador(idPrestador)
)
go

DROP TABLE IF EXISTS CURESA.examen.Estudio
go

create table examen.Estudio (
idEstudio int identity(1,1) primary key,
fecha date,
areaEstudio varchar(20),
nombreEstudio varchar(100),
requiere_autorizacion bit,
porcentaje_cobertura int,
importe decimal(8,2),
documentoResultado varchar(255), 
imagenResultado varchar(255),
idHistoriaClinica int,
idPrestador int, 
constraint Fk_HistoriaClinicaEstudio foreign key(idHistoriaClinica) references persona.Paciente(idHistoriaClinica),
constraint Fk_PrestadorEstudio foreign key(idPrestador) references prestacion.Prestador(idPrestador)
)
go

DROP TABLE IF EXISTS CURESA.turno.TipoTurno
go

create table turno.TipoTurno (
idTipoTurno int primary key, 
nombreTipoTurno char(10),
constraint CK_nombreTipoTurno check (nombreTipoTurno in ('Presencial', 'Virtual'))
)
go

DROP TABLE IF EXISTS CURESA.turno.EstadoTurno
go

create table turno.EstadoTurno (
IdEstado int primary key, 
nombreEstado char(10),
constraint CK_nombreEstado check (nombreEstado in ('Disponible', 'Pendiente', 'Atendido', 'Ausente', 'Cancelado'))
)
go

DROP TABLE IF EXISTS CURESA.especialista.Especialidad
go

create table especialista.Especialidad (
idEspecialidad int identity(1,1) primary key, 
nombreEspecialidad varchar(20) unique,
activo bit
)
go

DROP TABLE IF EXISTS CURESA.especialista.Medico
go

create table especialista.Medico (
idMedico int identity(1,1) primary key, 
nombre varchar(50), 
apellido varchar(50), 
nroMatricula int unique, 
idEspecialidad int,
activo bit,
constraint Fk_MedicoEspecialidad foreign key(idEspecialidad) references especialista.Especialidad(idEspecialidad)
)
go

DROP TABLE IF EXISTS CURESA.sede.SedeAtencion
go

create table sede.SedeAtencion (
idSede int identity(1,1) primary key, 
nombreSede varchar(20) unique, 
direccionSede varchar(50)
)
go

DROP TABLE IF EXISTS CURESA.sede.DiasxSede
go

create table sede.DiasxSede ( --Debil de Sede y Medico, con clave parcial dia
idSede int, 
idMedico int, 
dia char(9), 
horaInicio time,
horaFin time,
constraint Pk_DiasxSede primary key (idSede, idMedico, dia),
constraint Fk_Sede foreign key(idSede) references sede.SedeAtencion(idSede),
constraint Fk_MedicoSede foreign key(idMedico) references especialista.Medico(idMedico)
)
go

DROP TABLE IF EXISTS CURESA.turno.ReservaTurnoMedico
go

create table turno.ReservaTurnoMedico ( --Sacamos especialidad del medico ya que no es necesario, puede obtenerse mediante consultas
idTurno int identity(1,1) primary key, 
fecha date, 
hora time, 
idMedico int,
idSede int,
diaMedicoSede char(9), --lo agrego para referenciar correctamente a DiasxSede
idEstadoTurno int, 
idTipoTurno int, 
idHistoriaClinica int,
constraint Fk_SedeMedicoReserva foreign key (idSede, idMedico, diaMedicoSede) references sede.DiasxSede (idSede, idMedico, dia),
constraint Fk_TipoTurnoReserva foreign key(idTipoTurno) references turno.TipoTurno(idTipoTurno),
constraint Fk_EstadoTurnoReserva foreign key(idEstadoTurno) references turno.EstadoTurno(idEstado),
constraint Fk_HistoriaClinicaReserva foreign key (idHistoriaClinica) references persona.Paciente(idHistoriaClinica)
)
go


/********************************************************************/
/*				CREACION DE LOS STORED PROCEDURES					*/
/********************************************************************/


/******** Stored Procedure Insertar Paciente ********/

drop procedure if exists persona.InsertarPaciente
go

CREATE PROCEDURE persona.InsertarPaciente --Asumimos que al insertar un Paciente, su Prestadora es aliada, sino no lo ingresaria. 
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @apellidoMaterno VARCHAR(50),
    @fechaNacimiento DATE,
    @tipoDocumento CHAR(3),
    @nroDocumento INT,
    @sexoBiologico CHAR(9),
    @genero CHAR(6),
    @nacionalidad VARCHAR(20),
    @fotodeperfil VARCHAR(255),
    @mail VARCHAR(40),
    @telefonoFijo VARCHAR(14),
    @telefonoAlternativo VARCHAR(14),
    @telefonoLaboral VARCHAR(14),
    @fechaRegistro DATE,
    @fechaActualizacion DATE,
    @usuarioActualizacion VARCHAR(20)
AS
BEGIN
    INSERT INTO persona.Paciente (
        nombre, apellido, apellidoMaterno, fechaNacimiento, tipoDocumento, nroDocumento,
        sexoBiologico, genero, nacionalidad, fotodeperfil, mail, telefonoFijo, telefonoAlternativo,
        telefonoLaboral, fechaRegistro, fechaActualizacion, usuarioActualizacion, activo
    )
    VALUES (
        @nombre, @apellido, @apellidoMaterno, @fechaNacimiento, @tipoDocumento, @nroDocumento,
        @sexoBiologico, @genero, @nacionalidad, @fotodeperfil, @mail, @telefonoFijo, @telefonoAlternativo,
        @telefonoLaboral, @fechaRegistro, @fechaActualizacion, @usuarioActualizacion, 1
    ); -- 1 para indicar que el paciente está activo por defecto
END;


go


/******** Stored Procedure Modificar Paciente ********/

drop procedure if exists persona.ModificarPaciente
go

CREATE PROCEDURE persona.ModificarPaciente
    @idHistoriaClinica INT,
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @apellidoMaterno VARCHAR(50),
    @fechaNacimiento DATE,
    @tipoDocumento CHAR(3),
    @nroDocumento INT,
    @sexoBiologico CHAR(9),
    @genero CHAR(6),
    @nacionalidad VARCHAR(20),
    @fotodeperfil varchar(255),
    @mail VARCHAR(40),
    @telefonoFijo VARCHAR(14),
    @telefonoAlternativo VARCHAR(14),
    @telefonoLaboral VARCHAR(14),
	@fechaRegistro DATE,
    @fechaActualizacion DATE,
    @usuarioActualizacion VARCHAR(20)
AS
BEGIN
    UPDATE persona.Paciente
    SET nombre = @nombre, apellido = @apellido, apellidoMaterno = @apellidoMaterno, fechaNacimiento = @fechaNacimiento,
        tipoDocumento = @tipoDocumento, nroDocumento = @nroDocumento, sexoBiologico = @sexoBiologico,
        genero = @genero, nacionalidad = @nacionalidad, fotodeperfil = @fotodeperfil, mail = @mail,
        telefonoFijo = @telefonoFijo, telefonoAlternativo = @telefonoAlternativo, telefonoLaboral = @telefonoLaboral,
		fechaRegistro = @fechaRegistro, fechaActualizacion = @fechaActualizacion, usuarioActualizacion = @usuarioActualizacion
    WHERE idHistoriaClinica = @idHistoriaClinica
END


go


/******** Stored Procedure Eliminar Paciente ********/

drop procedure if exists persona.EliminarPaciente
go

-- Borrado lógico de un paciente
CREATE PROCEDURE persona.EliminarPaciente --Por ejemplo cuando se rompe relacion con su Prestadora.
   @idHistoriaClinica INT
AS
BEGIN
   UPDATE persona.Paciente
   SET activo = 0
   WHERE idHistoriaClinica = @idHistoriaClinica;
END;


go


/******** Stored Procedure Insertar Usuario ********/

drop procedure if exists persona.InsertarUsuario
go

--El usuario web se define utilizando el DNI.
CREATE PROCEDURE persona.InsertarUsuario
    @contraseña VARCHAR(20),
    @fechaCreacion DATE,
    @idHistoriaClinica INT
AS
	declare @idUsuario INT
BEGIN
	set @idUsuario = (select nroDocumento from persona.Paciente where idHistoriaClinica=@idHistoriaClinica)
    INSERT INTO persona.Usuario (idUsuario, contraseña, fechaCreacion, idHistoriaClinica, activo)
    VALUES (@idUsuario, @contraseña, @fechaCreacion, @idHistoriaClinica, 1);
END;


go


/******** Stored Procedure Modificar Usuario ********/

drop procedure if exists persona.ModificarUsuario
go

CREATE PROCEDURE persona.ModificarUsuario
    @idUsuario INT,
    @nuevaContraseña VARCHAR(20),
    @nuevaFechaCreacion DATE,
	@nuevoIdHistoriaClinica INT
AS
	declare @idHistoriaClinicaAnterior int
BEGIN
	--debo chequear si cambió el id de historia clinica en especial ya que la PK depende de ello
	select @idHistoriaClinicaAnterior=idHistoriaClinica from persona.Usuario where idUsuario=@idUsuario 

	--caso de que el nuevo id ya exista como FK y, el anterior sea distinto del nuevo o nulo
	IF (exists (select 1 from persona.Usuario where idHistoriaClinica=@nuevoIdHistoriaClinica))
		and ( (@idHistoriaClinicaAnterior is not null and @idHistoriaClinicaAnterior <> @nuevoIdHistoriaClinica) or (@idHistoriaClinicaAnterior is null) )
			print 'El nuevo ID de Historia Clinica ya le pertenece a otro Usuario.';
	
	--caso de que el anterior id sea nulo o distinto del nuevo, sabiendo que el nuevo no existe aun como FK
	--si bien es modificacion, voy a cambiar la PK (su valor depende del IdHistoriaClinica), por lo q no es aconsejable hacer update de esta.
	--lo correcto seria hacer un borrado fisico e insertarlo de nuevo para evitar errores, simulando asi una actualizacion.
	ELSE IF @idHistoriaClinicaAnterior is null or @idHistoriaClinicaAnterior <> @nuevoIdHistoriaClinica
		IF exists (select 1 from persona.Paciente where idHistoriaClinica=@nuevoIdHistoriaClinica) --podria pasar a su vez que el nuevo id no exista en Paciente
		begin
			DELETE FROM persona.Usuario 
			WHERE idUsuario = @idUsuario
		
			set @idUsuario = (select nroDocumento from persona.Paciente where idHistoriaClinica=@nuevoIdHistoriaClinica)

			insert into persona.Usuario (idUsuario, contraseña, fechaCreacion, idHistoriaClinica, activo)
			values (@idUsuario, @nuevaContraseña, @nuevaFechaCreacion, @nuevoIdHistoriaClinica, 1)
		end
		else
			print 'El nuevo ID de Historia Clinica no existe para ningun Paciente.';
	
	--caso de que no se modifique el id de historia clinica
	ELSE
		UPDATE persona.Usuario
		SET contraseña = @nuevaContraseña,
			fechaCreacion = @nuevaFechaCreacion
		WHERE idUsuario = @idUsuario;
END;


go


/******** Stored Procedure Eliminar Usuario ********/

drop procedure if exists persona.EliminarUsuario
go

CREATE PROCEDURE persona.EliminarUsuario
    @idUsuario INT
AS
BEGIN
    -- se realiza borrado lógico actualizando el estado a inactivo 
    UPDATE persona.Usuario
    SET Activo = 0
    WHERE idUsuario = @idUsuario;
END;


go


/******** Stored Procedure Insertar Domicilio ********/

drop procedure if exists persona.InsertarDomicilio
go

CREATE PROCEDURE persona.InsertarDomicilio
    @calle VARCHAR(50),
    @numero INT,
    @piso INT,
    @departamento CHAR(3),
    @codigoPostal CHAR(4),
    @pais VARCHAR(20),
    @provincia VARCHAR(25),
    @localidad VARCHAR(50),
    @idHistoriaClinica INT
AS
BEGIN
    INSERT INTO persona.Domicilio (calle, numero, piso, departamento, codigoPostal, pais, provincia, localidad, idHistoriaClinica, activo)
    VALUES (@calle, @numero, @piso, @departamento, @codigoPostal, @pais, @provincia, @localidad, @idHistoriaClinica, 1);
END;


go


/******** Stored Procedure Modificar Domicilio ********/

drop procedure if exists persona.ModificarDomicilio
go

CREATE PROCEDURE persona.ModificarDomicilio
    @idDomicilio INT,
    @nuevaCalle VARCHAR(50),
    @nuevoNumero INT,
    @nuevoPiso INT,
    @nuevoDepartamento CHAR(3),
    @nuevoCodigoPostal CHAR(4),
    @nuevoPais VARCHAR(20),
    @nuevaProvincia VARCHAR(25),
    @nuevaLocalidad VARCHAR(50),
	@nuevoIdHistoriaClinica INT
AS
BEGIN
    UPDATE persona.Domicilio
    SET calle = @nuevaCalle,
        numero = @nuevoNumero,
        piso = @nuevoPiso,
        departamento = @nuevoDepartamento,
        codigoPostal = @nuevoCodigoPostal,
        pais = @nuevoPais,
        provincia = @nuevaProvincia,
        localidad = @nuevaLocalidad,
		idHistoriaClinica = @nuevoIdHistoriaClinica
    WHERE idDomicilio = @idDomicilio;
END;


go


/******** Stored Procedure Eliminar Domicilio ********/

drop procedure if exists persona.EliminarDomicilio
go

CREATE PROCEDURE persona.EliminarDomicilio
    @idDomicilio INT
AS
BEGIN
    -- Realizo borrado logico
    UPDATE persona.Domicilio
	SET activo=0
    WHERE idDomicilio = @idDomicilio;
END;


go


/******** Stored Procedure Insertar Prestador ********/

drop procedure if exists prestacion.InsertarPrestador
go

CREATE PROCEDURE prestacion.InsertarPrestador
    @nombrePrestador VARCHAR(20),
    @planPrestador VARCHAR(50)
AS
BEGIN
    INSERT INTO prestacion.Prestador (nombrePrestador, planPrestador, activo)
    VALUES (@nombrePrestador, @planPrestador, 1);
END;


go


/******** Stored Procedure Modificar Prestador ********/

drop procedure if exists prestacion.ModificarPrestador
go

CREATE PROCEDURE prestacion.ModificarPrestador
    @idPrestador INT,
    @nuevoNombrePrestador VARCHAR(20),
    @nuevoPlanPrestador VARCHAR(50)
AS
BEGIN
    UPDATE prestacion.Prestador
    SET nombrePrestador = @nuevoNombrePrestador,
        planPrestador = @nuevoPlanPrestador
    WHERE idPrestador = @idPrestador;
END;


go


/******** Stored Procedure Eliminar Prestador ********/

drop procedure if exists prestacion.EliminarPrestador
go

CREATE PROCEDURE prestacion.EliminarPrestador
    @idPrestador INT
AS
BEGIN
    -- Realizo borrado logico
    UPDATE prestacion.Prestador
    SET activo=0
	WHERE idPrestador = @idPrestador;
END;


go


/******** Stored Procedure Insertar Cobertura ********/

drop procedure if exists prestacion.InsertarCobertura
go

CREATE PROCEDURE prestacion.InsertarCobertura
    @imagenCredencial varchar(255),
    @nroSocio INT,
    @fechaRegistro DATE,
    @idHistoriaClinica INT,
	@idPrestador INT
AS
BEGIN
    INSERT INTO prestacion.Cobertura (imagenCredencial, nroSocio, fechaRegistro, idHistoriaClinica, idPrestador, activo)
    VALUES (@imagenCredencial, @nroSocio, @fechaRegistro, @idHistoriaClinica, @idPrestador, 1);
END;


go


/******** Stored Procedure Modificar Cobertura ********/

drop procedure if exists prestacion.ModificarCobertura
go

CREATE PROCEDURE prestacion.ModificarCobertura
    @idCobertura INT,
    @nuevaImagenCredencial varchar(255),
    @nuevoNroSocio INT,
    @nuevaFechaRegistro DATE,
	@nuevoIdHistoriaClinica INT,
	@nuevoIdPrestador INT
AS
BEGIN
    UPDATE prestacion.Cobertura
    SET imagenCredencial = @nuevaImagenCredencial,
        nroSocio = @nuevoNroSocio,
        fechaRegistro = @nuevaFechaRegistro,
		idHistoriaClinica = @nuevoIdHistoriaClinica,
		idPrestador = @nuevoIdPrestador
    WHERE idCobertura = @idCobertura;
END;


go


/******** Stored Procedure Eliminar Cobertura ********/

drop procedure if exists prestacion.EliminarCobertura
go

CREATE PROCEDURE prestacion.EliminarCobertura
    @idCobertura INT
AS
BEGIN
    -- Realizo borrado logico
    UPDATE prestacion.Cobertura
    SET activo=0
	WHERE idCobertura = @idCobertura;
END;


go

/******** Stored Procedure Insertar Estudio ********/

drop procedure if exists examen.InsertarEstudio
go

/*Los estudios clínicos deben ser autorizados, e indicar si se cubre el costo completo del mismo o
solo un porcentaje. El sistema de Cure se comunica con el servicio de la prestadora, se le envía
el código del estudio, el dni del paciente y el plan; el sistema de la prestadora informa si está
autorizado o no y el importe a facturarle al paciente.*/

CREATE PROCEDURE examen.InsertarEstudio 
    @fecha DATE,
	@areaEstudio varchar(20),
    @nombreEstudio VARCHAR(100),
	@requiere_autorizacion bit,
	@porcentaje_cobertura int,
	@importe decimal(8,2),
    @documentoResultado VARCHAR(255),
    @imagenResultado VARCHAR(255),
	@nombrePrestador varchar(20), --nombre y plan Prestador para deducir su correspondiente id en la fk
	@planPrestador varchar(50)
AS
	declare @idPrestador int
BEGIN
	select @idPrestador=idPrestador
	from prestacion.Prestador
	where nombrePrestador=@nombrePrestador and planPrestador=@planPrestador

	if @idPrestador is null
		print 'No existe coincidencia para el nombre y plan de prestador ingresados.'
	else
		INSERT INTO examen.Estudio (fecha, areaEstudio, nombreEstudio, requiere_autorizacion, porcentaje_cobertura, 
									importe, documentoResultado, imagenResultado, idHistoriaClinica, idPrestador)
		VALUES (@fecha, @areaEstudio, @nombreEstudio, @requiere_autorizacion, @porcentaje_cobertura, 
				@importe, @documentoResultado, @imagenResultado, null, @idPrestador);
END;


go


/******** Stored Procedure Modificar Estudio ********/

drop procedure if exists examen.ModificarEstudio
go

CREATE PROCEDURE examen.ModificarEstudio
    @idEstudio INT,
    @nuevaFecha DATE,
	@nuevoAreaEstudio varchar(20),
    @nuevoNombreEstudio VARCHAR(100),
	@nuevoRequiere_autorizacion bit,
	@nuevoPorcentaje_cobertura int,
	@nuevoImporte decimal(8,2), 
    @nuevoDocumentoResultado VARCHAR(255),
    @nuevaImagenResultado VARCHAR(255),
	@nuevoIdHistoriaClinica INT,
	@nuevoNombrePrestador varchar(20),
	@nuevoPlanPrestador varchar(50)
AS
	declare @nuevoIdPrestador int
	declare @idPrestadorPaciente int
	declare @nombrePrestadorPaciente varchar(20)
	declare @planPrestadorPaciente varchar(50)
	declare @nombrePrestadorAnterior varchar(20)
	declare @planPrestadorAnterior varchar(50)
BEGIN
	if @nuevoIdHistoriaClinica is not null --si cargo un paciente, debo ver q coincidan su prestador y el del estudio
	begin
		select @idPrestadorPaciente=pr.idPrestador, @nombrePrestadorPaciente=pr.nombrePrestador, @planPrestadorPaciente=pr.planPrestador
		from persona.Paciente pa
		inner join prestacion.Cobertura c on pa.idHistoriaClinica=c.idHistoriaClinica
		inner join prestacion.Prestador pr on c.idPrestador=pr.idPrestador
		where pa.idHistoriaClinica=@nuevoIdHistoriaClinica

		if @nuevoNombrePrestador=@nombrePrestadorPaciente and @nuevoPlanPrestador=@planPrestadorPaciente
			set @nuevoIdPrestador = @idPrestadorPaciente --hago esto ya que pudo haber cambiado el nombre o plan del prestador, asi lo soluciono de una obteniendo el nuevo id
		else
		begin
			print 'El nombre y plan del prestador asociado al estudio no se corresponden con el del paciente.';	
			RETURN;
		end
	end
	else --si no se carga paciente, debo chequear si se modifico el prestador para actualizar la correspondiente FK
	begin
		select @nuevoIdPrestador=p.idPrestador, @nombrePrestadorAnterior=p.nombrePrestador, @planPrestadorAnterior=p.planPrestador
		from examen.Estudio e
		inner join prestacion.Prestador p on e.idPrestador=p.idPrestador
		where idEstudio=@idEstudio

		if @nuevoNombrePrestador <> @nombrePrestadorAnterior or @nuevoPlanPrestador <> @planPrestadorAnterior
			select @nuevoIdPrestador=idPrestador 
			from prestacion.Prestador 
			where nombrePrestador=@nuevoNombrePrestador and planPrestador=@nuevoPlanPrestador
	end

    UPDATE examen.Estudio
    SET fecha = @nuevaFecha,
		areaEstudio = @nuevoAreaEstudio,
        nombreEstudio = @nuevoNombreEstudio,
        requiere_autorizacion = @nuevoRequiere_autorizacion,
		porcentaje_cobertura = @nuevoPorcentaje_cobertura,
		importe = @nuevoImporte,
        documentoResultado = @nuevoDocumentoResultado,
        imagenResultado = @nuevaImagenResultado,
		idHistoriaClinica = @nuevoIdHistoriaClinica,
		idPrestador = @nuevoIdPrestador
    WHERE idEstudio = @idEstudio;
END;


go


/******** Stored Procedure Eliminar Estudio ********/

drop procedure if exists examen.EliminarEstudio
go

CREATE PROCEDURE examen.EliminarEstudio
    @idEstudio INT
AS
BEGIN
    -- Realiza el borrado definitivo eliminando el registro de la tabla
    DELETE FROM examen.Estudio
    WHERE idEstudio = @idEstudio;
END;


go


/******** Stored Procedure Insertar Tipo Turno ********/

drop procedure if exists turno.InsertarTipoTurno
go

CREATE PROCEDURE turno.InsertarTipoTurno
    @nombreTipoTurno CHAR(10)
AS
	declare @idTipoTurno int
BEGIN
	set @idTipoTurno = case @nombreTipoTurno when 'Presencial' then 1 else 2 end
    INSERT INTO turno.TipoTurno (idTipoTurno, nombreTipoTurno)
    VALUES (@idTipoTurno, @nombreTipoTurno);
END;


go


/******** Stored Procedure Modificar Tipo Turno ********/

drop procedure if exists turno.ModificarTipoTurno
go

CREATE PROCEDURE turno.ModificarTipoTurno
    @idTipoTurno INT,
    @nuevoNombreTipoTurno CHAR(10)
AS
BEGIN
    UPDATE turno.TipoTurno
    SET nombreTipoTurno = @nuevoNombreTipoTurno
    WHERE idTipoTurno = @idTipoTurno;
END;


go


/******** Stored Procedure Eliminar Tipo Turno ********/

drop procedure if exists turno.EliminarTipoTurno
go

CREATE PROCEDURE turno.EliminarTipoTurno
    @idTipoTurno INT
AS
BEGIN
	DELETE FROM turno.TipoTurno 
	WHERE idTipoTurno = @idTipoTurno
END;


go


/******** Stored Procedure Insertar Estado Turno ********/

drop procedure if exists turno.InsertarEstadoTurno
go

CREATE PROCEDURE turno.InsertarEstadoTurno
    @nombreEstado CHAR(10)
AS
	declare @idEstado int
BEGIN
	set @idEstado = case @nombreEstado
						when 'Disponible' then 1
						when 'Pendiente' then 2
						when 'Atendido' then 3
						when 'Ausente' then 4
						else 5
						end
    INSERT INTO turno.EstadoTurno (idEstado, nombreEstado)
    VALUES (@idEstado, @nombreEstado);
END;


go


/******** Stored Procedure Modificar Estado Turno ********/

drop procedure if exists turno.ModificarEstadoTurno
go

CREATE PROCEDURE turno.ModificarEstadoTurno
    @idEstado INT,
    @nuevoNombreEstado CHAR(10)
AS
BEGIN
	UPDATE turno.EstadoTurno
	SET nombreEstado = @nuevoNombreEstado
	WHERE IdEstado = @idEstado;
END;


go


/******** Stored Procedure Eliminar Estado Turno ********/

drop procedure if exists turno.EliminarEstadoTurno
go

CREATE PROCEDURE turno.EliminarEstadoTurno
    @idEstado INT
AS
BEGIN
    DELETE FROM turno.EstadoTurno 
	WHERE IdEstado = @idEstado
END;


go 


/******** Stored Procedure Insertar Especialidad ********/

drop procedure if exists especialista.InsertarEspecialidad
go

CREATE PROCEDURE especialista.InsertarEspecialidad
    @nombreEspecialidad VARCHAR(20)
AS
BEGIN

	INSERT INTO especialista.Especialidad (nombreEspecialidad, activo)
	VALUES (@nombreEspecialidad, 1);
END;


go


/******** Stored Procedure Modificar Especialidad ********/

drop procedure if exists especialista.ModificarEspecialidad
go

CREATE PROCEDURE especialista.ModificarEspecialidad
    @idEspecialidad INT,
    @nuevoNombreEspecialidad VARCHAR(20)
AS
BEGIN
    UPDATE especialista.Especialidad
    SET nombreEspecialidad = @nuevoNombreEspecialidad
    WHERE idEspecialidad = @idEspecialidad;
END;


go


/******** Stored Procedure Eliminar Especialidad ********/

drop procedure if exists especialista.EliminarEspecialidad
go

CREATE PROCEDURE especialista.EliminarEspecialidad
    @idEspecialidad INT
AS
BEGIN
    UPDATE especialista.Especialidad
	set activo = 0
	where idEspecialidad = @idEspecialidad
END;


go


/******** Stored Procedure Insertar Medico ********/

drop procedure if exists especialista.InsertarMedico
go

CREATE PROCEDURE especialista.InsertarMedico
    @nombre VARCHAR(50),
    @apellido VARCHAR(50),
    @nroMatricula INT,
    @idEspecialidad INT
AS
BEGIN
    INSERT INTO especialista.Medico (nombre, apellido, nroMatricula, idEspecialidad, activo)
    VALUES (@nombre, @apellido, @nroMatricula, @idEspecialidad, 1);
END;


go


/******** Stored Procedure Modificar Medico ********/

drop procedure if exists especialista.ModificarMedico
go

CREATE PROCEDURE especialista.ModificarMedico
    @idMedico INT,
    @nuevoNombre VARCHAR(50),
    @nuevoApellido VARCHAR(50),
    @nuevoNroMatricula INT,
	@nuevoIdEspecialidad int
AS
BEGIN
    UPDATE especialista.Medico
    SET nombre = @nuevoNombre,
        apellido = @nuevoApellido,
        nroMatricula = @nuevoNroMatricula,
		idEspecialidad = @nuevoIdEspecialidad
    WHERE idMedico = @idMedico;
END;


go


/******** Stored Procedure Eliminar Medico ********/

drop procedure if exists especialista.EliminarMedico
go

CREATE PROCEDURE especialista.EliminarMedico
    @idMedico INT
AS
BEGIN
    update especialista.Medico
	set activo = 0
	where idMedico = @idMedico
END;


go


/******** Stored Procedure Insertar Sede Atencion ********/

drop procedure if exists sede.InsertarSedeAtencion
go

CREATE PROCEDURE sede.InsertarSedeAtencion
    @nombreSede VARCHAR(20),
    @direccionSede VARCHAR(50)
AS
BEGIN
    INSERT INTO sede.SedeAtencion (nombreSede, direccionSede)
    VALUES (@nombreSede, @direccionSede);
END;


go


/******** Stored Procedure Modificar Sede Atencion ********/

drop procedure if exists sede.ModificarSedeAtencion
go

CREATE PROCEDURE sede.ModificarSedeAtencion
    @idSede INT,
    @nuevoNombreSede VARCHAR(20),
    @nuevaDireccionSede VARCHAR(50)
AS
BEGIN
    UPDATE sede.SedeAtencion
    SET nombreSede = @nuevoNombreSede,
        direccionSede = @nuevaDireccionSede
    WHERE idSede = @idSede;
END;


go


/******** Stored Procedure Eliminar Sede Atencion ********/

drop procedure if exists sede.EliminarSedeAtencion
go

CREATE PROCEDURE sede.EliminarSedeAtencion
    @idSede INT
AS
BEGIN
    DELETE FROM sede.SedeAtencion
	WHERE idSede = @idSede
END;


go


/******** Stored Procedure Insertar Dias x Sede ********/

drop procedure if exists sede.InsertarDiasxSede
go

CREATE PROCEDURE sede.InsertarDiasxSede
    @idSede INT,
    @idMedico INT,
    @dia CHAR(9),
    @horaInicio TIME,
	@horaFin TIME
AS
BEGIN
    INSERT INTO sede.DiasxSede (idSede, idMedico, dia, horaInicio, horaFin)
    VALUES (@idSede, @idMedico, @dia, @horaInicio, @horaFin);
END;


go


/******** Stored Procedure Modificar Dias x Sede ********/

drop procedure if exists sede.ModificarDiasxSede
go

CREATE PROCEDURE sede.ModificarDiasxSede
    @idSede INT,
    @idMedico INT,
    @dia CHAR(9),
    @nuevaHoraInicio TIME,
    @nuevaHoraFin TIME
AS
BEGIN
    UPDATE sede.DiasxSede
    SET horaInicio = @nuevaHoraInicio,
		horaFin = @nuevaHoraFin
    WHERE idSede = @idSede AND idMedico = @idMedico AND dia = @dia;
END;


go


/******** Stored Procedure Eliminar Dias x Sede ********/

drop procedure if exists sede.EliminarDiasxSede
go

CREATE PROCEDURE sede.EliminarDiasxSede
    @idSede INT,
    @idMedico INT,
	@dia CHAR(9)
AS
BEGIN
    DELETE FROM sede.DiasxSede 
	WHERE idSede = @idSede AND idMedico = @idMedico AND dia = @dia;
END;


go


/******** Funcion Get Dia Semana ********/

drop function if exists turno.getDiaSemana
go

--Funcion Complementaria para obtener nombre del Dia de la Semana a partir de una fecha
CREATE FUNCTION turno.getDiaSemana(@fecha date) returns char(9) as
begin

declare @diaenletra char(9)
declare @dia int

set @dia = DATEPART(dw, @fecha)
select @diaenletra = case @dia
					 when 1 then 'Domingo'
					 when 2 then 'Lunes'
					 when 3 then 'Martes'
					 when 4 then 'Miercoles'
					 when 5 then 'Jueves'
					 when 6 then 'Viernes'
					 when 7 then 'Sabado'
					 end
return @diaenletra
end

go


/******** Stored Procedure Insertar Reserva Turno Medico ********/

drop procedure if exists turno.InsertarReservaTurnoMedico
go

--Los turnos para atención médica tienen como estado inicial disponible, según el médico, la especialidad y la sede.
CREATE PROCEDURE turno.InsertarReservaTurnoMedico
    @fecha DATE,
    @hora TIME,
    @idMedico INT,
    @idSede INT,
	@diaMedicoSede CHAR(9),
    @idTipoTurno INT 
AS
BEGIN
	if turno.getDiaSemana(@fecha)<>@diaMedicoSede
		print 'El dia de la semana del turno no coincide con el dia asignado en la sede.';
	else
	if not exists (select 1 from sede.DiasxSede where idSede=@idSede and idMedico=@idMedico and dia=@diaMedicoSede and @hora between horaInicio and horaFin)
		print 'No existe una combinacion posible para el medico, la sede, el dia y el horario solicitados.';
	else
		INSERT INTO turno.ReservaTurnoMedico (fecha, hora, idMedico, idSede, diaMedicoSede, idEstadoTurno, idTipoTurno, idHistoriaClinica)
		VALUES (@fecha, @hora, @idMedico, @idSede, @diaMedicoSede, 1, @idTipoTurno, null);
		--solo se crea el turno en si como disponible, no se le asigna a nadie en primera instancia
END;


go


/******** Stored Procedure Modificar Reserva Turno Medico ********/

drop procedure if exists turno.ModificarReservaTurnoMedico
go

CREATE PROCEDURE turno.ModificarReservaTurnoMedico --aqui ya puedo asignar a algun paciente
    @idTurno INT,
    @nuevaFecha DATE,
    @nuevaHora TIME,
    @nuevoIdMedico INT,
    @nuevoIdSede INT,
	@nuevoDiaMedicoSede CHAR(9),
    @nuevoIdEstadoTurno INT,
    @nuevoIdTipoTurno INT,
	@nuevoIdHistoriaClinica INT
AS
BEGIN
	if turno.getDiaSemana(@nuevaFecha)<>@nuevoDiaMedicoSede
		print 'El dia de la semana del turno no coincide con el dia asignado en la sede.';
	else
	if not exists (select 1 from sede.DiasxSede where idSede=@nuevoIdSede and idMedico=@nuevoIdMedico and dia=@nuevoDiaMedicoSede and @nuevaHora between horaInicio and horaFin)
		print 'No existe una combinacion posible para el medico, la sede, el dia y el horario solicitados.';
	else
		UPDATE turno.ReservaTurnoMedico
		SET fecha = @nuevaFecha,
			hora = @nuevaHora,
			idMedico = @nuevoIdMedico,
			idSede = @nuevoIdSede,
			diaMedicoSede = @nuevoDiaMedicoSede,
			idEstadoTurno = @nuevoIdEstadoTurno,
			idTipoTurno = @nuevoIdTipoTurno,
			idHistoriaClinica = @nuevoIdHistoriaClinica
		WHERE idTurno = @idTurno
END;


go


/******** Stored Procedure Eliminar Reserva Turno Medico ********/

drop procedure if exists turno.EliminarReservaTurnoMedico
go

CREATE PROCEDURE turno.EliminarReservaTurnoMedico
    @idTurno INT
AS
BEGIN
	DELETE FROM turno.ReservaTurnoMedico 
	WHERE idTurno = @idTurno;
END;


go


/******** Stored Procedure Finalizar Alianza Prestador ********/

drop procedure if exists prestacion.FinalizarAlianzaPrestador
go

/*Los prestadores están conformados por Obras Sociales y Prepagas con las cuales se establece
una alianza comercial. Dicha alianza puede finalizar en cualquier momento, por lo cual debe
poder ser actualizable de forma inmediata si el contrato no está vigente. En caso de no estar
vigente el contrato, deben ser anulados todos los turnos de pacientes que se encuentren
vinculados a esa prestadora y pasar a estado disponible.*/

CREATE PROCEDURE prestacion.FinalizarAlianzaPrestador
	@idPrestador INT
AS
	declare @countPaciente int
	declare @idActual int
	declare @idCobertura int
	declare @idDomicilio int
	declare @idUsuario int
BEGIN
	--Primero cargo en una temporal que pacientes son los afectados
	select PacientesAnulados.idHistoriaClinica 
	into #TempPacientes
	from (select pa.idHistoriaClinica
			from persona.Paciente pa
			inner join prestacion.Cobertura c on pa.idHistoriaClinica=c.idHistoriaClinica
			inner join prestacion.Prestador pr on c.idPrestador=pr.idPrestador
			where pr.idPrestador=@idPrestador) PacientesAnulados

	--Sus correspondientes turnos pasaran a estar disponibles
	UPDATE turno.ReservaTurnoMedico --no utilizo modificarReserva xq requiero hacer consulta x un campo especifico, desconozco resto
	set idEstadoTurno=1, idHistoriaClinica=null
	where idHistoriaClinica in (select idHistoriaClinica
								from #TempPacientes)

	--Tambien elimino(fisicamente) los estudios asociados a esa prestadora
	--No utilizo examen.EliminarEstudio ya que deberia crear una temporal con los estudios afectados y luego recorrerla ejecutando para cada registro dicho SP
	DELETE FROM examen.Estudio
	where idPrestador=@idPrestador

	--Actualizados los turnos y eliminados los estudios, elimino(logicamente) el prestador
	exec prestacion.EliminarPrestador @idPrestador 

	--elimino(logicamente) a dichos pacientes y sus datos relacionados de mi sistema.
	set @countPaciente = (select count(1) from #TempPacientes)
	while @countPaciente > 0 
	begin
		--selecciono a alguien de los pacientes afectados
		select top 1 @idActual = idHistoriaClinica from #TempPacientes

		--borro logicamente su cobertura
		select @idCobertura = idCobertura from prestacion.Cobertura where idHistoriaClinica=@idActual
		exec prestacion.EliminarCobertura @idCobertura

		--borro logicamente su domicilio
		select @idDomicilio = idDomicilio from persona.Domicilio where idHistoriaClinica=@idActual
		exec persona.EliminarDomicilio @idDomicilio

		--borro logicamente su usuario
		select @idUsuario = idUsuario from persona.Usuario where idHistoriaClinica=@idActual
		exec persona.EliminarUsuario @idUsuario

		--borro logicamente al paciente
		exec persona.EliminarPaciente @idActual

		--borro de la temporal y resto contador para pasar al siguiente
		delete from #TempPacientes where idHistoriaClinica=@idActual
		set @countPaciente = @countPaciente - 1
	end

	drop table #TempPacientes
END;

go