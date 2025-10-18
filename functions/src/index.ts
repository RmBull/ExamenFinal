import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

// ✅ Imports compatibles sin esModuleInterop
import * as express from "express";
import * as cors from "cors";
import type { Request, Response } from "express";

admin.initializeApp();
const db = admin.firestore();

const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// 🔐 Correos con permiso de administración
const ADMIN_EMAILS = new Set<string>([
  "patricio.alarcon01@mayor.cl", // agrega más si quieres
]);

// ============================
// Helpers
// ============================

function normalizeComic(body: any) {
  const titulo = String(body?.titulo ?? "").trim();
  const autor = String(body?.autor ?? "").trim();
  const portadaUrl = String(body?.portadaUrl ?? "").trim();
  const precioNum = Number(body?.precio ?? 0);
  const stockNum = Number(body?.stock ?? 0);
  const categoria = String(body?.categoria ?? "Otros").trim();

  if (!titulo || !autor || !portadaUrl) {
    throw new Error("Campos requeridos: titulo, autor, portadaUrl");
  }
  if (Number.isNaN(precioNum) || precioNum < 0) {
    throw new Error("precio inválido");
  }
  if (!Number.isInteger(stockNum) || stockNum < 0) {
    throw new Error("stock inválido (entero >= 0)");
  }

  return {
    titulo,
    autor,
    portadaUrl,
    precio: precioNum,
    stock: stockNum,
    categoria: categoria.length === 0 ? "Otros" : categoria,
  };
}

async function checkAdmin(req: Request): Promise<boolean> {
  const token = req.headers.authorization?.startsWith("Bearer ")
    ? req.headers.authorization!.slice(7)
    : "";

  if (!token) return false;
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    const email = decoded.email ?? "";
    return ADMIN_EMAILS.has(email);
  } catch {
    return false;
  }
}

// ============================
// Rutas públicas
// ============================

// GET: lista de cómics
app.get("/api/comics", async (_req: Request, res: Response) => {
  try {
    const snap = await db.collection("comics").orderBy("titulo").get();
    const comics = snap.docs.map((d) => ({ id: d.id, ...d.data() }));
    res.status(200).json(comics);
  } catch (e) {
    res.status(500).json({ error: "Error al obtener cómics" });
  }
});

// GET: cómic por ID
app.get("/api/comics/:id", async (req: Request, res: Response) => {
  try {
    const doc = await db.collection("comics").doc(req.params.id).get();
    if (!doc.exists)
      return res.status(404).json({ error: "Cómic no encontrado" });
    res.status(200).json({ id: doc.id, ...doc.data() });
  } catch {
    res.status(500).json({ error: "Error al obtener cómic" });
  }
});

// ============================
// Rutas admin (POST/PUT/DELETE)
// ============================

app.post("/api/comics", async (req: Request, res: Response) => {
  if (!(await checkAdmin(req)))
    return res.status(403).json({ error: "No autorizado" });
  try {
    const data = normalizeComic(req.body);
    const ref = await db.collection("comics").add(data);
    res.status(201).json({ id: ref.id, ...data });
  } catch (e: any) {
    res.status(400).json({ error: e?.message ?? "Bad request" });
  }
});

app.put("/api/comics/:id", async (req: Request, res: Response) => {
  if (!(await checkAdmin(req)))
    return res.status(403).json({ error: "No autorizado" });
  try {
    const data = normalizeComic(req.body);
    await db.collection("comics").doc(req.params.id).set(data, { merge: true });
    res.status(200).json({ id: req.params.id, ...data });
  } catch (e: any) {
    res.status(400).json({ error: e?.message ?? "Bad request" });
  }
});

app.delete("/api/comics/:id", async (req: Request, res: Response) => {
  if (!(await checkAdmin(req)))
    return res.status(403).json({ error: "No autorizado" });
  try {
    await db.collection("comics").doc(req.params.id).delete();
    res.status(204).send();
  } catch {
    res.status(500).json({ error: "Error al eliminar cómic" });
  }
});

// ============================
// Compra (descontar stock)
// ============================

app.patch("/api/comics/:id/comprar", async (req: Request, res: Response) => {
  try {
    const cantidad = Number(req.body?.cantidad ?? 1);
    if (!Number.isInteger(cantidad) || cantidad <= 0) {
      return res.status(400).json({ error: "Cantidad inválida" });
    }

    const ref = db.collection("comics").doc(req.params.id);
    const doc = await ref.get();
    if (!doc.exists)
      return res.status(404).json({ error: "Cómic no encontrado" });

    const data = doc.data()!;
    const stockActual = Number(data.stock ?? 0);
    const nuevoStock = stockActual - cantidad;
    if (nuevoStock < 0)
      return res.status(400).json({ error: "Stock insuficiente" });

    await ref.update({ stock: nuevoStock });
    res.status(200).json({ message: "Compra realizada", nuevoStock });
  } catch {
    res.status(500).json({ error: "Error al procesar compra" });
  }
});

// Export
export const api = functions.https.onRequest(app);
// Si quieres fijar región:
// export const api = functions.region('us-central1').https.onRequest(app);
