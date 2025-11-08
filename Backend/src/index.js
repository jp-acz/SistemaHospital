require('dotenv').config();
const app = require('./app');
const { getConnection } = require('./config/database');

const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || 'localhost';
const { crearTablaAuditoria } = require('./config/audit-table');

async function startServer() {
  try {
    await getConnection();
    await crearTablaAuditoria();
    
    app.listen(PORT, HOST, () => {
      console.log('\n🏥 SERVIDOR HOSPITALARIO CON CONSULTAS AVANZADAS');
      console.log('📊 Consultas disponibles en: http://localhost:3000/api/consultas/');
    });
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}


async function startServer() {
  try {
    await getConnection();
    
    app.listen(PORT, HOST, () => {
      console.log('\n═══════════════════════════════════════════════════');
      console.log('🏥 SERVIDOR HOSPITALARIO INICIADO');
      console.log('═══════════════════════════════════════════════════');
      console.log(`🚀 URL: http://${HOST}:${PORT}`);
      console.log('📊 Base de Datos: SQLite');
      console.log('═══════════════════════════════════════════════════\n');
    });
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

process.on('SIGINT', () => {
  console.log('\n⚠️  Cerrando...');
  process.exit(0);
});

startServer();
