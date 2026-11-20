// @vitest-environment jsdom
import { describe, it, expect, vi } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import type { AcikRapor, AcikLabRaporu } from '../api/uclar/raporGonderim';

/**
 * LAB SONUÇ SAYFASI (1394; kullanıcı 20.11.2026): Bakanlık "Tıbbi Laboratuvar Tetkik Sonuç Raporu" düzeni; durum
 * H / L harfi değil OK (↑ ↓), panikte ÇİFT ok; geçmiş iki sonuç kolonu; "Geliş No" değil Protokol No, Örnek No ayrı;
 * hastaya gösterilmeyen testin adı yazmaz, yalnız sayısı.
 */
const lab: AcikLabRaporu = {
  bolum: 1, bolumAd: 'Biyokimya',
  baslik: { hasta: 'Ayşe Kaya', tc: '12*******34', dogumTarihi: '1980-05-01', cinsiyet: 2, dosyaNo: 'H-100', protokolNo: 'P-2026-55',
            isteyen: 'Dr. Ali Demir', kurum: 'Ücretli', sube: 'Merkez', gonderilecekYer: 'Dahiliye', raporNo: 'P-2026-55.N-77', ornekNo: 'N-77',
            istemZamani: '2026-11-20T07:00:00Z', numuneAlma: '2026-11-20T07:10:00Z', numuneKabul: '2026-11-20T07:20:00Z',
            onayZamani: '2026-11-20T09:00:00Z', basimZamani: '2026-11-20T10:00:00Z' },
  gecmisGunler: ['2026-10-21', '2026-08-22'],
  satirlar: [
    { kod: 'GLU', ad: 'Glukoz', sonuc: '126', birim: 'mg/dL', bayrak: 'H', panik: false, referans: '70 – 100', kararNotu: '', yorum: '',
      ornekNo: 'N-77', yontem: '', onceki1: { deger: '118', bayrak: 'H', panik: false }, onceki2: null },
    { kod: 'K', ad: 'Potasyum', sonuc: '2,4', birim: 'mmol/L', bayrak: 'LL', panik: true, referans: '3,5 – 5,1', kararNotu: '', yorum: '',
      ornekNo: 'N-77', yontem: '', onceki1: null, onceki2: null },
    { kod: 'NA', ad: 'Sodyum', sonuc: '140', birim: 'mmol/L', bayrak: 'N', panik: false, referans: '136 – 145', kararNotu: '', yorum: '',
      ornekNo: 'N-77', yontem: '', onceki1: null, onceki2: null },
  ],
  gizlenen: 1, uzman: { ad: 'Uzm. Dr. Zeynep Ak', brans: '', tescilNo: '12345' },
};
const yanit: AcikRapor = { durum: 'ok', tur: 'lab', aliciTur: 1, sonGecerli: '2026-12-20T00:00:00Z', kurum: { unvan: 'Genotip Lab', telefon: '0216 000 00 00' }, lab };
vi.mock('../api/uclar/raporGonderim', async asil => ({
  ...(await asil<typeof import('../api/uclar/raporGonderim')>()),
  acikRaporOku: async () => yanit,
}));
vi.mock('../api/istemci', () => ({ api: { dokumanIcerikUrl: async () => null } }));
const { RaporAcik } = await import('../sayfalar/raporGonderim/RaporAcik');
const { durumOku } = await import('../sayfalar/raporGonderim/LabSonucRaporu');

describe('lab sonuç sayfası', () => {
  it('durum oku: tek ok / panikte çift ok / normalde yok', () => {
    expect(durumOku('H', false)?.ok).toBe('↑');
    expect(durumOku('L', false)?.ok).toBe('↓');
    expect(durumOku('HH', false)?.ok).toBe('↑↑');
    expect(durumOku('L', true)?.ok).toBe('↓↓');
    expect(durumOku('N', false)).toBeNull();
    expect(durumOku('', false)).toBeNull();
  });

  it('Bakanlık düzeni: protokol no, örnek no, geçmiş iki sonuç, gizlenen test sayısı', async () => {
    render(<MemoryRouter initialEntries={['/r/ABCD']}><Routes><Route path="/r/:kod" element={<RaporAcik />} /></Routes></MemoryRouter>);
    const r = await screen.findByTestId('lab-sonuc-raporu');
    const m = r.textContent ?? '';
    expect(m).toContain('Tıbbi Laboratuvar Tetkik Sonuç Raporu');
    expect(m).toContain('Dosya No / Protokol No');
    expect(m).not.toMatch(/Geliş No/);
    expect(m).toContain('Örnek No');
    expect(m).toContain('12*******34');
    expect(r.querySelectorAll('th.ls-onc-b').length).toBe(2);
    const satirlar = [...r.querySelectorAll('tbody tr')];
    expect(satirlar[0].querySelector('.ls-ok')?.textContent).toBe('↑');
    expect(satirlar[0].querySelectorAll('td.ls-onc')[0].textContent).toContain('118');
    expect(satirlar[1].querySelector('.ls-ok.pnk')?.textContent).toBe('↓↓');
    expect(satirlar[2].querySelector('.ls-ok')).toBeNull();
    expect(satirlar[0].textContent).not.toMatch(/\bH\b/);
    expect(screen.getByTestId('lab-gizlenen').textContent).toContain('1 testinizin');
  });
});
