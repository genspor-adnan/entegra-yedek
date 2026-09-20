// @vitest-environment jsdom
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { EnabizButonu } from '../bilesenler/EnabizButonu';

/**
 * e-NABIZ BUTONU — BAKANLIK STANDARDI (KTS denetim maddesi H8).
 *
 * Denetim üç şeye bakar: resim, yer ve **hint**. Düğme iki ekranda ayrı
 * yazılmıştı; ortaklaştırıldı. Test, denetimde sorulan davranışları tutuyor:
 * ipucu metni var mı, yetkisiz kullanıcıda düğme hiç çiziliyor mu, ve
 * pop-up İSTEKTEN ÖNCE mi açılıyor (tarayıcı `await` sonrası açılan pencereyi
 * engelliyor - hekim "bir şey olmadı" diyordu).
 */
const enabizErisimAc = vi.fn();
let aksiyonlar = ['enabiz.erisim', 'enabiz.mesaj'];

vi.mock('../api/istemci', () => ({
  api: { enabizErisimAc: (g: unknown) => enabizErisimAc(g) },
}));

vi.mock('../kimlik/OturumBaglami', () => ({
  useOturum: () => ({
    kullanici: null, aksiyonlar: [], kaynaklar: [], yukleniyor: false,
    yetki: () => true, aksiyonDegeri: () => 0,
    aksiyonVar: (kod: string) => aksiyonlar.includes(kod),
  }),
}));

describe('e-Nabız butonu (H8)', () => {
  beforeEach(() => {
    enabizErisimAc.mockReset();
    aksiyonlar = ['enabiz.erisim', 'enabiz.mesaj'];
  });

  it('İPUCU (hint) taşır ve etiketi standarttır', () => {
    render(<EnabizButonu tur="erisim" hastaId={5} />);
    const dugme = screen.getByRole('button');

    expect(dugme.textContent).toContain('e-Nabız Kayıtları');
    // Hint denetimde ayrıca sorulur: ne olacağını ve SMS/e-Devlet onayını
    //   söylemeli.
    expect(dugme.getAttribute('title')).toContain('e-Nabız');
    expect(dugme.getAttribute('title')).toContain('SMS');
  });

  it('YETKİSİZ kullanıcıda düğme HİÇ çizilmez', () => {
    aksiyonlar = [];
    const { container } = render(<EnabizButonu tur="erisim" hastaId={5} />);
    // Tıklanınca "yetkiniz yok" demek, olmayan bir kapıyı göstermektir.
    expect(container.querySelector('button')).toBeNull();
  });

  it('HASTASIZ bağlamda çizilmez', () => {
    const { container } = render(<EnabizButonu tur="erisim" hastaId={0} />);
    expect(container.querySelector('button')).toBeNull();
  });

  it('SEKME İSTEKTEN ÖNCE açılır ve adres sonradan yazılır', async () => {
    const sekme = { location: { href: '' }, close: vi.fn() };
    const ac = vi.fn(() => sekme as unknown as Window);
    vi.stubGlobal('open', ac);

    let cozum: ((d: { adres: string }) => void) | null = null;
    enabizErisimAc.mockReturnValue(new Promise(c => { cozum = c }));

    render(<EnabizButonu tur="erisim" hastaId={5} muayeneId={9} />);
    fireEvent.click(screen.getByRole('button'));

    // İSTEK DAHA BİTMEDEN sekme açılmış olmalı - tarayıcı kuralı bu.
    expect(ac).toHaveBeenCalledWith('', '_blank');
    expect(enabizErisimAc).toHaveBeenCalledWith(
      { hastaId: 5, muayeneId: 9, belgeId: null });

    cozum!({ adres: 'https://enabiz.gov.tr/paylasim?keyH=abc' });
    await waitFor(() => expect(sekme.location.href).toContain('keyH=abc'));
    expect(sekme.close).not.toHaveBeenCalled();

    vi.unstubAllGlobals();
  });

  it('HATA gelince açılan sekme KAPATILIR', async () => {
    const sekme = { location: { href: '' }, close: vi.fn() };
    vi.stubGlobal('open', vi.fn(() => sekme as unknown as Window));
    enabizErisimAc.mockRejectedValue(new Error('erişim reddedildi'));

    render(<EnabizButonu tur="erisim" hastaId={5} />);
    fireEvent.click(screen.getByRole('button'));

    // Boş sekme ekranda kalırsa hekim "açıldı ama boş" der; kapatılmalı.
    await waitFor(() => expect(sekme.close).toHaveBeenCalled());
    expect(sekme.location.href).toBe('');

    vi.unstubAllGlobals();
  });

  it('MESAJ düğmesi istek atmaz, ekranın penceresini açar', () => {
    const onMesaj = vi.fn();
    render(<EnabizButonu tur="mesaj" hastaId={5} onMesaj={onMesaj} />);
    fireEvent.click(screen.getByRole('button'));

    expect(onMesaj).toHaveBeenCalled();
    expect(enabizErisimAc).not.toHaveBeenCalled();
  });
});
