const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
const pacientesRoutes = require('./routes/pacientes');
const consultasRoutes = require('./routes/consultas');

const app = express();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, '../public')));

// Rutas
app.use('/api/pacientes', pacientesRoutes);
app.use('/api/consultas', consultasRoutes);

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Error del servidor',
    error: err.message
  });
});

module.exports = app;
