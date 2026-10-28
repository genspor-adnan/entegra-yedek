/**
 * YAZDIRMA PENCERESİ GÜVENLİĞİ (kod inceleme raporu 28.10.2026 B03): `document.write` ile açılan yazdırma
 * pencereleri AYNI KÖKENDE çalışır - kayıttaki bir metin (yatak adı, masraf açıklaması) HTML olarak yorumlanırsa
 * `<svg onload=...>` script çalıştırır ve localStorage'daki oturum anahtarlarına ulaşır.
 *
 *  - `h(deger)`: düz metni HTML'e GÖMERKEN her interpolasyonda kullanılır (& < > " ' kaçışı).
 *  - `htmlTemizle(html)`: dışarıdan gelen HAZIR HTML (e-Fatura XSLT çıktısı - gelen faturanın şablonu karşı
 *    firmadan gelir) yazılmadan önce: script / iframe / object / embed / base / meta-refresh, `on…` olayları ve
 *    `javascript:` adresleri atılır; görünüm (CSS, tablo, resim) kalır.
 */
export function h(deger: unknown): string {
  return String(deger ?? '')
    .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
}

const TEHLIKELI_ETIKET = 'script, iframe, frame, frameset, object, embed, base, applet, meta[http-equiv]';

export function htmlTemizle(html: string): string {
  const belge = new DOMParser().parseFromString(html, 'text/html');
  belge.querySelectorAll(TEHLIKELI_ETIKET).forEach(e => e.remove());
  belge.querySelectorAll('*').forEach(e => {
    for (const a of Array.from(e.attributes)) {
      const ad = a.name.toLowerCase();
      const deger = a.value.replace(/[\s\u0000-\u001f]/g, '').toLowerCase();
      if (ad.startsWith('on')) e.removeAttribute(a.name);
      else if (['href', 'src', 'action', 'formaction', 'xlink:href', 'data'].includes(ad)
               && (deger.startsWith('javascript:') || deger.startsWith('vbscript:')
                   || (deger.startsWith('data:') && !deger.startsWith('data:image/'))))
        e.removeAttribute(a.name);
    }
  });
  return '<!doctype html>' + belge.documentElement.outerHTML;
}
