// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render } from '@testing-library/react';
import { KalemPenceresi } from '../bilesenler/belge/KalemPenceresi';
import { bosSatir } from '../sayfalar/belgeSatir';

/**
 * KALEM PENCERESİ ÇİZİLİYOR MU.
 *
 * Bu test bir regresyondan doğdu: fiyat matematiği saf modüle taşınırken
 * (`f0cc446`) `fg()` yardımcısı `sgkKilitli`yi kapsıyor ve `brutFiyat`
 * satırı onu **hemen** çağırıyordu; `sgkKilitli` ise aşağıda tanımlıydı.
 * Sonuç TDZ hatası - *"Cannot access 'sgkKilitli' before initialization"* -
 * ve kullanıcıya **beyaz ekran**: başvuruda ücret eklerken listeden bir
 * kalem seçilince fiyat penceresi yerine boş sayfa geliyordu.
 *
 * Saf hesap testleri (`kalemFiyat.test.ts`) bunu yakalayamaz: matematik
 * doğruydu, patlayan bileşenin kendisiydi. Burada tek ölçülen şey pencerenin
 * **çizilebilmesi** - iç kuralları değil. Bir sonraki taşımada aynı hata
 * derlemeden değil testten dönsün.
 *
 * Dört tarife/rota bileşimi deneniyor çünkü kilit kararları (`sgkKilitli`,
 * `katkiliTarife`, `sutKutusu`) rotaya göre ayrı dallar açıyor ve bir dalda
 * çizilen pencere ötekinde patlayabilir.
 */

vi.mock('../api/istemci', () => ({
  api: {
    liste: vi.fn().mockResolvedValue({ satirlar: [], toplamKayit: 0 }),
    dovizKur: vi.fn().mockResolvedValue({ kur: 1 }),
  },
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({ aksiyonDegeri: () => 0 }),
}));

const cizdir = (ek: Record<string, unknown>) => render(
  <KalemPenceresi
    satir={{ ...bosSatir(1), stokAdi: 'Normal Poliklinik Muayenesi',
             hizmetId: 7, birimFiyat: '2000', kdv: '10' }}
    girisIzlemi={false}
    cikisIzlemi={false}
    cikisDepoId={null}
    yerelPara="TRY"
    vergisiz={false}
    transferMi={false}
    siparisMi={false}
    belgeTarihi="2026-09-17"
    onKapat={() => {}}
    onKaydet={() => {}}
    {...ek}
  />,
);

describe('kalem penceresi', () => {
  it.each([
    ['özel tarife, rota yok', { tarifeTipi: 1, rota: 0 }],
    ['SUT tarifesi, saf SGK rotası', { tarifeTipi: 3, rota: 5 }],
    ['TTB tarifesi, TSS rotası', { tarifeTipi: 2, rota: 3 }],
    ['başvuru (KDV dahil)', { basvuruMu: true, tarifeTipi: 1, rota: 0 }],
  ])('%s → beyaz ekran vermeden çizilir', (_ad, ek) => {
    cizdir(ek);
    // Modal PORTAL ile body'ye basiyor - kabin kendi container'i bos olur.
    //   Pencere cizildiyse body'de baslik ve girdi kutulari vardir; TDZ
    //   hatasinda React hicbir sey basamiyor ve kullanici beyaz ekran
    //   goruyordu.
    expect(document.body.textContent).toContain('Normal Poliklinik Muayenesi');
    expect(document.body.querySelectorAll('input').length).toBeGreaterThan(0);
  });
});
