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

  /**
   * Ilac katalogundan STOK KARTI uretir (ya da varsa dondurur).
   *
   * Belge satiri daima bir STOK'a baglanir; ilac katalogu 23 bin satirlik bir
   * REFERANS listedir, hepsine pesinen kart acmak stok listesini kullanilamaz
   * hale getirirdi. Kart ilk kullanimda acilir.
   */
  ilacStokKarti: (ilacId: number) =>
    gonder<{ stokId: number; barkod: string; ad: string; fiyat: number }>(
      `/api/katalog/ilac/${ilacId}/stok`, {}),

  /** Elle ilac fiyati (kaynak 9): TITCK Detayli Fiyat Listesi kapisi acilana
      kadar tek yol. Bagli stok kartinin satis fiyatini da gunceller. */
  ilacFiyatGir: (ilacId: number, perakende: number, kdv = 10) =>
    gonder<{ barkod: string; perakende: number; stokId: number | null; yururluk: string }>(
      `/api/katalog/ilac/${ilacId}/fiyat`, { perakende, kdv }),

  /** Sablonu muayeneye uygula (411): alanlar bulgu satiri olarak acilir,
      hepsi "normal" isaretlenir - hekimin isi "hepsini yaz" degil "sapani
      duzelt" olsun. Var olan bulgular korunur. */
  muayeneSablonUygula: (muayeneId: number, sablonId: number) =>
    gonder<{ acilan: number; bulguOzet: string; mesaj: string }>(
      `/api/muayene/${muayeneId}/sablon/${sablonId}`, {}),

  /** Tani onerileri: bu HASTANIN onceki tanilari + bu HEKIMIN son 90 gunde
      en cok yazdiklari (mockup "Onceki tanilar" / "Sik kullandiklarim"). */
  muayeneTaniOnerileri: (muayeneId: number) =>
    istek<{
      onceki: { kod: string; ad: string; kronik: number; son: string }[];
      sik: { kod: string; ad: string; adet: number }[];
    }>(`/api/muayene/${muayeneId}/tani-onerileri`),

  /** Listeden secilen ICD kodunu tani satiri olarak ekler (ana tani varsa EK). */
  muayeneTaniEkle: (muayeneId: number, icdKod: string) =>
    gonder<{ eklendi: boolean; mesaj: string }>(
      `/api/muayene/${muayeneId}/tani/${encodeURIComponent(icdKod)}`, {}),

  /** ILAC SECILIRKEN alerji/tekrar uyarisi (yazmadan once gorunsun). */
  receteKontrol: (hastaId: number, barkod: string) =>
    istek<{ uyarilar: { tur: string; metin: string }[] }>(
      `/api/recete/kontrol?hastaId=${hastaId}&barkod=${encodeURIComponent(barkod)}`),

  /** Receteye ilac ekler; recete yoksa acar. Uyari ENGEL degil - gerekce ile gecilir. */
  receteIlacEkle: (muayeneId: number, istek_: {
    barkod: string; doz?: string; periyot?: string; sureGun?: number;
    kutu?: number; aciklama?: string; uyariGerekce?: string;
  }) => gonder<{ receteId: number; satirId: number; uyarilar: unknown[]; mesaj: string }>(
    `/api/recete/muayene/${muayeneId}`, istek_),

  /** Imzalanmamis receteden ilac cikarir. */
  receteIlacSil: (receteId: number, satirId: number) =>
    istek<{ mesaj: string }>(`/api/recete/${receteId}/ilac/${satirId}`,
                             { method: 'DELETE' }),

  /** Hastanin son imzali recetesindeki ilaclari bu muayenenin recetesine kopyalar. */
  receteOncekiKopyala: (muayeneId: number) =>
    gonder<{ receteId: number; eklenen: number; mesaj: string }>(
      `/api/recete/muayene/${muayeneId}/kopyala`, {}),

  /** Receteyi imzalar: kilitler ve aktif ilac listesine isler. */
  receteImzala: (receteId: number) =>
    gonder<{ mesaj: string }>(`/api/recete/${receteId}/imzala`, {}),

  /** Muayene kartinin ek sekmeleri (e-Recete, konsultasyon, ucret, gecmis). */
  muayeneSekmeVerisi: (muayeneId: number) =>
    istek<{
      belgeId: number | null; ustMuayeneId: number | null; tanilar: string;
      receteler: Record<string, unknown>[]; receteSatirlari: Record<string, unknown>[];
      konsultasyonlar: Record<string, unknown>[]; islemler: Record<string, unknown>[];
      gecmis: Record<string, unknown>[];
    }>(`/api/muayene/${muayeneId}/sekme-verisi`),

  /** Metin anahtarli katalogda (ICD...) kullanicinin SIK ve SON kullandiklari. */
  katalogKullanilan: (kaynak: string) =>
    istek<{ sik: { kod: string; ad: string; say: number }[];
            son: { kod: string; ad: string; tarih: string }[] }>(
      `/api/liste/${kaynak}/kullanilan`),

  /** Katalog kullanim sayaci (secim aninda). */
  katalogKullanildi: (kaynak: string, kod: string) =>
    gonder<{ isaretlendi: boolean }>(
      `/api/liste/${kaynak}/kullanilan/${encodeURIComponent(kod)}`, {}),

  /** Onceki muayeneden anamnez + tanilari kopyalar (bos alan doldurulur). */
  muayeneOncekiKopyala: (muayeneId: number, kaynakId: number) =>
    gonder<{ taniEklenen: number; mesaj: string }>(
      `/api/muayene/${muayeneId}/onceki-kopyala/${kaynakId}`, {}),

  /** Kartin raporlari (imza secimi icin). */
  muayeneRaporlari: (muayeneId: number) =>
    istek<{ raporlar: Record<string, unknown>[] }>(`/api/muayene/${muayeneId}/raporlar`),

  /** Raporu imzalar: kilitler; eksik rapor (tur/baslangic/gun/tani) reddedilir. */
  muayeneRaporImzala: (raporId: number) =>
    gonder<{ mesaj: string }>(`/api/muayene/rapor/${raporId}/imzala`, {}),

  /** Kartin tani satirlari (arac cubugundaki sil icin). */
  muayeneTanilari: (muayeneId: number) =>
    istek<{ tanilar: { id: number; kod: string; ad: string; tur: number }[] }>(
      `/api/muayene/${muayeneId}/tanilar`),

  /** Tani satirini kaldirir (kartla AYNI uc - silme izi tek yoldan). */
  muayeneTaniSil: (muayeneId: number, taniId: number) =>
    istek<{ mesaj: string }>(`/api/muayene/${muayeneId}/tani/${taniId}`,
                             { method: 'DELETE' }),

  /** Bos bulgu satirlarini "normal" isaretler (mockup "Tumu normal isaretle").
      Bulgu METNI YAZILMIS satira dokunmaz - o hekimin karari. */
  muayeneTumuNormal: (muayeneId: number) =>
    gonder<{ isaretlenen: number; bulguOzet: string; mesaj: string }>(
      `/api/muayene/${muayeneId}/tumu-normal`, {}),

  /** Bulgulardan muayene ozetini yeniden derler (rapora/e-Nabiz'a giden metin). */
  muayeneOzetDerle: (muayeneId: number) =>
    gonder<{ bulguOzet: string }>(`/api/muayene/${muayeneId}/ozet-derle`, {}),

  /** Kurumsal klasore dokuman yukler (419): kaynagi bir KART OLMAYAN
      dokuman (prosedur, talimat, sozlesme). Tur/gizlilik klasor
      varsayilanindan gelir - her yuklemede ayni soru sorulmasin. */
  dokumanKlasoreYukle: async (klasorId: number, dosya: File, kategoriId?: number) => {
    const govde = new FormData();
    govde.append('dosya', dosya);
    if (kategoriId) govde.append('kategoriId', String(kategoriId));
    // DOSYA YUKLEME `dosyaYukle` ILE: `istek` govdeyi JSON sayip
    //   "Content-Type: application/json" basligini koyuyor; tarayici o zaman
    //   multipart SINIRINI (boundary) yazamiyor ve sunucu istegi
    //   "Incorrect Content-Type" ile reddediyordu - yukleme HER SEFERINDE
    //   "beklenmeyen hata" veriyordu.
    return dosyaYukle<{ dokumanId: number; durum: number; mesaj: string }>(
      `/api/dokuman-yonetim/klasor/${klasorId}/yukle`, govde);
  },

  // ----------------------------------------------------------------- CIHAZ
  /** Ham cihaz mesajini kuyruga alir (432) - kopru uygulamalari ve TEST icin. */
  cihazMesaj: (cihazId: number, ham: string, kaynak?: string) =>
    gonder<{ mesajId: number; durum: string; mesaj: string }>(
      '/api/cihaz/mesaj', { cihazId, ham, kaynak }),

  /** Surucu duzeltildikten sonra ayni ham metni tekrar cozumler. */
  cihazYenidenIsle: (mesajId: number) =>
    gonder<{ durum: string; mesaj: string }>(
      `/api/cihaz/mesaj/${mesajId}/yeniden-isle`, {}),

  cihazMesajOku: (mesajId: number) =>
    istek<{ mesaj: Record<string, unknown>; kalemler: Record<string, unknown>[] }>(
      `/api/cihaz/mesaj/${mesajId}`),

  cihazKlasorTara: () =>
    gonder<{ okunan: number; hatali: number; mesaj: string }>(
      '/api/cihaz/klasor-tara', {}),

  // ------------------------------------------------------------------- LAB
  /** Basvurudan istem acar; tup planini ve barkodlari sunucu uretir (433). */
  labIstemAc: (govde: { belgeId: number;
                        satirlar: { tetkikId?: number; panelId?: number }[];
                        oncelik?: number; klinikBilgi?: string; taniIcd?: string }) =>
    gonder<{ id: number; istemNo: string; barkodlar: string[];
             tetkikSayisi: number; mesaj: string }>('/api/lab/istem', govde),

  /** Kartla acilan istemin barkodlarini uretir (uc yolunda plan zaten calisir). */
  labNumunePlani: (istemId: number) =>
    gonder<{ id: number; barkodlar: string[]; mesaj: string }>(
      `/api/lab/istem/${istemId}/numune-plani`, {}),

  /**
   * AI REHBER (447): "ne nerede, nasil yapilir". Sunucu katalog + yetki ile
   * cevaplar; panel yalniz cizer - istemcide is kurali yok.
   */
  aiRehber: (govde: { kullaniciMesaji: string; aktifMod?: number;
                      aktifSayfa?: string; seciliKaynak?: string }) =>
    gonder<Record<string, unknown>>('/api/ai/rehber', govde),

  /** Sonuc onay ekraninin ust serit sayaclari (446, mockup ".ozet"). */
  labOzet: () =>
    istek<{ sayaclar: Record<string, number>;
            cihazlar: Record<string, unknown>[] }>('/api/lab/ozet'),

  /**
   * AI KONTROLLU ONERI (449): acik kaydin eksikleri. Kurallar sunucuda;
   * panel yalniz cizer - istemcide is kurali yok.
   */
  aiOneri: (kaynak: string, kayitId: number) =>
    gonder<{ kaynak: string; kayitId: number; engel: number; uyari: number;
             bilgi: number;
             oneriler: { kod: string; seviye: number; baslik: string;
                         aciklama: string; alan: string; ekran: string;
                         rota?: string }[] }>('/api/ai/oneri', { kaynak, kayitId }),

  /** "Bunu bir daha gosterme": kural silinmez, bu kullanici icin susar. */
  aiOneriGizle: (kod: string, gizle: boolean) =>
    gonder<{ mesaj: string }>('/api/ai/oneri/gizle', { kod, gizle }),

  /**
   * e-NABIZ PAKET KARTI (454): paketin USS alanlari ve gonderim denemeleri.
   * SALT OKUNUR - paket elle duzeltilmez, kaynak duzeltilip yeniden uretilir.
   */
  enabizPaketOku: (id: number) =>
    istek<{ paket: Record<string, unknown>;
            alanlar: Record<string, unknown>[];
            denemeler: Record<string, unknown>[] }>(`/api/enabiz/paket/${id}`),

  /** e-Nabiz veri kalitesi panosu (454): donem "YYYY-MM". */
  enabizVeriKalitesi: (ay: string) =>
    istek<never>(`/api/enabiz/veri-kalitesi?ay=${encodeURIComponent(ay)}`),

  labIstemOku: (id: number) =>
    istek<Record<string, unknown>>(`/api/lab/istem/${id}`),

  /** Muayene "Istem & Sonuclar" sekmesi: basvurunun istemleri. */
  labBasvuruIstemleri: (belgeId: number) =>
    istek<{ belgeId: number; istemler: Record<string, unknown>[] }>(
      `/api/lab/basvuru/${belgeId}/istemler`),

  /** durum: 2 alindi · 3 kabul · 0 ret (ret nedeni ZORUNLU). */
  labNumuneDurum: (id: number, durum: number, ek?: { kalite?: number;
                                                     retNeden?: number;
                                                     aciklama?: string }) =>
    gonder<{ id: number; mesaj: string }>(`/api/lab/numune/${id}/durum`,
      { durum, ...(ek ?? {}) }),

  /**
   * İSTEMİN TÜM TÜPLERİ tek işlemde (mockup araç çubuğu "✔ Numune Kabul" /
   * "✖ Numune Ret"): hangi tüpün işleneceğine sunucu karar verir - çalışılmış
   * numuneye dokunulmaz.
   */
  /**
   * Kurumun YURURLUKTEKI sozlesmeleri (468). Basvuru karti bunlarla secici
   * cizer; tek sozlesme varsa deger zaten bellidir.
   */
  kurumSozlesmeleri: (kurumId: number) =>
    istek<{ kurumId: number; sozlesmeler: {
      id: number; ad: string; altKurum: number; altKurumAdi: string;
      sozlesmeNo: string; durum: number; rota: number; tur: number;
      fiyatListesiId: number | null; sgkFiyatListesiId: number | null;
      sgkKurumId: number | null; varsayilanKarsilama: number;
    }[] }>(`/api/kurum/${kurumId}/sozlesmeler`),

  /**
   * Satirlarin ODEME DAGILIMINI yeniler (472/474). Istemci KURAL gondermez:
   * rota sozlesmeden, fiyatlar SUT/TTB listelerinden sunucuda cozulur.
   */
  belgeDagit: (belgeId: number, govde?: {
    /** `sgkListe`: SUT bedeli EKRANDAN (483) - liste boşsa kullanıcı girer. */
    sgkProvizyon?: { satirId: number; tutar?: number; provizyonNo?: string;
                     sgkListe?: number; huvListe?: number }[];
    ossProvizyon?: number;
  }) =>
    gonder<{ id: number; satir: number; mesaj: string }>(
      `/api/belge/${belgeId}/dagit`, govde ?? {}),

  labIstemNumuneDurum: (istemId: number, durum: number,
                        ek?: { kalite?: number; retNeden?: number; aciklama?: string }) =>
    gonder<{ id: number; mesaj: string }>(`/api/lab/istem/${istemId}/numune-durum`,
      { durum, ...(ek ?? {}) }),

  /** Tüplerin saklama yeri / sıcaklığı (mockup "🧊 Saklama Yeri"). */
  labIstemSaklama: (istemId: number, yer: string, sicaklik?: number) =>
    gonder<{ id: number; say: number; mesaj: string }>(
      `/api/lab/istem/${istemId}/saklama`, { yer, sicaklik }),

  /**
   * ÇALIŞMA TAKVİMİ ÖNİZLEMESİ (487). Düzen PARAMETRE gider, tetkik id ile
   * değil: kullanıcı kartta düzeni değiştirirken önizleme kaydetmeden
   * güncellensin. Saatleri sunucu hesaplar - aynı kural istem ekranında da
   * çalışıyor, ikinci bir hesap iki farklı saat söylerdi.
   */
  /** Tetkik Katalogu sol paneli (492): bolum sayimlari + panel uyelikleri. */
  labTetkikAgaci: () =>
    istek<{ toplam: number;
            bolumler: { kod: number; ad: string; ikon: string; adet: number; aktif: number }[];
            paneller: { id: number; kod: string; ad: string; durum: number;
                        tetkikIdleri: number[] }[] }>('/api/lab/tetkik/agac'),

  /** Tetkik Katalogu sag paneli (492): secili tetkigin ozeti. */
  labTetkikOzeti: (id: number) =>
    istek<{ tetkik: Record<string, unknown>; referanslar: Record<string, unknown>[];
            paneller: { id: number; ad: string }[]; istemAdedi: number }>(
      `/api/lab/tetkik/${id}/ozet`),

  labCalismaTakvimi: (d: { duzen: number; gunler: number; saatler: string;
                           kabulSonDk: number; tatDk: number; acilTatDk: number;
                           acilBeklemez: number; kabul: string }) =>
    istek<{ duzen: number;
            hafta: { saat: string; kabulSon: string;
                     gunler: { acik: boolean; sonuc?: string | null }[] }[];
            ozet: { simdiKabul: string; simdi: string | null;
                    kacirilan: string | null; acil: string | null } }>(
      '/api/lab/calisma-takvimi?'
      + `duzen=${d.duzen}&gunler=${d.gunler}`
      + `&saatler=${encodeURIComponent(d.saatler)}`
      + `&kabulSonDk=${d.kabulSonDk}&tatDk=${d.tatDk}&acilTatDk=${d.acilTatDk}`
      + `&acilBeklemez=${d.acilBeklemez}&kabul=${encodeURIComponent(d.kabul)}`),

  labNumuneBarkod: (barkod: string) =>
    istek<Record<string, unknown>>(
      `/api/lab/numune/barkod/${encodeURIComponent(barkod)}`),

  /** Kural motoru sunucuda calisir: bayrak/panik/delta yanitla doner. */
  labSonucYaz: (govde: { istemSatirId: number; deger: string; birim?: string;
                         yorum?: string; dilusyon?: number }) =>
    gonder<{ sonucId: number; bayrak: string; panik: boolean;
             deltaUyari: boolean; mesaj: string }>('/api/lab/sonuc', govde),

  /** asama 1 teknik, 2 uzman (yayin). */
  labSonucOnayla: (id: number, asama = 2) =>
    gonder<{ mesaj: string }>(`/api/lab/sonuc/${id}/onayla`, { asama }),

  labSonucDuzelt: (id: number, deger: string, neden: string) =>
    gonder<{ sonucId: number; bayrak: string; mesaj: string }>(
      `/api/lab/sonuc/${id}/duzelt`, { deger, neden }),

  labPanikBildir: (sonucId: number, bildirilenAd: string, kanal = 1,
                   aciklama?: string) =>
    gonder<{ bildirimId: number; mesaj: string }>(
      `/api/lab/sonuc/${sonucId}/panik`, { bildirilenAd, kanal, aciklama }),

  labPanikTeyit: (bildirimId: number, teyitEden: string) =>
    gonder<{ mesaj: string }>(`/api/lab/panik/${bildirimId}/teyit`, { teyitEden }),

  /** Host query: cihaz "bu barkodda ne calisacagim" der. */
  labCalismaListesi: (cihazId: number, barkod: string) =>
    istek<{ satirlar: Record<string, unknown>[] }>(
      `/api/lab/cihaz/${cihazId}/calisma-listesi/${encodeURIComponent(barkod)}`),

  /** Cozumlenmis cihaz mesajini lab sonucuna aktarir. */
  labCihazMesajIsle: (mesajId: number) =>
    gonder<{ yazilan: number; atlanan: number; mesaj: string }>(
      `/api/lab/cihaz-mesaj/${mesajId}/isle`, {}),

  /** Tup barkod etiketi (444): istemin TUM tupleri ya da tek numune. */
  labEtiket: (ek: { istemId?: number; numuneId?: number }) => {
    const q = new URLSearchParams();
    if (ek.istemId) q.set('istemId', String(ek.istemId));
    if (ek.numuneId) q.set('numuneId', String(ek.numuneId));
    return istek<{ etiketler: Record<string, unknown>[];
                   kurum: Record<string, unknown> | null }>(`/api/lab/etiket?${q}`);
  },

  /** Muayene karti "Istem & Sonuclar" sekmesi (443): bag + SONUCUN KENDISI. */
  /** Muayene listesi ozet seridi (461): poliklinigin o gunku hali. */
  muayeneOzet: (gun?: string) =>
    istek<never>(`/api/muayene/ozet${gun ? `?gun=${gun}` : ''}`),

  muayeneSonuclari: (muayeneId: number) =>
    istek<{ muayeneId: number; belgeId: number | null;
            baglar: Record<string, unknown>[];
            istemler: Record<string, unknown>[];
            sonuclar: Record<string, unknown>[];
            kulturler: Record<string, unknown>[];
            vakalar: Record<string, unknown>[];
            radyoloji: Record<string, unknown>[] }>(
      `/api/lab/muayene/${muayeneId}/sonuclar`),

  /** Hekim sonucu gordu (418): sonucun gelmesi ile gorulmesi AYRI olaylar. */
  muayeneIstemGordu: (bagId: number) =>
    gonder<{ id: number; zaman: string; mesaj: string }>(
      `/api/muayene/istem/${bagId}/gordu`, {}),

  // ------------------------------------------------ DIS LABORATUVAR (445)
  /** Secilen tetkikleri dis laboratuvara sevk eder (kurye + soguk zincir). */
  disLabGonder: (govde: { disLabId: number; istemSatirIdler: number[];
                          kuryeFirma?: string; kuryeAd?: string; kuryeTel?: string;
                          tasimaKosulu?: number; sicaklik?: number;
                          kapSayisi?: number; aciklama?: string }) =>
    gonder<{ id: number; gonderimNo: string; satir: number; mesaj: string }>(
      '/api/lab/dis/gonder', govde),

  disLabOku: (id: number) =>
    istek<{ gonderim: Record<string, unknown>;
            satirlar: Record<string, unknown>[] }>(`/api/lab/dis/${id}`),

  disLabYolda: (id: number) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/yolda`, {}),

  /** Dis kabul no: sonuc eslestirmesinde iki laboratuvarin ortak referansi. */
  disLabTeslim: (id: number, teslimAlan: string, disKabulNo: string) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/teslim`,
      { teslimAlan, disKabulNo }),

  /** Dis lab sonucu: kurallar isler ama OTO-ONAY KAPALI. */
  disLabSonuc: (id: number, govde: { istemSatirId: number; deger: string;
                                     birim?: string; yorum?: string;
                                     sonucZamani?: string }) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/sonuc`, govde),

  /** durum: 3 dis lab reddetti · 4 numune kayboldu. */
  disLabRet: (id: number, istemSatirId: number, durum: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/ret`,
      { istemSatirId, durum, neden }),

  disLabFatura: (id: number, belgeId: number, tutar?: number) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/fatura`, { belgeId, tutar }),

  /** Sozlesme TAT'ini asan gonderimler - hastanin sonucu baska binada. */
  disLabGeciken: () =>
    istek<{ liste: Record<string, unknown>[] }>('/api/lab/dis/geciken'),

  // -------------------------------------------------- KALITE KONTROL (442)
  /** KK olcumu: z skoru ve Westgard degerlendirmesi SUNUCUDA hesaplanir. */
  kkOlcum: (govde: { lotId: number; tetkikId: number; seviye: number;
                     deger: number; cihazId?: number; zaman?: string;
                     kaynak?: number; tekrar?: boolean }) =>
    gonder<{ id: number; z: number | null; durum: number; ihlaller: string[];
             mesaj: string }>('/api/lab/kk/olcum', govde),

  /** Ret/uyari sonrasi duzeltici faaliyet (ISO 15189) - metin ZORUNLU. */
  kkAksiyon: (olcumId: number, govde: { aksiyon: string; gozdenGecirilen?: number;
                                        duzeltilen?: number; olay?: number }) =>
    gonder<{ mesaj: string }>(`/api/lab/kk/olcum/${olcumId}/aksiyon`, govde),

  /** Levey-Jennings serisi + ayni donemin cihaz olaylari. */
  labKkLj: (tetkikId: number, ek?: { lotId?: number; seviye?: number; gun?: number }) => {
    const s = new URLSearchParams({ tetkikId: String(tetkikId) });
    if (ek?.lotId) s.set('lotId', String(ek.lotId));
    if (ek?.seviye) s.set('seviye', String(ek.seviye));
    if (ek?.gun) s.set('gun', String(ek.gun));
    return istek<{ tetkik: Record<string, unknown> | null;
                   seri: Record<string, unknown>[];
                   olaylar: Record<string, unknown>[] }>(`/api/lab/kk/lj?${s}`);
  },

  /** Dis kalite sonucu; SDI = (bizim - hedef) / grup SD, sunucuda. */
  kkDkk: (govde: { program: string; donem: string; tetkikId: number;
                   numuneKodu?: string; sonucumuz: number; hedef: number;
                   grupSd?: number; grupN?: number; yontem?: string;
                   raporTarihi?: string }) =>
    gonder<{ id: number; sdi: number | null; degerlendirme: number; mesaj: string }>(
      '/api/lab/kk/dkk', govde),

  /** Cihazdan gelen KONTROL mesajini KK olcumune cevirir. */
  kkCihazMesaj: (mesajId: number) =>
    gonder<{ yazilan: number; mesaj: string }>(`/api/lab/kk/cihaz-mesaj/${mesajId}`, {}),

  /** Testlerin KK gecerliligi - oto-onay penceresi. */
  kkDurum: () =>
    istek<{ liste: Record<string, unknown>[] }>('/api/lab/kk/durum'),

  // --------------------------------------------------------- GENETIK (439)
  /** Istem satirindan genetik vaka acar; rapor icin ONAM sart (KVKK md. 6). */
  genetikVakaAc: (istemSatirId: number, istek?: { panelId?: number;
                                                  endikasyon?: string;
                                                  taniIcd?: string;
                                                  aileOykusu?: string;
                                                  anaVakaId?: number;
                                                  aileRolu?: number }) =>
    gonder<{ vakaId: number; vakaNo: string; mesaj: string }>(
      `/api/lab/satir/${istemSatirId}/genetik-vaka`, istek ?? {}),

  /** Vaka calisma alani: onam, kalite, varyantlar. */
  genetikVakaOku: (id: number) =>
    istek<Record<string, unknown>>(`/api/lab/genetik/${id}`),

  /** tesadufiBulgu: 1 istiyor · 2 istemiyor - raporlamayi dogrudan degistirir. */
  genetikOnam: (id: number, govde: { surum: string; tesadufiBulgu: number;
                                     veriSaklamaYil?: number;
                                     arastirmaIzni?: boolean }) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/onam`, govde),

  genetikIzolasyon: (id: number, konsantrasyon: number, saflik: number,
                     not?: string) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/izolasyon`,
      { konsantrasyon, saflik, not }),

  genetikRunaAl: (id: number, govde: { runId?: number; runKodu?: string;
                                       cihazAdi?: string; kit?: string;
                                       kitLot?: string; flowCell?: string;
                                       barkodIndex?: string }) =>
    gonder<{ runId: number; runKodu: string; mesaj: string }>(
      `/api/lab/genetik/${id}/run`, govde),

  genetikKalite: (id: number, govde: { q30?: number; okumaSayisi?: number;
                                       ortDerinlik?: number; kapsamaYuzde?: number;
                                       kontaminasyon?: number;
                                       cinsiyetDogrulama?: number; kalite?: number;
                                       fastqYol?: string; bamYol?: string;
                                       vcfYol?: string; hamHash?: string }) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/kalite`, govde),

  /** Sinif ACMG kanitlarindan SUNUCUDA turetilir; banka uyarisi yanitla doner. */
  genetikVaryant: (id: number, govde: { genSembol: string; transkript?: string;
                                        hgvsC: string; hgvsP?: string;
                                        zigosite?: number; derinlik?: number;
                                        vaf?: number; gnomadAf?: number;
                                        clinVar?: string; clinVarId?: string;
                                        acmgKriterler?: string[];
                                        ikincilBulgu?: boolean; yorum?: string }) =>
    gonder<{ id: number; sinif: number; sinifAdi: string; raporlanir: boolean;
             bankaUyarisi: string | null; mesaj: string }>(
      `/api/lab/genetik/${id}/varyant`, govde),

  varyantSinif: (id: number, sinif: number, neden: string, raporla?: boolean) =>
    gonder<{ mesaj: string }>(`/api/lab/varyant/${id}/sinif`,
      { sinif, neden, raporla }),

  /** durum: 1 istendi · 2 dogrulandi · 3 dogrulanamadi (rapordan cikar). */
  varyantDogrulama: (id: number, durum: number, yontem?: string) =>
    gonder<{ mesaj: string }>(`/api/lab/varyant/${id}/dogrulama`, { durum, yontem }),

  genetikOnayla: (id: number, yorum?: string, oneriler?: string,
                  sinirliliklar?: string) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/onayla`,
      { yorum, oneriler, sinirliliklar }),

  genetikIptal: (id: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/iptal`, { neden }),

  /** Bilgi bankasindaki sinif degisince etkilenen ONAYLI vakalar. */
  genetikYenidenDegerlendirme: () =>
    istek<{ liste: Record<string, unknown>[] }>(
      '/api/lab/genetik/yeniden-degerlendirme'),

  /** Hastaya verilen SONUC RAPORU (441): uc bolum de tek uctan gelir. */
  labRaporCikti: (istemId: number) =>
    istek<{
      istem: Record<string, unknown>;
      sonuclar: Record<string, unknown>[];
      kulturler: Record<string, unknown>[];
      izolatlar: Record<string, unknown>[];
      antibiyogram: Record<string, unknown>[];
      vakalar: Record<string, unknown>[];
      varyantlar: Record<string, unknown>[];
      kurum: Record<string, unknown> | null;
    }>(`/api/lab/rapor/${istemId}`),

  // --------------------------------------------------- MIKROBIYOLOJI (436)
  /** Kulturu acar: besiyeri seti verilmezse tetkigin varsayilani kullanilir. */
  labEkim: (istemSatirId: number, istek?: { besiyeriIdler?: number[];
                                            sicaklik?: number; atmosfer?: number;
                                            direktBaki?: string; gramSonuc?: string;
                                            numuneKalite?: string }) =>
    gonder<{ kulturId: number; mesaj: string }>(
      `/api/lab/satir/${istemSatirId}/ekim`, istek ?? {}),

  /** Kultur calisma alani: besiyeri + okuma + izolat + antibiyogram. */
  labKulturOku: (id: number) =>
    istek<Record<string, unknown>>(`/api/lab/kultur/${id}`),

  labKulturOkuma: (id: number, govde: { saat?: number; uremeVar: boolean;
                                        bulgu?: string; sonrakiAdim?: string }) =>
    gonder<{ mesaj: string }>(`/api/lab/kultur/${id}/okuma`, govde),

  /** Gram / erken bulgu hekime: kultur bitmeden gider. */
  labKulturOnRapor: (id: number, metin: string, kritik = false) =>
    gonder<{ mesaj: string }>(`/api/lab/kultur/${id}/on-rapor`, { metin, kritik }),

  labKulturIzolat: (id: number, govde: { organizmaId: number; koloniSayisi?: number;
                                         koloniBirim?: string; idYontem?: number;
                                         idGuven?: number; esbl?: number;
                                         karbapenemaz?: number; mrsa?: number;
                                         vre?: number; ampc?: number;
                                         direncNotu?: string; anlamli?: boolean }) =>
    gonder<{ uremeId: number; mesaj: string }>(`/api/lab/kultur/${id}/izolat`, govde),

  /** Kademeli bildirimi SUNUCU hesaplar; yanit kac satirin raporlanacagini soyler. */
  labAntibiyogram: (uremeId: number, govde: {
      standart?: string; standartSurum?: string;
      satirlar: { antibiyotikId: number; mic?: number; micIsaret?: string;
                  zonMm?: number; yorum: string; kaynak?: number;
                  aciklama?: string }[] }) =>
    gonder<{ satir: number; bildirilen: number; mesaj: string }>(
      `/api/lab/izolat/${uremeId}/antibiyogram`, govde),

  /** Uzman S/I/R degistirir - GEREKCE zorunlu. */
  labAntibiyogramYorum: (id: number, yorum: string, neden: string, bildir = true) =>
    gonder<{ mesaj: string }>(`/api/lab/antibiyogram/${id}/yorum`,
      { yorum, neden, bildir }),

  labKulturOnayla: (id: number, yorum?: string) =>
    gonder<{ mesaj: string }>(`/api/lab/kultur/${id}/onayla`, { yorum }),

  labKulturIptal: (id: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/lab/kultur/${id}/iptal`, { neden }),

  // --------------------------------------------------------------- SIGORTA
  /** Sağlayıcı kataloğu + yetenekler (430): ekran düğmeleri buna göre çizilir. */
  sigortaSaglayicilar: () =>
    istek<{ saglayicilar: { id: number; kod: string; ad: string;
                            yetenekler: string; durum: number; hesap: number }[] }>(
      '/api/sigorta/saglayicilar'),

  /** checkPolicy - poliçe bu kurumda, bu hekimle, bu tarihte geçerli mi. */
  sigortaPoliceSorgu: (govde: { tarafId: number; kurumId: number; hekimId?: number;
                                policeNo?: string; tarih?: string }) =>
    gonder<{ id: number; gecerli: boolean; policeNo: string; policeAdi: string;
             kartNo: string; agKodu: string; notlar: string[]; mesaj: string }>(
      '/api/sigorta/police-sorgu', govde),

  /** createProvision - başvurudan provizyon oluştur/güncelle; paylar yazılır. */
  sigortaProvizyon: (govde: { belgeId: number; tip?: number; altTip?: number;
                              hizmetTipi?: number; vakaTipi?: number;
                              talepTuru?: number; acil?: boolean; not?: string }) =>
    gonder<{ id: number; mesaj: string }>('/api/sigorta/provizyon', govde),

  sigortaProvizyonOku: (id: number) =>
    istek<{ ozet: Record<string, unknown>;
            satirlar: Record<string, unknown>[];
            tanilar: { kod: string; ad: string }[];
            notlar: { tip: string; metin: string }[];
            dokumanlar: Record<string, unknown>[] }>(`/api/sigorta/provizyon/${id}`),

  sigortaTazele: (id: number) =>
    gonder<{ mesaj: string }>(`/api/sigorta/provizyon/${id}/tazele`, {}),

  sigortaIptal: (id: number, nedenKodu: number, aciklama: string) =>
    gonder<{ mesaj: string }>(`/api/sigorta/provizyon/${id}/iptal`,
      { nedenKodu, aciklama }),

  sigortaDokumanGonder: (id: number, tipKodu: string, dokumanId: number) =>
    gonder<{ mesaj: string }>(`/api/sigorta/provizyon/${id}/dokuman`,
      { tipKodu, dokumanId }),

  sigortaHesapTest: (id: number) =>
    gonder<{ saglayici: string; test: boolean; mesaj: string; notlar: string[] }>(
      `/api/sigorta/hesap/${id}/test`, {}),

  // ---------------------------------------------------------------- URETIM
  /** Agacin birim maliyetini hesaplar ve TARIHLI olarak karta yazar (429). */
  uretimAgacMaliyet: (agacId: number, gugYuzde = 0) =>
    gonder<{ malzeme: number; iscilik: number; gug: number; toplam: number }>(
      `/api/uretim/agac/${agacId}/maliyet`, { gugYuzde }),

  /** Agaci kopyalar, surumu artirir; ESKI SURUM PASIFLESIR ama silinmez. */
  uretimYeniSurum: (agacId: number) =>
    gonder<{ id: number; kod: string; surum: number; mesaj: string }>(
      `/api/uretim/agac/${agacId}/yeni-surum`, {}),

  /** Ters agac: bilesen hangi mamullerde geciyor (fiyat degisim etkisi). */
  uretimNeredeKullaniliyor: (stokId: number) =>
    istek<{ kayitlar: { id: number; kod: string; ad: string; surum: number;
                        miktar: number; mamul: string }[] }>(
      `/api/uretim/agac/nerede-kullaniliyor/${stokId}`),

  /** Emir acar ve agaci EMRE KOPYALAR (agac sonra degisse emir etkilenmez). */
  uretimEmriAc: (govde: { stokId: number; agacId?: number; adet: number;
                          tur?: number; planBas?: string; termin?: string;
                          sarfDepoId?: number; mamulDepoId?: number;
                          kaynakBelgeId?: number; kaynakSatirId?: number;
                          ustEmirId?: number; aciklama?: string }) =>
    gonder<{ id: number; no: string; bilesen: number; operasyon: number; mesaj: string }>(
      '/api/uretim/emri', govde),

  uretimAgactanYenile: (id: number) =>
    gonder<{ mesaj: string }>(`/api/uretim/emri/${id}/agactan-yenile`, {}),

  uretimRezerve: (id: number, ac: boolean) =>
    gonder<{ satir: number; hazirlik: number; mesaj: string }>(
      `/api/uretim/emri/${id}/rezerve?ac=${ac}`, {}),

  uretimOnayla: (id: number) =>
    gonder<{ mesaj: string }>(`/api/uretim/emri/${id}/onayla`, {}),

  uretimBaslat: (id: number) =>
    gonder<{ sarfBelgeId: number | null; mesaj: string }>(
      `/api/uretim/emri/${id}/baslat`, {}),

  uretimSarf: (id: number, satirlar?: { satirId: number; miktar: number }[]) =>
    gonder<{ belgeId: number; mesaj: string }>(`/api/uretim/emri/${id}/sarf`,
      satirlar ? { satirlar } : {}),

  uretimMamulGiris: (id: number, adet: number, birimFiyat?: number) =>
    gonder<{ belgeId: number; uretilen: number; adet: number; durum: number;
             mesaj: string }>(
      `/api/uretim/emri/${id}/mamul-giris`, { adet, birimFiyat }),

  uretimFire: (id: number, stokId: number, adet: number, neden?: string) =>
    gonder<{ belgeId: number; mesaj: string }>(
      `/api/uretim/emri/${id}/fire`, { stokId, adet, neden }),

  uretimMaliyetKapat: (id: number, gugYuzde = 0) =>
    gonder<{ malzeme: number; iscilik: number; toplam: number; birim: number;
             planBirim: number; farkYuzde: number; mesaj: string }>(
      `/api/uretim/emri/${id}/maliyet-kapat`, { gugYuzde }),

  uretimEmriKapat: (id: number) =>
    gonder<{ mesaj: string }>(`/api/uretim/emri/${id}/kapat`, {}),

  uretimEmriIptal: (id: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/uretim/emri/${id}/iptal`, { neden }),

  uretimEksikMalzeme: (id: number) =>
    istek<{ hazirlik: number;
            satirlar: { id: number; kod: string; ad: string; gerekli: number;
                        rezerve: number; sarfEdilen: number; mevcut: number;
                        eksik: number }[] }>(
      `/api/uretim/emri/${id}/eksik-malzeme`),

  /** ITS karekod cozumleme (427): GS1 ayristirma SUNUCUDA - her ekranda ayri
      cozumleyici, ayirici gondermeyen okuyucuda birinde calisip otekinde
      bozulurdu. */
  itsKarekod: (karekod: string, dogrula = false) =>
    gonder<{ gtin: string; barkod: string; seriNo: string; partiNo: string;
             sonKullanma: string | null; ilacAd: string; stokId: number;
             katalogda: boolean;
             dogrulama: { gecerli: boolean; durum: string; mesaj: string } | null }>(
      '/api/its/karekod', { karekod, dogrula }),

  /** Mal alim (kabul) bildirimi kuyruga. */
  itsBildirim: (istekGovdesi: { tur: number; belgeId?: number; karsiGln?: string;
                                karekodlar: string[]; islemTarihi?: string }) =>
    gonder<{ bildirimId: number; eklenen: number; mesaj: string }>(
      '/api/its/bildirim', istekGovdesi),

  itsGonder: (id: number) =>
    gonder<{ mesaj: string }>(`/api/its/bildirim/${id}/gonder`, {}),

  itsIptal: (id: number) =>
    gonder<{ mesaj: string }>(`/api/its/bildirim/${id}/iptal`, {}),

  /** Sol paneldeki klasor agaci + sayaclar (419). Kaynak klasorleri SANAL:
      dokumanin kaynak alanindan turer, tablo kaydi yoktur. */
  dokumanKlasorleri: () =>
    istek<{ toplam: number;
            kurumsal: { tur: string; id: number; ad: string; yol: string;
                        ustId: number; sayi: number }[];
            kaynaklar: { tur: string; kod: string; sayi: number }[] }>(
      '/api/dokuman-yonetim/klasorler'),

  /** Depo kullanimi: hash-dedup'in kazandirdigi yer ancak olculunce gorunur. */
  dokumanDepo: () =>
    istek<{ fizikselBayt: number; mantikselBayt: number; tasarrufBayt: number;
            icerikSayisi: number; dokumanSayisi: number }>('/api/dokuman-yonetim/depo'),

  /** Klasor / etiket / gizlilik degisimi - verilmeyen alan DEGISMEZ. */
  dokumanTasi: (id: number, istekGovdesi: { klasorId?: number; etiketler?: string[];
                                            gizlilik?: number }) =>
    gonder<{ mesaj: string }>(`/api/dokuman-yonetim/${id}/tasi`, istekGovdesi),

  /** Sureli / sayacli paylasim linki uretir (424). Ozel nitelikli dokumanda
      sunucu ayri yetki ister (dokuman.ozel_nitelikli). */
  dokumanPaylasimUret: (id: number, istekGovdesi: { gunSayisi?: number;
                                                    azamiAcilma?: number;
                                                    indirmeIzni?: boolean;
                                                    aliciEposta?: string }) =>
    gonder<{ paylasimId: number; kod: string; mesaj: string }>(
      `/api/dokuman-yonetim/${id}/paylasim`, istekGovdesi),

  /** Link SILINMEZ, iptal DAMGALANIR: silinen kod yeniden uretilebilir ve
      eski alici erisim kazanirdi. */
  dokumanPaylasimIptal: (paylasimId: number) =>
    gonder<{ mesaj: string }>(`/api/dokuman-yonetim/paylasim/${paylasimId}/iptal`, {}),

  /** Ek baglanti (419): birincil bag (dokuman.kaynak) DEGISMEZ, dokuman
      ikinci bir kayda da baglanir - ayni sozlesme hem cariye hem projeye. */
  dokumanBaglantiEkle: (id: number, kaynak: string, kaynakId: number, rol?: string) =>
    gonder<{ mesaj: string }>(`/api/dokuman-yonetim/${id}/baglanti`,
      { kaynak, kaynakId, rol }),

  /** Surumu onaya gonderir (419): akis adimlari SABLONDAN KOPYALANIR, akis
      sonradan degisirse suren onay etkilenmez. */
  dokumanOnayaGonder: (surumId: number) =>
    gonder<{ onayId: number; mesaj: string }>(
      `/api/dokuman-yonetim/surum/${surumId}/onaya-gonder`, {}),

  /** Onay adimi karari (419): 1 onay · 2 ret. Son adim onaylaninca YAYINLANIR. */
  dokumanOnayKarar: (onayId: number, karar: number, not?: string) =>
    gonder<{ mesaj: string }>(`/api/dokuman-yonetim/onay/${onayId}/karar`,
                              { karar, not }),

  /** e-Nabiz paketini KAYNAKTAN yeniden uretir (415): paket satirini elle
      duzeltmek, gonderilen veriyle kayittaki veriyi ayirirdi. */
  enabizYenidenUret: (paketId: number) =>
    gonder<{ yeni: string; durum: number; eksikler: string[]; mesaj: string }>(
      `/api/enabiz/paket/${paketId}/yeniden-uret`, {}),

  /** Paketi simdi gonder (415): hesap tanimli degilse sonuc bunu SOYLER. */
  enabizGonder: (paketId: number) =>
    gonder<{ alinan: number; gonderilen: number; hatali: number; mesaj: string }>(
      `/api/enabiz/paket/${paketId}/gonder`, {}),

  enabizPaketIptal: (paketId: number) =>
    gonder<{ mesaj: string }>(`/api/enabiz/paket/${paketId}/iptal`, {}),

  /** Sirayi cagir (410): belge verilmezse hekimin SIRADAKI hastasi. */
  siraCagir: (istek: { belgeId?: number; hekimId?: number }) =>
    gonder<{ belgeId: number; siraNo?: string; hasta?: string; ekranAdi?: string;
             cagirma?: string; mesaj: string }>('/api/muayene/sira/cagir', istek),

  /** Basvurudan muayeneye al: muayene kaydi yoksa ACILIR. */
  basvurudanMuayeneyeAl: (belgeId: number) =>
    gonder<{ belgeId: number; muayeneId: number; baslangic: string; yeni: boolean;
             mesaj: string }>(`/api/muayene/basvuru/${belgeId}/al`, {}),

  /** Muayeneden istem ac (418): asil kayit MODUL tablosunda acilir,
      muayene_istem bag ve durum satiridir. */
  muayeneIstemAc: (muayeneId: number, istek: { tur: number; hizmetId?: number;
                                               aciliyet?: number; aciklama?: string;
                                               tetkikIdler?: number[];
                                               panelIdler?: number[] }) =>
    gonder<{ istemId: number; hedefTablo: string; hedefId: number | null; mesaj: string }>(
      `/api/muayene/${muayeneId}/istem`, istek),

  /** Muayeneye Al (409): baslangic zamani - ikinci tikta ezilmez (sunucu). */
  muayeneyeAl: (id: number) =>
    gonder<{ id: number; baslangic: string; mesaj: string }>(`/api/muayene/${id}/al`, {}),

  /** Muayeneyi tamamla: kayit kilitlenir, eksikse 400 ile reddedilir. */
  muayeneTamamla: (id: number) =>
    gonder<{ id: number; belgeId: number | null; uyari: string | null; mesaj: string }>(
      `/api/muayene/${id}/tamamla`, {}),

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
                         listeId?: number | null; sozlesmeId?: number | null;
                         sgkKullan?: number | null }) =>
    istek<{ fiyat: number | null; bazFiyat: number | null; dovizCinsi: string;
            kdvDahil: number; kaynak: string; kampanyaId: number | null;
            listeId: number | null; satirId: number | null; tip: number | null;
            iskontoTipi: number | null; iskonto: number | null;
            /** Odeme rotasi (483): 1 Ozel · 2 OSS · 3 TSS · 4 Karma · 5 SGK. */
            rota: number; sgkGerekli: boolean;
            /** null ise SUT LISTESINDE YOK - bedel ekrandan istenir. */
            sgkFiyat: number | null; sgkListesiId: number | null;
            sgkKdvDahil: number; sgkKatilim: number }>(
      '/api/fiyat/kalem?'
      + (kalem.stokId ? `stokId=${kalem.stokId}` : `hizmetId=${kalem.hizmetId}`)
      + (kaynak.tarafId ? `&tarafId=${kaynak.tarafId}` : '')
      + (kaynak.kurumId ? `&kurumId=${kaynak.kurumId}` : '')
      + (kaynak.listeId ? `&listeId=${kaynak.listeId}` : '')
      // SOZLESME (483): SUT listesi ve rota ondan cikar - kurumun tek
      //   sozlesmesi yoksa sunucu hangi tarifeyi uygulayacagini bilemez.
      + (kaynak.sozlesmeId ? `&sozlesmeId=${kaynak.sozlesmeId}` : '')
      + (kaynak.sgkKullan != null ? `&sgkKullan=${kaynak.sgkKullan}` : '')),

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

  /**
   * Hakedis satirlari seridindeki Prim Rolu / Kisi combo secenekleri.
   * Secenekler ARALIKTAKI SATIRLARDAN uretilir (kullanici): combo'da
   * secilince bos grid veren secenek gorunmesin. `rol` verilirse kisi
   * listesi o rolde satiri olanlara daralir.
   */
  /**
   * Basvuru listesi seridindeki Odeyen / Bolum / Doktor combo secenekleri.
   * Secenekler ARALIKTAKI BASVURULARDAN uretilir (kullanici) - tanim
   * tablolarindan degil, yani secilince bos liste veren secenek gorunmez.
   */
  basvuruSuzgecSecenekleri: (bas?: string, bit?: string) => {
    const p = new URLSearchParams();
    if (bas) p.set('bas', bas);
    if (bit) p.set('bit', bit);
    const q = p.toString();
    type Secenek = { id: number; ad: string; adet: number };
    return istek<{ odeyenler: Secenek[]; bolumler: Secenek[]; doktorlar: Secenek[] }>(
      `/api/belge/basvuru-suzgec${q ? `?${q}` : ''}`);
  },

  hakedisSuzgecSecenekleri: (bas?: string, bit?: string, rol?: number) => {
    const p = new URLSearchParams();
    if (bas) p.set('bas', bas);
    if (bit) p.set('bit', bit);
    if (rol !== undefined) p.set('rol', String(rol));
    const q = p.toString();
    return istek<{ roller: { id: number; ad: string; adet: number }[];
                   kisiler: { id: number; ad: string; adet: number }[] }>(
      `/api/prim/hakedis-suzgec${q ? `?${q}` : ''}`);
  },

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

  /**
   * SKRS klinik kodlarini BOLUM KODUNA yazar (455). Dolu koda dokunmaz -
   * kurum kendi kodlamasini yapmis olabilir.
   */
  skrsKlinikEsle: (id: number) =>
    gonder<{ eslenen: number; skrsKodSayisi: number; mesaj: string;
             eslesmeyen: { id: number; ad: string }[] }>(
      `/api/entegrasyon/${id}/skrs-klinik-esle`, {}),

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

  // ----------------------------------------------------- zamanli isler ----
  /** Zamanlı işi zamanını beklemeden çalıştırır (kilit sunucuda). */
  zamanliIsCalistir: (kod: string) =>
    gonder<{ kod: string; sonuc: string }>(
      `/api/zamanli-is/${encodeURIComponent(kod)}/calistir`, {}),

  // --------------------------------------------------------- katalog ----
  /** Klinik katalogların durumu (ICD / ilaç): son senkron, satır sayısı. */
  katalogDurum: () =>
    istek<{ satirlar: {
      kod: string; ad: string; sonCalisma?: string | null; satirSayisi: number;
      sonuc: string; basarili: boolean; mevcutSatir: number }[] }>('/api/katalog/durum')
      .then(y => y.satirlar),
  /** ICD-10 listesini dosyadan yükler (upsert; gelmeyen kod pasife çekilmez). */
  katalogIcdYukle: (icerik: string) =>
    gonder<{ yazilan: number; atlanan: number }>('/api/katalog/icd-yukle', { icerik }),
  /** TİTCK'nin haftalık yayınından en güncel listeyi çekip kataloğu tazeler. */
  katalogTitckGuncelle: () =>
    gonder<{ yazilan: number; askida: number; atlanan: number; dosya: string; tarih: string }>(
      '/api/katalog/titck-guncelle', {}),
  /** İlaç (barkod) listesini dosyadan yükler. */
  katalogIlacYukle: (icerik: string) =>
    gonder<{ yazilan: number; atlanan: number }>('/api/katalog/ilac-yukle', { icerik }),

  // -------------------------------------------------------- bildirim ----
  /** Kuyruğa bildirim koyar (399); gönderimi arka plan işçisi yapar. */
  bildirimKuyruga: (govde: {
      sablonKodu?: string; kanal?: number; alici: string;
      degiskenler?: Record<string, string>; konu?: string; govde?: string;
      tarafId?: number; kaynakTur?: number; kaynakId?: number;
      oncelik?: number; planlanan?: string; hesapId?: number }) =>
    gonder<{ id: number | null; kuyruga: boolean }>('/api/bildirim', govde),
  /** Hatalı / iptal / vazgeçilmiş satırı yeniden kuyruğa alır. */
  bildirimTekrar: (id: number) =>
    gonder<{ tekrar: boolean }>(`/api/bildirim/${id}/tekrar`, {}),
  /** Gönderilmemiş satırı iptal eder. */
  bildirimIptal: (id: number) =>
    gonder<{ iptal: boolean }>(`/api/bildirim/${id}/iptal`, {}),
  /** Tek bildirimin deneme günlüğü. */
  bildirimLog: (id: number) =>
    istek<{ satirlar: Record<string, unknown>[] }>(`/api/bildirim/${id}/log`)
      .then(y => y.satirlar),

  // ------------------------------------------------- kullanici tercihi ----
  /** Kullanicinin KENDI arayuz tercihleri (397): menu favorileri gibi.
      Deger istemcinin yazdigi JSON metni - sunucu yorumlamaz, saklar. */
  tercihler: () =>
    istek<{ tercihler: Record<string, string> }>('/api/tercih').then(y => y.tercihler),
  tercihYaz: (anahtar: string, deger: string) =>
    gonder<{ izlemeNo?: string }>(`/api/tercih/${encodeURIComponent(anahtar)}`,
                                  { deger }, 'PUT'),

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
