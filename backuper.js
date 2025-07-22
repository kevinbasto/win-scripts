const { execSync } = require('child_process');

function getCurrentBranch() {
  return execSync('git rev-parse --abbrev-ref HEAD').toString().trim();
}

function getTimestamp() {
  const now = new Date();
  const pad = (n) => n.toString().padStart(2, '0');

  const yy = now.getFullYear().toString().slice(-2);
  const MM = pad(now.getMonth() + 1);
  const dd = pad(now.getDate());
  const hh = pad(now.getHours());
  const mm = pad(now.getMinutes());

  return `${yy}-${MM}-${dd}-${hh}-${mm}`;
}

function createBackupBranch() {
  try {
    const branch = getCurrentBranch();
    const timestamp = getTimestamp();
    const backupBranch = `backup-${branch}-${timestamp}`;

    console.log(`Creando rama de respaldo: ${backupBranch}`);
    execSync(`git checkout -b ${backupBranch}`, { stdio: 'inherit' });
  } catch (error) {
    console.error('Error al crear la rama de respaldo:', error.message);
    process.exit(1);
  }
}

createBackupBranch();
