import {
  type ListeIstegi, type ListeYaniti, } from '../sozlesme';
import { istek, gonder, dosyaYukle } from '../cekirdek';

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

};
