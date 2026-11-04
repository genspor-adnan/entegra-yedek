import { createWorker, OEM, PSM, type Worker } from 'tesseract.js';

/**
 * MRZ OCR - TARAYICIDA (1255). Kimlik görüntüsü sunucuya GİTMEZ (KVKK): tesseract.js (WASM) kameradan / dosyadan
 * gelen kareyi tarayıcıda okur, yalnız çözülen 2-3 satır metin `POST /api/kimlik/mrz-coz`a gider.
 *
 * Dosyalar: işçi + çekirdek `ocr/` altından (vite eklentisi `ocr.ts` node_modules'tan kopyalar - CSP `worker-src
 * 'self' blob:` ve `connect-src 'self'` CDN'e izin vermez). Dil verisi `ocr/eng.traineddata.gz` (public/ocr) -
 * yoksa geliştirmede CDN'den denenir; yayında CSP engeller ve kullanıcıya "MRZ metnini yapıştır" yolu kalır.
 *
 * OCR-B yazı tipi için ayrı eğitim yok: `eng` + karakter beyaz listesi (A-Z 0-9 <) MRZ'de yeterli çıkıyor; güven
 * eşiği (kayit.ocr_esik) düşük okumayı eler, kontrol haneleri sunucuda son sözü söyler.
 */
const KOK = `${import.meta.env.BASE_URL}ocr/`;
const BEYAZ_LISTE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<';

let isciSozu: Promise<Worker> | null = null;

async function kur(langPath: string | undefined): Promise<Worker> {
  const w = await createWorker('eng', OEM.LSTM_ONLY, { workerPath: `${KOK}worker.min.js`, corePath: KOK, langPath, logger: () => {} });
  await w.setParameters({ tessedit_char_whitelist: BEYAZ_LISTE, tessedit_pageseg_mode: PSM.SINGLE_BLOCK, preserve_interword_spaces: '0' });
  return w;
}

/**
 * Yerel dil dosyası var mı (`ocr/eng.traineddata.gz`). Dosya yokken işçiyi kurmak olmaz: tesseract.js dil yüklenemeyince
 * hata fırlatmıyor, sonsuza dek bekliyor. Geliştirme sunucusu bilinmeyen yola index.html döner - içerik tipine bakılır.
 */
async function yerelDilVar(): Promise<boolean> {
  try {
    const r = await fetch(`${KOK}eng.traineddata.gz`, { method: 'HEAD', cache: 'no-store' });
    return r.ok && !(r.headers.get('content-type') ?? '').includes('text/html');
  } catch { return false }
}

function zamanAsimi<T>(soz: Promise<T>, ms: number, mesaj: string): Promise<T> {
  return new Promise<T>((cozul, red) => {
    const z = window.setTimeout(() => red(new Error(mesaj)), ms);
    soz.then(v => { window.clearTimeout(z); cozul(v) }, h => { window.clearTimeout(z); red(h) });
  });
}

/** Tek işçi, tembel kurulum; kurulamazsa bir sonraki çağrı yeniden dener. */
export function ocrIsci(): Promise<Worker> {
  isciSozu ??= (async () => {
    try {
      // Yerel dil dosyası yoksa geliştirmede CDN'den (tesseract.js varsayılanı); yayında CSP engeller - zaman aşımı
      //   açık mesajla döner, kullanıcıya MRZ metnini yapıştırma yolu kalır.
      const yerel = await yerelDilVar();
      return await zamanAsimi(kur(yerel ? KOK : undefined), 90_000,
        yerel ? 'OCR motoru yüklenemedi (ocr/ dosyaları).'
              : 'OCR dil dosyası bulunamadı (web/public/ocr/eng.traineddata.gz) - MRZ metnini yapıştırın ya da okuyucu cihaz kullanın; dosyayı yönetici ekler.');
    } catch (h) { isciSozu = null; throw h }
  })();
  return isciSozu;
}

export interface OcrSonucu { metin: string; guven: number; satirlar: string[] }

/** OCR metninden MRZ adayı satırlar: büyük harf, boşluksuz, benzer işaretler '<', 20+ karakter ve yalnız A-Z 0-9 <. */
export function mrzSatirlari(metin: string): string[] {
  return metin.split(/\r?\n/)
    .map(s => s.toUpperCase().replace(/[«‹〈《≪]/g, '<').replace(/\s+/g, '')
      .replace(/İ/g, 'I').replace(/Ş/g, 'S').replace(/Ğ/g, 'G').replace(/Ü/g, 'U').replace(/Ö/g, 'O').replace(/Ç/g, 'C'))
    .filter(s => s.length >= 20 && /^[A-Z0-9<]+$/.test(s));
}

/**
 * Kareyi okur. Önce gri + kontrast gerilmesi (OCR-B siyah-beyaz baskı; yansıma / gölge düzleşir), genişlik ~1400 px.
 */
export async function mrzOku(kaynak: HTMLCanvasElement | HTMLImageElement | HTMLVideoElement,
                             kesit?: { x: number; y: number; w: number; h: number }): Promise<OcrSonucu> {
  const tuval = hazirla(kaynak, kesit);
  const isci = await ocrIsci();
  const { data } = await isci.recognize(tuval, {}, { text: true, blocks: true });
  const satirlar = mrzSatirlari(data.text ?? '');
  // Güven: sayfa güveni 0 gelebiliyor (v7, beyaz listeli okuma) - kelime güvenlerinin ortalaması alınır.
  let guven = data.confidence ?? 0;
  if (!guven && data.blocks) {
    const kelimeler = data.blocks.flatMap(b => b.paragraphs.flatMap(p => p.lines.flatMap(l => l.words)));
    if (kelimeler.length) guven = kelimeler.reduce((t, w) => t + (w.confidence ?? 0), 0) / kelimeler.length;
  }
  return { metin: data.text ?? '', guven: Math.round(guven), satirlar };
}

function hazirla(kaynak: HTMLCanvasElement | HTMLImageElement | HTMLVideoElement,
                 kesit?: { x: number; y: number; w: number; h: number }): HTMLCanvasElement {
  const kw = kaynak instanceof HTMLVideoElement ? kaynak.videoWidth : kaynak instanceof HTMLImageElement ? kaynak.naturalWidth : kaynak.width;
  const kh = kaynak instanceof HTMLVideoElement ? kaynak.videoHeight : kaynak instanceof HTMLImageElement ? kaynak.naturalHeight : kaynak.height;
  const k = kesit ?? { x: 0, y: 0, w: kw, h: kh };
  const olcek = Math.min(2.5, Math.max(1, 1400 / Math.max(1, k.w)));
  const tuval = document.createElement('canvas');
  tuval.width = Math.round(k.w * olcek); tuval.height = Math.round(k.h * olcek);
  const ctx = tuval.getContext('2d', { willReadFrequently: true })!;
  ctx.imageSmoothingEnabled = true; ctx.imageSmoothingQuality = 'high';
  ctx.drawImage(kaynak, k.x, k.y, k.w, k.h, 0, 0, tuval.width, tuval.height);
  // Gri + kontrast gerilmesi (yüzde 2-98 arası).
  const im = ctx.getImageData(0, 0, tuval.width, tuval.height); const d = im.data;
  const hist = new Uint32Array(256);
  for (let i = 0; i < d.length; i += 4) { const g = (d[i] * 299 + d[i + 1] * 587 + d[i + 2] * 114) / 1000; d[i] = g; hist[g | 0]++ }
  const n = d.length / 4; let alt = 0, ust = 255, top = 0;
  for (let i = 0; i < 256; i++) { top += hist[i]; if (top >= n * 0.02) { alt = i; break } }
  top = 0; for (let i = 255; i >= 0; i--) { top += hist[i]; if (top >= n * 0.02) { ust = i; break } }
  const aralik = Math.max(1, ust - alt);
  for (let i = 0; i < d.length; i += 4) {
    const g = Math.max(0, Math.min(255, ((d[i] - alt) * 255) / aralik));
    d[i] = d[i + 1] = d[i + 2] = g;
  }
  ctx.putImageData(im, 0, 0);
  return tuval;
}
