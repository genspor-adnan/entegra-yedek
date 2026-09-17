import { hamSayi, para } from '../../bilesenler/bicim';
import { type SatirDurumu, satirTutari } from '../belgeSatir';
import { EK_KATKILI_ROTALAR, SAF_SGK_ROTA } from '../belgeKartiKurallari';
import {
  type FiyatGirdisi, brutBirimFiyat, gosterimTabani as tabanCoz,
  hedefBirimFiyat, iskontoKarsiligi, iskontoTabani as tabanIskonto,
  iskontoluBirim as iskontoluBirimCoz, iskontoVarMi,
} from './kalemFiyat';

/**
 * KALEM PENCERESİNİN TÜRETİLMİŞ DURUMU.
 *
 * ============ NEDEN AYRI DOSYA =======================================
 * Bu değerler 1000 satırlık bileşenin içine, JSX'in arasına dağılmıştı ve
 * birbirini besliyordu. Sıra bozulduğunda TypeScript uyarmıyor, tarayıcı
 * çalışma anında patlıyor: `fg()` `sgkKilitli`yi kapsıyordu, `brutFiyat`
 * satırı onu hemen çağırıyordu, `sgkKilitli` ise 40 satır aşağıdaydı -
 * *"Cannot access 'sgkKilitli' before initialization"* ve kullanıcıya
 * **beyaz ekran** (17.09.2026, başvuruda ücret eklerken).
 *
 * Burada hepsi TEK blokta ve bağımlılık sırasında; bir daha kaydıklarında
 * 60 satırlık bir fonksiyonda görünürler, 300 satır arayla değil. Üstelik
 * bileşen çizmeden test edilebilirler - `kalemDurumu.test.ts`.
 *
 * ============ DAVRANIŞ DEĞİŞMEDİ =====================================
 * Taşıma birebir: her ifade eski hâliyle, aynı sırada. Hesabın kendisi
 * zaten `kalemFiyat.ts`te; burası o saf fonksiyonlara HANGİ girdiyle
 * sorulacağına karar veren katman.
 */

export interface KalemGirdisi {
  /** Pencerenin düzenlediği satır (yerel state). */
  r: SatirDurumu;
  /** Belgenin rotası - satırın kendi rotası önceliklidir. */
  rota: number;
  /** 1 Özel · 2 TTB/HUV · 3 SUT. */
  tarifeTipi: number;
  /** Başvuru (kayıt kabul): fiyat her zaman KDV dahil girilir. */
  basvuruMu: boolean;
  yerelPara: string;
  kdvDahil: boolean;
  /** Kutuya yazılmış brüt metin (dahil modda kullanıcının yazdığı sayı). */
  brutMetni: string;
  girisIzlemi: boolean;
  cikisIzlemi: boolean;
}

export interface KalemDurumu {
  dovizli: boolean;
  adet: number;
  /** Satırın kendi rotası, yoksa belgeninki. */
  etkinRota: number;
  /** Saf SGK: birim fiyat ve katkı salt okunur, iskonto yalnız katkıya işler. */
  sgkKilitli: boolean;
  seciliCarpan: number;
  /** "2 Kutu = 24 Adet" karşılığı; ana birim seçiliyse null. */
  anaBirimMiktar: number | null;
  kur: number;
  dovizFiyat: number;
  /** Yerel birim fiyat (MATRAH). */
  fiyat: number;
  tutar: number;
  /** Saf fonksiyonların hepsinin aldığı girdi. */
  fg: FiyatGirdisi;
  brutFiyat: number;
  onizlemeTutar: number;
  katkiliTarife: boolean;
  /** SGK (SUT) bedeli kutusu çizilir mi - saf SGK'da çizilmez. */
  sutKutusu: boolean;
  kurumRotasi: boolean;
  fiyatKilitli: boolean;
  katkiVar: boolean;
  katkiTutari: number;
  iskontoTabani: number;
  onizlemeBirim: number;
  iskontoluMu: boolean;
  oranSayi: number;
  gosterimTabani: number;
  tutarIskontosu: number;
  hedefFiyat: number;
  /** İskonto tabanının adı - üst kutudaki etiketin aynısı. */
  tabanAdi: string;
  /** İzlemli stokta lot adımı gerekiyor mu. */
  izlemGerekli: boolean;
}

/**
 * Sıra ÖNEMLİ ve tek yerde: `etkinRota` → `sgkKilitli` → `fg` → ondan
 * türeyen her şey. Yukarıdan aşağı okunur.
 */
export function kalemDurumu(g: KalemGirdisi): KalemDurumu {
  const { r, tarifeTipi, basvuruMu, yerelPara, kdvDahil, brutMetni } = g;

  const dovizli = r.fiyatDovizi !== yerelPara && r.fiyatDovizi !== '';
  const adet = hamSayi(r.adet);

  // ROTA VE SGK KİLİDİ EN ÖNDE: `fg` bunları kapsıyor.
  const etkinRota = Number(r.rota ?? 0) || Number(g.rota ?? 0);
  const sgkKilitli = etkinRota === SAF_SGK_ROTA;

  const seciliCarpan = Number(r.birimCarpan ?? 1) || 1;
  const anaBirimMiktar = seciliCarpan !== 1 && adet > 0
    ? Math.round(adet * seciliCarpan * 1e6) / 1e6
    : null;

  const kur = dovizli ? hamSayi(r.kur) : 1;
  const dovizFiyat = hamSayi(r.dovizFiyat);
  // Yerel birim fiyat: dövizli kalemde döviz fiyatı × kur, değilse girilen.
  const fiyat = dovizli
    ? Math.round(dovizFiyat * kur * 100) / 100
    : hamSayi(r.birimFiyat);
  const tutar = satirTutari(adet, fiyat, r.iskonto, r.iskonto2);

  const fg: FiyatGirdisi = {
    fiyat, brutMetni, kdv: r.kdv, kdvDahil, sgkKilitli,
    katkiTutar: r.katkiTutar, iskonto: String(r.iskonto ?? '0'),
    iskonto2: String(r.iskonto2 ?? '0'),
  };

  const brutFiyat = brutBirimFiyat(fg);
  const onizlemeTutar = kdvDahil
    ? satirTutari(adet, brutFiyat, r.iskonto, r.iskonto2) : tutar;

  // Hasta ek katkısı yalnız TSS (3) ve SGK (5) rotasında doğar; ÖSS ve
  //   Karma'da hastanın payı karşılama oranından çıkar (595).
  const katkiliTarife = [2, 3].includes(Number(tarifeTipi))
                     && EK_KATKILI_ROTALAR.includes(etkinRota);
  // Saf SGK'da tarife = SUT olduğu için üstteki "Birim Fiyat" ile SUT kutusu
  //   AYNI sayıyı soruyordu (601) - orada çizilmez.
  const sutKutusu = !!r.sgkGerekli && etkinRota !== SAF_SGK_ROTA;

  const kurumRotasi = etkinRota > 0 && etkinRota !== 1;
  // Başvuruda üst kutu TÜM rollere kapalı: indirim ISKONTO satırından
  //   yapılır - orada oran olarak kayda geçer ve onaya tabidir (661/662).
  const fiyatKilitli = sgkKilitli || basvuruMu;
  const katkiVar = katkiliTarife && hamSayi(r.katkiTutar ?? '0') > 0;
  const katkiTutari = satirTutari(adet, hamSayi(r.katkiTutar ?? '0'),
                                  r.iskonto, r.iskonto2);

  return {
    dovizli, adet, etkinRota, sgkKilitli, seciliCarpan, anaBirimMiktar,
    kur, dovizFiyat, fiyat, tutar, fg, brutFiyat, onizlemeTutar,
    katkiliTarife, sutKutusu, kurumRotasi, fiyatKilitli, katkiVar, katkiTutari,
    iskontoTabani: tabanIskonto(fg),
    onizlemeBirim: iskontoluBirimCoz(fg),
    iskontoluMu: iskontoVarMi(fg),
    oranSayi: hamSayi(r.iskonto),
    gosterimTabani: tabanCoz(fg),
    tutarIskontosu: iskontoKarsiligi(fg),
    hedefFiyat: hedefBirimFiyat(fg),
    tabanAdi: sgkKilitli ? 'Katkı' : 'Birim Fiyat',
    izlemGerekli: (g.girisIzlemi || g.cikisIzlemi)
               && r.satirTur === 1 && r.izleme > 0,
  };
}

/**
 * SAĞ KUTUNUN GÖRÜNÜMÜ - modu kullanıcı seçer, bu yüzden ayrı fonksiyon.
 *
 * `sagMod` bir `useState` ve başlangıç değeri `oranSayi`dan geliyor; ikisini
 * tek fonksiyona koymak state'i türetilmiş değerin içine sokmak olurdu.
 *
 *   hazır oran     → salt görünüm iskonto TUTARI (200 TL'nin %10'u = 20)
 *   "Özel İskonto" → ORAN girilir (%)
 *   "Birim Fiyat"  → hedef BİRİM FİYAT girilir; fark orana çevrilir
 *
 * Üçü de aynı alanı (`iskonto`) yazar - satırda saklanan tek şey yüzdedir.
 */
export type SagMod = 'tutar' | 'oran' | 'fiyat';

export interface SagKutu {
  oranSecimi: string;
  deger: string;
  etiket: string;
  baslik: string;
}

export function sagKutuGorunumu(
  d: Pick<KalemDurumu, 'oranSayi' | 'gosterimTabani' | 'hedefFiyat'
                     | 'tutarIskontosu' | 'tabanAdi'>,
  sagMod: SagMod, iskontoMetni: string, yerelPara: string,
): SagKutu {
  return {
    oranSecimi: sagMod === 'oran' ? 'ozel'
      : sagMod === 'fiyat' ? 'fiyat'
      : (d.oranSayi > 0 ? String(d.oranSayi) : ''),
    deger: sagMod === 'oran'
      ? (d.oranSayi > 0 ? iskontoMetni : '')
      : sagMod === 'fiyat'
      ? (d.gosterimTabani > 0 ? para.format(d.hedefFiyat) : '')
      : (d.tutarIskontosu > 0.004 ? para.format(d.tutarIskontosu) : ''),
    etiket: sagMod === 'oran' ? '%' : yerelPara,
    // Hazır oranda sağdaki kutu o oranın PARA KARŞILIĞIDIR (salt okunur),
    //   girilen bir iskonto değil - başlığı "İskonto" demek kutuyu
    //   doldurulacak bir alan gibi gösteriyordu.
    baslik: sagMod === 'oran' ? 'Oran'
      : sagMod === 'fiyat' ? d.tabanAdi : 'Karşılığı',
  };
}
