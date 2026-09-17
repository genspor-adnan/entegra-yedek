import { gonder, istek } from '../cekirdek';

/**
 * İZİN UÇLARI (743).
 *
 * GÜN SAYISINI SUNUCU HESAPLAR: başlangıç ve bitişten. İstemci de
 * hesaplasaydı ekranın gösterdiği ile bakiyeden düşen farklı olabilir ve
 * fark kimsenin dikkatini çekmeden bakiyeyi eritirdi.
 *
 * BAKİYE AŞIMI ENGEL DEĞİL: hakkı olmayan personele izin vermek ücretsiz
 * ya da avans izindir - ayrı bir karardır ve zincire bir basamak ekler.
 */

/** 768: belge talebi icin uretilmis (ya da dondurulmus) yazi. */
export interface BelgeYazisi {
  /** true = metin bu talep icin DONDURULMUS; sablon degisse de degismez. */
  donmus: boolean;
  baslik: string;
  govde: string;
  altNot: string;
  imzaUnvan: string;
  sablonId: number;
  sablonAd: string;
  /** Sablonda gecen ama degeri BOS yer tutucular - bunlar varken hazirlanamaz. */
  eksik: string[];
  adet: number;
  talepNo: string;
  personelAd: string;
  durum: number;
  antet: {
    unvan: string; adres: string; il: string; ilce: string;
    telefon: string; vkno: string; vd: string;
  };
}

export interface IzinBakiyesi {
  tarafId: number;
  personelAd: string;
  yil: number;
  /** null = işe giriş tarihi yok, kanunî hak hesaplanamıyor. */
  hakGun: number | null;
  devirGun: number;
  ekGun: number;
  kullanilanGun: number;
  /** Onaylı ama henüz başlamamış izin - bakiyeden düşer, "kullanıldı" değil. */
  planlananGun: number;
  onaydaGun: number;
  kalan: number;
  not: string | null;
}

export const izinUclari = {
  izinBakiye: (tarafId: number, yil?: number) =>
    istek<IzinBakiyesi>(`/api/ik/personel/${tarafId}/izin-bakiye`
      + (yil ? `?yil=${yil}` : '')),

  /** Talep açar (taslak). Gün sayısı sunucuda hesaplanır. */
  izinAc: (g: {
    tarafId: number; tur: number; baslangic: string; bitis: string;
    isGunu?: boolean; aciklama?: string; belgeNo?: string; yerineId?: number;
  }) => gonder<{
    id: number; gun: number; durum: number;
    bakiye: IzinBakiyesi; uyarilar: string[];
  }>('/api/ik/izin', g),

  /* Not: onaya gönderme yanıtındaki `randevu`, izin tarihlerindeki AÇIK
     randevu sayısıdır - izin onaylanınca takvim kapanır ama o randevular
     kendiliğinden taşınmaz. */

  /** Onay zincirini kurar. Âmiri tanımlı olmayan personelde reddedilir. */
  izinGonder: (id: number) =>
    gonder<{
      durum: number; gun: number; bayraklar: string[]; randevu: number;
      basamaklar: { sira: number; ad: string; rol: number }[];
      bakiye: IzinBakiyesi;
    }>(`/api/ik/izin/${id}/gonder`, {}),

  /**
   * Bir yılın MİLLÎ tatillerini üretir (749). Dinî bayramlar DÂHİL DEĞİL:
   * hicrî takvime bağlıdırlar ve algoritmayla üretilmezler - bir gün kayan
   * hesap izin gününü ve bordroyu yanlış hesaplar.
   */
  resmiTatilUret: (yil: number) =>
    gonder<{ yil: number; eklenen: number; dini: number; uyarilar: string[] }>(
      `/api/ik/tatil/uret/${yil}`, {}),

  // ======================================================= AVANS (753) ==
  // BORDRO YOK: mahsup kendi kesinti planında izlenir. Ödeme kasa
  // işlemidir - avansta yalnız bağ durur.
  avansAc: (g: {
    tarafId: number; tutar: number; taksitSayisi?: number;
    ilkDonem?: string; gerekce?: string;
  }) => gonder<{
    id: number; tutar: number; taksit: number; ilkDonem: string;
    durum: number; uyarilar: string[];
  }>('/api/ik/avans', g),

  avansGonder: (id: number) =>
    gonder<{
      durum: number; tutar: number; bayraklar: string[];
      basamaklar: { sira: number; ad: string; rol: number }[];
    }>(`/api/ik/avans/${id}/gonder`, {}),

  /** Yalnız ONAYLANMIŞ avans ödenir; kasa işlemi ve kesinti planı burada doğar. */
  avansOde: (id: number, g: {
    hesapId: number; tur?: number; tarih?: string; aciklama?: string;
  }) => gonder<{
    durum: number; tutar: number; kasaIslemId: number; taksit: number;
  }>(`/api/ik/avans/${id}/ode`, g),

  /** Bekleyen EN ESKİ taksiti keser - sıra atlanmaz. */
  avansKesinti: (id: number, g: { kesintiId?: number; tarih?: string; aciklama?: string }) =>
    gonder<{
      kesintiId: number; sira: number; donem: string; tutar: number;
      kalanTaksit: number; avansDurum: number;
    }>(`/api/ik/avans/${id}/kesinti`, g),

  avansIptal: (id: number, gerekce: string) =>
    gonder<{ durum: number }>(`/api/ik/avans/${id}/iptal`, { gerekce }),

  /** Onaylı izin de iptal edilir - silinmez; "alınmış mıydı" sorusu sonra da sorulur. */
  izinIptal: (id: number, gerekce: string) =>
    gonder<{ durum: number }>(`/api/ik/izin/${id}/iptal`, { gerekce }),

  // ======================================================= masraf beyani ==
  //  ODEME YOK (764): zincir onayla biter, muhasebe disarida oder.

  masrafAc: (g: { tarafId: number; beyanTarihi?: string; aciklama?: string }) =>
    gonder<{ id: number; durum: number }>('/api/ik/masraf', g),

  /** Belgesiz satir YAZILAMAZ - `belgeNo` zorunlu (db kisiti da korur). */
  masrafSatirEkle: (id: number, g: {
    masrafId?: number; harcamaTarihi?: string; belgeTuru?: number;
    belgeNo: string; tutar: number; kdvTutar?: number; aciklama?: string;
  }) => gonder<{ satirId: number; toplamTutar: number }>(
      `/api/ik/masraf/${id}/satir`, g),

  masrafSatirSil: (satirId: number) =>
    istek<{ satirId: number }>(`/api/ik/masraf/satir/${satirId}`,
                               { method: 'DELETE' }),

  masrafGonder: (id: number) =>
    gonder<{
      durum: number; toplamTutar: number;
      basamaklar: { sira: number; ad: string; rol: number }[];
    }>(`/api/ik/masraf/${id}/gonder`, {}),

  masrafIptal: (id: number, gerekce: string) =>
    gonder<{ durum: number }>(`/api/ik/masraf/${id}/iptal`, { gerekce }),

  // ======================================================== belge talebi ==
  //  ASIL IS ONAY DEGIL HAZIRLAMAK (765): durum onayla bitmez.

  belgeTalepAc: (g: {
    tarafId: number; tur?: number; amac: string; muhatap?: string;
    adet?: number; teslimSekli?: number; aciklama?: string;
  }) => gonder<{
    id: number; durum: number; otomatikOnay: boolean; mesaj: string;
    basamaklar?: { sira: number; ad: string; rol: number }[];
  }>('/api/ik/belge-talep', g),

  /** 768: artik metni de URETIR ve dondurur; eksik yer tutucu varsa reddeder. */
  belgeTalepHazirla: (id: number, not?: string) =>
    gonder<{ durum: number; sablonAd: string | null; baslik: string | null;
             elleDuzenlenmis: boolean }>(
      `/api/ik/belge-talep/${id}/hazirla`, { gerekce: not }),

  belgeTalepTeslim: (id: number, not?: string) =>
    gonder<{ durum: number }>(`/api/ik/belge-talep/${id}/teslim`, { gerekce: not }),

  /** Otomatik onaylanmis talep de gerekceyle reddedilebilir. */
  belgeTalepReddet: (id: number, gerekce: string) =>
    gonder<{ durum: number }>(`/api/ik/belge-talep/${id}/reddet`, { gerekce }),

  // ------------------------------------------------------ yazinin kendisi --
  //  768: "hazirlandi" artik bir ISARET degil, URETILMIS metin.
  //
  //  `donmus = true` ise metin o talep icin DONDURULMUS demektir; sablon
  //  sonradan degisse de bu metin degismez - teslim edilen kagitla ekrandaki
  //  yazi ayrismasin. `sablon` verilirse dondurulmus metin degil, o sablonun
  //  onizlemesi doner.
  belgeTalepYazi: (id: number, sablon?: number) =>
    istek<BelgeYazisi>(`/api/ik/belge-talep/${id}/yazi`
                       + (sablon ? `?sablon=${sablon}` : '')),

  /** Elle duzeltilmis metni dondurur; hazirlama bunu korur. */
  belgeTalepYaziKaydet: (id: number,
                         g: { baslik: string; govde: string; sablonId?: number }) =>
    gonder<{ donduruldu: boolean }>(`/api/ik/belge-talep/${id}/yazi`, g),
};
