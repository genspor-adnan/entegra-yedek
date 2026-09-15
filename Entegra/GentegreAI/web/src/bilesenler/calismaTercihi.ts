import { api } from '../api/istemci';

/**
 * ÇALIŞMA TERCİHLERİ (mockup kullanici_ayarlari.html › Hesabım › Çalışma
 * Tercihleri): açılış şubesi ve açılış ekranı.
 *
 * `gorunum.ts` ile aynı desen: sunucuda `kullanici_tercih` (anahtar
 * "calisma"), tarayıcıda AYNA. Ayna açılışta anında okunur - açılış ekranı
 * ilk yönlendirmede (App.ilkYol) lazım, sunucu cevabı o ana yetişmez.
 *
 * Tarih biçimi / sayı ayıracı / oturum süresi BURADA DEĞİL: onlar şubenin
 * (kurumun) ayarıdır, kişi değiştiremez - pencerede gri gösterilir.
 */
export interface CalismaTercihi {
  /** 0 = son kullanılan şube (varsayılan davranış). */
  acilisSube: number;
  /** Rota ('' = ana sayfa / ilk erişilebilir ekran). */
  acilisEkran: string;
}

const VARSAYILAN: CalismaTercihi = { acilisSube: 0, acilisEkran: '' };
const AYNA = 'gentegre.calisma';

let mevcut: CalismaTercihi = aynadanOku();

function aynadanOku(): CalismaTercihi {
  try {
    const ham = localStorage.getItem(AYNA);
    return ham ? duzelt(JSON.parse(ham)) : { ...VARSAYILAN };
  } catch { return { ...VARSAYILAN } }
}

function duzelt(h: unknown): CalismaTercihi {
  const o = (h ?? {}) as Partial<CalismaTercihi>;
  const sube = Number(o.acilisSube);
  return {
    acilisSube: Number.isFinite(sube) && sube > 0 ? sube : 0,
    acilisEkran: typeof o.acilisEkran === 'string' ? o.acilisEkran.replace(/^\/+/, '').slice(0, 60) : '',
  };
}

export function calismaOku(): CalismaTercihi { return mevcut }

export function calismaUygula(t: CalismaTercihi) {
  mevcut = t;
  try { localStorage.setItem(AYNA, JSON.stringify(t)) } catch { /* yoksay */ }
}

/** Oturum açılışında: aynayı tut, sunucudakini getir. Sonucu döner (açılış şubesi için). */
export async function calismaYukle(tercihler?: Record<string, string>): Promise<CalismaTercihi> {
  try {
    const t = tercihler ?? await api.tercihler();
    if (t.calisma) calismaUygula(duzelt(JSON.parse(t.calisma)));
  } catch { /* tercih okunamadi: ayna/varsayilan yeterli */ }
  return mevcut;
}

export async function calismaKaydet(t: CalismaTercihi) {
  calismaUygula(duzelt(t));
  await api.tercihYaz('calisma', JSON.stringify(mevcut));
}

/**
 * AÇILIŞ ŞUBESİ BİR KEZ uygulanır: oturum başına tek sefer (sessionStorage
 * bayrağı). Yoksa kullanıcı üst şeritten şube değiştirip sayfayı yenilediğinde
 * tercih onu tekrar açılış şubesine atardı.
 */
export function acilisSubesiGerekliMi(t: CalismaTercihi, aktifSube: number | null | undefined,
                                      subeler: { id: number }[]): boolean {
  if (!t.acilisSube || t.acilisSube === aktifSube) return false;
  if (!subeler.some(s => s.id === t.acilisSube)) return false;
  try {
    if (sessionStorage.getItem('gentegre.acilisSube') === '1') return false;
    sessionStorage.setItem('gentegre.acilisSube', '1');
  } catch { /* gizli sekme: her yenilemede uygulanır, kabul */ }
  return true;
}
