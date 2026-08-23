import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
// base: uygulama KOKTE degil bir ALT YOLDA yayinlanabiliyor (sunucuda /ai).
//   Yerel gelistirmede bos kalir; yayinda `VITE_BASE=/ai/ npm run build`.
export default defineConfig({
  base: process.env.VITE_BASE ?? '/',
  plugins: [react()],
})
