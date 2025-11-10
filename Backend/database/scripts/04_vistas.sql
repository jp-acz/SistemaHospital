-- ========================================
-- VISTAS Y CONSULTAS AVANZADAS
-- Cumpliendo requisitos 4 y 5
-- ========================================
USE HospitalDB;
GO

PRINT '📊 Creando vistas y consultas avanzadas...';
GO

-- =============================================
-- VISTA 1: Pacientes con Citas (INNER JOIN)
-- Requisito 4a: Usa INNER JOIN
-- =============================================
CREATE OR ALTER VIEW vw_PacientesCitas AS
SELECT 
    p.ID AS PacienteID,
    p.nombre AS PacienteNombre,
    p.edad,
    c.ID AS CitaID,
    c.fecha,
    d.nombre AS DoctorNombre,
    d.especialidad
FROM Pacientes p
INNER JOIN Citas c ON p.ID = c.paciente_id
INNER JOIN Doctores d ON c.doctor_id = d.ID;
GO

-- =============================================
-- VISTA 2: Doctores con Estadísticas (LEFT JOIN + GROUP BY)
-- Requisito 4a: Usa LEFT JOIN
-- Requisito 5a: Usa funciones de agregación
-- =============================================
CREATE OR ALTER VIEW vw_DoctoresEstadisticas AS
SELECT 
    d.ID AS DoctorID,
    d.nombre AS DoctorNombre,
    d.especialidad,
    COUNT(c.ID) AS TotalCitas,
    COUNT(DISTINCT c.paciente_id) AS PacientesUnicos
FROM Doctores d
LEFT JOIN Citas c ON d.ID = c.doctor_id
GROUP BY d.ID, d.nombre, d.especialidad;
GO

-- =============================================
-- VISTA 3: Pacientes sin Citas (Subconsulta en WHERE - NOT IN)
-- Requisito 4b: Subconsulta tipo 1 (NOT IN)
-- =============================================
CREATE OR ALTER VIEW vw_PacientesSinCitas AS
SELECT 
    ID, 
    nombre, 
    edad,
    direccion, 
    telefono
FROM Pacientes
WHERE ID NOT IN (
    SELECT DISTINCT paciente_id 
    FROM Citas 
    WHERE paciente_id IS NOT NULL
);
GO

-- =============================================
-- VISTA 4: Doctores más solicitados (Subconsulta correlacionada)
-- Requisito 4b: Subconsulta correlacionada
-- =============================================
CREATE OR ALTER VIEW vw_DoctoresPopulares AS
SELECT TOP 100 PERCENT
    d.ID,
    d.nombre,
    d.especialidad,
    (SELECT COUNT(*) FROM Citas c WHERE c.doctor_id = d.ID) AS TotalCitas
FROM Doctores d
WHERE (SELECT COUNT(*) FROM Citas c WHERE c.doctor_id = d.ID) >= 1
ORDER BY TotalCitas DESC;
GO

-- =============================================
-- VISTA 5: Ranking de Pacientes (Funciones de ventana)
-- Requisito 4c: Funciones de ventana (ROW_NUMBER, RANK, DENSE_RANK)
-- Requisito 5a: Uso de ROW_NUMBER(), RANK(), DENSE_RANK()
-- =============================================
CREATE OR ALTER VIEW vw_RankingPacientes AS
SELECT 
    p.ID,
    p.nombre,
    p.edad,
    COUNT(c.ID) AS TotalCitas,
    ROW_NUMBER() OVER (ORDER BY COUNT(c.ID) DESC) AS RowNumber,
    RANK() OVER (ORDER BY COUNT(c.ID) DESC) AS Ranking,
    DENSE_RANK() OVER (ORDER BY COUNT(c.ID) DESC) AS DenseRanking
FROM Pacientes p
LEFT JOIN Citas c ON p.ID = c.paciente_id
GROUP BY p.ID, p.nombre, p.edad;
GO

-- =============================================
-- VISTA 6: Diagnósticos con acumulados (SUM OVER PARTITION BY)
-- Requisito 5a: Usa SUM() OVER(PARTITION BY ...)
-- =============================================
CREATE OR ALTER VIEW vw_DiagnosticosAcumulados AS
SELECT 
    diag.ID AS DiagnosticoID,
    p.nombre AS PacienteNombre,
    d.nombre AS DoctorNombre,
    d.especialidad,
    c.fecha AS FechaCita,
    diag.diagnostico,
    diag.tratamiento,
    COUNT(*) OVER (PARTITION BY d.especialidad) AS DiagnosticosPorEspecialidad,
    ROW_NUMBER() OVER (PARTITION BY p.ID ORDER BY c.fecha) AS NumeroConsultaPaciente
FROM Diagnosticos diag
INNER JOIN Citas c ON diag.id_cita = c.ID
INNER JOIN Pacientes p ON c.paciente_id = p.ID
INNER JOIN Doctores d ON c.doctor_id = d.ID;
GO

-- =============================================
-- VISTA 7: Citas con Seguros (LEFT JOIN múltiple)
-- Requisito 4a: Múltiples JOINs
-- =============================================
CREATE OR ALTER VIEW vw_CitasConSeguro AS
SELECT 
    c.ID AS CitaID,
    p.nombre AS PacienteNombre,
    d.nombre AS DoctorNombre,
    d.especialidad,
    c.fecha,
    s.compañia AS Seguro
FROM Citas c
INNER JOIN Pacientes p ON c.paciente_id = p.ID
INNER JOIN Doctores d ON c.doctor_id = d.ID
LEFT JOIN Seguros s ON p.ID = s.id_pac;
GO

-- =============================================
-- VISTA 8: Análisis temporal con LAG/LEAD
-- Requisito 5a: Uso de LAG() o LEAD()
-- =============================================
CREATE OR ALTER VIEW vw_AnalisisTemporal AS
SELECT 
    c.ID,
    p.nombre AS PacienteNombre,
    d.nombre AS DoctorNombre,
    c.fecha,
    LAG(c.fecha) OVER (PARTITION BY c.paciente_id ORDER BY c.fecha) AS CitaAnterior,
    LEAD(c.fecha) OVER (PARTITION BY c.paciente_id ORDER BY c.fecha) AS CitaSiguiente
FROM Citas c
INNER JOIN Pacientes p ON c.paciente_id = p.ID
INNER JOIN Doctores d ON c.doctor_id = d.ID;
GO

PRINT '✓ Vistas creadas correctamente';
GO

-- =============================================
-- CONSULTA CON CTE #1: Pacientes con múltiples citas
-- Requisito 4d: Uso de CTE
-- =============================================
PRINT '📋 Ejemplo de CTE #1: Pacientes con múltiples citas';
GO

WITH CitasPorPaciente AS (
    SELECT 
        p.ID,
        p.nombre,
        COUNT(c.ID) AS TotalCitas
    FROM Pacientes p
    LEFT JOIN Citas c ON p.ID = c.paciente_id
    GROUP BY p.ID, p.nombre
)
SELECT 
    ID,
    nombre,
    TotalCitas
FROM CitasPorPaciente
WHERE TotalCitas > 1
ORDER BY TotalCitas DESC;
GO

-- =============================================
-- CONSULTA CON CTE #2: Especialidades con mayor demanda
-- Requisito 4d: Uso de CTE anidado
-- =============================================
PRINT '📋 Ejemplo de CTE #2: Ranking de especialidades';
GO

WITH CitasPorDoctor AS (
    SELECT 
        d.ID,
        d.nombre,
        d.especialidad,
        COUNT(c.ID) AS TotalCitas
    FROM Doctores d
    LEFT JOIN Citas c ON d.ID = c.doctor_id
    GROUP BY d.ID, d.nombre, d.especialidad
),
EspecialidadesRanking AS (
    SELECT 
        especialidad,
        SUM(TotalCitas) AS CitasTotales,
        RANK() OVER (ORDER BY SUM(TotalCitas) DESC) AS Ranking
    FROM CitasPorDoctor
    GROUP BY especialidad
)
SELECT 
    especialidad,
    CitasTotales,
    Ranking
FROM EspecialidadesRanking
WHERE Ranking <= 3;
GO

-- =============================================
-- CONSULTA CON CTE #3: Análisis de diagnósticos
-- Requisito 4b: Subconsulta en FROM
-- =============================================
PRINT '📋 Ejemplo de CTE #3: Diagnósticos por doctor';
GO

WITH DiagnosticosPorDoctor AS (
    SELECT 
        d.ID AS DoctorID,
        d.nombre AS DoctorNombre,
        d.especialidad,
        COUNT(diag.ID) AS TotalDiagnosticos
    FROM Doctores d
    INNER JOIN Citas c ON d.ID = c.doctor_id
    INNER JOIN Diagnosticos diag ON c.ID = diag.id_cita
    GROUP BY d.ID, d.nombre, d.especialidad
)
SELECT 
    DoctorID,
    DoctorNombre,
    especialidad,
    TotalDiagnosticos,
    RANK() OVER (PARTITION BY especialidad ORDER BY TotalDiagnosticos DESC) AS RankingEnEspecialidad
FROM DiagnosticosPorDoctor;
GO

-- VISTA: Citas próximas (sin LIMIT, usando TOP/fecha)
CREATE OR ALTER VIEW vw_CitasProximas AS
SELECT
    c.ID         AS CitaID,
    p.nombre     AS PacienteNombre,
    d.nombre     AS DoctorNombre,
    d.especialidad,
    c.fecha
FROM Citas c
INNER JOIN Pacientes p ON p.ID = c.paciente_id
INNER JOIN Doctores  d ON d.ID = c.doctor_id
WHERE CAST(c.fecha AS date) >= CAST(GETDATE() AS date);
GO

-- VISTA: Diagnósticos por especialidad (agregación)
CREATE OR ALTER VIEW vw_DiagnosticosPorEspecialidad AS
SELECT
    d.especialidad,
    COUNT(diag.ID) AS TotalDiagnosticos
FROM Diagnosticos diag
INNER JOIN Citas c ON c.ID = diag.id_cita
INNER JOIN Doctores d ON d.ID = c.doctor_id
GROUP BY d.especialidad;
GO

-- VISTA: Diagnósticos completos (detalle)
CREATE OR ALTER VIEW vw_DiagnosticosCompletos AS
SELECT
    diag.ID        AS DiagnosticoID,
    c.ID           AS CitaID,
    p.nombre       AS PacienteNombre,
    d.nombre       AS DoctorNombre,
    d.especialidad,
    c.fecha        AS FechaCita,
    diag.diagnostico,
    diag.tratamiento
FROM Diagnosticos diag
INNER JOIN Citas c ON c.ID = diag.id_cita
INNER JOIN Pacientes p ON p.ID = c.paciente_id
INNER JOIN Doctores  d ON d.ID = c.doctor_id;
GO

-- VISTA: Seguros activos (join simple)
CREATE OR ALTER VIEW vw_SegurosActivos AS
SELECT
    s.ID        AS SeguroID,
    s.compañia,
    p.ID        AS PacienteID,
    p.nombre    AS PacienteNombre
FROM Seguros s
INNER JOIN Pacientes p ON p.ID = s.id_pac;
GO

PRINT '✓ Todas las vistas y consultas avanzadas creadas correctamente';
GO
