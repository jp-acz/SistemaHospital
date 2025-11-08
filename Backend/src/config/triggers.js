const { executeRun } = require('./database');

// Trigger 1: Auditoría de pacientes eliminados
const TRIGGER_AUDITORIA_PACIENTES = `
  CREATE TRIGGER IF NOT EXISTS trigger_auditoria_pacientes
  AFTER UPDATE OF Estado ON Pacientes
  FOR EACH ROW
  WHEN OLD.Estado = 1 AND NEW.Estado = 0
  BEGIN
    INSERT INTO AuditoriaEliminar (tabla, registro_id, datos_antiguos, fecha)
    VALUES ('Pacientes', NEW.ID, 
      'Nombre: ' || OLD.nombre || ', Edad: ' || OLD.edad, 
      datetime('now')
    );
  END
`;

// Trigger 2: Validación de citas
const TRIGGER_VALIDACION_CITAS = `
  CREATE TRIGGER IF NOT EXISTS trigger_validacion_citas
  BEFORE INSERT ON Citas
  FOR EACH ROW
  WHEN (
    SELECT COUNT(*) FROM Citas 
    WHERE doctor_id = NEW.doctor_id 
    AND fecha = NEW.fecha 
    AND hora = NEW.hora
  ) > 0
  BEGIN
    SELECT RAISE(FAIL, 'El doctor ya tiene una cita a esa hora');
  END
`;

// Procedimiento 1: Listar citas de un doctor
const PROC_CITAS_DOCTOR = `
  -- Para SQLite (no tiene PROCEDURE, usamos vistas + functions)
  CREATE VIEW IF NOT EXISTS vw_citas_doctor AS
  SELECT 
    d.ID as doctor_id,
    d.nombre as doctor_nombre,
    COUNT(c.ID) as total_citas,
    GROUP_CONCAT(p.nombre, ', ') as pacientes
  FROM Doctores d
  LEFT JOIN Citas c ON d.ID = c.doctor_id
  LEFT JOIN Pacientes p ON c.paciente_id = p.ID
  GROUP BY d.ID
`;

// Procedimiento 2: Crear cita (con validación)
async function crearCitaConValidacion(paciente_id, doctor_id, fecha, hora) {
  try {
    // Validar que no haya cita duplicada
    const { executeQuery } = require('./database');
    const existe = await executeQuery(
      'SELECT ID FROM Citas WHERE doctor_id = ? AND fecha = ? AND hora = ?',
      [doctor_id, fecha, hora]
    );
    
    if (existe.length > 0) {
      throw new Error('El doctor ya tiene una cita a esa hora');
    }

    // Validar paciente
    const paciente = await executeQuery(
      'SELECT ID FROM Pacientes WHERE ID = ? AND Estado = 1',
      [paciente_id]
    );
    
    if (paciente.length === 0) {
      throw new Error('Paciente inválido');
    }

    // Crear cita
    const { executeRun } = require('./database');
    const result = await executeRun(
      'INSERT INTO Citas (paciente_id, doctor_id, fecha, hora) VALUES (?, ?, ?, ?)',
      [paciente_id, doctor_id, fecha, hora]
    );

    return {
      success: true,
      cita_id: result.lastID,
      message: 'Cita creada exitosamente'
    };
  } catch (error) {
    return {
      success: false,
      error: error.message
    };
  }
}

module.exports = {
  TRIGGER_AUDITORIA_PACIENTES,
  TRIGGER_VALIDACION_CITAS,
  PROC_CITAS_DOCTOR,
  crearCitaConValidacion
};
