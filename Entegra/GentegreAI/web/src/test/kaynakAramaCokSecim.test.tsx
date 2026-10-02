// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { act, render, waitFor } from '@testing-library/react';

/**
 * TANI ÇOK SEÇİM (kullanıcı): *"tanı çok seçimli olabilir.. her seçimde her
 * defasında ekran kapanmasın"*. `acikKalir` kipinde pencere seçimde kapanmaz,
 * eklenen satır işaretlenir, aynı kod ikinci kez gönderilmez; hata alan seçim
 * işaretlenmez.
 */
const liste = vi.fn();
const kullanilan = vi.fn();
vi.mock('../api/istemci', () => ({ api: {
  get liste() { return liste },
  katalogKullanilan: (...a: unknown[]) => kullanilan(...a),
} }));

const { KaynakArama } = await import('../bilesenler/KaynakArama');

const SATIRLAR = [
  { kod: 'I10', ad: 'Esansiyel hipertansiyon' },
  { kod: 'E11', ad: 'Tip 2 diyabet' },
];

/** Arama kutusuna yazar, debounce sonrası satırları bekler. */
const ara = async () => {
  const kutu = document.querySelector('input[type=search]') as HTMLInputElement;
  await act(async () => {
    const set = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')!.set!;
    set.call(kutu, 'hip');
    kutu.dispatchEvent(new Event('input', { bubbles: true }));
  });
  await waitFor(() => expect(document.querySelectorAll('.kaynak-arama tbody tr').length).toBe(2),
                { timeout: 2000 });
  return [...document.querySelectorAll('.kaynak-arama tbody tr')] as HTMLElement[];
};

describe('kaynak arama: çok seçim', () => {
  beforeEach(() => {
    document.body.innerHTML = '';
    liste.mockReset();
    liste.mockResolvedValue({ satirlar: SATIRLAR, toplamKayit: 2 });
  });

  const tikla = async (s: HTMLElement, o: MouseEventInit = {}) => {
    await act(async () => { s.dispatchEvent(new MouseEvent('click', { bubbles: true, ...o })) });
  };
  const kutu = (s: HTMLElement) => s.querySelector('input[type=checkbox]') as HTMLInputElement;
  const dugme = () => [...document.querySelectorAll('button')]
    .find(b => (b.textContent ?? '').includes('Seçilenleri Ekle')) as HTMLButtonElement | undefined;

  it('check deseni: tık işaretler, diğerleri KALIR, tekrar tık kaldırır; Ekle sırayla ekler ve KAPATIR', async () => {
    const onSec = vi.fn().mockResolvedValue(undefined);
    const onKapat = vi.fn();
    render(<KaynakArama kaynak="icd" baslik="ICD" acikKalir onSec={onSec} onKapat={onKapat} />);
    const satir = await ara();
    expect(kutu(satir[0])).not.toBeNull();

    // Tık: seçer, EKLEMEZ. Aynı satıra tekrar tık: kaldırır.
    await tikla(satir[0]);
    expect(kutu(satir[0]).checked).toBe(true);
    await tikla(satir[0]);
    expect(kutu(satir[0]).checked).toBe(false);
    expect(onSec).not.toHaveBeenCalled();

    // Düz tık EKLER - öncekinin işareti kalkmaz.
    await tikla(satir[0]);
    await tikla(satir[1]);
    expect(satir.map(s => kutu(s).checked)).toEqual([true, true]);
    expect(dugme()!.textContent).toContain('(2)');

    await act(async () => { dugme()!.click() });
    await waitFor(() => expect(onSec).toHaveBeenCalledTimes(2));
    expect(onSec.mock.calls.map(c => (c[0] as { kod: string }).kod)).toEqual(['I10', 'E11']);
    // Seçim sırasında kapanmadı, EKLE kapattı.
    expect(onKapat).toHaveBeenCalledTimes(1);
  });

  it('çift tık tek satırı ekler ve kapatır', async () => {
    const onSec = vi.fn().mockResolvedValue(undefined);
    const onKapat = vi.fn();
    render(<KaynakArama kaynak="icd" baslik="ICD" acikKalir onSec={onSec} onKapat={onKapat} />);
    const satir = await ara();
    await act(async () => { satir[1].dispatchEvent(new MouseEvent('dblclick', { bubbles: true })) });
    expect(onSec.mock.calls.map(c => (c[0] as { kod: string }).kod)).toEqual(['E11']);
    expect(onKapat).toHaveBeenCalledTimes(1);
  });

  it('hata alan seçim işaretli kalır, pencere açık kalır, yeniden denenebilir', async () => {
    const onSec = vi.fn().mockRejectedValueOnce(new Error('x')).mockResolvedValue(undefined);
    const onKapat = vi.fn();
    render(<KaynakArama kaynak="icd" baslik="ICD" acikKalir onSec={onSec} onKapat={onKapat} />);
    const satir = await ara();

    await tikla(satir[0]);
    await act(async () => { dugme()!.click() });
    await waitFor(() => expect(onSec).toHaveBeenCalledTimes(1));
    expect(kutu(satir[0]).checked).toBe(true);
    expect(onKapat).not.toHaveBeenCalled();          // hata: açık kalır
    await act(async () => { dugme()!.click() });
    await waitFor(() => expect(onSec).toHaveBeenCalledTimes(2));
    expect(onKapat).toHaveBeenCalledTimes(1);
  });

  it('SIK KULLANILANLAR: 6 satırdan 1 işaretlenince YALNIZ o eklenir (kullanıcı hatası)', async () => {
    kullanilan.mockResolvedValue({ son: [], sik: Array.from({ length: 6 },
      (_, i) => ({ kod: `K0${i}`, ad: `Tanı ${i}`, say: 6 - i })) });
    const onSec = vi.fn().mockResolvedValue(undefined);
    render(<KaynakArama kaynak="icd" baslik="ICD" acikKalir onSec={onSec} onKapat={() => {}} />);
    const sik = [...document.querySelectorAll('button')].find(b => (b.textContent ?? '').includes('Sık'))!;
    await act(async () => { sik.click() });
    await waitFor(() => expect(document.querySelectorAll('.kaynak-arama tbody tr').length).toBe(6));
    const satir = [...document.querySelectorAll('.kaynak-arama tbody tr')] as HTMLElement[];

    await tikla(satir[2]);
    expect(onSec).not.toHaveBeenCalled();             // tık EKLEMEZ
    expect(satir.map(s => kutu(s).checked)).toEqual([false, false, true, false, false, false]);
    expect(dugme()!.textContent).toContain('(1)');
    await act(async () => { dugme()!.click() });
    await waitFor(() => expect(onSec).toHaveBeenCalledTimes(1));
    expect((onSec.mock.calls[0][0] as { kod: string }).kod).toBe('K02');
  });

  it('önceki listede işaretlenen satır ÇİP olarak görünür, ✕ ile kaldırılınca eklenmez', async () => {
    kullanilan.mockResolvedValue({ son: [], sik: [{ kod: 'Z00.1', ad: 'Kontrol', say: 3 }] });
    const onSec = vi.fn().mockResolvedValue(undefined);
    render(<KaynakArama kaynak="icd" baslik="ICD" acikKalir onSec={onSec} onKapat={() => {}} />);
    const satir = await ara();
    await tikla(satir[0]);                                   // I10 (arama listesi)

    const sik = [...document.querySelectorAll('button')].find(b => (b.textContent ?? '').includes('Sık'))!;
    await act(async () => { sik.click() });
    await waitFor(() => expect(document.querySelectorAll('.kaynak-arama tbody tr').length).toBe(1));
    await tikla(document.querySelector('.kaynak-arama tbody tr') as HTMLElement);  // Z00.1

    const cipler = () => [...document.querySelectorAll('.kaynak-arama-cip')].map(c => c.textContent ?? '');
    expect(cipler().some(c => c.startsWith('I10'))).toBe(true);   // görünmeyen satır görünür
    expect(cipler().some(c => c.startsWith('Z00.1'))).toBe(true);
    const kaldir = document.querySelector('.kaynak-arama-cip button[aria-label^="I10"]') as HTMLButtonElement;
    await act(async () => { kaldir.click() });
    expect(dugme()!.textContent).toContain('(1)');
    await act(async () => { dugme()!.click() });
    await waitFor(() => expect(onSec).toHaveBeenCalledTimes(1));
    expect((onSec.mock.calls[0][0] as { kod: string }).kod).toBe('Z00.1');
  });

  it('şablon listesi (931): düğme şablonun sık tanılarını gösterir, seçilen eklenir', async () => {
    const onSec = vi.fn().mockResolvedValue(undefined);
    const sablon = vi.fn().mockResolvedValue([{ kod: 'J06.9', ad: 'Akut ÜSYE' }]);
    render(<KaynakArama kaynak="icd" baslik="ICD" acikKalir sablon={sablon} sablonBaslik="Şablon Tanıları"
                        onSec={onSec} onKapat={() => {}} />);
    const d = [...document.querySelectorAll('button')].find(b => (b.textContent ?? '').includes('Şablon Tanıları'))!;
    await act(async () => { d.click() });
    await waitFor(() => expect(document.querySelectorAll('.kaynak-arama tbody tr').length).toBe(1));
    expect(sablon).toHaveBeenCalled();
    expect(liste).not.toHaveBeenCalled();
    const satir = document.querySelector('.kaynak-arama tbody tr') as HTMLElement;
    await act(async () => { satir.dispatchEvent(new MouseEvent('dblclick', { bubbles: true })) });
    expect((onSec.mock.calls[0][0] as { kod: string }).kod).toBe('J06.9');
  });

  it('YZ önerisi: düğme bir kez çağırır, gerekçe/olasılık ve notlar görünür, seçilen eklenir', async () => {
    const onSec = vi.fn().mockResolvedValue(undefined);
    const yz = vi.fn().mockResolvedValue({
      satirlar: [{ kod: 'J03.9', ad: 'Akut tonsillit', olasilik: 'yuksek', gerekce: 'ateş ve eksüda' }],
      notlar: ['⚠ peritonsiller apse dışlanmalı'], uyari: 'YZ önerisidir; tanı kararı hekimindir.' });
    render(<KaynakArama kaynak="icd" baslik="ICD" acikKalir yz={yz} onSec={onSec} onKapat={() => {}} />);
    const d = [...document.querySelectorAll('button')].find(b => (b.textContent ?? '').includes('YZ Önerisi'))!;
    await act(async () => { d.click() });
    await waitFor(() => expect(document.querySelectorAll('.kaynak-arama tbody tr').length).toBe(1));
    const govde = document.body.textContent ?? '';
    expect(govde).toContain('ateş ve eksüda');
    expect(govde).toContain('Yüksek');
    expect(govde).toContain('peritonsiller apse');
    expect(govde).toContain('tanı kararı hekimindir');
    expect(yz).toHaveBeenCalledTimes(1);
    expect(liste).not.toHaveBeenCalled();
    const satir = document.querySelector('.kaynak-arama tbody tr') as HTMLElement;
    await act(async () => { satir.dispatchEvent(new MouseEvent('dblclick', { bubbles: true })) });
    expect((onSec.mock.calls[0][0] as { kod: string }).kod).toBe('J03.9');
    expect(yz).toHaveBeenCalledTimes(1);   // çizim tekrarı modeli yeniden çağırmaz
  });
});
