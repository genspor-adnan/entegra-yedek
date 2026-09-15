import { istek, gonder } from '../cekirdek';
import type {
  DokumAntet, DokumKatalogu, DokumKaydi, DokumTanimi, ListeYaniti, OzetYaniti,
} from '../sozlesme';

/**
 * DÖKÜMLER & İSTATİSTİK (686). Tanım JSON gider, SQL sunucuda üretilir;
 * çalıştırma yanıtı liste çıktısında ListeYaniti, özet çıktısında OzetYaniti.
 */
export const dokumUclari = {
  /** Tasarımcı kataloğu: görülebilen kaynaklar + kolonlar + fn/kesme/kural adları. */
  dokumKatalogu: () => istek<DokumKatalogu>('/api/dokum/kaynaklar'),

  dokumler: (kaynak?: string) =>
    istek<DokumKaydi[]>(`/api/dokum${kaynak ? `?kaynak=${encodeURIComponent(kaynak)}` : ''}`),

  dokum: (id: number) =>
    istek<{ dokum: DokumKaydi; surumler: { surum: number; tarih: string; kullanici: string }[] }>(
      `/api/dokum/${id}`),

  dokumKaydet: (kayit: Partial<DokumKaydi> & { ad: string; tanim: DokumTanimi }) =>
    gonder<{ id: number }>('/api/dokum', kayit),

  dokumSil: (id: number) => gonder<{ silindi: boolean }>(`/api/dokum/${id}`, undefined, 'DELETE'),

  /** id=0 + tanım = kaydetmeden önizleme. */
  dokumCalistir: (id: number, govde: {
    tanim?: DokumTanimi; parametreler?: Record<string, unknown>; sayfa?: number; boyut?: number;
  }) => gonder<ListeYaniti | OzetYaniti>(`/api/dokum/${id}/calistir`, govde),

  dokumAntet: () => istek<DokumAntet>('/api/dokum/antet'),
};
