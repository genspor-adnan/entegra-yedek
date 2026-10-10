import { describe, expect, it } from 'vitest';
import { dilimYuzdeleri, yasRozeti } from '../sayfalar/yaslandirma/yaslandirmaOrtak';

describe('alacak yaşlandırma', () => {
  it('rozet en kötü dilime göre', () => {
    expect(yasRozeti({ d30: 0, d60: 0, d90: 0 }).ad).toBe('Güncel');
    expect(yasRozeti({ d30: 10, d60: 0, d90: 0 }).renk).toBe('mavi');
    expect(yasRozeti({ d30: 10, d60: 5, d90: 0 }).renk).toBe('sari');
    expect(yasRozeti({ d30: 0, d60: 0, d90: 1 }).renk).toBe('kir');
  });
  it('dilim yüzdeleri toplama göre', () => {
    expect(dilimYuzdeleri({ d0: 50, d30: 25, d60: 25, d90: 0 })).toEqual([50, 25, 25, 0]);
    expect(dilimYuzdeleri({ d0: 0, d30: 0, d60: 0, d90: 0 })).toEqual([0, 0, 0, 0]);
  });
});
