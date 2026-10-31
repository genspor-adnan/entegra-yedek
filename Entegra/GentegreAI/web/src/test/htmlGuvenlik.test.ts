// @vitest-environment jsdom
import { describe, expect, it } from 'vitest';
import { h, htmlTemizle, yazdirmaSargisi } from '../bilesenler/htmlGuvenlik';

/** KOD İNCELEME RAPORU 28.10.2026 — B03: yazdırma pencerelerinde kullanıcı metni HTML olarak yorumlanmaz. */
describe('html güvenliği', () => {
  it('h: işaretleyiciler düz metin olur', () => {
    expect(h('<svg onload="x()">')).toBe('&lt;svg onload=&quot;x()&quot;&gt;');
    expect(h(`<img src=x onerror='y'>`)).toBe('&lt;img src=x onerror=&#39;y&#39;&gt;');
    expect(h(null)).toBe('');
    expect(h('Ç & Ş')).toBe('Ç &amp; Ş');
  });
  it('htmlTemizle: script, olay ve javascript: adresi düşer; görünüm kalır', () => {
    const t = htmlTemizle('<html><head><style>td{color:red}</style><script>alert(1)</script></head>'
      + '<body><table><tr><td onclick="x()">Fatura</td></tr></table><a href="javascript:x()">a</a>'
      + '<img src="data:image/png;base64,AA" onerror="y()"><iframe src="https://kotu"></iframe></body></html>');
    expect(t).not.toMatch(/<script|onclick|onerror|javascript:|<iframe/i);
    expect(t).toContain('<style>td{color:red}</style>');
    expect(t).toContain('>Fatura</td>');
    expect(t).toContain('data:image/png;base64,AA');
  });

  /** K54: belge opak kökenli sandbox iframe'de; allow-same-origin YOK. */
  it('yazdirmaSargisi: sandbox iframe, başlık dışta, yazdırma içte', () => {
    const s = yazdirmaSargisi('<html><head><title>e-Fatura</title></head><body><p>x</p><script>a()</script></body></html>', 'GNY1 "Firma"', true);
    expect(s).toContain('<iframe sandbox="allow-scripts allow-modals" srcdoc="');
    expect(s).not.toContain('allow-same-origin');
    expect(s).toContain('<title>GNY1 &quot;Firma&quot;</title>');
    expect(s).not.toContain('<title>e-Fatura</title>');
    expect(s).not.toContain('a()');                         // temizlik hâlâ uygulanır
    expect(s).toContain('print()');                         // yazdırma iframe içinden
    expect(yazdirmaSargisi('<p>y</p>', 'B', false)).not.toContain('print()');
  });
});
