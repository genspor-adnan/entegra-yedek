import { istek, gonder } from '../cekirdek';

/** Laboratuvar: cihaz, istem, numune, dis lab, kalite kontrol, genetik, mikrobiyoloji. */
export const labUclari = {
  // ----------------------------------------------------------------- CIHAZ
  /** Ham cihaz mesajini kuyruga alir (432) - kopru uygulamalari ve TEST icin. */
  cihazMesaj: (cihazId: number, ham: string, kaynak?: string) =>
    gonder<{ mesajId: number; durum: string; mesaj: string }>(
      '/api/cihaz/mesaj', { cihazId, ham, kaynak }),

  /** Surucu duzeltildikten sonra ayni ham metni tekrar cozumler. */
  cihazYenidenIsle: (mesajId: number) =>
    gonder<{ durum: string; mesaj: string }>(
      `/api/cihaz/mesaj/${mesajId}/yeniden-isle`, {}),

  cihazMesajOku: (mesajId: number) =>
    istek<{ mesaj: Record<string, unknown>; kalemler: Record<string, unknown>[] }>(
      `/api/cihaz/mesaj/${mesajId}`),

  cihazKlasorTara: () =>
    gonder<{ okunan: number; hatali: number; mesaj: string }>(
      '/api/cihaz/klasor-tara', {}),

  // ------------------------------------------------------------------- LAB
  /** Basvurudan istem acar; tup planini ve barkodlari sunucu uretir (433). */
  /**
   * ISTEM ACAR - IKI YOL (637):
   *   * `belgeId` : BASVURUDAN (hasta burada). Ucretlendirme, provizyon ve
   *     e-Nabiz o basvuru uzerinden yurur.
   *   * `disKurumId` + `hastaId` : DIS KURUM NUMUNESI - numune gelir, hasta
   *     gelmez. Basvuru yoktur; fatura gonderen kuruma kesilir ve istem
   *     e-Nabiz'a bildirilmez (USS'de baglanacagi bir hasta kabulu yok).
   */
  labIstemAc: (govde: { belgeId?: number;
                        hastaId?: number; disKurumId?: number;
                        satirlar: { tetkikId?: number; panelId?: number }[];
                        oncelik?: number; klinikBilgi?: string; taniIcd?: string }) =>
    gonder<{ id: number; istemNo: string; barkodlar: string[];
             tetkikSayisi: number; mesaj: string }>('/api/lab/istem', govde),

  /** Kartla acilan istemin barkodlarini uretir (uc yolunda plan zaten calisir). */
  labNumunePlani: (istemId: number) =>
    gonder<{ id: number; barkodlar: string[]; mesaj: string }>(
      `/api/lab/istem/${istemId}/numune-plani`, {}),

  /**
   * AI REHBER (447): "ne nerede, nasil yapilir". Sunucu katalog + yetki ile
   * cevaplar; panel yalniz cizer - istemcide is kurali yok.
   */
  aiRehber: (govde: { kullaniciMesaji: string; aktifMod?: number;
                      aktifSayfa?: string; seciliKaynak?: string }) =>
    gonder<Record<string, unknown>>('/api/ai/rehber', govde),

  /** Sonuc onay ekraninin ust serit sayaclari (446, mockup ".ozet"). */
  labOzet: () =>
    istek<{ sayaclar: Record<string, number>;
            cihazlar: Record<string, unknown>[] }>('/api/lab/ozet'),

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

  /**
   * e-NABIZ PAKET KARTI (454): paketin USS alanlari ve gonderim denemeleri.
   * SALT OKUNUR - paket elle duzeltilmez, kaynak duzeltilip yeniden uretilir.
   */
  enabizPaketOku: (id: number) =>
    istek<{ paket: Record<string, unknown>;
            alanlar: Record<string, unknown>[];
            denemeler: Record<string, unknown>[] }>(`/api/enabiz/paket/${id}`),

  /** e-Nabiz veri kalitesi panosu (454): donem "YYYY-MM". */
  enabizVeriKalitesi: (ay: string) =>
    istek<never>(`/api/enabiz/veri-kalitesi?ay=${encodeURIComponent(ay)}`),

  labIstemOku: (id: number) =>
    istek<Record<string, unknown>>(`/api/lab/istem/${id}`),

  /** Muayene "Istem & Sonuclar" sekmesi: basvurunun istemleri. */
  labBasvuruIstemleri: (belgeId: number) =>
    istek<{ belgeId: number; istemler: Record<string, unknown>[] }>(
      `/api/lab/basvuru/${belgeId}/istemler`),

  /** durum: 2 alindi · 3 kabul · 0 ret (ret nedeni ZORUNLU). */
  labNumuneDurum: (id: number, durum: number, ek?: { kalite?: number;
                                                     retNeden?: number;
                                                     aciklama?: string }) =>
    gonder<{ id: number; mesaj: string }>(`/api/lab/numune/${id}/durum`,
      { durum, ...(ek ?? {}) }),

  /**
   * İSTEMİN TÜM TÜPLERİ tek işlemde (mockup araç çubuğu "✔ Numune Kabul" /
   * "✖ Numune Ret"): hangi tüpün işleneceğine sunucu karar verir - çalışılmış
   * numuneye dokunulmaz.
   */
  /**
   * Kurumun YURURLUKTEKI sozlesmeleri (468). Basvuru karti bunlarla secici
   * cizer; tek sozlesme varsa deger zaten bellidir.
   */
  kurumSozlesmeleri: (kurumId: number) =>
    istek<{ kurumId: number; sozlesmeler: {
      id: number; ad: string; altKurum: number; altKurumAdi: string;
      sozlesmeNo: string; durum: number; rota: number; tur: number;
      fiyatListesiId: number | null; sgkFiyatListesiId: number | null;
      sgkKurumId: number | null; varsayilanKarsilama: number;
    }[] }>(`/api/kurum/${kurumId}/sozlesmeler`),

  /**
   * Satirlarin ODEME DAGILIMINI yeniler (472/474). Istemci KURAL gondermez:
   * rota sozlesmeden, fiyatlar SUT/TTB listelerinden sunucuda cozulur.
   */
  belgeDagit: (belgeId: number, govde?: {
    /** `sgkListe`: SUT bedeli EKRANDAN (483) - liste boşsa kullanıcı girer. */
    sgkProvizyon?: { satirId: number; tutar?: number; provizyonNo?: string;
                     sgkListe?: number; huvListe?: number }[];
    ossProvizyon?: number;
  }) =>
    gonder<{ id: number; satir: number; mesaj: string }>(
      `/api/belge/${belgeId}/dagit`, govde ?? {}),

  /**
   * KAYDEDILMEMIS satirlarin dagilim ONIZLEMESI (594, kullanici: "kaydetmeden
   * ucret satirinin sagindaki + detay butonu gelmiyor, oysa ben ekledigimde
   * hemen detay ne diye gormek istiyorum").
   *
   * Sunucu hicbir sey yazmaz ve KAYITLI satirla ayni fonksiyonu calistirir
   * (`fn_dagilim_coz`) - onizlemede gorulen rakam kaydedince degismez.
   * Satirlar `anahtar` ile eslesir: satirin henuz id'si yoktur.
   */
  belgeDagilimOnizleme: (govde: {
    odeyenKurumId: number; sozlesmeId?: number | null; altKurum?: number | null;
    sgkKullan?: number | null; emekli?: number | null;
    satirlar: { anahtar: string; stokId?: number | null; hizmetId?: number | null;
                miktar: number; tutar: number; kdv: number;
                iskonto?: number; iskonto2?: number;
                sgkListe?: number | null; katkiTutar?: number | null }[];
  }) =>
    gonder<{ satirlar: { anahtar: string; rota: number; tutar: number;
                         sgk: number; oss: number; hastaProvizyon: number;
                         hastaEkKatki: number; sgkKatilimPayi: number;
                         sgkListe: number; huvListe: number }[] }>(
      '/api/belge/dagilim-onizleme', govde),

  labIstemNumuneDurum: (istemId: number, durum: number,
                        ek?: { kalite?: number; retNeden?: number; aciklama?: string }) =>
    gonder<{ id: number; mesaj: string }>(`/api/lab/istem/${istemId}/numune-durum`,
      { durum, ...(ek ?? {}) }),

  /** Tüplerin saklama yeri / sıcaklığı (mockup "🧊 Saklama Yeri"). */
  labIstemSaklama: (istemId: number, yer: string, sicaklik?: number) =>
    gonder<{ id: number; say: number; mesaj: string }>(
      `/api/lab/istem/${istemId}/saklama`, { yer, sicaklik }),

  /**
   * ÇALIŞMA TAKVİMİ ÖNİZLEMESİ (487). Düzen PARAMETRE gider, tetkik id ile
   * değil: kullanıcı kartta düzeni değiştirirken önizleme kaydetmeden
   * güncellensin. Saatleri sunucu hesaplar - aynı kural istem ekranında da
   * çalışıyor, ikinci bir hesap iki farklı saat söylerdi.
   */
  /** Tetkik Katalogu sol paneli (492): bolum sayimlari + panel uyelikleri. */
  labTetkikAgaci: () =>
    istek<{ toplam: number;
            bolumler: { kod: number; ad: string; ikon: string; adet: number; aktif: number }[];
            paneller: { id: number; kod: string; ad: string; durum: number;
                        tetkikIdleri: number[] }[] }>('/api/lab/tetkik/agac'),

  /** Tetkik Katalogu sag paneli (492): secili tetkigin ozeti. */
  labTetkikOzeti: (id: number) =>
    istek<{ tetkik: Record<string, unknown>; referanslar: Record<string, unknown>[];
            paneller: { id: number; ad: string }[]; istemAdedi: number }>(
      `/api/lab/tetkik/${id}/ozet`),

  labCalismaTakvimi: (d: { duzen: number; gunler: number; saatler: string;
                           kabulSonDk: number; tatDk: number; acilTatDk: number;
                           acilBeklemez: number; kabul: string }) =>
    istek<{ duzen: number;
            hafta: { saat: string; kabulSon: string;
                     gunler: { acik: boolean; sonuc?: string | null }[] }[];
            ozet: { simdiKabul: string; simdi: string | null;
                    kacirilan: string | null; acil: string | null } }>(
      '/api/lab/calisma-takvimi?'
      + `duzen=${d.duzen}&gunler=${d.gunler}`
      + `&saatler=${encodeURIComponent(d.saatler)}`
      + `&kabulSonDk=${d.kabulSonDk}&tatDk=${d.tatDk}&acilTatDk=${d.acilTatDk}`
      + `&acilBeklemez=${d.acilBeklemez}&kabul=${encodeURIComponent(d.kabul)}`),

  labNumuneBarkod: (barkod: string) =>
    istek<Record<string, unknown>>(
      `/api/lab/numune/barkod/${encodeURIComponent(barkod)}`),

  /** Kural motoru sunucuda calisir: bayrak/panik/delta yanitla doner. */
  labSonucYaz: (govde: { istemSatirId: number; deger: string; birim?: string;
                         yorum?: string; dilusyon?: number }) =>
    gonder<{ sonucId: number; bayrak: string; panik: boolean;
             deltaUyari: boolean; mesaj: string }>('/api/lab/sonuc', govde),

  /** asama 1 teknik, 2 uzman (yayin). */
  labSonucOnayla: (id: number, asama = 2) =>
    gonder<{ mesaj: string }>(`/api/lab/sonuc/${id}/onayla`, { asama }),

  labSonucDuzelt: (id: number, deger: string, neden: string) =>
    gonder<{ sonucId: number; bayrak: string; mesaj: string }>(
      `/api/lab/sonuc/${id}/duzelt`, { deger, neden }),

  labPanikBildir: (sonucId: number, bildirilenAd: string, kanal = 1,
                   aciklama?: string) =>
    gonder<{ bildirimId: number; mesaj: string }>(
      `/api/lab/sonuc/${sonucId}/panik`, { bildirilenAd, kanal, aciklama }),

  labPanikTeyit: (bildirimId: number, teyitEden: string) =>
    gonder<{ mesaj: string }>(`/api/lab/panik/${bildirimId}/teyit`, { teyitEden }),

  /** Host query: cihaz "bu barkodda ne calisacagim" der. */
  labCalismaListesi: (cihazId: number, barkod: string) =>
    istek<{ satirlar: Record<string, unknown>[] }>(
      `/api/lab/cihaz/${cihazId}/calisma-listesi/${encodeURIComponent(barkod)}`),

  /** Cozumlenmis cihaz mesajini lab sonucuna aktarir. */
  labCihazMesajIsle: (mesajId: number) =>
    gonder<{ yazilan: number; atlanan: number; mesaj: string }>(
      `/api/lab/cihaz-mesaj/${mesajId}/isle`, {}),

  /** Tup barkod etiketi (444): istemin TUM tupleri ya da tek numune. */
  labEtiket: (ek: { istemId?: number; numuneId?: number }) => {
    const q = new URLSearchParams();
    if (ek.istemId) q.set('istemId', String(ek.istemId));
    if (ek.numuneId) q.set('numuneId', String(ek.numuneId));
    return istek<{ etiketler: Record<string, unknown>[];
                   kurum: Record<string, unknown> | null }>(`/api/lab/etiket?${q}`);
  },

  /** Muayene karti "Istem & Sonuclar" sekmesi (443): bag + SONUCUN KENDISI. */
  /** Muayene listesi ozet seridi (461): poliklinigin o gunku hali. */
  muayeneOzet: (gun?: string) =>
    istek<never>(`/api/muayene/ozet${gun ? `?gun=${gun}` : ''}`),

  muayeneSonuclari: (muayeneId: number) =>
    istek<{ muayeneId: number; belgeId: number | null;
            baglar: Record<string, unknown>[];
            istemler: Record<string, unknown>[];
            sonuclar: Record<string, unknown>[];
            kulturler: Record<string, unknown>[];
            vakalar: Record<string, unknown>[];
            radyoloji: Record<string, unknown>[] }>(
      `/api/lab/muayene/${muayeneId}/sonuclar`),

  /** Hekim sonucu gordu (418): sonucun gelmesi ile gorulmesi AYRI olaylar. */
  muayeneIstemGordu: (bagId: number) =>
    gonder<{ id: number; zaman: string; mesaj: string }>(
      `/api/muayene/istem/${bagId}/gordu`, {}),

  // ------------------------------------------------ DIS LABORATUVAR (445)
  /** Secilen tetkikleri dis laboratuvara sevk eder (kurye + soguk zincir). */
  disLabGonder: (govde: { disLabId: number; istemSatirIdler: number[];
                          kuryeFirma?: string; kuryeAd?: string; kuryeTel?: string;
                          tasimaKosulu?: number; sicaklik?: number;
                          kapSayisi?: number; aciklama?: string }) =>
    gonder<{ id: number; gonderimNo: string; satir: number; mesaj: string }>(
      '/api/lab/dis/gonder', govde),

  disLabOku: (id: number) =>
    istek<{ gonderim: Record<string, unknown>;
            satirlar: Record<string, unknown>[] }>(`/api/lab/dis/${id}`),

  disLabYolda: (id: number) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/yolda`, {}),

  /** Dis kabul no: sonuc eslestirmesinde iki laboratuvarin ortak referansi. */
  disLabTeslim: (id: number, teslimAlan: string, disKabulNo: string) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/teslim`,
      { teslimAlan, disKabulNo }),

  /** Dis lab sonucu: kurallar isler ama OTO-ONAY KAPALI. */
  disLabSonuc: (id: number, govde: { istemSatirId: number; deger: string;
                                     birim?: string; yorum?: string;
                                     sonucZamani?: string }) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/sonuc`, govde),

  /** durum: 3 dis lab reddetti · 4 numune kayboldu. */
  disLabRet: (id: number, istemSatirId: number, durum: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/ret`,
      { istemSatirId, durum, neden }),

  disLabFatura: (id: number, belgeId: number, tutar?: number) =>
    gonder<{ mesaj: string }>(`/api/lab/dis/${id}/fatura`, { belgeId, tutar }),

  /** Sozlesme TAT'ini asan gonderimler - hastanin sonucu baska binada. */
  disLabGeciken: () =>
    istek<{ liste: Record<string, unknown>[] }>('/api/lab/dis/geciken'),

  // -------------------------------------------------- KALITE KONTROL (442)
  /** KK olcumu: z skoru ve Westgard degerlendirmesi SUNUCUDA hesaplanir. */
  kkOlcum: (govde: { lotId: number; tetkikId: number; seviye: number;
                     deger: number; cihazId?: number; zaman?: string;
                     kaynak?: number; tekrar?: boolean }) =>
    gonder<{ id: number; z: number | null; durum: number; ihlaller: string[];
             mesaj: string }>('/api/lab/kk/olcum', govde),

  /** Ret/uyari sonrasi duzeltici faaliyet (ISO 15189) - metin ZORUNLU. */
  kkAksiyon: (olcumId: number, govde: { aksiyon: string; gozdenGecirilen?: number;
                                        duzeltilen?: number; olay?: number }) =>
    gonder<{ mesaj: string }>(`/api/lab/kk/olcum/${olcumId}/aksiyon`, govde),

  /** Levey-Jennings serisi + ayni donemin cihaz olaylari. */
  labKkLj: (tetkikId: number, ek?: { lotId?: number; seviye?: number; gun?: number }) => {
    const s = new URLSearchParams({ tetkikId: String(tetkikId) });
    if (ek?.lotId) s.set('lotId', String(ek.lotId));
    if (ek?.seviye) s.set('seviye', String(ek.seviye));
    if (ek?.gun) s.set('gun', String(ek.gun));
    return istek<{ tetkik: Record<string, unknown> | null;
                   seri: Record<string, unknown>[];
                   olaylar: Record<string, unknown>[] }>(`/api/lab/kk/lj?${s}`);
  },

  /** Dis kalite sonucu; SDI = (bizim - hedef) / grup SD, sunucuda. */
  kkDkk: (govde: { program: string; donem: string; tetkikId: number;
                   numuneKodu?: string; sonucumuz: number; hedef: number;
                   grupSd?: number; grupN?: number; yontem?: string;
                   raporTarihi?: string }) =>
    gonder<{ id: number; sdi: number | null; degerlendirme: number; mesaj: string }>(
      '/api/lab/kk/dkk', govde),

  /** Cihazdan gelen KONTROL mesajini KK olcumune cevirir. */
  kkCihazMesaj: (mesajId: number) =>
    gonder<{ yazilan: number; mesaj: string }>(`/api/lab/kk/cihaz-mesaj/${mesajId}`, {}),

  /** Testlerin KK gecerliligi - oto-onay penceresi. */
  kkDurum: () =>
    istek<{ liste: Record<string, unknown>[] }>('/api/lab/kk/durum'),

  // --------------------------------------------------------- GENETIK (439)
  /** Istem satirindan genetik vaka acar; rapor icin ONAM sart (KVKK md. 6). */
  genetikVakaAc: (istemSatirId: number, istek?: { panelId?: number;
                                                  endikasyon?: string;
                                                  taniIcd?: string;
                                                  aileOykusu?: string;
                                                  anaVakaId?: number;
                                                  aileRolu?: number }) =>
    gonder<{ vakaId: number; vakaNo: string; mesaj: string }>(
      `/api/lab/satir/${istemSatirId}/genetik-vaka`, istek ?? {}),

  /** Vaka calisma alani: onam, kalite, varyantlar. */
  genetikVakaOku: (id: number) =>
    istek<Record<string, unknown>>(`/api/lab/genetik/${id}`),

  /** tesadufiBulgu: 1 istiyor · 2 istemiyor - raporlamayi dogrudan degistirir. */
  genetikOnam: (id: number, govde: { surum: string; tesadufiBulgu: number;
                                     veriSaklamaYil?: number;
                                     arastirmaIzni?: boolean }) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/onam`, govde),

  genetikIzolasyon: (id: number, konsantrasyon: number, saflik: number,
                     not?: string) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/izolasyon`,
      { konsantrasyon, saflik, not }),

  genetikRunaAl: (id: number, govde: { runId?: number; runKodu?: string;
                                       cihazAdi?: string; kit?: string;
                                       kitLot?: string; flowCell?: string;
                                       barkodIndex?: string }) =>
    gonder<{ runId: number; runKodu: string; mesaj: string }>(
      `/api/lab/genetik/${id}/run`, govde),

  genetikKalite: (id: number, govde: { q30?: number; okumaSayisi?: number;
                                       ortDerinlik?: number; kapsamaYuzde?: number;
                                       kontaminasyon?: number;
                                       cinsiyetDogrulama?: number; kalite?: number;
                                       fastqYol?: string; bamYol?: string;
                                       vcfYol?: string; hamHash?: string }) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/kalite`, govde),

  /** Sinif ACMG kanitlarindan SUNUCUDA turetilir; banka uyarisi yanitla doner. */
  genetikVaryant: (id: number, govde: { genSembol: string; transkript?: string;
                                        hgvsC: string; hgvsP?: string;
                                        zigosite?: number; derinlik?: number;
                                        vaf?: number; gnomadAf?: number;
                                        clinVar?: string; clinVarId?: string;
                                        acmgKriterler?: string[];
                                        ikincilBulgu?: boolean; yorum?: string }) =>
    gonder<{ id: number; sinif: number; sinifAdi: string; raporlanir: boolean;
             bankaUyarisi: string | null; mesaj: string }>(
      `/api/lab/genetik/${id}/varyant`, govde),

  varyantSinif: (id: number, sinif: number, neden: string, raporla?: boolean) =>
    gonder<{ mesaj: string }>(`/api/lab/varyant/${id}/sinif`,
      { sinif, neden, raporla }),

  /** durum: 1 istendi · 2 dogrulandi · 3 dogrulanamadi (rapordan cikar). */
  varyantDogrulama: (id: number, durum: number, yontem?: string) =>
    gonder<{ mesaj: string }>(`/api/lab/varyant/${id}/dogrulama`, { durum, yontem }),

  genetikOnayla: (id: number, yorum?: string, oneriler?: string,
                  sinirliliklar?: string) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/onayla`,
      { yorum, oneriler, sinirliliklar }),

  genetikIptal: (id: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/lab/genetik/${id}/iptal`, { neden }),

  /** Bilgi bankasindaki sinif degisince etkilenen ONAYLI vakalar. */
  genetikYenidenDegerlendirme: () =>
    istek<{ liste: Record<string, unknown>[] }>(
      '/api/lab/genetik/yeniden-degerlendirme'),

  /** Hastaya verilen SONUC RAPORU (441): uc bolum de tek uctan gelir. */
  labRaporCikti: (istemId: number) =>
    istek<{
      istem: Record<string, unknown>;
      sonuclar: Record<string, unknown>[];
      kulturler: Record<string, unknown>[];
      izolatlar: Record<string, unknown>[];
      antibiyogram: Record<string, unknown>[];
      vakalar: Record<string, unknown>[];
      varyantlar: Record<string, unknown>[];
      kurum: Record<string, unknown> | null;
    }>(`/api/lab/rapor/${istemId}`),

  // --------------------------------------------------- MIKROBIYOLOJI (436)
  /** Kulturu acar: besiyeri seti verilmezse tetkigin varsayilani kullanilir. */
  labEkim: (istemSatirId: number, istek?: { besiyeriIdler?: number[];
                                            sicaklik?: number; atmosfer?: number;
                                            direktBaki?: string; gramSonuc?: string;
                                            numuneKalite?: string }) =>
    gonder<{ kulturId: number; mesaj: string }>(
      `/api/lab/satir/${istemSatirId}/ekim`, istek ?? {}),

  /** Kultur calisma alani: besiyeri + okuma + izolat + antibiyogram. */
  labKulturOku: (id: number) =>
    istek<Record<string, unknown>>(`/api/lab/kultur/${id}`),

  labKulturOkuma: (id: number, govde: { saat?: number; uremeVar: boolean;
                                        bulgu?: string; sonrakiAdim?: string }) =>
    gonder<{ mesaj: string }>(`/api/lab/kultur/${id}/okuma`, govde),

  /** Gram / erken bulgu hekime: kultur bitmeden gider. */
  labKulturOnRapor: (id: number, metin: string, kritik = false) =>
    gonder<{ mesaj: string }>(`/api/lab/kultur/${id}/on-rapor`, { metin, kritik }),

  labKulturIzolat: (id: number, govde: { organizmaId: number; koloniSayisi?: number;
                                         koloniBirim?: string; idYontem?: number;
                                         idGuven?: number; esbl?: number;
                                         karbapenemaz?: number; mrsa?: number;
                                         vre?: number; ampc?: number;
                                         direncNotu?: string; anlamli?: boolean }) =>
    gonder<{ uremeId: number; mesaj: string }>(`/api/lab/kultur/${id}/izolat`, govde),

  /** Kademeli bildirimi SUNUCU hesaplar; yanit kac satirin raporlanacagini soyler. */
  labAntibiyogram: (uremeId: number, govde: {
      standart?: string; standartSurum?: string;
      satirlar: { antibiyotikId: number; mic?: number; micIsaret?: string;
                  zonMm?: number; yorum: string; kaynak?: number;
                  aciklama?: string }[] }) =>
    gonder<{ satir: number; bildirilen: number; mesaj: string }>(
      `/api/lab/izolat/${uremeId}/antibiyogram`, govde),

  /** Uzman S/I/R degistirir - GEREKCE zorunlu. */
  labAntibiyogramYorum: (id: number, yorum: string, neden: string, bildir = true) =>
    gonder<{ mesaj: string }>(`/api/lab/antibiyogram/${id}/yorum`,
      { yorum, neden, bildir }),

  labKulturOnayla: (id: number, yorum?: string) =>
    gonder<{ mesaj: string }>(`/api/lab/kultur/${id}/onayla`, { yorum }),

  labKulturIptal: (id: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/lab/kultur/${id}/iptal`, { neden }),

};
