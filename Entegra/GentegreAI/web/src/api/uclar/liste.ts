import {
  type ListeIstegi, type ListeYaniti, } from '../sozlesme';
import { istek, gonder, dosyaYukle } from '../cekirdek';

/** YZ tanı önerisi yanıtı: öneri hekime; kod ICD kataloğunda doğrulanmış. */
export interface YzTaniOnerisiYaniti {
  oneriler: { kod: string; ad: string; olasilik: 'yuksek' | 'orta' | 'dusuk'; gerekce: string }[];
  kirmiziBayrak: string; eksikBilgi: string; atilanKod: number; model: string; uyari: string;
}

/** Muayenede uygulanabilecek şablon (933). oncelik 0 doktorun, 1 bölüm ortak, 2 diğer. */
export interface MuayeneSablonSecenek {
  id: number; ad: string; tur: number; varsayilan: boolean; oncelik: number;
  doktor: string; alanSayisi: number;
}

/** Muayene şablonu hekim tercihleri (931) - muayeneye uygulanan şablonlardan. */
export interface SablonTercihleri {
  tanilar: { kod: string; ad: string }[];
  receteler: { sablon: string; grup: string; satirlar: {
    barkod: string; ilac: string; doz: string; periyot: string; kullanimSekli: number;
    sureGun: number; kutu: number; aciklama: string; icdKod: string }[] }[];
  paneller: { id: number; kod: string; ad: string }[];
  /** kaynak 's' şablon makrosu, 'k' kurum makrosu (metin_makro); id kullanım sayacı için. */
  makrolar: { kisayol: string; alan: string; metin: string; kaynak?: 's' | 'k'; id?: number;
              kullanim?: number }[];
}

/** Liste kaynaklari ve kolon metasi. */
export const listeUclari = {
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
  /** YZ tanı önerisi: bağlam sunucuda toplanır ve anonimleştirilir; kodlar katalogla doğrulanır. */
  muayeneYzTaniOnerisi: (muayeneId: number) =>
    gonder<YzTaniOnerisiYaniti>(`/api/muayene/${muayeneId}/yz-tani-onerisi`, {}),
  /** YZ tetkik önerisi: lab kodu katalog listesinden, görüntüleme radyoloji hizmetinden. */
  muayeneYzTetkikOnerisi: (muayeneId: number) =>
    gonder<{ oneriler: { tur: 'tetkik' | 'panel' | 'radyoloji'; id: number; kod: string; ad: string; gerekce: string }[];
             not: string; atilan: number; model: string; uyari: string }>(
      `/api/muayene/${muayeneId}/yz-tetkik-onerisi`, {}),
  /** YZ ilaç önerisi: etken madde -> katalog ürünleri; alerjiyle çakışan elenir; doz yok. */
  muayeneYzIlacOnerisi: (muayeneId: number) =>
    gonder<{ oneriler: { barkod: string; ad: string; etken: string; gerekce: string }[];
             notlar: string[]; model: string; uyari: string }>(
      `/api/muayene/${muayeneId}/yz-ilac-onerisi`, {}),
  muayeneTaniOnerileri: (muayeneId: number) =>
    istek<{
      onceki: { kod: string; ad: string; kronik: number; son: string }[];
      sik: { kod: string; ad: string; adet: number }[];
    }>(`/api/muayene/${muayeneId}/tani-onerileri`),

  /** Listeden secilen ICD kodunu tani satiri olarak ekler. Tur verilmezse ilk
      tani ANA, sonrakiler EK; ANA secilip ana tani varsa sunucu EK yazar. */
  muayeneTaniEkle: (muayeneId: number, icdKod: string,
                    secim: { tur?: number | null; taraf?: number | null;
                             kesinlik?: number | null } = {}) =>
    gonder<{ eklendi: boolean; mesaj: string; tur?: number }>(
      `/api/muayene/${muayeneId}/tani/${encodeURIComponent(icdKod)}`, secim),

  /** ICD arama penceresindeki TÜR (Kesin / Ön tanı = kesinlik) ve TARAF secenekleri. */
  muayeneTaniSecenekleri: () =>
    istek<{ kesinlikler: { kod: number; ad: string }[]; taraflar: { kod: number; ad: string }[] }>(
      '/api/muayene/tani-secenekleri'),

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

  // ------------------------------------------------ muayene sablonlari (927) ----
  /** Sablonu kullaniciya (doktora ozel) kopyalar, alanlariyla. */
  sablonKopyala: (id: number) =>
    gonder<{ id: number; kod: string; mesaj: string }>(`/api/muayene-sablon/${id}/kopyala`, {}),
  /** Bolum varsayilani yapar (bolumde tek; eskisi kalkar). */
  sablonVarsayilan: (id: number) =>
    gonder<{ mesaj: string }>(`/api/muayene-sablon/${id}/varsayilan`, {}),
  /** Son 30 gun kullanim: toplam, doktora gore, son muayeneler. */
  sablonKullanim: (id: number) =>
    istek<{ toplam30: number; doktorSayisi: number;
            doktorlar: { ad: string; adet: number }[];
            son: { muayeneId: number; tarih: string; hasta: string; doktor: string }[] }>(
      `/api/muayene-sablon/${id}/kullanim`),
  /** Sablon ve alanlarinin degisiklik kaydi (islem_log). */
  sablonGecmis: (id: number) =>
    istek<{ satirlar: { tarih: string; kullanici: string; islemTipi: number; alan: boolean;
                        bolum?: string; bilgi: string }[] }>(
      `/api/muayene-sablon/${id}/gecmis`),
  /** Muayeneye uygulanan şablonların hekim tercihleri (931): sık tanı, reçete şablonu, panel, makro. */
  /** Muayenede uygulanabilecek şablonlar öncelik sırasıyla (933): 0 doktorun,
      1 bölüm ortak, 2 diğer; `onerilen` doktorunki yoksa bölüm varsayılanı. */
  muayeneSablonlari: (muayeneId: number) =>
    istek<{ sablonlar: MuayeneSablonSecenek[]; onerilen: MuayeneSablonSecenek | null }>(
      `/api/muayene-sablon/muayene/${muayeneId}/sablonlar`),
  /** Muayenede alana yazılan makronun kullanım sayısını artırır (932). */
  makroKullanim: (kaynak: 's' | 'k', id: number) =>
    gonder<{ izlemeNo: string }>('/api/muayene-sablon/makro-kullanim', { kaynak, id }),
  muayeneSablonTercihleri: (muayeneId: number) =>
    istek<SablonTercihleri>(`/api/muayene-sablon/muayene/${muayeneId}/tercihler`),

  /** Taslak recetede ilac satirini duzeltir (doz/periyot/kullanim/sure/kutu/tarif). */
  receteSatirGuncelle: (receteId: number, satirId: number, g: {
    doz?: string; periyot?: string; kullanimSekli?: number; sureGun?: number;
    kutu?: number; aciklama?: string;
  }) => gonder<{ mesaj: string }>(`/api/recete/${receteId}/ilac/${satirId}`, g, 'PUT'),

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

  /** Yeni rapor: modal ön bilgilerle açılır, tarih/gün/açıklama/ICD ile kaydedilir. */
  muayeneRaporEkle: (muayeneId: number, govde: { tur: number; altTur?: number;
                     baslangic?: string; gun?: number; bitis?: string;
                     aciklama?: string; icdKod?: string }) =>
    gonder<{ raporId: number; mesaj: string }>(`/api/muayene/${muayeneId}/rapor`, govde),

  /** Taslak rapor sil (imzalı silinmez). */
  muayeneRaporSil: (raporId: number) =>
    istek<{ mesaj: string }>(`/api/muayene/rapor/${raporId}`, { method: 'DELETE' }),

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

};
