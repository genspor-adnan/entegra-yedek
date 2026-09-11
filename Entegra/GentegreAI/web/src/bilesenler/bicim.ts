import type { KolonMeta } from '../api/sozlesme';

/**
 * TEK BICIM KAYNAGI: tutar / miktar bicimleri butun ekranlarda ayni olmali.
 *   para  - iki hane, tutar kolonlari
 *   say4  - dorde kadar hane, MIKTAR (0,5 adet / 12,375 kg)
 *   sayi  - tam sayi
 * Onceden her dosya kendi Intl.NumberFormat'ini kuruyordu (8 kopya); biri
 * degistiginde otekiler geride kaliyordu.
 */
export const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
/** Kur / carpan kolonlari - dort hane (7,0092'nin 7,01 gorunmemesi icin). */
export const para4 = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 4 });
export const say4 = new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 4 });
export const sayi = new Intl.NumberFormat('tr-TR');

/**
 * ONDALIKLI SAYI KOLONU: kolonun `bicim` deseni ("#,##0.00000") kaç hane
 * istiyorsa o kadar gösterilir. Önceden `sayi` (tam sayı) kullanılıyordu ve
 * gnomAD frekansı 0,00002 ekranda **0** görünüyordu - varyantın nadir mi
 * yaygın mı olduğu, sınıflandırmanın en önemli girdisidir.
 */
const ondalikBicimler = new Map<number, Intl.NumberFormat>();
export function ondalikSayi(deger: number, hane: number): string {
  const h = Math.max(0, Math.min(10, hane));
  let b = ondalikBicimler.get(h);
  if (!b) {
    b = new Intl.NumberFormat('tr-TR',
      { minimumFractionDigits: h, maximumFractionDigits: h });
    ondalikBicimler.set(h, b);
  }
  return b.format(deger);
}

/** "#,##0.000" -> 3. Desen yoksa ya da ondalık istemiyorsa 0. */
export function bicimHanesi(bicim: string | null | undefined): number {
  const n = bicim?.split('.')[1]?.length ?? 0;
  return Number.isFinite(n) ? n : 0;
}
const tarih = new Intl.DateTimeFormat('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric' });
const tarihSaatBicim = new Intl.DateTimeFormat('tr-TR', {
  day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit',
});

function tarihParcala(deger: string): { gun: string; ay: string; yil: string; saat?: string; dakika?: string } | null {
  const eslesme = deger.match(/^(\d{4})-(\d{2})-(\d{2})(?:[T\s](\d{2}):(\d{2}))?/);
  if (!eslesme) return null;
  return {
    yil: eslesme[1],
    ay: eslesme[2],
    gun: eslesme[3],
    saat: eslesme[4],
    dakika: eslesme[5],
  };
}

export function tarihYaz(deger: string): string {
  const parca = tarihParcala(deger);
  if (parca) return `${parca.gun}.${parca.ay}.${parca.yil}`;

  const t = new Date(deger);
  return Number.isNaN(t.getTime()) ? deger : tarih.format(t);
}

/**
 * Hucre bicimlendirme. Sunucu sayilari JSON'da metin olarak da gonderebilir
 * (numeric alanlar) - ikisi de desteklenir.
 *
 * 'mantik' alanlar PG'de SMALLINT'tir (MSSQL bit karsiligi): 1 = evet.
 */
/**
 * TELEFON GOSTERIMI (genel kural): kayitta ne olursa olsun ekranda ayni bicim.
 * "+905324187720" / "0532 418 77 20" / "5324187720" -> "+90 532 418 77 20".
 * Yabanci numarada gruplama yapilmaz (format ulkeden ulkeye degisir), yalniz
 * ulke kodu ayrilir.
 */
export function telefonBicimle(ham: unknown): string {
  const metin = String(ham ?? '').trim();
  if (!metin) return '';

  const artili = metin.startsWith('+');
  const rakam = metin.replace(/\D/g, '');
  if (!rakam) return metin;

  // Yerel yazim: "0532...", "532..." - Turkiye kabul edilir.
  if (!artili) {
    const on = rakam.length === 11 && rakam.startsWith('0') ? rakam.slice(1) : rakam;
    if (on.length === 10) return `+90 ${on.slice(0, 3)} ${on.slice(3, 6)} ${on.slice(6, 8)} ${on.slice(8)}`;
    return metin;
  }

  if (rakam.startsWith('90')) {
    // Kullanici ulke kodunun ARDINDAN da "0" yazabiliyor ("+90 0532..."):
    //   yerel onek atilir, kalan 10 hane ise gruplanir.
    let on = rakam.slice(2);
    if (on.length === 11 && on.startsWith('0')) on = on.slice(1);
    if (on.length === 10)
      return `+90 ${on.slice(0, 3)} ${on.slice(3, 6)} ${on.slice(6, 8)} ${on.slice(8)}`;
  }
  // Diger ulkeler: rakamlara dokunma, yalniz "+" korunur.
  return `+${rakam}`;
}

/** Kolon telefon mu - katalogda Bicim:"telefon" ya da adindan anlasilir. */
const telefonKolonu = (kolon: KolonMeta) =>
  kolon.bicim === 'telefon' || /telefon|ceptel|gsm|faks/i.test(kolon.ad);

export function bicimle(deger: unknown, kolon: KolonMeta): string {
  if (deger === null || deger === undefined) return '';
  // Telefon HER LISTEDE ayni bicimde (genel kural) - kolon tipi metin oldugu
  //   icin switch'e girmeden once yakalanir.
  if (telefonKolonu(kolon)) return telefonBicimle(deger);

  switch (kolon.tip) {
    case 'para': {
      const s = Number(deger);
      if (!Number.isFinite(s)) return String(deger);
      // Kolon 4 haneli bicim istediyse (carpan/kur kolonlari "#,##0.0000")
      //   2 haneye EZILMEZ: 7,0092'yi 7,01 gostermek kullaniciyi yaniltir.
      return kolon.bicim?.includes('0000') ? para4.format(s) : para.format(s);
    }
    case 'sayi': {
      const s = Number(deger);
      if (!Number.isFinite(s)) return String(deger);
      // Yuzde kolonu (basvuru tamamlanmasi): deger 0-100 tam sayi gelir,
      //   ekranda "%" ile okunur. Bolme/carpma YOK - sunucu zaten yuzde
      //   gonderiyor, burada ikinci bir hesap iki kaynak demek olurdu.
      if (kolon.bicim === 'yuzde') return `%${sayi.format(s)}`;
      const hane = bicimHanesi(kolon.bicim);
      return hane > 0 ? ondalikSayi(s, hane) : sayi.format(s);
    }
    case 'tarih': {
      const metin = String(deger);
      const parca = tarihParcala(metin);
      if (parca) {
        const sadeceTarih = `${parca.gun}.${parca.ay}.${parca.yil}`;
        return kolon.bicim?.includes('HH') && parca.saat
          ? `${sadeceTarih} ${parca.saat}:${parca.dakika ?? '00'}`
          : sadeceTarih;
      }

      const t = new Date(metin);
      if (Number.isNaN(t.getTime())) return String(deger);
      return kolon.bicim?.includes('HH') ? tarihSaatBicim.format(t) : tarih.format(t);
    }
    case 'mantik':
      return Number(deger) === 1 ? '✓' : '';
    default:
      return String(deger);
  }
}

/**
 * Ise giris tarihinden KIDEM metni: "3 yıl 2 ay".
 *
 * Ay farki gun duzeltmesiyle: ayin gunu henuz gelmediyse o ay SAYILMAZ
 * (25.03 girisli personel 10.06'da 2 ay kidemlidir, 3 degil).
 * Iki ekranda (PersonelKimlikOzet, TekOzluk) birebir ayni kod duruyordu.
 */
export function kidemMetni(tarihStr: string, bitisStr?: string | null): string | null {
  if (!tarihStr) return null;
  const giris = new Date(tarihStr);
  if (Number.isNaN(giris.getTime())) return null;
  // Isten cikis tarihi varsa kidem GIRIS-CIKIS arasidir (kullanici); yoksa
  //   bugune kadar isler.
  const bitis = bitisStr ? new Date(bitisStr) : null;
  const simdi = bitis && !Number.isNaN(bitis.getTime()) ? bitis : new Date();
  let ay = (simdi.getFullYear() - giris.getFullYear()) * 12
         + (simdi.getMonth() - giris.getMonth());
  if (simdi.getDate() < giris.getDate()) ay -= 1;
  if (ay < 0) return null;
  const yil = Math.floor(ay / 12);
  const kalanAy = ay % 12;
  return yil > 0 ? `${yil} yıl ${kalanAy} ay` : `${kalanAy} ay`;
}

/**
 * "2026-08-25T14:05:00" -> "25.08.2026". METINDEN keser, `new Date` ile
 * cevirmez: saat dilimi kaymasi gunu bir gun oteye atabiliyordu.
 */
export const gunMetni = (t?: string | null) =>
  (t ? t.slice(0, 10).split('-').reverse().join('.') : '—');

/**
 * "2026-08-23T14:05:00" -> "23.08.2026 14:05" (saat yoksa/00:00 ise yalniz
 * tarih). `gunMetni` ile ayni metin-kesme mantigi; farki saati de gostermesi.
 */
export function tarihSaat(ham: unknown): string {
  const metin = String(ham ?? '');
  if (!metin) return '';
  const gun = metin.slice(0, 10).split('-').reverse().join('.');
  const saat = metin.slice(11, 16);
  return saat && saat !== '00:00' ? `${gun} ${saat}` : gun;
}

/**
 * YEREL gunun ISO metni ("2026-08-23").
 *
 * `new Date().toISOString().slice(0,10)` KULLANMAYIN: UTC'ye cevirir, TR'de
 * aksam 03:00'ten sonra bir SONRAKI gunu yazar. Tarih kutulari, CSV dosya adi,
 * varsayilan belge tarihi - hepsi bu fonksiyondan gecmeli.
 */
export const bugunIso = (d: Date = new Date()) => yerelGun(d);

/** Verilen tarihin yerel "YYYY-MM-DD" metni (saat dilimine kaymadan). */
export function yerelGun(d: Date): string {
  const p = (n: number) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`;
}

/** datetime-local kutusunun bekledigi YEREL "YYYY-MM-DDTHH:mm" (UTC'ye kaymaz). */
export function yerelAnMetni(d: Date): string {
  const p = (n: number) => String(n).padStart(2, '0');
  return `${yerelGun(d)}T${p(d.getHours())}:${p(d.getMinutes())}`;
}

// ============================================================ sayi okuma ====
// EKRANDAN gelen metin ile SUNUCUDAN gelen ham deger AYNI SEKILDE COZULEMEZ;
// nokta birinde binlik ayraci, otekinde ondalik ayracidir. Ayni fonksiyonu
// ikisine de vermek gercek bir hataya yol acmisti (kayitli kasa islemi acilip
// yeniden kaydedilince tutar 100 katina cikiyordu). Bu yuzden IKI AYRI ad:

/**
 * EKRAN kutusundaki TURKCE sayiyi cozer: nokta binlik, virgul ondalik
 * ("1.234,56" -> 1234.56). Cozulemezse 0.
 *
 * Sunucudan gelen ham degeri ("1234.56") BURAYA VERMEYIN - `hamSayi` kullanin
 * ya da once `tutarMetni` ile ekran bicimine cevirin.
 *
 * UC OKUYUCU, UC KAYNAK (karistirilirsa sessizce yanlis sayi cikar):
 *   hamSayi  - SUNUCU/JSON degeri, binlik ayraci YOK  ("1234.56")
 *   sayiOku  - GRID/FORM kutusu, Turkce bicim         ("1.234,56")
 *   tutarOku - kullanicinin SERBEST yazdigi tutar     ("1.234,56 ₺", "1234")
 */
export const sayiOku = (metin: unknown) =>
  Number(String(metin ?? '').replace(/\./g, '').replace(',', '.')) || 0;

/**
 * KULLANICININ YAZDIGI TUTAR: ekran bicimi, para isareti ve bosluk serbest.
 * "50.000,00", "50.000,00 ₺", "50 000,00", "50000" hepsi ayni sayidir.
 *
 * `sayiOku` yalniz temiz ekran bicimini cozer; kutuya para isareti ya da
 * bosluk karisinca 0 donuyor ve cagiran "Tutar sıfırdan büyük olmalı" diyordu
 * (kullanici, POS tahsilati). Once sayi disi her sey atilir, sonra ayni kural
 * uygulanir: nokta binlik, virgul ondalik.
 */
export const tutarOku = (metin: unknown): number => {
  const t = String(metin ?? '').replace(/[^\d.,-]/g, '');
  if (t === '') return 0;
  // Yalniz NOKTA varsa ve son grup 3 haneyse binlik ayracidir ("50.000");
  //   aksi halde ondalik kabul edilir ("50.5").
  const noktaBinlik = !t.includes(',') && /^-?\d{1,3}(\.\d{3})+$/.test(t);
  const sade = t.includes(',') || noktaBinlik
    ? t.replace(/\./g, '').replace(',', '.')
    : t;
  const n = Number(sade);
  return Number.isFinite(n) ? n : 0;
};

/** `sayiOku`nun bos/gecersiz degeri 0 yerine null dondurdugu surumu. */
export const sayiOkuNull = (metin: unknown): number | null => {
  const t = String(metin ?? '').trim();
  if (t === '') return null;
  const s = Number(t.replace(/\./g, '').replace(',', '.'));
  return Number.isFinite(s) ? s : null;
};

/**
 * SUNUCUDAN/JSON'dan gelen sayiyi cozer ("1234.56" ya da "1234,56" - ikisi de
 * ondalik). Binlik ayraci beklenmez. Cozulemezse 0.
 */
export const hamSayi = (deger: unknown) =>
  Number(String(deger ?? '').replace(',', '.')) || 0;

/** `hamSayi`nin bos/gecersiz degeri 0 yerine null dondurugu surumu. */
export const hamSayiNull = (deger: unknown): number | null => {
  const metin = String(deger ?? '').trim();
  if (metin === '') return null;
  const n = Number(metin.replace(',', '.'));
  return Number.isFinite(n) ? n : null;
};

/**
 * Ham/JSON tutari EKRAN bicimine cevirir ("1234.5600" -> "1234,56").
 * `sayiOku`nun tersi: ikisi bir arada gidip gelen deger bozulmasin.
 */
export const tutarMetni = (ham: string | number | undefined | null): string => {
  if (ham === null || ham === undefined || ham === '') return '';
  const n = Number(String(ham).replace(',', '.'));
  return Number.isFinite(n) ? n.toFixed(2).replace('.', ',') : '';
};

/**
 * ISO tarihini gun.ay.yil olarak yazar ("2026-09-11" -> "11.09.2026").
 * Cikti ekranlarinda (etiket, lab raporu, radyoloji raporu) ayni ayri
 * kopyalanmisti - tek yerde.
 */
export const gunNokta = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '';
};

/** Dogum tarihinden YAS (tam yil). Gecersiz tarihte bos doner. */
export const yasMetni = (dogum: unknown): string => {
  const m = String(dogum ?? '').slice(0, 10);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(m)) return '';
  const d = new Date(m), b = new Date();
  let y = b.getFullYear() - d.getFullYear();
  const ay = b.getMonth() - d.getMonth();
  if (ay < 0 || (ay === 0 && b.getDate() < d.getDate())) y--;
  return String(y);
};
