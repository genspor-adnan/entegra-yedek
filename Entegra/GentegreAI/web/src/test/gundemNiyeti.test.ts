import { describe, expect, it } from 'vitest';
import { gundemNiyetiMi } from '../sayfalar/kabuk/KomutPaleti';

// GÜNDEM NİYETİ (03.11.2026): "bugünkü işlerim" YZ'ye gitmez, kelime listesiyle tanınır; kayıt / ekran adları niyet sayılmaz.
describe('gundemNiyetiMi', () => {
  it.each(['bugünkü işlerim', 'Bugünkü işlerim?', 'işlerim', 'görevlerim', 'bugün ne var', 'bugün', 'gündem',
           'bugünkü görevlerim neler'])('niyet: %s', m => expect(gundemNiyetiMi(m)).toBe(true));
  it.each(['', 'Demir', 'iş listesi', 'görev listesi', 'bugünkü randevular', 'kasa'])('niyet değil: %s',
    m => expect(gundemNiyetiMi(m)).toBe(false));
});
