// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import type { AcikRapor } from '../api/uclar/raporGonderim';

/**
 * AÇIK RAPOR SAYFASI `/r/{kod}` (1389; kullanıcı 20.11.2026): doğrulama adımı yok; borç varken rapor GÖSTERİLMEZ ve
 * tutar yazmaz; süresi dolan / geri çekilen / olmayan bağlantı kendi ekranını gösterir; e-imzalıda imza paneli.
 * Karekod: bağlantı satır içi SVG olarak basılır.
 */
let yanit: AcikRapor = { durum: 'yok' };
vi.mock('../api/uclar/raporGonderim', async asil => ({
  ...(await asil<typeof import('../api/uclar/raporGonderim')>()),
  acikRaporOku: async () => yanit,
}));
vi.mock('../api/istemci', () => ({ api: { dokumanIcerikUrl: async () => null } }));
const { RaporAcik } = await import('../sayfalar/raporGonderim/RaporAcik');
const { Karekod } = await import('../bilesenler/Karekod');
const { raporBaglantisi } = await import('../api/uclar/raporGonderim');

const ac = () => render(
  <MemoryRouter initialEntries={['/r/ABCD']}><Routes><Route path="/r/:kod" element={<RaporAcik />} /></Routes></MemoryRouter>);
const kurum = { unvan: 'Genotip Görüntüleme', telefon: '0216 000 00 00' };
const rapor = { id: 1, raporNo: 'R-1', durum: 3, hastaAdi: 'Ayşe Kaya', tetkikAdi: 'Mamografi', onaylayan: 'Dr. M. Yılmaz', onayTarihi: '2026-11-20T11:28:00Z' };
const imzasiz = { imzali: false, gecerli: false, hata: '', hekim: 'Dr. M. Yılmaz', tescil: '', zaman: null, sahip: '', veren: '',
                  gecerlilikBas: null, gecerlilikBit: null, seriNo: '', ozet: '' };

describe('açık rapor sayfası', () => {
  beforeEach(() => { yanit = { durum: 'yok' } });

  it('borç varken rapor yok, tutar yazmaz, kurum telefonu var', async () => {
    yanit = { durum: 'iletisim', kurum, ozet: { tetkik: 'Lomber MR', cekimTarihi: '2026-11-20T08:00:00Z' } };
    ac();
    expect(await screen.findByText('Raporunuz için kurumla iletişime geçin')).toBeTruthy();
    expect(screen.queryByTestId('rapor-acik-rapor')).toBeNull();
    expect(document.body.textContent).not.toMatch(/₺|TL|borç/i);
    expect(document.querySelector('a[href="tel:02160000000"]')).toBeTruthy();
  });

  it('süresi dolmuş, geri çekilmiş ve olmayan bağlantı', async () => {
    yanit = { durum: 'sure', kurum, sonGecerli: '2026-12-20T00:00:00Z' };
    const { unmount } = ac();
    expect(await screen.findByText('Bağlantının süresi doldu')).toBeTruthy();
    unmount();
    yanit = { durum: 'guncel', kurum };
    const g = ac();
    expect(await screen.findByText('Rapor güncelleniyor')).toBeTruthy();
    g.unmount();
    yanit = { durum: 'yok' };
    ac();
    expect(await screen.findByText('Bağlantı bulunamadı')).toBeTruthy();
  });

  it('rapor doğrudan görünür (doğrulama adımı yok); e-imzasızda onay paneli', async () => {
    yanit = { durum: 'ok', aliciTur: 1, kurum, imza: imzasiz, rapor, bolumler: [{ sira: 1, baslik: 'Sonuç', metin: 'BI-RADS 3' }], alanlar: [], ekler: [] };
    ac();
    expect(await screen.findByTestId('rapor-acik-rapor')).toBeTruthy();
    expect(screen.getByText('BI-RADS 3')).toBeTruthy();
    expect(document.querySelector('input')).toBeNull();                       // doğrulama kutusu yok
    expect(screen.getAllByText('Onaylı rapor').length).toBeGreaterThan(0);
  });

  it('e-imzalıda imza paneli: geçerli, sertifika sahibi, asıl belge bağlantısı', async () => {
    yanit = { durum: 'ok', aliciTur: 2, kurum, rapor, bolumler: [], alanlar: [], ekler: [],
              imza: { ...imzasiz, imzali: true, gecerli: true, sahip: 'MEHMET YILMAZ', veren: 'Kamu SM', seriNo: '4A1F',
                      zaman: '2026-11-20T11:28:07Z', gecerlilikBas: '2025-02-03T00:00:00Z', gecerlilikBit: '2028-02-03T00:00:00Z' } };
    ac();
    expect(await screen.findByText('İmza geçerli')).toBeTruthy();
    expect(screen.getByText('MEHMET YILMAZ')).toBeTruthy();
    expect(screen.getByText('Kamu SM')).toBeTruthy();
    expect(document.querySelector('a[href$="/api/acik/rapor/ABCD/imzali"]')).toBeTruthy();
  });
});

describe('karekod ve bağlantı', () => {
  it('bağlantı kök adresin alt yolunu korur', () => {
    expect(raporBaglantisi('ABCD', 'https://kurum.com/ai/')).toBe('https://kurum.com/ai/r/ABCD');
  });

  it('karekod satır içi SVG: sessiz bölge + modüller, içerik değişince değişir', () => {
    const { container, rerender } = render(<Karekod deger="https://kurum.com/r/ABCDEFGHJKLMNPQR" />);
    const svg = container.querySelector('svg[data-testid="karekod"]')!;
    const n = Number(svg.getAttribute('viewBox')!.split(' ')[2]) - 8;
    expect(n).toBeGreaterThanOrEqual(21);                                      // en küçük QR 21 modül
    expect((n - 21) % 4).toBe(0);                                              // sürüm adımı 4
    const yol = svg.querySelector('path')!.getAttribute('d')!;
    expect(yol.length).toBeGreaterThan(200);
    rerender(<Karekod deger="https://kurum.com/r/BASKABIRKOD23456" />);
    expect(container.querySelector('path')!.getAttribute('d')).not.toBe(yol);
  });
});
