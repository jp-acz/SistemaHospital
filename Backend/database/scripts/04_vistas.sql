-- database/scripts/04_vistas_hospital.sql
-- Vistas avanzadas con JOINs, subconsultas y funciones de ventana

USE HospitalDB;
GO

-- ===================================================
-- VISTA 1: Citas con información completa (INNER JOIN)
-- ===================================================
CREATE OR ALTER VIEW vw_CitasCompletas AS
SELECT 
    c.ID AS CitaID,
    p.ID AS PacienteID,
    p.nombre AS PacienteNombre,
    d.ID AS DoctorID,
    d.nombre AS DoctorNombre,
    d.especialidad,
    c.fecha,
    c.hora,
    CONCAT(c.fecha, ' ', c.hora) AS FechaHora,
    c.estado,
    c.motivo
FROM Citas c
INNER JOIN Pacientes p ON c.paciente_id = p.ID
INNER JOIN Doctores d ON c.doctor_id = d.ID;
GO

-- ===================================================
-- VISTA 2: Diagnósticos con detalles (INNER JOIN múltiple)
-- ===================================================
CREATE OR ALTER VIEW vw_DiagnosticosCompletos AS
SELECT 
    diag.ID AS DiagnosticoID,
    c.ID AS CitaID,
    p.nombre AS PacienteNombre,
    d.nombre AS DoctorNombre,
    d.especialidad,
    c.fecha,
    diag.diagnostico,
    diag.tratamiento,
    diag.medicamentos,
    diag.recomendaciones,
    diag.FechaRegistro
FROM Diagnosticos diag
INNER JOIN Citas c ON diag.cita_id = c.ID
INNER JOIN Pacientes p ON c.paciente_id = p.ID
INNER JOIN Doctores d ON c.doctor_id = d.ID;
GO

-- ===================================================
-- VISTA 3: Pacientes con seguro (LEFT JOIN)
-- ===================================================
CREATE OR ALTER VIEW vw_PacientesConSeguro AS
SELECT 
    p.ID,
    p.nombre AS PacienteNombre,
    p.edad,
    p.telefono,
    ISNULL(s.tipo, 'Sin Seguro') AS TipoSeguro,
    ISNULL(s.compañia, 'N/A') AS CompañiaSeguro,
    ISNULL(s.numeroPoliza, 'N/A') AS NumeroPoliza,
    COUNT(c.ID) AS TotalCitas
FROM Pacientes p
LEFT JOIN Seguros s ON p.ID = s.id_paciente AND s.estado = 1
LEFT JOIN Citas c ON p.ID = c.paciente_id
WHERE p.Estado = 1
GROUP BY p.ID, p.nombre, p.edad, p.telefono, s.tipo, s.compañia, s.numeroPoliza;
GO

-- ===================================================
-- VISTA 4: Citas pendientes (subconsulta correlacionada)
-- ===================================================
CREATE OR ALTER VIEW vw_CitasPendientes AS
SELECT 
    p.ID AS PacienteID,
    p.nombre AS PacienteNombre,
    (SELECT COUNT(*) FROM Citas WHERE paciente_id = p.ID AND estado = 'Programada') AS CitasProgramadas,
    (SELECT TOP 1 fecha FROM Citas WHERE paciente_id = p.ID AND estado = 'Programada' ORDER BY fecha) AS ProxCita,
    (SELECT TOP 1 d.nombre FROM Citas c
     INNER JOIN Doctores d ON c.doctor_id = d.ID
     WHERE c.paciente_id = p.ID AND c.estado = 'Programada'
     ORDER BY c.fecha) AS ProxDoctor
FROM Pacientes p
WHERE p.Estado = 1
AND EXISTS (SELECT 1 FROM Citas WHERE paciente_id = p.ID AND estado = 'Programada');
GO

-- ===================================================
-- VISTA 5: Ranking de especialidades (Función de ventana)
-- ===================================================
CREATE OR ALTER VIEW vw_RankingEspecialidades AS
SELECT 
    d.especialidad,
    COUNT(c.ID) AS TotalCitas,
    COUNT(DISTINCT c.paciente_id) AS TotalPacientes,
    AVG(p.edad) AS EdadPromedioPacientes,
    ROW_NUMBER() OVER (ORDER BY COUNT(c.ID) DESC) AS RankingCitas,
    RANK() OVER (ORDER BY COUNT(DISTINCT c.paciente_id) DESC) AS RankingPacientes,
    PERCENT_RANK() OVER (ORDER BY COUNT(c.ID) DESC) AS PercentilCitas
FROM Doctores d
LEFT JOIN Citas c ON d.ID = c.doctor_id
LEFT JOIN Pacientes p ON c.paciente_id = p.ID
WHERE d.Estado = 1
GROUP BY d.especialidad;
GO

-- ===================================================
-- VISTA 6: Actividad mensual con funciones de ventana
-- ===================================================
CREATE OR ALTER VIEW vw_ActividadMensual AS
SELECT 
    YEAR(c.fecha) AS Anio,
    MONTH(c.fecha) AS Mes,
    DATENAME(MONTH, c.fecha) AS NombreMes,
    COUNT(c.ID) AS TotalCitas,
    COUNT(DISTINCT c.paciente_id) AS PacientesAtendidos,
    COUNT(DISTINCT c.doctor_id) AS DoctoresActivos,
    SUM(COUNT(c.ID)) OVER (PARTITION BY YEAR(c.fecha) ORDER BY MONTH(c.fecha)) AS AcumuladoAnio,
    LAG(COUNT(c.ID)) OVER (ORDER BY YEAR(c.fecha), MONTH(c.fecha)) AS CitasMesAnterior,
    LEAD(COUNT(c.ID)) OVER (ORDER BY YEAR(c.fecha), MONTH(c.fecha)) AS CitasMesSiguiente
FROM Citas c
GROUP BY YEAR(c.fecha), MONTH(c.fecha), DATENAME(MONTH, c.fecha);
GO

-- ===================================================
-- VISTA 7: Pacientes por rango de edad (Función de ventana)
-- ===================================================
CREATE OR ALTER VIEW vw_PacientesPorEdad AS
SELECT 
    CASE 
        WHEN edad < 18 THEN 'Menor de edad'
        WHEN edad BETWEEN 18 AND 30 THEN '18-30 años'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45 años'
        WHEN edad BETWEEN 46 AND 60 THEN '46-60 años'
        ELSE 'Mayor de 60'
    END AS RangoEdad,
    COUNT(*) AS TotalPacientes,
    AVG(edad) AS EdadPromedio,
    MIN(edad) AS EdadMinima,
    MAX(edad) AS EdadMaxima,
    ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) AS RankingPorCantidad
FROM Pacientes
WHERE Estado = 1
GROUP BY 
    CASE 
        WHEN edad < 18 THEN 'Menor de edad'
        WHEN edad BETWEEN 18 AND 30 THEN '18-30 años'
        WHEN edad BETWEEN 31 AND 45 THEN '31-45 años'
        WHEN edad BETWEEN 46 AND 60 THEN '46-60 años'
        ELSE 'Mayor de 60'
    END;
GO

-- ===================================================
-- CTE: Top Doctores por cantidad de citas
-- ===================================================
CREATE OR ALTER PROCEDURE sp_TopDoctoresPorCitas
    @TopN INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH DoctoresConCitas AS (
        SELECT 
            d.ID,
            d.nombre,
            d.especialidad,
            COUNT(c.ID) AS TotalCitas,
            COUNT(DISTINCT c.paciente_id) AS TotalPacientes,
            MAX(c.fecha) AS UltimaCita
        FROM Doctores d
        LEFT JOIN Citas c ON d.ID = c.doctor_id
        WHERE d.Estado = 1
        GROUP BY d.ID, d.nombre, d.especialidad
    ),
    DoctoresRankeados AS (
        SELECT 
            *,
            ROW_NUMBER() OVER (ORDER BY TotalCitas DESC) AS Ranking
        FROM DoctoresConCitas
    )
    SELECT TOP (@TopN)
        Ranking,
        nombre,
        especialidad,
        TotalCitas,
        TotalPacientes,
        UltimaCita
    FROM DoctoresRankeados
    ORDER BY Ranking;
END
GO

-- ===================================================
-- CTE: Pacientes con historial completo
-- ===================================================
CREATE OR ALTER PROCEDURE sp_HistorialPaciente
    @paciente_id INT
AS
BEGIN
    SET NOCOUNT ON;
    
    WITH HistorialCitas AS (
        SELECT 
            c.ID AS CitaID,
            c.fecha,
            c.hora,
            d.nombre AS DoctorNombre,
            d.especialidad,
            c.motivo,
            c.estado,
            ROW_NUMBER() OVER (ORDER BY c.fecha DESC) AS NumCita
        FROM Citas c
        INNER JOIN Doctores d ON c.doctor_id = d.ID
        WHERE c.paciente_id = @paciente_id
    ),
    DiagnosticosRecientes AS (
        SELECT 
            diag.cita_id,
            diag.diagnostico,
            diag.tratamiento,
            ROW_NUMBER() OVER (ORDER BY diag.FechaRegistro DESC) AS NumDiagnostico
        FROM Diagnosticos diag
        WHERE diag.cita_id IN (SELECT CitaID FROM HistorialCitas)
    )
    SELECT 
        p.nombre AS PacienteNombre,
        p.edad,
        p.direccion,
        p.telefono,
        hc.NumCita,
        hc.CitaID,
        hc.fecha,
        hc.hora,
        hc.DoctorNombre,
        hc.especialidad,
        hc.motivo,
        hc.estado,
        dr.diagnostico,
        dr.tratamiento
    FROM Pacientes p
    LEFT JOIN HistorialCitas hc ON p.ID = @paciente_id
    LEFT JOIN DiagnosticosRecientes dr ON hc.CitaID = dr.cita_id AND dr.NumDiagnostico = 1
    WHERE p.ID = @paciente_id
    ORDER BY hc.NumCita;
END
GO

PRINT '✓ Vistas y consultas avanzadas creadas exitosamente';
GO