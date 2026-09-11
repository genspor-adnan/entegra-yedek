import { istek, gonder } from '../cekirdek';

/** Mesajlasma kanallari. */
export const mesajUclari = {
  // ---------------------------------------------------------- MESAJLAR ---
  // Mockup: Ekranlar/umesajlar.html (341/342). Gercek zamanli iletim yok;
  //   ekran kisa arayla tazeliyor.
  /** Kullanicinin sohbet listesi + okunmamis sayaclari. */
  mesajSohbetler: (filtre: string, ara: string) =>
    istek<{ sohbetler: Record<string, unknown>[];
            ozet: { okunmamisMesaj: number; okunmamisSohbet: number;
                    bugunMesaj: number; bugunEk: number; bugunKayit: number } | null }>(
      `/api/mesaj/sohbetler?filtre=${encodeURIComponent(filtre)}`
      + `&ara=${encodeURIComponent(ara)}`),

  /** Sohbetin mesajlari; `sonrasi` verilirse yalniz yeni gelenler. */
  mesajAkis: (sohbetId: number, sonrasi = 0) =>
    istek<{ sohbet: Record<string, unknown> | null; mesajlar: Record<string, unknown>[] }>(
      `/api/mesaj/${sohbetId}/mesajlar?sonrasi=${sonrasi}`),

  mesajGonder: (sohbetId: number, metin: string, yanitId?: number,
                kayit?: { modul: string; kayitId: number; ozet?: string }) =>
    gonder<{ id: number; tarih: string }>(`/api/mesaj/${sohbetId}/gonder`,
      { metin, yanitId: yanitId ?? null, kayit: kayit ?? null }),

  mesajOkundu: (sohbetId: number) =>
    gonder<{ tamam: boolean }>(`/api/mesaj/${sohbetId}/okundu`, {}),

  mesajBayrak: (sohbetId: number,
                govde: { favori?: number; sabit?: number; sessiz?: number; arsiv?: number }) =>
    gonder<{ tamam: boolean }>(`/api/mesaj/${sohbetId}/bayrak`, govde),

  mesajBilgi: (sohbetId: number) =>
    istek<{ kunye: Record<string, unknown> | null;
            uyeler: Record<string, unknown>[]; ekler: Record<string, unknown>[];
            kayitlar: Record<string, unknown>[]; sabitler: Record<string, unknown>[] }>(
      `/api/mesaj/${sohbetId}/bilgi`),

  mesajSabit: (mesajId: number, geriAl: boolean) =>
    gonder<{ tamam: boolean }>(`/api/mesaj/mesaj/${mesajId}/sabit?geriAl=${geriAl}`, {}),

  mesajSil: (mesajId: number) =>
    istek<{ tamam: boolean }>(`/api/mesaj/mesaj/${mesajId}`, { method: 'DELETE' }),

  mesajKisiler: (ara: string) =>
    istek<{ kisiler: { id: number; ad: string; gorev: string }[] }>(
      `/api/mesaj/kisiler?ara=${encodeURIComponent(ara)}`),

  mesajSohbetAc: (govde: { tip: number; ad?: string; uyeler: number[] }) =>
    gonder<{ id: number; mevcutMu: boolean }>('/api/mesaj/sohbet', govde),

  /** Entegrasyon hesabinin baglantisini sinar (336). */
  entegrasyonSina: (id: number) =>
    gonder<{ basarili: boolean; mesaj: string }>(`/api/entegrasyon/${id}/sina`, {}),

  /** SKRS kod listelerini servisten cekip yerel listeleri gunceller (336). */
  skrsListeSenkron: (id: number) =>
    gonder<{ satirSayisi: number; mesaj: string }>(`/api/entegrasyon/${id}/skrs-senkron`, {}),

  /**
   * SKRS klinik kodlarini BOLUM KODUNA yazar (455). Dolu koda dokunmaz -
   * kurum kendi kodlamasini yapmis olabilir.
   */
  skrsKlinikEsle: (id: number) =>
    gonder<{ eslenen: number; skrsKodSayisi: number; mesaj: string;
             eslesmeyen: { id: number; ad: string }[] }>(
      `/api/entegrasyon/${id}/skrs-klinik-esle`, {}),

  /** Prim satirlarini ONAYLA / onayi kaldir (330) - onayli satir kilitlidir. */
  primOnayla: (govde: { satirlar: number[]; geriAl?: boolean }) =>
    gonder<{ satirSayisi: number; geriAl: boolean }>('/api/prim/onayla', govde),

  /** Donemi kapat: acik satirlar bir basliga baglanir ve DONDURULUR (324). */
  primDonemKapat: (govde: { tarafId: number; baslangic: string; bitis: string }) =>
    gonder<Record<string, unknown>>('/api/prim/donem-kapat', govde),

  /** Carinin dagitilmamis tahsilatlari (322) - avans mahsubu seridi. */
  kasaAvans: (tarafId: number) =>
    istek<{ satirlar: Record<string, unknown>[]; toplam: number }>(
      `/api/kasa-islem/avans?tarafId=${tarafId}`),

  /**
   * Avansi belgenin acik satirlarina dagit (322). Prim tarihi dagitim gunu
   * DEGIL, tahsilatin islem tarihidir.
   */
  kasaAvansMahsup: (govde: { belgeId: number; islemIdler?: number[] }) =>
    gonder<{ dagitilan: number; islemSayisi: number }>(
      '/api/kasa-islem/avans-mahsup', govde),

  /** Radyoloji panosu (320): sayaclar + cihaz dolulugu + uyarilar tek uctan. */
  radyolojiPano: <T,>(gun?: string) =>
    istek<T>(`/api/radyoloji/pano${gun ? `?gun=${encodeURIComponent(gun)}` : ''}`),

  /**
   * Cihazin kapali araliklari (318): bakim/ariza/tatil + ogle arasi.
   * Takvim bunlari tarali blok olarak cizer - kural zaten tetikte, bu
   * GORUNURLUK icin.
   */
  radyolojiCihazKapatma: (bas: string, bit: string) =>
    istek<{ kapatmalar: Record<string, unknown>[]; ogleArasi: Record<string, unknown>[] }>(
      `/api/radyoloji/cihaz-kapatma?bas=${encodeURIComponent(bas)}`
      + `&bit=${encodeURIComponent(bit)}`),

  /** Takvimden cihaz kapatma (318) - etkilenen randevu sayisi doner. */
  radyolojiKapatmaEkle: (cihazId: number,
                         govde: { baslangic: string; bitis: string;
                                  nedenTur?: number; aciklama?: string }) =>
    gonder<{ id: number; etkilenenRandevu: number }>(
      `/api/radyoloji/cihaz/${cihazId}/kapatma`, govde),

  /** Kritik bulgu takibini kapat (318): teyit alindi, listeden duser. */
  radyolojiKritikKapat: (istemId: number) =>
    gonder<{ tamam: boolean }>(`/api/radyoloji/istem/${istemId}/kritik-kapat`, {}),

  /** Randevusu olmayan istemler (316) - takvimin bekleyen paneli. */
  radyolojiRandevuBekleyen: () =>
    istek<Record<string, unknown>[]>('/api/radyoloji/randevu-bekleyen'),

  /**
   * Isteme randevu ver (316): kayit public.randevu'ya gider, kaynagi CIHAZ.
   * Sure verilmezse cekim protokolu (314), o da yoksa cihaz varsayilani.
   */
  radyolojiRandevuVer: (istemId: number,
                        govde: { cihazId: number; baslangic: string;
                                 sureDk?: number; teknikerId?: number;
                                 aciklama?: string }) =>
    gonder<{ randevuId: number; sureDk: number }>(
      `/api/radyoloji/istem/${istemId}/randevu`, govde),

  /** Istem akis seridi + ozet (310): istem/randevu/cekim/rapor/onay/teslim. */
  radyolojiIstemAkis: (istemId: number) =>
    istek<Record<string, unknown>>(`/api/radyoloji/istem/${istemId}/akis`),

  /** Cekim oncesi kontrol listesi (310) - modaliteye gore sorular + yanitlar. */
  radyolojiKontrol: (istemId: number) =>
    istek<{ sorular: Record<string, unknown>[] }>(
      `/api/radyoloji/istem/${istemId}/kontrol`),

  radyolojiKontrolKaydet: (istemId: number,
                           yanitlar: { soruId: number; yanit: string }[]) =>
    gonder<{ kaydedildi: boolean }>(
      `/api/radyoloji/istem/${istemId}/kontrol`, { yanitlar }),

  /** SONUC TESLIMI (304): film/CD/basili rapor kime verildi. */
  radyolojiTeslim: (istemId: number, govde: unknown) =>
    gonder<{ tamam: boolean }>(`/api/radyoloji/istem/${istemId}/teslim`, govde),

  radyolojiTeslimler: (istemId: number) =>
    istek<Record<string, unknown>[]>(`/api/radyoloji/istem/${istemId}/teslimler`),

  /**
   * KONSULTASYON (304): ikinci gorus. `konsultasyonId` verilirse DONEN GORUS
   * yazilir (kayit "dondu" olur), yoksa yeni istek acilir.
   */
  radyolojiKonsultasyon: (istemId: number, govde: unknown, konsultasyonId?: number) =>
    gonder<{ id: number }>(
      `/api/radyoloji/istem/${istemId}/konsultasyon`
      + (konsultasyonId ? `?konsultasyonId=${konsultasyonId}` : ''), govde),

  radyolojiKonsultasyonlar: (istemId: number) =>
    istek<Record<string, unknown>[]>(`/api/radyoloji/istem/${istemId}/konsultasyonlar`),

  /** Dis hekim gonderim ozeti (305): kutular + modalite dagilimi. */
  radyolojiHekimOzeti: (hekimId: number) =>
    istek<{ ozet: Record<string, unknown>; dagilim: Record<string, unknown>[] }>(
      `/api/radyoloji/hekim/${hekimId}/ozet`),

  radyolojiAddendum: (raporId: number) =>
    gonder<{ raporId: number }>(`/api/radyoloji/rapor/${raporId}/addendum`, {}),

  radyolojiKritikBulgu: (istemId: number, govde: unknown) =>
    gonder<{ tamam: boolean }>(`/api/radyoloji/istem/${istemId}/kritik-bulgu`, govde),

};
