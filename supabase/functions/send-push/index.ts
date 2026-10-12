// Resto — envoi des notifications push (Firebase Cloud Messaging, API HTTP v1).
//
// Appelée par la base (migration 031) à chaque nouvelle notification, avec
// { "id": "<notification>" }. Elle ne fait confiance qu'à la base : elle relit
// la notification, ne l'envoie qu'une fois (pushed_at), compose le texte dans
// la langue de chaque appareil et retire les jetons périmés.
//
// Secrets (Supabase › Edge Functions › Secrets) :
//   FCM_SERVICE_ACCOUNT : contenu JSON de la clé de compte de service Firebase.
// SUPABASE_URL et SUPABASE_SERVICE_ROLE_KEY sont fournis automatiquement.
// Réglage : « Verify JWT » désactivé (la fonction est idempotente et n'envoie
// une notification qu'à son destinataire).

import { createClient } from "jsr:@supabase/supabase-js@2";

type Lang = "fr" | "en" | "es" | "pt" | "de" | "ar" | "zh";
type Data = Record<string, unknown>;

const s = (v: unknown) => (v == null ? "" : String(v));

// Textes : [titre, corps] par type et par langue.
const texts: Record<string, Record<Lang, (d: Data) => [string, string]>> = {
  order_accepted: {
    fr: (d) => ["Commande acceptée", `${s(d.brand_name)} prépare votre commande n° ${s(d.number)}.`],
    en: (d) => ["Order accepted", `${s(d.brand_name)} is preparing your order #${s(d.number)}.`],
    es: (d) => ["Pedido aceptado", `${s(d.brand_name)} prepara su pedido n.º ${s(d.number)}.`],
    pt: (d) => ["Pedido aceite", `${s(d.brand_name)} está a preparar o seu pedido n.º ${s(d.number)}.`],
    de: (d) => ["Bestellung angenommen", `${s(d.brand_name)} bereitet Ihre Bestellung Nr. ${s(d.number)} zu.`],
    ar: (d) => ["تم قبول الطلب", `${s(d.brand_name)} يحضّر طلبك رقم ${s(d.number)}.`],
    zh: (d) => ["订单已接受", `${s(d.brand_name)} 正在准备您的订单 #${s(d.number)}。`],
  },
  order_ready: {
    fr: (d) => d.channel === "delivery"
      ? ["Commande en route", `Votre commande n° ${s(d.number)} de ${s(d.brand_name)} est en livraison.`]
      : ["Commande prête", `Votre commande n° ${s(d.number)} vous attend chez ${s(d.brand_name)}.`],
    en: (d) => d.channel === "delivery"
      ? ["Order on the way", `Your order #${s(d.number)} from ${s(d.brand_name)} is being delivered.`]
      : ["Order ready", `Your order #${s(d.number)} is waiting for you at ${s(d.brand_name)}.`],
    es: (d) => d.channel === "delivery"
      ? ["Pedido en camino", `Su pedido n.º ${s(d.number)} de ${s(d.brand_name)} está en reparto.`]
      : ["Pedido listo", `Su pedido n.º ${s(d.number)} le espera en ${s(d.brand_name)}.`],
    pt: (d) => d.channel === "delivery"
      ? ["Pedido a caminho", `O seu pedido n.º ${s(d.number)} de ${s(d.brand_name)} está em entrega.`]
      : ["Pedido pronto", `O seu pedido n.º ${s(d.number)} espera por si em ${s(d.brand_name)}.`],
    de: (d) => d.channel === "delivery"
      ? ["Bestellung unterwegs", `Ihre Bestellung Nr. ${s(d.number)} von ${s(d.brand_name)} wird geliefert.`]
      : ["Bestellung fertig", `Ihre Bestellung Nr. ${s(d.number)} wartet bei ${s(d.brand_name)} auf Sie.`],
    ar: (d) => d.channel === "delivery"
      ? ["الطلب في الطريق", `طلبك رقم ${s(d.number)} من ${s(d.brand_name)} قيد التوصيل.`]
      : ["الطلب جاهز", `طلبك رقم ${s(d.number)} بانتظارك في ${s(d.brand_name)}.`],
    zh: (d) => d.channel === "delivery"
      ? ["订单配送中", `您在 ${s(d.brand_name)} 的订单 #${s(d.number)} 正在配送。`]
      : ["订单已备好", `您的订单 #${s(d.number)} 已在 ${s(d.brand_name)} 备好。`],
  },
  order_rejected: {
    fr: (d) => ["Commande refusée", `${s(d.brand_name)} ne peut pas honorer la commande n° ${s(d.number)}. ${s(d.reason)}`],
    en: (d) => ["Order declined", `${s(d.brand_name)} cannot fulfil order #${s(d.number)}. ${s(d.reason)}`],
    es: (d) => ["Pedido rechazado", `${s(d.brand_name)} no puede atender el pedido n.º ${s(d.number)}. ${s(d.reason)}`],
    pt: (d) => ["Pedido recusado", `${s(d.brand_name)} não pode aceitar o pedido n.º ${s(d.number)}. ${s(d.reason)}`],
    de: (d) => ["Bestellung abgelehnt", `${s(d.brand_name)} kann Bestellung Nr. ${s(d.number)} nicht annehmen. ${s(d.reason)}`],
    ar: (d) => ["تم رفض الطلب", `لا يستطيع ${s(d.brand_name)} تلبية الطلب رقم ${s(d.number)}. ${s(d.reason)}`],
    zh: (d) => ["订单被拒绝", `${s(d.brand_name)} 无法完成订单 #${s(d.number)}。${s(d.reason)}`],
  },
  reservation_confirmed: {
    fr: (d) => ["Réservation confirmée", `${s(d.brand_name)} vous attend (${s(d.party_size)} pers.).`],
    en: (d) => ["Reservation confirmed", `${s(d.brand_name)} is expecting you (${s(d.party_size)} guests).`],
    es: (d) => ["Reserva confirmada", `${s(d.brand_name)} le espera (${s(d.party_size)} pers.).`],
    pt: (d) => ["Reserva confirmada", `${s(d.brand_name)} espera por si (${s(d.party_size)} pess.).`],
    de: (d) => ["Reservierung bestätigt", `${s(d.brand_name)} erwartet Sie (${s(d.party_size)} Pers.).`],
    ar: (d) => ["تم تأكيد الحجز", `${s(d.brand_name)} بانتظارك (${s(d.party_size)} أشخاص).`],
    zh: (d) => ["预订已确认", `${s(d.brand_name)} 期待您的光临（${s(d.party_size)} 人）。`],
  },
  reservation_declined: {
    fr: (d) => ["Réservation refusée", `${s(d.brand_name)} ne peut pas vous accueillir. ${s(d.reason)}`],
    en: (d) => ["Reservation declined", `${s(d.brand_name)} cannot welcome you. ${s(d.reason)}`],
    es: (d) => ["Reserva rechazada", `${s(d.brand_name)} no puede recibirle. ${s(d.reason)}`],
    pt: (d) => ["Reserva recusada", `${s(d.brand_name)} não o pode receber. ${s(d.reason)}`],
    de: (d) => ["Reservierung abgelehnt", `${s(d.brand_name)} kann Sie nicht empfangen. ${s(d.reason)}`],
    ar: (d) => ["تم رفض الحجز", `لا يستطيع ${s(d.brand_name)} استقبالك. ${s(d.reason)}`],
    zh: (d) => ["预订被拒绝", `${s(d.brand_name)} 无法接待您。${s(d.reason)}`],
  },
  birthday_reward: {
    fr: (d) => ["Joyeux anniversaire !", `${s(d.organization_name)} vous offre ${s(d.points)} points.`],
    en: (d) => ["Happy birthday!", `${s(d.organization_name)} gives you ${s(d.points)} points.`],
    es: (d) => ["¡Feliz cumpleaños!", `${s(d.organization_name)} le regala ${s(d.points)} puntos.`],
    pt: (d) => ["Feliz aniversário!", `${s(d.organization_name)} oferece-lhe ${s(d.points)} pontos.`],
    de: (d) => ["Alles Gute zum Geburtstag!", `${s(d.organization_name)} schenkt Ihnen ${s(d.points)} Punkte.`],
    ar: (d) => ["عيد ميلاد سعيد!", `${s(d.organization_name)} يهديك ${s(d.points)} نقطة.`],
    zh: (d) => ["生日快乐！", `${s(d.organization_name)} 送您 ${s(d.points)} 积分。`],
  },
  group_joined: {
    fr: (d) => ["Commande groupée", `${s(d.participant_name)} a rejoint votre commande chez ${s(d.brand_name)}.`],
    en: (d) => ["Group order", `${s(d.participant_name)} joined your order at ${s(d.brand_name)}.`],
    es: (d) => ["Pedido en grupo", `${s(d.participant_name)} se unió a su pedido en ${s(d.brand_name)}.`],
    pt: (d) => ["Pedido em grupo", `${s(d.participant_name)} juntou-se ao seu pedido em ${s(d.brand_name)}.`],
    de: (d) => ["Gruppenbestellung", `${s(d.participant_name)} ist Ihrer Bestellung bei ${s(d.brand_name)} beigetreten.`],
    ar: (d) => ["طلب جماعي", `انضم ${s(d.participant_name)} إلى طلبك في ${s(d.brand_name)}.`],
    zh: (d) => ["团体订单", `${s(d.participant_name)} 加入了您在 ${s(d.brand_name)} 的订单。`],
  },
  group_placed: {
    fr: (d) => ["Commande groupée envoyée", `${s(d.host_name)} a envoyé la commande n° ${s(d.number)} chez ${s(d.brand_name)}.`],
    en: (d) => ["Group order sent", `${s(d.host_name)} sent order #${s(d.number)} at ${s(d.brand_name)}.`],
    es: (d) => ["Pedido en grupo enviado", `${s(d.host_name)} envió el pedido n.º ${s(d.number)} en ${s(d.brand_name)}.`],
    pt: (d) => ["Pedido em grupo enviado", `${s(d.host_name)} enviou o pedido n.º ${s(d.number)} em ${s(d.brand_name)}.`],
    de: (d) => ["Gruppenbestellung gesendet", `${s(d.host_name)} hat Bestellung Nr. ${s(d.number)} bei ${s(d.brand_name)} gesendet.`],
    ar: (d) => ["تم إرسال الطلب الجماعي", `أرسل ${s(d.host_name)} الطلب رقم ${s(d.number)} في ${s(d.brand_name)}.`],
    zh: (d) => ["团体订单已发送", `${s(d.host_name)} 已在 ${s(d.brand_name)} 发送订单 #${s(d.number)}。`],
  },
  promotion: {
    fr: (d) => [`${s(d.brand_name)} · ${s(d.title)}`, s(d.body)],
    en: (d) => [`${s(d.brand_name)} · ${s(d.title)}`, s(d.body)],
    es: (d) => [`${s(d.brand_name)} · ${s(d.title)}`, s(d.body)],
    pt: (d) => [`${s(d.brand_name)} · ${s(d.title)}`, s(d.body)],
    de: (d) => [`${s(d.brand_name)} · ${s(d.title)}`, s(d.body)],
    ar: (d) => [`${s(d.brand_name)} · ${s(d.title)}`, s(d.body)],
    zh: (d) => [`${s(d.brand_name)} · ${s(d.title)}`, s(d.body)],
  },
  staff_new_order: {
    fr: (d) => ["Nouvelle commande", `Commande n° ${s(d.number)}${d.customer_name ? " · " + s(d.customer_name) : ""} — ${s(d.branch_name)}`],
    en: (d) => ["New order", `Order #${s(d.number)}${d.customer_name ? " · " + s(d.customer_name) : ""} — ${s(d.branch_name)}`],
    es: (d) => ["Nuevo pedido", `Pedido n.º ${s(d.number)}${d.customer_name ? " · " + s(d.customer_name) : ""} — ${s(d.branch_name)}`],
    pt: (d) => ["Novo pedido", `Pedido n.º ${s(d.number)}${d.customer_name ? " · " + s(d.customer_name) : ""} — ${s(d.branch_name)}`],
    de: (d) => ["Neue Bestellung", `Bestellung Nr. ${s(d.number)}${d.customer_name ? " · " + s(d.customer_name) : ""} — ${s(d.branch_name)}`],
    ar: (d) => ["طلب جديد", `طلب رقم ${s(d.number)}${d.customer_name ? " · " + s(d.customer_name) : ""} — ${s(d.branch_name)}`],
    zh: (d) => ["新订单", `订单 #${s(d.number)}${d.customer_name ? " · " + s(d.customer_name) : ""} — ${s(d.branch_name)}`],
  },
  staff_order_ready: {
    fr: (d) => ["Commande prête à servir", `Commande n° ${s(d.number)} — ${s(d.branch_name)}`],
    en: (d) => ["Order ready to serve", `Order #${s(d.number)} — ${s(d.branch_name)}`],
    es: (d) => ["Pedido listo para servir", `Pedido n.º ${s(d.number)} — ${s(d.branch_name)}`],
    pt: (d) => ["Pedido pronto a servir", `Pedido n.º ${s(d.number)} — ${s(d.branch_name)}`],
    de: (d) => ["Bestellung servierbereit", `Bestellung Nr. ${s(d.number)} — ${s(d.branch_name)}`],
    ar: (d) => ["الطلب جاهز للتقديم", `طلب رقم ${s(d.number)} — ${s(d.branch_name)}`],
    zh: (d) => ["订单可上菜", `订单 #${s(d.number)} — ${s(d.branch_name)}`],
  },
  staff_new_reservation: {
    fr: (d) => ["Nouvelle réservation", `${s(d.customer_name)} · ${s(d.party_size)} pers. — ${s(d.branch_name)}`],
    en: (d) => ["New reservation", `${s(d.customer_name)} · ${s(d.party_size)} guests — ${s(d.branch_name)}`],
    es: (d) => ["Nueva reserva", `${s(d.customer_name)} · ${s(d.party_size)} pers. — ${s(d.branch_name)}`],
    pt: (d) => ["Nova reserva", `${s(d.customer_name)} · ${s(d.party_size)} pess. — ${s(d.branch_name)}`],
    de: (d) => ["Neue Reservierung", `${s(d.customer_name)} · ${s(d.party_size)} Pers. — ${s(d.branch_name)}`],
    ar: (d) => ["حجز جديد", `${s(d.customer_name)} · ${s(d.party_size)} أشخاص — ${s(d.branch_name)}`],
    zh: (d) => ["新预订", `${s(d.customer_name)} · ${s(d.party_size)} 人 — ${s(d.branch_name)}`],
  },
  staff_new_review: {
    fr: (d) => ["Nouvel avis", `${s(d.author)} sur « ${s(d.item_name)} »${d.rating ? " · " + s(d.rating) + "★" : ""}`],
    en: (d) => ["New review", `${s(d.author)} on “${s(d.item_name)}”${d.rating ? " · " + s(d.rating) + "★" : ""}`],
    es: (d) => ["Nueva opinión", `${s(d.author)} sobre «${s(d.item_name)}»${d.rating ? " · " + s(d.rating) + "★" : ""}`],
    pt: (d) => ["Nova opinião", `${s(d.author)} sobre «${s(d.item_name)}»${d.rating ? " · " + s(d.rating) + "★" : ""}`],
    de: (d) => ["Neue Bewertung", `${s(d.author)} zu „${s(d.item_name)}“${d.rating ? " · " + s(d.rating) + "★" : ""}`],
    ar: (d) => ["رأي جديد", `${s(d.author)} عن «${s(d.item_name)}»${d.rating ? " · " + s(d.rating) + "★" : ""}`],
    zh: (d) => ["新评价", `${s(d.author)} 评价了「${s(d.item_name)}」${d.rating ? " · " + s(d.rating) + "★" : ""}`],
  },
};

function lang(locale: string): Lang {
  const l = locale.toLowerCase().slice(0, 2);
  return (["fr", "en", "es", "pt", "de", "ar", "zh"].includes(l) ? l : "en") as Lang;
}

// Jeton d'accès Google (OAuth 2, compte de service), gardé en mémoire 50 min.
let cached: { token: string; until: number } | null = null;

function b64url(bytes: Uint8Array | string): string {
  const b = typeof bytes === "string" ? new TextEncoder().encode(bytes) : bytes;
  let bin = "";
  for (const c of b) bin += String.fromCharCode(c);
  return btoa(bin).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

async function accessToken(sa: { client_email: string; private_key: string }): Promise<string> {
  if (cached && cached.until > Date.now()) return cached.token;
  const now = Math.floor(Date.now() / 1000);
  const header = b64url(JSON.stringify({ alg: "RS256", typ: "JWT" }));
  const claims = b64url(JSON.stringify({
    iss: sa.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  }));
  const pem = sa.private_key.replace(/-----[^-]+-----/g, "").replace(/\s+/g, "");
  const der = Uint8Array.from(atob(pem), (c) => c.charCodeAt(0));
  const key = await crypto.subtle.importKey("pkcs8", der, { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" }, false, ["sign"]);
  const sig = new Uint8Array(await crypto.subtle.sign("RSASSA-PKCS1-v1_5", key, new TextEncoder().encode(`${header}.${claims}`)));
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: `${header}.${claims}.${b64url(sig)}`,
    }),
  });
  if (!res.ok) throw new Error(`oauth ${res.status}`);
  const json = await res.json();
  cached = { token: json.access_token, until: Date.now() + 50 * 60 * 1000 };
  return cached.token;
}

// Clé serveur fournie par Supabase : ancienne clé « service_role », ou nouvelle
// clé secrète (SUPABASE_SECRET_KEYS, objet JSON).
function serverKey(): string | undefined {
  const legacy = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (legacy) return legacy;
  try {
    const keys = JSON.parse(Deno.env.get("SUPABASE_SECRET_KEYS") ?? "{}");
    const first = Object.values(keys).find((v) => typeof v === "string");
    return first as string | undefined;
  } catch {
    return undefined;
  }
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("method", { status: 405 });
  let id = "";
  try {
    id = String((await req.json()).id ?? "");
  } catch {
    return new Response("bad request", { status: 400 });
  }
  if (!/^[0-9a-f-]{36}$/.test(id)) return new Response("bad request", { status: 400 });

  // Réglages : messages explicites (jamais le contenu d'un secret) pour le diagnostic.
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT");
  if (!raw) return new Response("config: secret FCM_SERVICE_ACCOUNT absent", { status: 503 });
  // Accepté : le fichier JSON tel quel, entouré de guillemets, ou encodé en base64.
  let sa: { project_id: string; client_email: string; private_key: string } | null = null;
  for (const candidate of [raw.trim(), raw.trim().replace(/^['"]|['"]$/g, "")]) {
    for (const text of [candidate, (() => { try { return atob(candidate); } catch { return ""; } })()]) {
      try {
        const v = JSON.parse(text);
        sa = typeof v === "string" ? JSON.parse(v) : v;
        break;
      } catch { /* format suivant */ }
    }
    if (sa) break;
  }
  if (!sa) {
    return new Response(
      `config: FCM_SERVICE_ACCOUNT n'est pas du JSON (${raw.trim().length} caractères, commence par « ${raw.trim().slice(0, 1)} ») — collez tout le fichier`,
      { status: 503 },
    );
  }
  const missing = ["project_id", "client_email", "private_key"].filter((k) => !(sa as Record<string, unknown>)[k]);
  if (missing.length) {
    return new Response(`config: FCM_SERVICE_ACCOUNT incomplet, il manque : ${missing.join(", ")} (est-ce bien la clé du compte de service ?)`, { status: 503 });
  }
  const url = Deno.env.get("SUPABASE_URL");
  const key = serverKey();
  if (!url || !key) return new Response("config: clé serveur Supabase indisponible", { status: 503 });
  const db = createClient(url, key, { auth: { persistSession: false } });

  // Une seule fois : la notification est « réservée » avant l'envoi.
  const { data: n, error } = await db.from("customer_notifications").update({ pushed_at: new Date().toISOString() })
    .eq("id", id).is("pushed_at", null).select("id, user_id, kind, data").maybeSingle();
  if (error) return new Response(`base: ${error.message}`, { status: 500 });
  if (!n) return new Response("ok");
  const { data: devices } = await db.from("push_devices").select("token, platform, locale").eq("user_id", n.user_id);
  if (!devices?.length || !texts[n.kind]) return new Response("ok");

  let token: string;
  try {
    token = await accessToken(sa);
  } catch (e) {
    return new Response(`firebase: authentification refusée (${(e as Error).message})`, { status: 502 });
  }
  const data: Record<string, string> = { notification_id: n.id, kind: n.kind };
  for (const [k, v] of Object.entries(n.data ?? {})) {
    if (["order_id", "reservation_id", "branch_id", "item_id", "campaign_id", "organization_id", "number", "channel"].includes(k)) {
      data[k] = s(v);
    }
  }
  for (const d of devices) {
    const [title, body] = texts[n.kind][lang(d.locale)](n.data ?? {});
    const res = await fetch(`https://fcm.googleapis.com/v1/projects/${sa.project_id}/messages:send`, {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
      body: JSON.stringify({
        message: {
          token: d.token,
          notification: { title, body },
          data,
          android: { priority: "high", notification: { channel_id: "resto_default", sound: "default" } },
          webpush: { notification: { icon: "/icons/Icon-192.png" } },
        },
      }),
    });
    // Jeton périmé (application désinstallée, autorisation retirée) : on l'oublie.
    if (res.status === 404 || res.status === 400) {
      const err = await res.text();
      if (err.includes("UNREGISTERED") || err.includes("not a valid FCM registration token")) {
        await db.from("push_devices").delete().eq("token", d.token);
      }
    }
  }
  return new Response("ok");
});
