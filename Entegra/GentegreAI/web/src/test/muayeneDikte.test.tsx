// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { act, fireEvent, render, screen } from '@testing-library/react';

/**
 * MUAYENE DİKTESİ (kullanıcı: "dikte ekranına 3 alan.. şikayet hikaye
 * değerlendirme.. mouse hangisinde ise oraya yazsa"). Alanlar kartın güncel
 * metniyle açılır; tanınan metin FARENİN üstünde olduğu alanın sonuna
 * eklenir; "Karta aktar" yalnız DEĞİŞEN alanları düzeltilmiş olarak yazar.
 */
const { MuayeneDikte, sozluNoktalama } = await import('../bilesenler/MuayeneDikte');

const HEDEFLER = [{ ad: 'sikayet', baslik: 'Şikâyet' }, { ad: 'hikaye', baslik: 'Hikâye' },
                  { ad: 'karar', baslik: 'Değerlendirme / Sonuç' }];

/** Sahte tarayıcı ses tanıyıcı: testten "söylet". */
class SahteTaniyici {
  static son: SahteTaniyici | null = null;
  lang = ''; continuous = false; interimResults = false;
  onresult: ((o: unknown) => void) | null = null;
  onerror: ((o: unknown) => void) | null = null;
  onend: (() => void) | null = null;
  start() { SahteTaniyici.son = this }
  stop() { /* yok */ }
  soyle(metin: string) {
    const sonuc = Object.assign([{ transcript: metin }], { isFinal: true });
    this.onresult?.({ resultIndex: 0, results: [sonuc] });
  }
}

describe('muayene diktesi', () => {
  beforeEach(() => { document.body.innerHTML = ''; SahteTaniyici.son = null });
  afterEach(() => {
    delete (window as unknown as Record<string, unknown>).webkitSpeechRecognition;
    Object.defineProperty(window, 'isSecureContext', { value: false, configurable: true });
  });

  it('söylenen noktalama: virgül / nokta / yeni satır', () => {
    expect(sozluNoktalama('baş ağrısı virgül bulantı nokta yeni satır ateş yok'))
      .toBe('baş ağrısı, bulantı.\nateş yok');
  });

  it('açılınca otomatik dinler; üç alan kartın metniyle açılır; FARE hangi alandaysa dikte oraya yazar; yalnız değişen aktarılır', async () => {
    (window as unknown as Record<string, unknown>).webkitSpeechRecognition = SahteTaniyici;
    Object.defineProperty(window, 'isSecureContext', { value: true, configurable: true });
    const onYaz = vi.fn();
    const onKapat = vi.fn();
    const kart: Record<string, string> = { sikayet: 'Baş ağrısı.', hikaye: '', karar: '' };
    render(<MuayeneDikte hedefler={HEDEFLER} degerOku={ad => kart[ad] ?? ''}
                         onYaz={onYaz} onKapat={onKapat} />);
    expect((screen.getByLabelText('Şikâyet') as HTMLTextAreaElement).value).toBe('Baş ağrısı.');

    // PENCERE ACILINCA KENDILIGINDEN DINLER (kullanici): Baslat'a basilmadan.
    const t = SahteTaniyici.son!;
    expect(t).not.toBeNull();
    expect(screen.getByText(/Durdur/)).toBeTruthy();

    // Fare Hikâye'nin üstünde -> oraya.
    const hikayeKutu = screen.getByLabelText('Hikâye').closest('.md-alan') as HTMLElement;
    await act(async () => { fireEvent.mouseEnter(hikayeKutu) });
    await act(async () => { t.soyle('üç gündür var virgül geceleri artıyor') });
    expect((screen.getByLabelText('Hikâye') as HTMLTextAreaElement).value)
      .toBe('üç gündür var, geceleri artıyor');

    // Fare Değerlendirme'ye geçti -> sonraki cümle oraya.
    const kararKutu = screen.getByLabelText('Değerlendirme / Sonuç').closest('.md-alan') as HTMLElement;
    await act(async () => { fireEvent.mouseEnter(kararKutu) });
    await act(async () => { t.soyle('istirahat önerildi') });
    expect((screen.getByLabelText('Değerlendirme / Sonuç') as HTMLTextAreaElement).value)
      .toBe('istirahat önerildi');
    expect((screen.getByLabelText('Hikâye') as HTMLTextAreaElement).value)
      .toBe('üç gündür var, geceleri artıyor');

    await act(async () => { (screen.getByText(/Karta aktar/, { selector: 'button' })).click() });
    // Şikâyet değişmedi: yazılmaz. Diğer ikisi düzeltilmiş (büyük harf + nokta).
    expect(onYaz.mock.calls).toEqual([
      ['hikaye', 'Üç gündür var, geceleri artıyor.'],
      ['karar', 'İstirahat önerildi.'],
    ]);
    expect(onKapat).toHaveBeenCalled();
  });

  it('ses tanıma yoksa / güvenli adres değilse Başlat kapalı ve sebep yazılı', () => {
    render(<MuayeneDikte hedefler={HEDEFLER} degerOku={() => ''}
                         onYaz={() => {}} onKapat={() => {}} />);
    const baslat = screen.getByText(/Başlat/).closest('button') as HTMLButtonElement;
    expect(baslat.disabled).toBe(true);
    expect(document.body.textContent).toMatch(/https|desteklemiyor/);
  });
});
