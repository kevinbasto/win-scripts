#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

// Obtener argumentos
const commitMessage = process.argv[2];
const repoPath = process.argv[3] || process.cwd();

if (!commitMessage) {
    console.error('❌ Error: Debes proporcionar un mensaje de commit');
    console.log('Uso: node git-commit-logger.js "<mensaje>" [ruta-repo]');
    process.exit(1);
}

// Verificar si estamos en un repositorio git
try {
    execSync('git rev-parse --git-dir', { cwd: repoPath, stdio: 'pipe' });
} catch (error) {
    console.error('❌ Error: No estás en un repositorio Git válido');
    process.exit(1);
}

// Crear directorio de logs si no existe
const logsPath = path.join(os.homedir(), 'logs');
if (!fs.existsSync(logsPath)) {
    fs.mkdirSync(logsPath, { recursive: true });
}

// Obtener información del commit y git
const now = new Date();
const dateString = now.toISOString().split('T')[0]; // YYYY-MM-DD
const timeString = now.toTimeString().split(' ')[0]; // HH:MM:SS

let gitUser, gitEmail, commitHash, branch, remoteUrl;

try {
    // Obtener información de git
    gitUser = execSync('git config user.name', { cwd: repoPath, encoding: 'utf8' }).trim();
    gitEmail = execSync('git config user.email', { cwd: repoPath, encoding: 'utf8' }).trim();
    
    // Obtener el hash del último commit (después del commit que se acaba de hacer)
    try {
        commitHash = execSync('git rev-parse HEAD', { cwd: repoPath, encoding: 'utf8' }).trim();
    } catch {
        commitHash = 'N/A (primer commit)';
    }
    
    // Obtener branch actual
    try {
        branch = execSync('git branch --show-current', { cwd: repoPath, encoding: 'utf8' }).trim();
    } catch {
        branch = 'N/A';
    }
    
    // Obtener URL del repositorio remoto
    try {
        remoteUrl = execSync('git config --get remote.origin.url', { cwd: repoPath, encoding: 'utf8' }).trim();
    } catch {
        remoteUrl = 'N/A (sin remoto)';
    }
    
} catch (error) {
    console.error(`❌ Error al obtener información de Git: ${error.message}`);
    process.exit(1);
}

// Crear entrada del log
const logEntry = {
    date: dateString,
    time: timeString,
    commit: {
        hash: commitHash,
        message: commitMessage,
        fullMessage: `[FEAT]: ${commitMessage}`
    },
    repository: {
        path: path.resolve(repoPath),
        branch: branch,
        remoteUrl: remoteUrl
    },
    user: {
        gitUser: gitUser,
        gitEmail: gitEmail,
        systemUser: os.userInfo().username,
        computer: os.hostname()
    },
    timestamp: now.toISOString()
};

// Nombre del archivo de log
const logFileName = `git-commits-${dateString}.json`;
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
    console.log(`✅ Commit registrado en: ${logFilePath}`);
    console.log(`📝 Commit: ${commitHash.substring(0, 7)} - ${logEntry.commit.fullMessage}`);
    console.log(`👤 Usuario: ${gitUser} (${gitEmail})`);
    console.log(`🌿 Branch: ${branch}`);
    console.log(`📁 Repositorio: ${logEntry.repository.path}`);
} catch (error) {
    console.error(`❌ Error al guardar el log: ${error.message}`);
    process.exit(1);
}