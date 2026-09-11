import {
  type BelgeYaniti,
  type AcikSatir,
  type EBelgeMesaji,
  type TopluEBelgeSonucu,
  type KurumProfil, type KurumProfilYaniti,
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
  kurumProfilYaz: (govde: Partial<KurumProfil>) =>
    gonder<{ profil: KurumProfil }>('/api/kurum-profil', govde, 'PUT'),
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
  /** Kategori acik/kapali (527) - hizmet/stok durumunu DB tetigi yayar. */
  kurumKategoriYaz: (id: number, aktif: number) =>
    gonder<{ id: number; aktif: number }>('/api/kurum-profil/kategori',
                                          { id, aktif }, 'PUT'),
  /** Secili kurum tipinin onerdigi kategori setini uygular (527). */
  kurumKategoriUygula: () =>
    gonder<{ kurumTipi: string; degisen: number; mesaj: string }>(
      '/api/kurum-profil/kategori-uygula', {}),

  belgeOku: (id: number) => istek<BelgeYaniti>(`/api/belge/${id}`),
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

  /** Siparis -> irsaliye -> fatura. Miktar KISMI olabilir; kalan kaynakta durur. */
  /**
   * e-BELGE HAZIRLA (163): belgeyi kuyruga alir - dogrular, e-Fatura/e-Arsiv/
   * e-Irsaliye kararini verir, seri ve numara atar. XML gonderim asamasinda.
   */
  belgeEBelgeHazirla: (id: number) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/ebelge-hazirla`, {}),

  /**
   * e-BELGE GONDER: hazirlanmis belgeyi entegratore yollar. GERI ALINAMAZ -
   * GIB'e giden belge iptal edilmez, yalniz iade faturasiyla duzeltilir.
   */
  belgeEBelgeGonder: (id: number, aliciAlias?: string) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/ebelge-gonder`, { aliciAlias: aliciAlias ?? null }),

  /** Gonderim oncesi alici adresi (184): e-Arsivde alias = alici e-postasi. */
  belgeEBelgeAlici: (id: number) =>
    istek<{ belgeTuru: number; alias: string; onerilenMail: string; tarafUnvan: string }>(
      `/api/belge/${id}/ebelge-alici`),

  /** Belgeyi siler (181). Izli belgede sunucu 422 doner (sebep mesajda). */
  belgeSil: (id: number) =>
    istek<{ mesaj: string }>(`/api/belge/${id}`, { method: 'DELETE' }),

  /** Onizleme HTML'i (178) - gonderim gerekmez. */
  belgeEBelgeOnizle: (id: number) =>
    istek<{ html: string }>(`/api/belge/${id}/ebelge-onizle`),

  /** GIB durumunu entegratorden ceker ve kayda isler (183). */
  belgeEBelgeDurum: (id: number) =>
    gonder<{ belgeNo: string; kod: string; aciklama: string; degisti: boolean }>(
      `/api/belge/${id}/ebelge-durum`, {}),

  /** Carinin GIB e-Fatura kaydini sorar, bayragi gunceller (183). */
  cariEBelgeMukellef: (id: number) =>
    gonder<{ mukellef: boolean; durum: string; degisti: boolean;
             gelen: { unvan: string; vergiDairesi: string; il: string; ilce: string; adres: string };
             kayitli: { unvan: string; vkno: string } }>(
      `/api/kart/cari/${id}/ebelge-mukellef`, {}),

  /** Toplu e-Belge (183): secili belgeleri hazirlar ya da gonderir. */
  belgeEBelgeToplu: (belgeler: number[], islem: 'hazirla' | 'gonder') =>
    gonder<{ sonuclar: TopluEBelgeSonucu[] }>('/api/belge/ebelge-toplu', { belgeler, islem }),

  /** UBL-XML + goruntuleme XSLT'si (182): "XML Kaydet" ve XSLT'li on izleme. */
  belgeEBelgeUbl: (id: number) =>
    istek<{ ubl: string; xslt: string; dosyaAdi: string }>(`/api/belge/${id}/ebelge-ubl`),

  /** Gonderim govdesi (entegratore giden ham istek). */
  belgeEBelgeGovde: (id: number) =>
    istek<{ bicim: number; govde: string; dosyaAdi: string }>(`/api/belge/${id}/ebelge-govde`),

  /** e-Belge gecmisi: hazirlama, gonderim, GIB yaniti (178). */
  belgeEBelgeMesajlar: (id: number) =>
    istek<{ mesajlar: EBelgeMesaji[] }>(`/api/belge/${id}/ebelge-mesajlar`),

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

  /** GIDEN belgeyi iptal eder / iptal talebi acar (188). Hangisi oldugunu
      sunucu belirler: e-Arsiv dogrudan iptal, e-Fatura talep. */
  belgeEBelgeIptal: (id: number, gerekce: string) =>
    gonder<{ basarili: boolean; yeniDurum: number; mesaj: string }>(
      `/api/belge/${id}/ebelge-iptal`, { gerekce }),

  /** e-Belgeyi geri al (164): kayit silinir, belge yeniden hazirlanabilir. */
  belgeEBelgeSifirla: (id: number) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/ebelge-sifirla`, {}),

  /** e-Belge serisini degistir (164). Seri bos ise siradaki kurala gecer. */
  belgeEBelgeSeri: (id: number, seri?: string) =>
    gonder<BelgeYaniti>(`/api/belge/${id}/ebelge-seri`, { seri: seri ?? null }),

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
