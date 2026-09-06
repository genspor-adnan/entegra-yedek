// @vitest-environment jsdom
// jsdom SART: istemci oturum jetonunu localStorage'dan okuyor; saf node
//   ortaminda "localStorage is not defined" ile dusuyor.
import { describe, expect, it, vi, afterEach } from 'vitest';
import { api } from '../api/istemci';

/**
 * DOSYA YUKLEME ISTEGININ BICIMI (431).
 *
 * Dokuman yukleme her seferinde "beklenmeyen hata" veriyordu: istek JSON
 * yardimcisindan geciyordu ve govde FormData olmasina ragmen
 * "Content-Type: application/json" basligi ekleniyordu. Tarayici o zaman
 * multipart SINIRINI (boundary) yazamiyor, sunucu istegi
 * "Incorrect Content-Type" ile reddediyor.
 *
 * Kural: dosya iceren istekte Content-Type ELLE KONULMAZ - tarayici kendisi
 * "multipart/form-data; boundary=..." yazar.
 */
describe('dosya yukleme istegi', () => {
  afterEach(() => { vi.unstubAllGlobals() });

  function fetchYakala() {
    const cagrilar: { yol: string; secenek: RequestInit }[] = [];
    vi.stubGlobal('fetch', (yol: string, secenek: RequestInit) => {
      cagrilar.push({ yol, secenek });
      return Promise.resolve(new Response(JSON.stringify({ dokumanId: 1, mesaj: 'ok' }),
        { status: 200, headers: { 'Content-Type': 'application/json' } }));
    });
    return cagrilar;
  }

  it('klasore yuklemede Content-Type ELLE konulmaz', async () => {
    const cagrilar = fetchYakala();
    const dosya = new File([new Uint8Array([1, 2, 3])], 'test.pdf',
                           { type: 'application/pdf' });

    await api.dokumanKlasoreYukle(2, dosya);

    expect(cagrilar).toHaveLength(1);
    const basliklar = cagrilar[0].secenek.headers as Record<string, string>;
    expect(basliklar['Content-Type']).toBeUndefined();
    expect(cagrilar[0].secenek.body).toBeInstanceOf(FormData);
    expect((cagrilar[0].secenek.body as FormData).get('dosya')).toBeInstanceOf(File);
  });

  it('kategori verilirse gövdeye eklenir', async () => {
    const cagrilar = fetchYakala();
    const dosya = new File(['x'], 'a.txt', { type: 'text/plain' });

    await api.dokumanKlasoreYukle(2, dosya, 7);

    const govde = cagrilar[0].secenek.body as FormData;
    // Alan adi 431'de "kategoriId" oldu (eski adi belgeTuruId).
    expect(govde.get('kategoriId')).toBe('7');
  });

  it('JSON isteklerinde Content-Type KONULUR', async () => {
    // Karsit kontrol: duzeltme JSON yolunu bozmamali.
    const cagrilar = fetchYakala();
    await api.sigortaTazele(1).catch(() => { /* yanit sekli onemli degil */ });

    const basliklar = cagrilar[0].secenek.headers as Record<string, string>;
    expect(basliklar['Content-Type']).toBe('application/json');
  });
});
