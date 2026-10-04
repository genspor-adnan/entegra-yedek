import { gonder, istek } from '../cekirdek';

/**
 * ARIZA / TALEP UÇLARI (hizmet masası, 911).
 *
 * Demirbaşa bağlı OLMAYAN genel arıza (klima, pencere, PC, masa): herkes
 * self-servis açar, kategori SORUMLU EKİBE yönlendirir, ekip devralır →
 * çözer → kapatır. Yönlendirme ve durum geçişleri SUNUCUDA (fn_ariza_talep_ac
 * + akış uçları); istemci yalnız formu ve düğmeyi uca bağlar.
 */

export interface ArizaSecenek { deger: number; ad: string }
export interface ArizaSecenekleri {
  kategoriler: ArizaSecenek[];
  oncelikler: ArizaSecenek[];
  /** 954: kategori → sorumlu ekip (pencere "iletilecek ekip"i gösterir). */
  ekipler?: { kategori: number; ekip: number; ad: string }[];
}

/** 954: bildirim penceresinde demirbaş arama sonucu. */
export interface ArizaDemirbas { id: number; kod: string; ad: string; konum: string }

/** 954: aynı demirbaş / konumda açık arıza - mükerrer yerine "ben de". */
export interface ArizaBenzer {
  id: number; talepNo: string; aciklama: string; durum: number; durumAdi: string;
  sorumluAdi: string; eklemeTarihi: string; benimki: boolean;
}

/** 955: ekibe gelen arıza satırı. */
export interface ArizaGelen {
  id: number; talepNo: string; kategoriAdi: string; ekipAdi: string; konum: string; aciklama: string;
  oncelik: number; oncelikAdi: string; durum: number; durumAdi: string; talepEdenAdi: string;
  telefon: string; sorumluId: number | null; sorumluAdi: string; eklemeTarihi: string; benim: boolean;
}

/** 954: Taleplerim'de takip - talep + akış + takipçiler. */
export interface ArizaTakip {
  talep: {
    id: number; talepNo: string; kategori: number; kategoriAdi: string; ekipAdi: string;
    konum: string; aciklama: string; oncelik: number; oncelikAdi: string;
    demirbasId: number | null; demirbasAdi: string; demirbasKod: string | null;
    talepEden: number; talepEdenAdi: string; sorumluId: number | null; sorumluAdi: string;
    durum: number; durumAdi: string; cozumNotu: string | null; cozumTarihi: string | null;
    kapanisTarihi: string | null; telefon: string; eklemeTarihi: string;
  };
  /** tur: 1 bildirildi · 2 iletildi · 3 atandı · 4 işleme alındı · 5 çözüldü · 6 kapandı
   *  7 yeniden açıldı · 8 iptal · 9 not · 10 ben de bildiriyorum · 11 kendiliğinden kapandı */
  hareketler: { id: number; tur: number; metin: string; tarih: string; yazan: string }[];
  takipciler: string[];
  /** 1 bildiren · 2 takipçi · 3 ekip */
  rol: number;
}

export const arizaUclari = {
  /** Self-servis formun kategori + öncelik seçenekleri (kod_deger). */
  arizaSecenekler: () => istek<ArizaSecenekleri>('/api/ariza/secenekler'),

  /** Talep aç; kategoriye göre ekip otomatik atanır, AT-NNNNNN üretilir. */
  arizaTalepAc: (g: {
    kategori: number; aciklama: string; konum?: string;
    oncelik?: number; demirbasId?: number | null; telefon?: string;
  }) => gonder<{ id: number; talepNo: string; mesaj: string; bildirilen?: number }>(
      '/api/ariza/talep', g),

  // --------------------------------------------- bildiren / takip (954) --
  arizaDemirbasAra: (q: string) =>
    istek<{ satirlar: ArizaDemirbas[] }>(`/api/ariza/demirbas-ara?q=${encodeURIComponent(q)}`),

  arizaBenzer: (g: { demirbasId?: number | null; kategori?: number; konum?: string }) => {
    const p = new URLSearchParams();
    if (g.demirbasId) p.set('demirbasId', String(g.demirbasId));
    if (g.kategori) p.set('kategori', String(g.kategori));
    if (g.konum) p.set('konum', g.konum);
    return istek<{ satirlar: ArizaBenzer[] }>(`/api/ariza/benzer?${p}`);
  },

  arizaTakip: (id: number) => istek<ArizaTakip>(`/api/ariza/${id}/takip`),

  /** "Bana gelenler" (955): ekibime düşen atanmamış + bana atanmış açık arızalar. */
  arizaGelen: () => istek<{ ekip: boolean; satirlar: ArizaGelen[] }>('/api/ariza/gelen'),

  /** Ata… listesi: talebin ekibine iş düşen kişiler. */
  arizaAtanabilir: (id: number) =>
    istek<{ satirlar: { id: number; ad: string; nobetci: number }[] }>(`/api/ariza/${id}/atanabilir`),

  // ------------------------------------------- ekip üyeleri (955) --
  arizaEkipler: () => istek<{
    ekipler: { ekip: number; ad: string; kategoriler: string | null; acik: number }[];
    uyeler: { ekip: number; kullaniciId: number; nobetci: number; aktif: number; ad: string; cepVar: boolean }[];
  }>('/api/ariza/ekipler'),
  arizaKullaniciAra: (q: string) =>
    istek<{ satirlar: { id: number; ad: string; kod: string }[] }>(`/api/ariza/kullanici-ara?q=${encodeURIComponent(q)}`),
  arizaEkipUyeKaydet: (ekip: number, kullaniciId: number, nobetci: boolean) =>
    gonder<{ ekip: number }>(`/api/ariza/ekip/${ekip}/uye`, { kullaniciId, nobetci }),
  arizaEkipUyeSil: (ekip: number, kullaniciId: number) =>
    istek<{ ekip: number }>(`/api/ariza/ekip/${ekip}/uye/${kullaniciId}`, { method: 'DELETE' }),

  /** Aynı arıza açıksa ikinci kayıt yerine takipçi ol. */
  arizaBenDe: (id: number, neden?: string) =>
    gonder<{ id: number; yeni: boolean; mesaj: string }>(`/api/ariza/${id}/ben-de`, { neden }),

  arizaNot: (id: number, metin: string) =>
    gonder<{ id: number }>(`/api/ariza/${id}/not`, { metin }),

  /** Bildiren "çözüldü"yü kabul eder → Kapandı. */
  arizaOnayla: (id: number) => gonder<{ id: number }>(`/api/ariza/${id}/onayla`, {}),

  /** "Düzelmedi" - neden zorunlu. */
  arizaYenidenAc: (id: number, neden: string) =>
    gonder<{ id: number }>(`/api/ariza/${id}/yeniden-ac`, { neden }),

  /** Bildiren, iş bitmeden vazgeçer. */
  arizaVazgec: (id: number, neden?: string) =>
    gonder<{ id: number }>(`/api/ariza/${id}/vazgec`, { neden }),

  /** Ekip devralır: sorumlu = ben, durum İşlemde. */
  arizaDevral: (id: number) =>
    gonder<{ id: number; mesaj: string }>(`/api/ariza/${id}/devral`, {}),

  /** Başka personele ata. */
  arizaAta: (id: number, sorumluId: number) =>
    gonder<{ id: number; mesaj: string }>(`/api/ariza/${id}/ata`, { sorumluId }),

  /** Çöz: çözüm notu zorunlu. */
  arizaCoz: (id: number, notu: string) =>
    gonder<{ id: number; mesaj: string }>(`/api/ariza/${id}/coz`, { notu }),

  /** Kapat. */
  arizaKapat: (id: number) =>
    gonder<{ id: number; mesaj: string }>(`/api/ariza/${id}/kapat`, {}),
};
