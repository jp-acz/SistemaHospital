-- ========================================
-- TRIGGERS - Cumpliendo requisito 6
-- ========================================
USE HospitalDB;
GO

PRINT '🔔 Creando triggers...';
GO

-- =============================================
-- Verificar y ajustar tabla de auditoría
-- =============================================
IF EXISTS (SELECT 1 FROM sys.columns 
           WHERE object_id = OBJECT_ID('AuditoriaEliminar') 
           AND name = 'fechaEliminacion')
BEGIN
    PRINT '✓ Tabla AuditoriaEliminar ya tiene la columna correcta';
END
ELSE
BEGIN
    -- Si la tabla existe con nombre diferente de columna, DROP y recrear
    IF OBJECT_ID('AuditoriaEliminar', 'U') IS NOT NULL
    BEGIN
        DROP TABLE AuditoriaEliminar;
        PRINT '⚠️  Tabla AuditoriaEliminar eliminada para recreación';
    END
    
    CREATE TABLE AuditoriaEliminar (
        ID INT PRIMARY KEY IDENTITY(1,1),
        tabla VARCHAR(50) NOT NULL,
        registroID INT NOT NULL,
        usuario VARCHAR(100) DEFAULT SYSTEM_USER,
        fechaEliminacion DATETIME DEFAULT GETDATE()
    );
    PRINT '✓ Tabla AuditoriaEliminar creada correctamente';
END
GO

-- =============================================
-- TRIGGER 1: Auditoría de eliminaciones (AFTER DELETE)
-- Requisito 6.1: Trigger de auditoría
-- =============================================

-- Trigger para Pacientes
CREATE OR ALTER TRIGGER trg_Pacientes_AuditDelete
ON Pacientes
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO AuditoriaEliminar (tabla, registroID, usuario, fechaEliminacion)
    SELECT 
        'Pacientes',
        d.ID,
        SYSTEM_USER,
        GETDATE()
    FROM DELETED d;
    
    PRINT 'Trigger: Paciente(s) eliminado(s) - Auditoría registrada';
END
GO

-- Trigger para Doctores
CREATE OR ALTER TRIGGER trg_Doctores_AuditDelete
ON Doctores
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO AuditoriaEliminar (tabla, registroID, usuario, fechaEliminacion)
    SELECT 
        'Doctores',
        d.ID,
        SYSTEM_USER,
        GETDATE()
    FROM DELETED d;
    
    PRINT 'Trigger: Doctor(es) eliminado(s) - Auditoría registrada';
END
GO

-- Trigger para Citas
CREATE OR ALTER TRIGGER trg_Citas_AuditDelete
ON Citas
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    INSERT INTO AuditoriaEliminar (tabla, registroID, usuario, fechaEliminacion)
    SELECT 
        'Citas',
        d.ID,
        SYSTEM_USER,
        GETDATE()
    FROM DELETED d;
    
    PRINT 'Trigger: Cita(s) eliminada(s) - Auditoría registrada';
END
GO

-- =============================================
-- TRIGGER 2: Validación de datos (INSTEAD OF INSERT)
-- Requisito 6.2: Trigger de validación
-- =============================================

CREATE OR ALTER TRIGGER trg_Pacientes_ValidateInsert
ON Pacientes
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar edad
    IF EXISTS (SELECT 1 FROM INSERTED WHERE edad < 0 OR edad > 150)
    BEGIN
        RAISERROR('Trigger: Edad inválida (debe estar entre 0 y 150)', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Validar nombre no vacío
    IF EXISTS (SELECT 1 FROM INSERTED WHERE LTRIM(RTRIM(nombre)) = '')
    BEGIN
        RAISERROR('Trigger: Nombre no puede estar vacío', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Si validación OK, insertar
    INSERT INTO Pacientes (nombre, edad, direccion, telefono)
    SELECT nombre, edad, direccion, telefono
    FROM INSERTED;
    
    PRINT 'Trigger: Paciente insertado después de validación';
END
GO

-- =============================================
-- TRIGGER 3: Auditoría de actualizaciones (AFTER UPDATE)
-- =============================================

-- Crear tabla de auditoría de actualizaciones si no existe
IF OBJECT_ID('AuditoriaActualizaciones', 'U') IS NULL
BEGIN
    CREATE TABLE AuditoriaActualizaciones (
        ID INT PRIMARY KEY IDENTITY(1,1),
        tabla VARCHAR(50) NOT NULL,
        registroID INT NOT NULL,
        campoModificado VARCHAR(100),
        valorAnterior VARCHAR(500),
        valorNuevo VARCHAR(500),
        usuario VARCHAR(100) DEFAULT SYSTEM_USER,
        fechaModificacion DATETIME DEFAULT GETDATE()
    );
    PRINT '✓ Tabla AuditoriaActualizaciones creada';
END
GO

CREATE OR ALTER TRIGGER trg_Doctores_AuditUpdate
ON Doctores
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Auditar cambio de especialidad
    IF UPDATE(especialidad)
    BEGIN
        INSERT INTO AuditoriaActualizaciones (tabla, registroID, campoModificado, valorAnterior, valorNuevo)
        SELECT 
            'Doctores',
            i.ID,
            'especialidad',
            d.especialidad,
            i.especialidad
        FROM INSERTED i
        INNER JOIN DELETED d ON i.ID = d.ID
        WHERE i.especialidad <> d.especialidad;
    END
    
    PRINT 'Trigger: Actualización de doctor auditada';
END
GO

-- =============================================
-- TRIGGER 4: Validación de citas (INSTEAD OF INSERT)
-- Requisito 6.2: Evita citas en fechas pasadas
-- =============================================

CREATE OR ALTER TRIGGER trg_Citas_ValidateFecha
ON Citas
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Validar fecha no en el pasado (solo validar fecha, no hora)
    IF EXISTS (SELECT 1 FROM INSERTED WHERE CAST(fecha AS DATE) < CAST(GETDATE() AS DATE))
    BEGIN
        RAISERROR('Trigger: No se pueden crear citas en fechas pasadas', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Validar que existan paciente y doctor
    IF EXISTS (SELECT 1 FROM INSERTED WHERE paciente_id NOT IN (SELECT ID FROM Pacientes))
    BEGIN
        RAISERROR('Trigger: Paciente no existe', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    IF EXISTS (SELECT 1 FROM INSERTED WHERE doctor_id NOT IN (SELECT ID FROM Doctores))
    BEGIN
        RAISERROR('Trigger: Doctor no existe', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
    
    -- Si validación OK, insertar
    INSERT INTO Citas (paciente_id, doctor_id, fecha)
    SELECT paciente_id, doctor_id, fecha
    FROM INSERTED;
    
    PRINT 'Trigger: Cita insertada después de validación';
END
GO

PRINT '✓ Todos los triggers creados correctamente';
GO

-- =============================================
-- DOCUMENTACIÓN DE TRIGGERS
-- =============================================
PRINT '';
PRINT '📖 DOCUMENTACIÓN DE TRIGGERS:';
PRINT '';
PRINT '1. trg_Pacientes_AuditDelete (AFTER DELETE)';
PRINT '   - Registra eliminaciones en AuditoriaEliminar';
PRINT '   - Usa tabla virtual DELETED';
PRINT '';
PRINT '2. trg_Doctores_AuditDelete (AFTER DELETE)';
PRINT '   - Auditoría de eliminación de doctores';
PRINT '';
PRINT '3. trg_Citas_AuditDelete (AFTER DELETE)';
PRINT '   - Auditoría de eliminación de citas';
PRINT '';
PRINT '4. trg_Pacientes_ValidateInsert (INSTEAD OF INSERT)';
PRINT '   - Valida edad (0-150) y nombre no vacío';
PRINT '   - Usa tabla virtual INSERTED';
PRINT '';
PRINT '5. trg_Doctores_AuditUpdate (AFTER UPDATE)';
PRINT '   - Registra cambios de especialidad';
PRINT '   - Compara INSERTED vs DELETED';
PRINT '';
PRINT '6. trg_Citas_ValidateFecha (INSTEAD OF INSERT)';
PRINT '   - Evita citas en fechas pasadas';
PRINT '   - Valida existencia de paciente y doctor';
PRINT '';
GO
