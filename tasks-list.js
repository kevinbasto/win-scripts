const fs = require('fs');
const path = require('path');

// Ruta a tu vault
const vaultPath = 'C:/Users/never/OneDrive/Documentos/tareas';

let notifier;
try {
  notifier = require('node-notifier');
} catch (e) {
  console.log('⚠️  node-notifier no está instalado. Instálalo con: npm install node-notifier');
  console.log('Mientras tanto, las notificaciones se mostrarán en consola.');
}

function getTodayFile() {
  const now = new Date();
  const day = String(now.getDate()).padStart(2, '0');
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const year = String(now.getFullYear()).slice(-2);
  return path.join(vaultPath, `${day}-${month}-${year}.md`);
}

function readTasks(file) {
  if (!fs.existsSync(file)) return null;
  
  const content = fs.readFileSync(file, 'utf8');
  
  // Regex para capturar tareas sin marcar: - [ ] o - [*]
  const regex = /^- \[( |\*)\] (.+)$/gm;
  let match;
  const tasks = [];
  
  while ((match = regex.exec(content)) !== null) {
    tasks.push(match[2].trim());
  }
  
  return tasks;
}

function sendNotification(title, tasks) {
  if (notifier) {
    // Usar node-notifier si está disponible
    const message = tasks.slice(0, 3).map((task, index) => `${index + 1}. ${task}`).join('\n');
    const fullMessage = tasks.length > 3 ? `${message}\n... y ${tasks.length - 3} más` : message;
    
    notifier.notify({
      title: title,
      message: fullMessage,
      sound: true,
      timeout: 15,
      type: 'info',
      appID: 'Obsidian Task Reminder' // Para Windows 10/11
    }, (err, response) => {
      if (err) {
        console.error('Error con node-notifier:', err);
        showConsoleNotification(title, tasks);
      } else {
        console.log('✅ Notificación enviada correctamente');
      }
    });
  } else {
    // Fallback: mostrar en consola
    showConsoleNotification(title, tasks);
  }
}

function showConsoleNotification(title, tasks) {
  const border = '═'.repeat(60);
  const line = '─'.repeat(60);
  
  console.log('\n' + border);
  console.log('🔔 RECORDATORIO DE TAREAS');
  console.log(border);
  console.log(`📋 ${title}`);
  console.log(line);
  tasks.forEach((task, index) => {
    console.log(`   ${index + 1}. ${task}`);
  });
  console.log(line);
  console.log(`⏰ ${new Date().toLocaleString()}`);
  console.log(border + '\n');
  
  // También hacer un beep en la consola
  process.stdout.write('\x07'); // Beep
}

function checkTasks() {
  const file = getTodayFile();
  const fileName = path.basename(file);
  
  console.log(`\n🔍 Revisando archivo: ${fileName}`);
  
  if (!fs.existsSync(file)) {
    console.log('📄 Archivo de hoy no encontrado');
    return;
  }
  
  const tasks = readTasks(file);
  
  if (tasks && tasks.length > 0) {
    console.log(`⚠️  Encontradas ${tasks.length} tareas pendientes:`);
    tasks.forEach((task, index) => {
      console.log(`   ${index + 1}. ${task}`);
    });
    
    const title = `📋 ${tasks.length} tarea${tasks.length > 1 ? 's' : ''} pendiente${tasks.length > 1 ? 's' : ''}`;
    sendNotification(title, tasks);
  } else {
    console.log('✅ ¡Todas las tareas están completadas!');
  }
}

function startMonitoring() {
  console.log('🚀 Iniciando monitor de tareas de Obsidian...');
  console.log(`📁 Vault: ${vaultPath}`);
  console.log('⏰ Revisará cada hora');
  console.log('🛑 Presiona Ctrl+C para detener\n');
  
  // Revisión inicial
  checkTasks();
  
  // Programar revisión cada hora
  setInterval(() => {
    const now = new Date();
    console.log(`\n⏰ Revisión programada - ${now.toLocaleTimeString()}`);
    checkTasks();
  }, 3600000); // 1 hora
}

// Verificar argumentos de línea de comandos
const args = process.argv.slice(2);

if (args.includes('--once') || args.includes('-o')) {
  // Ejecutar solo una vez
  checkTasks();
} else if (args.includes('--test') || args.includes('-t')) {
  // Modo de prueba cada 10 segundos
  console.log('🧪 Modo de prueba: revisará cada 10 segundos');
  checkTasks();
  setInterval(checkTasks, 10000);
} else {
  // Ejecutar monitoreo continuo
  startMonitoring();
}

// Manejar cierre elegante
process.on('SIGINT', () => {
  console.log('\n👋 Monitor detenido por el usuario');
  process.exit(0);
});