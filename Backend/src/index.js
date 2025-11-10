require('dotenv').config();

const app = require('./app');
const { createDatabase, executeQuery } = require('./config/database');
const { crearTablaAuditoria } = require('./config/audit-table');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || 'localhost';

async function ejecutarScriptsSQL() {
    try {
        const scripts = [
            '01_crear_bd.sql',
            '02_crear_tablas.sql',
            '03_procedimientos.sql',
            '04_vistas.sql',
            '05_triggers.sql',
            '06_insertar_datos.sql'
        ];

        console.log('\n📋 Ejecutando scripts SQL...\n');

        for (const scriptName of scripts) {
            const scriptPath = path.join(__dirname, '../database/scripts', scriptName);
            
            if (!fs.existsSync(scriptPath)) {
                console.log(`⚠️  ${scriptName} no encontrado, saltando...`);
                continue;
            }

            // SKIP inserción de datos si ya hay registros
            if (scriptName === '06_insertar_datos.sql') {
                try {
                    const result = await executeQuery('SELECT COUNT(*) as total FROM Pacientes');
                    if (result && result[0] && result[0].total > 0) {
                        console.log(`⚠️  Ya existen ${result[0].total} pacientes. Saltando inserción de datos...`);
                        continue;
                    }
                } catch (err) {
                    console.log('⚠️  Error verificando datos, intentando insertar...');
                }
            }

            const sqlScript = fs.readFileSync(scriptPath, 'utf-8');
            
            const batches = sqlScript
                .split(/^\s*GO\s*$/gim)
                .map(batch => batch.trim())
                .filter(batch => batch.length > 0);

            console.log(`Ejecutando ${scriptName}...`);

            for (let i = 0; i < batches.length; i++) {
                const batch = batches[i];
                try {
                    await executeQuery(batch);
                } catch (err) {
                    if (err.message.includes('already') || 
                        err.message.includes('ya existe') ||
                        err.message.includes('does not exist') ||
                        err.message.includes('Cannot drop') ||
                        err.message.includes('There is already')) {
                        console.log(`⚠️  ${err.message.substring(0, 80)}...`);
                    } else {
                        console.error(`❌ Error en ${scriptName}:`, err.message);
                        throw err;
                    }
                }
            }

            console.log(`✓ ${scriptName} completado`);
        }

        console.log('\n✅ Scripts SQL ejecutados correctamente\n');
    } catch (error) {
        console.error('❌ Error ejecutando scripts:', error.message);
        throw error;
    }
}

async function startServer() {
    try {
        console.log('\n🔧 Iniciando sistema hospitalario...\n');
        
        await createDatabase();
        await crearTablaAuditoria();
        await ejecutarScriptsSQL();

        app.listen(PORT, HOST, () => {
            console.log('\n═══════════════════════════════════════════════════');
            console.log('🏥 SERVIDOR HOSPITALARIO INICIADO');
            console.log('═══════════════════════════════════════════════════');
            console.log(`🚀 URL: http://${HOST}:${PORT}`);
            console.log(`📄 Frontend: http://${HOST}:${PORT}/index.html`);
            console.log('📊 Base de Datos: SQL Server (HospitalDB)');
            console.log('═══════════════════════════════════════════════════\n');
        });
    } catch (error) {
        console.error('\n❌ Error al iniciar servidor:', error.message);
        process.exit(1);
    }
}

startServer();
