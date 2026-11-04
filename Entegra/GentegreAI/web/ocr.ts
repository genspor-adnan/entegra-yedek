import { readFileSync } from 'node:fs'
import { createRequire } from 'node:module'
import type { Plugin } from 'vite'

/**
 * OCR DOSYALARI (1255, MRZ okutma): tesseract.js işçisi ve WASM çekirdeği `ocr/` altından sunulur. Paket varsayılanı
 * jsdelivr CDN'dir; CSP (csp.ts) `worker-src 'self' blob:` ve `connect-src 'self'` ile kapalıdır, kurum ağı da dışa
 * açık olmayabilir. Geliştirme sunucusunda node_modules'tan okunur, derlemede `dist/ocr/` içine kopyalanır - adlar
 * tesseract.js'in aradığı adlardır (SIMD desteğine göre üç çekirdek, yalnız LSTM).
 *
 * Dil verisi (`eng.traineddata.gz`) pakette yok: `public/ocr/` altına konur (yoksa geliştirmede CDN'den denenir).
 */
const require = createRequire(import.meta.url)

const DOSYALAR: Record<string, string> = {
  'worker.min.js': require.resolve('tesseract.js/dist/worker.min.js'),
}
for (const cekirdek of ['tesseract-core-relaxedsimd-lstm', 'tesseract-core-simd-lstm', 'tesseract-core-lstm']) {
  DOSYALAR[`${cekirdek}.wasm.js`] = require.resolve(`tesseract.js-core/${cekirdek}.wasm.js`)
  DOSYALAR[`${cekirdek}.wasm`] = require.resolve(`tesseract.js-core/${cekirdek}.wasm`)
}

const tip = (ad: string) => ad.endsWith('.wasm') ? 'application/wasm' : 'application/javascript'

export function ocrDosyalari(): Plugin {
  return {
    name: 'gentegre-ocr',
    configureServer(sunucu) {
      sunucu.middlewares.use((istek, yanit, sonraki) => {
        const yol = (istek.url ?? '').split('?')[0]
        const i = yol.indexOf('/ocr/')
        if (i < 0) return sonraki()
        const ad = yol.slice(i + 5)
        const kaynak = DOSYALAR[ad]
        if (!kaynak) return sonraki()
        yanit.setHeader('Content-Type', tip(ad))
        yanit.setHeader('Cache-Control', 'public, max-age=86400')
        yanit.end(readFileSync(kaynak))
      })
    },
    generateBundle() {
      for (const [ad, kaynak] of Object.entries(DOSYALAR))
        this.emitFile({ type: 'asset', fileName: `ocr/${ad}`, source: readFileSync(kaynak) })
    },
  }
}
