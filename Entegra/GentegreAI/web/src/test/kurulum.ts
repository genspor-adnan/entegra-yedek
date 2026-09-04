import { afterEach } from 'vitest';

/**
 * Ortak test kurulumu.
 *
 * Takimin cogu SAF MANTIK testi ve `node` ortaminda kosuyor (jsdom hepsine
 * acilinca sure 1,7 sn -> 33 sn oluyordu). Bu dosya her iki ortamda da
 * yuklendigi icin DOM araclari KOSULLU baglanir: yalnizca `document` varsa,
 * yani bilesen testlerinde.
 */
if (typeof document !== 'undefined') {
  // jest-dom eslestiricileri (toBeInTheDocument vb.) ve her testten sonra
  //   DOM temizligi - React 19'da kalan bilesen sonraki testin sorgusuna
  //   karisip "birden fazla eleman" hatasi veriyor.
  await import('@testing-library/jest-dom/vitest');
  const { cleanup } = await import('@testing-library/react');
  afterEach(() => cleanup());
}
