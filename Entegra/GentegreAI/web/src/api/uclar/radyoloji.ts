import { istek, gonder } from '../cekirdek';

/** Radyoloji: istem, worklist, rapor, randevu, kritik bulgu. */
export const radyolojiUclari = {
  // ---------------------------------------------------------- radyoloji ----
  // RAPOR EKRANI (283): acilista ihtiyac duyulan HER SEY tek istekte gelir -
  //   istem, rapor, bolumler, sablonlar, makrolar, skorlar, hasta gecmisi ve
  //   kritik bulgu bildirimleri.
  radyolojiRapor: (istemId: number) =>
    istek<{
      istem: Record<string, unknown>;
      rapor: Record<string, unknown> | null;
      bolumler: Record<string, unknown>[];
      alanlar: Record<string, unknown>[];
      sablonlar: Record<string, unknown>[];
      makrolar: Record<string, unknown>[];
      skorlar: Record<string, unknown>[];
      gecmis: Record<string, unknown>[];
      kritikler: Record<string, unknown>[];
    }>(`/api/radyoloji/istem/${istemId}/rapor`),

  radyolojiRaporYaz: (istemId: number, govde: unknown) =>
    gonder<{ raporId: number }>(`/api/radyoloji/istem/${istemId}/rapor`, govde),

  /** Sablon iskeleti - "yeniden uygula" bolumleri buradan kurar. */
  radyolojiSablonBolumleri: async (sablonId: number) => {
    const y = await istek<{ detaylar?: Record<string, Record<string, unknown>[]> }>(
      `/api/kart/radyoloji-sablon/${sablonId}`);
    return y.detaylar?.bolumler ?? [];
  },

  /** Ön rapor / onay. Onay ön kosullari sunucuda (fn_radyoloji_rapor_onaylanabilir). */
  radyolojiRaporDurum: (raporId: number, hedef: 'on-rapor' | 'onay') =>
    gonder<{ tamam: boolean }>(`/api/radyoloji/rapor/${raporId}/durum?hedef=${hedef}`, {}),

  /**
   * RAPOR CIKTISI (303): hastaya verilen belge. Yazma ekraninin verisinden
   * AYRI - burada sablon/makro degil KURUM ANTETI, kimlik satirlari, yalniz
   * basilacak bolumler ve ek raporlar var.
   */
  radyolojiRaporCikti: (raporId: number) =>
    istek<{
      rapor: Record<string, unknown>;
      bolumler: Record<string, unknown>[];
      alanlar: Record<string, unknown>[];
      ekler: Record<string, unknown>[];
      kurum: Record<string, unknown> | null;
    }>(`/api/radyoloji/rapor/${raporId}/cikti`),

  /**
   * ISTEM EKRANI (304): tetkik agaci (modalite gruplu), isteyen hekim adaylari
   * ve hastanin son 12 aydaki ayni tetkikleri - mukerrer uyarisi bundan cikar.
   */
  radyolojiIstemSecenekleri: (hastaId: number) =>
    istek<{
      tetkikler: Record<string, unknown>[];
      hekimler: Record<string, unknown>[];
      /** Kayitli DIS hekimler (305) - dis istemde listeden secilir. */
      disHekimler: Record<string, unknown>[];
      gecmis: Record<string, unknown>[];
    }>(`/api/radyoloji/istem-secenekleri?hastaId=${hastaId}`),

  /**
   * Coklu tetkik -> her biri AYRI istem (ayri accession no). Kabul
   * ekraninda (310) basvuru da acilir; sunucu protokol numarasini ve
   * tutarlari geri doner - istemci ikinci istek atmasin.
   */
  radyolojiIstemAc: (govde: unknown) =>
    gonder<{ idler: number[]; accessionlar: string[]; uyarilar: string[];
             belgeId: number | null;
             basvuru: Record<string, unknown> | null }>(
      '/api/radyoloji/istem', govde),

  /** Hastanin aktif policesi (kabul ekrani odeyen kurum/police onyukleme). */
  radyolojiHastaOdeme: (hastaId: number) =>
    istek<{ kurumId?: number | null; kurumAd?: string; policeNo?: string }>(
      `/api/radyoloji/hasta/${hastaId}/odeme`),

  /**
   * Tetkikin randevu bilgisi (317): cekim protokolu suresi + modalite.
   * Radyoloji tetkiki degilse null doner.
   */
  radyolojiTetkikBilgi: (hizmetId: number) =>
    istek<{ hizmetId: number; hizmetAdi: string; modalite: number;
            modaliteAdi: string; protokolSure: number; kontrast: number;
            hazirlikMetni: string } | null>(
      `/api/radyoloji/tetkik-bilgi/${hizmetId}`),

  /**
   * Cekim sonrasi sarf onerisi (320): protokol malzemesi + depo bakiyesi +
   * izlemli stoklar icin lot listesi.
   */
  radyolojiSarf: (istemId: number) =>
    istek<{ aktif: boolean; depoId: number | null; depoAdi: string;
            accessionNo: string; cdIstendi: number; kontrastMl: number;
            satirlar: Record<string, unknown>[]; lotlar: Record<string, unknown>[];
            dusulen: Record<string, unknown>[] }>(
      `/api/radyoloji/istem/${istemId}/sarf`),

  /** Sarfi dus (320): stok cikis fisi uretilir, kritik seviye uyarisi doner. */
  radyolojiSarfDus: (istemId: number,
                     govde: { depoId?: number;
                              satirlar: { stokId: number; miktar: number;
                                          izlemler?: { seriLotId: number;
                                                       miktar: number }[] }[] }) =>
    gonder<{ belgeId: number; uyarilar: string[];
             kritik: Record<string, unknown>[] }>(
      `/api/radyoloji/istem/${istemId}/sarf`, govde),

  /**
   * TAHSILAT DAGITIMI (321): belgenin satirlari + pay bazinda tahsil edilen /
   * kalan. kasaIslemId verilirse o islemin mevcut dagitimi da doner.
   */
  kasaDagitimSatirlari: (belgeId: number, kasaIslemId?: number) =>
    istek<{ belge: Record<string, unknown> | null;
            satirlar: Record<string, unknown>[] }>(
      `/api/kasa-islem/dagitim-satirlari?belgeId=${belgeId}`
      + (kasaIslemId ? `&kasaIslemId=${kasaIslemId}` : '')),

  /**
   * Dagitimi TOPLU yaz (321). otomatik=true ise sunucu kalanlari siraya gore
   * kapatir - radyoloji kabulu gibi tek tikla akislar bunu kullanir.
   */
  kasaDagitimYaz: (kasaIslemId: number,
                   govde: { belgeId?: number; otomatik?: boolean;
                            satirlar?: { belgeSatirId: number; pay: number;
                                         tutar: number }[] }) =>
    gonder<{ dagitilan: number; avans: number; satirSayisi: number }>(
      `/api/kasa-islem/${kasaIslemId}/dagitim`, govde),

  /**
   * Hakedis satirlari seridindeki Prim Rolu / Kisi combo secenekleri.
   * Secenekler ARALIKTAKI SATIRLARDAN uretilir (kullanici): combo'da
   * secilince bos grid veren secenek gorunmesin. `rol` verilirse kisi
   * listesi o rolde satiri olanlara daralir.
   */
  /**
   * Basvuru listesi seridindeki Odeyen / Bolum / Doktor combo secenekleri.
   * Secenekler ARALIKTAKI BASVURULARDAN uretilir (kullanici) - tanim
   * tablolarindan degil, yani secilince bos liste veren secenek gorunmez.
   */
  basvuruSuzgecSecenekleri: (bas?: string, bit?: string) => {
    const p = new URLSearchParams();
    if (bas) p.set('bas', bas);
    if (bit) p.set('bit', bit);
    const q = p.toString();
    type Secenek = { id: number; ad: string; adet: number };
    return istek<{ odeyenler: Secenek[]; bolumler: Secenek[]; doktorlar: Secenek[] }>(
      `/api/belge/basvuru-suzgec${q ? `?${q}` : ''}`);
  },

  hakedisSuzgecSecenekleri: (bas?: string, bit?: string, rol?: number) => {
    const p = new URLSearchParams();
    if (bas) p.set('bas', bas);
    if (bit) p.set('bit', bit);
    if (rol !== undefined) p.set('rol', String(rol));
    const q = p.toString();
    return istek<{ roller: { id: number; ad: string; adet: number }[];
                   kisiler: { id: number; ad: string; adet: number }[] }>(
      `/api/prim/hakedis-suzgec${q ? `?${q}` : ''}`);
  },

  /** Kalemin prim rolleri + o kalemden dogmus primler (324). */
  primKalemRolleri: (belgeSatirId: number) =>
    istek<{ satirlar: Record<string, unknown>[]; primler: Record<string, unknown>[] }>(
      `/api/prim/kalem/${belgeSatirId}/roller`),

  /** Rolleri TOPLU yaz; kalemin primleri yeniden hesaplanir (324). */
  primKalemRolleriYaz: (belgeSatirId: number,
                        govde: { satirlar: { rol: number; tarafId: number;
                                             payYuzde?: number }[] }) =>
    gonder<{ satirSayisi: number; primSatiri: number }>(
      `/api/prim/kalem/${belgeSatirId}/roller`, govde),

  /**
   * Plan satirinin KADEMELERI (388): adede gore artan oran. Kademe satirin
   * cocugu - kart cercevesi torun detayi baglamadigi icin kendi ucu var.
   */
  primKademeler: (planSatirId: number) =>
    istek<{ satirlar: { id: number; adetAlt: number; adetUst: number | null;
                        deger: number }[] }>(
      `/api/prim/satir/${planSatirId}/kademeler`),

  /** Kademeleri TOPLU yaz (tam liste yerine konur) - aralik kumesi butun halinde. */
  primKademeYaz: (planSatirId: number,
                  satirlar: { adetAlt: number; adetUst: number | null; deger: number }[]) =>
    gonder<{ satirSayisi: number }>(
      `/api/prim/satir/${planSatirId}/kademeler`, { satirlar }, 'PUT'),

  /** Kisi bazinda acik (donemi kapanmamis) hakedis (324). */
  primAcikHakedis: () =>
    istek<Record<string, unknown>[]>('/api/prim/acik'),

};
