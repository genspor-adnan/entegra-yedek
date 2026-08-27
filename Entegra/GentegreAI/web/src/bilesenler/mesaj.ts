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
  cozum(sonuc: boolean): void;
  cozumMetin?(deger: string | null): void;
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

/** Onay penceresi: kullanici "Tamam" derse true. */
export function onay(metin: string, tehlike = false): Promise<boolean> {
  if (!dinleyici) return Promise.resolve(confirm(metin));
  return new Promise<boolean>(cozum => {
    dinleyici!({ metin, onayMi: true, tehlike, cozum });
  });
}
