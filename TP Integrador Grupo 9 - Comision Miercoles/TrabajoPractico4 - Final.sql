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
Se proveen maestros de Médicos, Pacientes, Prestadores y Sedes en formato CSV. También se
dispone de un archivo JSON que contiene la parametrización del mecanismo de autorización
según estudio y obra social, además de porcentaje cubierto, etc. Ver archivo “Datasets para
importar” en Miel.

Se requiere que importe toda la información antes mencionada a la base de datos. Genere los
objetos necesarios (store procedures, funciones, etc.) para importar los archivos antes
mencionados. Tenga en cuenta que cada mes se recibirán archivos de novedades con la misma
estructura pero datos nuevos para agregar a cada maestro. Considere este comportamiento al
generar el código. Debe admitir la importación de novedades periódicamente.

Los archivos CSV/JSON no deben modificarse. En caso de que haya datos mal cargados,
incompletos, erróneos, etc., deberá contemplarlo y realizar las correcciones en el fuente SQL.
(Sería una excepción si el archivo está malformado y no es posible interpretarlo como JSON o
CSV). Documente las correcciones que haga indicando número de línea, contenido previo y
contenido nuevo. Esto se cotejará para constatar que cumpla correctamente la consigna.

Adicionalmente se requiere que el sistema sea capaz de generar un archivo XML detallando los
turnos atendidos para informar a la Obra Social. El mismo debe constar de los datos del paciente
(Apellido, nombre, DNI), nombre y matrícula del profesional que lo atendió, fecha, hora,
especialidad. Los parámetros de entrada son el nombre de la obra social y un intervalo de fechas.
*/

GO
USE CURESA

GO

 -- Drop la función si existe
 IF OBJECT_ID('dbo.Capitalize') IS NOT NULL
   DROP FUNCTION dbo.Capitalize;
 GO

CREATE FUNCTION dbo.Capitalize (@string VARCHAR(255))
  RETURNS VARCHAR(255)
  AS
  BEGIN
    DECLARE @res VARCHAR(255) = LOWER(@string),
         @char CHAR(1), 
         @alphanum BIT = 0,
         @len INT = LEN(@string),
         @pos INT = 1;        

    -- Iterar entre todos los caracteres en la cadena de entrada
    WHILE @pos <= @len 
	BEGIN
		  -- Obtener el siguiente caracter
		  SET @char = SUBSTRING(@string, @pos, 1);

		  -- Si la posición del caracter es la 1ª, o el caracter previo no es alfanumérico
		  -- convierte el caracter actual a mayúscula
		  IF @pos = 1 OR @alphanum = 0
			SET @res = STUFF(@res, @pos, 1, UPPER(@char));

		  SET @pos = @pos + 1;

		  -- Define si el caracter actual es  non-alfanumérico
		  IF ASCII(@char) <= 47 OR (ASCII(@char) BETWEEN 58 AND 64) OR
		  (ASCII(@char) BETWEEN 91 AND 96) OR (ASCII(@char) BETWEEN 123 AND 126)
		  SET @alphanum = 0;
		  ELSE
		  SET @alphanum = 1;
    END
	SET @res = LTRIM(RTRIM(@res))
  RETURN @res;         
  END
GO
-------------------------------------------------------------------------------------------------------
--Importacion de Informacion de archivo de Medicos
GO
  IF OBJECT_ID('especialista.ProcesarMedicos') IS NOT NULL
    DROP PROCEDURE especialista.ProcesarMedicos;
  GO
CREATE PROCEDURE especialista.ProcesarMedicos
	AS
	BEGIN
	
		-- Definir una tabla temporal para cargar los datos CSV Medicos
		CREATE TABLE #TempMedicos (
			apellido VARCHAR(50),
			nombre VARCHAR(50),
			especialidad VARCHAR(20),
			nro_colegiado INT
		)

		-- Cargar los datos CSV en la tabla temporal
		DECLARE @PATH NVARCHAR(255)
		SELECT @PATH = CONVERT(NVARCHAR(255), SESSION_CONTEXT(N'@PATH'))
		DECLARE @SQL NVARCHAR(MAX);
		SET @SQL = '
		BULK INSERT #TempMedicos
		FROM ''' + @PATH + 'Medicos.csv''
		WITH
		(
			FIRSTROW = 2,            -- Ignora la primera fila si contiene encabezados
			FIELDTERMINATOR = '';'',   -- Especifica el delimitador de campos (coma)
			ROWTERMINATOR = ''\n'',     -- Especifica el delimitador de filas (salto de línea)
			CODEPAGE = ''65001'' -- Para UTF-8
		);'
		EXEC sp_executesql @SQL;

		--Importar en la tabla Especialidades.
		--DBCC CHECKIDENT ('especialista.Especialidad', RESEED, 0);
		INSERT INTO especialista.Especialidad (nombreEspecialidad, activo)
		SELECT DISTINCT 
		dbo.Capitalize(especialidad) AS Especialidad, 1 
		FROM #TempMedicos Tmp
		WHERE NOT EXISTS ( 
			SELECT 1 FROM especialista.Especialidad E
			WHERE E.nombreEspecialidad = Tmp.especialidad)

		--Importar en la tabla Medicos
		--DBCC CHECKIDENT ('especialista.Medico', RESEED, 0);
		INSERT INTO especialista.Medico(nombre,apellido,nroMatricula,idEspecialidad,activo)
		SELECT 
		dbo.Capitalize(nombre) AS Nombre,
		dbo.Capitalize(SUBSTRING(apellido, CHARINDEX('.', apellido) + 1, LEN(apellido))) AS Apellido,
		nro_colegiado, 
		idEspecialidad, 
		1 AS activo
		FROM #TempMedicos tmpM INNER JOIN especialista.Especialidad E ON tmpM.especialidad = E.nombreEspecialidad
		WHERE NOT EXISTS ( 
			SELECT 1 FROM especialista.Medico M
			WHERE M.nroMatricula = tmpM.nro_colegiado
			AND nombre NOT LIKE '%[0-9]%'  -- Valida que el nombre no contenga números
			AND apellido NOT LIKE '%[0-9]%'  -- Valida que el apellido no contenga números
			AND especialidad NOT LIKE '%[0-9]%')  -- Valida que la especialidad no contenga números


		--Eliminar Temporal
		DROP TABLE #TempMedicos
	END
GO
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
--Importacion de Informacion de archivo de Sedes
GO
  IF OBJECT_ID('sede.ProcesarSedeAtencion') IS NOT NULL
    DROP PROCEDURE sede.ProcesarSedeAtencion;
  GO
create PROCEDURE sede.ProcesarSedeAtencion
	AS
	BEGIN
	
		-- Definir una tabla temporal para cargar los datos CSV Sedes
		CREATE TABLE #TempSedes (
			nombre_sede VARCHAR(20),
			direccion VARCHAR(50),
			localidad VARCHAR(20),
			provincia VARCHAR(20)
		)
		-- Cargar los datos CSV en la tabla temporal
		--DROP TABLE #TempSedes
		DECLARE @PATH NVARCHAR(255)
		SELECT @PATH = CONVERT(NVARCHAR(255), SESSION_CONTEXT(N'@PATH'))
		DECLARE @SQL NVARCHAR(MAX);
		SET @SQL = '
		BULK INSERT #TempSedes
		FROM ''' + @PATH + 'Sedes.csv''
		WITH
		(
			FIRSTROW = 2,            -- Ignora la primera fila si contiene encabezados
			FIELDTERMINATOR = '';'',   -- Especifica el delimitador de campos (coma)
			ROWTERMINATOR = ''\n'',     -- Especifica el delimitador de filas (salto de línea)
			CODEPAGE = ''65001'' -- Para UTF-8
		);'

		EXEC sp_executesql @SQL;

		--Importar en la tabla SedeAtencion.
		--DBCC CHECKIDENT ('sede.SedeAtencion', RESEED, 0);
		INSERT INTO sede.SedeAtencion (nombreSede, direccionSede)
		SELECT LTRIM(RTRIM(nombre_sede)), LTRIM(RTRIM(direccion))
		FROM #TempSedes Tmp
		WHERE NOT EXISTS ( 
			SELECT 1 FROM sede.SedeAtencion S
			WHERE S.nombreSede = LTRIM(Tmp.nombre_sede)
			AND S.direccionSede = LTRIM(Tmp.direccion))
	
		--Eliminar Temporal
		DROP TABLE #TempSedes
	END
GO
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
--Importacion de Informacion de archivo de Prestadores
GO
  IF OBJECT_ID('prestacion.ProcesarPrestadores') IS NOT NULL
    DROP PROCEDURE prestacion.ProcesarPrestadores;
  GO
CREATE PROCEDURE prestacion.ProcesarPrestadores
	AS
	BEGIN
	
		-- Definir una tabla temporal para cargar los datos CSV Prestadores
		CREATE TABLE #TempPrestadores (
			nombre_prestador VARCHAR(20),
			plan_prestador VARCHAR(50)
		)

		-- Cargar los datos CSV en la tabla temporal
		DECLARE @PATH NVARCHAR(255)
		SELECT @PATH = CONVERT(NVARCHAR(255), SESSION_CONTEXT(N'@PATH'))
		DECLARE @SQL NVARCHAR(MAX);
		SET @SQL = '
		BULK INSERT #TempPrestadores
		FROM ''' + @PATH + 'Prestador.csv''
		WITH
		(
			FIRSTROW = 2,            -- Ignora la primera fila si contiene encabezados
			FIELDTERMINATOR = '';'',   -- Especifica el delimitador de campos (coma)
			ROWTERMINATOR = ''\n'',     -- Especifica el delimitador de filas (salto de línea)
			CODEPAGE = ''65001'' -- Para UTF-8
		);'
		EXEC sp_executesql @SQL;
		--Importar en la tabla Prestador.
		--DBCC CHECKIDENT ('prestacion.Prestador', RESEED, 0);
		INSERT INTO prestacion.Prestador (nombrePrestador, planPrestador, activo)
		SELECT 
		nombre_prestador,
		SUBSTRING(plan_prestador, 1, CHARINDEX(';', plan_prestador) - 1) AS plan_prestador,
		1 AS activo
		FROM #TempPrestadores Tmp
		WHERE NOT EXISTS ( 
			SELECT 1 FROM prestacion.Prestador P
			WHERE P.nombrePrestador = Tmp.nombre_prestador
			AND P.planPrestador = SUBSTRING(Tmp.plan_prestador, 1, CHARINDEX(';', Tmp.plan_prestador) - 1))


		--Eliminar Temporal
		DROP TABLE #TempPrestadores
	END
GO
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
--Importacion de Informacion de archivo de Pacientes
GO
  IF OBJECT_ID('persona.ProcesarPacientes') IS NOT NULL
    DROP PROCEDURE persona.ProcesarPacientes;
  GO
CREATE PROCEDURE persona.ProcesarPacientes
	AS
	BEGIN
		-- Definir una tabla temporal para cargar los datos CSV
		CREATE TABLE #TempPacientes (
			Nombre VARCHAR(50),
			Apellido VARCHAR(50),
			FechaNacimiento VARCHAR(10), -- Mantén la fecha como VARCHAR
			TipoDocumento VARCHAR(3),
			NroDocumento INT,
			SexoBiologico VARCHAR(9),
			Genero VARCHAR(6),
			TelefonoFijo VARCHAR(14),
			Nacionalidad VARCHAR(20),
			Mail VARCHAR(40),
			Direccion VARCHAR(255),
			Localidad VARCHAR(50),
			Provincia VARCHAR(25)
		)

		-- Cargar los datos CSV en la tabla temporal
		DECLARE @PATH NVARCHAR(255)
		SELECT @PATH = CONVERT(NVARCHAR(255), SESSION_CONTEXT(N'@PATH'))
		DECLARE @SQL NVARCHAR(MAX);
		SET @SQL = '
		BULK INSERT #TempPacientes
		FROM ''' + @PATH + 'Pacientes.csv''
		WITH
		(
			FIRSTROW = 2,            -- Ignora la primera fila si contiene encabezados
			FIELDTERMINATOR = '';'',   -- Especifica el delimitador de campos (coma)
			ROWTERMINATOR = ''\n'',     -- Especifica el delimitador de filas (salto de línea)
			CODEPAGE = ''65001'' -- Para UTF-8
		);'
		EXEC sp_executesql @SQL;

		-- Insertar los pacientes en la tabla Paciente desde la tabla temporal
		--DBCC CHECKIDENT ('persona.Paciente', RESEED, 0);
		INSERT INTO persona.Paciente (nombre, apellido, fechaNacimiento, tipoDocumento, nroDocumento, sexoBiologico, genero, telefonoFijo, nacionalidad, mail, fechaRegistro, activo)
		SELECT 
			dbo.Capitalize(Nombre),
			dbo.Capitalize(Apellido),
			TRY_PARSE(FechaNacimiento AS DATE USING 'es-ES'),
			TipoDocumento,
			NroDocumento,
			dbo.Capitalize(SexoBiologico),
			dbo.Capitalize(Genero),
			TelefonoFijo,
			dbo.Capitalize(Nacionalidad),
			Mail,
			GETDATE(),
			1
		FROM #TempPacientes tmpP
		WHERE NOT EXISTS ( 
			SELECT 1 FROM persona.Paciente P
			WHERE P.tipoDocumento = tmpP.TipoDocumento
			AND p.nroDocumento = tmpP.NroDocumento)
			AND (SexoBiologico = 'Femenino' OR SexoBiologico = 'Masculino') -- Valida el valor de SexoBiologico
			AND (Genero = 'Hombre' OR Genero = 'Mujer' OR Genero = 'Otro' OR Genero = 'Trans') -- Valida el valor de Genero
			AND TRY_PARSE(FechaNacimiento AS DATE USING 'es-ES') IS NOT NULL -- Valida que la fecha sea no nula y válida
            AND NOT (Nombre LIKE '%[0-9]%' OR Apellido LIKE '%[0-9]%') -- Valida que los nombres y apellidos no contengan números
			AND Mail LIKE '%@%'; -- Valida que el campo "Mail" contenga el carácter "@"

		-- Insertar los domicilios en la tabla Domicilio desde la tabla temporal
		-- Para la no insercion de Domicilios duplicados, se debe poner como 
		INSERT INTO persona.Domicilio (calle, numero, localidad, provincia, idHistoriaClinica, pais, activo)
		SELECT
		CASE
		   WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(Direccion))) + ' ') > 0 THEN
				--primero busco el ultimo espacio en blanco en la cadena, por las dudas se le pone un espacio al final. asi garantizo que tengo el indice de la posiscion final
					LEFT(LTRIM(RTRIM(Direccion)), LEN(LTRIM(RTRIM(Direccion))) - CHARINDEX(' ', REVERSE(LTRIM(RTRIM(Direccion))) + ' '))
					--obtengo la longitud de la calle, para eso resto la posicion final contra la longitud de calle
				ELSE
					LTRIM(RTRIM(Direccion))
			END AS calle,
			CASE
				WHEN CHARINDEX(' ', REVERSE(LTRIM(RTRIM(Direccion))) + ' ') > 0 THEN
					CASE
						WHEN ISNUMERIC(SUBSTRING(LTRIM(RTRIM(Direccion)), LEN(LTRIM(RTRIM(Direccion))) - CHARINDEX(' ', REVERSE(LTRIM(RTRIM(Direccion))) + ' ')+1, 255)) = 1 THEN
						--se fija si es numerico, extraigo el numero de la direccion 
							CAST(SUBSTRING(LTRIM(RTRIM(Direccion)), LEN(LTRIM(RTRIM(Direccion))) - CHARINDEX(' ', REVERSE(LTRIM(RTRIM(Direccion))) + ' ')+1,255) AS INT)
							--si numerico casteo a int
						ELSE
							NULL
					END
				ELSE
					NULL
    END AS numero,
    tmpP.Localidad,
    dbo.Capitalize(tmpP.Provincia),
    P.idHistoriaClinica,
			CASE 
				WHEN tmpP.provincia IN(
				'BUENOS AIRES', 
				'CAPITAL FEDERAL', 
				'LA PAMPA', 
				'CATAMARCA', 
				'CHACO', 
				'CHUBUT', 
				'CORDOBA', 
				'CORRIENTES', 
				'ENTRE RIOS', 
				'FORMOSA', 
				'JUJUY', 
				'LA PAMPA', 
				'LA RIOJA', 
				'MENDOZA', 
				'MISIONES', 
				'NEUQUEN', 
				'RIO NEGRO', 
				'SALTA', 
				'SAN JUAN', 
				'SAN LUIS', 
				'SANTA CRUZ', 
				'SANTA FE', 
				'SANTIAGO DEL ESTERO', 
				'TUCUMAN', 
				'TIERRA DEL FUEGO') 
				THEN 'Argentina'
				ELSE NULL
			END AS pais,
		1 AS activo
		FROM #TempPacientes tmpP
		INNER JOIN persona.Paciente P ON tmpP.NroDocumento = P.nroDocumento
		--WHERE NOT EXISTS ( 
		--	SELECT 1 FROM persona.Paciente P, persona.Domicilio D
		--	WHERE P.idHistoriaClinica = D.idHistoriaClinica)		

		-- Elimina la tabla temporal al final del procedimiento
		DROP TABLE #TempPacientes;
	END
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
--Importacion de Informacion de archivo de Estudios
GO
  IF OBJECT_ID('examen.ProcesarEstudios') IS NOT NULL
    DROP PROCEDURE examen.ProcesarEstudios;
  GO
CREATE PROCEDURE examen.ProcesarEstudios
	AS
	BEGIN
		-- Definir una tabla temporal para cargar los datos JSON

		CREATE TABLE #TempEstudios (
			Area NVARCHAR(20),	
			Estudio NVARCHAR (100),
			Prestador NVARCHAR (20),
			PlanPrestador NVARCHAR (50),
			PorcentajeCobertura INT,
			Costo decimal,
			RequiereAutorizacion BIT
		);

		-- Importar el archivo JSON en la tabla temporal
		DECLARE @PATH NVARCHAR(255)
		SELECT @PATH = CONVERT(NVARCHAR(255), SESSION_CONTEXT(N'@PATH'))
		DECLARE @SQL NVARCHAR(MAX);
		SET @SQL = '
		INSERT INTO #TempEstudios (Area, Estudio, Prestador,PlanPrestador, PorcentajeCobertura, Costo, RequiereAutorizacion)
		SELECT Area, Estudio, Prestador, PlanPrestador, PorcentajeCobertura, Costo, RequiereAutorizacion
		FROM OPENROWSET (BULK ''' + @PATH + 'Centro_Autorizaciones.Estudios clinicos.json'', SINGLE_CLOB) AS JsonFile
		CROSS APPLY OPENJSON(JsonFile.BulkColumn)
		WITH (
			Area NVARCHAR(20) ''$.Area'',
			Estudio NVARCHAR(100) ''$.Estudio'',
			Prestador NVARCHAR(20) ''$.Prestador'',
			PlanPrestador NVARCHAR(50) ''$.Plan'',
			PorcentajeCobertura INT ''$."Porcentaje Cobertura"'',
			Costo int ''$.Costo'',
			RequiereAutorizacion BIT ''$."Requiere autorizacion"''
		);'
		EXEC sp_executesql @SQL;


		-- Insertar los estudios en la tabla Estudios desde la tabla temporal
		--DBCC CHECKIDENT ('examen.Estudio', RESEED, 0);
		INSERT INTO examen.Estudio (idPrestador, areaEstudio, nombreEstudio, requiere_autorizacion, porcentaje_cobertura,importe)
		SELECT 
			P.idPrestador,
			dbo.Capitalize(Area),
			dbo.Capitalize(Estudio),
			RequiereAutorizacion,
			PorcentajeCobertura,
			CAST(Costo AS Decimal)
		FROM #TempEstudios TmpE
		INNER JOIN prestacion.Prestador AS P ON TmpE.Prestador = P.nombrePrestador
		AND TmpE.PlanPrestador = P.planPrestador
		WHERE NOT EXISTS ( 
			SELECT 1 FROM examen.Estudio E
			WHERE E.nombreEstudio = TmpE.Estudio
			AND E.idPrestador = P.idPrestador)
		-- Elimina la tabla temporal al final del procedimiento
		DROP TABLE #TempEstudios;
	END
GO
-------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------
--Obtener Turnos Medicos en un Rango de Fecha por Prestador
GO
  IF OBJECT_ID('turno.getTurnosMedicos') IS NOT NULL
    DROP PROCEDURE turno.getTurnosMedicos;
  GO
CREATE PROCEDURE turno.getTurnosMedicos
	@nombrePrestador nvarchar(20),
	@fechaDesde datetime,
	@fechaHasta datetime
	AS
	BEGIN
		SELECT 
			P.apellido AS apellido_paciente, 
			P.apellidoMaterno AS apellido_materno_paciente, 
			P.nombre AS nombre_paciente, 
			P.tipoDocumento AS tipo_doc_paciente, 
			P.nroDocumento AS nro_doc_paciente, 
			M.apellido AS apellido_medico, 
			M.nombre AS nombre_medico, 
			M.nroMatricula AS matricula_medico, 
			E.nombreEspecialidad AS especialidad_medico,
			RTM.fecha AS fecha_turno, 
			RTM.hora AS hora_turno
		FROM turno.ReservaTurnoMedico RTM
			INNER JOIN turno.EstadoTurno ET ON ET.IdEstado = RTM.idEstadoTurno 
			INNER JOIN persona.Paciente P ON P.idHistoriaClinica = RTM.idHistoriaClinica
			INNER JOIN especialista.Medico M ON M.idMedico = RTM.idMedico
			INNER JOIN especialista.Especialidad E ON E.idEspecialidad = M.idEspecialidad
			INNER JOIN prestacion.Cobertura C ON C.idHistoriaClinica = P.idHistoriaClinica
			INNER JOIN prestacion.Prestador Pr ON Pr.idPrestador = C.idPrestador
		WHERE	ET.nombreEstado = 'Atendido'
				AND RTM.fecha BETWEEN @fechaDesde AND @fechaHasta
				AND  Pr.nombrePrestador = @nombrePrestador
		for xml RAW ('Turno'),  ROOT('TurnosMedicos');;

	END;
GO
--------------------------------------------------------------------------------------------------------------------