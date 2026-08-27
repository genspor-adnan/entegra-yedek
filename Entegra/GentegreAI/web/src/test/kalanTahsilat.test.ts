import { describe, expect, it } from 'vitest';
import { kalanTahsilat, tahsilToplami } from '../sayfalar/belgeTahsilat';
import type { ListeSatiri } from '../api/sozlesme';

const satir = (x: Record<string, unknown>) => x as unknown as ListeSatiri;

/**
 * Yeni tahsilat açılırken tutar alanına KALAN yazılır (kullanıcı bildirimi):
 * önce genel toplam geliyordu, ikinci tahsilatta kullanıcı tutarı elle
 * düzeltmek zorunda kalıyordu.
 */
describe('kalanTahsilat', () => {
  it('hiç tahsilat yoksa genel toplam', () => {
    expect(kalanTahsilat(1200, [])).toBe(1200);
  });

  it('kısmi tahsilatta kalan döner', () => {
    expect(kalanTahsilat(1200, [satir({ yerelTutar: 500 })])).toBe(700);
  });

  it('birden çok tahsilat toplanır', () => {
    expect(kalanTahsilat(1200, [
      satir({ yerelTutar: 500 }), satir({ yerelTutar: 200 }), satir({ yerelTutar: 100 }),
    ])).toBe(400);
  });

  it('tam tahsil edilmişse 0', () => {
    expect(kalanTahsilat(1200, [satir({ yerelTutar: 1200 })])).toBe(0);
  });

  // Fazla tahsilat (avans/yanlış giriş) negatif tutar önermemeli.
  it('fazla tahsilatta negatife düşmez', () => {
    expect(kalanTahsilat(1200, [satir({ yerelTutar: 1500 })])).toBe(0);
  });

  // Doviz belgede kasa islemi yerel karsiligiyla kapatir; yerelTutar yoksa tutar.
  it('yerelTutar yoksa tutar kullanılır', () => {
    expect(kalanTahsilat(1000, [satir({ tutar: 250 })])).toBe(750);
  });

  it('belge toplamı yoksa 0', () => {
    expect(kalanTahsilat(0, [])).toBe(0);
    expect(kalanTahsilat(null, [satir({ yerelTutar: 100 })])).toBe(0);
  });
});

describe('tahsilToplami', () => {
  it('boş listede 0', () => {
    expect(tahsilToplami([])).toBe(0);
  });

  it('sayı olmayan değerler 0 sayılır', () => {
    expect(tahsilToplami([satir({ yerelTutar: 'abc' }), satir({ yerelTutar: 300 })])).toBe(300);
  });
});
