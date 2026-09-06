// `vitest/config` (vite'in kendisi degil): `test` bolumunun tipi ancak
//   buradan gelir - yoksa `tsc -b` derlemeyi "test does not exist in type
//   UserConfigExport" ile kirar.
import { defineConfig } from 'vitest/config'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
// base: uygulama KOKTE degil bir ALT YOLDA yayinlanabiliyor (sunucuda /ai).
//   Yerel gelistirmede bos kalir; yayinda `VITE_BASE=/ai/ npm run build`.
export default defineConfig({
  base: process.env.VITE_BASE ?? '/',
  plugins: [react()],
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
