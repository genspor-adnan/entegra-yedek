import type { AcikSatir, Kosul } from '../api/sozlesme';
import { satirTutari, type SatirDagilimi } from './belgeSatir';
import { hamSayi } from '../bilesenler/bicim';
import { bruta } from './belgeKarti/kdvModu';
import { onerilenTutar, payKalanDahil, matrahaCevir, kurusTamamla }
  from './belgeDonusumHesap';
import { TAHAKKUK_TURLERI } from './belgeTuru';
import { DONUSUM_KOVA_SIRASI, KOVA_HASTA_PROVIZYON, KOVA_HASTA_EK_KATKI,
         KOVA_SGK, KOVA_OSS }
  from './belgeKarti/dagilimKovalari';

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
  /** API'nin bekledigi MATRAH. */
  tutar?: number;
  /**
   * Ayni secimin KDV DAHIL karsiligi (kullanici: "500 TL fiş girdim ama
   * 499,99 kesti"): hedef satirin brut fiyati bundan yazilir, matrah brutten
   * turer ve girilen rakam belgede birebir cikar.
   */
  tutarKdvli?: number;
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
      // TUTAR OLCUSUNDE de olcu ACIK KALANDIR (kullanici): tahsilat
      //   yapilmadan da fatura/tahakkuk kesilebilir. `onerilenTutar` yalniz
      //   otomatik POS fisinde anlamli - orada tahsilat zaten sinirdir.
      .map(s => ({ s, dahil: TAHAKKUK_TURLERI.has(hedefTur) ? payKalanDahil(s, pay)
                                             : onerilenTutar(s, hedefTur, pay) }))
      // Kurusun altindaki artiklar satir acmaya degmez.
      .filter(x => x.dahil > 0.005)
      .map(x => ({ s: x.s, dahil: x.dahil, matrah: matrahaCevir(x.s, x.dahil) }));
    // Satir bazinda asagi yuvarlanan kuruslar geri konur (hedefi asmadan).
    kurusTamamla(secim, secim.reduce((t, x) => t + x.dahil, 0));
    return secim.map(x => ({ satirId: x.s.satirId, miktar: Number(x.s.miktar),
                             tutar: x.matrah, tutarKdvli: x.dahil }));
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
    { satirlar: DonusumSatiri[]; toplamDahil: number; pay: number } {
  // POS FISINDE OLCU TAHSILATTIR: cekilen kadar fis kesilir.
  // PAY ACIK KOVADAN (kullanici: "2000 TL POS girdim, otomatik fiş
  //   oluşmadı"): sabit 1 (hasta provizyonu) varsayiliyordu; "Kurumu Öder"
  //   ya da ozel/indirimli tarifede kova HASTA EK KATKISI (4) oldugu icin
  //   secim bos donuyor ve fis SESSIZCE kesilmiyordu.
  const pay = donusumPayi(acik, 16);
  return { ...sinirliDonusumSecimi(acik, 16, ustSinir, 'tahsilat', pay), pay };
}

/**
 * DONUSTURULECEK PAY (kullanici: "butona basinca acik belge tutari gelsin"):
 * hasta ve kurum kovalarindan HANGISI ACIKSA o. Ikisi de aciksa hedef karar
 * verir - tahakkuk kuruma, fis/fatura hastaya. Sabit "hasta payi" varsayimi,
 * tamami kuruma tahakkuk eden anlasmali kurum basvurusunda sifir veriyordu.
 */
export function donusumPayi(acik: AcikSatir[], hedefTur: number): number {
  const topla = (pay: number) => acik.reduce((t, s) => t + payKalanDahil(s, pay), 0);
  // INCE KOVALAR (470) sirayla: hangisi aciksa donusum onun uzerinden gider.
  //   Tahakkukta once KURUM kovalari (SGK / sigorta), fis-faturada once
  //   HASTA kovalari denenir - kalani olmayan kova atlanir.
  const sira = TAHAKKUK_TURLERI.has(hedefTur)
    ? DONUSUM_KOVA_SIRASI.kurumOnce : DONUSUM_KOVA_SIRASI.hastaOnce;
  for (const p of sira) if (topla(p) > 0.005) return p;
  return KOVA_HASTA_PROVIZYON;
}

/**
 * TARAFIN ACIK KOVASI (kullanici: "hasta tahakkukunu da özel hasta tipinde
 * olabilir").
 *
 * "Hasta" ve "kurum" TEK KOVA DEGIL: özel (ücretli) işte hastanın payı EK
 * KATKI kovasinda (4), ÖSS/SGK'da PROVIZYON kovasinda (1) durur; kurum tarafi
 * da SGK (2) ya da sigorta (3) olabilir. Dugmeye sabit bir kova numarasi
 * baglamak, özel hastada "Hasta Tahakkuk"u bos sonuc verir hale getiriyordu.
 * Burada tarafin kovalari SIRAYLA denenir, KALANI olan ilki secilir.
 *
 * Kalan hicbir kovada yoksa 0 doner - cagiran "belgelenecek tutar kalmadi"
 * der; yanlis kovaya yazmaktansa sebebi soylemek dogru.
 */
export function tarafPayi(acik: AcikSatir[], taraf: 'hasta' | 'kurum'): number {
  const sira = taraf === 'hasta'
    ? [KOVA_HASTA_PROVIZYON, KOVA_HASTA_EK_KATKI]
    : [KOVA_SGK, KOVA_OSS];
  for (const p of sira)
    if (acik.reduce((t, s) => t + payKalanDahil(s, p), 0) > 0.005) return p;
  return 0;
}

/**
 * TUTAR SINIRLI donusum secimi: satirlara sirayla dagitir, sinir dolunca
 * durur. Sinir verilmezse her satirin onerilen tutarinin tamami alinir.
 * Basvuruda "Belge Kes" ve POS sonrasi otomatik fis bunu kullanir.
 */
export function sinirliDonusumSecimi(acik: AcikSatir[], hedefTur: number,
                                     ustSinir?: number,
                                     olcu: 'kalan' | 'tahsilat' = 'kalan',
                                     pay = 1):
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
    // OLCU (kullanici): elle "Belge Kes"te ACIK KALAN onerilir - "butona
    //   basinca acik belge tutari ne ise o gelecek"; tahsilat yapilmamis
    //   basvuruda tahsilata bakmak sifir veriyor ve dugme hicbir sey
    //   yapmiyormus gibi gorunuyordu. POS sonrasi otomatik fiste ise olcu
    //   TAHSILATTIR (cekilen kadar fis). Ust sinir her iki durumda gecerli.
    const oneri = olcu === 'tahsilat'
      ? onerilenTutar(s, hedefTur, pay) : payKalanDahil(s, pay);
    const dahil = Math.min(oneri, kalanSinir);
    if (dahil <= 0.005) continue;
    secim.push({ s, dahil });
    kalanSinir -= dahil;
  }
  // Satir bazinda asagi yuvarlanan kuruslar toplamda gorunur bir eksik yapar
  //   (kullanici: POS 75.000 -> fis 74.999,99); hedefi asmadan geri konur.
  // PAY da tasinir: kurus tamamlama o kovanin kalanini asmamali (bkz.
  //   `kurusTamamla`) - asarsa sunucu belgeyi hic olusturmuyor.
  const matrahli = secim.map(x => ({ s: x.s, matrah: matrahaCevir(x.s, x.dahil), pay }));
  const hedef = secim.reduce((t, x) => t + x.dahil, 0);
  kurusTamamla(matrahli, hedef);
  return {
    satirlar: matrahli.map((x, i) => ({ satirId: x.s.satirId, miktar: Number(x.s.miktar),
                                        tutar: x.matrah, tutarKdvli: secim[i]?.dahil })),
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

/**
 * BELGE ÖNİZLEME TOPLAMI (matrah / KDV / genel) - kart kaydedilmeden önce
 * seritte ve dip toplamda okunan rakam. Gerçek tutar sunucudan gelir; bu
 * yalnız "şu an ekranda ne var" sorusunun cevabıdır.
 *
 * KDV MATRAHI ORANLA ÇARPARAK DEĞİL, BRÜT − MATRAH (kullanıcı: "500 girdim,
 * önizlemede 500,01 göründü"). Satırın brütü kullanıcının yazdığı sayıdır
 * (`birimFiyatKdvli`); matrah ondan türetilip bir kez yuvarlandı - ters yöne
 * gitmek kuruşu geri getirmiyor (454,55 × 1,10 = 500,005 → 500,01).
 * Sunucu da böyle hesaplar (`BelgeDeposu.Yazma`): önizleme ile kayıt aynı
 * rakamı söylemeli.
 *
 * STOK FİŞİ VERGİSİZDİR: satır da sunucuya 0 KDV ile gider.
 */
export function belgeOnizlemesi(
  satirlar: readonly {
    adet: string; birimFiyat: string; iskonto: string; iskonto2: string;
    kdv: string; birimFiyatKdvli?: string;
  }[],
  stokFisiMi: boolean,
): { matrah: number; kdv: number; genel: number } {
  let matrah = 0, brut = 0;
  for (const s of satirlar) {
    const adet = hamSayi(s.adet);
    const fiyat = hamSayi(s.birimFiyat);
    matrah += stokFisiMi ? adet * fiyat
                         : satirTutari(adet, fiyat, s.iskonto, s.iskonto2);
    const brutFiyat = stokFisiMi ? fiyat
                    : (hamSayi(s.birimFiyatKdvli) || bruta(fiyat, s.kdv));
    brut += stokFisiMi ? adet * fiyat
                       : satirTutari(adet, brutFiyat, s.iskonto, s.iskonto2);
  }
  return { matrah, kdv: brut - matrah, genel: brut };
}

/**
 * KART BAŞLIĞI: "Başvuru #114377 — 2026-000000048".
 *
 * KAYIT ID'si BAŞLIKTA (kullanıcı): belge no iş numarasıdır (protokol, fatura
 * no) ve seriye/yıla göre TEKRAR EDEBİLİR; destek ya da kayıt izi sürerken
 * aranan şey kayıt kimliğidir. İkisi birlikte durur.
 *
 * GenoTIP'te aynı tür "Başvuru" adıyla açılır (279): tür kataloğundaki ad
 * "Satış Siparişi"dir, hasta ekranında o başlığı göstermek yanlış olurdu.
 */
export function kartBasligi({ basvuruMu, turAdi, mevcutBelge, kayitliId, belgeNo }: {
  basvuruMu: boolean; turAdi: string; mevcutBelge: boolean;
  kayitliId: number; belgeNo?: string | null;
}): string {
  const ad = basvuruMu ? 'Başvuru' : turAdi;
  if (!mevcutBelge) return ad;
  return `${ad} #${kayitliId}${belgeNo ? ` — ${belgeNo}` : ''}`;
}

export function acikBorcHesapla(
  satirSayisi: number, onizlemeGenel: number, kayitliGenel: number, tahsilToplam: number,
): number {
  const genel = satirSayisi > 0 ? onizlemeGenel : kayitliGenel;
  return Math.round((genel - tahsilToplam) * 100) / 100;
}


/**
 * PAYLASIMLI BASVURUDA ACIK TUTARLARIN TARAFA GORE AYRIMI (kullanıcı: "kurum
 * tipi TTB (sigorta) veya SUT (SGK) olursa Açık Tahsilat iki satır olur -
 * hastadan tahsilat ve kurumdan tahsilat; aynısı Açık Belge için de").
 *
 * Özel (ücretli) işte tek muhatap vardır - hasta. Sigorta/SGK anlaşmasında ise
 * aynı başvurunun bir kısmı hastadan, bir kısmı kurumdan tahsil edilir ve
 * faturası da ayrı kesilir. Tek rakam gösterip "300 TL açık" demek, memura
 * kimden isteyeceğini söylemiyordu.
 *
 * Kaynak SUNUCUNUN dağıtım kovalarıdır (470/492) - istemci yalnız toplar:
 *     hasta  = hasta provizyonu + hasta ek katkısı + SGK katılım payı
 *     kurum  = SGK + özel sigorta (ÖSS/TSS)
 * Açık tahsilat tahsil sayaçlarından, açık belge kapatma (faturalama)
 * sayaçlarından düşülür.
 */
/**
 * ÖDEME ROTASI - sunucudaki `fn_dagilim_rota`nın AYNASI (595).
 *
 *   1 Özel · 2 ÖSS · 3 TSS · 4 Karma · 5 SGK
 *
 * Kovaları yine SUNUCU böler; bu kopya yalnız EKRANIN neyi SORACAĞINA karar
 * verir - emekli işareti (SGK'nın ödediği rotalarda) ve "Katkı Fiyatı" kutusu
 * (yalnız ek katkı kovası olan TSS/SGK'da). Tek yerde durur: iki ekran aynı
 * soruyu iki farklı kuralla sormasın.
 */
export function dagilimRotasi(
  kurumTuru: number | null | undefined,
  altKurum: number | null | undefined,
  sgkKullan: number | null | undefined,
): number {
  const t = Number(kurumTuru ?? 1);
  if (t === 3) return 5;                       // SGK
  if (t !== 2) return 1;                       // Özel / kurumu öder
  // TSS ve KARMA: hasta SGK'yı kullanmak istemezse iş ÖSS gibi yürür (597,
  //   kullanıcı: "hasta SGK kullanılmasın deme hakkına sahip").
  const alt = Number(altKurum ?? 201);
  const sgkVar = Number(sgkKullan ?? 1) === 1;
  if (alt === 202) return sgkVar ? 3 : 2;      // TSS (tamamlayıcı)
  if (alt === 203) return sgkVar ? 4 : 2;      // Karma
  return 2;                                    // ÖSS
}

/** Hastanın ek katkı payı DOĞAN rotalar (595): yalnız TSS ve SGK. */
export const EK_KATKILI_ROTALAR = [3, 5];

/**
 * SAF SGK rotası (601). Bu rotada satırın TEK bir bedeli vardır: tarife = SUT
 * (fn_belge_varsayilan_liste saf SGK'da SUT listesini seçer, fn_belge_satir_dagit
 * da tutarı SUT + ek katkı olarak yazar). Bu yüzden ücret penceresinde ayrı bir
 * "SGK (SUT) Bedeli" kutusu gösterilmez - kullanıcı (SGK hastası için): "SGK
 * (SUT) Bedeli zaten birim fiyatta var, bir daha yazmaya gerek yok."
 *
 * TSS (3) ve Karma (4) bunun DIŞINDADIR: orada tarife bedeli ile SUT bedeli
 * gerçekten iki ayrı fiyattır (SGK SUT'u öder, sigorta aradaki farkı) ve kutu
 * gösterilmeye devam eder.
 */
export const SAF_SGK_ROTA = 5;

export interface TarafAcik { hasta: number; kurum: number }

/** Serit satiri: dagitim kovalari + satirin KDV orani. */
export interface AcikSatirGirdisi { dagilim?: SatirDagilimi; kdv?: number | string }

/**
 * KOVALAR MATRAHTIR, SERIT KDV DAHIL GOSTERIR (kullanici: "kdv dahil olsun").
 *
 * Dagitim kovalari KDV haric tutulur - kurum icmali ve hakedis matrah uzerinden
 * calisir. Kabul memurunun tahsil ettigi ve faturada gordugu rakam ise KDV'li
 * tutardir; serit matrahi yazinca 1.000 TL'lik islemde "181,82 + 727,27 = 909"
 * cikiyor ve toplam, gridin Genel Toplam'iyla tutmuyordu.
 *
 * BIRIMLER KARISIKTIR, dikkat: kovalar ve KAPATILAN (faturalanan) sayaclari
 * MATRAH, TAHSIL sayaclari ise BRUT'tur - kasaya giren para KDV'li girer.
 * Bu yuzden brutlestirme yalniz matrah kisma uygulanir; brut sayac oldugu gibi
 * dusulur. (Ikisini birlikte carpinca 100 TL tahsilat 110 sayiliyor ve
 * "200'den 100 aldim, kalan 90" gibi bir kalan cikiyordu.)
 *
 * UCUNCU BIR BIRIM DAHA VAR (593, kullanici: "açık tahsilatta 850 olması
 * gerekirken 860 yazıyor, SGK katılıma KDV mi ekliyor?"): SGK KATILIM PAYI
 * ciro disi bir EMANETTIR - hastadan ayarda yazan SABIT tutar (100 TL) alinir,
 * uzerine KDV binmez. Kovada da o haliyle durur; brutlestirilirse 110 olur ve
 * hastadan istenen tutar 10 TL fazla cikar. `ham` bu kovalar icindir.
 */
const topla = (ler: readonly AcikSatirGirdisi[],
               matrah: (d: SatirDagilimi) => number,
               brut: (d: SatirDagilimi) => number = () => 0,
               ham: (d: SatirDagilimi) => number = () => 0): number =>
  // YUVARLAMA SATIR SATIR: once brutlestir, sonra kurusa yuvarla, sonra topla.
  //   Toplayip sonunda yuvarlamak 181,82 + 90,91 + 181,82 gibi uc satirda
  //   "500,01" uretiyordu (her birinin x1,1 artigi birikiyor); belgenin kendi
  //   toplami ise satir satir yuvarlanmis 500,00.
  Math.round(ler.reduce((t, s) => t + (s.dagilim
    ? Math.round(matrah(s.dagilim) * (1 + (Number(s.kdv) || 0) / 100) * 100) / 100
      + ham(s.dagilim) - brut(s.dagilim)
    : 0), 0) * 100) / 100;

/** Açık TAHSİLAT - taraf başına (tahsil edilmemiş kısım). */
export function acikTahsilatTaraflara(
  satirlar: readonly AcikSatirGirdisi[],
): TarafAcik {
  return {
    // KATILIM PAYI KDV'SIZ EKLENIR (593): sabit emanet tutari, matrah degil.
    hasta: topla(satirlar,
      d => d.hastaProvizyon + d.hastaEkKatki,
      d => d.hastaProvizyonTahsil + d.hastaEkKatkiTahsil + d.sgkKatilimTahsil,
      d => d.sgkKatilimPayi),
    // KURUM PAYI BELGELENINCE ACIK TAHSILATTAN DUSER (kullanici: "kurum
    //   tahakkuku atınca hem kurum tahsilat sıfırlansın hem kurum belge
    //   sıfırlansın"): tahakkuk kesildigi anda alacak KURUM CARISINE gecer,
    //   takibi orada (cari ekstresi / kurum icmali) surer. Basvuru seridinde
    //   durmasi, hala buradan tahsil edilecekmis izlenimi veriyordu.
    //   HASTA TARAFI BOYLE DEGIL: fis/fatura kesilse de para hastadan bu
    //   ekranda alinir - orada yalniz TAHSILAT dusulur.
    kurum: topla(satirlar,
      d => d.sgk + d.oss - d.sgkKapatilan - d.ossKapatilan,
      d => d.sgkTahsil + d.ossTahsil),
  };
}

/** Açık BELGE - taraf başına (henüz faturaya/tahakkuka dönüşmemiş kısım). */
export function acikBelgeTaraflara(
  satirlar: readonly AcikSatirGirdisi[],
): TarafAcik {
  return {
    // SGK KATILIM PAYI belgeye girmez (ciro dışı emanet, 473): açık belgede
    //   sayılmaz, açık tahsilatta sayılır - hastadan yine de alınır.
    //
    // HER PARÇA AYRI BRÜTLEŞTİRİLİR (602, kullanıcı: "başvuru 85 açık belge
    //   500.01 oldu"). Kapatılan da matrahtır ama FARKI brütleştirmek kuruş
    //   kaydırıyordu: pay 1.363,64 · kapatılan 909,09 · KDV %10 iken
    //       (1363,64 − 909,09) × 1,1 = 500,005 → 500,01
    //   oysa iki tutarın kendi brütleri 1.500,00 ve 1.000,00 - açık tam
    //   500,00. Fark, iki YUVARLANMIŞ matrahın arasındaki artığın tekrar
    //   çarpılmasından doğuyor; her parçayı kendi brütüne çevirip çıkarmak
    //   belgenin ve tahsilatın gerçekten gördüğü rakamları kullanır.
    hasta: topla(satirlar, d => d.hastaProvizyon + d.hastaEkKatki)
         - topla(satirlar, d => d.hastaProvizyonKapatilan + d.hastaEkKatkiKapatilan),
    kurum: topla(satirlar, d => d.sgk + d.oss)
         - topla(satirlar, d => d.sgkKapatilan + d.ossKapatilan),
  };
}

/**
 * Serit iki satira BOLUNUR MU: ödeyen kurum ÖSS (2) ya da SGK (3) ise evet.
 * Özel (1) ve "Kurumu Öder" (4) tek muhataplıdır.
 */
export function paylasimliKurum(
  kurumlar: readonly { id: number; tur: number }[], kurumId: number | null,
): boolean {
  const t = Number(kurumlar.find(k => k.id === kurumId)?.tur ?? 0);
  return t === 2 || t === 3;
}
