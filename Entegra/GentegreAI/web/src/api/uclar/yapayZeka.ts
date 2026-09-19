import { istek, gonder } from '../cekirdek';

/**
 * BAĞLAMSAL YARDIM İSTEĞİNİN EKRAN İPUCU (871). İstemci yalnız KİMLİK
 * gönderir: rota, kaynak kodu, kayıt numarası, sekme adı, son hata kodu,
 * dil. DOM, satır verisi, hasta bilgisi GÖNDERİLMEZ; sunucu bu ipucunu
 * katalog ve yetkiyle doğrular, uymayanı atar.
 */
export interface AiEkranIpucu {
  rota?: string; kaynak?: string; kayitId?: number; sekme?: string;
  hataKodu?: string; dil?: string;
}

/** Sunucunun doğruladığı ekran özeti - "şu ekran hakkında soruyorsunuz". */
export interface AiEkranOzeti {
  bulundu: boolean; yetkili: boolean; kaynak: string; rota: string; baslik: string;
  yol: string; sekme?: string | null; kayitVar: boolean; hataKodu?: string | null;
}

export interface AiRehberYaniti {
  cevap: string;
  adimlar: { no: number; metin: string; ekran?: string; rota?: string; aksiyon?: string }[];
  onerilenEkranlar: { kaynak: string; ad: string; rota: string; yol: string; menuGrup: string }[];
  onerilenAksiyonlar: { kod: string; ad: string; ekran: string }[];
  guvenSkoru: number; eksikBilgiSorusu?: string | null; uyarilar: string[];
  konuKod: string;
  /** 1 katalog · 2 ekran · 3 bağlamsal · 5 model · 6 rol · 7 kapsam dışı · 8 yardım belgesi · 9 akılcı istem kuralı · 0 yok */
  kaynakTuru: number; kontorBakiye: number;
  modelKullanildi?: boolean; model?: string;
  ekran?: AiEkranOzeti | null;
  kaynaklar: { id: string; baslik: string; belge: string }[];
  dil?: string;
}

/** Yapay zeka rehberi, bağlamsal yardım ve model çağrıları. */
export const yapayZekaUclari = {
  // ------------------------------------------------------ AI REHBER ---
  /**
   * BAĞLAMSAL YARDIM (447 · 871): soru + ekran ipucu. Cevap, adımlar ve
   * ekran düğmeleri sunucudan; yetkisiz ekranın rotası hiç gelmez.
   */
  aiRehber: (govde: { kullaniciMesaji: string; aktifMod?: number;
                      aktifSayfa?: string; seciliKaynak?: string;
                      baglam?: AiEkranIpucu }) =>
    gonder<AiRehberYaniti>('/api/ai/rehber', govde),

  /** Panel açılınca / rota değişince: doğrulanmış ekran + önerilen sorular. */
  aiEkranBaglami: (ipucu: AiEkranIpucu) => {
    const p = new URLSearchParams();
    for (const [k, v] of Object.entries(ipucu))
      if (v !== undefined && v !== null && v !== '') p.set(k, String(v));
    return istek<{ ekran: AiEkranOzeti; onerilenSorular: string[];
                   aksiyonlar: { kod: string; ad: string; ekran: string }[] }>(
      `/api/ai/ekran-baglami?${p.toString()}`);
  },

  /** Yardım dizini durumu (sürüm, belge/parça sayısı). */
  aiYardimDizin: () =>
    istek<{ surum: string; olusturmaZamani: string; belgeSayisi: number; parcaSayisi: number;
            modelHazir: boolean; model: string;
            klasor: string; hatalar: string[]; belgeler: string[] }>('/api/ai/yardim/dizin'),

  /** Yardım belgelerini yeniden dizinle (ai.yardim yetkisi). */
  aiYardimIndeksle: () =>
    gonder<{ surum: string; belgeSayisi: number; parcaSayisi: number; hatalar: string[] }>(
      '/api/ai/yardim/indeksle', {}),

  /**
   * AI KONTROLLU ONERI (449): acik kaydin eksikleri. Kurallar sunucuda;
   * panel yalniz cizer - istemcide is kurali yok.
   */
  aiOneri: (kaynak: string, kayitId: number) =>
    gonder<{ kaynak: string; kayitId: number; engel: number; uyari: number;
             bilgi: number;
             oneriler: { kod: string; seviye: number; baslik: string;
                         aciklama: string; alan: string; ekran: string;
                         rota?: string }[] }>('/api/ai/oneri', { kaynak, kayitId }),

  /** "Bunu bir daha gosterme": kural silinmez, bu kullanici icin susar. */
  aiOneriGizle: (kod: string, gizle: boolean) =>
    gonder<{ mesaj: string }>('/api/ai/oneri/gizle', { kod, gizle }),

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
