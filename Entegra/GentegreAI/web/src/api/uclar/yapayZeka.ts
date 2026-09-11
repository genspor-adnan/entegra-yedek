import { istek, gonder } from '../cekirdek';

/** Yapay zeka rehberi ve model cagrilari. */
export const yapayZekaUclari = {
  // -------------------------------------------------------- YAPAY ZEKA ---
  // Mockup: Ekranlar/ai_asistan.html (341/343). Model bagli degilken de
  //   izinli fonksiyonlar (hazir komutlar) calisir.
  aiSohbetler: () =>
    istek<{ sohbetler: Record<string, unknown>[];
            araclar: { kod: string; ad: string; aciklama: string;
                       yetkiKodu: string; yazar: number }[];
            bekleyenTaslak: number }>('/api/ai/sohbetler'),

  aiSohbetAc: () => gonder<{ id: number }>('/api/ai/sohbet', {}),

  aiSohbet: (id: number) =>
    istek<{ sohbet: Record<string, unknown>;
            mesajlar: Record<string, unknown>[];
            taslaklar: Record<string, unknown>[];
            gunluk: Record<string, unknown>[] }>(`/api/ai/${id}`),

  aiSor: (sohbetId: number, metin: string, arac?: string,
          parametre?: Record<string, unknown>, baglam?: Record<string, unknown>) =>
    gonder<{ mesajId: number; kayit: number }>(`/api/ai/${sohbetId}/sor`,
      { metin, arac: arac ?? null, parametre: parametre ?? null, baglam: baglam ?? null }),

  aiTaslak: (taslakId: number, iptal: boolean) =>
    gonder<{ durum: number; hedefModul: string; hedefId: number | null }>(
      '/api/ai/taslak', { taslakId, iptal }),

  aiGeriBildirim: (mesajId: number, deger: number) =>
    gonder<{ tamam: boolean }>('/api/ai/geribildirim', { mesajId, deger }),

};
