// backend/src/index.js
require('dotenv').config();
const app = require('./app');
const { getConnection } = require('./config/database');

const PORT = process.env.PORT || 3000;

async function startServer() {
  try {
    await getConnection();
    
    app.listen(PORT, () => {
      console.log(`\n🚀 Servidor ejecutándose en http://localhost:${PORT}`);
      console.log(`📚 Documentación API: http://localhost:${PORT}/api-docs\n`);
    });
  } catch (error) {
    console.error('Error al iniciar el servidor:', error);
    process.exit(1);
  }
}

startServer();
