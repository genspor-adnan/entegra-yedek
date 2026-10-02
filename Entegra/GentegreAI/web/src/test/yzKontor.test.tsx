// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, fireEvent, render, screen, waitFor } from '@testing-library/react';

/**
 * YZ KONTÖR & KULLANIM (934) — mockup Ekranlar/Ayarlar/yz_kontor_kullanim.html.
 *   * göstergeler sunucudan (bakiye, bugün / sınır, bu ay);
 *   * satın alma: plan seçimi → fatura → sipariş SUNUCUDA fiyatlanır (istemci
 *     yalnız plan kodu + dönem yollar) → ödeme (simülasyon) → sonuç;
 *   * sözleşme onayı olmadan ödeme yok; satın alma yetkisi yoksa düğme yok.
 */
const api = {
  aiKontorOzet: vi.fn(), aiKontorPlanlar: vi.fn(), aiKontorSiparis: vi.fn(), aiKontorSimulasyon: vi.fn(),
  aiKontorHareketler: vi.fn(), aiKontorKullanicilar: vi.fn(), aiKontorSiparisler: vi.fn(),
  aiKontorAyar: vi.fn(), aiAbonelikIptal: vi.fn(), aiKontorSiparisDurum: vi.fn(),
};
vi.mock('../api/istemci', () => ({ api }));
vi.mock('../bilesenler/mesaj', () => ({
  mesaj: () => {}, onay: () => Promise.resolve(true), guvenli: (f: () => Promise<void>) => f(),
}));
const oturum = { satinAl: true };
vi.mock('../kimlik/OturumBaglami', () => ({ useOturum: () => ({
  aksiyonVar: (k: string) => k === 'ai.kontor_satin_al' && oturum.satinAl, yetki: () => true }) }));

const { YzKontor } = await import('../sayfalar/YzKontor');

const OZET = {
  kontor: { bakiye: 86, cagriUcreti: 1, uyariEsigi: 20, modelAktif: true, gunlukSinir: 500, kullaniciGunlukSinir: 0,
            ozRehber: true, ozTani: true, ozTetkik: true, ozIlac: true, otomatikEkPaket: '',
            bugunCagri: 14, bugunKontor: 12, buAy: 214, gecenAy: 168, basarisizAy: 3 },
  sureler: [{ ozellik: 'tani', ortalamaMs: 1500 }],
  seri: [{ gun: '2026-09-29', ozellik: 'tani', adet: 5 }],
  dagilim: [{ ozellik: 'tani', cagri: 98, kontor: 98 }],
  abonelik: null,
  saglayici: { tur: 'openai', model: 'openai/gpt-oss-120b', hazir: true, akilYurutme: 'low', zamanAsimiSn: 30,
               adres: 'api.groq.com', test: true },
  odemeSaglayici: 'simulasyon',
};
const PLANLAR = {
  planlar: [
    { kod: 'baslangic', ad: 'Başlangıç', aylikKontor: 500, aylikFiyat: 890, yillikFiyat: 8900, devreder: false, oneCikan: false, ozellikler: ['a'] },
    { kod: 'profesyonel', ad: 'Profesyonel', aylikKontor: 2000, aylikFiyat: 2490, yillikFiyat: 24900, devreder: true, oneCikan: true, ozellikler: ['b'] },
    { kod: 'kurumsal', ad: 'Kurumsal', aylikKontor: 10000, aylikFiyat: 8990, yillikFiyat: 89900, devreder: true, oneCikan: false, ozellikler: ['c'] },
  ],
  paketler: [{ kod: 'ek250', kontor: 250, fiyat: 449 }, { kod: 'ek500', kontor: 500, fiyat: 649 }],
  abonelik: null, kdvOrani: 0.2, odemeSaglayici: 'simulasyon',
};

beforeEach(() => {
  oturum.satinAl = true;
  Object.values(api).forEach(f => f.mockReset());
  api.aiKontorOzet.mockResolvedValue(OZET);
  api.aiKontorPlanlar.mockResolvedValue(PLANLAR);
  api.aiKontorSiparis.mockResolvedValue({ siparisId: 7, kontor: 24000, tutar: 24900, kdv: 4980, toplam: 29880,
                                          odemeSaglayici: 'simulasyon', odemeAdresi: null });
  api.aiKontorSimulasyon.mockResolvedValue({ durum: 2, yeniBakiye: 24086, faturaNo: 'GYZ-2026-000007', mesaj: '24.000 kontör yüklendi.' });
});

const dugme = (metin: RegExp) => screen.getAllByRole('button').find(b => metin.test(b.textContent ?? ''))!;

describe('YZ kontör ekranı', () => {
  it('göstergeler: bakiye, bugün / günlük sınır, TEST sağlayıcı rozeti', async () => {
    render(<YzKontor />);
    await waitFor(() => expect(document.body.textContent).toContain('Kontör bakiyesi'));
    const kpi = document.querySelector('.yk-kpi')!.textContent ?? '';
    expect(kpi).toContain('86');
    expect(kpi).toContain('/ 500');
    expect(document.body.textContent).toContain('TEST ortamı');
    expect(document.body.textContent).toContain('api.groq.com');
  });

  it('satın alma: yıllık Profesyonel → fatura → sipariş kodla gider → onaysız ödeme yok → başarılı ödeme', async () => {
    render(<YzKontor />);
    await waitFor(() => expect(document.body.textContent).toContain('Kontör bakiyesi'));
    await act(async () => { dugme(/Kontör Satın Al/).click() });
    await waitFor(() => expect(document.body.textContent).toContain('En çok tercih edilen'));
    await act(async () => { screen.getByRole('radio', { name: /Yıllık/ }).click() });
    expect(document.querySelector('.yk-plan.sec')!.textContent).toContain('24.900');
    await act(async () => { dugme(/Devam/).click() });

    // Fatura zorunlu alanları boşken sipariş açılmaz.
    await act(async () => { dugme(/Devam/).click() });
    expect(api.aiKontorSiparis).not.toHaveBeenCalled();
    fireEvent.change(screen.getByLabelText(/Fatura unvanı/), { target: { value: 'Örnek Tıp' } });
    fireEvent.change(screen.getByLabelText(/VKN/), { target: { value: '1234567890' } });
    fireEvent.change(screen.getByLabelText(/e-postası/), { target: { value: 'a@b.com' } });
    await act(async () => { dugme(/Devam/).click() });
    expect(api.aiKontorSiparis).toHaveBeenCalledWith(expect.objectContaining({ tur: 'plan', kod: 'profesyonel', donemAy: 12 }));
    // Tutar istemciden GİTMEZ.
    expect(api.aiKontorSiparis.mock.calls[0][0]).not.toHaveProperty('tutar');

    await waitFor(() => expect(document.body.textContent).toContain('simülasyon'));
    await act(async () => { dugme(/Başarılı ödeme/).click() });
    expect(api.aiKontorSimulasyon).not.toHaveBeenCalled();   // sözleşme onayı yok
    await act(async () => { fireEvent.click(screen.getByRole('checkbox', { name: /Sözleşme/ })) });
    await act(async () => { dugme(/Başarılı ödeme/).click() });
    expect(api.aiKontorSimulasyon).toHaveBeenCalledWith(7, true);
    await waitFor(() => expect(document.body.textContent).toContain('kontör yüklendi'));
    expect(document.body.textContent).toContain('GYZ-2026-000007');
  });

  it('iyzico: onaysız düğme pasif; onayla iyzico sayfasına gider (kart bu uygulamaya girmez)', async () => {
    api.aiKontorSiparis.mockResolvedValue({ siparisId: 9, kontor: 500, tutar: 649, kdv: 129.8, toplam: 778.8,
                                            odemeSaglayici: 'iyzico', odemeAdresi: 'https://sandbox-cpp.iyzipay.com/?token=abc' });
    const git = vi.fn();
    const eski = window.location;
    Object.defineProperty(window, 'location', { configurable: true, value: { ...eski, assign: git, search: '', pathname: '/yz-kontor' } });
    try {
      render(<YzKontor />);
      await waitFor(() => expect(document.body.textContent).toContain('Kontör bakiyesi'));
      await act(async () => { dugme(/Kontör Satın Al/).click() });
      await waitFor(() => expect(document.body.textContent).toContain('En çok tercih edilen'));
      await act(async () => { dugme(/Devam/).click() });
      fireEvent.change(screen.getByLabelText(/Fatura unvanı/), { target: { value: 'Örnek Tıp' } });
      fireEvent.change(screen.getByLabelText(/VKN/), { target: { value: '1234567890' } });
      fireEvent.change(screen.getByLabelText(/e-postası/), { target: { value: 'a@b.com' } });
      fireEvent.change(screen.getByLabelText(/^İl/), { target: { value: 'Ankara' } });
      await act(async () => { dugme(/Devam/).click() });
      expect(api.aiKontorSiparis.mock.calls[0][0].fatura).toEqual(expect.objectContaining({ il: 'Ankara' }));
      const ode = dugme(/iyzico ile öde/) as HTMLButtonElement;
      expect(ode.disabled).toBe(true);
      await act(async () => { fireEvent.click(screen.getByRole('checkbox', { name: /Sözleşme/ })) });
      await act(async () => { ode.click() });
      expect(git).toHaveBeenCalledWith('https://sandbox-cpp.iyzipay.com/?token=abc');
      expect(api.aiKontorSimulasyon).not.toHaveBeenCalled();
    } finally {
      Object.defineProperty(window, 'location', { configurable: true, value: eski });
    }
  });

  it('iyzico dönüşü: ?siparis=ID ile gelince sonuç penceresi açılır, adres temizlenir', async () => {
    api.aiKontorSiparisDurum.mockResolvedValue({ durum: 2, kontor: 500, toplam: 778.8, hata: '',
                                                 faturaNo: 'GYZ-2026-000009', yeniBakiye: 586 });
    window.history.replaceState(null, '', '/yz-kontor?siparis=9');
    render(<YzKontor />);
    await waitFor(() => expect(document.body.textContent).toContain('Ödeme alındı'));
    expect(api.aiKontorSiparisDurum).toHaveBeenCalledWith(9);
    expect(document.body.textContent).toContain('GYZ-2026-000009');
    expect(window.location.search).toBe('');
  });

  it('satın alma yetkisi yoksa Kontör Satın Al düğmesi yok', async () => {
    oturum.satinAl = false;
    render(<YzKontor />);
    await waitFor(() => expect(document.body.textContent).toContain('Kontör bakiyesi'));
    expect(screen.queryByText(/Kontör Satın Al/)).toBeNull();
  });
});
