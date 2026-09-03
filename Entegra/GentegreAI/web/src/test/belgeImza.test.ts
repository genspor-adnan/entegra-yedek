import { describe, it, expect } from 'vitest';
import { kartImzasi, type KartImzaDurumu } from '../sayfalar/belgeImza';
import { bosSatir, type SatirDurumu } from '../sayfalar/belgeSatir';

/**
 * KURAL (kullanici): "başvuruya herhangi bir ekleme veya değişim yaptığımda
 * kaydetmeden kapat dersem uyarsın" - ama HICBIR SEY DEGISTIRMEDEN kapatana
 * soru sorulmamali (kartDegisim.ts'teki eski ders).
 *
 * Asagidaki vakalar iki tarafi da korur: sahte fark uyari uretmemeli, gercek
 * degisiklik uyari uretmeli.
 */
const temelDurum = (): KartImzaDurumu => ({
  tarih: '2026-09-03T13:49',
  cariId: 5011,
  seri: 'WEB',
  belgeNo: '',
  vadeGun: '30',
  faturaTipi: 1,
  aciklama: '',
  satirlar: [],
  odeyenKurumId: 4990,
  bolumId: 3,
  personelId: 4997,
  basvuruBilgi: { gelisSekli: 1, basvuruTuru: 5 },
  fiyatListesiId: 12,
  kampanyaId: null,
  depoId: 1,
  raporDovizi: 'TL',
  ekstreDovizi: 'TL',
  belgeKuru: '1',
  senaryo: 1,
});

const satir = (y: Partial<SatirDurumu> = {}): SatirDurumu =>
  ({ ...bosSatir(1), hizmetId: 900, satirTur: 2, adet: '1',
     birimFiyat: '1000', kdv: '10', ...y });

describe('kartImzasi - sahte fark uretmez', () => {
  it('ayni durum ayni imzayi verir', () => {
    expect(kartImzasi(temelDurum())).toBe(kartImzasi(temelDurum()));
  });

  it('sayinin farkli yazimi fark sayilmaz (sunucu "1500.0000", ekran "1500")', () => {
    const a = { ...temelDurum(), satirlar: [satir({ birimFiyat: '1500.0000' })] };
    const b = { ...temelDurum(), satirlar: [satir({ birimFiyat: '1500' })] };
    expect(kartImzasi(a)).toBe(kartImzasi(b));
  });

  it('bos kimligin uc yazimi ayni (null / 0 / undefined)', () => {
    const a = { ...temelDurum(), kampanyaId: null };
    const b = { ...temelDurum(), kampanyaId: 0 };
    expect(kartImzasi(a)).toBe(kartImzasi(b));
  });

  it('metnin bas/son boslugu fark sayilmaz', () => {
    const a = { ...temelDurum(), aciklama: 'Kontrol' };
    const b = { ...temelDurum(), aciklama: '  Kontrol  ' };
    expect(kartImzasi(a)).toBe(kartImzasi(b));
  });

  it('basvuru alanlarinin SIRASI degisince imza degismez', () => {
    const a = { ...temelDurum(), basvuruBilgi: { gelisSekli: 1, basvuruTuru: 5 } };
    const b = { ...temelDurum(), basvuruBilgi: { basvuruTuru: 5, gelisSekli: 1 } };
    expect(kartImzasi(a)).toBe(kartImzasi(b));
  });

  it('basvuruda BOS alan eklenmesi fark sayilmaz (otomatik doldurmanin izi)', () => {
    const a = { ...temelDurum(), basvuruBilgi: { gelisSekli: 1, basvuruTuru: 5 } };
    const b = { ...temelDurum(),
                basvuruBilgi: { gelisSekli: 1, basvuruTuru: 5, siraNo: '', refakatci: '' } };
    expect(kartImzasi(a)).toBe(kartImzasi(b));
  });

  it('satirin ANAHTARI (gecici) degisse de imza ayni', () => {
    const a = { ...temelDurum(), satirlar: [{ ...satir(), anahtar: 1 }] };
    const b = { ...temelDurum(), satirlar: [{ ...satir(), anahtar: 77 }] };
    expect(kartImzasi(a)).toBe(kartImzasi(b));
  });
});

describe('kartImzasi - gercek degisikligi yakalar', () => {
  const temiz = kartImzasi(temelDurum());

  it('kalem eklenince', () => {
    expect(kartImzasi({ ...temelDurum(), satirlar: [satir()] })).not.toBe(temiz);
  });

  it('kalem tutari degisince', () => {
    const bir = kartImzasi({ ...temelDurum(), satirlar: [satir({ birimFiyat: '1000' })] });
    const iki = kartImzasi({ ...temelDurum(), satirlar: [satir({ birimFiyat: '1200' })] });
    expect(bir).not.toBe(iki);
  });

  it('kalem silinince', () => {
    const dolu = kartImzasi({ ...temelDurum(), satirlar: [satir(), satir({ hizmetId: 901 })] });
    const tek = kartImzasi({ ...temelDurum(), satirlar: [satir()] });
    expect(dolu).not.toBe(tek);
  });

  it('odeyen kurum degisince', () => {
    expect(kartImzasi({ ...temelDurum(), odeyenKurumId: 4968 })).not.toBe(temiz);
  });

  it('gonderen (hekim) degisince', () => {
    expect(kartImzasi({ ...temelDurum(), personelId: 4999 })).not.toBe(temiz);
  });

  it('bolum degisince', () => {
    expect(kartImzasi({ ...temelDurum(), bolumId: 1 })).not.toBe(temiz);
  });

  it('tarih/saat degisince', () => {
    expect(kartImzasi({ ...temelDurum(), tarih: '2026-09-03T14:00' })).not.toBe(temiz);
  });

  it('basvuru alani degisince (gelis sekli sevkli oldu)', () => {
    expect(kartImzasi({ ...temelDurum(), basvuruBilgi: { gelisSekli: 3, basvuruTuru: 5 } }))
      .not.toBe(temiz);
  });

  it('kalem tarihi (368) degisince', () => {
    const bir = kartImzasi({ ...temelDurum(),
      satirlar: [satir({ teslimTarihi: '2026-09-03T10:00' })] });
    const iki = kartImzasi({ ...temelDurum(),
      satirlar: [satir({ teslimTarihi: '2026-09-03T15:30' })] });
    expect(bir).not.toBe(iki);
  });
});
