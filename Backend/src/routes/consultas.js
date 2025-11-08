const express = require('express');
const router = express.Router();
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, '../../database/hospital.db');

function executeQuery(sql) {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(dbPath);
    db.all(sql, (err, rows) => {
      db.close();
      if (err) reject(err);
      else resolve(rows || []);
    });
  });
}

// Vista 1: Pacientes con citas
router.get('/pacientes-citas', async (req, res) => {
  try {
    const sql = `SELECT p.ID, p.nombre, p.edad, d.nombre as doctor, d.especialidad, c.fecha, c.hora 
                 FROM Pacientes p 
                 INNER JOIN Citas c ON p.ID = c.paciente_id 
                 INNER JOIN Doctores d ON c.doctor_id = d.ID`;
    const data = await executeQuery(sql);
    res.json({
      success: true,
      titulo: 'Pacientes con Citas (INNER JOIN)',
      descripcion: 'Unión de pacientes, citas y doctores',
      data: data
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Vista 2: Doctores estadísticas
router.get('/doctores-estadisticas', async (req, res) => {
  try {
    const sql = `SELECT d.ID, d.nombre, d.especialidad, COUNT(c.ID) as total_citas 
                 FROM Doctores d 
                 LEFT JOIN Citas c ON d.ID = c.doctor_id 
                 GROUP BY d.ID`;
    const data = await executeQuery(sql);
    res.json({
      success: true,
      titulo: 'Estadísticas de Doctores (GROUP BY)',
      descripcion: 'Cantidad de citas por doctor',
      data: data
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Vista 3: Pacientes sin citas
router.get('/pacientes-sin-citas', async (req, res) => {
  try {
    const sql = `SELECT p.ID, p.nombre, p.edad 
                 FROM Pacientes p 
                 WHERE p.ID NOT IN (SELECT DISTINCT paciente_id FROM Citas)`;
    const data = await executeQuery(sql);
    res.json({
      success: true,
      titulo: 'Pacientes sin Citas (Subconsulta NOT IN)',
      descripcion: 'Pacientes que no tienen citas asignadas',
      data: data
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Vista 4: Citas próximas
router.get('/citas-proximas', async (req, res) => {
  try {
    const sql = `SELECT c.ID, p.nombre as paciente, d.nombre as doctor, c.fecha, c.hora 
                 FROM Citas c 
                 INNER JOIN Pacientes p ON c.paciente_id = p.ID 
                 INNER JOIN Doctores d ON c.doctor_id = d.ID 
                 ORDER BY c.fecha LIMIT 10`;
    const data = await executeQuery(sql);
    res.json({
      success: true,
      titulo: 'Citas Próximas (ORDER BY)',
      descripcion: 'Ultimas 10 citas programadas',
      data: data
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// Vista 5: Diagnósticos por especialidad
router.get('/diagnosticos-especialidad', async (req, res) => {
  try {
    const sql = `SELECT d.especialidad, dg.diagnostico, COUNT(*) as cantidad 
                 FROM Diagnosticos dg 
                 INNER JOIN Citas c ON dg.cita_id = c.ID 
                 INNER JOIN Doctores d ON c.doctor_id = d.ID 
                 GROUP BY d.especialidad, dg.diagnostico`;
    const data = await executeQuery(sql);
    res.json({
      success: true,
      titulo: 'Diagnósticos por Especialidad (GROUP BY)',
      descripcion: 'Diagnósticos agrupados por tipo de especialidad',
      data: data
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
