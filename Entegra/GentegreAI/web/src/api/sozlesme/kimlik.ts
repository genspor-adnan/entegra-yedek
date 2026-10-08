/** API sozlesmesi - kimlik. Alan adlari sunucuyla birebir. */

// --------------------------------------------------------------- kimlik ----
export interface SubeOzeti {
  id: number; ad: string; varsayilan: boolean; yazma: boolean;
  /** ISO 3166 iki harf (666). TR disinda TCKN/telefon bicim kontrolu YAPILMAZ. */
  ulkeKod: string;
  /** Telefon kutusunun acilis kodu ('+90'). */
  telefonKodu: string;
  /** IANA adi ('Europe/Istanbul') - sabit saat farki DEGIL. */
  zamanDilimi: string;
  /** ISO 4217 ('TRY') - belgenin kendi dovizi ayridir. */
  paraBirimi: string;
  /** Şube kartındaki "Logo" görseli (dokuman id); üst şeritte şube adının yanında. */
  logoDokumanId?: number | null;
}

export interface KullaniciOzeti {
  id: number; kod: string; ad: string;
  rolId: number; rolAdi: string;
  dil: number;
  /**
   * PORTAL TURU (806): 0 ic kullanici · 1 dis doktor · 2 dis kurum · 3 hasta.
   * Arayuz KURAL YAZMAZ - kapsam sunucuda; bu alan yalnizca portal
   * kullanicisina ANLAMSIZ dugmeyi gostermemek icin ("serbest sohbet ac"
   * sunucuda reddediliyor, her zaman hata veren dugme yalan soylemektir).
   */
  portalTuru?: number;
  /**
   * HEKIM KISITI: kullanici yalniz kendi muayene / calisma listesi / randevu
   * satirlarini gorur (suzme SUNUCUDA). Arayuz bununla hekim seciciyi kendi
   * adina kilitler.
   */
  hekimKisitli?: boolean;
  /**
   * PORTALDA KAPSAMI ACIK kaynak adlari (796 V2). Yetki tek basina yetmiyor:
   * kurali `false` olan ekran acilsa BOS gelir - portal menusu bununla
   * suzulur. Ic kullanicida bos dizi.
   */
  portalKaynaklar?: string[];
  /**
   * ZORUNLU PAROLA DEGISIMI (674): varsayilan parolayla (personel kart id'si)
   * giren kisi once kendi parolasini belirler. /ben de tasir - yalniz giris
   * yanitinda olsaydi sayfayi yenileyen kullanici zorunlulugu atlardi.
   */
  parolaDegismeli?: boolean;
  yetkiSurumu: number;
  subeId?: number | null;
  subeYazma: boolean;
  subeler: SubeOzeti[];
  /** Urun modu (215): 1 Gentegre AI (ERP), 2 GenoTIP AI (HBYS). */
  urunModu?: number;
  /**
   * KURULUMDA ACIK MODULLER (359): kurum profilinden cozulur. Menu ve rotalar
   * bunlara gore suzulur; bos dizi = bilgi yok, hicbir sey suzulmez.
   */
  moduller?: string[];
  /**
   * AKTIF SUBENIN KURUM PROFILI (786): sol menunun "Oturum" bolumu yazar.
   * Kullanici hangi profilde calistigini menuyu yorumlayarak degil, yazili
   * gorerek bilsin.
   */
  kurumTipi?: string;
  kurumTipiAdi?: string;
  /** MENÜ TİPİ (905): 1 bölgeli (Hasta Akışı/Klinikler başlıkları), 0 düz. Profilden. */
  menuBolgeli?: number;
  /**
   * AKTIF SUBEDE basvuruda sorulan hekim rolu (361/364): 1 "Gönderen"
   * (lab/goruntuleme subesi - dis doktor), 4 "Yapan" (digerleri - personel).
   */
  hekimRolu?: number;
  /**
   * ISKONTO ONAY ESIGI (783): bu oranin USTUNDEKI iskonto, kullanicinin
   * tavani yetse bile ONAYLI talepten gelmek zorunda. 0 = kural kapali.
   * Kural sunucuda tetikle korunur; ekran limiti bunu gozetip kullaniciyi
   * reddedilecek bir orani yazmaktan kurtarir.
   */
  iskontoOnayEsigi?: number;
}

/** Urun modlari (215). Ad sol ust marka, mesaj basligi ve menu suzmede kullanilir. */
export const URUN_GENOTIP = 2;
/** 3 = "ikisi" (tip merkezi + ticari): HER IKI urunun ekranlari acik. */
export const URUN_IKISI = 3;
export const urunAdi = (mod?: number) => (mod === URUN_GENOTIP ? 'GenoTIP AI' : 'Gentegre AI');

/**
 * Ekranin urun modu kurulumunkiyle uyuyor mu (492).
 *
 * TAM ESITLIK YETMEZ: karma kurulumda (mod 3) tam esitlik arayan suzgec hem
 * ERP'ye hem HBYS'ye ozgu ekranlari birden gizliyordu - kullanici "ikisi"
 * secmesine ragmen menude ne SKRS ne Uretim kaliyordu.
 */
export const modUyar = (ekranModu?: number, kurulumModu?: number) =>
  !ekranModu || (kurulumModu ?? 1) === URUN_IKISI || ekranModu === (kurulumModu ?? 1);

export interface GirisYaniti {
  accessToken: string;
  refreshToken: string;
  sonaErme: string;
  refreshSonaErme: string;
  parolaDegismeli: boolean;
  subeSecimiGerekli: boolean;
  kullanici: KullaniciOzeti;
}

export interface KaynakYetkisi {
  kod: string; gor: boolean; ekle: boolean; degistir: boolean; sil: boolean;
}

export interface BenYaniti {
  kullanici: KullaniciOzeti;
  aksiyonlar: string[];
  /**
   * SAYISAL SINIRI OLAN aksiyonlar (661): kod -> sinir. Ornek
   * `{ 'basvuru.iskonto': 20 }` = bu rol en cok %20 iskonto yapabilir.
   * Yalniz siniri TANIMLI olanlar gelir; sinir isteyen bir aksiyon burada
   * yoksa "yapamaz" demektir - eksik deger "sinirsiz" sayilsaydi, degeri
   * girilmemis her rol sinirsiz iskonto yapardi.
   */
  aksiyonDegerleri?: Record<string, number>;
  kaynaklar: KaynakYetkisi[];
}
