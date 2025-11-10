// Base URL idempotente (evita redeclaraciones)
var API_URL = window.API_URL || (window.API_URL = `${window.location.origin}/api`);

// ===== Render de tabla =====
function renderTableHtml(rows) {
  if (!rows || rows.length === 0) return '<p>No hay resultados</p>';
  const cols = Object.keys(rows[0]);
  let html = '<table class="table"><thead><tr>';
  cols.forEach(c => html += `<th>${c}</th>`);
  html += '</tr></thead><tbody>';
  rows.forEach(r => {
    html += '<tr>';
    cols.forEach(c => html += `<td>${r[c] ?? ''}</td>`);
    html += '</tr>';
  });
  html += '</tbody></table>';
  return html;
}

// ===== Navegación =====
function showSection(id) {
  document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
  const el = document.getElementById(id);
  if (el) el.classList.add('active');
}

// ===== Estado del servidor =====
async function checkStatus() {
  const el = document.getElementById('server-status');
  try {
    const r = await fetch(`${API_URL}/pacientes`);
    const j = await r.json();
    const total = j?.data?.length || 0;
    if (el) { el.textContent = `✓ Conectado - ${total} pacientes registrados`; el.style.color = 'green'; }
    const tot = document.getElementById('total-pacientes');
    if (tot) tot.textContent = total;
  } catch {
    if (el) { el.textContent = '✗ Error de conexión'; el.style.color = 'red'; }
  }
}

// ===== Consultas =====
async function cargarConsulta(tipo) {
  const t = document.getElementById('consulta-titulo');
  const d = document.getElementById('consulta-descripcion');
  const out = document.getElementById('consulta-resultado');
  if (!out) return;
  out.innerHTML = '<p>Cargando...</p>';
  try {
    const r = await fetch(`${API_URL}/consultas/${tipo}`);
    const j = await r.json();
    if (!j.success) throw new Error(j.error || 'Error en la consulta');
    if (t) t.textContent = j.titulo || 'Resultado de consulta';
    if (d) d.textContent = j.descripcion || '';
    out.innerHTML = renderTableHtml(j.data);
  } catch (e) {
    out.innerHTML = `<p>Error: ${e.message}</p>`;
  }
}

// ===== Ver tablas =====
async function cargarTabla(nombreTabla) {
  const cont = document.getElementById('tabla-resultado');
  if (!cont) return;
  cont.innerHTML = '<p>Cargando...</p>';
  try {
    const r = await fetch(`${API_URL}/tablas/${encodeURIComponent(nombreTabla)}`);
    const j = await r.json();
    if (!j.success) throw new Error(j.error || 'Error consultando la tabla');
    cont.innerHTML = `<h3 style="margin:8px 0">Tabla: ${nombreTabla}</h3>` + renderTableHtml(j.data || []);
  } catch (e) {
    cont.innerHTML = `<p>Error: ${e.message}</p>`;
  }
}

// ===== CRUD genérico =====
const CRUD_CONFIG = {
  Pacientes: ['nombre','edad','direccion','telefono'],
  Doctores:  ['nombre','especialidad','telefono'],
  Citas:     ['paciente_id','doctor_id','fecha'],
};

function renderCrudForm(tabla) {
  const form = document.getElementById('crud-form'); if (!form) return;
  form.innerHTML = '';
  (CRUD_CONFIG[tabla] || []).forEach(campo => {
    const type = /edad|telefono|_id|ID$/i.test(campo) ? 'number' : (campo === 'fecha' ? 'datetime-local' : 'text');
    form.insertAdjacentHTML('beforeend', `<div><label>${campo.replace('_',' ')}:</label> <input id="fld-${campo}" type="${type}"></div>`);
  });
  const msg = document.getElementById('crud-msg'); if (msg) msg.textContent = '';
}

function collectForm(tabla) {
  const o = {};
  (CRUD_CONFIG[tabla] || []).forEach(c => {
    const el = document.getElementById(`fld-${c}`);
    if (!el) return;
    let v = el.value;
    if (/edad|telefono|_id|ID$/i.test(c)) v = v ? Number(v) : null;
    o[c] = v || null;
  });
  return o;
}

async function crudCreate(){
  const t = document.getElementById('crud-tabla').value;
  const b = collectForm(t);
  const m = document.getElementById('crud-msg');
  m.textContent = 'Creando...';
  try {
    const r = await fetch(`${API_URL}/crud/${t}`, { method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(b) });
    const j = await r.json();
    m.textContent = j.success ? '✓ Creado' : `✗ ${j.error || 'Error'}`;
  } catch(e){ m.textContent = `✗ ${e.message}`; }
}

async function crudUpdate(){
  const t = document.getElementById('crud-tabla').value;
  const id = document.getElementById('crud-id').value;
  const b = collectForm(t);
  const m = document.getElementById('crud-msg');
  if(!id){ m.textContent = 'Ingresa ID para actualizar'; return; }
  m.textContent = 'Actualizando...';
  try {
    const r = await fetch(`${API_URL}/crud/${t}/${id}`, { method:'PUT', headers:{'Content-Type':'application/json'}, body:JSON.stringify(b) });
    const j = await r.json();
    m.textContent = j.success ? '✓ Actualizado' : `✗ ${j.error || 'Error'}`;
  } catch(e){ m.textContent = `✗ ${e.message}`; }
}

async function crudDelete(){
  const t = document.getElementById('crud-tabla').value;
  const id = document.getElementById('crud-id').value;
  const m = document.getElementById('crud-msg');
  if(!id){ m.textContent = 'Ingresa ID para eliminar'; return; }
  m.textContent = 'Eliminando...';
  try {
    const r = await fetch(`${API_URL}/crud/${t}/${id}`, { method:'DELETE' });
    const j = await r.json();
    m.textContent = j.success ? '✓ Eliminado' : `✗ ${j.error || 'Error'}`;
  } catch(e){ m.textContent = `✗ ${e.message}`; }
}

// Listado para la pestaña CRUD
async function crudList() {
  const tabla = document.getElementById('crud-tabla').value;
  const out = document.getElementById('crud-resultado');
  if (!out) return;
  out.innerHTML = '<p>Cargando...</p>';
  try {
    const r = await fetch(`${API_URL}/crud/${encodeURIComponent(tabla)}`);
    const j = await r.json();
    if (!j.success) throw new Error(j.error || 'Error listando');
    out.innerHTML = `<h3 style="margin:8px 0">Registros: ${tabla}</h3>` + renderTableHtml(j.data || []);
  } catch (e) {
    out.innerHTML = `<p>Error: ${e.message}</p>`;
  }
}

// Modifica las operaciones para refrescar al terminar
async function crudCreate() {
  const tabla = document.getElementById('crud-tabla').value;
  const body = collectForm(tabla);
  const msg = document.getElementById('crud-msg');
  msg.textContent = 'Creando...';
  try {
    const r = await fetch(`${API_URL}/crud/${tabla}`, {
      method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body)
    });
    const j = await r.json();
    msg.textContent = j.success ? '✓ Creado' : `✗ ${j.error || 'Error'}`;
    if (j.success) crudList();
  } catch (e) { msg.textContent = `✗ ${e.message}`; }
}

async function crudUpdate() {
  const tabla = document.getElementById('crud-tabla').value;
  const id = document.getElementById('crud-id').value;
  const body = collectForm(tabla);
  const msg = document.getElementById('crud-msg');
  if (!id) { msg.textContent = 'Ingresa ID para actualizar'; return; }
  msg.textContent = 'Actualizando...';
  try {
    const r = await fetch(`${API_URL}/crud/${tabla}/${id}`, {
      method: 'PUT', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body)
    });
    const j = await r.json();
    msg.textContent = j.success ? '✓ Actualizado' : `✗ ${j.error || 'Error'}`;
    if (j.success) crudList();
  } catch (e) { msg.textContent = `✗ ${e.message}`; }
}

async function crudDelete() {
  const tabla = document.getElementById('crud-tabla').value;
  const id = document.getElementById('crud-id').value;
  const msg = document.getElementById('crud-msg');
  if (!id) { msg.textContent = 'Ingresa ID para eliminar'; return; }
  msg.textContent = 'Eliminando...';
  try {
    const r = await fetch(`${API_URL}/crud/${tabla}/${id}`, { method: 'DELETE' });
    const j = await r.json();
    msg.textContent = j.success ? '✓ Eliminado' : `✗ ${j.error || 'Error'}`;
    if (j.success) crudList();
  } catch (e) { msg.textContent = `✗ ${e.message}`; }
}

// Exponer crudList para depuración 
window.crudList = crudList;

// Inicialización: render form y primer listado
document.addEventListener('DOMContentLoaded', () => {
  checkStatus();
  const sel = document.getElementById('crud-tabla');
  if (sel) { renderCrudForm(sel.value); crudList(); }
});


// Exponer funciones
window.API_URL = API_URL;
window.showSection = showSection;
window.cargarConsulta = cargarConsulta;
window.cargarTabla = cargarTabla;
window.renderCrudForm = renderCrudForm;
window.crudCreate = crudCreate;
window.crudUpdate = crudUpdate;
window.crudDelete = crudDelete;

// Init
document.addEventListener('DOMContentLoaded', () => {
  checkStatus();
  const sel = document.getElementById('crud-tabla'); if (sel) renderCrudForm(sel.value);
});
