#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');

// Función para obtener unidades USB en Windows
function getUSBDrives() {
    const { execSync } = require('child_process');
    
    try {
        // Usar PowerShell para obtener unidades USB
        const command = `powershell -Command "Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 2} | Select-Object DeviceID, VolumeName, Size | ConvertTo-Json"`;
        const result = execSync(command, { encoding: 'utf8' });
        
        let drives = JSON.parse(result);
        
        // Si solo hay una unidad, PowerShell no devuelve un array
        if (!Array.isArray(drives)) {
            drives = [drives];
        }
        
        return drives.map(drive => ({
            letter: drive.DeviceID,
            name: drive.VolumeName || 'Sin nombre',
            size: Math.round(drive.Size / (1024 * 1024 * 1024) * 100) / 100 // GB
        }));
    } catch (error) {
        console.error('❌ Error al buscar unidades USB:', error.message);
        return [];
    }
}

// Función para copiar directorio recursivamente
function copyDirectory(src, dest) {
    if (!fs.existsSync(dest)) {
        fs.mkdirSync(dest, { recursive: true });
    }
    
    const items = fs.readdirSync(src);
    let copiedFiles = 0;
    
    for (const item of items) {
        const srcPath = path.join(src, item);
        const destPath = path.join(dest, item);
        
        const stat = fs.statSync(srcPath);
        
        if (stat.isDirectory()) {
            copiedFiles += copyDirectory(srcPath, destPath);
        } else {
            fs.copyFileSync(srcPath, destPath);
            copiedFiles++;
            console.log(`📄 Copiado: ${item}`);
        }
    }
    
    return copiedFiles;
}

// Función principal
async function main() {
    console.log('🔍 Buscando unidades USB...');
    
    const usbDrives = getUSBDrives();
    
    if (usbDrives.length === 0) {
        console.log('📱 No se encontraron unidades USB conectadas');
        console.log('💡 Conecta tu USB e intenta nuevamente');
        process.exit(1);
    }
    
    console.log(`✅ Se encontraron ${usbDrives.length} unidad(es) USB:`);
    usbDrives.forEach((drive, index) => {
        console.log(`   ${index + 1}. ${drive.letter} - "${drive.name}" (${drive.size} GB)`);
    });
    
    // Seleccionar USB (tomar la primera si solo hay una)
    let selectedUSB;
    if (usbDrives.length === 1) {
        selectedUSB = usbDrives[0];
        console.log(`🎯 Seleccionando automáticamente: ${selectedUSB.letter}`);
    } else {
        // Si hay múltiples, tomar la primera por defecto
        // En una versión más avanzada podrías pedir input del usuario
        selectedUSB = usbDrives[0];
        console.log(`🎯 Seleccionando: ${selectedUSB.letter} (primera unidad encontrada)`);
    }
    
    // Ruta de logs
    const logsPath = path.join(os.homedir(), 'logs');
    
    if (!fs.existsSync(logsPath)) {
        console.log('❌ No se encontró la carpeta de logs en:', logsPath);
        process.exit(1);
    }
    
    // Ruta de destino en USB
    const usbBackupPath = path.join(selectedUSB.letter, 'logs-backup');
    
    console.log(`📁 Origen: ${logsPath}`);
    console.log(`💾 Destino: ${usbBackupPath}`);
    
    try {
        console.log('🔄 Iniciando copia de archivos...');
        
        const copiedFiles = copyDirectory(logsPath, usbBackupPath);
        
        // Crear archivo de información del backup
        const backupInfo = {
            backupDate: new Date().toISOString(),
            sourceUser: os.userInfo().username,
            sourceComputer: os.hostname(),
            sourcePath: logsPath,
            destinationPath: usbBackupPath,
            usbDrive: selectedUSB,
            filesCount: copiedFiles
        };
        
        const backupInfoPath = path.join(usbBackupPath, 'backup-info.json');
        fs.writeFileSync(backupInfoPath, JSON.stringify(backupInfo, null, 2));
        
        console.log('✅ ¡Backup completado exitosamente!');
        console.log(`📊 Archivos copiados: ${copiedFiles}`);
        console.log(`💾 Ubicación: ${usbBackupPath}`);
        console.log(`ℹ️  Información del backup guardada en: backup-info.json`);
        
    } catch (error) {
        console.error('❌ Error durante el backup:', error.message);
        process.exit(1);
    }
}

// Ejecutar
main().catch(console.error);