import {
  ApiHatasi,
  type GirisYaniti, type HataGovdesi,
  } from './sozlesme';
import { hataIziKaydet } from './hataIzi';

/**
 * TEK ISTEK NOKTASI: token, `X-Sube-Id`, 401'de otomatik yenileme.
 *
 * Uc sarmalayicilari konu bazli dosyalara (api/uclar) ayrildi; bu dosya
 * yalniz TASIMA katmanidir - hangi ucun ne dondurdugu orada yazar.
 */
/**
 * API taban adresi. Normalde derleme zamanında (`VITE_API`) sabittir, ama
 * **GenProfil** aracı adresi kullanıcıdan alır: teknisyen hangi kurumun
 * sunucusuna bağlanacağını girişte yazar. Bu yüzden `let` ve
 * {@link tabanAyarla} - ESM canlı bağlama sayesinde içe alan modüller yeni
 * değeri görür.
 */
export let TABAN = import.meta.env.VITE_API ?? 'http://localhost:5180';

/** Sonundaki `/` ve `/api` eki atılır: kullanıcı ikisini de yazabilir. */
export function tabanAyarla(adres: string) {
  TABAN = adres.trim().replace(/\/+$/, '').replace(/\/api$/i, '');
}

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
  /** Saklanan sube artik yetkili degilse (403) secim birakilir; oturum kalir. */
  subeSil() { localStorage.removeItem(ANAHTAR.sube) },
  temizle() { Object.values(ANAHTAR).forEach(a => localStorage.removeItem(a)) },
};

/**
 * Tek istek noktasi.
 *  - Access token 30 dk; 401 gelirse refresh ile BIR KEZ yenilenip istek tekrarlanir.
 *  - Es zamanli 401'lerde tek yenileme yapilir (yoksa rotation zinciri kirilir ve
 *    sunucu "tekrar kullanim" sayip TUM oturumu iptal eder).
 */
let yenilemeIslemi: Promise<boolean> | null = null;

/** Tarayici sekmeleri arasi kilit (Web Locks) - yoksa yalniz sekme ici birlestirme. */
type Kilitler = { request<T>(ad: string, f: () => Promise<T>): Promise<T> };
const kilitler = (): Kilitler | undefined =>
  (globalThis.navigator as { locks?: Kilitler } | undefined)?.locks;

/**
 * @param kullanilanAccess 401 alan istegin tasidigi access token. Kilit
 *   beklenirken baska sekme yenilediyse depodaki token artik farklidir; bu
 *   durumda sunucuya GITMEDEN yeni token'la tekrar denenir.
 */
async function yenile(kullanilanAccess?: string | null): Promise<boolean> {
  if (!oturum.refresh) return false;

  yenilemeIslemi ??= (async () => {
    try {
      // SEKMELER ARASI TEK YENILEME (denetim 28.09.2026 #6): iki sekme ayni
      //   refresh ile yenilerse sunucu ikincisini "tekrar kullanim" sayar ve
      //   AILEYI iptal eder - iki sekme de disari duser. Sunucu korumasi
      //   dogru; cozum istemcilerin ayni anda yenilememesi. Kilidi alan
      //   sekme once bakar: token kilit beklenirken yenilendiyse yeter.
      const calis = async (): Promise<boolean> => {
        if (kullanilanAccess !== undefined && oturum.access && oturum.access !== kullanilanAccess)
          return true;
        return sunucudaYenile();
      };
      const k = kilitler();
      return k ? await k.request('gentegre.yenile', calis) : await calis();
    } finally {
      setTimeout(() => { yenilemeIslemi = null }, 0);
    }
  })();

  return yenilemeIslemi;
}

async function sunucudaYenile(): Promise<boolean> {
  const refresh = oturum.refresh;
  if (!refresh) return false;
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
  }
}

/**
 * OTURUM TAZELEME SINYALI: sunucu hesabin durumunun degistigini soyledi
 * (or. parola degistirme zorunlu hale geldi). Oturum baglami dinler ve
 * /ben'i yeniden okur - ekran kendi kararini sunucudan alir.
 */
export const OTURUM_TAZELE_OLAYI = 'gentegre:oturum-tazele';

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
  const access = oturum.access;
  if (access) basliklar.Authorization = `Bearer ${access}`;
  // Aktif sube her istekte tasinir; sunucu yetkiyi yine de kendisi dogrular.
  if (oturum.subeId) basliklar['X-Sube-Id'] = String(oturum.subeId);

  const yanit = await fetch(`${TABAN}${yol}`, { ...secenek, headers: basliklar });

  if (yanit.status === 401 && tekrar && await yenile(access))
    return ham(yol, secenek, jsonGovde, false);

  if (!yanit.ok) {
    let govde: HataGovdesi;
    try {
      govde = ((await yanit.json()) as { hata: HataGovdesi }).hata;
    } catch {
      govde = { kod: 'SUNUCU', mesaj: `Sunucuya ulasilamadi (${yanit.status}).`, izlemeNo: '' };
    }
    // SON HATA İZİ (871): yalnız kod - asistan "bu hata ne demek" diye açıklar.
    hataIziKaydet(govde.kod, (govde.engel as { kod?: string } | undefined)?.kod);
    // Parola degisimi oturum sirasinda zorunlu olduysa ekran /ben'i
    //   yeniden okusun: parola ekrani sunucunun kararina gore acilir.
    if (govde.kod === 'PAROLA_DEGISMELI' && typeof window !== 'undefined')
      window.dispatchEvent(new Event(OTURUM_TAZELE_OLAYI));
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

