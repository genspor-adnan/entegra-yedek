import { describe, expect, it } from 'vitest';
import type { PlanliGiderDonemi, PlanliGiderKategorisi } from '../api/uclar/planliGider';
import {
  bitisTuru, cubukBoyu, donemCipSayisi, donemIslemleri, donemSuz, durumRozeti, ek, gunT, kategoriOntanimi,
  odemeGunuMetni, odenecekDonem, tedarikciZorunlu,
} from '../sayfalar/planliGider/planliGiderOrtak';

const donem = (vade: string, durum: string, ek: Partial<PlanliGiderDonemi> = {}): PlanliGiderDonemi => ({
  vade, planTarihi: vade, kaydirildi: false, kaydirmaNedeni: '', plan: 100, gercek: null, fark: null, odemeTarihi: null,
  eslesen: null, otomatik: false, durum, gun: null, elleTutar: null, aciklama: '', dondurulmus: false, ...ek,
});
const kat: PlanliGiderKategorisi = {
  id: 4, kod: 'vergi_sgk', ad: 'Vergi / SGK', masrafId: 9, masraf: '360 · Vergi', tutarTur: 4, hesapKaynak: 'kdv', tatilKural: 2, hatirlatmaGun: 5,
};
const yeniKart = { id: 0, masrafId: null, tutarTur: 1, hesapKaynak: '', tatilKural: 2, hatirlatmaGun: 0 };

describe('planlı gider - kategori öntanımı (yalnız boş alanlar)', () => {
  it('yeni kayıtta dokunulmamış alanlar dolar', () => {
    expect(kategoriOntanimi(yeniKart, kat, new Set())).toEqual({
      masrafId: 9, masraf: '360 · Vergi', tutarTur: 4, hesapKaynak: 'kdv', hatirlatmaGun: 5,
    });
  });
  it('kullanıcının değiştirdiği alan ezilmez', () => {
    const d = kategoriOntanimi({ ...yeniKart, masrafId: 3, hatirlatmaGun: 2 }, kat, new Set(['tutarTur']));
    expect(d.masrafId).toBeUndefined();
    expect(d.tutarTur).toBeUndefined();
    expect(d.hatirlatmaGun).toBeUndefined();
    expect(d.hesapKaynak).toBeUndefined();   // tutar türü 4 değil
  });
  it('kayıtlı kartta varsayılanlı alanlara dokunulmaz, yalnız boş masraf dolar', () => {
    expect(kategoriOntanimi({ ...yeniKart, id: 7 }, kat, new Set())).toEqual({ masrafId: 9, masraf: '360 · Vergi' });
  });
});

describe('planlı gider - görünüm yardımcıları', () => {
  it('durum rozeti', () => {
    expect(durumRozeti('gecikti', 15)).toEqual({ ad: 'Gecikti 15 gün', renk: 'kir' });
    expect(durumRozeti('gec', 2).ad).toBe('Geç · +2 gün');
    expect(durumRozeti('faturalandi').renk).toBe('mor');
    expect(durumRozeti('bilinmeyen').ad).toBe('bilinmeyen');
  });
  it('Türkçe sayı eki ve ödeme günü', () => {
    expect([1, 2, 3, 5, 6, 9, 10, 20, 30, 12].map(n => `${n}'${ek(n)}`))
      .toEqual(["1'i", "2'si", "3'ü", "5'i", "6'sı", "9'u", "10'u", "20'si", "30'u", "12'si"]);
    expect(odemeGunuMetni(2, 5)).toBe("Ayın 5'i");
    expect(odemeGunuMetni(1, 3)).toBe('Çarşamba');
    expect(odemeGunuMetni(2, 31)).toContain('kısa ayda son gün');
  });
  it('gün metni saat dilimine kaymaz', () => {
    expect(gunT('2026-11-05')).toBe('05.11.2026');
    expect(gunT(null)).toBe('—');
  });
  it('vergi / SGK dışında ödenecek yer zorunlu', () => {
    expect(tedarikciZorunlu('kira')).toBe(true);
    expect(tedarikciZorunlu(undefined)).toBe(true);
    expect(tedarikciZorunlu('vergi_sgk')).toBe(false);
  });
  it('bitiş türü', () => {
    expect(bitisTuru({ bitis: null, donemSayisi: null })).toBe('suresiz');
    expect(bitisTuru({ bitis: '2027-12-31', donemSayisi: null })).toBe('tarih');
    expect(bitisTuru({ bitis: null, donemSayisi: 9 })).toBe('donem');
  });
  it('çubuk boyu', () => {
    expect(cubukBoyu(50, 100, 96)).toBe(48);
    expect(cubukBoyu(0, 100, 96)).toBe(0);
    expect(cubukBoyu(1, 1000, 96)).toBe(2);
  });
});

describe('planlı gider - dönemler', () => {
  const liste = [
    ...Array.from({ length: 8 }, (_, i) => donem(`2026-0${i + 1}-05`, 'odendi', { eslesen: { tur: 'kasa', id: i, no: `K${i}`, metin: '' } })),
    donem('2026-09-05', 'gecikti'), donem('2026-10-05', 'atlandi'), donem('2026-11-05', 'planli'),
    ...Array.from({ length: 8 }, (_, i) => donem(`2027-0${i + 1}-05`, 'planli')),
  ];
  it('son 6 + gelecek 6', () => {
    const y = donemSuz(liste, 'yakin');
    expect(y).toHaveLength(12);
    expect(y[6].vade).toBe('2026-11-05');
    expect(donemCipSayisi(liste, 'yakin')).toBeNull();
  });
  it('çip sayıları', () => {
    expect(donemCipSayisi(liste, 'odendi')).toBe(8);
    expect(donemCipSayisi(liste, 'atlandi')).toBe(1);
    expect(donemCipSayisi(liste, 'planli')).toBe(9);
    expect(donemCipSayisi(liste, 'tumu')).toBe(liste.length);
  });
  it('ödenecek dönem önce gecikmiş', () => {
    expect(odenecekDonem(liste)?.vade).toBe('2026-09-05');
    expect(odenecekDonem(liste.filter(d => d.durum !== 'gecikti'))?.vade).toBe('2026-11-05');
    expect(odenecekDonem([])).toBeNull();
  });
  it('dönem işlemleri', () => {
    expect(donemIslemleri(liste[0])).toMatchObject({ esles: false, kaldir: true, odeme: false });
    expect(donemIslemleri(donem('x', 'atlandi'))).toMatchObject({ atla: false, geriAl: true });
    expect(donemIslemleri(donem('x', 'planli', { elleTutar: 5 }))).toMatchObject({ esles: true, geriAl: true, odeme: true });
    expect(donemIslemleri(null).esles).toBe(false);
  });
});
