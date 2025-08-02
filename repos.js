#!/usr/bin/env node

const fs = require('fs').promises;
const path = require('path');
const { execSync, spawn } = require('child_process');
const os = require('os');

// Configuración
const CONFIG = {
    reposFile: process.argv[2] || 'repos.txt',
    logDir: process.argv[3] || 'logs',
    maxConcurrent: parseInt(process.argv[4]) || 4
};

// Colores para consola
const colors = {
    reset: '\x1b[0m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    cyan: '\x1b[36m',
    gray: '\x1b[90m'
};

// Función para logging con colores y archivo
async function log(message, color = 'reset', logFile = null) {
    const timestamp = new Date().toISOString().replace('T', ' ').slice(0, 19);
    const coloredMessage = `${colors[color]}${message}${colors.reset}`;
    const logMessage = `[${timestamp}] ${message}`;
    
    console.log(coloredMessage);
    
    if (logFile) {
        try {
            await fs.appendFile(path.join(CONFIG.logDir, logFile), logMessage + '\n');
        } catch (err) {
            console.error(`Error escribiendo log: ${err.message}`);
        }
    }
    
    // También escribir al log principal
    try {
        await fs.appendFile(path.join(CONFIG.logDir, 'main.log'), logMessage + '\n');
    } catch (err) {
        // Ignorar errores del log principal
    }
}

// Verificar dependencias
function checkDependencies() {
    log('🔍 Verificando dependencias...', 'cyan');
    
    const dependencies = ['git', 'npm'];
    const missing = [];
    
    for (const dep of dependencies) {
        try {
            execSync(`${dep} --version`, { stdio: 'ignore' });
            log(`  ✅ ${dep} encontrado`, 'green');
        } catch (error) {
            missing.push(dep);
            log(`  ❌ ${dep} no encontrado`, 'red');
        }
    }
    
    if (missing.length > 0) {
        log(`❌ Dependencias faltantes: ${missing.join(', ')}`, 'red');
        log('Instala las dependencias faltantes:', 'yellow');
        if (missing.includes('git')) {
            log('  - Git: https://git-scm.com/download/win', 'yellow');
        }
        if (missing.includes('npm')) {
            log('  - Node.js (incluye npm): https://nodejs.org/', 'yellow');
        }
        process.exit(1);
    }
    
    log('✅ Todas las dependencias están instaladas', 'green');
}

// Ejecutar comando y capturar salida
function runCommand(command, cwd = process.cwd()) {
    return new Promise((resolve, reject) => {
        const [cmd, ...args] = command.split(' ');
        const child = spawn(cmd, args, { 
            cwd, 
            stdio: 'pipe',
            shell: true 
        });
        
        let stdout = '';
        let stderr = '';
        
        child.stdout.on('data', (data) => {
            stdout += data.toString();
        });
        
        child.stderr.on('data', (data) => {
            stderr += data.toString();
        });
        
        child.on('close', (code) => {
            resolve({
                code,
                stdout: stdout.trim(),
                stderr: stderr.trim(),
                output: (stdout + stderr).trim()
            });
        });
        
        child.on('error', (error) => {
            reject(error);
        });
    });
}

// Procesar un repositorio individual
async function processRepository(repoUrl) {
    const repoName = path.basename(repoUrl).replace(/\.git$/, '');
    const logFile = `${repoName}.log`;
    
    try {
        await log(`Iniciando procesamiento de ${repoName}`, 'cyan', logFile);
        await log(`URL: ${repoUrl}`, 'gray', logFile);
        
        // Verificar si el directorio ya existe
        let repoExists = false;
        try {
            await fs.access(repoName);
            repoExists = true;
        } catch (err) {
            // El directorio no existe
        }
        
        if (repoExists) {
            await log(`📂 Directorio ${repoName} ya existe, actualizando...`, 'yellow', logFile);
            
            const pullResult = await runCommand('git pull', repoName);
            await log(`Git pull output: ${pullResult.output}`, 'gray', logFile);
            
            if (pullResult.code !== 0) {
                await log(`⚠️ No se pudo actualizar, continuando con la versión actual`, 'yellow', logFile);
            } else {
                await log(`✅ Repositorio actualizado`, 'green', logFile);
            }
        } else {
            await log(`📥 Clonando ${repoUrl}...`, 'cyan', logFile);
            
            const cloneResult = await runCommand(`git clone ${repoUrl} ${repoName}`);
            await log(`Git clone output: ${cloneResult.output}`, 'gray', logFile);
            
            if (cloneResult.code !== 0) {
                throw new Error(`Error al clonar el repositorio: ${cloneResult.output}`);
            }
            
            await log(`✅ Repositorio clonado exitosamente`, 'green', logFile);
        }
        
        // Verificar si existe package.json
        let hasPackageJson = false;
        try {
            await fs.access(path.join(repoName, 'package.json'));
            hasPackageJson = true;
        } catch (err) {
            // No existe package.json
        }
        
        if (hasPackageJson) {
            await log(`📦 Encontrado package.json, ejecutando npm install...`, 'cyan', logFile);
            
            const npmResult = await runCommand('npm install', repoName);
            await log(`NPM install output:`, 'gray', logFile);
            await log(npmResult.output, 'gray', logFile);
            
            if (npmResult.code === 0) {
                await log(`✅ npm install completado exitosamente`, 'green', logFile);
            } else {
                await log(`❌ Error durante npm install (código: ${npmResult.code})`, 'red', logFile);
                return {
                    success: false,
                    repoName,
                    error: 'npm install falló',
                    hasPackageJson: true
                };
            }
        } else {
            await log(`ℹ️ No se encontró package.json en este repositorio`, 'gray', logFile);
        }
        
        await log(`✅ Procesamiento de ${repoName} completado exitosamente`, 'green', logFile);
        
        return {
            success: true,
            repoName,
            hasPackageJson
        };
        
    } catch (error) {
        await log(`❌ Error crítico: ${error.message}`, 'red', logFile);
        return {
            success: false,
            repoName,
            error: error.message,
            hasPackageJson: false
        };
    }
}

// Procesar repositorios con control de concurrencia
async function processRepositoriesConcurrent(repos) {
    const results = [];
    const executing = [];
    
    for (const repo of repos) {
        const promise = processRepository(repo).then(result => {
            const status = result.hasPackageJson ? '(con npm install)' : '(sin package.json)';
            if (result.success) {
                log(`✅ ${result.repoName} completado ${status}`, 'green');
            } else {
                log(`❌ ${result.repoName} falló: ${result.error}`, 'red');
            }
            return result;
        });
        
        results.push(promise);
        executing.push(promise);
        
        if (executing.length >= CONFIG.maxConcurrent) {
            await Promise.race(executing);
            executing.splice(executing.findIndex(p => p === promise), 1);
        }
    }
    
    return Promise.all(results);
}

// Función principal
async function main() {
    try {
        log('🚀 Iniciando automatización de repositorios (Git + NPM)', 'cyan');
        log(`📅 Fecha: ${new Date().toLocaleString()}`, 'gray');
        console.log();
        
        // Crear directorio de logs
        try {
            await fs.mkdir(CONFIG.logDir, { recursive: true });
        } catch (err) {
            // Directorio ya existe
        }
        
        // Verificar que existe el archivo repos.txt
        try {
            await fs.access(CONFIG.reposFile);
        } catch (err) {
            log(`❌ No se encontró el archivo ${CONFIG.reposFile}`, 'red');
            log(`Crea un archivo ${CONFIG.reposFile} con las URLs de los repositorios (una por línea)`, 'yellow');
            console.log();
            log('Ejemplo de contenido:', 'yellow');
            console.log('https://github.com/usuario/repo1.git');
            console.log('https://github.com/usuario/repo2.git');
            console.log('# Los comentarios empiezan con #');
            process.exit(1);
        }
        
        // Verificar dependencias
        checkDependencies();
        console.log();
        
        // Leer repositorios del archivo
        const fileContent = await fs.readFile(CONFIG.reposFile, 'utf8');
        const repos = fileContent
            .split('\n')
            .map(line => line.trim())
            .filter(line => line && !line.startsWith('#'));
        
        if (repos.length === 0) {
            log(`❌ No se encontraron URLs válidas en ${CONFIG.reposFile}`, 'red');
            log('Asegúrate de que el archivo contenga URLs de repositorios', 'yellow');
            process.exit(1);
        }
        
        log(`📋 Encontrados ${repos.length} repositorio(s) para procesar`, 'cyan');
        log(`🔧 Procesamiento concurrente: máximo ${CONFIG.maxConcurrent} repositorios simultáneos`, 'cyan');
        console.log();
        
        // Mostrar lista de repos
        log('📝 Repositorios a procesar:', 'cyan');
        repos.forEach((repo, index) => {
            const repoName = path.basename(repo).replace(/\.git$/, '');
            log(`  ${index + 1}. ${repoName}`, 'gray');
        });
        console.log();
        
        // Procesar repositorios
        const startTime = Date.now();
        log('⏳ Iniciando procesamiento...', 'yellow');
        
        const results = await processRepositoriesConcurrent(repos);
        
        // Mostrar resumen final
        const endTime = Date.now();
        const duration = Math.round((endTime - startTime) / 1000);
        
        console.log();
        log('🎉 ¡Procesamiento completado!', 'green');
        log(`⏱️ Tiempo total: ${Math.floor(duration / 60)}:${(duration % 60).toString().padStart(2, '0')}`, 'cyan');
        log(`📊 Logs disponibles en: ${CONFIG.logDir}`, 'cyan');
        
        console.log();
        log('📈 Resumen final:', 'cyan');
        
        const successful = results.filter(r => r.success);
        const failed = results.filter(r => !r.success);
        const withNpm = results.filter(r => r.success && r.hasPackageJson);
        
        log(`  ✅ Exitosos: ${successful.length}/${results.length}`, 'green');
        log(`  📦 Con npm install: ${withNpm.length}`, 'cyan');
        log(`  ❌ Fallidos: ${failed.length}`, failed.length === 0 ? 'green' : 'red');
        
        if (failed.length > 0) {
            console.log();
            log('❌ Repositorios con errores:', 'red');
            failed.forEach(fail => {
                log(`  • ${fail.repoName}: ${fail.error}`, 'red');
            });
        }
        
    } catch (error) {
        log(`🛑 Error crítico: ${error.message}`, 'red');
        process.exit(1);
    }
}

// Manejo de interrupciones
process.on('SIGINT', () => {
    log('🛑 Script interrumpido por el usuario', 'yellow');
    process.exit(0);
});

process.on('SIGTERM', () => {
    log('🛑 Script terminado', 'yellow');
    process.exit(0);
});

// Ejecutar script
if (require.main === module) {
    main();
}