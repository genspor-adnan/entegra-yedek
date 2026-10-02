// @vitest-environment jsdom
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { istek } from '../api/cekirdek';

/**
 * SEKMELER ARASI YENILEME (denetim 28.09.2026 #6).
 *
 * Sunucu tekrar kullanilan refresh'te AILEYI iptal eder (dogru koruma). Iki
 * sekme ayni anda 401 alip ikisi de ayni refresh'le yenilerse ikincisi
 * "tekrar kullanim" sayilir ve iki sekme birden disari duser. Istemci bu
 * yuzden: (a) sekmeler arasi kilitle tek yenileme yapar, (b) kilidi alan
 * sekme token'in bu arada BASKA sekmece yenilendigini gorurse sunucuya hic
 * gitmez.
 */
const yanit = (durum: number, govde: unknown = {}) =>
  new Response(JSON.stringify(govde), { status: durum, headers: { 'Content-Type': 'application/json' } });

let fetchTaklit: ReturnType<typeof vi.fn>;

beforeEach(() => {
  localStorage.clear();
  localStorage.setItem('gentegre.access', 'ESKI');
  localStorage.setItem('gentegre.refresh', 'R1');
  fetchTaklit = vi.fn();
  vi.stubGlobal('fetch', fetchTaklit);
});
// Sekme ici birlestirme sozu bir sonraki tikte birakilir; testler birbirinin
//   sozunu devralmasin.
afterEach(async () => { vi.unstubAllGlobals(); await new Promise(r => setTimeout(r, 5)) });

const yenilemeCagrisi = () =>
  fetchTaklit.mock.calls.filter(c => String(c[0]).endsWith('/api/kimlik/yenile')).length;

describe('401 sonrasi yenileme', () => {
  it('baska sekme token yenilediyse sunucuya gitmeden yeni token la tekrar dener', async () => {
    fetchTaklit.mockImplementation(async (url: string, s: RequestInit) => {
      const auth = (s.headers as Record<string, string>).Authorization;
      if (url.endsWith('/api/x') && auth === 'Bearer ESKI') {
        // Istek yoldayken diger sekme yeniledi ve depoya yazdi.
        localStorage.setItem('gentegre.access', 'YENI');
        localStorage.setItem('gentegre.refresh', 'R2');
        return yanit(401, { hata: { kod: 'YETKISIZ', mesaj: '', izlemeNo: '' } });
      }
      if (url.endsWith('/api/x') && auth === 'Bearer YENI') return yanit(200, { tamam: true });
      return yanit(500);
    });
    await expect(istek('/api/x')).resolves.toEqual({ tamam: true });
    expect(yenilemeCagrisi()).toBe(0);
  });

  it('ayni sekmede es zamanli 401 ler tek yenileme yapar', async () => {
    fetchTaklit.mockImplementation(async (url: string, s: RequestInit) => {
      const auth = (s.headers as Record<string, string>)?.Authorization;
      if (url.endsWith('/api/kimlik/yenile'))
        return yanit(200, { accessToken: 'YENI', refreshToken: 'R2', sonaErme: '' });
      return auth === 'Bearer YENI' ? yanit(200, { ok: 1 })
        : yanit(401, { hata: { kod: 'YETKISIZ', mesaj: '', izlemeNo: '' } });
    });
    await Promise.all([istek('/api/a'), istek('/api/b'), istek('/api/c')]);
    expect(yenilemeCagrisi()).toBe(1);
    expect(localStorage.getItem('gentegre.refresh')).toBe('R2');
  });

  it('yenileme 503 donerse token lar silinmez', async () => {
    fetchTaklit.mockImplementation(async (url: string) =>
      url.endsWith('/api/kimlik/yenile') ? yanit(503)
        : yanit(401, { hata: { kod: 'YETKISIZ', mesaj: '', izlemeNo: '' } }));
    await expect(istek('/api/x')).rejects.toBeTruthy();
    expect(localStorage.getItem('gentegre.refresh')).toBe('R1');
  });

  it('sunucu refresh i reddederse (401) token lar silinir', async () => {
    fetchTaklit.mockImplementation(async () =>
      yanit(401, { hata: { kod: 'YETKISIZ', mesaj: '', izlemeNo: '' } }));
    await expect(istek('/api/x')).rejects.toBeTruthy();
    expect(localStorage.getItem('gentegre.refresh')).toBeNull();
  });

  it('Web Locks varsa yenileme kilit altinda calisir', async () => {
    const istenen: string[] = [];
    vi.stubGlobal('navigator', {
      ...navigator,
      locks: { request: async (ad: string, f: () => Promise<unknown>) => { istenen.push(ad); return f() } },
    });
    fetchTaklit.mockImplementation(async (url: string, s: RequestInit) => {
      const auth = (s.headers as Record<string, string>)?.Authorization;
      if (url.endsWith('/api/kimlik/yenile'))
        return yanit(200, { accessToken: 'YENI', refreshToken: 'R2', sonaErme: '' });
      return auth === 'Bearer YENI' ? yanit(200, {})
        : yanit(401, { hata: { kod: 'YETKISIZ', mesaj: '', izlemeNo: '' } });
    });
    await istek('/api/x');
    expect(istenen).toEqual(['gentegre.yenile']);
  });
});
