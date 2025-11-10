const { executeQuery } = require('./database');

async function crearTablaAuditoria() {
    const sql = `
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'AuditoriaEliminar')
        BEGIN
            CREATE TABLE AuditoriaEliminar (
                ID INT PRIMARY KEY IDENTITY(1,1),
                tabla VARCHAR(50) NOT NULL,
                id_eliminado INT NOT NULL,
                fecha_eliminacion DATETIME DEFAULT GETDATE(),
                usuario VARCHAR(100) DEFAULT SYSTEM_USER
            );
            PRINT '✓ Tabla AuditoriaEliminar creada';
        END
        ELSE
        BEGIN
            PRINT '⚠ Tabla AuditoriaEliminar ya existe';
        END
    `;
    
    try {
        await executeQuery(sql);
        console.log('✓ Tabla Auditoría verificada');
    } catch (error) {
        console.error('Error tabla auditoría:', error.message);
    }
}

module.exports = { crearTablaAuditoria };
