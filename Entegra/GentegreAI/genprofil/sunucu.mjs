/**
 * GenProfil yerel sunucusu (`npm run basla`): `dist` çıktısını servis eder ve
 * `/vekil/...` isteklerini kullanıcının girdiği sunucuya iletir.
 *
 * Geliştirmede aynı vekil Vite'ın içinde çalışır (vite.config.ts) - tek kod,
 * iki mod.
 */
import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';
import { vekilAraKatmani } from './vekil.mjs';

const KOK = fileURLToPath(new URL('./dist', import.meta.url));
const PORT = Number(process.env.PORT ?? 5174);
const TURLER = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8', '.json': 'application/json; charset=utf-8',
  '.svg': 'image/svg+xml', '.png': 'image/png', '.ico': 'image/x-icon',
  '.woff2': 'font/woff2',
};

createServer((istek, yanit) => {
  vekilAraKatmani(istek, yanit, async () => {
    // YOL NORMALLEŞTİRİLİR: `..` ile dist dışına çıkılmasın.
    const yol = normalize(decodeURIComponent((istek.url ?? '/').split('?')[0]));
    const dosya = join(KOK, yol === '/' ? 'index.html' : yol);
    if (!dosya.startsWith(KOK)) { yanit.statusCode = 403; yanit.end('Yasak'); return }
    try {
      const icerik = await readFile(dosya);
      yanit.setHeader('content-type', TURLER[extname(dosya)] ?? 'application/octet-stream');
      yanit.end(icerik);
    } catch {
      // Tek sayfa uygulaması: bilinmeyen yol index.html'e düşer.
      try {
        const icerik = await readFile(join(KOK, 'index.html'));
        yanit.setHeader('content-type', TURLER['.html']);
        yanit.end(icerik);
      } catch { yanit.statusCode = 404; yanit.end('Bulunamadi') }
    }
  });
}).listen(PORT, () => {
  console.log(`GenProfil hazir: http://localhost:${PORT}`);
});
