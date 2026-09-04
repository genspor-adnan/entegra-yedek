import { hamSayi } from '../../bilesenler/bicim';
import { satirTutari, type SatirDurumu } from '../belgeSatir';

/**
 * PROVIZYON / ODEME PAYLASIMI HESABI (289/291) - saf fonksiyonlar.
 *
 * Kart bilesenin icindeyken bu iki formul dogrulanamiyordu; oysa yanlis pay
 * dogrudan PARA hatasi demek: kuruma fazla, hastadan eksik yazilir ve hata
 * ancak faturalamada goze carpar.
 *
 * IKI MOD (291):
 *   KARSILAMA (1) - ozel sigorta: kurum tutarin %X'ini karsilar, kalani hasta.
 *   KATILIM  (2) - SGK: hastadan SABIT katilim payi alinir, kalani kuruma.
 * Ikisinde de satir tutari once iskontolarla hesaplanir (satirTutari), yani
 * ekranda gorulen tutarla ayni.
 */

/** Ekranda gosterilen ozet - "hastadan X TL" mesaji buradan yazilir. */
export interface PaylasimSonucu {
  satirlar: SatirDurumu[];
  toplamHasta: number;
  toplamKurum: number;
}

/**
 * KARSILAMA ORANI (289): kurum tutarin %oran'ini oder, kalani hastaya kalir.
 * Oran 0 verilirse tamami hastaya yazilir ("kendi öder").
 * Yuvarlama: kurum payi kurusa yuvarlanir, hasta payi KALANDIR - iki payin
 * toplami her zaman satir tutarina esit olur (kurus kaybi olmaz).
 */
export function karsilamaUygula(satirlar: SatirDurumu[], oranHam: number): PaylasimSonucu {
  const oran = Math.min(100, Math.max(0, oranHam));
  let toplamHasta = 0, toplamKurum = 0;

  const yeni = satirlar.map(r => {
    const tutar = satirTutari(hamSayi(r.adet), hamSayi(r.birimFiyat), r.iskonto, r.iskonto2);
    const kurum = Math.round(tutar * oran) / 100;
    const hasta = tutar - kurum;
    toplamKurum += kurum;
    toplamHasta += hasta;
    return { ...r, karsilama: String(oran),
             kurumTutar: kurum.toFixed(2), hastaTutar: hasta.toFixed(2) };
  });

  return { satirlar: yeni, toplamHasta, toplamKurum };
}

/**
 * KATILIM PAYI (291, SGK): hastadan sabit tutar alinir, KALANI kuruma yazilir.
 *
 * `elle` verilmezse her satir KENDI katilim payiyla bolunur (fiyat listesinden
 * kalemle birlikte gelir) - kullanici tek tip tutar dayatmak isterse yazar.
 * Katilim payi satir tutarini ASAMAZ: ucuz kalemde hastadan tutardan fazlasini
 * istemek yanlis olurdu.
 */
export function katilimUygula(satirlar: SatirDurumu[], elle: number | null): PaylasimSonucu {
  let toplamHasta = 0, toplamKurum = 0;

  const yeni = satirlar.map(r => {
    const tutar = satirTutari(hamSayi(r.adet), hamSayi(r.birimFiyat), r.iskonto, r.iskonto2);
    const katki = Math.min(elle ?? hamSayi(r.katkiTutar ?? '0'), tutar);
    const kurum = tutar - katki;
    toplamHasta += katki;
    toplamKurum += kurum;
    return { ...r, karsilama: '0', katkiTutar: String(katki),
             kurumTutar: kurum.toFixed(2), hastaTutar: katki.toFixed(2) };
  });

  return { satirlar: yeni, toplamHasta, toplamKurum };
}
