// `vitest/config` (vite'in kendisi degil): `test` bolumunun tipi ancak
//   buradan gelir - yoksa `tsc -b` derlemeyi "test does not exist in type
//   UserConfigExport" ile kirar.
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'
import { execSync } from 'node:child_process'

/**
 * UYGULAMA SÜRÜMÜ DERLEMEDE ÜRETİLİR (kullanıcı 17.10.2026: "projenin versiyonunu ekle"). Biçim
 * src/surum.ts'deki kural: YIL(2).AY.GÜN.BUILD, BUILD = git commit sayısı. Elle yazılan sürüm
 * yayınlarda güncellenmeyip eskiyordu (28.09'da kalmıştı). Git yoksa (paket dışı derleme) build 0.
 */
const surum = (() => {
  const g = new Date();
  const iki = (n: number) => String(n).padStart(2, '0');
  let say = '0';
  try { say = execSync('git rev-list --count HEAD', { stdio: ['ignore', 'pipe', 'ignore'] }).toString().trim() } catch { /* git yok */ }
  return `${iki(g.getFullYear() % 100)}.${iki(g.getMonth() + 1)}.${iki(g.getDate())}.${say}`;
})();

// TESTLER KURUM SAATINDE KOSAR (13.10.2026): tarih testleri (bugunIso "yerel
//   gun, UTC degil") Istanbul saatini varsayiyor. CI sunucusu UTC'de calisinca
//   kirmiziya donuyordu - uygulama hatasi degil, ortam farki. Yalniz vitest
//   altinda; isciler bu ortami devralir.
if (process.env.VITEST) process.env.TZ = 'Europe/Istanbul'

// https://vite.dev/config/
// base: uygulama KOKTE degil bir ALT YOLDA yayinlanabiliyor (sunucuda /ai).
//   Yerel gelistirmede bos kalir; yayinda `VITE_BASE=/ai/ npm run build`.
export default defineConfig({
  base: process.env.VITE_BASE ?? '/',
  plugins: [react()],
  define: { __SURUM__: JSON.stringify(surum) },
  // 500 kB uyarisi STDERR'e yaziliyor, PowerShell bunu hata sayip yayinla.ps1'i
  //   durduruyordu. Paket tek parca (SPA, tamami girişte gerekiyor) - siniri
  //   gercek boyutun uzerine alip uyariyi susturuyoruz.
  build: { chunkSizeWarningLimit: 1500 },
  // DEV SUNUCU IPv4'E DE BAGLANIR. Varsayilan 'localhost' Node 18+ ile once
  //   ::1'e (IPv6) baglaniyor; tarayici `localhost`u 127.0.0.1'e cozunce
  //   "baglanti reddedildi" aliniyordu - sunucu ayakta oldugu halde sayfa
  //   acilmiyordu. 127.0.0.1 ile iki ad da ayni yere gider.
  server: { host: '127.0.0.1', port: 5173, strictPort: true },
  // TEST ORTAMI: varsayilan `node` - saf mantik testleri (bicim, kurallar,
  //   imza, pay hesabi) hizli kossun. jsdom PAHALIDIR: hepsine acilinca takim
  //   1,7 sn'den 33 sn'ye cikti. DOM gerektiren BILESEN testleri kendi
  //   dosyasinin basinda `// @vitest-environment jsdom` ile ortami secer.
  test: { setupFiles: ['./src/test/kurulum.ts'] },
})
