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

/**
 * YAZDIRMA SARGISI (kod inceleme 30.10.2026 K54): `htmlTemizle` kara listedir - DOMParser → outerHTML yeniden
 * serileştirmesi mXSS'e açık; kaçan tek yük aynı kökende localStorage'daki oturum anahtarını alırdı. Belge artık
 * `sandbox` iframe'de (allow-same-origin YOK = opak köken) açılır: betik çalışsa bile ana pencerenin
 * depolamasına, çerezine, API'sine ulaşamaz. Temizlik yine uygulanır (katmanlı). Yazdırma iframe'in içinden
 * tetiklenir (allow-modals); sekme başlığı = PDF dosya adı dışta kalır.
 */
export function yazdirmaSargisi(html: string, baslik: string, yazdir: boolean): string {
  let ic = htmlTemizle(html).replace(/<title>[\s\S]*?<\/title>/i, '');
  const ek = `<title>${h(baslik)}</title>` + (yazdir ? '<script>addEventListener("load",function(){setTimeout(function(){print()},400)})</script>' : '');
  ic = /<head[^>]*>/i.test(ic) ? ic.replace(/<head[^>]*>/i, m => m + ek) : ek + ic;
  return `<!doctype html><html><head><meta charset="utf-8"><title>${h(baslik)}</title>`
    + `<style>html,body{margin:0;height:100%;background:#fff}iframe{border:0;width:100%;height:100%}</style></head>`
    + `<body><iframe sandbox="allow-scripts allow-modals" srcdoc="${h(ic)}"></iframe></body></html>`;
}

/** Dışarıdan gelen HTML'i yeni sekmede güvenli (sandbox) açar; `yazdir` ile yazdırma diyaloğu gelir. */
export function guvenliPencereAc(html: string, baslik: string, yazdir: boolean): Window | null {
  const p = window.open('', '_blank');
  if (!p) return null;
  p.opener = null;   // K90: yazdırma penceresi ana pencereyi yönlendiremez
  p.document.write(yazdirmaSargisi(html, baslik, yazdir));
  p.document.close();
  return p;
}
