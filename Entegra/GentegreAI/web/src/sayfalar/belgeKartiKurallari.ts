import type { AcikSatir, Kosul } from '../api/sozlesme';
import { onerilenTutar, matrahaCevir, kurusTamamla } from './belgeDonusumHesap';

/**
 * BELGE KARTININ IS KURALLARI - saf fonksiyonlar.
 *
 * Karttan ayrildilar cunku hepsi "veriden karar uret" isi yapiyor ve ekranin
 * state'ine ihtiyaci yok. Boylece TESTLENEBILIYORLAR: kart 2000 satirlik bir
 * bilesen ve icindeki kural bir daha kimse tarafindan dogrulanamiyordu.
 *
 * Buradaki her kural bir kullanici karariyla kondu; degistirilirse ilgili test
 * de degismeli (test/belgeKartiKurallari.test.ts).
 */

/** Donusum olcusu: kalan MIKTAR mi, tahsil edilen/kalan TUTAR mi (352). */
export type DonusumOlcusu = 'adet' | 'tutar';

/** api.belgeDonustur'un bekledigi satir govdesi. */
export interface DonusumSatiri {
  satirId: number;
  miktar: number;
  tutar?: number;
}

/**
 * PROVIZYON / PAY PAYLASIMI VAR MI (kullanici): yalniz odeyen kurumun turu
 * ÖSS (2) ya da SGK (3) iken. "Özel (Ücretli)" de bir KURUMDUR ama hasta kendi
 * oder - orada pay kolonlari, provizyon sekmesi ve ⚖ dugmesi anlamsizdir.
 */
export function provizyonVarMi(
  kurumlar: { id: number; tur?: number }[],
  odeyenKurumId: number | null,
): boolean {
  const k = kurumlar.find(x => x.id === odeyenKurumId);
  return k?.tur === 2 || k?.tur === 3;
}

/**
 * HIZLI DONUSUM SATIRLARI (kullanici: Fis / Fatura / Tahakkuk dugmeleri).
 *
 *   adet  -> her acik satirin KALAN MIKTARI (klasik siparis -> fatura)
 *   tutar -> fis/faturada TAHSIL EDILEN kadar, tahakkukta (17) kalanin TAMAMI
 *
 * Tutar olcusunde ekran KDV DAHIL calisir, API MATRAH ister - cevrim
 * belgeDonusumHesap'ta (tek kaynak).
 */
export function donusumSatirlari(
  acik: AcikSatir[],
  hedefTur: number,
  olcu: DonusumOlcusu,
  pay = 1,
): DonusumSatiri[] {
  if (olcu === 'tutar') {
    const secim = acik
      .map(s => ({ s, dahil: onerilenTutar(s, hedefTur, pay) }))
      // Kurusun altindaki artiklar satir acmaya degmez.
      .filter(x => x.dahil > 0.005)
      .map(x => ({ s: x.s, dahil: x.dahil, matrah: matrahaCevir(x.s, x.dahil) }));
    // Satir bazinda asagi yuvarlanan kuruslar geri konur (hedefi asmadan).
    kurusTamamla(secim, secim.reduce((t, x) => t + x.dahil, 0));
    return secim.map(x => ({ satirId: x.s.satirId, miktar: Number(x.s.miktar),
                             tutar: x.matrah }));
  }
  return acik
    .filter(s => Number(s.kalanMiktar) > 0)
    .map(s => ({ satirId: s.satirId, miktar: Number(s.kalanMiktar) }));
}

/**
 * POS TAHSILATI SONRASI FIS (355): tahsil edilen kadar satis fisi.
 * Donusum satirlariyla AYNI hesap - "tutar" olcusunun fis (16) hali.
 * Toplam, kullaniciya sorulan onay metninde gosterilir.
 */
export function posFisiSecimi(acik: AcikSatir[], ustSinir?: number):
    { satirlar: DonusumSatiri[]; toplamDahil: number } {
  return sinirliDonusumSecimi(acik, 16, ustSinir);
}

/**
 * TUTAR SINIRLI donusum secimi: satirlara sirayla dagitir, sinir dolunca
 * durur. Sinir verilmezse her satirin onerilen tutarinin tamami alinir.
 * Basvuruda "Belge Kes" ve POS sonrasi otomatik fis bunu kullanir.
 */
export function sinirliDonusumSecimi(acik: AcikSatir[], hedefTur: number,
                                     ustSinir?: number):
    { satirlar: DonusumSatiri[]; toplamDahil: number } {
  // UST SINIR = tetikleyen POS tahsilatinin tutari (kullanici karari).
  //   Sinirsizken satira DAGITILMIS tum tahsilat belgeleniyordu: onceki
  //   bir tahsilattan kalan 90,00 TL de fise giriyor ve 2.200 cekilen
  //   POS'a 2.290 TL'lik fis kesiliyordu (basvuru 114317). Eski tahsilatin
  //   belgelenmemis kalani yerinde durur - elle tahakkuk/fis ile kapatilir.
  let kalanSinir = ustSinir === undefined ? Number.POSITIVE_INFINITY : ustSinir;
  const secim: { s: AcikSatir; dahil: number }[] = [];
  for (const s of acik) {
    if (kalanSinir <= 0.005) break;
    const dahil = Math.min(onerilenTutar(s, hedefTur, 1), kalanSinir);
    if (dahil <= 0.005) continue;
    secim.push({ s, dahil });
    kalanSinir -= dahil;
  }
  // Satir bazinda asagi yuvarlanan kuruslar toplamda gorunur bir eksik yapar
  //   (kullanici: POS 75.000 -> fis 74.999,99); hedefi asmadan geri konur.
  const matrahli = secim.map(x => ({ s: x.s, matrah: matrahaCevir(x.s, x.dahil) }));
  const hedef = secim.reduce((t, x) => t + x.dahil, 0);
  kurusTamamla(matrahli, hedef);
  return {
    satirlar: matrahli.map(x => ({ satirId: x.s.satirId, miktar: Number(x.s.miktar),
                                   tutar: x.matrah })),
    toplamDahil: hedef,
  };
}

/**
 * HIZLI NAKIT KASASI SIRASI (200 `hesap.atama`, kullanici: ayri ayar YOK):
 *   1) oturumu acan kullaniciya ATANMIS kasa
 *   2) yoksa atamasi "Ana Kasa" (-1) olan kasa
 *   3) o da yoksa herhangi bir aktif yerel para kasasi
 * Her adim bir liste filtresi olarak doner; cagiran sirayla dener.
 */
export function kasaAramaSirasi(kullaniciId: number | null, yerelPara: string): Kosul[] {
  const taban: Kosul[] = [
    { alan: 'tur', op: 'esit', deger: 'K' },
    { alan: 'durum', op: 'esit', deger: 1 },
    { alan: 'dovizCinsi', op: 'esit', deger: yerelPara },
  ];
  const atamali = (atama: number): Kosul =>
    ({ op: 'and', kosullar: [...taban, { alan: 'atama', op: 'esit', deger: atama }] });

  return [
    ...(kullaniciId ? [atamali(kullaniciId)] : []),
    atamali(-1),
    { op: 'and', kosullar: taban },
  ];
}

/**
 * GELIS SEKLI, gonderen secimine baglidir (kullanici):
 *   gonderen secildi -> 3 "Sevkli"
 *   gonderen yok     -> 1 "Kendi imkânıyla"
 * Ikisi de ACIK eylemdir; kullanici sonra ambulans/kurum aracina cevirebilir.
 */
export function gelisSekliKarari(gonderenVar: boolean): 1 | 3 {
  return gonderenVar ? 3 : 1;
}

/**
 * ACIK BORC: ucretlendirme genel toplami - tahsilat. Kalem girilirken canli
 * onizleme toplami, satir yoksa sunucunun kayitli toplami kullanilir.
 * Eksiye dusmez (fazla tahsilatta 0) - hizli tahsilat tutari bundan gelir.
 */
/**
 * ACIK BELGE (495): ucretin faturaya/tahakkuka HENUZ donusmemis kismi.
 *
 * Kalan sunucudan okunmaz, ucret toplamindan DUSULUR: kart uzerinde yeni
 * satir eklendiginde (henuz kaydedilmemisken) serit ANINDA dogru rakami
 * gostersin - kullanici "daha hiç belge kaydı yok ama 0 yazıyor" dedi.
 * Donusen tutar sunucudan gelir (KDV dahil, kapatilan kovalar).
 */
export function acikBelgeHesapla(
  satirSayisi: number, onizlemeGenel: number, kayitliGenel: number, donusen: number,
): number {
  const genel = satirSayisi > 0 ? onizlemeGenel : kayitliGenel;
  return Math.max(0, Math.round((genel - donusen) * 100) / 100);
}

export function acikBorcHesapla(
  satirSayisi: number, onizlemeGenel: number, kayitliGenel: number, tahsilToplam: number,
): number {
  const genel = satirSayisi > 0 ? onizlemeGenel : kayitliGenel;
  return Math.round((genel - tahsilToplam) * 100) / 100;
}
