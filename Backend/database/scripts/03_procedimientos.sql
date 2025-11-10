-- ========================================
-- PROCEDIMIENTOS ALMACENADOS - CUMPLIENDO REQUISITO 3
-- ========================================
USE HospitalDB;
GO

PRINT '📋 Creando procedimientos almacenados...';
GO

-- =============================================
-- REQUISITO 3a: CRUD COMPLETO PARA PACIENTES
-- =============================================

-- CREATE
CREATE OR ALTER PROCEDURE sp_Pacientes_Create
    @nombre CHAR(80),
    @edad INT,
    @direccion VARCHAR(150) = NULL,
    @telefono INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO Pacientes (nombre, edad, direccion, telefono)
        VALUES (@nombre, @edad, @direccion, @telefono);
        
        SELECT ID, nombre, edad, direccion, telefono
        FROM Pacientes WHERE ID = SCOPE_IDENTITY();
    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END
GO

-- READ ALL
CREATE OR ALTER PROCEDURE sp_Pacientes_ReadAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, nombre, edad, direccion, telefono
    FROM Pacientes
    ORDER BY nombre;
END
GO

-- READ BY ID
CREATE OR ALTER PROCEDURE sp_Pacientes_ReadByID
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, nombre, edad, direccion, telefono
    FROM Pacientes
    WHERE ID = @id;
END
GO

-- UPDATE
CREATE OR ALTER PROCEDURE sp_Pacientes_Update
    @id INT,
    @nombre CHAR(80),
    @edad INT,
    @direccion VARCHAR(150) = NULL,
    @telefono INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Pacientes
    SET nombre = @nombre, edad = @edad, direccion = @direccion, telefono = @telefono
    WHERE ID = @id;
    
    SELECT ID, nombre, edad, direccion, telefono
    FROM Pacientes WHERE ID = @id;
END
GO

-- DELETE
CREATE OR ALTER PROCEDURE sp_Pacientes_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Pacientes WHERE ID = @id;
END
GO

-- =============================================
-- REQUISITO 3a: CRUD COMPLETO PARA DOCTORES
-- =============================================

CREATE OR ALTER PROCEDURE sp_Doctores_Create
    @nombre CHAR(60),
    @especialidad VARCHAR(50),
    @telefono INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Doctores (nombre, especialidad, telefono)
    VALUES (@nombre, @especialidad, @telefono);
    
    SELECT ID, nombre, especialidad, telefono
    FROM Doctores WHERE ID = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE sp_Doctores_ReadAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ID, nombre, especialidad, telefono
    FROM Doctores
    ORDER BY especialidad, nombre;
END
GO

CREATE OR ALTER PROCEDURE sp_Doctores_Update
    @id INT,
    @nombre CHAR(60),
    @especialidad VARCHAR(50),
    @telefono INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Doctores
    SET nombre = @nombre, especialidad = @especialidad, telefono = @telefono
    WHERE ID = @id;
    
    SELECT ID, nombre, especialidad, telefono
    FROM Doctores WHERE ID = @id;
END
GO

CREATE OR ALTER PROCEDURE sp_Doctores_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Doctores WHERE ID = @id;
END
GO

-- =============================================
-- REQUISITO 3a: CRUD COMPLETO PARA CITAS
-- =============================================

CREATE OR ALTER PROCEDURE sp_Citas_Create
    @paciente_id INT,
    @doctor_id INT,
    @fecha DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Citas (paciente_id, doctor_id, fecha)
    VALUES (@paciente_id, @doctor_id, @fecha);
    
    SELECT ID, paciente_id, doctor_id, fecha
    FROM Citas WHERE ID = SCOPE_IDENTITY();
END
GO

CREATE OR ALTER PROCEDURE sp_Citas_ReadAll
AS
BEGIN
    SET NOCOUNT ON;
    SELECT c.ID, c.paciente_id, p.nombre AS paciente_nombre,
           c.doctor_id, d.nombre AS doctor_nombre, c.fecha
    FROM Citas c
    INNER JOIN Pacientes p ON c.paciente_id = p.ID
    INNER JOIN Doctores d ON c.doctor_id = d.ID
    ORDER BY c.fecha DESC;
END
GO

CREATE OR ALTER PROCEDURE sp_Citas_Update
    @id INT,
    @paciente_id INT,
    @doctor_id INT,
    @fecha DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Citas
    SET paciente_id = @paciente_id, doctor_id = @doctor_id, fecha = @fecha
    WHERE ID = @id;
    
    SELECT ID, paciente_id, doctor_id, fecha
    FROM Citas WHERE ID = @id;
END
GO

CREATE OR ALTER PROCEDURE sp_Citas_Delete
    @id INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM Citas WHERE ID = @id;
END
GO

-- =============================================
-- REQUISITO 3b: PROCEDIMIENTO COMPUESTO
-- Inserta Cita (maestra) + Diagnóstico (detalle)
-- =============================================

CREATE OR ALTER PROCEDURE sp_CitaConDiagnostico_Insert
    @paciente_id INT,
    @doctor_id INT,
    @fecha DATETIME,
    @diagnostico VARCHAR(200),
    @tratamiento VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Insertar en tabla maestra (Citas)
        DECLARE @cita_id INT;
        INSERT INTO Citas (paciente_id, doctor_id, fecha)
        VALUES (@paciente_id, @doctor_id, @fecha);
        
        SET @cita_id = SCOPE_IDENTITY();
        
        -- Insertar en tabla detalle (Diagnosticos)
        INSERT INTO Diagnosticos (id_cita, diagnostico, tratamiento)
        VALUES (@cita_id, @diagnostico, @tratamiento);
        
        -- Retornar ambos registros insertados
        SELECT c.ID AS CitaID, c.paciente_id, c.doctor_id, c.fecha,
               d.ID AS DiagnosticoID, d.diagnostico, d.tratamiento
        FROM Citas c
        INNER JOIN Diagnosticos d ON c.ID = d.id_cita
        WHERE c.ID = @cita_id;
        
        COMMIT TRANSACTION;
        PRINT '✓ Cita y diagnóstico insertados correctamente';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END
GO

PRINT '✓ Procedimientos almacenados creados correctamente';
GO
