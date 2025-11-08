-- database/scripts/05_triggers_hospital.sql
-- Triggers para auditoría, validación y control de datos

USE HospitalDB;
GO

-- ===================================================
-- TRIGGER 1 (AFTER INSERT, UPDATE, DELETE): Auditoría en Pacientes
-- ===================================================
CREATE OR ALTER TRIGGER trg_Pacientes_Auditoria
ON Pacientes
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Operacion VARCHAR(10);
    DECLARE @DatosAnteriores NVARCHAR(MAX);
    DECLARE @DatosNuevos NVARCHAR(MAX);
    
    -- Determinar tipo de operación
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'UPDATE'
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @Operacion = 'INSERT'
    ELSE
        SET @Operacion = 'DELETE';
    
    -- Capturar datos
    IF EXISTS (SELECT * FROM deleted)
        SELECT @DatosAnteriores = (SELECT * FROM deleted FOR JSON PATH);
    
    IF EXISTS (SELECT * FROM inserted)
        SELECT @DatosNuevos = (SELECT * FROM inserted FOR JSON PATH);
    
    -- Registrar en auditoría
    INSERT INTO LOG_AUDITORIA (TablaAfectada, TipoOperacion, UsuarioOperacion, DatosAnteriores, DatosNuevos)
    VALUES ('Pacientes', @Operacion, SYSTEM_USER, @DatosAnteriores, @DatosNuevos);
END
GO

-- ===================================================
-- TRIGGER 2 (AFTER INSERT, UPDATE, DELETE): Auditoría en Citas
-- ===================================================
CREATE OR ALTER TRIGGER trg_Citas_Auditoria
ON Citas
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Operacion VARCHAR(10);
    DECLARE @DatosAnteriores NVARCHAR(MAX);
    DECLARE @DatosNuevos NVARCHAR(MAX);
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'UPDATE'
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @Operacion = 'INSERT'
    ELSE
        SET @Operacion = 'DELETE';
    
    IF EXISTS (SELECT * FROM deleted)
        SELECT @DatosAnteriores = (SELECT * FROM deleted FOR JSON PATH);
    
    IF EXISTS (SELECT * FROM inserted)
        SELECT @DatosNuevos = (SELECT * FROM inserted FOR JSON PATH);
    
    INSERT INTO LOG_AUDITORIA (TablaAfectada, TipoOperacion, UsuarioOperacion, DatosAnteriores, DatosNuevos)
    VALUES ('Citas', @Operacion, SYSTEM_USER, @DatosAnteriores, @DatosNuevos);
END
GO

-- ===================================================
-- TRIGGER 3 (INSTEAD OF DELETE): Soft delete en Pacientes
-- ===================================================
CREATE OR ALTER TRIGGER trg_Pacientes_SoftDelete
ON Pacientes
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- En lugar de eliminar, marcar como inactivo
    UPDATE Pacientes
    SET Estado = 0
    FROM Pacientes p
    INNER JOIN deleted d ON p.ID = d.ID;
    
    -- Registrar en auditoría
    INSERT INTO LOG_AUDITORIA (TablaAfectada, TipoOperacion, UsuarioOperacion, DatosAnteriores)
    SELECT 'Pacientes', 'SOFT_DELETE', SYSTEM_USER, (SELECT * FROM deleted FOR JSON PATH);
END
GO

-- ===================================================
-- TRIGGER 4 (INSTEAD OF DELETE): Soft delete en Doctores
-- ===================================================
CREATE OR ALTER TRIGGER trg_Doctores_SoftDelete
ON Doctores
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE Doctores
    SET Estado = 0
    FROM Doctores d
    INNER JOIN deleted del ON d.ID = del.ID;
    
    INSERT INTO LOG_AUDITORIA (TablaAfectada, TipoOperacion, UsuarioOperacion, DatosAnteriores)
    SELECT 'Doctores', 'SOFT_DELETE', SYSTEM_USER, (SELECT * FROM deleted FOR JSON PATH);
END
GO

-- ===================================================
-- TRIGGER 5 (AFTER INSERT): Validación de citas duplicadas
-- ===================================================
CREATE OR ALTER TRIGGER trg_Citas_ValidarDuplicadas
ON Citas
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que no haya dos citas del mismo doctor en la misma fecha/hora
    IF EXISTS (
        SELECT 1
        FROM Citas c1
        INNER JOIN inserted i ON c1.doctor_id = i.doctor_id 
                               AND c1.fecha = i.fecha 
                               AND c1.hora = i.hora
                               AND c1.ID != i.ID
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('El doctor ya tiene una cita a esa fecha y hora', 16, 1);
        RETURN;
    END
    
    -- Validar que el paciente no tenga citas a la misma fecha/hora
    IF EXISTS (
        SELECT 1
        FROM Citas c1
        INNER JOIN inserted i ON c1.paciente_id = i.paciente_id 
                               AND c1.fecha = i.fecha 
                               AND c1.hora = i.hora
                               AND c1.ID != i.ID
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('El paciente ya tiene una cita a esa fecha y hora', 16, 1);
        RETURN;
    END
END
GO

-- ===================================================
-- TRIGGER 6 (AFTER INSERT): Validación de diagnósticos
-- ===================================================
CREATE OR ALTER TRIGGER trg_Diagnosticos_Validacion
ON Diagnosticos
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar que no haya dos diagnósticos para la misma cita
    IF EXISTS (
        SELECT 1
        FROM Diagnosticos d1
        INNER JOIN inserted i ON d1.cita_id = i.cita_id
        WHERE d1.ID != i.ID
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('Esta cita ya tiene un diagnóstico registrado', 16, 1);
        RETURN;
    END
    
    -- Cambiar estado de cita a Completada
    UPDATE Citas
    SET estado = 'Completada'
    FROM Citas c
    INNER JOIN inserted i ON c.ID = i.cita_id;
END
GO

-- ===================================================
-- TRIGGER 7 (AFTER INSERT, UPDATE, DELETE): Auditoría en Diagnosticos
-- ===================================================
CREATE OR ALTER TRIGGER trg_Diagnosticos_Auditoria
ON Diagnosticos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Operacion VARCHAR(10);
    DECLARE @DatosAnteriores NVARCHAR(MAX);
    DECLARE @DatosNuevos NVARCHAR(MAX);
    
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
        SET @Operacion = 'UPDATE'
    ELSE IF EXISTS (SELECT * FROM inserted)
        SET @Operacion = 'INSERT'
    ELSE
        SET @Operacion = 'DELETE';
    
    IF EXISTS (SELECT * FROM deleted)
        SELECT @DatosAnteriores = (SELECT * FROM deleted FOR JSON PATH);
    
    IF EXISTS (SELECT * FROM inserted)
        SELECT @DatosNuevos = (SELECT * FROM inserted FOR JSON PATH);
    
    INSERT INTO LOG_AUDITORIA (TablaAfectada, TipoOperacion, UsuarioOperacion, DatosAnteriores, DatosNuevos)
    VALUES ('Diagnosticos', @Operacion, SYSTEM_USER, @DatosAnteriores, @DatosNuevos);
END
GO

PRINT '✓ Triggers creados exitosamente';
PRINT '  - Auditoría en Pacientes, Citas y Diagnósticos';
PRINT '  - Soft delete en Pacientes y Doctores';
PRINT '  - Validación de citas duplicadas';
PRINT '  - Validación de diagnósticos únicos por cita';
GO