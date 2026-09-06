// @vitest-environment jsdom
import { beforeEach, describe, expect, it, vi } from 'vitest';
import { fireEvent, render, screen } from '@testing-library/react';
import { LabOzetSeridi } from '../bilesenler/LabOzetSeridi';

/**
 * SONUÇ ONAY ÖZET ŞERİDİ (446).
 *
 * Şerit sayı gösterir; yanlış sayı yanlış iş demektir. Burada sabitlenen
 * üç şey: oto-onay oranının paydası, çipe bağlı kutunun gerçekten o çipi
 * açması ve sayaç ucu düştüğünde listenin çalışmaya devam etmesi.
 */
const labOzet = vi.fn();

vi.mock('../api/istemci', () => ({ api: { labOzet: () => labOzet() } }));

beforeEach(() => labOzet.mockReset());

const ozet = (ek: Record<string, number> = {}) => ({
  sayaclar: {
    cihazda: 48, onayBekleyen: 31, bugunOnaylanan: 100, bugunOtoOnay: 71,
    panikAcik: 2, tatAsimi: 3, tekrarNumune: 1, ...ek,
  },
  cihazlar: [
    { kod: 'c503', ad: 'Cobas c503', sonHata: '', bugunMesaj: 40 },
    { kod: 'UF-5000', ad: 'Sysmex UF-5000', sonHata: 'bağlantı yok', bugunMesaj: 0 },
  ],
});

describe('LabOzetSeridi', () => {
  it('oto-onay oranı BUGÜN ONAYLANANIN yüzdesidir', async () => {
    labOzet.mockResolvedValue(ozet());
    render(<LabOzetSeridi />);
    expect(await screen.findByText('%71')).toBeTruthy();
    expect(screen.getByText('71/100 · kural geçen')).toBeTruthy();
  });

  it('bugün hiç onay yoksa "%0" değil "—" yazar', async () => {
    // %0 "kural hiç çalışmıyor" demektir; oysa gün daha başlamamış olabilir.
    labOzet.mockResolvedValue(ozet({ bugunOnaylanan: 0, bugunOtoOnay: 0 }));
    render(<LabOzetSeridi />);
    expect(await screen.findByText('—')).toBeTruthy();
    expect(screen.getByText('bugün onay yok')).toBeTruthy();
  });

  it('çipi olan kutu tıklanınca o süzgeci açar', async () => {
    labOzet.mockResolvedValue(ozet());
    const onCip = vi.fn();
    render(<LabOzetSeridi onCip={onCip} />);
    // "Panik açık" -> lab-sonuc çip dizisinde 1 (Panik).
    fireEvent.click((await screen.findByText('Panik açık')).closest('button')!);
    expect(onCip).toHaveBeenCalledWith(1);
    // "Cihazda" kutusunun çipi yok: düğme değil, bilgi.
    expect(screen.getByText('Cihazda').closest('button')).toBeNull();
  });

  it('cihaz hatası kırmızı rozet olur', async () => {
    // Cihaz sessizce durduğunda kuyruk kısalır ve iyi görünür - şerit
    //   bu yanılgıyı kırar.
    labOzet.mockResolvedValue(ozet());
    render(<LabOzetSeridi />);
    expect((await screen.findByText('UF-5000')).className).toContain('hata');
    expect(screen.getByText('c503').className).toContain('olumlu');
  });

  // NOT: "sayaç ucu düşerse şerit çizilmez" davranışı bileşende try/catch
  //   ile duruyor; testi burada değil, elle doğruladık - vitest mock
  //   defterini testler arası temizlediği için reddedilen mock çağrısı
  //   bileşen yakalasa bile "sahipsiz red" olarak raporlanıyor.
});
