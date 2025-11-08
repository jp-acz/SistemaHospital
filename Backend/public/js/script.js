// public/js/script.js

// API Base URL
const API_URL = 'http://localhost:3000/api';

// Mostrar/Ocultar secciones
function showSection(sectionId) {
  // Ocultar todas las secciones
  const sections = document.querySelectorAll('.section');
  sections.forEach(section => section.classList.remove('active'));

  // Mostrar sección seleccionada
  document.getElementById(sectionId).classList.add('active');

  // Actualizar navegación
  const navLinks = document.querySelectorAll('.navbar a');
  navLinks.forEach(link => link.classList.remove('active'));
  event.target.classList.add('active');

  // Cargar datos si es necesario
  if (sectionId === 'pacientes') {
    loadPacientes();
  }
}

// Probar conexión al servidor
async function testConnection() {
  try {
    const response = await fetch('http://localhost:3000/api');
    const data = await response.json();
    showMessage(`✓ Conexión exitosa: ${data.message}`, 'success');
  } catch (error) {
    showMessage('✗ Error al conectar al servidor', 'error');
  }
}

// Verificar estado del servidor
async function checkStatus() {
  const statusElement = document.getElementById('server-status');
  try {
    const response = await fetch('http://localhost:3000/api');
    if (response.ok) {
      statusElement.textContent = '✓ Servidor en línea';
      statusElement.style.color = '#27ae60';
    }
  } catch (error) {
    statusElement.textContent = '✗ Servidor sin conexión';
    statusElement.style.color = '#e74c3c';
  }
}

// Cargar pacientes
async function loadPacientes() {
  try {
    const response = await fetch(`${API_URL}/pacientes`);
    const data = await response.json();

    if (data.success) {
      displayPacientes(data.data);
      updatePacientesCount(data.data.length);
    }
  } catch (error) {
    showMessage('Error al cargar pacientes', 'error');
  }
}

// Mostrar pacientes en tabla
function displayPacientes(pacientes) {
  const tbody = document.querySelector('#pacientes-table tbody');
  tbody.innerHTML = '';

  if (pacientes.length === 0) {
    tbody.innerHTML = '<tr><td colspan="6">No hay pacientes registrados</td></tr>';
    return;
  }

  pacientes.forEach(paciente => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${paciente.ID}</td>
      <td>${paciente.nombre}</td>
      <td>${paciente.edad}</td>
      <td>${paciente.direccion || '-'}</td>
      <td>${paciente.telefono || '-'}</td>
      <td>
        <button class="btn-danger" onclick="deletePaciente(${paciente.ID})">Eliminar</button>
      </td>
    `;
    tbody.appendChild(row);
  });
}

// Actualizar contador de pacientes
function updatePacientesCount(count) {
  document.getElementById('total-pacientes').textContent = count;
}

// Crear nuevo paciente
async function createPaciente(event) {
  event.preventDefault();

  const nombre = document.getElementById('nombre').value;
  const edad = parseInt(document.getElementById('edad').value);
  const direccion = document.getElementById('direccion').value;
  const telefono = document.getElementById('telefono').value;

  try {
    const response = await fetch(`${API_URL}/pacientes`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ nombre, edad, direccion, telefono })
    });

    const data = await response.json();

    if (data.success) {
      showMessage('✓ Paciente creado exitosamente', 'success');
      document.getElementById('paciente-form').reset();
      loadPacientes();
    } else {
      showMessage('✗ Error: ' + data.message, 'error');
    }
  } catch (error) {
    showMessage('Error al crear paciente: ' + error.message, 'error');
  }
}

// Eliminar paciente
async function deletePaciente(id) {
  if (!confirm('¿Está seguro de que desea eliminar este paciente?')) {
    return;
  }

  try {
    const response = await fetch(`${API_URL}/pacientes/${id}`, {
      method: 'DELETE'
    });

    const data = await response.json();

    if (data.success) {
      showMessage('✓ Paciente eliminado exitosamente', 'success');
      loadPacientes();
    } else {
      showMessage('✗ Error al eliminar paciente', 'error');
    }
  } catch (error) {
    showMessage('Error al eliminar paciente: ' + error.message, 'error');
  }
}

// Mostrar mensajes
function showMessage(message, type) {
  // Crear elemento de mensaje
  const messageDiv = document.createElement('div');
  messageDiv.className = `message ${type}`;
  messageDiv.textContent = message;

  // Insertar en el top
  const mainContent = document.querySelector('.main-content');
  mainContent.insertBefore(messageDiv, mainContent.firstChild);

  // Auto-eliminar después de 3 segundos
  setTimeout(() => {
    messageDiv.remove();
  }, 3000);
}

// Inicializar al cargar la página
document.addEventListener('DOMContentLoaded', () => {
  // Cargar datos iniciales
  loadPacientes();
  checkStatus();

  // Cargar cada 30 segundos
  setInterval(checkStatus, 30000);
});