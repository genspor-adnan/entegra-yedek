/**
 * BASVURU TAMAMLANMA SERIDI (370) - saf hesap.
 *
 * Kayit kabul memuru "bu basvuruda daha ne eksik" sorusunu tek bakista
 * gormeli: radyoloji istem kartindaki akis seridinin (310) basvuru karsiligi.
 * Yapilmayan asama GRI, yapilan kendi rengiyle dolar; hepsi dolunca (%100)
 * basvuru tamamlanmistir.
 *
 * SIRA ODEYEN KURUMA GORE DEGISIR (kullanici) - provizyonun yeri farkli:
 *   Özel (1)  Başvuru · Ücretlendirme · Tahsilat · Faturalama
 *   ÖSS  (2)  Başvuru · PROVIZYON · Ücretlendirme · Tahsilat · Faturalama
 *   SGK  (3)  Başvuru · Ücretlendirme · PROVIZYON · Tahsilat · Faturalama
 *
 * Ozel sigortada provizyon ONCE alinir (police kapsami belli olmadan islem
 * fiyatlanmaz); SGK'da once hizmet girilir, takip/provizyon o hizmetler
 * uzerinden alinir. Sira kozmetik degil, akisin kendisidir.
 */

/**
 * Kurum tipi - `taraf_kurum.tur` (467'de yine üçe indi).
 *
 * TSS ve KARMA ARTIK KURUM TÜRÜ DEĞİL: aynı sigorta şirketiyle ÖSS, TSS ve
 * Karma poliçe ayrı şartlarla çalışılır, bu yüzden poliçe türü SÖZLEŞMENİN
 * alt kurumudur (`belge_basvuru.alt_kurum`, 468/469). Türü dörde çıkarmak
 * aynı şirketi üç kez cari açmayı gerektiriyordu.
 */
export const KURUM_OZEL = 1;
export const KURUM_OSS = 2;
export const KURUM_SGK = 3;

/** `kurum.alt_kurum` (468): tur * 100 + kod. */
export const ALT_OSS = 201;
export const ALT_TSS = 202;
export const ALT_KARMA = 203;

/**
 * PROVIZYON DURUMU (kod listesi `provizyon.durum`):
 * 0 Alınmadı · 1 Onaylandı · 2 Reddedildi · 3 Kısmi Onay · 4 İptal.
 * Asama YALNIZ onay/kismi onayda tamamlanir - reddedilen provizyon isin
 * bittigi degil, DURDUGU anlamina gelir.
 */
const PROVIZYON_TAMAM = new Set([1, 3]);

export type AsamaKodu = 'basvuru' | 'provizyon' | 'ucret' | 'tahsilat' | 'fatura';

export interface Asama {
  kod: AsamaKodu;
  ad: string;
  /** CSS sinifi son eki: `.asama.kirmizi` gibi. */
  renk: 'kirmizi' | 'turuncu' | 'sari' | 'mavi' | 'yesil';
  tamam: boolean;
  /** Neden tamamlanmadigi (ipucu) - bos ise tamamlanmis demektir. */
  ipucu: string;
}

export interface AsamaGirdisi {
  /** taraf_kurum.tur; secilmemisse Özel akisi cizilir (hasta kendi oder). */
  kurumTuru?: number | null;
  /** belge_basvuru.alt_kurum (468): police turu / devredilen kurum. */
  altKurum?: number | null;
  /** Kayitli belge kimligi - 0 ise protokol henuz verilmedi. */
  kayitliId: number;
  /** Ucretlendirme genel toplami (KDV dahil). */
  ucretGenel: number;
  /** Belgeye baglanmis tahsilat toplami. */
  tahsilToplam: number;
  /** ÖSS'de ossDurum, SGK'da sgkDurum (kod listesi provizyon.durum). */
  provizyonDurum?: number | null;
  /** belge.kapanma_durum: 0 faturalanmadi · 1 kismi · 2 faturalandi. */
  kapanmaDurum?: number | null;
}

export interface AsamaSonucu {
  asamalar: Asama[];
  /** Tamamlanan asamalarin yuzdesi (0-100, tam sayi). */
  yuzde: number;
  tamamlandi: boolean;
}

/** Kurusun altindaki fark kapanmis sayilir - yuvarlama artigi asamayi acik birakmasin. */
const KURUS = 0.005;

export function basvuruAsamalari(g: AsamaGirdisi): AsamaSonucu {
  const tur = Number(g.kurumTuru ?? KURUM_OZEL);

  const basvuru: Asama = {
    kod: 'basvuru', ad: 'Başvuru', renk: 'kirmizi',
    tamam: g.kayitliId > 0,
    ipucu: g.kayitliId > 0 ? '' : 'Başvuru henüz açılmadı (protokol verilmedi).',
  };

  const provDurum = Number(g.provizyonDurum ?? 0);
  const provizyon: Asama = {
    kod: 'provizyon', ad: 'Provizyon', renk: 'turuncu',
    tamam: PROVIZYON_TAMAM.has(provDurum),
    ipucu: PROVIZYON_TAMAM.has(provDurum) ? ''
         : provDurum === 2 ? 'Provizyon REDDEDİLDİ.'
         : provDurum === 4 ? 'Provizyon iptal edildi.'
         : 'Provizyon alınmadı.',
  };

  const ucret: Asama = {
    kod: 'ucret', ad: 'Ücretlendirme', renk: 'sari',
    tamam: g.ucretGenel > 0,
    ipucu: g.ucretGenel > 0 ? '' : 'Hiç ücret kalemi girilmedi.',
  };

  // TAHSILAT tamam = ACIK BORC KALMADI. Ucret girilmeden tahsilat asamasi
  //   tamam SAYILMAZ: 0 TL'lik bir belge "tahsil edildi" degildir.
  const kalan = Math.round((g.ucretGenel - g.tahsilToplam) * 100) / 100;
  const tahsilat: Asama = {
    kod: 'tahsilat', ad: 'Tahsilat', renk: 'mavi',
    tamam: g.ucretGenel > 0 && kalan <= KURUS,
    ipucu: g.ucretGenel <= 0 ? 'Önce ücretlendirme yapılmalı.'
         : kalan > KURUS ? `Açık borç ${kalan.toFixed(2)} ₺.`
         : '',
  };

  const kapanma = Number(g.kapanmaDurum ?? 0);
  const fatura: Asama = {
    kod: 'fatura', ad: 'Belge Kesimi', renk: 'yesil',
    tamam: kapanma === 2,
    ipucu: kapanma === 2 ? ''
         : kapanma === 1 ? 'Kısmi belge kesildi.'
         : 'Fiş / fatura / tahakkuk kesilmedi.',
  };

  // ÖSS'de provizyon UCRETTEN ONCE, SGK tarafinda SONRA (kullanici).
  //   TSS ve KARMA'da da provizyon SGK'dan baslar: alt kurum bunu soyler,
  //   kurum turu degil (468).
  const alt = Number(g.altKurum ?? 0);
  const sgkTarafi = tur === KURUM_SGK || alt === ALT_TSS || alt === ALT_KARMA;
  const asamalar: Asama[] =
    tur === KURUM_OSS && !sgkTarafi
      ? [basvuru, provizyon, ucret, tahsilat, fatura]
  : tur === KURUM_OSS || tur === KURUM_SGK
      ? [basvuru, ucret, provizyon, tahsilat, fatura]
  : [basvuru, ucret, tahsilat, fatura];

  // Provizyonsuz kurumda (Özel) asama hic cizilmez - kullanilmayan asama
  //   yuzdeyi de bozmamali; bu yuzden yuzde CIZILEN asamalardan hesaplanir.
  const tamamSayisi = asamalar.filter(a => a.tamam).length;

  return {
    asamalar,
    yuzde: Math.round(tamamSayisi / asamalar.length * 100),
    tamamlandi: tamamSayisi === asamalar.length,
  };
}
