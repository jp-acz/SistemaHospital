const { executeScriptFile } = require('./init-sqlserver');
const path = require('path');

async function setupDatabase() {
    console.log('🚀 Iniciando configuración de base de datos...\n');
    
    const scriptsPath = path.join(__dirname, '../../database/scripts');
    const scripts = [
        '00_borrar_tablas.sql',
        '01_crear_bd.sql',
        '02_crear_tablas.sql',
        '03_procedimientos.sql',
        '04_vistas.sql',
        '05_triggers.sql',
        '06_insertar_datos.sql'
    ];

    try {
        for (const script of scripts) {
            await executeScriptFile(path.join(scriptsPath, script));
        }

        console.log('\n✅ Base de datos configurada exitosamente\n');
        process.exit(0);
    } catch (error) {
        console.error('❌ Error durante la configuración:', error.message);
        process.exit(1);
    }
}

setupDatabase();
