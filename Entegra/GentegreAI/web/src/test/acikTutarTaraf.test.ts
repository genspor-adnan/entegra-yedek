import { describe, it, expect } from 'vitest';
import {
  acikTahsilatTaraflara, acikBelgeTaraflara, paylasimliKurum, tarafPayi,
} from '../sayfalar/belgeKartiKurallari';
import type { SatirDagilimi } from '../sayfalar/belgeSatir';

/**
 * PAYLASIMLI BASVURUDA ACIK TUTAR TARAFA GORE (kullanıcı: "kurum tipi TTB
 * (sigorta) veya SUT (SGK) olursa Açık Tahsilat iki satır olur - hastadan ve
 * kurumdan; aynısı Açık Belge için de").
 *
 * Kovalar SUNUCUDAN gelir; buradaki kural yalnız TOPLAMA ve HANGI KOVANIN
 * KIME ait olduğudur - yanlış eşleme, memurun yanlış taraftan para istemesi
 * demek.
 */
const bos: SatirDagilimi = {
  rota: 5, sgk: 0, oss: 0, hastaProvizyon: 0, hastaEkKatki: 0, sgkKatilimPayi: 0,
  sgkKapatilan: 0, ossKapatilan: 0, hastaProvizyonKapatilan: 0, hastaEkKatkiKapatilan: 0,
  sgkTahsil: 0, ossTahsil: 0, hastaProvizyonTahsil: 0, hastaEkKatkiTahsil: 0,
  sgkKatilimTahsil: 0, sgkListe: 0, huvListe: 0, sgkProvizyonNo: '', elle: 0,
  sgkListeElle: 0,
} as SatirDagilimi;

/** Satir: kovalar MATRAH, `kdv` orani serit brutlestirmesi icin. */
const satir = (d: Partial<SatirDagilimi>, kdv = 0) =>
  ({ dagilim: { ...bos, ...d }, kdv });

describe('açık tutarların tarafa göre ayrımı', () => {
  it('KDV DAHİL gösterilir: kovalar matrah, serit brüt (kullanıcı)', () => {
    // 1.000 TL'lik %10 KDV'li işlem: matrah 909,09 -> kurum 727,27 / hasta 181,82.
    //   Seritte 800 / 200 yazmalı - gridin Genel Toplam'ıyla tutsun.
    const s = [satir({ oss: 727.27, hastaProvizyon: 181.82 }, 10)];
    expect(acikTahsilatTaraflara(s)).toEqual({ hasta: 200, kurum: 800 });
    expect(acikBelgeTaraflara(s)).toEqual({ hasta: 200, kurum: 800 });
  });

  it('hasta payı = provizyon + ek katkı + SGK katılım payı; kurum payı = SGK + ÖSS', () => {
    const s = [satir({ sgk: 600, oss: 200, hastaProvizyon: 100, hastaEkKatki: 50,
                       sgkKatilimPayi: 20 })];
    expect(acikTahsilatTaraflara(s)).toEqual({ hasta: 170, kurum: 800 });
  });

  it('SGK katılım payına KDV EKLENMEZ (kullanıcı: "850 olması gerekirken 860")', () => {
    // TSS muayenesi %10 KDV: hasta ek katkısı 681,82 matrah -> 750 brüt,
    //   SGK katılım payı 100 TL SABİT (ciro dışı emanet, KDV'siz).
    //   Hastadan istenecek: 750 + 100 = 850. Katılımı da brütleştirmek 860
    //   veriyordu - hastadan 10 TL fazla istenirdi.
    const s = [satir({ sgk: 77.94, oss: 909.09,
                       hastaEkKatki: 681.82, sgkKatilimPayi: 100 }, 10)];
    expect(acikTahsilatTaraflara(s).hasta).toBe(850);
    // Katılım payı BELGEYE girmez: açık belgede yalnız ek katkı görünür.
    expect(acikBelgeTaraflara(s).hasta).toBe(750);
  });

  it('tahsil edilen kısım açık tahsilattan düşer - taraf karışmaz', () => {
    const s = [satir({ sgk: 600, oss: 0, hastaProvizyon: 100, hastaEkKatki: 50,
                       sgkTahsil: 600, hastaProvizyonTahsil: 100 })];
    expect(acikTahsilatTaraflara(s)).toEqual({ hasta: 50, kurum: 0 });
  });

  it('TAHSİL sayaçları BRÜT, kovalar MATRAH: ikisi ayrı işlenir', () => {
    // 200 TL'lik hasta payı (matrah 181,82 · %10) ve 100 TL tahsilat:
    //   kalan 100 olmalı. Tahsilatı da brütleştirmek 110 sayıp 90 veriyordu.
    const s = [satir({ hastaProvizyon: 181.82, hastaProvizyonTahsil: 100 }, 10)];
    expect(acikTahsilatTaraflara(s).hasta).toBe(100);
    // Açık BELGE'de iki taraf da matrah: faturalanmamış kısım brütleşir.
    const t = [satir({ oss: 727.27, ossKapatilan: 727.27,
                       hastaProvizyon: 181.82 }, 10)];
    expect(acikBelgeTaraflara(t)).toEqual({ hasta: 200, kurum: 0 });
  });

  it('KURUM tahakkuk edilince açık TAHSİLATTAN da düşer (alacak cariye geçti)', () => {
    const s = [satir({ oss: 727.27, ossKapatilan: 727.27, hastaProvizyon: 181.82 }, 10)];
    expect(acikTahsilatTaraflara(s)).toEqual({ hasta: 200, kurum: 0 });
    expect(acikBelgeTaraflara(s)).toEqual({ hasta: 200, kurum: 0 });
    // HASTA payında fiş/fatura kesilmesi açık tahsilatı düşürmez - para yine
    //   bu ekrandan alınır.
    const t = [satir({ hastaProvizyon: 181.82, hastaProvizyonKapatilan: 181.82 }, 10)];
    expect(acikTahsilatTaraflara(t).hasta).toBe(200);
    expect(acikBelgeTaraflara(t).hasta).toBe(0);
  });

  it('açık BELGE faturalanan (kapatılan) kısmı düşer', () => {
    const s = [satir({ sgk: 600, hastaEkKatki: 400,
                       sgkKapatilan: 600, hastaEkKatkiKapatilan: 100 })];
    expect(acikBelgeTaraflara(s)).toEqual({ hasta: 300, kurum: 0 });
  });

  it('SGK KATILIM PAYI açık belgeye girmez (ciro dışı emanet) ama tahsilata girer', () => {
    const s = [satir({ hastaProvizyon: 0, sgkKatilimPayi: 25 })];
    expect(acikBelgeTaraflara(s)).toEqual({ hasta: 0, kurum: 0 });
    expect(acikTahsilatTaraflara(s)).toEqual({ hasta: 25, kurum: 0 });
  });

  it('KURUŞ ARTIĞI BİRİKMEZ: her satır ayrı yuvarlanır', () => {
    // Üç satırın hasta payı 181,82 + 90,91 + 181,82 (%10): brütleri
    //   200 + 100 + 200 = 500,00. Önce toplayıp sonra brütleştirmek 500,01
    //   veriyordu - belgenin kendi toplamıyla tutmuyordu.
    const s = [satir({ hastaProvizyon: 181.82 }, 10),
               satir({ hastaProvizyon: 90.91 }, 10),
               satir({ hastaProvizyon: 181.82 }, 10)];
    expect(acikTahsilatTaraflara(s).hasta).toBe(500);
  });

  it('dağılımı olmayan satır (henüz kaydedilmemiş) sıfır sayılır', () => {
    expect(acikTahsilatTaraflara([{}, satir({ sgk: 100 })]))
      .toEqual({ hasta: 0, kurum: 100 });
  });

  it('serit yalnız ÖSS (2) ve SGK (3) kurumunda ikiye bölünür', () => {
    const k = [{ id: 1, tur: 1 }, { id: 2, tur: 2 }, { id: 3, tur: 3 }, { id: 4, tur: 4 }];
    expect(paylasimliKurum(k, 2)).toBe(true);
    expect(paylasimliKurum(k, 3)).toBe(true);
    expect(paylasimliKurum(k, 1)).toBe(false);
    expect(paylasimliKurum(k, 4)).toBe(false);
    expect(paylasimliKurum(k, null)).toBe(false);
  });
});

describe('tarafın açık kovası (hasta tahakkuku özel hastada da çalışır)', () => {
  it('ÖSS hastasında hasta payı PROVİZYON kovası (1), kurum payı SİGORTA (3)', () => {
    const s = [{ satirId: 1, kdv: 10, hastaProvizyonKalan: 181.82, hastaEkKatkiKalan: 0,
                 ossKalan: 727.27, sgkKalan: 0 }] as unknown as Parameters<typeof tarafPayi>[0];
    expect(tarafPayi(s, 'hasta')).toBe(1);
    expect(tarafPayi(s, 'kurum')).toBe(3);
  });

  it('ÖZEL (ücretli) hastada hasta payı EK KATKI kovası (4) - sabit 1 boş dönerdi', () => {
    const s = [{ satirId: 1, kdv: 10, hastaProvizyonKalan: 0, hastaEkKatkiKalan: 909.09,
                 ossKalan: 0, sgkKalan: 0 }] as unknown as Parameters<typeof tarafPayi>[0];
    expect(tarafPayi(s, 'hasta')).toBe(4);
    // Kurum tarafı yok: 0 döner, çağıran "belgelenecek pay kalmadı" der.
    expect(tarafPayi(s, 'kurum')).toBe(0);
  });

  it('SGK hastasında kurum payı SGK kovası (2)', () => {
    const s = [{ satirId: 1, kdv: 10, hastaProvizyonKalan: 0, hastaEkKatkiKalan: 50,
                 ossKalan: 0, sgkKalan: 450 }] as unknown as Parameters<typeof tarafPayi>[0];
    expect(tarafPayi(s, 'kurum')).toBe(2);
    expect(tarafPayi(s, 'hasta')).toBe(4);
  });
});
