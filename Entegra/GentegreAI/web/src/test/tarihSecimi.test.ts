import { describe, expect, it } from 'vitest';
import { aralikEtiketi } from '../sayfalar/liste/tarihAralik';

/** Boş liste iletisindeki aralık etiketi (başvuru listesi). */
describe('tarih aralığı etiketi', () => {
  it('tek gün, aynı yıl, farklı yıl', () => {
    expect(aralikEtiketi('2026-09-12', '2026-09-19')).toBe('12.09 – 19.09.2026');
    expect(aralikEtiketi('2025-12-30', '2026-01-02')).toBe('30.12.2025 – 02.01.2026');
    expect(aralikEtiketi('2026-10-27', '2026-10-27')).toBe('27.10.2026');
    expect(aralikEtiketi('', '2026-10-27')).toBe('');
  });
});
