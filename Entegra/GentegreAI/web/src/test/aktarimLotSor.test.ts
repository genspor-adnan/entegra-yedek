import { describe, expect, it } from 'vitest';
import { lotSorulacakSatirlar, siparisSatirlari } from '../sayfalar/belgeKalem';
import type { SiparisSatiri } from '../bilesenler/belge/SiparistenAktarPenceresi';

// KAYNAKTAN AKTARIMDA LOT (kullanıcı 09.11.2026):
//   · siparişten aktar: izlemli stok satırı lotsuz gelir -> hedef belge stok oynatıyorsa SORULUR
//   · irsaliyeden aktar: kaynağın lotları aynen gelir, stok düşürmez -> sorulmaz
const taban = {
  sira: 1, satirTur: 1, aciklama: '', miktar: 10, kapatilanMiktar: 0, kalanMiktar: 10, birim: 51,
  birimFiyat: 100, iskonto: 0, kdv: 20, belgeNo: 'X', tarafUnvan: 'T', belgeDovizi: 'TL', kapanmaDurum: 0,
} as const;

describe('aktarım sonrası lot sorma', () => {
  it('siparişten gelen izlemli stok satırı sorulur, izlemsiz ve hizmet sorulmaz', () => {
    const yeniler = siparisSatirlari([
      { ...taban, satirId: 1, stokId: 10, stokAdi: 'Lotlu', izleme: 5, belgeTur: 19, secilenMiktar: '4' },
      { ...taban, satirId: 2, stokId: 11, stokAdi: 'Düz', izleme: 0, belgeTur: 19, secilenMiktar: '2' },
      { ...taban, satirId: 3, satirTur: 2, hizmetId: 7, kalemAdi: 'Hizmet', izleme: 0, belgeTur: 19, secilenMiktar: '1' },
    ] as unknown as SiparisSatiri[], 0);
    const sor = lotSorulacakSatirlar(yeniler, { girisIzlemi: false, cikisIzlemi: true });
    expect(sor).toEqual([yeniler[0].anahtar]);
  });

  it('hedef belge stok oynatmıyorsa (sipariş, teklif) hiç sorulmaz', () => {
    const yeniler = siparisSatirlari([
      { ...taban, satirId: 1, stokId: 10, stokAdi: 'Lotlu', izleme: 2, belgeTur: 18, secilenMiktar: '4' },
    ] as unknown as SiparisSatiri[], 0);
    expect(lotSorulacakSatirlar(yeniler, { girisIzlemi: false, cikisIzlemi: false })).toEqual([]);
  });

  it('irsaliyeden gelen satır lotlarıyla gelir, stok düşürmez, sorulmaz', () => {
    const yeniler = siparisSatirlari([
      { ...taban, satirId: 5, stokId: 10, stokAdi: 'Lotlu', izleme: 5, belgeTur: 14, secilenMiktar: '3',
        izlemler: [{ seriLotId: 90, lotNo: 'L1', seriNo: '', uretimTarihi: '2026-01-01', sonKullanmaTarihi: '2028-01-01', durum: 0, miktar: 2 },
                   { seriLotId: 91, lotNo: 'L2', seriNo: '', uretimTarihi: '2026-02-01', sonKullanmaTarihi: '2028-02-01', durum: 0, miktar: 5 }] },
    ] as unknown as SiparisSatiri[], 0);
    expect(yeniler[0].stokDurumDegis).toBe(0);
    expect(yeniler[0].izlemler.map(z => [z.lotNo, z.miktar])).toEqual([['L1', '2'], ['L2', '1']]);
    expect(lotSorulacakSatirlar(yeniler, { girisIzlemi: false, cikisIzlemi: true })).toEqual([]);
  });
});
