import { hamSayi } from '../bicim';
import type { DetayDurumu } from '../GenDetayTablo';

/**
 * FIYAT LISTESI / TARIFE KURALLARI (532 · 533).
 *
 * Kurallarin son otoritesi DB tetigidir (kaydeden kim olursa olsun ayni
 * sonuc); buradaki kopya EKRANIN aynasidir - kullanici katsayiyi yazarken
 * fiyati kaydetmeden gormeli, ayrica degisen deger istekle birlikte gidip
 * ISLEM LOGUNA yazilmali.
 *
 * `GenForm` govdesinden ayrildi: bilesen 2300 satira ulasmisti ve bu uc
 * fonksiyon kart durumuna hic dokunmuyor - saf kural.
 */

/**
 * SATIR ICI GIRIS YAPILACAK ALANLAR tarife tipine gore (533).
 *   Özel  : fiyat elle, katki elle
 *   TTB   : KATSAYI ve CARPAN elle - fiyat carpimdan doğar, yazilamaz
 *   SUT   : yalniz katki - fiyat SKRS'den kilitli
 * Fiyat kutusunu TTB/SUT'ta acik birakmak, kullaniciya tutmayacagi bir soz
 * vermekti: girilen sayi kaydedilirken tetik tarafindan yok sayiliyor.
 */
export function tarifeHizli(tip: number): Set<string> {
  if (tip === 2) return new Set(['tabanFiyat', 'carpan', 'katkiTutar']);
  if (tip === 3) return new Set(['katkiTutar']);
  return new Set(['fiyat']);   // Özel: yalniz fiyat
}

/**
 * TTB/HUV SATIRINDA FIYAT ANINDA DOGSUN (533, kullanici: "katsayi carpan
 * degisince fiyat aninda degissin"). Kural DB tetiginde de var (kaydeden kim
 * olursa olsun ayni sonuc); burasi EKRANIN aynasi - kullanici katsayiyi
 * yazarken fiyati gormek zorunda, kaydedip beklememeli.
 * Yuvarlama DB'de listenin kuralina gore yapilir; ekranda iki hane yeter -
 * kayittan sonra gelen deger son sozdur.
 */
export function ttbFiyatTuret(durum: DetayDurumu): DetayDurumu {
  let degisti = false;
  const guncel = durum.guncel.map(s => {
    const katsayi = Number(s.tabanFiyat ?? 0);
    const carpan = Number(s.carpan ?? 0);
    if (!(katsayi > 0 && carpan > 0)) return s;
    const yeni = Math.round(katsayi * carpan * 100) / 100;
    if (Number(s.fiyat ?? 0) === yeni) return s;
    degisti = true;
    return { ...s, fiyat: yeni };
  });
  return degisti ? { ...durum, guncel } : durum;
}

export function tarifeGizli(tip: number): string[] {
  // Ek katki alanlari 532'de fiyat listesinden kalkti - listede yok.
  if (tip === 2) return [];                       // katsayi · carpan · fiyat · katki
  if (tip === 3) return ['tabanFiyat', 'carpan']; // fiyat SKRS'den, katsayi yok
  // OZEL (1) VE TARIFESI BILINMEYEN (542): yalniz Fiyat. ERP kurulumunda
  //   tarife alani karta HIC gelmiyor (`UrunModu`) - deger okunamayinca eski
  //   kod `0` sayip TUM sutunlari aciyordu: kullanici Özel listede katsayi,
  //   carpan ve katki sutunlarini goruyordu (kullanici: "sadece fiyat olması
  //   gerekir"). ERP'de DB de 1 yaziyor, ekran da 1 varsayar.
  return ['tabanFiyat', 'carpan', 'katkiTutar'];
}

/**
 * FIYAT LISTESI SATIR KURALI (539):
 *  - Carpan degisince fiyat = taban fiyat x carpan (yuvarlama satirdan,
 *    bossa basligin kuralindan) ve Yazim MANUEL olur - uretim artik ezmez.
 *  - Yazim HESAP'a cevrilince fiyat basligin kuralindan yeniden hesaplanir,
 *    carpan basligin carpanina doner.
 *
 * `baslik` kart govdesinin (liste basliginin) o anki degerleridir: satirda
 * bos birakilan yuvarlama/carpan oradan miras alinir.
 */
export function fiyatSatirKurali(
  alan: string, v: unknown,
  taslak: Record<string, unknown>,
  baslik: Record<string, unknown>,
) {
  const yuvarla = (tutar: number, yonHam: unknown, adimHam: unknown) => {
    const yon = Number(yonHam ?? 0);
    const adim = hamSayi(adimHam) || 1;
    if (!yon || adim <= 0) return tutar;
    if (yon === 1) return Math.ceil(tutar / adim) * adim;
    if (yon === 2) return Math.floor(tutar / adim) * adim;
    if (yon === 3) return Math.round(tutar / adim) * adim;
    return tutar;
  };
  // Fiyat 4, carpan 6 hane (kolon numeric(18,6) - 7,0092 gibi degerler).
  const metin = (s: number, hane = 4) => {
    const k = 10 ** hane;
    return String(Math.round(s * k) / k);
  };
  const taban = hamSayi(taslak.tabanFiyat);

  if (alan === 'carpan') {
    const carpan = hamSayi(v);
    if (carpan <= 0 || taban <= 0) return { yazim: '1' };
    const bos = (d: unknown) => d === '' || d === null || d === undefined;
    const yon  = bos(taslak.yuvarlama)      ? baslik.yuvarlama      : taslak.yuvarlama;
    const adim = bos(taslak.yuvarlamaBirim) ? baslik.yuvarlamaBirim : taslak.yuvarlamaBirim;
    return { fiyat: metin(yuvarla(taban * carpan, yon, adim)), yazim: '1' };
  }
  // FIYAT elle degisti: satir Manuel olur; zincirli satirda carpan fiyattan
  //   GERIYE hesaplanir (taban degismez). Koksuz/manuel listede carpan
  //   anlamsiz - dokunulmaz.
  if (alan === 'fiyat') {
    const f = hamSayi(v);
    if (taslak.tabanListeId && taban > 0 && f > 0)
      return { yazim: '1', carpan: metin(f / taban, 6) };
    return { yazim: '1' };
  }
  if (alan === 'yazim' && String(v) === '2' && taban > 0) {
    const carpan = hamSayi(baslik.carpan) || 1;
    return {
      fiyat: metin(yuvarla(taban * carpan, baslik.yuvarlama, baslik.yuvarlamaBirim)),
      carpan: metin(carpan, 6),
    };
  }
  return null;
}
