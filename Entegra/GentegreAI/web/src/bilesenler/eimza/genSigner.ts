import type { EImzaKart, EImzaSertifika } from '../../api/uclar/eimza';

/**
 * GenSigner (Sign-Server) İSTEMCİ KİPİ: kart hekimin bilgisayarında, GenSigner orada (varsayılan
 * http://localhost:51919). Tarayıcı doğrudan gider; PIN yalnız bu makinedeki araca verilir, sunucuya gitmez.
 *
 * GenSigner'ın CORS'u açık olmalı (Sign-Server/config/application.properties: quarkus.http.cors.* - Beni Oku.txt).
 * Tarayıcı HTTPS sayfadan http://localhost'a gidebilir (localhost "güvenilir köken" sayılır).
 */
export async function genSignerSertifikalar(url: string, apiKey: string): Promise<EImzaSertifika[]> {
  const y = await cagir<{ success: boolean; data?: EImzaSertifika[]; message?: string }>(
    url, '/api/sign/certificates', apiKey, { method: 'GET' });
  if (!y.success) throw new Error(y.message || 'GenSigner sertifika listesi vermedi.');
  return y.data ?? [];
}

/** Belgeyi (base64) XAdES enveloping imzalar; imzalı XML'in base64'ünü döner. */
export async function genSignerImzala(url: string, apiKey: string, kart: EImzaKart, pin: string,
                                      bytesBase64Encoded: string, mimeType: string): Promise<string> {
  const y = await cagir<{ success: boolean; data?: string; message?: string }>(
    url, '/api/sign/document', apiKey, {
      method: 'POST', headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ libraryAlias: kart.libraryAlias, slotId: kart.slotId, serial: kart.serial, pin,
                             mimeType, bytesBase64Encoded, acceptExpiredCerts: false }),
    });
  if (!y.success || !y.data) throw new Error(y.message || 'GenSigner imzalamadı.');
  return y.data;
}

async function cagir<T>(url: string, yol: string, apiKey: string, secenek: RequestInit): Promise<T> {
  let yanit: Response;
  try {
    yanit = await fetch(url.replace(/\/+$/, '') + yol, {
      ...secenek, headers: { ...(secenek.headers as Record<string, string> | undefined), 'X-Api-Key': apiKey },
    });
  } catch {
    throw new Error(`e-İmza aracına (GenSigner, ${url}) ulaşılamadı. Bu bilgisayarda GenSigner çalışıyor mu, CORS açık mı?`);
  }
  const metin = await yanit.text();
  if (!yanit.ok) throw new Error(`GenSigner ${yanit.status}: ${metin.slice(0, 300) || yanit.statusText}`);
  try { return JSON.parse(metin) as T; }
  catch { throw new Error('GenSigner yanıtı JSON değil: ' + metin.slice(0, 120)); }
}

/** UTF-8 metni base64'e çevirir (büyük belgede btoa/unicode sorunu olmadan). */
export function utf8Base64(metin: string): string {
  const bayt = new TextEncoder().encode(metin);
  let s = '';
  const parca = 0x8000;
  for (let i = 0; i < bayt.length; i += parca) s += String.fromCharCode(...bayt.subarray(i, i + parca));
  return btoa(s);
}
