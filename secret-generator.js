const crypto = require('crypto');

const hash = crypto.createHash('SHA512').update(crypto.randomBytes(128)).digest('hex')
console.log(hash);