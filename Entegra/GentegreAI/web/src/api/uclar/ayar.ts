import type { CalismaPlaniYaniti } from '../sozlesme';
import type { AcikOturum, GirisDenemesi } from './kimlik';
import {
  type AyarSatiri, type YardimKaydi,
  type RandevuBolumDugumu, type RandevuAyarYazma,
  } from '../sozlesme';
import { istek, gonder } from '../cekirdek';
import type {
  UtsSorguYaniti, UtsBildirimYaniti, UtsBelgeBildirimYaniti, UtsHazirlaYaniti,
} from '../tipler';

/** Randevu bolumleri, ayarlar, zamanli isler, katalog, bildirim, tercih, ÜTS. */
export const ayarUclari = {
  // ------------------------------------------------ randevu bolumleri ----
  // Randevu Ayarlari > Bolumler (251): randevu verilen bolumler, hekimleri ve
  //   her ikisinin randevu duzeni; sol agac + sag form ayni yanittan beslenir.
  randevuBolumleri: () => istek<RandevuBolumDugumu[]>('/api/randevu/bolumler'),
  randevuBolumAyarYaz: (istek_: RandevuAyarYazma) =>
    gonder<{ tamam: boolean }>('/api/randevu/bolum-ayar', istek_, 'PUT'),
  /** Hekim çalışma planı (711): türetilmiş bloklar ve bugün çalışanlar. */
  calismaPlani: (g: { bas?: string; bit?: string; hekimId?: number | null; departmanId?: number | null; sube?: number | null } = {}) =>
    istek<CalismaPlaniYaniti>('/api/calisma-plani?' + Object.entries(g).filter(([, v]) => v !== undefined && v !== null && v !== '').map(([k, v]) => `${k}=${encodeURIComponent(String(v))}`).join('&')),
  calismaBugun: (gun?: string, sube?: number | null) =>
    istek<{ gun: string; subeId: number; satirlar: { departmanId: number; departman: string; hekimId: number; hekim: string; saatler: string; kaynak: number; kanallar: string; randevu: number; gelen: number; simdi: boolean }[]; randevusuz: { id: number; ad: string }[] }>(
      `/api/calisma-plani/bugun?${gun ? `gun=${gun}&` : ''}${sube ? `sube=${sube}` : ''}`),
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

  // ------------------------------------------- kullanici yonetimi (Guvenlik) ----
  // Yonetici PAROLA YAZMAZ: sifirlama hesabi parolasiz duruma alir, kisi ilk
  //   giriste kendi parolasini koyar.
  kullaniciParolaSifirla: (id: number, kilitCoz = true) =>
    gonder<{ mesaj: string }>(
      `/api/kullanici/${id}/parola-sifirla?kilitCoz=${kilitCoz}`, {}),
  kullaniciKilitCoz: (id: number) =>
    gonder<{ mesaj: string }>(`/api/kullanici/${id}/kilit-coz`, {}),
  kullaniciOturumKapat: (id: number) =>
    gonder<{ mesaj: string }>(`/api/kullanici/${id}/oturum-kapat`, {}),
  kullaniciDurum: (id: number, aktif: boolean) =>
    gonder<{ mesaj: string }>(`/api/kullanici/${id}/durum?aktif=${aktif}`, {}),
  /** Yoneticinin gordugu: BASKASININ acik oturumlari / giris gecmisi. */
  kullaniciOturumlari: (id: number) =>
    istek<AcikOturum[]>(`/api/kullanici/${id}/oturumlar`),
  kullaniciGirisGecmisi: (id: number) =>
    istek<GirisDenemesi[]>(`/api/kullanici/${id}/giris-gecmisi`),
  kullaniciTopluAc: () =>
    gonder<{ acilan: number; mesaj: string }>('/api/kullanici/toplu-ac', {}),
  /** Gridin ustundeki sayac kutulari - hepsi TEK sorgudan gelir. */
  kullaniciOzet: () => istek<KullaniciOzeti>('/api/kullanici/ozet'),
  /** "Bu HESABA ne yapildi" - parola sifirlandi mi, kim pasife aldi. */
  kullaniciIslemGunlugu: (id: number) =>
    istek<KullaniciLogSatiri[]>(`/api/kullanici/${id}/islem-gunlugu`),

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

  // BAGLI LISTE (544): `ust` verilirse yalniz o ust degerin satirlari -
  //   "bu markanin modelleri". Bagsiz listelerde parametre gonderilmez.
  kodListe: (kod: string, ust?: number) =>
    istek<{ kod: string; degerler: {
      deger: number; ad: string; sira: number; aktif: number; ustDeger: number }[] }>(
      `/api/kod-liste/${encodeURIComponent(kod)}`
      + (ust === undefined ? '' : `?ust=${ust}`)),
  kodListeEkle: (kod: string, ad: string, sira?: number, ustDeger?: number) =>
    gonder<{ deger: number }>(`/api/kod-liste/${encodeURIComponent(kod)}`,
                              { ad, sira, ustDeger }),
  kodListeGuncelle: (kod: string, deger: number, govde: { ad: string; sira?: number; aktif?: number }) =>
    gonder<object>(`/api/kod-liste/${encodeURIComponent(kod)}/${deger}`, govde, 'PUT'),
  kodListeSil: (kod: string, deger: number) =>
    gonder<object>(`/api/kod-liste/${encodeURIComponent(kod)}/${deger}`, undefined, 'DELETE'),

};

/** `GET /api/kullanici/ozet` - Kullanicilar ekraninin ust seridi. */
export interface KullaniciOzeti {
  toplam: number;
  aktif: number;
  pasif: number;
  /** Parolasi hic konmamis YA DA varsayilan bayragi acik hesaplar. */
  parolasiz: number;
  kilitli: number;
  /** 90 gundur girmemis (hic girmemis dahil) AKTIF hesaplar. */
  uykuda: number;
  /** Aktif personel sayisi - `hesapsiz` bunun altkumesi. */
  personel: number;
  hesapsiz: number;
  /** Acik oturum AILE basina sayilir (rotation cogaltmasin). */
  oturum: number;
  oturumKisi: number;
}

/** `GET /api/kullanici/{id}/islem-gunlugu` - hesaba yapilan islemler. */
export interface KullaniciLogSatiri {
  tarih: string;
  /** islem_log.islem_tipi ham kodu (1 ekle / 2 degistir / 3 sil). */
  islemTipi: number;
  /** Islemi YAPAN kisi - hesabin sahibi degil. */
  kullanici: string;
  ip: string;
  /** Yonetim uclarinin bilgi JSON'una yazdigi serbest aciklama. */
  islem: string;
}
