// @vitest-environment jsdom
import { describe, expect, it, vi } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import { smsOlc, sablonDoldur, metindekiDegiskenler } from '../bilesenler/bildirim/smsSayaci';

/** BİLDİRİM ŞABLONU KARTI (1354, mockup Ekranlar/Ayarlar/bildirim_sablonu_karti.html). */
vi.mock('../api/istemci', () => ({ api: {
  bildirimSablonOzet: async () => ({ kod: 'basvuru.kvkk_sms', kanal: 1, degiskenler: { ONAYKODU: 'Tek kullanımlık onay kodu' },
                                      sistem: true, gonderen: 'GENYAZILIM', hesap: 'SMS (Ayyıldız)', buAy: 5, hatali: 0 }),
} }));
vi.mock('../bilesenler/GenGrid', () => ({ GenGrid: () => null }));
const { BildirimMetinPaneli } = await import('../bilesenler/bildirim/BildirimSablonPanelleri');

describe('SMS sayacı', () => {
  it('Türkçe harf UCS-2 (70/67), yoksa 7-bit (160/153)', () => {
    expect(smsOlc('a'.repeat(160))).toMatchObject({ ucs2: false, adet: 1 });
    expect(smsOlc('a'.repeat(161)).adet).toBe(2);
    expect(smsOlc('ş' + 'a'.repeat(69))).toMatchObject({ ucs2: true, adet: 1 });
    expect(smsOlc('ş' + 'a'.repeat(70)).adet).toBe(2);
    expect(smsOlc('öüÖÜÇ').ucs2).toBe(false);
  });
  it('değişkenler: @AD ve {{ad}} yazımları', () => {
    expect(metindekiDegiskenler('@ONAYKODU ve {{kurum}}')).toEqual(['kurum', 'ONAYKODU']);
    expect(sablonDoldur('Kod @ONAYKODU / {{ONAYKODU}}', { ONAYKODU: '123' })).toBe('Kod 123 / 123');
  });
});

describe('Metin paneli', () => {
  it('önizleme, gönderen başlığı, sayaç ve tanımsız değişken uyarısı', async () => {
    render(<BildirimMetinPaneli icerik={<div />} id={41}
             deger={{ kanal: 1, govde: '@ONAYKODU kodunuz. {{protokol}} https://ornek.com/kvkk', saatBas: 9, saatBit: 20 }} />);
    await waitFor(() => expect(screen.getByText('GENYAZILIM')).toBeTruthy());
    expect(document.querySelector('.bsk-balon')!.textContent).toContain('482913 kodunuz');
    expect(document.querySelector('.bsk-uy.k')!.textContent).toContain('{{protokol}}');
    expect(document.querySelector('.bsk-uyarilar')!.textContent).toContain('ornek.com');
    expect(screen.getByText('Kullanıldığı yer')).toBeTruthy();
    expect(document.querySelector('.bsk-sayac')!.textContent).toContain('Bu ay gönderim5');
  });
});
