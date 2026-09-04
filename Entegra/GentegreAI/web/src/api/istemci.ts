import {
  ApiHatasi,
  type BenYaniti, type GirisYaniti, type HataGovdesi,
  type AksiyonListesi, type KartMetaYaniti, type KartYaniti, type KartYazmaIstegi, type KolonMeta,
  type ListeIstegi, type ListeYaniti, type BelgeYaniti,
  type KisiKaydi, type KisiIstegi, type YerlerYaniti,
  type KasaIslemTuru, type KasaIslemYaniti, type KasaIslemYazmaIstegi, type FisOzeti,
  type AcikSatir,
  type YetkiSatiri, type YetkiSatiriIstegi, type DokumanSatiri,
  type StokDurumYaniti, type StokHareketYaniti, type StokLotSatiri, type PaketIcerikSatiri,
  type AyarSatiri, type YardimKaydi,
  type PanelYaniti,
  type EBelgeMesaji,
  type TopluEBelgeSonucu,
  type RandevuBolumDugumu, type RandevuAyarYazma,
  type KurumProfil, type KurumProfilYaniti,
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

/** Personel kartinda sube yetkisi satiri (sube kisiti KISIDE). */
export interface KullaniciSubeSatiri {
  subeId: number; subeAdi: string;
  yetkili: boolean; varsayilan: boolean; yazma: boolean;
}

/** Personel/kisi kartinda kullanici rolu bolumu. */
export interface KartRolBilgisi {
  kullaniciVar: boolean; rolId: number; rolAdi: string;
  roller: { id: number; ad: string }[];
}

/** Rol > Kullanicilar sekmesi satiri. */
export interface RolKullanicisi {
  id: number; kod: string; unvan: string; eposta: string;
  departman: string; gorev: string; telefon: string; sube: string;
  aktif: boolean; sonGiris?: string | null; rolAdi: string;
}

/** ÜTS cevap zarflari (223). */
export interface UtsMesaji { tip?: string; met?: string; kod?: string }
export interface UtsSorguYaniti { basarili: boolean; sonuc?: unknown; mesajlar: UtsMesaji[] }
export interface UtsBildirimYaniti {
  bildirimId: number; basarili: boolean; utsBildirimId?: string;
  mesajlar: UtsMesaji[]; mesaj: string;
}
export interface UtsBelgeBildirimSatiri {
  stok: string; seriNo: string; lotNo: string; adet: number;
  islem: string; basarili: boolean; mesaj: string;
}
export interface UtsBelgeBildirimYaniti {
  belgeNo: string; toplam: number; basarili: number; hatali: number;
  sonuclar: UtsBelgeBildirimSatiri[]; mesaj: string;
}
/** Verme hazırla: hazırlanamayan satır (gridde gösterilir, CSV'ye gider). */
export interface UtsHazirlaAtlanan {
  belgeNo: string; tarih: string; cari: string; stok: string;
  urunNo: string; seriNo: string; lotNo: string; adet: number; sebep: string;
}
export interface UtsHazirlaYaniti {
  olusan: number; atlanan: UtsHazirlaAtlanan[]; atlananSayisi: number; mesaj: string;
}

async function istek<T>(yol: string, secenek: RequestInit = {}): Promise<T> {
  const yanit = await ham(yol, secenek, true);
  if (yanit.status === 204) return undefined as T;
  return yanit.json() as Promise<T>;
}

const gonder = <T,>(yol: string, govde: unknown, yontem = 'POST') =>
  istek<T>(yol, { method: yontem, body: JSON.stringify(govde) });

/** Dosya yukleme - "Content-Type: application/json" KOYULMAZ,
 *  tarayici FormData icin dogru multipart boundary'yi kendisi ekler. */
async function dosyaYukle<T>(yol: string, form: FormData): Promise<T> {
  const yanit = await ham(yol, { method: 'POST', body: form }, false);
  return yanit.json() as Promise<T>;
}

/** İçerik indirme - blob URL doner, <img>/indirme icin (Authorization header ile, token URL'e sizmaz). */
async function dosyaIndir(yol: string): Promise<string> {
  const yanit = await ham(yol, {}, false);
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

  /** Ilk giris: otomatik acilan hesabin parolasini kisi kendisi tanimlar. */
  ilkParola: (kod: string, tcknSon4: string, yeniParola: string) =>
    gonder<{ mesaj: string }>('/api/kimlik/ilk-parola', { kod, tcknSon4, yeniParola }),

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
  /** Personel/kisi kartindan rol goster-degistir. */
  kartRol: (kartId: number) =>
    istek<KartRolBilgisi>(`/api/kart/kullanici/${kartId}/rol`),
  kartRolDegistir: (kartId: number, rolId: number) =>
    istek<KartRolBilgisi>(`/api/kart/kullanici/${kartId}/rol/${rolId}`, { method: 'PUT' }),
  kartSubeleri: (kartId: number) =>
    istek<KullaniciSubeSatiri[]>(`/api/kart/kullanici/${kartId}/subeler`),
  kartSubeKaydet: (kartId: number, satirlar: Omit<KullaniciSubeSatiri, 'subeAdi'>[]) =>
    istek<KullaniciSubeSatiri[]>(`/api/kart/kullanici/${kartId}/subeler`,
      { method: 'PUT', body: JSON.stringify({ satirlar }) }),
  rolKullanicilari: (rolId: number) =>
    istek<RolKullanicisi[]>(`/api/kart/rol/${rolId}/kullanicilar`),
  rolKullaniciAdaylari: (rolId: number, arama: string) =>
    istek<RolKullanicisi[]>(
      `/api/kart/rol/${rolId}/kullanicilar/adaylar?arama=${encodeURIComponent(arama)}`),
  rolKullaniciEkle: (rolId: number, kullaniciId: number) =>
    gonder<RolKullanicisi[]>(`/api/kart/rol/${rolId}/kullanicilar/${kullaniciId}`, {}),
  rolKullaniciCikar: (rolId: number, kullaniciId: number) =>
    istek<{ mesaj: string; kullanicilar: RolKullanicisi[] }>(
      `/api/kart/rol/${rolId}/kullanicilar/${kullaniciId}`, { method: 'DELETE' }),
  rolYetkiKaydet: (rolId: number, satirlar: YetkiSatiriIstegi[]) =>
    gonder<YetkiSatiri[]>(`/api/kart/rol/${rolId}/yetkiler`, { satirlar }, 'PUT'),

  // ------------------------------------------------------------- dokuman ----
  dokumanlar: (kartAdi: string, kaynakId: number) =>
    istek<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}`),
  // yon: 0 uygulanmaz · 1 gelen · 2 giden (e-Belge XSLT sablonlari, 160).
  dokumanYukle: (kartAdi: string, kaynakId: number, dosya: File, varsayilan: boolean, yon = 0) => {
    const form = new FormData();
    form.append('dosya', dosya);
    form.append('varsayilan', varsayilan ? 'true' : 'false');
    if (yon) form.append('yon', String(yon));
    return dosyaYukle<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}`, form);
  },
  dokumanVarsayilanYap: (kartAdi: string, kaynakId: number, dokumanId: number) =>
    gonder<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}/varsayilan`, {}),
  // kaynakId/yon/varsayilan yalniz e-Belge XSLT sablonlarinda gonderilir (160):
  //   orada belge turu ve yon dosyanin kimligidir, sonradan duzeltilebilmeli.
  dokumanDuzenle: (kartAdi: string, kaynakId: number, dokumanId: number, ad: string,
                   belgeTuru: string, ek?: { kaynakId?: number; yon?: number; varsayilan?: boolean }) =>
    istek<DokumanSatiri[]>(`/api/dokuman/${kartAdi}/${kaynakId}/${dokumanId}`,
      { method: 'PUT', body: JSON.stringify({ ad, belgeTuru, ...ek }) }),
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
  // ----------------------------------------------------- kurum profili ----
  /** Kurum tipi & sistem ayarlari (359): profil + tip/modul kataloglari. */
  kurumProfil: (sube?: number) =>
    istek<KurumProfilYaniti>(`/api/kurum-profil${sube === undefined ? '' : `?sube=${sube}`}`),
  /** Profili yazar - verilmeyen alanlar mevcut degerini korur. */
  kurumProfilYaz: (govde: Partial<KurumProfil>) =>
    gonder<{ profil: KurumProfil }>('/api/kurum-profil', govde, 'PUT'),

  belgeOku: (id: number) => istek<BelgeYaniti>(`/api/belge/${id}`),
  belgeEkle: (govde: unknown) => gonder<BelgeYaniti>('/api/belge', govde),

  /** Donusturulmeyi bekleyen satirlar (siparis/irsaliye kalanlari). */
  belgeAcikSatirlar: (id: number) =>
    istek<{ satirlar: AcikSatir[] }>(`/api/belge/${id}/acik-satirlar`).then(y => y.satirlar),

  /** Bu belgeden turetilmis belgeler (irsaliye kartinin Faturalama sekmesi). */
  belgeDonusumler: (id: number) =>
    istek<{ belgeler: Record<string, unknown>[] }>(`/api/belge/${id}/donusumler`)
      .then(y => y.belgeler),

  /** Kayitli belgeyi duzenler (135) - numara korunur, stok/cari yeniden yazilir. */
  belgeGuncelle: (id: number, govde: unknown) =>
    gonder<BelgeYaniti>(`/api/belge/${id}`, govde, 'PUT'),

  /**
   * IADE faturasinda secilebilecek "onceki alinanlar" (132): carinin kesin
   * fatura satirlari, iade edilmis miktar dusulmus olarak.
   */
  iadeSatirlari: (tarafId: number, belgeId?: number, ara?: string, turler?: number[]) =>
    istek<{ satirlar: Record<string, unknown>[] }>(
      `/api/belge/iade-satirlari?tarafId=${tarafId}`
      + (belgeId ? `&belgeId=${belgeId}` : '')
      + (ara ? `&ara=${encodeURIComponent(ara)}` : '')
      + (turler?.length ? `&turler=${turler.join(',')}` : '')).then(y => y.satirlar),

  /** Siparis -> irsaliye -> fatura. Miktar KISMI olabilir; kalan kaynakta durur. */
  /**
   * e-BELGE HAZIRLA (163): belgeyi kuyruga alir - dogrular, e-Fatura/e-Arsiv/
   * e-Irsaliye kararini verir, seri ve numara atar. XML gonderim asamasinda.
   */
  belgeEBelgeHazirla: (id: number) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/ebelge-hazirla`, {}),

  /**
   * e-BELGE GONDER: hazirlanmis belgeyi entegratore yollar. GERI ALINAMAZ -
   * GIB'e giden belge iptal edilmez, yalniz iade faturasiyla duzeltilir.
   */
  belgeEBelgeGonder: (id: number, aliciAlias?: string) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/ebelge-gonder`, { aliciAlias: aliciAlias ?? null }),

  /** Gonderim oncesi alici adresi (184): e-Arsivde alias = alici e-postasi. */
  belgeEBelgeAlici: (id: number) =>
    istek<{ belgeTuru: number; alias: string; onerilenMail: string; tarafUnvan: string }>(
      `/api/belge/${id}/ebelge-alici`),

  /** Belgeyi siler (181). Izli belgede sunucu 422 doner (sebep mesajda). */
  belgeSil: (id: number) =>
    istek<{ mesaj: string }>(`/api/belge/${id}`, { method: 'DELETE' }),

  /** Onizleme HTML'i (178) - gonderim gerekmez. */
  belgeEBelgeOnizle: (id: number) =>
    istek<{ html: string }>(`/api/belge/${id}/ebelge-onizle`),

  /** GIB durumunu entegratorden ceker ve kayda isler (183). */
  belgeEBelgeDurum: (id: number) =>
    gonder<{ belgeNo: string; kod: string; aciklama: string; degisti: boolean }>(
      `/api/belge/${id}/ebelge-durum`, {}),

  /** Carinin GIB e-Fatura kaydini sorar, bayragi gunceller (183). */
  cariEBelgeMukellef: (id: number) =>
    gonder<{ mukellef: boolean; durum: string; degisti: boolean;
             gelen: { unvan: string; vergiDairesi: string; il: string; ilce: string; adres: string };
             kayitli: { unvan: string; vkno: string } }>(
      `/api/kart/cari/${id}/ebelge-mukellef`, {}),

  /** Toplu e-Belge (183): secili belgeleri hazirlar ya da gonderir. */
  belgeEBelgeToplu: (belgeler: number[], islem: 'hazirla' | 'gonder') =>
    gonder<{ sonuclar: TopluEBelgeSonucu[] }>('/api/belge/ebelge-toplu', { belgeler, islem }),

  /** UBL-XML + goruntuleme XSLT'si (182): "XML Kaydet" ve XSLT'li on izleme. */
  belgeEBelgeUbl: (id: number) =>
    istek<{ ubl: string; xslt: string; dosyaAdi: string }>(`/api/belge/${id}/ebelge-ubl`),

  /** Gonderim govdesi (entegratore giden ham istek). */
  belgeEBelgeGovde: (id: number) =>
    istek<{ bicim: number; govde: string; dosyaAdi: string }>(`/api/belge/${id}/ebelge-govde`),

  /** e-Belge gecmisi: hazirlama, gonderim, GIB yaniti (178). */
  belgeEBelgeMesajlar: (id: number) =>
    istek<{ mesajlar: EBelgeMesaji[] }>(`/api/belge/${id}/ebelge-mesajlar`),

  // ------------------------------------------------------ gelen belge ----
  /** Entegrator kutusunu tarar, gelen belgeleri kaydeder (187). */
  gelenKutuYenile: (baslangic?: string, bitis?: string) =>
    gonder<{ okunan: number; yeni: number; guncellenen: number; mesaj: string }>(
      '/api/gelen-belge/kutu-yenile',
      { baslangic: baslangic ?? null, bitis: bitis ?? null }),

  /** Gelen belgenin UBL XML'i; ilk cagride entegratorden indirilir (187). */
  gelenBelgeUbl: (id: number) =>
    istek<{ ubl: string }>(`/api/gelen-belge/${id}/ubl`),

  /** Gelen ticari faturaya KABUL / RED yaniti (187). Kabulde belge alis
      faturasina da aktarilir; olusan belge id'si `belgeId` ile doner. */
  gelenBelgeYanit: (id: number, kabul: boolean, aciklama: string) =>
    gonder<{ basarili: boolean; mesaj: string; belgeId: number | null }>(
      `/api/gelen-belge/${id}/yanit`, { kabul, aciklama }),

  /** Gelen belgenin gecmisi (189): kutuya dusme, zarf, indirme, yanit, aktarim. */
  gelenBelgeMesajlar: (id: number) =>
    istek<{ mesajlar: EBelgeMesaji[] }>(`/api/gelen-belge/${id}/mesajlar`),

  /** Gelen belgeyi ALIS FATURASINA aktarir (187). */
  gelenBelgeAktar: (id: number) =>
    gonder<{ belgeId: number; belgeNo: string; satirSayisi: number;
             eslesenStok: number; mesaj: string }>(`/api/gelen-belge/${id}/aktar`, {}),

  /** GIDEN belgeyi iptal eder / iptal talebi acar (188). Hangisi oldugunu
      sunucu belirler: e-Arsiv dogrudan iptal, e-Fatura talep. */
  belgeEBelgeIptal: (id: number, gerekce: string) =>
    gonder<{ basarili: boolean; yeniDurum: number; mesaj: string }>(
      `/api/belge/${id}/ebelge-iptal`, { gerekce }),

  /** e-Belgeyi geri al (164): kayit silinir, belge yeniden hazirlanabilir. */
  belgeEBelgeSifirla: (id: number) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/ebelge-sifirla`, {}),

  /** e-Belge serisini degistir (164). Seri bos ise siradaki kurala gecer. */
  belgeEBelgeSeri: (id: number, seri?: string) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/ebelge-seri`, { seri: seri ?? null }),

  /** Siparis rezervasyonu - 142. ac=false rezervi kaldirir. */
  belgeRezerve: (id: number, ac: boolean) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/rezerve`, { ac }),

  /** Termin (teslim tarihi) guncelleme - 140. Tarih null = termin kaldirildi. */
  belgeTermin: (id: number, satirlar: { satirId: number; teslimTarihi: string | null }[]) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/termin`, { satirlar }),

  /**
   * Belge donusumu. `pay` (289): 0/bos tum satir · 1 yalniz HASTA payi ·
   * 2 yalniz KURUM payi - kurum payinda hedef belgenin carisi odeyen kurum olur.
   */
  belgeDonustur: (id: number, hedefTur: number,
                  satirlar: { satirId: number; miktar: number; tutar?: number }[],
                  belgeTarihi?: string, taslak = false, belgeNo?: string,
                  pay = 0, kalaniTahakkuk = false) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/donustur`,
                        { hedefTur, satirlar, belgeTarihi, taslak, belgeNo, pay, kalaniTahakkuk }),

  // ------------------------------------------ stok karti: Stok Durumu ----
  /** Depo bazli miktar/rezerve/kullanilabilir + KPI seridi (salt okunur). */
  stokDurum: (stokId: number) =>
    istek<StokDurumYaniti>(`/api/kart/stok/${stokId}/durum`),

  /** Hareket dokumu: tarih araligi + depo suzgeci, yurumeli kalan. */
  stokHareket: (stokId: number, bas: string, bit: string, depoId?: number | null) =>
    istek<StokHareketYaniti>(`/api/kart/stok/${stokId}/hareket?bas=${bas}&bit=${bit}`
      + (depoId ? `&depoId=${depoId}` : '')),

  /** Cikis belgesinde secilebilecek lotlar: stokta KALANI olanlar (114). */
  stokLotlari: (stokId: number, depoId?: number | null) =>
    istek<{ lotlar: StokLotSatiri[] }>(`/api/kart/stok/${stokId}/lot`
      + (depoId ? `?depoId=${depoId}` : '')).then(y => y.lotlar),

  /** Paket icerigi (124): belge kaleminde paket secilince acilan satirlar. */
  paketIcerigi: (stokId: number, alis = false) =>
    istek<{ icerik: PaketIcerikSatiri[] }>(
      `/api/kart/stok/${stokId}/paket${alis ? '?alis=true' : ''}`).then(y => y.icerik),

  /** Stok kartini kopyalar (126): kod "_Kn", ad " kopya"; paket icerigi de gelir. */
  stokKopyala: (stokId: number) =>
    istek<{ id: number }>(`/api/kart/stok/${stokId}/kopyala`, { method: 'POST' }).then(y => y.id),

  /**
   * Fiyat listesini URETIR (202): satirlari kurala gore yeniden yazar.
   * MANUEL girilen satirlar korunur; fiyati cozulemeyen kalemler atlanir ve
   * sayilari mesajda bildirilir.
   */
  fiyatListesiUret: (listeId: number, secim?: { stok?: boolean; hizmet?: boolean }) =>
    istek<{ eklenen: number; guncellenen: number; korunan: number; fiyatsiz: number; mesaj: string }>(
      `/api/fiyat-listesi/${listeId}/uret`,
      { method: 'POST', body: JSON.stringify({ stok: secim?.stok ?? true, hizmet: secim?.hizmet ?? true }) }),

  /** Excel sablonu (207): dolu=true mevcut satirlari doldurur. Blob URL doner. */
  fiyatListesiSablon: (listeId: number, dolu: boolean) =>
    dosyaIndir(`/api/fiyat-listesi/${listeId}/sablon${dolu ? '?dolu=1' : ''}`),

  /**
   * Excel'den iceri alma (207). YA HEP YA HIC: sunucu bir hata bile bulursa
   * hicbir satir yazmaz ve 422 govdesinde satir numarali hatalar doner
   * (ApiHatasi.hata icinde satirHatalari).
   */
  fiyatListesiIceriAl: (listeId: number, dosya: File) => {
    const form = new FormData();
    form.append('dosya', dosya);
    return dosyaYukle<{ eklenen: number; guncellenen: number; toplam: number; mesaj: string }>(
      `/api/fiyat-listesi/${listeId}/iceri-al`, form);
  },

  /** Belge acilirken gelecek fiyat listesi (205): turun yonune gore cari listesi > varsayilan. */
  belgeVarsayilanListe: (tur: number, tarafId: number, kurumId?: number | null) =>
    istek<{ listeId: number | null; ad: string; yon: number; kdvDahil: number }>(
      `/api/belge/varsayilan-liste?tur=${tur}&tarafId=${tarafId}`
      + (kurumId ? `&kurumId=${kurumId}` : '')),

  /** Tek kalemin liste fiyati - liste henuz uretilmemis olsa da kural isletilir. */
  fiyatListesiFiyat: (listeId: number, kalem: { stokId?: number; hizmetId?: number }) =>
    istek<{ fiyat: number | null; dovizCinsi: string; kdvDahil: number; kaynak: string }>(
      `/api/fiyat-listesi/${listeId}/fiyat?`
      + (kalem.stokId ? `stokId=${kalem.stokId}` : `hizmetId=${kalem.hizmetId}`)),

  /**
   * Yururlukteki kampanya (274) - belge basligindaki rozet. Basvuruda ODEYEN
   * KURUM verilir: odemeyi yapan taraf fiyati belirler.
   */
  fiyatKampanya: (taraf: { tarafId?: number | null; kurumId?: number | null }) =>
    istek<{ kampanyaId: number | null; kod: string; ad: string;
            fiyatListesiId: number | null;
            /** 1 karsilama ORANI (OSS) · 2 KATILIM PAYI sabit tutar (SGK). */
            paylasimModu: number; varsayilanKarsilama: number }>(
      '/api/fiyat/kampanya?'
      + (taraf.kurumId ? `kurumId=${taraf.kurumId}&` : '')
      + (taraf.tarafId ? `tarafId=${taraf.tarafId}` : '')),

  /**
   * Kalem fiyati LISTE + KAMPANYA (274). Baz fiyat listeden gelir, kampanya
   * uzerine indirim isler; kampanyanin kendi listesi varsa baz O olur.
   */
  fiyatKalem: (kalem: { stokId?: number; hizmetId?: number },
               kaynak: { tarafId?: number | null; kurumId?: number | null;
                         listeId?: number | null }) =>
    istek<{ fiyat: number | null; bazFiyat: number | null; dovizCinsi: string;
            kdvDahil: number; kaynak: string; kampanyaId: number | null;
            listeId: number | null; satirId: number | null; tip: number | null;
            iskontoTipi: number | null; iskonto: number | null }>(
      '/api/fiyat/kalem?'
      + (kalem.stokId ? `stokId=${kalem.stokId}` : `hizmetId=${kalem.hizmetId}`)
      + (kaynak.tarafId ? `&tarafId=${kaynak.tarafId}` : '')
      + (kaynak.kurumId ? `&kurumId=${kaynak.kurumId}` : '')
      + (kaynak.listeId ? `&listeId=${kaynak.listeId}` : '')),

  /** Depo bazli min/max seviye (099). Miktarlara DOKUNMAZ. */
  stokDurumLimit: (stokId: number, depoId: number,
                   minStok: number | null, maxStok: number | null) =>
    gonder<StokDurumYaniti>(`/api/kart/stok/${stokId}/durum/limit`,
                            { depoId, minStok, maxStok }, 'PUT'),

  // -------------------------------------------------------- ana sayfa ----
  /** Panel: kutular + listeler TEK istekte (acilista bes cagri yapmamak icin). */
  panel: () => istek<PanelYaniti>('/api/panel'),

  // -------------------------------------------------------- kurum icmali ----
  /** Donemde faturalanacak acik kurum paylari (289) - icmal oncesi onizleme. */
  icmalOnizleme: (kurumId: number, donemBas: string, donemBit: string) =>
    istek<{ satirlar: Record<string, unknown>[]; toplam: number }>(
      `/api/kurum-icmal/onizleme?kurumId=${kurumId}`
      + `&donemBas=${donemBas}&donemBit=${donemBit}`),

  icmalOlustur: (govde: { kurumId: number; donemBas: string; donemBit: string;
                          aciklama?: string }) =>
    gonder<{ icmalId: number; satir: number }>('/api/kurum-icmal', govde),

  /** Icmali TEK faturaya cevirir; cari KURUMDUR, satirlarin kurum payi kapanir. */
  icmalFaturala: (icmalId: number) =>
    gonder<{ belgeId: number; satir: number; uyarilar?: string[] }>(
      `/api/kurum-icmal/${icmalId}/faturala`, {}),

  // ---------------------------------------------------------- radyoloji ----
  // RAPOR EKRANI (283): acilista ihtiyac duyulan HER SEY tek istekte gelir -
  //   istem, rapor, bolumler, sablonlar, makrolar, skorlar, hasta gecmisi ve
  //   kritik bulgu bildirimleri.
  radyolojiRapor: (istemId: number) =>
    istek<{
      istem: Record<string, unknown>;
      rapor: Record<string, unknown> | null;
      bolumler: Record<string, unknown>[];
      alanlar: Record<string, unknown>[];
      sablonlar: Record<string, unknown>[];
      makrolar: Record<string, unknown>[];
      skorlar: Record<string, unknown>[];
      gecmis: Record<string, unknown>[];
      kritikler: Record<string, unknown>[];
    }>(`/api/radyoloji/istem/${istemId}/rapor`),

  radyolojiRaporYaz: (istemId: number, govde: unknown) =>
    gonder<{ raporId: number }>(`/api/radyoloji/istem/${istemId}/rapor`, govde),

  /** Sablon iskeleti - "yeniden uygula" bolumleri buradan kurar. */
  radyolojiSablonBolumleri: async (sablonId: number) => {
    const y = await istek<{ detaylar?: Record<string, Record<string, unknown>[]> }>(
      `/api/kart/radyoloji-sablon/${sablonId}`);
    return y.detaylar?.bolumler ?? [];
  },

  /** Ön rapor / onay. Onay ön kosullari sunucuda (fn_radyoloji_rapor_onaylanabilir). */
  radyolojiRaporDurum: (raporId: number, hedef: 'on-rapor' | 'onay') =>
    gonder<{ tamam: boolean }>(`/api/radyoloji/rapor/${raporId}/durum?hedef=${hedef}`, {}),

  /**
   * RAPOR CIKTISI (303): hastaya verilen belge. Yazma ekraninin verisinden
   * AYRI - burada sablon/makro degil KURUM ANTETI, kimlik satirlari, yalniz
   * basilacak bolumler ve ek raporlar var.
   */
  radyolojiRaporCikti: (raporId: number) =>
    istek<{
      rapor: Record<string, unknown>;
      bolumler: Record<string, unknown>[];
      alanlar: Record<string, unknown>[];
      ekler: Record<string, unknown>[];
      kurum: Record<string, unknown> | null;
    }>(`/api/radyoloji/rapor/${raporId}/cikti`),

  /**
   * ISTEM EKRANI (304): tetkik agaci (modalite gruplu), isteyen hekim adaylari
   * ve hastanin son 12 aydaki ayni tetkikleri - mukerrer uyarisi bundan cikar.
   */
  radyolojiIstemSecenekleri: (hastaId: number) =>
    istek<{
      tetkikler: Record<string, unknown>[];
      hekimler: Record<string, unknown>[];
      /** Kayitli DIS hekimler (305) - dis istemde listeden secilir. */
      disHekimler: Record<string, unknown>[];
      gecmis: Record<string, unknown>[];
    }>(`/api/radyoloji/istem-secenekleri?hastaId=${hastaId}`),

  /**
   * Coklu tetkik -> her biri AYRI istem (ayri accession no). Kabul
   * ekraninda (310) basvuru da acilir; sunucu protokol numarasini ve
   * tutarlari geri doner - istemci ikinci istek atmasin.
   */
  radyolojiIstemAc: (govde: unknown) =>
    gonder<{ idler: number[]; accessionlar: string[]; uyarilar: string[];
             belgeId: number | null;
             basvuru: Record<string, unknown> | null }>(
      '/api/radyoloji/istem', govde),

  /** Hastanin aktif policesi (kabul ekrani odeyen kurum/police onyukleme). */
  radyolojiHastaOdeme: (hastaId: number) =>
    istek<{ kurumId?: number | null; kurumAd?: string; policeNo?: string }>(
      `/api/radyoloji/hasta/${hastaId}/odeme`),

  /**
   * Tetkikin randevu bilgisi (317): cekim protokolu suresi + modalite.
   * Radyoloji tetkiki degilse null doner.
   */
  radyolojiTetkikBilgi: (hizmetId: number) =>
    istek<{ hizmetId: number; hizmetAdi: string; modalite: number;
            modaliteAdi: string; protokolSure: number; kontrast: number;
            hazirlikMetni: string } | null>(
      `/api/radyoloji/tetkik-bilgi/${hizmetId}`),

  /**
   * Cekim sonrasi sarf onerisi (320): protokol malzemesi + depo bakiyesi +
   * izlemli stoklar icin lot listesi.
   */
  radyolojiSarf: (istemId: number) =>
    istek<{ aktif: boolean; depoId: number | null; depoAdi: string;
            accessionNo: string; cdIstendi: number; kontrastMl: number;
            satirlar: Record<string, unknown>[]; lotlar: Record<string, unknown>[];
            dusulen: Record<string, unknown>[] }>(
      `/api/radyoloji/istem/${istemId}/sarf`),

  /** Sarfi dus (320): stok cikis fisi uretilir, kritik seviye uyarisi doner. */
  radyolojiSarfDus: (istemId: number,
                     govde: { depoId?: number;
                              satirlar: { stokId: number; miktar: number;
                                          izlemler?: { seriLotId: number;
                                                       miktar: number }[] }[] }) =>
    gonder<{ belgeId: number; uyarilar: string[];
             kritik: Record<string, unknown>[] }>(
      `/api/radyoloji/istem/${istemId}/sarf`, govde),

  /**
   * TAHSILAT DAGITIMI (321): belgenin satirlari + pay bazinda tahsil edilen /
   * kalan. kasaIslemId verilirse o islemin mevcut dagitimi da doner.
   */
  kasaDagitimSatirlari: (belgeId: number, kasaIslemId?: number) =>
    istek<{ belge: Record<string, unknown> | null;
            satirlar: Record<string, unknown>[] }>(
      `/api/kasa-islem/dagitim-satirlari?belgeId=${belgeId}`
      + (kasaIslemId ? `&kasaIslemId=${kasaIslemId}` : '')),

  /**
   * Dagitimi TOPLU yaz (321). otomatik=true ise sunucu kalanlari siraya gore
   * kapatir - radyoloji kabulu gibi tek tikla akislar bunu kullanir.
   */
  kasaDagitimYaz: (kasaIslemId: number,
                   govde: { belgeId?: number; otomatik?: boolean;
                            satirlar?: { belgeSatirId: number; pay: number;
                                         tutar: number }[] }) =>
    gonder<{ dagitilan: number; avans: number; satirSayisi: number }>(
      `/api/kasa-islem/${kasaIslemId}/dagitim`, govde),

  /** Kalemin prim rolleri + o kalemden dogmus primler (324). */
  primKalemRolleri: (belgeSatirId: number) =>
    istek<{ satirlar: Record<string, unknown>[]; primler: Record<string, unknown>[] }>(
      `/api/prim/kalem/${belgeSatirId}/roller`),

  /** Rolleri TOPLU yaz; kalemin primleri yeniden hesaplanir (324). */
  primKalemRolleriYaz: (belgeSatirId: number,
                        govde: { satirlar: { rol: number; tarafId: number;
                                             payYuzde?: number }[] }) =>
    gonder<{ satirSayisi: number; primSatiri: number }>(
      `/api/prim/kalem/${belgeSatirId}/roller`, govde),

  /**
   * Plan satirinin KADEMELERI (388): adede gore artan oran. Kademe satirin
   * cocugu - kart cercevesi torun detayi baglamadigi icin kendi ucu var.
   */
  primKademeler: (planSatirId: number) =>
    istek<{ satirlar: { id: number; adetAlt: number; adetUst: number | null;
                        deger: number }[] }>(
      `/api/prim/satir/${planSatirId}/kademeler`),

  /** Kademeleri TOPLU yaz (tam liste yerine konur) - aralik kumesi butun halinde. */
  primKademeYaz: (planSatirId: number,
                  satirlar: { adetAlt: number; adetUst: number | null; deger: number }[]) =>
    gonder<{ satirSayisi: number }>(
      `/api/prim/satir/${planSatirId}/kademeler`, { satirlar }, 'PUT'),

  /** Kisi bazinda acik (donemi kapanmamis) hakedis (324). */
  primAcikHakedis: () =>
    istek<Record<string, unknown>[]>('/api/prim/acik'),

  // -------------------------------------------------------- YAPAY ZEKA ---
  // Mockup: Ekranlar/ai_asistan.html (341/343). Model bagli degilken de
  //   izinli fonksiyonlar (hazir komutlar) calisir.
  aiSohbetler: () =>
    istek<{ sohbetler: Record<string, unknown>[];
            araclar: { kod: string; ad: string; aciklama: string;
                       yetkiKodu: string; yazar: number }[];
            bekleyenTaslak: number }>('/api/ai/sohbetler'),

  aiSohbetAc: () => gonder<{ id: number }>('/api/ai/sohbet', {}),

  aiSohbet: (id: number) =>
    istek<{ sohbet: Record<string, unknown>;
            mesajlar: Record<string, unknown>[];
            taslaklar: Record<string, unknown>[];
            gunluk: Record<string, unknown>[] }>(`/api/ai/${id}`),

  aiSor: (sohbetId: number, metin: string, arac?: string,
          parametre?: Record<string, unknown>, baglam?: Record<string, unknown>) =>
    gonder<{ mesajId: number; kayit: number }>(`/api/ai/${sohbetId}/sor`,
      { metin, arac: arac ?? null, parametre: parametre ?? null, baglam: baglam ?? null }),

  aiTaslak: (taslakId: number, iptal: boolean) =>
    gonder<{ durum: number; hedefModul: string; hedefId: number | null }>(
      '/api/ai/taslak', { taslakId, iptal }),

  aiGeriBildirim: (mesajId: number, deger: number) =>
    gonder<{ tamam: boolean }>('/api/ai/geribildirim', { mesajId, deger }),

  // ---------------------------------------------------------- MESAJLAR ---
  // Mockup: Ekranlar/umesajlar.html (341/342). Gercek zamanli iletim yok;
  //   ekran kisa arayla tazeliyor.
  /** Kullanicinin sohbet listesi + okunmamis sayaclari. */
  mesajSohbetler: (filtre: string, ara: string) =>
    istek<{ sohbetler: Record<string, unknown>[];
            ozet: { okunmamisMesaj: number; okunmamisSohbet: number;
                    bugunMesaj: number; bugunEk: number; bugunKayit: number } | null }>(
      `/api/mesaj/sohbetler?filtre=${encodeURIComponent(filtre)}`
      + `&ara=${encodeURIComponent(ara)}`),

  /** Sohbetin mesajlari; `sonrasi` verilirse yalniz yeni gelenler. */
  mesajAkis: (sohbetId: number, sonrasi = 0) =>
    istek<{ sohbet: Record<string, unknown> | null; mesajlar: Record<string, unknown>[] }>(
      `/api/mesaj/${sohbetId}/mesajlar?sonrasi=${sonrasi}`),

  mesajGonder: (sohbetId: number, metin: string, yanitId?: number,
                kayit?: { modul: string; kayitId: number; ozet?: string }) =>
    gonder<{ id: number; tarih: string }>(`/api/mesaj/${sohbetId}/gonder`,
      { metin, yanitId: yanitId ?? null, kayit: kayit ?? null }),

  mesajOkundu: (sohbetId: number) =>
    gonder<{ tamam: boolean }>(`/api/mesaj/${sohbetId}/okundu`, {}),

  mesajBayrak: (sohbetId: number,
                govde: { favori?: number; sabit?: number; sessiz?: number; arsiv?: number }) =>
    gonder<{ tamam: boolean }>(`/api/mesaj/${sohbetId}/bayrak`, govde),

  mesajBilgi: (sohbetId: number) =>
    istek<{ kunye: Record<string, unknown> | null;
            uyeler: Record<string, unknown>[]; ekler: Record<string, unknown>[];
            kayitlar: Record<string, unknown>[]; sabitler: Record<string, unknown>[] }>(
      `/api/mesaj/${sohbetId}/bilgi`),

  mesajSabit: (mesajId: number, geriAl: boolean) =>
    gonder<{ tamam: boolean }>(`/api/mesaj/mesaj/${mesajId}/sabit?geriAl=${geriAl}`, {}),

  mesajSil: (mesajId: number) =>
    istek<{ tamam: boolean }>(`/api/mesaj/mesaj/${mesajId}`, { method: 'DELETE' }),

  mesajKisiler: (ara: string) =>
    istek<{ kisiler: { id: number; ad: string; gorev: string }[] }>(
      `/api/mesaj/kisiler?ara=${encodeURIComponent(ara)}`),

  mesajSohbetAc: (govde: { tip: number; ad?: string; uyeler: number[] }) =>
    gonder<{ id: number; mevcutMu: boolean }>('/api/mesaj/sohbet', govde),

  /** Entegrasyon hesabinin baglantisini sinar (336). */
  entegrasyonSina: (id: number) =>
    gonder<{ basarili: boolean; mesaj: string }>(`/api/entegrasyon/${id}/sina`, {}),

  /** SKRS kod listelerini servisten cekip yerel listeleri gunceller (336). */
  skrsListeSenkron: (id: number) =>
    gonder<{ satirSayisi: number; mesaj: string }>(`/api/entegrasyon/${id}/skrs-senkron`, {}),

  /** Prim satirlarini ONAYLA / onayi kaldir (330) - onayli satir kilitlidir. */
  primOnayla: (govde: { satirlar: number[]; geriAl?: boolean }) =>
    gonder<{ satirSayisi: number; geriAl: boolean }>('/api/prim/onayla', govde),

  /** Donemi kapat: acik satirlar bir basliga baglanir ve DONDURULUR (324). */
  primDonemKapat: (govde: { tarafId: number; baslangic: string; bitis: string }) =>
    gonder<Record<string, unknown>>('/api/prim/donem-kapat', govde),

  /** Carinin dagitilmamis tahsilatlari (322) - avans mahsubu seridi. */
  kasaAvans: (tarafId: number) =>
    istek<{ satirlar: Record<string, unknown>[]; toplam: number }>(
      `/api/kasa-islem/avans?tarafId=${tarafId}`),

  /**
   * Avansi belgenin acik satirlarina dagit (322). Prim tarihi dagitim gunu
   * DEGIL, tahsilatin islem tarihidir.
   */
  kasaAvansMahsup: (govde: { belgeId: number; islemIdler?: number[] }) =>
    gonder<{ dagitilan: number; islemSayisi: number }>(
      '/api/kasa-islem/avans-mahsup', govde),

  /** Radyoloji panosu (320): sayaclar + cihaz dolulugu + uyarilar tek uctan. */
  radyolojiPano: <T,>(gun?: string) =>
    istek<T>(`/api/radyoloji/pano${gun ? `?gun=${encodeURIComponent(gun)}` : ''}`),

  /**
   * Cihazin kapali araliklari (318): bakim/ariza/tatil + ogle arasi.
   * Takvim bunlari tarali blok olarak cizer - kural zaten tetikte, bu
   * GORUNURLUK icin.
   */
  radyolojiCihazKapatma: (bas: string, bit: string) =>
    istek<{ kapatmalar: Record<string, unknown>[]; ogleArasi: Record<string, unknown>[] }>(
      `/api/radyoloji/cihaz-kapatma?bas=${encodeURIComponent(bas)}`
      + `&bit=${encodeURIComponent(bit)}`),

  /** Takvimden cihaz kapatma (318) - etkilenen randevu sayisi doner. */
  radyolojiKapatmaEkle: (cihazId: number,
                         govde: { baslangic: string; bitis: string;
                                  nedenTur?: number; aciklama?: string }) =>
    gonder<{ id: number; etkilenenRandevu: number }>(
      `/api/radyoloji/cihaz/${cihazId}/kapatma`, govde),

  /** Kritik bulgu takibini kapat (318): teyit alindi, listeden duser. */
  radyolojiKritikKapat: (istemId: number) =>
    gonder<{ tamam: boolean }>(`/api/radyoloji/istem/${istemId}/kritik-kapat`, {}),

  /** Randevusu olmayan istemler (316) - takvimin bekleyen paneli. */
  radyolojiRandevuBekleyen: () =>
    istek<Record<string, unknown>[]>('/api/radyoloji/randevu-bekleyen'),

  /**
   * Isteme randevu ver (316): kayit public.randevu'ya gider, kaynagi CIHAZ.
   * Sure verilmezse cekim protokolu (314), o da yoksa cihaz varsayilani.
   */
  radyolojiRandevuVer: (istemId: number,
                        govde: { cihazId: number; baslangic: string;
                                 sureDk?: number; teknikerId?: number;
                                 aciklama?: string }) =>
    gonder<{ randevuId: number; sureDk: number }>(
      `/api/radyoloji/istem/${istemId}/randevu`, govde),

  /** Istem akis seridi + ozet (310): istem/randevu/cekim/rapor/onay/teslim. */
  radyolojiIstemAkis: (istemId: number) =>
    istek<Record<string, unknown>>(`/api/radyoloji/istem/${istemId}/akis`),

  /** Cekim oncesi kontrol listesi (310) - modaliteye gore sorular + yanitlar. */
  radyolojiKontrol: (istemId: number) =>
    istek<{ sorular: Record<string, unknown>[] }>(
      `/api/radyoloji/istem/${istemId}/kontrol`),

  radyolojiKontrolKaydet: (istemId: number,
                           yanitlar: { soruId: number; yanit: string }[]) =>
    gonder<{ kaydedildi: boolean }>(
      `/api/radyoloji/istem/${istemId}/kontrol`, { yanitlar }),

  /** SONUC TESLIMI (304): film/CD/basili rapor kime verildi. */
  radyolojiTeslim: (istemId: number, govde: unknown) =>
    gonder<{ tamam: boolean }>(`/api/radyoloji/istem/${istemId}/teslim`, govde),

  radyolojiTeslimler: (istemId: number) =>
    istek<Record<string, unknown>[]>(`/api/radyoloji/istem/${istemId}/teslimler`),

  /**
   * KONSULTASYON (304): ikinci gorus. `konsultasyonId` verilirse DONEN GORUS
   * yazilir (kayit "dondu" olur), yoksa yeni istek acilir.
   */
  radyolojiKonsultasyon: (istemId: number, govde: unknown, konsultasyonId?: number) =>
    gonder<{ id: number }>(
      `/api/radyoloji/istem/${istemId}/konsultasyon`
      + (konsultasyonId ? `?konsultasyonId=${konsultasyonId}` : ''), govde),

  radyolojiKonsultasyonlar: (istemId: number) =>
    istek<Record<string, unknown>[]>(`/api/radyoloji/istem/${istemId}/konsultasyonlar`),

  /** Dis hekim gonderim ozeti (305): kutular + modalite dagilimi. */
  radyolojiHekimOzeti: (hekimId: number) =>
    istek<{ ozet: Record<string, unknown>; dagilim: Record<string, unknown>[] }>(
      `/api/radyoloji/hekim/${hekimId}/ozet`),

  radyolojiAddendum: (raporId: number) =>
    gonder<{ raporId: number }>(`/api/radyoloji/rapor/${raporId}/addendum`, {}),

  radyolojiKritikBulgu: (istemId: number, govde: unknown) =>
    gonder<{ tamam: boolean }>(`/api/radyoloji/istem/${istemId}/kritik-bulgu`, govde),

  // ------------------------------------------------ randevu bolumleri ----
  // Randevu Ayarlari > Bolumler (251): randevu verilen bolumler, hekimleri ve
  //   her ikisinin randevu duzeni; sol agac + sag form ayni yanittan beslenir.
  randevuBolumleri: () => istek<RandevuBolumDugumu[]>('/api/randevu/bolumler'),
  randevuBolumAyarYaz: (istek_: RandevuAyarYazma) =>
    gonder<{ tamam: boolean }>('/api/randevu/bolum-ayar', istek_, 'PUT'),
  randevuBolumIsaretle: (departmanId: number, bolumMu: boolean) =>
    gonder<{ tamam: boolean }>('/api/randevu/bolum', { departmanId, bolumMu }, 'PUT'),

  // ---------------------------------------------------------- ayarlar ----
  ayarlar: () => istek<{ ayarlar: AyarSatiri[] }>('/api/ayar').then(y => y.ayarlar),

  /** Tek yardim metni ("?" ikonu) - ayar disindaki ekranlar da bunu kullanir. */
  yardim: (anahtar: string) =>
    istek<YardimKaydi>(`/api/yardim/${encodeURIComponent(anahtar)}`),

  ayarYaz: (anahtar: string, deger: string) =>
    gonder<{ ayarlar: AyarSatiri[] }>(`/api/ayar/${encodeURIComponent(anahtar)}`,
                                      { deger }, 'PUT').then(y => y.ayarlar),

  // Kod listesi yonetimi (219) - ayar combolarinin icerigi.
  // ÜTS (223) - Saglik Bakanligi Urun Takip Sistemi.
  utsHesapDurum: () =>
    istek<{ kurumNo: string; testMi: boolean; url: string;
            tokenVar: boolean; tokenSonu: string }>('/api/uts/hesap-durum'),
  utsTekilUrun: (govde: { uno: string; lotNo?: string; seriNo?: string }) =>
    gonder<UtsSorguYaniti>('/api/uts/sorgu/tekil-urun', govde),
  utsAyrintili: (govde: { uno?: string; lotNo?: string; seriNo?: string }) =>
    gonder<UtsSorguYaniti>('/api/uts/sorgu/ayrintili', govde),
  utsAskidakilerSenkron: () =>
    gonder<{ toplam: number; kaybolan: number; mesaj: string }>(
      '/api/uts/askidakiler-senkron', {}),
  utsAlmaBildir: (govde: { envanterId?: number; vbi?: string; adet?: number }) =>
    gonder<UtsBildirimYaniti>('/api/uts/bildirim/alma', govde),
  utsVermeBildir: (govde: Record<string, unknown>) =>
    gonder<UtsBildirimYaniti>('/api/uts/bildirim/verme', govde),
  utsKullanimBildir: (govde: Record<string, unknown>) =>
    gonder<UtsBildirimYaniti>('/api/uts/bildirim/kullanim', govde),
  utsUretimBildir: (govde: Record<string, unknown>) =>
    gonder<UtsBildirimYaniti>('/api/uts/bildirim/uretim', govde),
  utsIthalatBildir: (govde: Record<string, unknown>) =>
    gonder<UtsBildirimYaniti>('/api/uts/bildirim/ithalat', govde),
  utsHekBildir: (govde: Record<string, unknown>) =>
    gonder<UtsBildirimYaniti>('/api/uts/bildirim/hek', govde),
  utsImhaBildir: (govde: Record<string, unknown>) =>
    gonder<UtsBildirimYaniti>('/api/uts/bildirim/imha', govde),
  utsIptal: (id: number) =>
    gonder<UtsBildirimYaniti>(`/api/uts/bildirim/${id}/iptal`, {}),
  utsYenidenGonder: (id: number) =>
    gonder<UtsBildirimYaniti>(`/api/uts/bildirim/${id}/yeniden-gonder`, {}),
  /** İki aşamalı verme, 1. adım: bekleyen kayıtları üretir (ÜTS'ye gitmez). */
  utsVermeHazirla: () =>
    gonder<UtsHazirlaYaniti>('/api/uts/verme-hazirla', {}),
  utsBelgedenBildir: (belgeId: number) =>
    gonder<UtsBelgeBildirimYaniti>(`/api/uts/belge/${belgeId}/bildir`, {}),
  utsBildirimDetay: (id: number) =>
    gonder<UtsSorguYaniti>(`/api/uts/bildirim/${id}/detay-sorgula`, {}),

  kodListe: (kod: string) =>
    istek<{ kod: string; degerler: { deger: number; ad: string; sira: number; aktif: number }[] }>(
      `/api/kod-liste/${encodeURIComponent(kod)}`),
  kodListeEkle: (kod: string, ad: string, sira?: number) =>
    gonder<{ deger: number }>(`/api/kod-liste/${encodeURIComponent(kod)}`, { ad, sira }),
  kodListeGuncelle: (kod: string, deger: number, govde: { ad: string; sira?: number; aktif?: number }) =>
    gonder<object>(`/api/kod-liste/${encodeURIComponent(kod)}/${deger}`, govde, 'PUT'),
  kodListeSil: (kod: string, deger: number) =>
    gonder<object>(`/api/kod-liste/${encodeURIComponent(kod)}/${deger}`, undefined, 'DELETE'),

  // --------------------------------------------------------------- kasa ----
  kasaIslemTurleri: () =>
    istek<{ turler: KasaIslemTuru[] }>('/api/kasa-islem-turu').then(y => y.turler),

  kasaOku: (id: number) => istek<KasaIslemYaniti>(`/api/kasa-islem/${id}`),

  /** Nakit islemde acilacak kasa (196): once kullaniciya atanmis kasa, yoksa
      subenin varsayilan kasasi. Yoksa hesapId null doner. */
  kullaniciKasasi: (tur = 'K') =>
    istek<{ hesapId: number | null; ad?: string; dovizCinsi?: string; kendiKasasi?: boolean }>(
      `/api/kasa/kullanici-kasasi?tur=${encodeURIComponent(tur)}`),

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
    istek<{ dovizCinsi: string; tarih: string; kurTarihi: string | null; kur: number | null }>(
      `/api/referans/doviz-kur?cins=${encodeURIComponent(cins)}&tarih=${tarih}&yon=${yon}`),

  fisOku: (id: number) =>
    istek<{ fis: FisOzeti }>(`/api/muhasebe/fis/${id}`).then(y => y.fis),
};
