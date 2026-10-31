// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { createHash } from 'node:crypto';
import { apiKokeni, cspMetni, satirIciBetikler } from '../../csp';
import { YAZDIR_BETIGI } from '../bilesenler/yazdirBetigi';
import { yazdirmaSargisi } from '../bilesenler/htmlGuvenlik';

const hash = (s: string) => `'sha256-${createHash('sha256').update(s, 'utf8').digest('base64')}'`;

/** KOD İNCELEME 30.10.2026 — K61: içerik güvenlik politikası. */
describe('CSP', () => {
  it('satır içi betik hash ile, unsafe-inline / eval yok, istek yalnız kendi kökene', () => {
    const html = '<html><head><script>var a=1</script><script type="module" src="/x.js"></script></head></html>';
    const csp = cspMetni(html);
    expect(satirIciBetikler(html)).toEqual(['var a=1']);
    expect(csp).toContain(hash('var a=1'));
    expect(csp).toContain(hash(YAZDIR_BETIGI));
    const script = csp.split('; ').find(p => p.startsWith('script-src'))!;
    expect(script).not.toContain('unsafe-inline');
    expect(script).not.toContain('unsafe-eval');
    expect(csp).toContain("connect-src 'self'");
    expect(csp).toContain("object-src 'none'");
  });

  it('yazdırma sargısının betiği tam olarak hash\'li ortak metin', () => {
    const s = yazdirmaSargisi('<p>x</p>', 'B', true);
    // srcdoc kaçışlı: &quot; geri çevrilince ortak metin birebir çıkmalı
    const coz = s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&#39;/g, "'").replace(/&amp;/g, '&');
    expect(coz).toContain(`<script>${YAZDIR_BETIGI}</script>`);
  });

  it('mutlak VITE_API köken olarak eklenir, göreli yol eklenmez', () => {
    expect(apiKokeni('/feta')).toBeUndefined();
    expect(apiKokeni('http://localhost:5180')).toBe('http://localhost:5180');
    expect(cspMetni('', 'http://localhost:5180')).toContain("connect-src 'self' http://localhost:5180");
  });
});
