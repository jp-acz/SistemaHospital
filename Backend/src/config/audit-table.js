const { executeRun } = require('./database');

async function crearTablaAuditoria() {
const sql = `
    CREATE TABLE IF NOT EXISTS AuditoriaEliminar (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    tabla TEXT NOT NULL,
    registro_id INTEGER NOT NULL,
    datos_antiguos TEXT,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP
    )
`;

try {
    await executeRun(sql);
    console.log('✓ Tabla Auditoría creada');
} catch (error) {
    console.error('Error tabla auditoría:', error);
}
}

module.exports = { crearTablaAuditoria };
