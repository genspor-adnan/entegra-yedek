/**
 * UYGULAMA MESAJLARI - tarayicinin `alert` / `confirm` kutulari yerine.
 *
 * Neden: tarayici kutulari sayfayi KILITLIYOR (acikken hicbir sey islemiyor,
 * hatta gelistirme sirasinda oturum donuyordu), basligi "localhost diyor ki"
 * oluyor ve bicimlendirilemiyor. Burada yayinlanan istek `MesajKatmani`
 * tarafindan uygulamanin kendi penceresinde gosterilir.
 *
 * Kullanim tek satir kalsin diye modul seviyesinde: bilesenden context
 * gecirmek gerekmiyor, `mesaj('...')` / `await onay('...')` yeter.
 */
import { hataMetni } from '../api/sozlesme';

export interface MesajIstegi {
  metin: string;
  /** Onay kutusu ise iki dugme cizilir ve secim `cozum`e gider. */
  onayMi: boolean;
  /** Kirmizi vurgulu baslik (silme gibi geri alinamaz isler icin). */
  tehlike?: boolean;
  /** Metin istegi: kutuya yazilan deger `cozumMetin`e gider (iptalde null). */
  girdiMi?: boolean;
  girdiVarsayilan?: string;
  girdiEtiket?: string;
  /**
   * GIRDI BIR LISTEDEN SECILIYORSA (kullanici: "kabul/ret butonlarinda
   * mesajda girisler combo olsun"). Kutu yerine acilir liste cizilir;
   * donen deger secilen KODDUR. Kod listesini metne yazip kullanicidan
   * numara istemek, ezberi olmayan herkese metni okutuyordu.
   */
  girdiSecenekleri?: { kod: string; ad: string }[];
  /**
   * UC (ya da daha cok) SECENEKLI soru - "Kaydet / İptal / Geri Dön"
   * (kullanici). Verilirse Tamam/Vazgeç yerine bu dugmeler cizilir ve secilen
   * kod `cozumSecim`e gider; pencere Escape ile kapatilirsa ILK dugme degil,
   * `varsayilanKod` doner (geri don = guvenli secenek).
   */
  secenekler?: { kod: string; ad: string; sinif?: string }[];
  varsayilanKod?: string;
  /**
   * PARA ISTEGI (tutar + para birimi): duz metin kutusu tutari soruyor ama
   * PARA BIRIMINI soramiyordu - dovizli tahsilatta kullanici "100" yaziyor,
   * sistem 100 TL saniyordu. Burada tutarin SAGINDA birim combosu, doviz
   * secilince kur ve yerel karsilik satiri cizilir.
   */
  paraMi?: boolean;
  para?: ParaIstegi;
  cozum(sonuc: boolean): void;
  cozumMetin?(deger: string | null): void;
  cozumSecim?(kod: string): void;
  cozumPara?(sonuc: ParaSecimi | null): void;
}

/** `paraSor` penceresinin sekil ayarlari. */
export interface ParaIstegi {
  varsayilan?: string;
  doviz?: string;
  /** Yerel para kodu - doviz buna cevrilir (varsayilan "TL"). */
  yerelPara?: string;
  dovizler?: string[];
  /** Girilebilecek en yuksek tutar (mutlak deger); asilirsa uyarilir. */
  enCok?: number;
  /** IADE/PARA USTU: tutar eksi isaretle islenir ve ekranda "−" gosterilir. */
  eksiMi?: boolean;
  /** Verilirse tutarin ALTINDA zorunlu bir neden combosu cizilir. */
  nedenler?: { kod: string; ad: string }[];
  nedenEtiket?: string;
  /** Doviz secilince kuru getirir; yoksa kullanici elle yazar. */
  kurGetir?(doviz: string): Promise<number | null>;
}

/** `paraSor` sonucu. Tutarlar `eksiMi` istendiginde EKSI doner. */
export interface ParaSecimi {
  tutar: number;
  doviz: string;
  kur: number;
  /** tutar × kur - kasa islemine yazilan yerel karsilik. */
  yerelTutar: number;
  neden?: string;
}

type Dinleyici = (istek: MesajIstegi) => void;

let dinleyici: Dinleyici | null = null;

/** MesajKatmani baglanir; katman yokken mesajlar tarayici kutusuna duser. */
export function mesajDinleyiciAta(d: Dinleyici | null) {
  dinleyici = d;
}

/** Bilgi/uyari penceresi. */
export function mesaj(metin: string) {
  if (!dinleyici) { alert(metin); return }
  dinleyici({ metin, onayMi: false, cozum: () => {} });
}

/**
 * Metin sorma penceresi (tarayici `prompt` yerine). Iptalde null doner.
 * e-Arsiv gonderiminde alici e-postasi bununla sorulur.
 */
export function metinSor(metin: string, varsayilan = '', etiket = ''): Promise<string | null> {
  if (!dinleyici) return Promise.resolve(prompt(metin, varsayilan));
  return new Promise<string | null>(cozum => {
    dinleyici!({
      metin, onayMi: true, girdiMi: true,
      girdiVarsayilan: varsayilan, girdiEtiket: etiket,
      cozum: () => {}, cozumMetin: cozum,
    });
  });
}

/**
 * ACILIR LISTEDEN SECTIRME. Iptalde null doner; varsayilan secili gelir.
 *
 *     const k = await listeSor('Numune kalitesi:', KALITELER, '1', 'Kalite');
 */
export function listeSor(metin: string, secenekler: { kod: string; ad: string }[],
                         varsayilan = '', etiket = ''): Promise<string | null> {
  if (!dinleyici) {
    const c = prompt(`${metin}
`
      + secenekler.map(x => `${x.kod} ${x.ad}`).join(' · '), varsayilan);
    return Promise.resolve(c);
  }
  return new Promise<string | null>(cozum => {
    dinleyici!({
      metin, onayMi: true, girdiMi: true,
      girdiVarsayilan: varsayilan || secenekler[0]?.kod || '',
      girdiEtiket: etiket, girdiSecenekleri: secenekler,
      cozum: () => {}, cozumMetin: cozum,
    });
  });
}

/**
 * TUTAR + PARA BIRIMI SORMA PENCERESI. Iptalde null doner.
 *
 * Metin kutusu yerine bunun kullanildigi yerler: hizli tahsilat, iade/iptal
 * ve iade (para ustu dahil - o da bir iade nedenidir). Tutarin yanina birim
 * koymak sart - dovizli kasada "100" ne
 * demek belirsizdi; ayrica iade neden KODUYLA sorulur, serbest metinle degil
 * (rapor "fazla tahsilat" ile "fazla alindi"yi ayni sayamiyordu).
 */
export function paraSor(metin: string, se: ParaIstegi = {}): Promise<ParaSecimi | null> {
  if (!dinleyici) return Promise.resolve(null);
  return new Promise<ParaSecimi | null>(cozum => {
    dinleyici!({
      metin, onayMi: true, paraMi: true, para: se,
      cozum: () => {}, cozumPara: cozum,
    });
  });
}

/** Onay penceresi: kullanici "Tamam" derse true. */
export function onay(metin: string, tehlike = false): Promise<boolean> {
  if (!dinleyici) return Promise.resolve(confirm(metin));
  return new Promise<boolean>(cozum => {
    dinleyici!({ metin, onayMi: true, tehlike, cozum });
  });
}

/**
 * COK SECENEKLI soru. Dondugu deger secilen dugmenin kodudur; pencere
 * Escape/perde ile kapatilirsa `varsayilan` doner.
 *
 * Ornek (kaydedilmemis kart kapatilirken, kullanici):
 *     const c = await secimSor('Değişiklikler kaydedilsin mi?', [
 *       { kod: 'kaydet', ad: '💾 Kaydet', sinif: 'bir' },
 *       { kod: 'atla',   ad: '✖ Kaydetme', sinif: 'teh' },
 *       { kod: 'geri',   ad: '↩ Geri Dön' },
 *     ], 'geri');
 */
export function secimSor(metin: string,
                         secenekler: { kod: string; ad: string; sinif?: string }[],
                         varsayilan = ''): Promise<string> {
  const kod0 = varsayilan || secenekler[secenekler.length - 1]?.kod || '';
  // Katman yoksa (teorik) en guvenli secenek: hicbir sey yapma.
  if (!dinleyici) return Promise.resolve(kod0);
  return new Promise<string>(cozum => {
    dinleyici!({
      metin, onayMi: true, secenekler, varsayilanKod: kod0,
      cozum: () => {}, cozumSecim: cozum,
    });
  });
}

/**
 * "Calistir, patlarsa mesaj goster" sarmalayicisi.
 *
 * `try { ... } catch (h) { mesaj(hataMetni(h)) }` kalibi 18 yerde birebir
 * tekrarliyordu (liste aksiyonlari + gelen e-Belge adimlari). Hepsi ayni seyi
 * yapiyor: aksiyonu calistir, sunucu hatasini kullaniciya goster, ekrani
 * cokertme.
 *
 * Isi bittiyse (hata cikmadiysa) true doner - cagiran "basardiysa listeyi
 * tazele" diyebilsin.
 */
export async function guvenli(is: () => Promise<unknown> | unknown): Promise<boolean> {
  try {
    await is();
    return true;
  } catch (h) {
    mesaj(hataMetni(h));
    return false;
  }
}
