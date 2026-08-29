import { defineConfig } from 'vite'
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
})
