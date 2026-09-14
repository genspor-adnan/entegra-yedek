import { describe, it, expect } from 'vitest';
import { belgeGovdesi } from '../sayfalar/belgeKaydet';
import type { SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * SUNUCUDAN OKUNAN ALANLAR İSTEK GÖVDESİNE GİRMEZ.
 *
 * Aynı hata üç kez yaşandı: sunucudan gelen salt okunur bir alan kart
 * durumuna yazılıyor, kaydederken geri gönderiliyor ve sunucu "Bilinmeyen
 * belge alanı: …" diyerek kaydı düşürüyor (sysTakipNo, sonra hastaUnvan).
 * Beyaz listeye eklemek yanlış olurdu - hastanın adı belgede değil hastanın
 * kartında durur; alan yalnız ekranda gösterilmek için okunur.
 *
 * Test gövdeyi ÜRETEN saf fonksiyona bakar: ekranın hangi yoldan kaydettiği
 * değişse de kural burada tutulur.
 */
const temel = {
  tur: 19,
  cari: { id: 4991, unvan: 'Test Hasta' },
  tarih: '2026-09-15',
  belgeNo: '',
  seri: '',
  vadeGun: '0',
  basvuruMu: true,
  odeyenKurumId: 7765,
  bolumId: 3,
  personelId: 900,
  fiyatListesiId: 481,
  yerelPara: 'TL',
  belgeKuru: '1',
} as unknown as Parameters<typeof belgeGovdesi>[0];

const satir = {
  anahtar: 1, adet: '1', birimFiyat: '100', kdv: '10', iskonto: '0', iskonto2: '0',
  hizmetId: 7634, stokAdi: 'Tetkik', izlemler: [], roller: [],
} as unknown as SatirDurumu;

describe('belge govdesi - salt okunur basvuru alanlari', () => {
  it('hastaUnvan ve sysTakipNo govdeye GIRMEZ', () => {
    const govde = belgeGovdesi({
      ...temel,
      basvuruAlanlari: {
        hastaId: 4991,
        hastaUnvan: 'AHMET ÖZTÜRK',      // sunucudan okunur - geri gitmez
        sysTakipNo: 'SYS-1',             // e-Nabiz kimligi - sunucu yazar
        basvuruTuru: 1,                  // gercek alan: gitmeli
      },
    }, [satir], false) as { belge: Record<string, unknown> };
    const belge = govde.belge;

    expect(belge).not.toHaveProperty('hastaUnvan');
    expect(belge).not.toHaveProperty('sysTakipNo');
    // Yazilabilir alan elenmemeli - suzgec fazla genis olursa kayit sessizce
    //   eksik kaydeder, hata da vermez.
    expect(belge.basvuruTuru).toBe(1);
    expect(belge.hastaId).toBe(4991);
  });
});
