const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir archivos estáticos
app.use(express.static(path.join(__dirname, '../public')));

// Rutas API
app.use('/api/pacientes', require('./routes/pacientes'));
app.use('/api/consultas', require('./routes/consultas'));
app.use('/api/tablas', require('./routes/tablas'));
app.use('/api/triggers', require('./routes/triggers'));

// CRUD 
app.use('/api/crud', require('./routes/crud'));

// Ruta raíz
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Manejo de errores
app.use((err, req, res, next) => {
    console.error('Error:', err.stack);
    res.status(500).json({
        success: false,
        message: 'Error interno del servidor',
        error: err.message
    });
});

module.exports = app;
