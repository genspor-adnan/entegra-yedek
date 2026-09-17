import { describe, it, expect } from 'vitest';
import { kalemDurumu, sagKutuGorunumu, type KalemGirdisi }
  from '../sayfalar/belgeKarti/kalemDurumu';
import { bosSatir, type SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * KALEM PENCERESİNİN TÜRETİLMİŞ DURUMU.
 *
 * Bu kararlar (hangi kutu kilitli, hangisi hiç çizilmez, iskonto neye işler)
 * 1000 satırlık bileşenin içindeydi ve ancak ekran açılarak denenebiliyordu;
 * bir sıra kayması çalışma anında beyaz ekran veriyordu. Saf modüle
 * taşındıktan sonra doğrudan ölçülebiliyorlar.
 *
 * Ölçülen şey HESAP DEĞİL (o `kalemFiyat.test.ts`te), saf fonksiyonlara
 * hangi girdiyle sorulduğu: rota/tarife bileşimine göre açılan dallar.
 */
const girdi = (r: Partial<SatirDurumu>, ek: Partial<KalemGirdisi> = {})
  : KalemGirdisi => ({
  r: { ...bosSatir(1), birimFiyat: '200', kdv: '10', ...r },
  rota: 0, tarifeTipi: 1, basvuruMu: false, yerelPara: 'TRY',
  kdvDahil: false, brutMetni: '', girisIzlemi: false, cikisIzlemi: false,
  ...ek,
});

describe('kalem durumu', () => {
  it('satırın rotası belgeninkini ezer', () => {
    expect(kalemDurumu(girdi({ rota: 5 }, { rota: 3 })).etkinRota).toBe(5);
    // Satırda rota yoksa belgeninki geçerli - yeni satır böyle açılır.
    expect(kalemDurumu(girdi({}, { rota: 3 })).etkinRota).toBe(3);
  });

  it('saf SGK: fiyat kilitli, SUT kutusu çizilmez, iskonto tabanı katkıdır', () => {
    const d = kalemDurumu(girdi(
      { rota: 5, sgkGerekli: true, katkiTutar: '50' }, { tarifeTipi: 3 }));
    expect(d.sgkKilitli).toBe(true);
    expect(d.fiyatKilitli).toBe(true);
    // Saf SGK'da tarife zaten SUT: üstteki kutu ile aynı sayıyı sormamak için
    //   SUT kutusu çizilmez (601).
    expect(d.sutKutusu).toBe(false);
    // İskonto SUT'a değil HASTA KATKISINA işler (fn_dagilim_coz).
    expect(d.iskontoTabani).toBe(50);
    expect(d.tabanAdi).toBe('Katkı');
  });

  it('TSS: SUT kutusu çizilir, katkı kutusu katkı varsa açılır', () => {
    const tam = kalemDurumu(girdi(
      { rota: 3, sgkGerekli: true, katkiTutar: '30' }, { tarifeTipi: 3 }));
    expect(tam.sutKutusu).toBe(true);
    expect(tam.katkiVar).toBe(true);
    expect(tam.sgkKilitli).toBe(false);
    // Katkısı OLMAYAN kalemde kutu açılmaz - yazılan rakam hiçbir yere gitmezdi.
    expect(kalemDurumu(girdi({ rota: 3, katkiTutar: '0' }, { tarifeTipi: 3 }))
      .katkiVar).toBe(false);
  });

  it('ÖSS ve Karma rotasında hasta ek katkısı doğmaz', () => {
    for (const rota of [2, 4]) {
      expect(kalemDurumu(girdi({ rota, katkiTutar: '30' }, { tarifeTipi: 3 }))
        .katkiVar).toBe(false);
    }
  });

  it('başvuruda üst kutu tüm rollere kapalı, ERP belgesinde açık', () => {
    expect(kalemDurumu(girdi({}, { basvuruMu: true })).fiyatKilitli).toBe(true);
    expect(kalemDurumu(girdi({})).fiyatKilitli).toBe(false);
  });

  it('kurum rotası: özel (1) ve rotasız hariç hepsi', () => {
    expect(kalemDurumu(girdi({ rota: 0 })).kurumRotasi).toBe(false);
    expect(kalemDurumu(girdi({ rota: 1 })).kurumRotasi).toBe(false);
    for (const rota of [2, 3, 4, 5]) {
      expect(kalemDurumu(girdi({ rota })).kurumRotasi).toBe(true);
    }
  });

  it('dövizli kalemde yerel fiyat kurla çarpılır', () => {
    const d = kalemDurumu(girdi({ fiyatDovizi: 'USD', dovizFiyat: '10', kur: '35' }));
    expect(d.dovizli).toBe(true);
    expect(d.fiyat).toBe(350);
    // Yerel para ile aynı kod dövizli SAYILMAZ - kur sorulmamalı.
    expect(kalemDurumu(girdi({ fiyatDovizi: 'TRY' })).dovizli).toBe(false);
  });

  it('lot adımı yalnız izlemli STOK satırında ve yön verilmişse gerekir', () => {
    const izlemli = { satirTur: 1, izleme: 1 };
    expect(kalemDurumu(girdi(izlemli, { girisIzlemi: true })).izlemGerekli).toBe(true);
    expect(kalemDurumu(girdi(izlemli, { cikisIzlemi: true })).izlemGerekli).toBe(true);
    // Yön yoksa (kalem yalnız düzenleniyor) lot ekranı açılmaz.
    expect(kalemDurumu(girdi(izlemli)).izlemGerekli).toBe(false);
    // Hizmet satırında (satirTur 2) lot diye bir şey yok.
    expect(kalemDurumu(girdi({ satirTur: 2, izleme: 1 }, { girisIzlemi: true }))
      .izlemGerekli).toBe(false);
  });
});

describe('sağ kutu görünümü', () => {
  const d = kalemDurumu(girdi({ birimFiyat: '200', iskonto: '10' }));

  it('hazır oranda kutu, oranın PARA karşılığını gösterir', () => {
    const s = sagKutuGorunumu(d, 'tutar', '10', 'TRY');
    expect(s.baslik).toBe('Karşılığı');
    expect(s.etiket).toBe('TRY');
    expect(s.oranSecimi).toBe('10');
    expect(s.deger).toBe('20,00');
  });

  it('özel iskontoda ORAN girilir', () => {
    const s = sagKutuGorunumu(d, 'oran', '10', 'TRY');
    expect(s.baslik).toBe('Oran');
    expect(s.etiket).toBe('%');
    expect(s.oranSecimi).toBe('ozel');
    expect(s.deger).toBe('10');
  });

  it('birim fiyat modunda hedef fiyat girilir, başlık tabanın adıdır', () => {
    const s = sagKutuGorunumu(d, 'fiyat', '10', 'TRY');
    expect(s.baslik).toBe('Birim Fiyat');
    expect(s.oranSecimi).toBe('fiyat');
    expect(s.deger).toBe('180,00');
  });

  it('iskonto yokken tutar kutusu BOŞ kalır', () => {
    const sifir = kalemDurumu(girdi({ birimFiyat: '200', iskonto: '0' }));
    expect(sagKutuGorunumu(sifir, 'tutar', '0', 'TRY').deger).toBe('');
    expect(sagKutuGorunumu(sifir, 'tutar', '0', 'TRY').oranSecimi).toBe('');
  });
});
