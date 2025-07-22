// entrada.js
import { MongoClient } from "mongodb";

// Configuración
const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri);
const dbName = "bastoexpress";
const collectionName = "asistencia";

// Función para obtener fecha sin tiempo en UTC-6
function getFechaUTC6() {
  const now = new Date();

  // Obtener fecha con tiempo a las 00:00 en UTC-6
  // UTC-6 significa restar 6 horas a UTC
  // Ajustamos la fecha restando 6 horas
  const utc6Time = new Date(now.getTime() - 6 * 60 * 60 * 1000);

  // Creamos una fecha con solo año, mes, día en UTC6 (sin horas/minutos)
  return new Date(Date.UTC(utc6Time.getUTCFullYear(), utc6Time.getUTCMonth(), utc6Time.getUTCDate()));
}

async function registrarEntrada() {
  try {
    await client.connect();
    const db = client.db(dbName);
    const coleccion = db.collection(collectionName);

    const fecha = getFechaUTC6();
    const ahora = new Date();

    // Buscamos documento del día (fecha sin hora)
    // Si existe, no insertamos otro, sino creamos
    const doc = await coleccion.findOne({ fecha });

    if (doc) {
      console.log("Ya existe registro para hoy:", doc);
      return;
    }

    // Insertar nuevo documento con entrada
    const nuevoDoc = {
      fecha,
      entrada: ahora,
      salida: null,
    };

    const result = await coleccion.insertOne(nuevoDoc);
    console.log("Entrada registrada con _id:", result.insertedId);
  } catch (error) {
    console.error("Error al registrar entrada:", error);
  } finally {
    await client.close();
  }
}

registrarEntrada();
