// src/app.js
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const swaggerUi = require('swagger-ui-express');
const path = require('path');

const app = express();

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Servir archivos estáticos
app.use(express.static(path.join(__dirname, '../public')));

// Importar rutas
const pacientesRoutes = require('./routes/pacientes');

// Rutas API
app.use('/api/pacientes', pacientesRoutes);

// Ruta raíz
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Ruta de prueba API
app.get('/api', (req, res) => {
  res.json({
    message: 'API del Sistema Hospitalario',
    version: '1.0.0',
    endpoints: {
      pacientes: '/api/pacientes',
      swagger: '/api-docs'
    }
  });
});

// Documentación Swagger
app.get('/api-docs.json', (req, res) => {
  res.json({
    openapi: '3.0.0',
    info: {
      title: 'Hospital Management API',
      version: '1.0.0',
      description: 'API REST para Sistema de Gestión Hospitalaria'
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Development server'
      }
    ],
    paths: {
      '/api/pacientes': {
        get: {
          summary: 'Obtener todos los pacientes',
          tags: ['Pacientes'],
          responses: {
            '200': {
              description: 'Lista de pacientes obtenida exitosamente'
            }
          }
        },
        post: {
          summary: 'Crear nuevo paciente',
          tags: ['Pacientes'],
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    nombre: { type: 'string' },
                    edad: { type: 'number' },
                    direccion: { type: 'string' },
                    telefono: { type: 'string' }
                  }
                }
              }
            }
          },
          responses: {
            '201': {
              description: 'Paciente creado exitosamente'
            }
          }
        }
      }
    }
  });
});

// Manejo de errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: 'Error interno del servidor',
    error: err.message
  });
});

// 404
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Ruta no encontrada'
  });
});

module.exports = app;