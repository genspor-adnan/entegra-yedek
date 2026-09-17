import {
  type KolonMeta,
  } from '../sozlesme';
import { istek, gonder } from '../cekirdek';

/** Uretim ve urun agaci. */
export const uretimUclari = {
  // ---------------------------------------------------------------- URETIM
  /** Agacin birim maliyetini hesaplar ve TARIHLI olarak karta yazar (429). */
  uretimAgacMaliyet: (agacId: number, gugYuzde = 0) =>
    gonder<{ malzeme: number; iscilik: number; gug: number; toplam: number }>(
      `/api/uretim/agac/${agacId}/maliyet`, { gugYuzde }),

  /** Agaci kopyalar, surumu artirir; ESKI SURUM PASIFLESIR ama silinmez. */
  uretimYeniSurum: (agacId: number) =>
    gonder<{ id: number; kod: string; surum: number; mesaj: string }>(
      `/api/uretim/agac/${agacId}/yeni-surum`, {}),

  /** Ters agac: bilesen hangi mamullerde geciyor (fiyat degisim etkisi). */
  uretimNeredeKullaniliyor: (stokId: number) =>
    istek<{ kayitlar: { id: number; kod: string; ad: string; surum: number;
                        miktar: number; mamul: string }[] }>(
      `/api/uretim/agac/nerede-kullaniliyor/${stokId}`),

  /** Emir acar ve agaci EMRE KOPYALAR (agac sonra degisse emir etkilenmez). */
  uretimEmriAc: (govde: { stokId: number; agacId?: number; adet: number;
                          tur?: number; planBas?: string; termin?: string;
                          sarfDepoId?: number; mamulDepoId?: number;
                          kaynakBelgeId?: number; kaynakSatirId?: number;
                          ustEmirId?: number; aciklama?: string }) =>
    gonder<{ id: number; no: string; bilesen: number; operasyon: number; mesaj: string }>(
      '/api/uretim/emri', govde),

  uretimAgactanYenile: (id: number) =>
    gonder<{ mesaj: string }>(`/api/uretim/emri/${id}/agactan-yenile`, {}),

  uretimRezerve: (id: number, ac: boolean) =>
    gonder<{ satir: number; hazirlik: number; mesaj: string }>(
      `/api/uretim/emri/${id}/rezerve?ac=${ac}`, {}),

  uretimOnayla: (id: number) =>
    gonder<{ mesaj: string }>(`/api/uretim/emri/${id}/onayla`, {}),

  uretimBaslat: (id: number) =>
    gonder<{ sarfBelgeId: number | null; mesaj: string }>(
      `/api/uretim/emri/${id}/baslat`, {}),

  uretimSarf: (id: number, satirlar?: { satirId: number; miktar: number }[]) =>
    gonder<{ belgeId: number; mesaj: string }>(`/api/uretim/emri/${id}/sarf`,
      satirlar ? { satirlar } : {}),

  uretimMamulGiris: (id: number, adet: number, birimFiyat?: number) =>
    gonder<{ belgeId: number; uretilen: number; adet: number; durum: number;
             mesaj: string }>(
      `/api/uretim/emri/${id}/mamul-giris`, { adet, birimFiyat }),

  uretimFire: (id: number, stokId: number, adet: number, neden?: string) =>
    gonder<{ belgeId: number; mesaj: string }>(
      `/api/uretim/emri/${id}/fire`, { stokId, adet, neden }),

  uretimMaliyetKapat: (id: number, gugYuzde = 0) =>
    gonder<{ malzeme: number; iscilik: number; toplam: number; birim: number;
             planBirim: number; farkYuzde: number; mesaj: string }>(
      `/api/uretim/emri/${id}/maliyet-kapat`, { gugYuzde }),

  uretimEmriKapat: (id: number) =>
    gonder<{ mesaj: string }>(`/api/uretim/emri/${id}/kapat`, {}),

  uretimEmriIptal: (id: number, neden: string) =>
    gonder<{ mesaj: string }>(`/api/uretim/emri/${id}/iptal`, { neden }),

  uretimEksikMalzeme: (id: number) =>
    istek<{ hazirlik: number;
            satirlar: { id: number; kod: string; ad: string; gerekli: number;
                        rezerve: number; sarfEdilen: number; mevcut: number;
                        eksik: number }[] }>(
      `/api/uretim/emri/${id}/eksik-malzeme`),

  /** ITS karekod cozumleme (427): GS1 ayristirma SUNUCUDA - her ekranda ayri
      cozumleyici, ayirici gondermeyen okuyucuda birinde calisip otekinde
      bozulurdu. */
  itsKarekod: (karekod: string, dogrula = false) =>
    gonder<{ gtin: string; barkod: string; seriNo: string; partiNo: string;
             sonKullanma: string | null; ilacAd: string; stokId: number;
             katalogda: boolean;
             dogrulama: { gecerli: boolean; durum: string; mesaj: string } | null }>(
      '/api/its/karekod', { karekod, dogrula }),

  /** Mal alim (kabul) bildirimi kuyruga. */
  itsBildirim: (istekGovdesi: { tur: number; belgeId?: number; karsiGln?: string;
                                karekodlar: string[]; islemTarihi?: string }) =>
    gonder<{ bildirimId: number; eklenen: number; mesaj: string }>(
      '/api/its/bildirim', istekGovdesi),

  itsGonder: (id: number) =>
    gonder<{ mesaj: string }>(`/api/its/bildirim/${id}/gonder`, {}),

  itsIptal: (id: number) =>
    gonder<{ mesaj: string }>(`/api/its/bildirim/${id}/iptal`, {}),

  /** Sol paneldeki klasor agaci + sayaclar (419). Kaynak klasorleri SANAL:
      dokumanin kaynak alanindan turer, tablo kaydi yoktur. */
  dokumanKlasorleri: () =>
    istek<{ toplam: number;
            kurumsal: { tur: string; id: number; ad: string; yol: string;
                        ustId: number; sayi: number }[];
            kaynaklar: { tur: string; kod: string; sayi: number }[] }>(
      '/api/dokuman-yonetim/klasorler'),

  /** Depo kullanimi: hash-dedup'in kazandirdigi yer ancak olculunce gorunur. */
  dokumanDepo: () =>
    istek<{ fizikselBayt: number; mantikselBayt: number; tasarrufBayt: number;
            icerikSayisi: number; dokumanSayisi: number }>('/api/dokuman-yonetim/depo'),

  /** Klasor / etiket / gizlilik degisimi - verilmeyen alan DEGISMEZ. */
  dokumanTasi: (id: number, istekGovdesi: { klasorId?: number; etiketler?: string[];
                                            gizlilik?: number }) =>
    gonder<{ mesaj: string }>(`/api/dokuman-yonetim/${id}/tasi`, istekGovdesi),

  /** Sureli / sayacli paylasim linki uretir (424). Ozel nitelikli dokumanda
      sunucu ayri yetki ister (dokuman.ozel_nitelikli). */
  dokumanPaylasimUret: (id: number, istekGovdesi: { gunSayisi?: number;
                                                    azamiAcilma?: number;
                                                    indirmeIzni?: boolean;
                                                    aliciEposta?: string }) =>
    gonder<{ paylasimId: number; kod: string; mesaj: string }>(
      `/api/dokuman-yonetim/${id}/paylasim`, istekGovdesi),

  /** Link SILINMEZ, iptal DAMGALANIR: silinen kod yeniden uretilebilir ve
      eski alici erisim kazanirdi. */
  dokumanPaylasimIptal: (paylasimId: number) =>
    gonder<{ mesaj: string }>(`/api/dokuman-yonetim/paylasim/${paylasimId}/iptal`, {}),

  /** Ek baglanti (419): birincil bag (dokuman.kaynak) DEGISMEZ, dokuman
      ikinci bir kayda da baglanir - ayni sozlesme hem cariye hem projeye. */
  dokumanBaglantiEkle: (id: number, kaynak: string, kaynakId: number, rol?: string) =>
    gonder<{ mesaj: string }>(`/api/dokuman-yonetim/${id}/baglanti`,
      { kaynak, kaynakId, rol }),

  /** Surumu onaya gonderir (419 · 758'de omurgaya tasindi): zinciri onay
      omurgasi kurar, basamaklar akis TANIMINDAN secilir. */
  dokumanOnayaGonder: (surumId: number) =>
    gonder<{ onayId: number; mesaj: string;
             basamaklar: { sira: number; ad: string; rol: number }[] }>(
      `/api/dokuman-yonetim/surum/${surumId}/onaya-gonder`, {}),

  /**
   * Onay adimi karari (758): artik OMURGA ucundan, kaynak_tur 976 ve
   * kaynak_id SURUM id'si. Dokumanin kendi karar ucu kaldirildi - iki yol
   * olsaydi biri zinciri yurutur, oteki dogrudan surumu yayinlardi.
   *
   * Son basamak onaylaninca surum YAYINLANIR, onceki yayin arsive duser
   * (`fn_dokuman_onay_sonuc`).
   */
  dokumanOnayKarar: (surumId: number, karar: number, not?: string) =>
    gonder<{ zincirDurum: number; kayitDurum: number | null;
             basamak: number; adim: string; sonrakiBasamak: number | null }>(
      `/api/onay/kayit/976/${surumId}/karar`,
      { karar: karar === 1 ? 'onayla' : 'reddet', gerekce: not }),

  /** e-Nabiz paketini KAYNAKTAN yeniden uretir (415): paket satirini elle
      duzeltmek, gonderilen veriyle kayittaki veriyi ayirirdi. */
  enabizYenidenUret: (paketId: number) =>
    gonder<{ yeni: string; durum: number; eksikler: string[]; mesaj: string }>(
      `/api/enabiz/paket/${paketId}/yeniden-uret`, {}),

  /** Paketi simdi gonder (415): hesap tanimli degilse sonuc bunu SOYLER. */
  enabizGonder: (paketId: number) =>
    gonder<{ alinan: number; gonderilen: number; hatali: number; mesaj: string }>(
      `/api/enabiz/paket/${paketId}/gonder`, {}),

  enabizPaketIptal: (paketId: number) =>
    gonder<{ mesaj: string }>(`/api/enabiz/paket/${paketId}/iptal`, {}),

  /** Sirayi cagir (410): belge verilmezse hekimin SIRADAKI hastasi. */
  siraCagir: (istek: { belgeId?: number; hekimId?: number }) =>
    gonder<{ belgeId: number; siraNo?: string; hasta?: string; ekranAdi?: string;
             cagirma?: string; mesaj: string }>('/api/muayene/sira/cagir', istek),

  /** Basvurudan muayeneye al: muayene kaydi yoksa ACILIR. */
  basvurudanMuayeneyeAl: (belgeId: number) =>
    gonder<{ belgeId: number; muayeneId: number; baslangic: string; yeni: boolean;
             mesaj: string }>(`/api/muayene/basvuru/${belgeId}/al`, {}),

  /** Muayeneden istem ac (418): asil kayit MODUL tablosunda acilir,
      muayene_istem bag ve durum satiridir. */
  muayeneIstemAc: (muayeneId: number, istek: { tur: number; hizmetId?: number;
                                               aciliyet?: number; aciklama?: string;
                                               tetkikIdler?: number[];
                                               panelIdler?: number[] }) =>
    gonder<{ istemId: number; hedefTablo: string; hedefId: number | null; mesaj: string }>(
      `/api/muayene/${muayeneId}/istem`, istek),

  /** Muayeneye Al (409): baslangic zamani - ikinci tikta ezilmez (sunucu). */
  muayeneyeAl: (id: number) =>
    gonder<{ id: number; baslangic: string; mesaj: string }>(`/api/muayene/${id}/al`, {}),

  /** Muayeneyi tamamla: kayit kilitlenir, eksikse 400 ile reddedilir. */
  muayeneTamamla: (id: number) =>
    gonder<{ id: number; belgeId: number | null; uyari: string | null; mesaj: string }>(
      `/api/muayene/${id}/tamamla`, {}),

  kolonlar: (kaynak: string) =>
    istek<{ kaynak: string; kolonlar: KolonMeta[] }>(`/api/liste/${kaynak}/kolonlar`),

  /** "Son / Sik Aranan" sayacini artirir - kart acilisi disindaki secimler icin
   *  (or. belge kalemine stok secmek). Hata yutulur: sayac akisi bloklamamali. */
  aramaIsaretle: (kaynak: string, id: number) =>
    gonder<{ isaretlendi: boolean }>(`/api/liste/${kaynak}/${id}/isaretle`, {})
      .catch(() => ({ isaretlendi: false })),

  kaynaklar: () => istek<{ kaynaklar: { ad: string; yetkiKodu: string }[] }>('/api/liste'),

};
