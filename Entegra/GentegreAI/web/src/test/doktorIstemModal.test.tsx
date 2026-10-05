// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, render, screen } from '@testing-library/react';
import type { BekleyenIstemYaniti } from '../api/uclar/basvuruIstem';

/**
 * DOKTOR İSTEMİ PENCERESİ (kullanıcı): istemler GRID, Laboratuvar /
 * Görüntüleme diye gruplu, varsayılan HEPSİ seçili; sağda hastanın kurumuna
 * göre fiyatlar; altta grup ve seçime göre toplam. Fiyatları sunucu hesaplar
 * (ücretlendirmeyle aynı kural) - ekran yalnız seçili tutarları toplar.
 */
const ucretlendir = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  basvuruIstemUcretlendir: (...a: unknown[]) => ucretlendir(...a),
} }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {}, guvenli: (f: () => Promise<void>) => f(),
}));

const { DoktorIstemModal } = await import('../bilesenler/belge/DoktorIstemModal');

const VERI: BekleyenIstemYaniti = {
  kurum: 'ABC Sigorta', sozlesme: 'TSS 2026', toplam: 3,
  lab: [
    { tur: 'lab', id: 1, oncelik: 1, tetkik: 'Glukoz', kategori: 'Biyokimya',
      fiyat: 100, iskonto: 10, tutar: 90, hizmetYok: false, ucrette: false },
    { tur: 'lab', id: 2, oncelik: 2, tetkik: 'Hemogram', kategori: 'Hematoloji',
      fiyat: 50, iskonto: 10, tutar: 45, hizmetYok: false, ucrette: false },
  ],
  radyoloji: [
    { tur: 'radyoloji', id: 7, oncelik: 1, tetkik: 'Akciğer Grafisi', kategori: 'Radyoloji · Röntgen',
      fiyat: 300, iskonto: 0, tutar: 300, hizmetYok: false, ucrette: false },
  ],
};

const metin = () => (document.body.textContent ?? '').replace(/\s+/g, ' ').replace(/ /g, ' ');

beforeEach(() => { ucretlendir.mockReset(); ucretlendir.mockResolvedValue({ eklenen: 3, mesaj: 'ok' }) });

describe('doktor istemi penceresi', () => {
  it('grid: iki grup, hepsi seçili, kurum ve fiyatlar görünür, toplamlar altta', () => {
    render(<DoktorIstemModal belgeId={5} veri={VERI} onKapat={() => {}} onTamam={() => {}} />);
    const kutular = [...document.querySelectorAll('table.doktor-istem-grid tbody input[type=checkbox]')] as HTMLInputElement[];
    // 2 grup başlığı + 3 satır, hepsi işaretli
    expect(kutular).toHaveLength(5);
    expect(kutular.every(k => k.checked)).toBe(true);
    expect(screen.getAllByText(/Laboratuvar/).length).toBeGreaterThan(0);
    expect(screen.getAllByText(/Görüntüleme/).length).toBeGreaterThan(0);
    expect(metin()).toContain('ABC Sigorta');
    expect(metin()).toContain('Seçilenlerin toplamı (3)');
    // Genel toplam 90 + 45 + 300 = 435
    expect(metin()).toMatch(/Seçilenlerin toplamı \(3\)\s*435,00/);
  });

  it('satır tıklanınca seçim kalkar, grup ve genel toplam seçime göre değişir', async () => {
    render(<DoktorIstemModal belgeId={5} veri={VERI} onKapat={() => {}} onTamam={() => {}} />);
    const satir = screen.getByText('Hemogram').closest('tr')!;
    await act(async () => { (satir as HTMLElement).click() });
    expect(metin()).toMatch(/Laboratuvar \(seçili\)\s*90,00/);
    expect(metin()).toMatch(/Seçilenlerin toplamı \(2\)\s*390,00/);

    await act(async () => { screen.getByText(/Seçilenleri Ücrete Ekle/).click() });
    expect(ucretlendir).toHaveBeenCalledWith(5, { lab: [1], radyoloji: [7], goz: [] });
  });
});
