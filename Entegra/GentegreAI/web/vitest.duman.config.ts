// DUMAN TESTİ YAPILANDIRMASI (dokuman/17) - `npm run duman`.
//   Normal `npm test` bunu ÇALIŞTIRMAZ: çalışan API (5180) + web (5173) ister,
//   gerçek tarayıcıyla bütün menüyü dolaşır, dakikalar sürer. Dosya deseni
//   `*.duman.ts` olduğu için varsayılan vitest taramasına da girmez.
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    include: ['duman/**/*.duman.ts'],
    environment: 'node',
    testTimeout: 60 * 60 * 1000,
    hookTimeout: 5 * 60 * 1000,
    // Tek dosya, kendi içinde paralel sayfa açar.
    fileParallelism: false,
  },
})
