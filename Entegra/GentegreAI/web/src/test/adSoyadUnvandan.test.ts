import { describe, expect, it } from 'vitest';
import { adSoyadUnvandan } from '../bilesenler/kart/useUnvanOneki';

// PERSONEL TAM ADI UNVANDA (03.11.2026, göç 1250 ile aynı kural).
describe('adSoyadUnvandan', () => {
  it('son kelime soyad', () => expect(adSoyadUnvandan({ unvan: 'NADİYE ELYEŞİT' })).toEqual({ ad: 'NADİYE', soyad: 'ELYEŞİT' }));
  it('çok kelimeli ad', () => expect(adSoyadUnvandan({ unvan: 'Ali Rıza Kaya' })).toEqual({ ad: 'Ali Rıza', soyad: 'Kaya' }));
  it('önek atlanır', () => expect(adSoyadUnvandan({ unvan: 'Uzm.Dr. Ayşe Demir' })).toEqual({ ad: 'Ayşe', soyad: 'Demir' }));
  it('ad doluysa dokunmaz', () => expect(adSoyadUnvandan({ unvan: 'Dr.', ad: 'Ali', soyad: 'Kaya' })).toBeNull());
  it('tek kelime / yalnız önek', () => {
    expect(adSoyadUnvandan({ unvan: 'Dr.' })).toBeNull();
    expect(adSoyadUnvandan({ unvan: 'Dr. Ali' })).toBeNull();
  });
});
