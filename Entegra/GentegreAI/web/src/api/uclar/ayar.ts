import type { CalismaPlaniYaniti } from '../sozlesme';
import type { AcikOturum, GirisDenemesi } from './kimlik';
import {
  type AyarSatiri, type YardimKaydi,
  type RandevuBolumDugumu,
  } from '../sozlesme';
import { istek, gonder } from '../cekirdek';
import type {
  UtsSorguYaniti, UtsBildirimYaniti, UtsBelgeBildirimYaniti, UtsHazirlaYaniti,
} from '../tipler';

export interface CalismaSablonTaslak {
  id: number | null; hekimId: number; departmanId: number | null; gunler: string;
  bas1: string; bit1: string; bas2: string | null; bit2: string | null;
  slotDk: number; tekrar: number; gecerliBas: string; gecerliBit: string | null;
}
export interface CalismaSablonEtki {
  randevu14: number; kapasite14: number; doluluk: number;
  disarida: { id: number; baslangic: string; sureDk: number; hasta: string }[];
  cakisan: { id: number; ad: string; departman: string; saat: string }[];
  digerleri: { id: number; ad: string; departman: string; gunler: string; aktif: boolean; gecerliBit: string | null }[];
  kayit: { ekleyen: string; eklemeTarihi: string; degistiren: string; degistirmeTarihi: string | null } | null;
}
export interface CalismaIstisnaBaglam {
  haftaBas: string;
  hafta: { gun: string; saatBas: string | null; saatBit: string | null; kaynak: number; istisnaTur: number | null; istisnaId: number | null; departman: string; aciklama: string; sablon: string }[];
  randevular: { id: number; baslangic: string; sureDk: number; hastaId: number; hasta: string; tip: string; telefonVar: boolean }[];
  yakin: { id: number; bas: string; bit: string; tur: string; onayli: boolean; kaynak: 'istisna' | 'ik'; aciklama: string }[];
  doktorlar: { id: number; ad: string; ayniBolum: boolean }[];
  kayit: { ekleyen: string; eklemeTarihi: string; onaylayan: string; onayTarihi: string | null } | null;
}

export interface CalismaBugunSatiri {
  departmanId: number; departman: string; hekimId: number; hekim: string;
  durum: 'muayenede' | 'saat-disi' | 'bitti' | 'yok'; neden?: string | null; ik: boolean;
  bloklar: { bas: string; bit: string; istisna: boolean }[]; kanallar: string;
  randevu: number; gelen: number; slot: number; siradakiBos?: string | null;
}
export interface CalismaBugun {
  gun: string; subeId: number; simdi?: string | null; satirlar: CalismaBugunSatiri[]; randevusuz: { id: number; ad: string }[];
}

const sorguMetni = (g: Record<string, unknown>) => Object.entries(g)
  .filter(([, v]) => v !== undefined && v !== null && v !== '')
  .map(([k, v]) => `${k}=${encodeURIComponent(String(v))}`).join('&');

export interface CalismaSablonSatiri {
  id: number; hekimId: number; hekim: string; departmanId: number; departman: string; subeId?: number | null; sube: string; ad: string;
  gunler: string; bas1: string; bit1: string; bas2?: string | null; bit2?: string | null; slotDk: number; kanallar: string; tekrar: number;
  gecerliBas: string; gecerliBit?: string | null; aktif: boolean; biten: boolean; doluluk?: number | null; cakisma: boolean;
}
export interface CalismaSablonListe {
  satirlar: CalismaSablonSatiri[];
  sayac: { aktif: number; pasif: number; biten: number; tumu: number };
  ozet: {
    aktifSablon: number; doktor: number; bolum: number; haftalikSlot: number; doluluk: number;
    sablonsuz: { id: number; ad: string; departman: string; departmanId: number }[];
    bitecek: { id: number; ad: string; hekim: string; gecerliBit: string }[];
  };
}
export interface CalismaIstisnaSatiri {
  kaynak: 'istisna' | 'ik'; id: number; tur: number; hekimId: number; hekim: string; departman: string; bolumSecili: boolean;
  bas: string; bit: string; saatBas?: string | null; saatBit?: string | null; kanallar: string; durum: number; aciklama: string;
  ikTur: string; izinNo: string; giren: string; eklemeTarihi: string; onaylayan: string; onayTarihi?: string | null;
  bekleyen: number; ekDolu: number; slotDk: number;
}
export interface CalismaIstisnaListe {
  satirlar: CalismaIstisnaSatiri[];
  sayac: { bekliyor: number; onayli: number; iptal: number; tumu: number };
  ozet: { onayBekleyen: number; enEskiGun: number; islemBekleyenRandevu: number; bugunYok: string[]; otuzGun: number; otuzGunTur: Record<string, number> };
}

/** Randevu bolumleri, ayarlar, zamanli isler, katalog, bildirim, tercih, ÜTS. */
export const ayarUclari = {
  // ------------------------------------------------ randevu bolumleri ----
  // Randevu Ayarlari > Bolumler (251): randevu verilen bolumler, hekimleri ve
  //   her ikisinin randevu duzeni; sol agac + sag form ayni yanittan beslenir.
  randevuBolumleri: () => istek<RandevuBolumDugumu[]>('/api/randevu/bolumler'),
  /** Hekim çalışma planı (711): türetilmiş bloklar ve bugün çalışanlar. */
  calismaPlani: (g: { bas?: string; bit?: string; hekimId?: number | null; departmanId?: number | null; sube?: number | null; ozet?: number } = {}) =>
    istek<CalismaPlaniYaniti>('/api/calisma-plani?' + Object.entries(g).filter(([, v]) => v !== undefined && v !== null && v !== '').map(([k, v]) => `${k}=${encodeURIComponent(String(v))}`).join('&')),
  calismaBugun: (gun?: string, sube?: number | null) =>
    istek<CalismaBugun>(`/api/calisma-plani/bugun?${gun ? `gun=${gun}&` : ''}${sube ? `sube=${sube}` : ''}`),
  /** Seçili hücre: doktorun o günkü randevuları (şube saatinde). */
  calismaGun: (hekimId: number, gun: string) =>
    istek<{ randevular: { id: number; saat: string; sureDk: number; durum: number; hasta: string; tip: string }[] }>(`/api/calisma-plani/gun?hekimId=${hekimId}&gun=${gun}`),
  // Çalışma şablonu / izin & istisna kartları (945): kaydetmeden önceki hesaplar.
  calismaSablonVarsayilan: () =>
    istek<{ gunler: string; bas1: string; bit1: string; bas2: string | null; bit2: string | null; slotDk: number }>('/api/calisma-plani/sablon-varsayilan'),
  calismaSablonEtki: (s: CalismaSablonTaslak) => gonder<CalismaSablonEtki>('/api/calisma-plani/sablon-etki', s),
  calismaIstisnaBaglam: (g: { hekimId: number; bas: string; bit: string; tur?: number; saatBas?: string; saatBit?: string; departmanId?: number | null; id?: number | null }) =>
    istek<CalismaIstisnaBaglam>('/api/calisma-plani/istisna-baglam?' + Object.entries(g).filter(([, v]) => v !== undefined && v !== null && v !== '').map(([k, v]) => `${k}=${encodeURIComponent(String(v))}`).join('&')),
  calismaIstisnaRandevu: (islem: 'iptal' | 'aktar' | 'kaydir' | 'sms', randevuIdleri: number[], hedefHekimId?: number, mesaj?: string) =>
    gonder<{ sonuc: { id: number; basarili: boolean; mesaj: string }[] }>('/api/calisma-plani/istisna-randevu', { islem, randevuIdleri, hedefHekimId, mesaj }),
  // Çalışma şablonları / izin & istisnalar LİSTELERİ.
  calismaSablonListe: (g: { durum?: string; departmanId?: number | ''; subeId?: number | ''; ara?: string }) =>
    istek<CalismaSablonListe>('/api/calisma-plani/sablon-liste?' + sorguMetni(g)),
  calismaSablonToplu: (islem: 'pasif' | 'bitis' | 'kopyala', idler: number[], ek: { bitis?: string; hedefHekimId?: number } = {}) =>
    gonder<{ sonuc: { id: number; basarili: boolean; mesaj: string }[] }>('/api/calisma-plani/sablon-toplu', { islem, idler, ...ek }),
  calismaIstisnaListe: (g: { durum?: string; tur?: string; bas?: string; bit?: string; departmanId?: number | ''; ara?: string }) =>
    istek<CalismaIstisnaListe>('/api/calisma-plani/istisna-liste?' + sorguMetni(g)),
  calismaIstisnaToplu: (islem: 'onayla' | 'iptal', idler: number[]) =>
    gonder<{ sonuc: { id: number; basarili: boolean; mesaj: string }[] }>('/api/calisma-plani/istisna-toplu', { islem, idler }),
  /** Bolumu randevuya ac / kapat. hekimIdleri: isaretli doktorlar (bos = sablonu olmayan herkes). */
  randevuBolumIsaretle: (departmanId: number, bolumMu: boolean, hekimIdleri?: number[]) =>
    gonder<{ tamam: boolean; eklenen: number }>('/api/randevu/bolum', { departmanId, bolumMu, hekimIdleri }, 'PUT'),
  /** Bolumun doktorlari + o bolumde aktif calisma sablonu var mi. */
  randevuBolumDoktorlari: (departmanId: number) =>
    istek<{ doktorlar: { id: number; ad: string; sablonVar: boolean }[] }>(`/api/randevu/bolum/${departmanId}/doktorlar`),

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
  /**
   * BILDIRIM KANALI SINAMASI (820): SMS / e-posta hesabina GERCEK test
   * mesaji gonderir - "Baglantiyi Sina" yalnizca adrese bakiyor, kanalda
   * hicbir sey soylemez. Dısarıya mesaj gider (SMS ucretlidir).
   */
  bildirimSina: (hesapId: number, alici: string, mesaj?: string) =>
    gonder<{ basarili: boolean; mesaj: string; saglayiciRef: string;
             hamYanit: string; httpDurum: number }>(
      `/api/entegrasyon/${hesapId}/test-bildirim`, { alici, mesaj }),

  kullaniciTopluAc: () =>
    gonder<{ acilan: number; mesaj: string }>('/api/kullanici/toplu-ac', {}),

  /**
   * PORTAL HESABI (819): dis hekim / kurum / hasta. Hesap PAROLASIZ acilir -
   * kisi ilk giriste kendi parolasini koyar. Kurum portalinda hesap KISIYE
   * acilir, kapsam `kurumId` ile kuruma baglanir.
   */
  portalHesapDurum: (tarafId: number) =>
    istek<{
      id: number; unvan: string; vkno: string; kisi: number; musteri: number;
      hasta: number; disHekim: number; mevcutKod: string | null;
      mevcutPortal: number; mevcutRol: string; kapsamTarafId: number | null;
      hesapAktif: number;
      /** Kisi kartindaki "Bagli Kurum" (309) - kurum portalinda varsayilan kapsam. */
      bagliKurumId: number | null; bagliKurumAdi: string;
      /**
       * Acilabilir portal rolleri (824). Kurum portalinda IKI rol var
       * (Klinik / Yonetici) ve ayri seyler gorurler - hangisinin acilacagi
       * SORULUR, sunucu tahmin etmez.
       */
      roller: { kod: string; ad: string; portalTuru: number; amac: string }[];
    }>(`/api/kullanici/portal-durum/${tarafId}`),

  /**
   * PORTAL DAVETI (822): hastaya SMS/e-posta ile tek kullanimlik baglanti.
   * Jeton YANITTA DONMEZ - baglanti yalniz kisiye gider.
   */
  portalDavetGonder: (govde: { tarafId: number; kanal: number; alici?: string }) =>
    gonder<{ davetId: number; kanal: number; alici: string; gecerlilikSaat: number;
             mesaj: string }>('/api/kullanici/portal-davet', govde),

  /**
   * TOPLU PORTAL ROLU (819): hesabi olan dis hekimlere/hastalara portal
   * rolunu atar. Yetkili bir IC rolu tasiyan hesap ATLANIR - rolunu ezmek
   * o kisinin butun yetkilerini sessizce kaldirirdi.
   */
  portalTopluRol: (portalTuru: number) =>
    gonder<{ atanan: number; atlanan: { id: number; unvan: string; rol: string;
                                        sebep: string }[]; mesaj: string }>(
      `/api/kullanici/portal-toplu-rol?portalTuru=${portalTuru}`, {}),

  portalHesapAc: (govde: {
    tarafId: number; portalTuru: number; kod?: string; kurumId?: number;
    /** Portal turunde birden cok rol varsa ZORUNLU (824). */
    rolKodu?: string;
    eposta?: string; cepTel?: string;
  }) =>
    gonder<{ tarafId: number; kod: string; portalTuru: number;
             kapsamTarafId: number | null; parolasiz: boolean; mesaj: string }>(
      '/api/kullanici/portal-hesap', govde),
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
