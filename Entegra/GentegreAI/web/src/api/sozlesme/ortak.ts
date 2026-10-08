/** API sozlesmesi - ortak tipler, hata govdesi ve yardimcilar. Alan adlari sunucuyla birebir. */

import { c } from '../../dil/ceviri';
// Sunucu sozlesmesinin (dokuman/01_API_SOZLESMELERI.md) TypeScript karsiligi.
// Alan adlari sunucudakiyle BIREBIR ayni tutulur - cevrim katmani yok.

export type HataKodu =
  | 'DOGRULAMA' | 'YETKISIZ' | 'YASAK' | 'BULUNAMADI'
  | 'CAKISMA' | 'IS_KURALI' | 'SUNUCU'
  // Hesap var ama parolasi hic tanimlanmamis - giris ekrani parola belirleme
  //   adimina gecer.
  | 'ILK_PAROLA'
  // Oturum gecerli ama hesap parolasini degistirmek ZORUNDA (denetim
  //   28.09.2026 #4) - sunucu yalniz profil/parola/cikis uclarini acar.
  | 'PAROLA_DEGISMELI';

export interface AlanHatasi { alan: string; mesaj: string }

/** Silme/degistirme engeli: bagli kayit sayisi. */
export interface SilmeEngeli { tablo: string; adet: number; ad?: string }
/** Is kurali engeli (873 akilci istem): kod + kurala ozgu alanlar. */
export interface KuralEngeli { kod: string; [ek: string]: unknown }

/** Engel silme engeli mi - mesaja "(tablo: n kayit)" eki bundan cikar. */
export const silmeEngeliMi = (e: SilmeEngeli | KuralEngeli | undefined): e is SilmeEngeli =>
  !!e && typeof (e as SilmeEngeli).adet === 'number';

export interface HataGovdesi {
  kod: HataKodu;
  mesaj: string;
  izlemeNo: string;
  alanlar?: AlanHatasi[];
  cakisanAlanlar?: string[];
  guncelDeger?: Record<string, unknown>;
  /**
   * ENGEL IKI SEKILLIDIR (873'te ikincisi geldi):
   *  - SILME ENGELI: "hangi tabloda kac kayit" (`tablo` + `adet`).
   *  - KURAL ENGELI: akilci test istemi gibi is kurallari, kendi kodu ve
   *    kurala ozgu alanlariyla (`kod` + serbest alanlar).
   * Tek sekil varsayilinca 873'un gonderdigi govde tipe uymuyordu ve
   * `npm run build` kiriliyordu - dogrusu sozlesmenin iki sekli de anlatmasi.
   */
  engel?: SilmeEngeli | KuralEngeli;
  /** Excel iceri alma (207): satir numarali dogrulama hatalari. */
  satirHatalari?: { satirNo: number; alan: string; mesaj: string }[];
  toplamHata?: number;
}

/** Sunucudan donen hata; istemcide bu tip firlatilir. */
export class ApiHatasi extends Error {
  durum: number;
  hata: HataGovdesi;

  constructor(durum: number, hata: HataGovdesi) {
    super(hata.mesaj);
    this.durum = durum;
    this.hata = hata;
  }
  get dogrulamaMi() { return this.hata.kod === 'DOGRULAMA' }
  get cakismaMi()   { return this.hata.kod === 'CAKISMA' }
}

/**
 * Yakalanan hatayi EKRANA yazilacak metne cevirir.
 *
 * Ayni ifade 24 dosyada tekrarliyordu; sunucu mesaji varsa oldugu gibi
 * gosterilir (kullaniciya donuk, Turkce), yoksa hatanin kendisi yazilir -
 * "[object Object]" cikmasin. `kodlu` hata kodunu one ekler (BELGE_KURALI: ...).
 */
/**
 * HATA METNİ DİLE GÖRE (849): makine sözleşmesi (`hata.kod`) DEĞİŞMEZ;
 * kullanıcıya gösterilen cümle koda göre sözlükten çözülür. Sözlükte
 * karşılığı olmayan kodda sunucunun kendi cümlesi kalır - iş kuralı (422)
 * ve doğrulama (400) hataları kurala özgü sebebi taşır, o sebep
 * KAYBOLMAMALI ("Bu cariye ait fatura var, silinemez").
 *
 * Kapsam `hata`, anahtar KODUN KENDİSİ - Türkçe cümle değil: sunucu
 * cümlesini değiştirdiğinde çeviri sessizce kopmasın.
 */
function hataCumlesi(h: ApiHatasi): string {
  const kodlu = c(h.hata.kod, 'hata');
  return kodlu === h.hata.kod ? h.message : kodlu;
}

export function hataMetni(h: unknown, kodlu = false): string {
  if (h instanceof ApiHatasi) {
    const cumle = hataCumlesi(h);
    const metin = kodlu ? `${h.hata.kod}: ${cumle}` : cumle;
    // IZLEME NUMARASI BEKLENMEYEN HATADA GOSTERILIR: sunucu "izleme
    //   numarasini bildirin" diyor ama numara ekranda hic gorunmuyordu -
    //   kullanicinin bildirebilecegi bir sey yoktu. Is kurali / dogrulama
    //   hatalarinda GOSTERILMEZ: orada mesajin kendisi zaten yeterli,
    //   numara gurultu olur.
    return h.hata.kod === 'SUNUCU' && h.hata.izlemeNo
      ? `${metin} (izleme: ${h.hata.izlemeNo})` : metin;
  }
  return h instanceof Error ? h.message : String(h);
}

/** `hataAyristir` ciktisi - kartlarin durum kutularina birebir oturur. */
export interface HataCozumu {
  /** Kutuda gosterilecek metin. */
  mesaj: string;
  /** alan -> mesaj; alan bazli uyarilar icin. Yoksa bos nesne. */
  alanlar: Record<string, string>;
  /** Ilk hatali alan - kart o sekmeye atlayabilsin diye. */
  ilkAlan: string | null;
  /** 409 CAKISMA: baskasinin degistirdigi alanlar + guncel degerler. */
  cakisma: { alanlar: string[]; guncel: Record<string, unknown> } | null;
}

/**
 * KAYIT HATASINI EKRAN DURUMUNA CEVIRIR - tek yer.
 *
 * Uc kart (GenForm, BelgeKarti, KasaIslemKarti) bunu ayri ayri yaziyordu ve
 * kopyalar ayrismisti: `cakisma` (409) ve `engel` (silme engeli sayaci)
 * dallari YALNIZ GenForm'da vardi, oteki iki kart ayni sunucu yanitina daha
 * fakir tepki veriyordu. Tek cozumleyici uc kartin davranisini esitler.
 */
export function hataAyristir(h: unknown): HataCozumu {
  if (!(h instanceof ApiHatasi))
    return { mesaj: hataMetni(h), alanlar: {}, ilkAlan: null, cakisma: null };

  if (h.dogrulamaMi && h.hata.alanlar?.length)
    return {
      mesaj: h.message,
      alanlar: Object.fromEntries(h.hata.alanlar.map(a => [a.alan, a.mesaj])),
      ilkAlan: h.hata.alanlar[0].alan,
      cakisma: null,
    };

  if (h.cakismaMi)
    return {
      mesaj: h.message,
      alanlar: {},
      ilkAlan: null,
      cakisma: { alanlar: h.hata.cakisanAlanlar ?? [], guncel: h.hata.guncelDeger ?? {} },
    };

  // Silme/degistirme engeli: "hangi tabloda kac kayit" bilgisi mesaja eklenir,
  //   kullanici neyi temizleyecegini bilsin.
  // Kullaniciya TABLO ADI degil, Turkce karsiligi gosterilir (sunucu cozer).
  const engel = silmeEngeliMi(h.hata.engel)
    ? ` (${h.hata.engel.ad || h.hata.engel.tablo}: ${h.hata.engel.adet} kayıt)` : '';
  // IS_KURALI mesaji ZATEN kullaniciya yazilmis Turkce bir cumledir ("... 
  //   silinemez, ... yapabilirsiniz") - basina teknik kod eklemek okumayi
  //   zorlastiriyordu. Oteki kodlar (SUNUCU, BULUNAMADI...) tani icin kalir.
  const onek = h.hata.kod === 'IS_KURALI' ? '' : `${h.hata.kod}: `;
  return { mesaj: `${onek}${h.message}${engel}`, alanlar: {}, ilkAlan: null, cakisma: null };
}
