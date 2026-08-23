import {
  ApiHatasi,
  type BenYaniti, type GirisYaniti, type HataGovdesi,
  type AksiyonListesi, type KartMetaYaniti, type KartYaniti, type KartYazmaIstegi, type KolonMeta,
  type ListeIstegi, type ListeYaniti, type BelgeYaniti,
  type KisiKaydi, type KisiIstegi, type YerlerYaniti,
  type KasaIslemTuru, type KasaIslemYaniti, type KasaIslemYazmaIstegi, type FisOzeti,
  type AcikSatir,
  type YetkiSatiri, type YetkiSatiriIstegi, type DokumanSatiri,
  type StokDurumYaniti, type StokHareketYaniti, type AyarSatiri, type YardimKaydi,
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

/** Dosya yukleme - istek()'in sabit "Content-Type: application/json" basligini KOYMAZ,
 *  tarayici FormData icin dogru multipart boundary'yi kendisi ekler. */
async function dosyaYukle<T>(yol: string, form: FormData, tekrar = true): Promise<T> {
  const basliklar: Record<string, string> = {};
  if (oturum.access) basliklar.Authorization = `Bearer ${oturum.access}`;
  if (oturum.subeId) basliklar['X-Sube-Id'] = String(oturum.subeId);

  const yanit = await fetch(`${TABAN}${yol}`, { method: 'POST', headers: basliklar, body: form });

  if (yanit.status === 401 && tekrar && await yenile())
    return dosyaYukle<T>(yol, form, false);

  if (!yanit.ok) {
    let govde: HataGovdesi;
    try {
      govde = ((await yanit.json()) as { hata: HataGovdesi }).hata;
    } catch {
      govde = { kod: 'SUNUCU', mesaj: `Sunucuya ulasilamadi (${yanit.status}).`, izlemeNo: '' };
    }
    throw new ApiHatasi(yanit.status, govde);
  }
  return yanit.json() as Promise<T>;
}

/** İçerik indirme - blob URL doner, <img>/indirme icin (Authorization header ile, token URL'e sizmaz). */
async function dosyaIndir(yol: string): Promise<string> {
  const basliklar: Record<string, string> = {};
  if (oturum.access) basliklar.Authorization = `Bearer ${oturum.access}`;
  const yanit = await fetch(`${TABAN}${yol}`, { headers: basliklar });
  if (!yanit.ok) throw new ApiHatasi(yanit.status, { kod: 'SUNUCU', mesaj: 'Dosya alınamadı.', izlemeNo: '' });
  return URL.createObjectURL(await yanit.blob());
}

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

  dilDegistir: (dil: number) =>
    gonder<void>('/api/kimlik/dil', { dil }),

  // -------------------------------------------------------------- liste ----
  liste: (kaynak: string, istekGovdesi: ListeIstegi) =>
    gonder<ListeYaniti>(`/api/liste/${kaynak}`, istekGovdesi),

  kolonlar: (kaynak: string) =>
    istek<{ kaynak: string; kolonlar: KolonMeta[] }>(`/api/liste/${kaynak}/kolonlar`),

  /** "Son / Sik Aranan" sayacini artirir - kart acilisi disindaki secimler icin
   *  (or. belge kalemine stok secmek). Hata yutulur: sayac akisi bloklamamali. */
  aramaIsaretle: (kaynak: string, id: number) =>
    gonder<{ isaretlendi: boolean }>(`/api/liste/${kaynak}/${id}/isaretle`, {})
      .catch(() => ({ isaretlendi: false })),

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

  // ------------------------------------------------ cari > ilgili kisiler ----
  kisiler: (tarafId: number) => istek<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler`),
  kisiEkle: (tarafId: number, govde: KisiIstegi) =>
    gonder<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler`, govde),
  kisiGuncelle: (tarafId: number, kisiId: number, govde: KisiIstegi) =>
    gonder<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler/${kisiId}`, govde, 'PUT'),
  kisiSil: (tarafId: number, kisiId: number) =>
    istek<void>(`/api/kart/cari/${tarafId}/kisiler/${kisiId}`, { method: 'DELETE' }),
  kisiBagla: (tarafId: number, kisiId: number) =>
    gonder<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler/${kisiId}/bagla`, {}),
  kisiKopar: (tarafId: number, kisiId: number) =>
    gonder<KisiKaydi[]>(`/api/kart/cari/${tarafId}/kisiler/${kisiId}/kopar`, {}),

  // ------------------------------------------------------- rol > yetkiler ----
  rolYetkileri: (rolId: number) => istek<YetkiSatiri[]>(`/api/kart/rol/${rolId}/yetkiler`),
  rolYetkiKaydet: (rolId: number, satirlar: YetkiSatiriIstegi[]) =>
    gonder<YetkiSatiri[]>(`/api/kart/rol/${rolId}/yetkiler`, { satirlar }, 'PUT'),

  // ------------------------------------------------------------- dokuman ----
  dokumanlar: (kartAdi: string, kaynakId: number) =>
    istek<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}`),
  dokumanYukle: (kartAdi: string, kaynakId: number, dosya: File, varsayilan: boolean) => {
    const form = new FormData();
    form.append('dosya', dosya);
    form.append('varsayilan', varsayilan ? 'true' : 'false');
    return dosyaYukle<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}`, form);
  },
  dokumanVarsayilanYap: (kartAdi: string, kaynakId: number, dokumanId: number) =>
    gonder<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}/varsayilan`, {}),
  dokumanDuzenle: (kartAdi: string, kaynakId: number, dokumanId: number, ad: string, belgeTuru: string) =>
    istek<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}`, { method: 'PUT', body: JSON.stringify({ ad, belgeTuru }) }),
  dokumanSil: (kartAdi: string, kaynakId: number, dokumanId: number) =>
    istek<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}`, { method: 'DELETE' }),
  dokumanIcerikUrl: (dokumanId: number) => dosyaIndir(`/api/dokuman-icerik/${dokumanId}`),
  dokumanPaylas: async (kartAdi: string, kaynakId: number, dokumanId: number) => {
    const { kod } = await gonder<{ kod: string }>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}/paylas`, {});
    return `${TABAN}/api/dokuman-paylasim/${kod}`;
  },

  // ----------------------------------------------------------- referans ----
  yerler: () => istek<YerlerYaniti>('/api/referans/yerler'),

  // ------------------------------------------------------------ aksiyon ----
  aksiyonlar: (ekran: string, kayitId?: number) =>
    istek<AksiyonListesi>(`/api/aksiyon/${ekran}` + (kayitId ? `?kayitId=${kayitId}` : '')),

  // -------------------------------------------------------------- belge ----
  belgeOku: (id: number) => istek<BelgeYaniti>(`/api/belge/${id}`),
  belgeEkle: (govde: unknown) => gonder<BelgeYaniti>('/api/belge', govde),

  /** Donusturulmeyi bekleyen satirlar (siparis/irsaliye kalanlari). */
  belgeAcikSatirlar: (id: number) =>
    istek<{ satirlar: AcikSatir[] }>(`/api/belge/${id}/acik-satirlar`).then(y => y.satirlar),

  /** Bu belgeden turetilmis belgeler (irsaliye kartinin Faturalama sekmesi). */
  belgeDonusumler: (id: number) =>
    istek<{ belgeler: Record<string, unknown>[] }>(`/api/belge/${id}/donusumler`)
      .then(y => y.belgeler),

  /** Siparis -> irsaliye -> fatura. Miktar KISMI olabilir; kalan kaynakta durur. */
  belgeDonustur: (id: number, hedefTur: number,
                  satirlar: { satirId: number; miktar: number }[],
                  belgeTarihi?: string, taslak = false, belgeNo?: string) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/donustur`,
                        { hedefTur, satirlar, belgeTarihi, taslak, belgeNo }),

  // ------------------------------------------ stok karti: Stok Durumu ----
  /** Depo bazli miktar/rezerve/kullanilabilir + KPI seridi (salt okunur). */
  stokDurum: (stokId: number) =>
    istek<StokDurumYaniti>(`/api/kart/stok/${stokId}/durum`),

  /** Hareket dokumu: tarih araligi + depo suzgeci, yurumeli kalan. */
  stokHareket: (stokId: number, bas: string, bit: string, depoId?: number | null) =>
    istek<StokHareketYaniti>(`/api/kart/stok/${stokId}/hareket?bas=${bas}&bit=${bit}`
      + (depoId ? `&depoId=${depoId}` : '')),

  /** Depo bazli min/max seviye (099). Miktarlara DOKUNMAZ. */
  stokDurumLimit: (stokId: number, depoId: number,
                   minStok: number | null, maxStok: number | null) =>
    gonder<StokDurumYaniti>(`/api/kart/stok/${stokId}/durum/limit`,
                            { depoId, minStok, maxStok }, 'PUT'),

  // ---------------------------------------------------------- ayarlar ----
  ayarlar: () => istek<{ ayarlar: AyarSatiri[] }>('/api/ayar').then(y => y.ayarlar),

  /** Tek yardim metni ("?" ikonu) - ayar disindaki ekranlar da bunu kullanir. */
  yardim: (anahtar: string) =>
    istek<YardimKaydi>(`/api/yardim/${encodeURIComponent(anahtar)}`),

  ayarYaz: (anahtar: string, deger: string) =>
    gonder<{ ayarlar: AyarSatiri[] }>(`/api/ayar/${encodeURIComponent(anahtar)}`,
                                      { deger }, 'PUT').then(y => y.ayarlar),

  // --------------------------------------------------------------- kasa ----
  kasaIslemTurleri: () =>
    istek<{ turler: KasaIslemTuru[] }>('/api/kasa-islem-turu').then(y => y.turler),

  kasaOku: (id: number) => istek<KasaIslemYaniti>(`/api/kasa-islem/${id}`),

  kasaEkle: (govde: KasaIslemYazmaIstegi) =>
    gonder<KasaIslemYaniti>('/api/kasa-islem', govde),

  kasaGuncelle: (id: number, govde: KasaIslemYazmaIstegi) =>
    gonder<KasaIslemYaniti>(`/api/kasa-islem/${id}`, govde, 'PUT'),

  kasaKesinlestir: (id: number) =>
    gonder<KasaIslemYaniti>(`/api/kasa-islem/${id}/kesinlestir`, {}),

  /** Plandan tahsilat/odeme uretir. tutar bos = planin kalani. */
  kasaGerceklestir: (id: number, hesapId: number, tutar?: number, tarih?: string, tur?: number) =>
    gonder<KasaIslemYaniti>(`/api/kasa-islem/${id}/gerceklestir`, { hesapId, tutar, tarih, tur }),

  kasaIptal: (id: number, sebep: string, tarih?: string) =>
    gonder<{ islem: Record<string, unknown>; tersIslemId: number }>(
      `/api/kasa-islem/${id}/iptal`, { sebep, tarih }),

  kasaSil: (id: number) =>
    istek<{ silindi: boolean }>(`/api/kasa-islem/${id}`, { method: 'DELETE' }),

  /** Kur kutusu: o tarihin kuru (yoksa onceki en yakin gun). yon 1 satis / 2 alis. */
  dovizKur: (cins: string, tarih: string, yon = 1) =>
    istek<{ dovizCinsi: string; tarih: string; kur: number | null }>(
      `/api/referans/doviz-kur?cins=${encodeURIComponent(cins)}&tarih=${tarih}&yon=${yon}`),

  fisOku: (id: number) =>
    istek<{ fis: FisOzeti }>(`/api/muhasebe/fis/${id}`).then(y => y.fis),
};
