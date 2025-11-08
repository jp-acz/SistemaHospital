-- database/scripts/03_procedimientos_hospital.sql
-- Procedimientos almacenados CRUD para el sistema hospitalario

USE HospitalDB;
GO

-- ===================================================
-- PROCEDIMIENTOS PARA PACIENTES
-- ===================================================

-- CREATE: Crear nuevo paciente
CREATE OR ALTER PROCEDURE sp_Pacientes_Create
    @nombre VARCHAR(100),
    @edad INT,
    @direccion VARCHAR(200),
    @telefono VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validaciones
        IF @edad < 0 OR @edad > 150
        BEGIN
            RAISERROR('La edad debe estar entre 0 y 150', 16, 1);
            RETURN;
        END
        
        INSERT INTO Pacientes (nombre, edad, direccion, telefono)
        VALUES (@nombre, @edad, @direccion, @telefono);
        
        SELECT 
            ID, nombre, edad, direccion, telefono, 
            FechaRegistro, Estado
        FROM Pacientes 
        WHERE ID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- READ: Obtener todos los pacientes activos
CREATE OR ALTER PROCEDURE sp_Pacientes_ReadAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, nombre, edad, direccion, telefono, 
        FechaRegistro, Estado
    FROM Pacientes
    WHERE Estado = 1
    ORDER BY nombre;
END
GO

-- READ: Obtener paciente por ID
CREATE OR ALTER PROCEDURE sp_Pacientes_ReadById
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, nombre, edad, direccion, telefono, 
        FechaRegistro, Estado
    FROM Pacientes
    WHERE ID = @ID;
END
GO

-- UPDATE: Actualizar paciente
CREATE OR ALTER PROCEDURE sp_Pacientes_Update
    @ID INT,
    @nombre VARCHAR(100),
    @edad INT,
    @direccion VARCHAR(200),
    @telefono VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE ID = @ID)
        BEGIN
            RAISERROR('Paciente no existe', 16, 1);
            RETURN;
        END
        
        UPDATE Pacientes
        SET nombre=@nombre, edad=@edad, direccion=@direccion, telefono=@telefono
        WHERE ID = @ID;
        
        SELECT 
            ID, nombre, edad, direccion, telefono, 
            FechaRegistro, Estado
        FROM Pacientes 
        WHERE ID = @ID;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- DELETE: Eliminar paciente (soft delete)
CREATE OR ALTER PROCEDURE sp_Pacientes_Delete
    @ID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE ID = @ID)
        BEGIN
            RAISERROR('Paciente no existe', 16, 1);
            RETURN;
        END
        
        UPDATE Pacientes SET Estado = 0 WHERE ID = @ID;
        
        COMMIT TRANSACTION;
        SELECT 'Paciente eliminado exitosamente' AS Mensaje;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- ===================================================
-- PROCEDIMIENTOS PARA DOCTORES
-- ===================================================

-- CREATE: Crear nuevo doctor
CREATE OR ALTER PROCEDURE sp_Doctores_Create
    @nombre VARCHAR(100),
    @especialidad VARCHAR(100),
    @telefono VARCHAR(15)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        INSERT INTO Doctores (nombre, especialidad, telefono)
        VALUES (@nombre, @especialidad, @telefono);
        
        SELECT 
            ID, nombre, especialidad, telefono, 
            FechaContratacion, Estado
        FROM Doctores 
        WHERE ID = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- READ: Obtener todos los doctores activos
CREATE OR ALTER PROCEDURE sp_Doctores_ReadAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, nombre, especialidad, telefono, 
        FechaContratacion, Estado
    FROM Doctores
    WHERE Estado = 1
    ORDER BY especialidad, nombre;
END
GO

-- READ: Obtener doctores por especialidad
CREATE OR ALTER PROCEDURE sp_Doctores_PorEspecialidad
    @especialidad VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, nombre, especialidad, telefono, 
        FechaContratacion, Estado
    FROM Doctores
    WHERE especialidad = @especialidad AND Estado = 1
    ORDER BY nombre;
END
GO

-- ===================================================
-- PROCEDIMIENTOS PARA CITAS (Maestra/Detalle)
-- ===================================================

-- CREATE: Crear cita con diagnóstico
CREATE OR ALTER PROCEDURE sp_Citas_CreateConDiagnostico
    @paciente_id INT,
    @doctor_id INT,
    @fecha DATE,
    @hora TIME,
    @motivo TEXT,
    @diagnostico TEXT,
    @tratamiento TEXT,
    @medicamentos TEXT = NULL,
    @recomendaciones TEXT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validaciones
        IF NOT EXISTS (SELECT 1 FROM Pacientes WHERE ID = @paciente_id AND Estado = 1)
        BEGIN
            RAISERROR('Paciente no existe o está inactivo', 16, 1);
            RETURN;
        END
        
        IF NOT EXISTS (SELECT 1 FROM Doctores WHERE ID = @doctor_id AND Estado = 1)
        BEGIN
            RAISERROR('Doctor no existe o está inactivo', 16, 1);
            RETURN;
        END
        
        -- Insertar cita
        INSERT INTO Citas (paciente_id, doctor_id, fecha, hora, motivo, estado)
        VALUES (@paciente_id, @doctor_id, @fecha, @hora, @motivo, 'Completada');
        
        DECLARE @cita_id INT = SCOPE_IDENTITY();
        
        -- Insertar diagnóstico
        INSERT INTO Diagnosticos (cita_id, diagnostico, tratamiento, medicamentos, recomendaciones)
        VALUES (@cita_id, @diagnostico, @tratamiento, @medicamentos, @recomendaciones);
        
        -- Retornar información de cita y diagnóstico
        SELECT 
            c.ID AS CitaID,
            p.nombre AS PacienteNombre,
            d.nombre AS DoctorNombre,
            c.fecha,
            c.hora,
            c.motivo,
            diag.diagnostico,
            diag.tratamiento
        FROM Citas c
        INNER JOIN Pacientes p ON c.paciente_id = p.ID
        INNER JOIN Doctores d ON c.doctor_id = d.ID
        INNER JOIN Diagnosticos diag ON c.ID = diag.cita_id
        WHERE c.ID = @cita_id;
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END
GO

-- READ: Obtener citas de un paciente
CREATE OR ALTER PROCEDURE sp_Citas_PorPaciente
    @paciente_id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.ID,
        c.paciente_id,
        p.nombre AS PacienteNombre,
        c.doctor_id,
        d.nombre AS DoctorNombre,
        d.especialidad,
        c.fecha,
        c.hora,
        c.estado,
        c.motivo
    FROM Citas c
    INNER JOIN Pacientes p ON c.paciente_id = p.ID
    INNER JOIN Doctores d ON c.doctor_id = d.ID
    WHERE c.paciente_id = @paciente_id
    ORDER BY c.fecha DESC;
END
GO

-- READ: Obtener agenda de un doctor
CREATE OR ALTER PROCEDURE sp_Citas_PorDoctor
    @doctor_id INT,
    @fecha DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        c.ID,
        c.paciente_id,
        p.nombre AS PacienteNombre,
        c.doctor_id,
        c.fecha,
        c.hora,
        c.estado,
        c.motivo
    FROM Citas c
    INNER JOIN Pacientes p ON c.paciente_id = p.ID
    WHERE c.doctor_id = @doctor_id
    AND (@fecha IS NULL OR c.fecha = @fecha)
    ORDER BY c.fecha, c.hora;
END
GO

PRINT '✓ Procedimientos almacenados creados exitosamente';
GO