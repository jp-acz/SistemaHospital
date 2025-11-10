// src/controllers/crudController.js
const { executeQuery } = require('../config/database');

const TABLAS_CONFIG = {
  Pacientes: { pk: 'ID', campos: ['nombre','edad','direccion','telefono'] },
  Doctores:  { pk: 'ID', campos: ['nombre','especialidad','telefono'] },
  Citas:     { pk: 'ID', campos: ['paciente_id','doctor_id','fecha'] },
};

function validarTabla(tabla) {
  if (!TABLAS_CONFIG[tabla]) {
    const disponibles = Object.keys(TABLAS_CONFIG).join(', ');
    throw new Error(`Tabla no permitida. Usa: ${disponibles}`);
  }
}
function buildParams(tabla, body) {
  const { campos } = TABLAS_CONFIG[tabla];
  const params = {};
  campos.forEach(c => { if (body[c] !== undefined) params[c] = body[c]; });
  return params;
}

exports.readAll = async (req, res) => {
  try {
    const { tabla } = req.params; validarTabla(tabla);
    const sp = `EXEC sp_${tabla}_ReadAll`;
    let data;
    try { data = await executeQuery(sp); }
    catch {
      const cols = [TABLAS_CONFIG[tabla].pk, ...TABLAS_CONFIG[tabla].campos].join(', ');
      data = await executeQuery(`SELECT ${cols} FROM ${tabla}`);
    }
    res.json({ success: true, data });
  } catch (error) { res.status(400).json({ success: false, error: error.message }); }
};

exports.readById = async (req, res) => {
  try {
    const { tabla, id } = req.params; validarTabla(tabla);
    let data;
    try { data = await executeQuery(`EXEC sp_${tabla}_ReadById @id`, { id: Number(id) }); }
    catch {
      const cols = [TABLAS_CONFIG[tabla].pk, ...TABLAS_CONFIG[tabla].campos].join(', ');
      data = await executeQuery(`SELECT ${cols} FROM ${tabla} WHERE ID = @id`, { id: Number(id) });
    }
    if (!data || data.length === 0) return res.status(404).json({ success:false, message:'No encontrado' });
    res.json({ success: true, data: data[0] });
  } catch (error) { res.status(400).json({ success: false, error: error.message }); }
};

exports.create = async (req, res) => {
  try {
    const { tabla } = req.params; validarTabla(tabla);
    const params = buildParams(tabla, req.body);
    const keys = Object.keys(params);
    if (keys.length === 0) throw new Error('Sin datos para crear');
    let data;
    try {
      const spParams = keys.map(k => `@${k}=@${k}`).join(', ');
      data = await executeQuery(`EXEC sp_${tabla}_Create ${spParams}`, params);
    } catch {
      const cols = keys.join(', ');
      const holders = keys.map((k,i)=>`@p${i}`).join(', ');
      const named = {}; keys.forEach((k,i)=> named[`p${i}`]=params[k]);
      await executeQuery(`INSERT INTO ${tabla} (${cols}) VALUES (${holders});`, named);
      data = await executeQuery(`SELECT TOP 1 * FROM ${tabla} ORDER BY ID DESC`);
    }
    res.status(201).json({ success: true, data: Array.isArray(data)? data[0]: data });
  } catch (error) { res.status(400).json({ success: false, error: error.message }); }
};

exports.update = async (req, res) => {
  try {
    const { tabla, id } = req.params; validarTabla(tabla);
    const params = buildParams(tabla, req.body);
    const keys = Object.keys(params);
    if (keys.length === 0) throw new Error('Sin datos para actualizar');
    let data;
    try {
      const spParams = ['@id=@id', ...keys.map(k=>`@${k}=@${k}`)].join(', ');
      data = await executeQuery(`EXEC sp_${tabla}_Update ${spParams}`, { id: Number(id), ...params });
    } catch {
      const sets = keys.map((k,i)=>`${k}=@p${i}`).join(', ');
      const named = {}; keys.forEach((k,i)=> named[`p${i}`]=params[k]);
      await executeQuery(`UPDATE ${tabla} SET ${sets} WHERE ID=@id`, { ...named, id: Number(id) });
      data = await executeQuery(`SELECT * FROM ${tabla} WHERE ID=@id`, { id: Number(id) });
    }
    res.json({ success: true, data: Array.isArray(data)? data[0]: data });
  } catch (error) { res.status(400).json({ success: false, error: error.message }); }
};

exports.remove = async (req, res) => {
  try {
    const { tabla, id } = req.params; validarTabla(tabla);
    try { await executeQuery(`EXEC sp_${tabla}_Delete @id`, { id: Number(id) }); }
    catch { await executeQuery(`DELETE FROM ${tabla} WHERE ID=@id`, { id: Number(id) }); }
    res.json({ success: true, message: 'Eliminado' });
  } catch (error) { res.status(400).json({ success: false, error: error.message }); }
};

// Exporta también la config si la necesitas en cliente
exports.TABLAS_CONFIG = TABLAS_CONFIG;
