#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn } = require('child_process');

// Obtener la ruta como argumento
const targetPath = process.argv[2];

if (!targetPath) {
    console.error('❌ Error: Debes proporcionar una ruta como argumento');
    console.log('Uso: node vscode-logger.js <ruta>');
    process.exit(1);
}

// Verificar si la ruta existe
if (!fs.existsSync(targetPath)) {
    console.error(`❌ Error: La ruta especificada no existe: ${targetPath}`);
    process.exit(1);
}

// Crear directorio de logs si no existe
const logsPath = path.join(os.homedir(), 'logs');
if (!fs.existsSync(logsPath)) {
    fs.mkdirSync(logsPath, { recursive: true });
}

// Obtener información para el log
const now = new Date();
const dateString = now.toISOString().split('T')[0]; // YYYY-MM-DD
const timeString = now.toTimeString().split(' ')[0]; // HH:MM:SS
const userName = os.userInfo().username;
const computerName = os.hostname();
const absolutePath = path.resolve(targetPath);

// Crear entrada del log
const logEntry = {
    date: dateString,
    time: timeString,
    user: userName,
    computer: computerName,
    action: "VS Code Initialized",
    folder: absolutePath,
    timestamp: now.toISOString()
};

// Nombre del archivo de log
const logFileName = `vscode-log-${dateString}.json`;
const logFilePath = path.join(logsPath, logFileName);

// Leer archivo existente o crear array vacío
let logData = [];
if (fs.existsSync(logFilePath)) {
    try {
        const existingContent = fs.readFileSync(logFilePath, 'utf8');
        logData = JSON.parse(existingContent);
        
        // Asegurar que sea un array
        if (!Array.isArray(logData)) {
            logData = [logData];
        }
    } catch (error) {
        console.warn('⚠️  Advertencia: Error al leer el archivo de log existente, creando uno nuevo');
        logData = [];
    }
}

// Agregar nueva entrada
logData.push(logEntry);

// Guardar el archivo
try {
    fs.writeFileSync(logFilePath, JSON.stringify(logData, null, 2));
    console.log(`✅ Log guardado en: ${logFilePath}`);
} catch (error) {
    console.error(`❌ Error al guardar el log: ${error.message}`);
    process.exit(1);
}

// Abrir VS Code
console.log(`🚀 Abriendo VS Code en: ${absolutePath}`);

const vscode = spawn('code', [absolutePath], {
    stdio: 'inherit',
    shell: true
});

vscode.on('error', (error) => {
    if (error.code === 'ENOENT') {
        console.error('❌ Error: VS Code no está instalado o no está en el PATH');
        console.log('💡 Asegúrate de tener VS Code instalado y agregado al PATH del sistema');
    } else {
        console.error(`❌ Error al abrir VS Code: ${error.message}`);
    }
    process.exit(1);
});

vscode.on('close', (code) => {
    if (code === 0) {
        console.log('✅ VS Code iniciado exitosamente!');
    }
});