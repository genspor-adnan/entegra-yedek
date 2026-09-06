// @vitest-environment jsdom
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { AiRehberPaneli } from '../bilesenler/AiRehberPaneli';

/**
 * AI REHBER PANELİ (447).
 *
 * Panel <b>rehberdir, operatör değildir</b>: yalnız sunucunun verdiğini çizer.
 * Buradaki testler iki şeyi tutuyor - sunucu bir ekran önermediyse panel düğme
 * uydurmaz, ve emin olunmayan cevapta güven açıkça yazılır.
 */
const aiRehber = vi.fn();
vi.mock('../api/istemci', () => ({ api: { aiRehber: (g: unknown) => aiRehber(g) } }));

beforeEach(() => aiRehber.mockClear());

const yanit = (ek: Record<string, unknown> = {}) => ({
  cevap: '**Yeni hasta kaydı açma** — 2 adım:',
  adimlar: [
    { no: 1, metin: 'Kayıt Kabul › Hasta Listesi ekranını açın.', ekran: 'hasta',
      rota: '/hasta' },
    { no: 2, metin: 'Yeni düğmesine basın.' },
  ],
  onerilenEkranlar: [{ kaynak: 'hasta', ad: 'Hastalar', rota: '/hasta',
                       yol: 'Hasta › Hastalar', menuGrup: 'Hasta' }],
  onerilenAksiyonlar: [{ kod: 'yeni', ad: '＋ Yeni', ekran: 'hasta-liste' }],
  guvenSkoru: 0.9, uyarilar: [], konuKod: 'hasta-kayit', kaynakTuru: 1,
  kontorBakiye: 0, ...ek,
});

const ac = () => {
  render(<MemoryRouter><AiRehberPaneli urunModu={2} /></MemoryRouter>);
  fireEvent.click(screen.getByTitle(/AI Rehber/i));
};

describe('AiRehberPaneli', () => {
  it('soruyu AKTİF SAYFA bağlamıyla gönderir', async () => {
    aiRehber.mockResolvedValue(yanit());
    ac();
    fireEvent.change(screen.getByPlaceholderText(/Nasıl yapılır/i),
                     { target: { value: 'hasta kaydı' } });
    fireEvent.click(screen.getByText('Sor'));
    expect(await screen.findByText(/Kayıt Kabul/)).toBeTruthy();
    // "Bu ekranda ne yapabilirim" sorusunun cevabı sayfaya bağlıdır.
    expect(aiRehber).toHaveBeenCalledWith(expect.objectContaining({
      kullaniciMesaji: 'hasta kaydı', aktifMod: 2, aktifSayfa: '/',
    }));
  });

  it('ekran düğmesi YALNIZ sunucu rota verdiyse çizilir', async () => {
    // Sunucu yetkisi olmayan ekranın rotasını hiç göndermez; panel kendi
    //   listesinden düğme uyduramaz.
    aiRehber.mockResolvedValue(yanit());
    ac();
    fireEvent.click(screen.getByText(/Yeni hasta kaydı/));
    expect(await screen.findByText(/Kayıt Kabul/)).toBeTruthy();
    expect(screen.getAllByText('Ekranı aç')).toHaveLength(1);   // 2. adımda yok
  });

  it('düşük güvende rozet UYARI rengine döner', async () => {
    aiRehber.mockResolvedValue(yanit({ guvenSkoru: 0.42 }));
    ac();
    fireEvent.click(screen.getByText(/Yeni hasta kaydı/));
    const rozet = await screen.findByText('güven %42');
    expect(rozet.className).toContain('uyari');
  });

  it('uyarı ve eksik bilgi sorusu gösterilir', async () => {
    aiRehber.mockResolvedValue(yanit({
      uyarilar: ['"lab" modülü bu kurulumda kapalı görünüyor.'],
      eksikBilgiSorusu: 'Hangi modülde çalışıyorsunuz?',
    }));
    ac();
    fireEvent.click(screen.getByText(/Yeni hasta kaydı/));
    expect(await screen.findByText(/modülü bu kurulumda kapalı/)).toBeTruthy();
    expect(screen.getByText(/Hangi modülde çalışıyorsunuz/)).toBeTruthy();
  });
});
