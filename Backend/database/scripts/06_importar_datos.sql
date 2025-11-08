-- database/scripts/06_importar_datos_hospital.sql
-- Script para importar datos desde archivos CSV en el sistema hospitalario

USE HospitalDB;
GO

PRINT '';
PRINT '═════════════════════════════════════════════════════════════';
PRINT 'INICIANDO IMPORTACIÓN DE DATOS DESDE CSV';
PRINT '═════════════════════════════════════════════════════════════';
PRINT '';

-- ===================================================
-- PASO 1: IMPORTAR PACIENTES
-- ===================================================

-- NOTA: Cambiar la ruta según la ubicación de los archivos CSV
-- Ejemplo: C:\tu_proyecto\database\data\pacientes.csv

BULK INSERT Pacientes (ID, nombre, edad, direccion, telefono)
FROM 'C:\database\data\pacientes.csv'
WITH
(
    FIRSTROW = 2,           -- Omite la cabecera
    FIELDTERMINATOR = ',',  -- Delimitador: coma
    ROWTERMINATOR = '\n',   -- Salto de línea
    CODEPAGE = '65001',     -- UTF-8
    TABLOCK
);

PRINT '✓ Pacientes importados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros';

-- ===================================================
-- PASO 2: IMPORTAR DOCTORES
-- ===================================================

BULK INSERT Doctores (ID, nombre, especialidad, telefono)
FROM 'C:\database\data\doctores.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

PRINT '✓ Doctores importados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros';

-- ===================================================
-- PASO 3: IMPORTAR CITAS
-- ===================================================

BULK INSERT Citas (ID, paciente_id, doctor_id, fecha, hora)
FROM 'C:\database\data\citas.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

PRINT '✓ Citas importadas: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros';

-- ===================================================
-- PASO 4: IMPORTAR DIAGNÓSTICOS
-- ===================================================

BULK INSERT Diagnosticos (ID, cita_id, diagnóstico, tratamiento)
FROM 'C:\database\data\diagnosticos.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

PRINT '✓ Diagnósticos importados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros';

-- ===================================================
-- PASO 5: IMPORTAR SEGUROS
-- ===================================================

BULK INSERT Seguros (id_seguro, tipo, compañia, id_paciente)
FROM 'C:\database\data\seguros.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

PRINT '✓ Seguros importados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros';

-- ===================================================
-- VERIFICACIÓN DE IMPORTACIÓN
-- ===================================================

PRINT '';
PRINT '═════════════════════════════════════════════════════════════';
PRINT 'RESUMEN DE IMPORTACIÓN';
PRINT '═════════════════════════════════════════════════════════════';

SELECT 'Pacientes' AS Tabla, COUNT(*) AS TotalRegistros FROM Pacientes
UNION ALL
SELECT 'Doctores', COUNT(*) FROM Doctores
UNION ALL
SELECT 'Citas', COUNT(*) FROM Citas
UNION ALL
SELECT 'Diagnósticos', COUNT(*) FROM Diagnosticos
UNION ALL
SELECT 'Seguros', COUNT(*) FROM Seguros;

PRINT '';
PRINT '✓ Importación completada exitosamente';
PRINT '';

-- ===================================================
-- CONSULTAS DE VERIFICACIÓN (descomentar si necesitas)
-- ===================================================

/*
-- Verificar que se importaron correctamente
SELECT * FROM Pacientes;
SELECT * FROM Doctores;
SELECT * FROM Citas;
SELECT * FROM Diagnosticos;
SELECT * FROM Seguros;

-- Ver distribución de citas por especialidad
SELECT d.especialidad, COUNT(c.ID) AS TotalCitas
FROM Citas c
INNER JOIN Doctores d ON c.doctor_id = d.ID
GROUP BY d.especialidad;

-- Ver pacientes con sus seguros
SELECT p.nombre AS Paciente, s.tipo AS TipoSeguro, s.compañia
FROM Pacientes p
LEFT JOIN Seguros s ON p.ID = s.id_paciente;
*/