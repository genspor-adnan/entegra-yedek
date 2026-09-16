import { gonder, istek } from '../cekirdek';

/**
 * ECZANE · BİYOMEDİKAL · SATINALMA İŞ AKIŞI UÇLARI (722-724, 729/730).
 *
 * ÜÇÜ TEK DOSYADA çünkü üçü de aynı zincirin halkaları: eczanenin kritik
 * stoğu satınalma talebi doğurur, biyomedikalin arızası da öyle; satınalmanın
 * mal kabulü ikisinin de stoğunu besler. Ayrı dosyalara bölseydik menüdeki
 * "Tedarik & Teknik" bölgesinin karşılığı kodda dağılırdı.
 *
 * KURAL SUNUCUDA. Sıra (hazırlanmadan kontrol yok), çift kontrol (kontrol
 * eden ≠ hazırlayan), üç iade ölçütü, onay basamağı, ağırlık kilidi ve teknik
 * eleme hep uçta uygulanır. İstemci hangi adımın geçerli olduğuna KARAR
 * VERMEZ - iki yerde karar verilseydi ekranın izin verip sunucunun reddettiği
 * durumlar çıkardı.
 *
 * ZORLAMA BAŞTAN GÖNDERİLMEZ. `zorla` bayrağını ancak sunucu reddettikten
 * ve kullanıcı gerekçe yazdıktan sonra gönderiyoruz; baştan göndermek kuralı
 * süse çevirirdi.
 *
 * ŞUBE GÖNDERİLMEZ: sunucu oturumun aktif şubesini kullanır.
 */

export type DozAdimi = 'hazirla' | 'kontrol' | 'teslim' | 'iade' | 'imha';
export type HazirlamaAdimi = 'hasta-geldi' | 'hazirla' | 'dogrula' | 'teslim' | 'iptal';
export type IsEmriAdimi =
  'ata' | 'mudahale' | 'parca-bekle' | 'dis-servis' | 'tamamla' | 'iptal';
export type OnayKarari = 'onayla' | 'reddet' | 'bilgi-iste' | 'sozlu-onay';

export interface AdimYaniti {
  adim: string;
  zaman: string;
  durum: number;
  uyarilar?: string[];
}

export interface DozHesapKalemi {
  id: number;
  ad: string;
  protokolDoz: string;
  hesaplanan: number | null;
  yontem?: string;
  birim?: string;
  not?: string;
}

/** Okutulan tek kod: yazildi · mukerrer · beklenmeyen · okunamadi. */
export interface KarekodSonucu {
  karekod: string;
  gtin?: string;
  seriNo?: string;
  partiNo?: string;
  sonKullanma?: string | null;
  ad?: string;
  sonuc: 'yazildi' | 'mukerrer' | 'beklenmeyen' | 'okunamadi';
  mesaj?: string;
  uyari?: string | null;
}

/** Tutanağın İTS bildirimi. durum: 0 taslak · 1 kuyrukta · 3 gönderildi · 5 iptal. */
export interface ItsBildirimSatiri {
  id: number;
  durum: number;
  testMi: number;
  karsiGln: string;
  itsBildirimNo: string;
  deneme: number;
  hataKodu: string;
  hataMesaj: string;
  aciklama: string;
  kutu: number;
  kalem: number;
  beklenmeyen: number;
}

/** Muayene satırı başına beklenen/okutulan kutu. */
export interface KarekodOzetSatiri {
  sira: number;
  ad: string;
  stokId: number | null;
  beklenen: number;
  okutulan: number;
  sktCeliskisi: number;
  miadiGecmis: number;
}

export interface TeklifSiraSatiri {
  firmaId: number;
  unvan: string;
  tutar: number;
  teslimGun: number | null;
  garantiAy: number | null;
  puanFiyat: number | null;
  puanToplam: number | null;
  durum: number;
  elemeNeden: string;
}

export const akisTedarikUclari = {
  // =========================================================== eczane ==
  /** Eczacı kararı. Yüksek düzey (geçilemez) uyarıyı "uygun" kapatmak `zorla` ister. */
  eczaneKontrolKarar: (id: number, g: {
    karar: number; oneri?: string; onlenenHata?: boolean; hekimId?: number;
    zorla?: boolean; gerekce?: string;
  }) => gonder<{ karar: number; kararZamani: string }>(
    `/api/eczane/kontrol/${id}/karar`, g),

  /** "Okundu" damgası yanıttan ayrı yazılır (yanıtsız kalan uyarı da sayılır). */
  eczaneHekimYanit: (id: number, yanit: string, karar?: number) =>
    gonder<{ okunduZamani: string }>(`/api/eczane/kontrol/${id}/hekim-yanit`,
      { yanit, karar }),

  /** Ünite doz adımı. Kontrol eden ≠ hazırlayan kuralı sunucuda. */
  eczaneDozAdim: (id: number, g: {
    adim: DozAdimi; personelId?: number; teslimAlanId?: number;
    zorla?: boolean; gerekce?: string;
  }) => gonder<AdimYaniti>(`/api/eczane/doz/${id}/adim`, g),

  /** Kemoterapi/TPN adımı. Hasta gelmeden hazırlama `zorla` ister. */
  eczaneHazirlamaAdim: (id: number, g: {
    adim: HazirlamaAdimi; personelId?: number; teslimAlanId?: number;
    kabinKod?: string; sonKullanim?: string; saklama?: string;
    zorla?: boolean; gerekce?: string;
  }) => gonder<AdimYaniti>(`/api/eczane/hazirlama/${id}/adim`, g),

  /**
   * Doz hesabı. Yalnız `hesaplanan` kolonunu yazar - uygulanacak dozu eczacı
   * girer (flakon yuvarlaması, doz azaltma onun kararı).
   */
  eczaneDozHesapla: (id: number, g: {
    boyCm?: number; kiloKg?: number; krkl?: number; azaltmaYuzde?: number;
  }) => gonder<{
    vyaM2: number; kalemler: DozHesapKalemi[]; not: string;
  }>(`/api/eczane/hazirlama/${id}/doz-hesapla`, g),

  /** İade kararı. Üç ölçütten biri "evet" ise stoğa kabul REDDEDİLİR (zorlama yok). */
  eczaneIadeKarar: (id: number, g: {
    karar: number; depoId?: number; imhaId?: number; aciklama?: string;
  }) => gonder<{ karar: number; girisBelgeId: number | null; uyarilar?: string[] }>(
    `/api/eczane/iade/${id}/karar`, g),

  eczaneImhaOnayla: (id: number, komisyon: string, aciklama?: string) =>
    gonder<{ durum: number }>(`/api/eczane/imha/${id}/onayla`, { komisyon, aciklama }),

  /** İmha = çıkış fişi (tür 4) + tutanak kapanışı + kontrollü ilaç defter satırı. */
  eczaneImhaEt: (id: number, g: { depoId?: number; atikTeslimNo?: string }) =>
    gonder<{ durum: number; belgeId: number; satir: number; defterSatiri: number }>(
      `/api/eczane/imha/${id}/imha-et`, g),

  /** Defter satırı YALNIZ EKLENİR; düzeltme ters satırla (`duzeltilenId`). */
  eczaneDefterYaz: (g: {
    hareket: number; stokId?: number; seriLotId?: number; ad?: string; miktar: number;
    receteRenk?: number; receteNo?: string; hastaId?: number; departmanId?: number;
    teslimEdenId?: number; teslimAlanId?: number; tanikId?: number; belgeId?: number;
    aciklama?: string; duzeltilenId?: number;
  }) => gonder<{ id: number }>('/api/eczane/defter', g),

  /** Fark varken kapatmak `farklaKapat` + gerekçe ister. */
  eczaneSayimKapat: (id: number, g: { aciklama?: string; farklaKapat?: boolean }) =>
    gonder<{ durum: number; uyumsuz: number }>(`/api/eczane/sayim/${id}/kapat`, g),

  // ====================================================== biyomedikal ==
  demirbasIsEmriAdim: (id: number, g: {
    adim: IsEmriAdimi; yapanId?: number; firmaId?: number; yedekDemirbasId?: number;
    yapilanIs?: string; kapsam?: string; maliyet?: number;
    zorla?: boolean; gerekce?: string;
  }) => gonder<AdimYaniti & { cihazDurum: number | null }>(
    `/api/demirbas/is-emri/${id}/adim`, g),

  /** Yalnız `kapsam = 0` (kurum ödüyor) parçalar düşülür. */
  demirbasParcaCikis: (id: number, g: { depoId?: number; satirIdler?: number[] }) =>
    gonder<{ belgeId: number; satir: number }>(`/api/demirbas/is-emri/${id}/parca-cikis`, g),

  /** Sonuç ölçümlerden türer; sınır dışı ölçüm varken "uygun" seçilemez. */
  demirbasKalibrasyonTamamla: (id: number, g: {
    sonuc?: number; gecerlilik?: string; yapanId?: number; firmaId?: number;
    geriyeDonukDeger?: string; zorla?: boolean; gerekce?: string;
  }) => gonder<{
    sonuc: number; gecerlilik: string | null; sinirDisi: number; uyarilar?: string[];
  }>(`/api/demirbas/kalibrasyon/${id}/tamamla`, g),

  demirbasHareket: (id: number, g: {
    hareket: number; yeniDepartmanId?: number; yeniZimmetId?: number;
    isEmriId?: number; aciklama?: string;
  }) => gonder<{ id: number; zaman: string }>(`/api/demirbas/${id}/hareket`, g),

  // ========================================================= satınalma ==
  /** Onay zincirini kurar (tutar + bütçe durumundan) ve talebi onaya alır. */
  satinalmaTalepGonder: (id: number, zinciriYenile = false) =>
    gonder<{
      durum: number; tutar: number; butceDurumu: number;
      basamaklar: { basamak: number; rol: number }[];
    }>(`/api/satinalma/talep/${id}/gonder`, { zinciriYenile }),

  /** Karar HEP bekleyen en küçük basamağa yazılır - basamak atlanamaz. */
  satinalmaTalepKarar: (id: number, g: {
    karar: OnayKarari; gerekce?: string; yaziliSaat?: number;
  }) => gonder<{
    karar: string; basamak: number; talepDurum: number; sonrakiBasamak: number | null;
  }>(`/api/satinalma/talep/${id}/karar`, g),

  satinalmaTalepBirlestir: (hedefId: number, kaynakIdler: number[]) =>
    gonder<{ hedefId: number; birlestirilen: number; tasinanSatir: number }>(
      '/api/satinalma/talep/birlestir', { hedefId, kaynakIdler }),

  /** Talebi tür 9 alış siparişine çevirir; satır bağı `belge_satir_id`de kalır. */
  satinalmaSiparise: (id: number, g: {
    tarafId: number; teklifId?: number; sozlesmeId?: number;
    sozTeslim?: string; depoId?: number; aciklama?: string;
  }) => gonder<{ belgeId: number; satir: number; baglanan: number; uyarilar?: string[] }>(
    `/api/satinalma/talep/${id}/siparise`, g),

  /** Davet ağırlıkları KİLİTLER (724 tetiği bundan sonra değişimi reddeder). */
  satinalmaTeklifDavet: (id: number, g: { firmaIdler?: number[]; sonTarih?: string }) =>
    gonder<{ firmaSayisi: number; agirlikKilit: number; uyarilar?: string[] }>(
      `/api/satinalma/teklif/${id}/davet`, g),

  /** Son tarihten önce açmak `zorla` + gerekçe ister. Puanlar burada hesaplanır. */
  satinalmaTeklifAc: (id: number, g: { zorla?: boolean; gerekce?: string }) =>
    gonder<{ elenen: number; puanlanan: number; siralama: TeklifSiraSatiri[] }>(
      `/api/satinalma/teklif/${id}/ac`, g),

  /** En düşük alınmıyorsa gerekçe ZORUNLU (denetimin ilk sorusu). */
  satinalmaTeklifKarar: (id: number, g: {
    kararFirmaId: number; gerekce?: string; kurul?: string;
  }) => gonder<{ kararFirmaId: number; enDusukAlindi: boolean }>(
    `/api/satinalma/teklif/${id}/karar`, g),

  satinalmaSiparisTakip: (id: number, g: {
    takipDurum?: number; sozTeslim?: string; ilkTeslim?: string; sonTeslim?: string;
    gecikmeBildir?: boolean; aciklama?: string;
  }) => gonder<{ gecikmeGun: number; olayYazildi: boolean }>(
    `/api/satinalma/siparis/${id}/takip`, g),

  /** Tutar boşsa sözleşmeden hesaplanır (binde/gün, üst sınır %). */
  satinalmaCeza: (id: number, g: { tutar?: number; aciklama?: string }) =>
    gonder<{ cezaTutar: number; gecikmeGun: number; ustSinir: number | null }>(
      `/api/satinalma/siparis/${id}/ceza`, g),

  /**
   * TUTANAK BEKLEYEN BELGELER. Tutanak bir belgeden doğar; kullanıcıya ham
   * `belge_id` yazdırmak yerine seçilebilir liste veriyoruz. Tutanağı olan
   * belge listede yoktur - bir belgenin tek tutanağı olur.
   */
  satinalmaKabulBekleyenBelgeler: (ara?: string) =>
    istek<{
      satirlar: {
        id: number; belgeNo: string; tur: number; belgeTarihi: string;
        tedarikci: string; satir: number; siparisBelgeId: number | null;
      }[];
    }>('/api/satinalma/kabul/bekleyen-belgeler'
       + (ara ? `?ara=${encodeURIComponent(ara)}` : '')),

  /**
   * Muayene tutanağı açar. Satırlar İRSALİYEDEN kopyalanır (733); sayılan
   * miktar irsaliyedekine eşit doğar - sıfır doğsaydı "henüz sayılmadı" ile
   * "sıfır sayıldı" aynı görünürdü.
   */
  satinalmaKabul: (g: {
    belgeId: number; siparisBelgeId?: number; sonuc?: number; komisyon?: string;
    uygunsuzluk?: string; tutanakNo?: string;
    kullaniciBirimId?: number; kullaniciBirimOnay?: boolean; satirDoldur?: boolean;
  }) => gonder<{ id: number; sonuc: number; satir: number }>('/api/satinalma/kabul', g),

  /**
   * Toplu kabul. `uyarilar` KAREKOD EKSİĞİNİ söyler (737): "sayılan = irsaliye
   * miktarı" demek kutuları saydığını iddia etmektir; okutulmamış kutu varsa
   * bu iddia dayanaksızdır. Engel değil, uyarıdır.
   */
  satinalmaKabulTumunu: (id: number, sayilaniEsitle = true) =>
    gonder<{ kabulEdilen: number; uyarilar?: string[] }>(
      `/api/satinalma/kabul/${id}/tumunu-kabul`, { sayilaniEsitle }),

  /**
   * Karekod okutma (734). HER KOD KENDİ SONUCUYLA döner - biri okunamadı diye
   * önceki okutmalar silinmez (iki yüz kutu tek tek okutulur).
   */
  satinalmaKabulKarekod: (id: number, karekodlar: string[], karsiGln?: string) =>
    gonder<{
      bildirimId: number; yazildi: number; mukerrer: number;
      beklenmeyen: number; okunamadi: number;
      sonuclar: KarekodSonucu[]; ozet: KarekodOzetSatiri[];
    }>(`/api/satinalma/kabul/${id}/karekod`, { karekodlar, karsiGln }),

  satinalmaKabulKarekodOzet: (id: number) =>
    istek<{ ozet: KarekodOzetSatiri[]; kutular: Record<string, unknown>[] }>(
      `/api/satinalma/kabul/${id}/karekod`),

  /** Yalnız BİLDİRİLMEMİŞ kutu silinebilir (gönderilmişte deaktivasyon gerekir). */
  satinalmaKabulKarekodSil: (id: number, satirId: number, gerekce?: string) =>
    gonder<{ silindi: boolean }>(`/api/satinalma/kabul/${id}/karekod-sil`,
      { satirId, gerekce }),

  /**
   * İTS bildirimini KUYRUĞA ALIR (736). Reddedilen ve beklenmeyen kalemlerin
   * kutuları bildirime girmez - ayrı bir iptal kaydına taşınır, okutuldukları
   * kayıtta kalır.
   */
  satinalmaKabulItsGonder: (id: number, g: { karsiGln?: string; simdiGonder?: boolean }) =>
    gonder<{
      bildirimId: number; kuyrukta: number; ayrilan: number;
      ayrikBildirim: number | null;
      /** Bu tutanağa ait olmayıp ayrı taslağa çıkarılan kutular. */
      yabanci: number; yabanciBildirim: number | null;
      gonderim: string; uyarilar?: string[];
    }>(`/api/satinalma/kabul/${id}/its-gonder`, g),

  satinalmaKabulItsDurum: (id: number) =>
    istek<{
      bildirimler: ItsBildirimSatiri[];
      kalemler: { bildirimId: number; ad: string; lot: string; skt: string | null;
                  adet: number; beklenmeyen: number }[];
      hesapVar: boolean; testMi: boolean;
    }>(`/api/satinalma/kabul/${id}/its`),

  /** Gönderilmiş bildirim iptal edilemez - iade/deaktivasyon ayrı işlemdir. */
  satinalmaKabulItsIptal: (id: number, bildirimId: number, gerekce: string) =>
    gonder<{ iptal: boolean }>(`/api/satinalma/kabul/${id}/its-iptal`,
      { bildirimId, gerekce }),

  /** Komisyon kararı. Muayenesi bitmemiş tutanak karara bağlanmaz. */
  satinalmaKabulKarar: (id: number, g: {
    sonuc: number; komisyon?: string; uygunsuzluk?: string;
    kullaniciBirimOnay?: boolean; kullaniciBirimId?: number;
    sogukZincirUygun?: number; sicaklik?: number; tasimaKosulu?: string;
  }) => gonder<{ sonuc: number; retKalem: number; uyarilar?: string[] }>(
    `/api/satinalma/kabul/${id}/karar`, g),

  /** Üçlü eşleştirme: sipariş - teslim - fatura. Taban TESLİMDİR. */
  satinalmaFaturaEslestir: (faturaBelgeId: number, siparisBelgeId?: number) =>
    gonder<{
      id: number; sonuc: number; siparisTutar: number; teslimTutar: number;
      faturaTutar: number; farkTutar: number; farkMetni: string;
    }>('/api/satinalma/fatura-eslestir', { faturaBelgeId, siparisBelgeId }),

  satinalmaOdemeKarar: (id: number, g: {
    karar: number; metin?: string; mahsupTutar?: number;
  }) => gonder<{ odemeDurum: number }>(`/api/satinalma/fatura/${id}/odeme`, g),
};
