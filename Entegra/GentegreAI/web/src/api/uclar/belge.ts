import {
  type BelgeYaniti,
  type AcikSatir,
  type EBelgeMesaji,
  type KurumProfil, type KurumProfilYaniti, type ProfilRolu,
} from '../sozlesme';
import { istek, gonder } from '../cekirdek';

/** Belge, kurum profili, gelen belge kutusu. */
export const belgeUclari = {
  // -------------------------------------------------------------- belge ----
  // ----------------------------------------------------- kurum profili ----
  /** Kurum tipi & sistem ayarlari (359): profil + tip/modul kataloglari. */
  kurumProfil: (sube?: number) =>
    istek<KurumProfilYaniti>(`/api/kurum-profil${sube === undefined ? '' : `?sube=${sube}`}`),
  /** Profili yazar - verilmeyen alanlar mevcut degerini korur. */
  /** Standart roller (712): kurum tipinin şablonları ve kurulum. */
  /**
   * `tumTipler` (agac gorunumu): tipe uymayan sablonlar da listelenir ve
   * `tipUygun: false` ile isaretlenir - gizlemeyi EKRAN secer.
   */
  standartRoller: (kurumTipi?: string, tumTipler?: boolean) =>
    istek<{ kurumTipi: string; bolumler: string[];
            roller: { kod: string; ad: string; amac: string; mevcut: boolean;
                      rolId?: number | null; aktif?: boolean | null;
                      modul?: string | null; modulKapali: boolean; tipUygun: boolean;
                      bolum: string; ust?: string | null; sira: number;
                      yetkiSayisi: number; ekran: number; aksiyon: number }[] }>(
      `/api/kurum-profil/standart-roller?${new URLSearchParams({
        ...(kurumTipi ? { kurumTipi } : {}),
        ...(tumTipler ? { tumTipler: 'true' } : {}),
      })}`),
  standartRolleriKur: (g: { kurumTipi?: string; kodlar?: string[]; guncelle?: boolean }) =>
    gonder<{ kurumTipi: string; kuruldu: string[]; guncellendi: string[]; atlandi: string[] }>('/api/kurum-profil/standart-roller', g),
  /**
   * PROFILDE GECERLI ROLLER (786): kurulu TUM roller + sablonun varsayilani +
   * kurumun kendi isareti. Isaretleme ekrani kapatilacaklari da gormeli, o
   * yuzden burada sablon suzgeci UYGULANMAZ.
   */
  /**
   * PORTAL ROLÜNÜ AÇ/KAPAT. Kurum tipi geçerlilik haritasına yazmaz: harita
   * kurum içi kadroyu anlatıyor ve portal rolünü bilinçle atlıyor (829).
   */
  portalRolAktif: (g: { kod: string; aktif: boolean }) =>
    gonder<{ kod: string; aktif: boolean; degisti: boolean; kisi: number }>(
      '/api/kurum-profil/standart-roller/portal-aktif', g),

  profilRolleri: (kurumTipi?: string) =>
    istek<{ kurumTipi: string; yazili: boolean; bolumler: string[]; roller: ProfilRolu[] }>(
      `/api/kurum-profil/standart-roller/profil-rolleri${
        kurumTipi ? `?kurumTipi=${encodeURIComponent(kurumTipi)}` : ''}`),
  /** Profili yazar - verilmeyen alanlar mevcut degerini korur. `roller` +
      `rolAdaylari` birlikte verilirse rol haritasi da yazilir ve uygulanir. */
  kurumProfilYaz: (govde: Partial<KurumProfil> & { roller?: string[]; rolAdaylari?: string[] }) =>
    gonder<{ profil: KurumProfil; rolSayisi?: number | null }>('/api/kurum-profil', govde, 'PUT'),
  /** Fiyat listesini satirlariyla kopyalar (540). */
  fiyatListesiKopyala: (id: number, ad?: string) =>
    gonder<{ id: number; mesaj: string }>(
      `/api/fiyat-listesi/${id}/kopyala`, { ad }),
  /** SUT listesini SKRS ambarindan tazeler (535) - fiyat kilidini yalniz bu
      yol acar. */
  fiyatSutGuncelle: (id: number) =>
    gonder<{ liste: string; guncellenen: number; eslesmeyen: number;
             ambar: number; mesaj: string }>(
      `/api/fiyat-listesi/${id}/sut-guncelle`, {}),
  /**
   * TOPLU SATIR DEGERI (kullanici: "modalde seçili / kategoriye / tüm
   * listeye uygula"). Kapsam sunucuda cozulur - grid 200'erlik sayfalarla
   * geldigi icin "tüm liste" istemcide yapilamaz.
   */
  fiyatTopluDeger: (id: number, govde: {
    islem: 'carpan' | 'katki' | 'fiyat-yuzde';
    deger: number;
    kapsam: 'secili' | 'kategori' | 'tumu';
    satirIdler?: number[];
    kategoriId?: number;
    yon?: 'artir' | 'azalt';
  }) =>
    gonder<{ liste: string; etkilenen: number; mesaj: string }>(
      `/api/fiyat-listesi/${id}/toplu-deger`, govde),
  /** Kategori acik/kapali (527) - hizmet/stok durumunu DB tetigi yayar. */
  kurumKategoriYaz: (id: number, aktif: number) =>
    gonder<{ id: number; aktif: number }>('/api/kurum-profil/kategori',
                                          { id, aktif }, 'PUT'),
  /** Secili kurum tipinin onerdigi kategori setini uygular (527). */
  kurumKategoriUygula: () =>
    gonder<{ kurumTipi: string; degisen: number; mesaj: string }>(
      '/api/kurum-profil/kategori-uygula', {}),

  belgeOku: (id: number) => istek<BelgeYaniti>(`/api/belge/${id}`),

  /**
   * BASVURU COMBOLARININ KAYNAGI: odeyen kurumlar, bolumler, depolar.
   *
   * Eskiden ucu de KART KAYNAGINDAN (`/api/liste/kurum` vb.) cekiliyordu ve
   * her biri kendi kaynak yetkisini istiyordu - banko rolunde "kurum" gor
   * yetkisi olmadigi icin combo SESSIZCE bos kaliyordu. Combo doldurmak kart
   * yetkisi degildir: basvuru acabilen kisi odeyen kurumu secebilmeli.
   */
  basvuruKaynaklari: () => istek<{
    kurumlar: { id: number; ad: string; tur: number }[];
    bolumler: { id: number; ad: string }[];
    depolar: { id: number; ad: string }[];
    /** Aktif fiyat listeleri - `yon` 1 alis, 2 satis. */
    fiyatListeleri: { id: number; ad: string; yon: number; tarifeTipi: number }[];
  }>('/api/belge/basvuru-kaynaklari'),
  belgeEkle: (govde: unknown) => gonder<BelgeYaniti>('/api/belge', govde),

  /** Donusturulmeyi bekleyen satirlar (siparis/irsaliye kalanlari). */
  belgeAcikSatirlar: (id: number) =>
    istek<{ satirlar: AcikSatir[] }>(`/api/belge/${id}/acik-satirlar`).then(y => y.satirlar),

  /** Bu belgeden turetilmis belgeler (irsaliye kartinin Faturalama sekmesi). */
  belgeDonusumler: (id: number) =>
    istek<{ belgeler: Record<string, unknown>[] }>(`/api/belge/${id}/donusumler`)
      .then(y => y.belgeler),

  /** Kayitli belgeyi duzenler (135) - numara korunur, stok/cari yeniden yazilir. */
  belgeGuncelle: (id: number, govde: unknown) =>
    gonder<BelgeYaniti>(`/api/belge/${id}`, govde, 'PUT'),

  /**
   * IADE faturasinda secilebilecek "onceki alinanlar" (132): carinin kesin
   * fatura satirlari, iade edilmis miktar dusulmus olarak.
   */
  iadeSatirlari: (tarafId: number, belgeId?: number, ara?: string, turler?: number[]) =>
    istek<{ satirlar: Record<string, unknown>[] }>(
      `/api/belge/iade-satirlari?tarafId=${tarafId}`
      + (belgeId ? `&belgeId=${belgeId}` : '')
      + (ara ? `&ara=${encodeURIComponent(ara)}` : '')
      + (turler?.length ? `&turler=${turler.join(',')}` : '')).then(y => y.satirlar),

  /** Belgeyi siler (181). Izli belgede sunucu 422 doner (sebep mesajda). */
  belgeSil: (id: number) =>
    istek<{ mesaj: string }>(`/api/belge/${id}`, { method: 'DELETE' }),

  /** Carinin GIB e-Fatura kaydini sorar, bayragi gunceller (183). */
  cariEBelgeMukellef: (id: number) =>
    gonder<{ mukellef: boolean; durum: string; degisti: boolean;
             gelen: { unvan: string; vergiDairesi: string; il: string; ilce: string; adres: string };
             kayitli: { unvan: string; vkno: string } }>(
      `/api/kart/cari/${id}/ebelge-mukellef`, {}),

  // ------------------------------------------------------ gelen belge ----
  /** Entegrator kutusunu tarar, gelen belgeleri kaydeder (187). */
  gelenKutuYenile: (baslangic?: string, bitis?: string) =>
    gonder<{ okunan: number; yeni: number; guncellenen: number; mesaj: string }>(
      '/api/gelen-belge/kutu-yenile',
      { baslangic: baslangic ?? null, bitis: bitis ?? null }),

  /** Gelen belgenin UBL XML'i; ilk cagride entegratorden indirilir (187). */
  gelenBelgeUbl: (id: number) =>
    istek<{ ubl: string }>(`/api/gelen-belge/${id}/ubl`),

  /** Gelen ticari faturaya KABUL / RED yaniti (187). Kabulde belge alis
      faturasina da aktarilir; olusan belge id'si `belgeId` ile doner. */
  gelenBelgeYanit: (id: number, kabul: boolean, aciklama: string) =>
    gonder<{ basarili: boolean; mesaj: string; belgeId: number | null }>(
      `/api/gelen-belge/${id}/yanit`, { kabul, aciklama }),

  /** Gelen belgenin gecmisi (189): kutuya dusme, zarf, indirme, yanit, aktarim. */
  gelenBelgeMesajlar: (id: number) =>
    istek<{ mesajlar: EBelgeMesaji[] }>(`/api/gelen-belge/${id}/mesajlar`),

  /** Gelen belgeyi ALIS FATURASINA aktarir (187). */
  gelenBelgeAktar: (id: number) =>
    gonder<{ belgeId: number; belgeNo: string; satirSayisi: number;
             eslesenStok: number; mesaj: string }>(`/api/gelen-belge/${id}/aktar`, {}),

  /** Siparis rezervasyonu - 142. ac=false rezervi kaldirir. */
  belgeRezerve: (id: number, ac: boolean) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/rezerve`, { ac }),

  /** Termin (teslim tarihi) guncelleme - 140. Tarih null = termin kaldirildi. */
  belgeTermin: (id: number, satirlar: { satirId: number; teslimTarihi: string | null }[]) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/termin`, { satirlar }),

  /**
   * Belge donusumu. `pay` (289): 0/bos tum satir · 1 yalniz HASTA payi ·
   * 2 yalniz KURUM payi - kurum payinda hedef belgenin carisi odeyen kurum olur.
   */
  belgeDonustur: (id: number, hedefTur: number,
                  satirlar: { satirId: number; miktar: number; tutar?: number;
                              tutarKdvli?: number }[],
                  belgeTarihi?: string, taslak = false, belgeNo?: string,
                  pay = 0, kalaniTahakkuk = false) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/donustur`,
                        { hedefTur, satirlar, belgeTarihi, taslak, belgeNo, pay, kalaniTahakkuk }),

};
