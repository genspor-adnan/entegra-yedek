import { describe, it, expect } from 'vitest';
import { kartYuvasiSec, KART_SEKME_SINIRI } from '../sayfalar/kabuk/EkranSekmeleri';

/**
 * AYNI TÜR KART SEKMESİ SINIRI (kullanıcı 24.10.2026: "aynı tür sekme 1 adet izin vermiştik onu 3
 * adete çıkar.. 3 tedarikçi kartı yan yana açabilirim").
 */
const T = '/tedarikci#kart';
const sekme = (n: number, yol: string, erisim: number) => ({ anahtar: `${T}#${n}`, konum: { pathname: yol }, erisim });
const temiz = () => false;

describe('kartYuvasiSec', () => {
  it('sınır 3', () => expect(KART_SEKME_SINIRI).toBe(3));

  it('boş yuvalar sırayla dolar', () => {
    expect(kartYuvasiSec(T, '/tedarikci/1', [], '/tedarikci', temiz)).toBe(`${T}#0`);
    expect(kartYuvasiSec(T, '/tedarikci/2', [sekme(0, '/tedarikci/1', 1)], '/tedarikci', temiz)).toBe(`${T}#1`);
  });

  it('açık kayıt ikinci sekme açmaz', () => {
    expect(kartYuvasiSec(T, '/tedarikci/1', [sekme(0, '/tedarikci/1', 1), sekme(1, '/tedarikci/2', 2)], '/tedarikci', temiz))
      .toBe(`${T}#0`);
  });

  it('karttan karta / yeni -> kayıt aynı yuvada', () => {
    expect(kartYuvasiSec(T, '/tedarikci/9', [sekme(0, '/tedarikci/1', 1), sekme(1, '/tedarikci/yeni', 2)], `${T}#1`, temiz))
      .toBe(`${T}#1`);
  });

  it('dolunca en uzun süredir bakılmayan, kirli olan atlanır, hepsi kirliyse null', () => {
    const uc = [sekme(0, '/tedarikci/1', 5), sekme(1, '/tedarikci/2', 1), sekme(2, '/tedarikci/3', 3)];
    expect(kartYuvasiSec(T, '/tedarikci/4', uc, '/tedarikci', temiz)).toBe(`${T}#1`);
    expect(kartYuvasiSec(T, '/tedarikci/4', uc, '/tedarikci', a => a === `${T}#1`)).toBe(`${T}#2`);
    expect(kartYuvasiSec(T, '/tedarikci/4', uc, '/tedarikci', () => true)).toBeNull();
  });

  it('kirli karttan başka karta geçiş o kartın yerine konmaz', () => {
    expect(kartYuvasiSec(T, '/tedarikci/4', [sekme(0, '/tedarikci/1', 5)], `${T}#0`, a => a === `${T}#0`)).toBe(`${T}#1`);
  });
});
