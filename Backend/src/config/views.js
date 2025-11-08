// Vista 1: Pacientes con sus citas asignadas
const VIEW_PACIENTES_CITAS = "SELECT p.ID as paciente_id, p.nombre as paciente_nombre, p.edad, d.nombre as doctor_nombre, d.especialidad, c.fecha, c.hora, dg.diagnostico, dg.tratamiento FROM Pacientes p INNER JOIN Citas c ON p.ID = c.paciente_id INNER JOIN Doctores d ON c.doctor_id = d.ID LEFT JOIN Diagnosticos dg ON c.ID = dg.cita_id WHERE p.Estado = 1 ORDER BY c.fecha DESC";

// Vista 2: Doctores con cantidad de pacientes
const VIEW_DOCTORES_ESTADISTICAS = "SELECT d.ID, d.nombre, d.especialidad, COUNT(DISTINCT c.paciente_id) as total_pacientes, COUNT(c.ID) as total_citas FROM Doctores d LEFT JOIN Citas c ON d.ID = c.doctor_id GROUP BY d.ID ORDER BY total_citas DESC";

// Vista 3: Pacientes sin citas
const VIEW_PACIENTES_SIN_CITAS = "SELECT p.ID, p.nombre, p.edad, p.telefono, p.direccion FROM Pacientes p WHERE p.ID NOT IN (SELECT DISTINCT paciente_id FROM Citas) AND p.Estado = 1";

// Vista 4: Citas proximas (sin window functions)
const VIEW_CITAS_PROXIMAS = "SELECT c.ID, p.nombre as paciente, d.nombre as doctor, d.especialidad, c.fecha, c.hora FROM Citas c INNER JOIN Pacientes p ON c.paciente_id = p.ID INNER JOIN Doctores d ON c.doctor_id = d.ID WHERE date(c.fecha) >= date('now') ORDER BY c.fecha ASC LIMIT 10";

// Vista 5: Diagnosticos por especialidad
const VIEW_DIAGNOSTICOS_ESPECIALIDAD = "SELECT d.especialidad, dg.diagnostico, COUNT(*) as frecuencia FROM Diagnosticos dg INNER JOIN Citas c ON dg.cita_id = c.ID INNER JOIN Doctores d ON c.doctor_id = d.ID WHERE dg.diagnostico IS NOT NULL GROUP BY d.especialidad, dg.diagnostico ORDER BY d.especialidad, frecuencia DESC";

module.exports = {
  VIEW_PACIENTES_CITAS,
  VIEW_DOCTORES_ESTADISTICAS,
  VIEW_PACIENTES_SIN_CITAS,
  VIEW_CITAS_PROXIMAS,
  VIEW_DIAGNOSTICOS_ESPECIALIDAD
};
