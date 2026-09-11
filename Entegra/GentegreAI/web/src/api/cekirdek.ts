import {
  ApiHatasi,
  type GirisYaniti, type HataGovdesi,
  } from './sozlesme';

/**
 * TEK ISTEK NOKTASI: token, `X-Sube-Id`, 401'de otomatik yenileme.
 *
 * Uc sarmalayicilari konu bazli dosyalara (api/uclar) ayrildi; bu dosya
 * yalniz TASIMA katmanidir - hangi ucun ne dondurdugu orada yazar.
 */
export const TABAN = import.meta.env.VITE_API ?? 'http://localhost:5180';

const ANAHTAR = {
  access: 'gentegre.access',
  refresh: 'gentegre.refresh',
  sube: 'gentegre.sube',
} as const;

export const oturum = {
  get access()  { return localStorage.getItem(ANAHTAR.access) },
  get refresh() { return localStorage.getItem(ANAHTAR.refresh) },
  get subeId()  { const s = localStorage.getItem(ANAHTAR.sube); return s ? Number(s) : null },

  yaz(y: GirisYaniti) {
    localStorage.setItem(ANAHTAR.access, y.accessToken);
    if (y.refreshToken) localStorage.setItem(ANAHTAR.refresh, y.refreshToken);
    if (y.kullanici?.subeId) localStorage.setItem(ANAHTAR.sube, String(y.kullanici.subeId));
  },
  subeYaz(id: number) { localStorage.setItem(ANAHTAR.sube, String(id)) },
  temizle() { Object.values(ANAHTAR).forEach(a => localStorage.removeItem(a)) },
};

/**
 * Tek istek noktasi.
 *  - Access token 30 dk; 401 gelirse refresh ile BIR KEZ yenilenip istek tekrarlanir.
 *  - Es zamanli 401'lerde tek yenileme yapilir (yoksa rotation zinciri kirilir ve
 *    sunucu "tekrar kullanim" sayip TUM oturumu iptal eder).
 */
let yenilemeIslemi: Promise<boolean> | null = null;

async function yenile(): Promise<boolean> {
  const refresh = oturum.refresh;
  if (!refresh) return false;

  yenilemeIslemi ??= (async () => {
    try {
      const yanit = await fetch(`${TABAN}/api/kimlik/yenile`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken: refresh }),
      });
      // OTURUMU YALNIZ SUNUCU REDDEDINCE SIL (401/403). Sunucu yeniden
      //   baslarken (502/503) ya da gecici hata verirken token silmek
      //   calisan herkesi disari atiyordu - kullanici hicbir sey yapmadigi
      //   halde giris ekranina duser ve yazdigi form kaybolurdu.
      if (yanit.status === 401 || yanit.status === 403) { oturum.temizle(); return false }
      if (!yanit.ok) return false;
      oturum.yaz(await yanit.json() as GirisYaniti);
      return true;
    } catch {
      return false;
    } finally {
      setTimeout(() => { yenilemeIslemi = null }, 0);
    }
  })();

  return yenilemeIslemi;
}

/**
 * TEK CEKIRDEK: basliklar + 401 yenileme + hata govdesi cozumleme.
 *
 * Bu uc adim uc ayri fonksiyonda (istek / dosyaYukle / dosyaIndir) kopyalanmisti
 * ve kopyalar ayrismisti: indirme 401'de YENILEMIYORDU, yani token'in suresi
 * dolduktan sonra ilk dosya indirme/onizleme sessizce basarisiz oluyordu.
 * Cekirdek tekleserek o bosluk da kapandi.
 */
async function ham(yol: string, secenek: RequestInit, jsonGovde: boolean,
                   tekrar = true): Promise<Response> {
  const basliklar: Record<string, string> = {
    ...(jsonGovde ? { 'Content-Type': 'application/json' } : {}),
    ...(secenek.headers as Record<string, string> ?? {}),
  };
  if (oturum.access) basliklar.Authorization = `Bearer ${oturum.access}`;
  // Aktif sube her istekte tasinir; sunucu yetkiyi yine de kendisi dogrular.
  if (oturum.subeId) basliklar['X-Sube-Id'] = String(oturum.subeId);

  const yanit = await fetch(`${TABAN}${yol}`, { ...secenek, headers: basliklar });

  if (yanit.status === 401 && tekrar && await yenile())
    return ham(yol, secenek, jsonGovde, false);

  if (!yanit.ok) {
    let govde: HataGovdesi;
    try {
      govde = ((await yanit.json()) as { hata: HataGovdesi }).hata;
    } catch {
      govde = { kod: 'SUNUCU', mesaj: `Sunucuya ulasilamadi (${yanit.status}).`, izlemeNo: '' };
    }
    throw new ApiHatasi(yanit.status, govde);
  }
  return yanit;
}


export async function istek<T>(yol: string, secenek: RequestInit = {}): Promise<T> {
  const yanit = await ham(yol, secenek, true);
  if (yanit.status === 204) return undefined as T;
  return yanit.json() as Promise<T>;
}

export const gonder = <T,>(yol: string, govde: unknown, yontem = 'POST') =>
  istek<T>(yol, { method: yontem, body: JSON.stringify(govde) });

/** Dosya yukleme - "Content-Type: application/json" KOYULMAZ,
 *  tarayici FormData icin dogru multipart boundary'yi kendisi ekler. */
export async function dosyaYukle<T>(yol: string, form: FormData): Promise<T> {
  const yanit = await ham(yol, { method: 'POST', body: form }, false);
  return yanit.json() as Promise<T>;
}

/** İçerik indirme - blob URL doner, <img>/indirme icin (Authorization header ile, token URL'e sizmaz). */
export async function dosyaIndir(yol: string): Promise<string> {
  const yanit = await ham(yol, {}, false);
  return URL.createObjectURL(await yanit.blob());
}

