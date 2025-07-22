// salida.js
import { MongoClient } from "mongodb";

const uri = "mongodb://localhost:27017";
const client = new MongoClient(uri);
const dbName = "bastoexpress";
const collectionName = "asistencia";

function getFechaUTC6() {
  const now = new Date();
  const utc6Time = new Date(now.getTime() - 6 * 60 * 60 * 1000);
  return new Date(Date.UTC(utc6Time.getUTCFullYear(), utc6Time.getUTCMonth(), utc6Time.getUTCDate()));
}

async function registrarSalida() {
  try {
    await client.connect();
    const db = client.db(dbName);
    const coleccion = db.collection(collectionName);

    const fecha = getFechaUTC6();
    const ahora = new Date();

    // Actualizamos la salida en el documento del día
    const result = await coleccion.updateOne(
      { fecha },
      { $set: { salida: ahora } }
    );

    if (result.matchedCount === 0) {
      console.log("No se encontró registro de entrada para hoy.");
    } else {
      console.log("Salida registrada correctamente.");
    }
  } catch (error) {
    console.error("Error al registrar salida:", error);
  } finally {
    await client.close();
  }
}

registrarSalida();
