const express = require('express');
const router = express.Router();
const { executeQuery } = require('../config/database');

// Consulta 1: Pacientes con Citas (INNER JOIN)
router.get('/pacientes-citas', async (req, res) => {
    try {
        const data = await executeQuery('SELECT * FROM vw_PacientesCitas ORDER BY fecha DESC');
        res.json({
            success: true,
            titulo: 'Pacientes con Citas (INNER JOIN)',
            descripcion: 'Vista de pacientes con sus citas y doctores',
            data
        });
    } catch (error) {
        console.error('Error en /pacientes-citas:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Consulta 2: Estadísticas de Doctores (GROUP BY)
router.get('/doctores-estadisticas', async (req, res) => {
    try {
        const data = await executeQuery('SELECT * FROM vw_DoctoresEstadisticas ORDER BY TotalCitas DESC');
        res.json({
            success: true,
            titulo: 'Estadísticas de Doctores (GROUP BY)',
            descripcion: 'Resumen de citas por doctor',
            data
        });
    } catch (error) {
        console.error('Error en /doctores-estadisticas:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Consulta 3: Pacientes sin Citas (Subconsulta NOT IN)
router.get('/pacientes-sin-citas', async (req, res) => {
    try {
        const data = await executeQuery('SELECT * FROM vw_PacientesSinCitas');
        res.json({
            success: true,
            titulo: 'Pacientes sin Citas (Subconsulta NOT IN)',
            descripcion: 'Pacientes que no tienen citas programadas',
            data
        });
    } catch (error) {
        console.error('Error en /pacientes-sin-citas:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Consulta 4: Citas Próximas (Fecha Futura)
router.get('/citas-proximas', async (req, res) => {
    try {
        const data = await executeQuery('SELECT * FROM vw_CitasProximas ORDER BY fecha ASC');
        res.json({
            success: true,
            titulo: 'Citas Próximas (Fecha Futura)',
            descripcion: 'Citas programadas para fechas futuras',
            data
        });
    } catch (error) {
        console.error('Error en /citas-proximas:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Consulta 5: Diagnósticos por Especialidad (GROUP BY)
router.get('/diagnosticos-especialidad', async (req, res) => {
    try {
        const data = await executeQuery('SELECT * FROM vw_DiagnosticosPorEspecialidad ORDER BY especialidad, TotalDiagnosticos DESC');
        res.json({
            success: true,
            titulo: 'Diagnósticos por Especialidad (GROUP BY)',
            descripcion: 'Frecuencia de diagnósticos agrupados por especialidad',
            data
        });
    } catch (error) {
        console.error('Error en /diagnosticos-especialidad:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Consulta 6: Diagnósticos Completos (INNER JOIN múltiple)
router.get('/diagnosticos-completos', async (req, res) => {
    try {
        const data = await executeQuery('SELECT * FROM vw_DiagnosticosCompletos ORDER BY FechaCita DESC');
        res.json({
            success: true,
            titulo: 'Diagnósticos Completos (INNER JOIN)',
            descripcion: 'Información detallada de diagnósticos con pacientes y doctores',
            data
        });
    } catch (error) {
        console.error('Error en /diagnosticos-completos:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

// Consulta 7: Seguros Activos (INNER JOIN)
router.get('/seguros-activos', async (req, res) => {
    try {
        const data = await executeQuery('SELECT * FROM vw_SegurosActivos ORDER BY PacienteNombre');
        res.json({
            success: true,
            titulo: 'Seguros Activos (INNER JOIN)',
            descripcion: 'Pacientes con seguro médico activo',
            data
        });
    } catch (error) {
        console.error('Error en /seguros-activos:', error);
        res.status(500).json({ success: false, error: error.message });
    }
});

module.exports = router;
