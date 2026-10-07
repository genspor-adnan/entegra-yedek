import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { fileURLToPath } from 'node:url';
import { vekilAraKatmani } from './vekil.mjs';

const webSrc = fileURLToPath(new URL('../web/src', import.meta.url));

/**
 * GenProfil, kurum profili ekranını ve API istemcisini **web projesinden
 * paylaşır** (`@web` takma adı): aynı ekranı ikinci kez yazmak, iki ayrı
 * davranış demekti. Bu yüzden `fs.allow` ile web kaynak klasörü de servis
 * edilir.
 */
export default defineConfig({
  plugins: [
    react(),
    {
      name: 'genprofil-vekil',
      configureServer(sunucu) { sunucu.middlewares.use(vekilAraKatmani) },
      configurePreviewServer(sunucu) { sunucu.middlewares.use(vekilAraKatmani) },
    },
  ],
  resolve: { alias: { '@web': webSrc } },
  server: { port: 5174, fs: { allow: [webSrc, fileURLToPath(new URL('.', import.meta.url))] } },
  build: { outDir: 'dist' },
});
