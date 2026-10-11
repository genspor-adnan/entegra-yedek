import { describe, expect, it } from 'vitest';
import { durumRengi, gonderilebilir, sorunRengi, ulasanRozeti, yuzde } from '../sayfalar/efaturaIcmal/efaturaIcmalOrtak';

describe('Fatura / e-Belge icmali yardımcıları', () => {
  it('yüzde ve GİB ulaşma rozeti', () => {
    expect(yuzde(null)).toBe('—');
    expect(yuzde(98.65)).toBe('%98,7');
    expect(ulasanRozeti(100).renk).toBe('ok');
    expect(ulasanRozeti(96).renk).toBe('sari');
    expect(ulasanRozeti(80).renk).toBe('kir');
    expect(ulasanRozeti(null).renk).toBe('pas');
  });
  it('sorun ve durum renkleri', () => {
    expect(sorunRengi("GİB'e gitmedi")).toBe('kir');
    expect(sorunRengi('Gönderim hatası')).toBe('kir');
    expect(sorunRengi('e-Belge hazırlanmadı')).toBe('sari');
    expect(durumRengi('Gönderildi')).toBe('ok');
    expect(durumRengi('Hazır')).toBe('sari');
  });
  it('yalnız hazır ve gönderilmemiş belge yeniden gönderilir', () => {
    expect(gonderilebilir({ hazir: true, gonderildi: false })).toBe(true);
    expect(gonderilebilir({ hazir: false, gonderildi: false })).toBe(false);
    expect(gonderilebilir({ hazir: false, gonderildi: true })).toBe(false);
  });
});
