import fs from 'fs';
import path from 'path';

// Usar la carpeta actual de trabajo (donde se ejecuta el comando)
const currentDir = process.cwd();

// Rutas de los archivos
const envPath = path.join(currentDir, '.env');
const envExamplePath = path.join(currentDir, '.env.example');

console.log('🔍 Buscando archivo .env...\n');

// Verificar si existe el archivo .env
if (!fs.existsSync(envPath)) {
  console.error('❌ Error: No se encontró el archivo .env en esta carpeta');
  console.log(`📁 Buscando en: ${__dirname}`);
  process.exit(1);
}

console.log('✅ Archivo .env encontrado');
console.log('📝 Generando .env.example...\n');

try {
  // Leer el archivo .env
  const envContent = fs.readFileSync(envPath, 'utf8');
  
  // Procesar línea por línea
  const lines = envContent.split('\n');
  const exampleLines = [];
  
  for (const line of lines) {
    const trimmedLine = line.trim();
    
    // Si es una línea vacía o comentario, mantenerla igual
    if (trimmedLine === '' || trimmedLine.startsWith('#')) {
      exampleLines.push(line);
      continue;
    }
    
    // Si contiene un '=', es una variable de entorno
    if (trimmedLine.includes('=')) {
      const [key, ...valueParts] = trimmedLine.split('=');
      const value = valueParts.join('='); // Por si el valor contiene '='
      
      // Limpiar la key de espacios
      const cleanKey = key.trim();
      
      // Determinar el placeholder según el tipo de valor
      let placeholder = '';
      
      if (value.trim() === '') {
        placeholder = '';
      } else if (value.includes('://')) {
        // Es una URL
        placeholder = 'your_url_here';
      } else if (value.match(/^\d+$/)) {
        // Es un número
        placeholder = '0';
      } else if (value.toLowerCase() === 'true' || value.toLowerCase() === 'false') {
        // Es un booleano
        placeholder = 'true';
      } else if (value.includes('@')) {
        // Probablemente un email
        placeholder = 'your_email@example.com';
      } else if (cleanKey.toLowerCase().includes('key') || cleanKey.toLowerCase().includes('secret')) {
        // Es una API key o secret
        placeholder = 'your_secret_key_here';
      } else if (cleanKey.toLowerCase().includes('password') || cleanKey.toLowerCase().includes('pass')) {
        // Es una contraseña
        placeholder = 'your_password_here';
      } else if (cleanKey.toLowerCase().includes('token')) {
        // Es un token
        placeholder = 'your_token_here';
      } else if (cleanKey.toLowerCase().includes('host')) {
        // Es un host
        placeholder = 'localhost';
      } else if (cleanKey.toLowerCase().includes('port')) {
        // Es un puerto
        placeholder = '3000';
      } else if (cleanKey.toLowerCase().includes('user')) {
        // Es un usuario
        placeholder = 'username';
      } else if (cleanKey.toLowerCase().includes('database') || cleanKey.toLowerCase().includes('db')) {
        // Es una base de datos
        placeholder = 'database_name';
      } else {
        // Valor genérico
        placeholder = 'value_here';
      }
      
      exampleLines.push(`${cleanKey}=${placeholder}`);
    } else {
      // Línea que no es una variable, mantenerla igual
      exampleLines.push(line);
    }
  }
  
  // Escribir el archivo .env.example
  const exampleContent = exampleLines.join('\n');
  fs.writeFileSync(envExamplePath, exampleContent, 'utf8');
  
  console.log('✅ Archivo .env.example generado exitosamente!');
  console.log(`📄 Guardado en: ${envExamplePath}\n`);
  
  // Mostrar preview
  console.log('👀 Preview del archivo generado:');
  console.log('─'.repeat(50));
  console.log(exampleContent);
  console.log('─'.repeat(50));
  
} catch (error) {
  console.error('❌ Error al procesar el archivo:', error.message);
  process.exit(1);
}