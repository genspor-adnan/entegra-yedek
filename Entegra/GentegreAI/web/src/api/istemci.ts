import {
  ApiHatasi,
  type BenYaniti, type GirisYaniti, type HataGovdesi,
  type AksiyonListesi, type KartMetaYaniti, type KartYaniti, type KartYazmaIstegi, type KolonMeta,
  type ListeIstegi, type ListeYaniti, type BelgeYaniti,
} from './sozlesme';

const TABAN = import.meta.env.VITE_API ?? 'http://localhost:5180';

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
      if (!yanit.ok) { oturum.temizle(); return false }
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

async function istek<T>(yol: string, secenek: RequestInit = {}, tekrar = true): Promise<T> {
  const basliklar: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(secenek.headers as Record<string, string> ?? {}),
  };
  if (oturum.access) basliklar.Authorization = `Bearer ${oturum.access}`;
  // Aktif sube her istekte tasinir; sunucu yetkiyi yine de kendisi dogrular.
  if (oturum.subeId) basliklar['X-Sube-Id'] = String(oturum.subeId);

  const yanit = await fetch(`${TABAN}${yol}`, { ...secenek, headers: basliklar });

  if (yanit.status === 401 && tekrar && await yenile())
    return istek<T>(yol, secenek, false);

  if (!yanit.ok) {
    let govde: HataGovdesi;
    try {
      govde = ((await yanit.json()) as { hata: HataGovdesi }).hata;
    } catch {
      govde = { kod: 'SUNUCU', mesaj: `Sunucuya ulasilamadi (${yanit.status}).`, izlemeNo: '' };
    }
    throw new ApiHatasi(yanit.status, govde);
  }

  if (yanit.status === 204) return undefined as T;
  return yanit.json() as Promise<T>;
}

const gonder = <T,>(yol: string, govde: unknown, yontem = 'POST') =>
  istek<T>(yol, { method: yontem, body: JSON.stringify(govde) });

export const api = {
  // ------------------------------------------------------------- kimlik ----
  giris: (kod: string, parola: string, subeId?: number) =>
    gonder<GirisYaniti>('/api/kimlik/giris', { kod, parola, subeId }),

  cikis: async () => {
    const refresh = oturum.refresh;
    if (refresh) { try { await gonder('/api/kimlik/cikis', { refreshToken: refresh }) } catch { /* yoksay */ } }
    oturum.temizle();
  },

  ben: () => istek<BenYaniti>('/api/kimlik/ben'),

  subeSec: (subeId: number) =>
    istek<GirisYaniti>('/api/kimlik/sube', {
      method: 'POST',
      body: JSON.stringify({ subeId }),
      headers: oturum.refresh ? { 'X-Refresh-Token': oturum.refresh } : {},
    }),

  parolaDegistir: (eskiParola: string, yeniParola: string) =>
    gonder<void>('/api/kimlik/parola', { eskiParola, yeniParola }),

  // -------------------------------------------------------------- liste ----
  liste: (kaynak: string, istekGovdesi: ListeIstegi) =>
    gonder<ListeYaniti>(`/api/liste/${kaynak}`, istekGovdesi),

  kolonlar: (kaynak: string) =>
    istek<{ kaynak: string; kolonlar: KolonMeta[] }>(`/api/liste/${kaynak}/kolonlar`),

  kaynaklar: () => istek<{ kaynaklar: { ad: string; yetkiKodu: string }[] }>('/api/liste'),

  // --------------------------------------------------------------- kart ----
  kartAlanlari: (kaynak: string) => istek<KartMetaYaniti>(`/api/kart/${kaynak}/alanlar`),
  kartOku: (kaynak: string, id: number) => istek<KartYaniti>(`/api/kart/${kaynak}/${id}`),
  kartEkle: (kaynak: string, govde: KartYazmaIstegi) =>
    gonder<KartYaniti>(`/api/kart/${kaynak}`, govde),
  kartGuncelle: (kaynak: string, id: number, govde: KartYazmaIstegi) =>
    gonder<KartYaniti>(`/api/kart/${kaynak}/${id}`, govde, 'PUT'),
  kartSil: (kaynak: string, id: number) =>
    istek<void>(`/api/kart/${kaynak}/${id}`, { method: 'DELETE' }),
  kartlar: () => istek<{ kartlar: { ad: string; ekle: boolean; degistir: boolean; sil: boolean }[] }>('/api/kart'),

  // ------------------------------------------------------------ aksiyon ----
  aksiyonlar: (ekran: string, kayitId?: number) =>
    istek<AksiyonListesi>(`/api/aksiyon/${ekran}` + (kayitId ? `?kayitId=${kayitId}` : '')),

  // -------------------------------------------------------------- belge ----
  belgeOku: (id: number) => istek<BelgeYaniti>(`/api/belge/${id}`),
  belgeEkle: (govde: unknown) => gonder<BelgeYaniti>('/api/belge', govde),
};
