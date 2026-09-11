import {
  type StokDurumYaniti, type StokHareketYaniti, type StokLotSatiri, type PaketIcerikSatiri,
  type PanelYaniti,
  } from '../sozlesme';
import { istek, gonder, dosyaYukle, dosyaIndir } from '../cekirdek';

/** Stok durumu, hareket, paket icerigi ve ana sayfa. */
export const stokUclari = {
  // ------------------------------------------ stok karti: Stok Durumu ----
  /** Depo bazli miktar/rezerve/kullanilabilir + KPI seridi (salt okunur). */
  stokDurum: (stokId: number) =>
    istek<StokDurumYaniti>(`/api/kart/stok/${stokId}/durum`),

  /** Hareket dokumu: tarih araligi + depo suzgeci, yurumeli kalan. */
  stokHareket: (stokId: number, bas: string, bit: string, depoId?: number | null) =>
    istek<StokHareketYaniti>(`/api/kart/stok/${stokId}/hareket?bas=${bas}&bit=${bit}`
      + (depoId ? `&depoId=${depoId}` : '')),

  /** Cikis belgesinde secilebilecek lotlar: stokta KALANI olanlar (114). */
  stokLotlari: (stokId: number, depoId?: number | null) =>
    istek<{ lotlar: StokLotSatiri[] }>(`/api/kart/stok/${stokId}/lot`
      + (depoId ? `?depoId=${depoId}` : '')).then(y => y.lotlar),

  /** Paket icerigi (124): belge kaleminde paket secilince acilan satirlar. */
  paketIcerigi: (stokId: number, alis = false) =>
    istek<{ icerik: PaketIcerikSatiri[] }>(
      `/api/kart/stok/${stokId}/paket${alis ? '?alis=true' : ''}`).then(y => y.icerik),

  /** Stok kartini kopyalar (126): kod "_Kn", ad " kopya"; paket icerigi de gelir. */
  stokKopyala: (stokId: number) =>
    istek<{ id: number }>(`/api/kart/stok/${stokId}/kopyala`, { method: 'POST' }).then(y => y.id),

  /**
   * Fiyat listesini URETIR (202): satirlari kurala gore yeniden yazar.
   * MANUEL girilen satirlar korunur; fiyati cozulemeyen kalemler atlanir ve
   * sayilari mesajda bildirilir.
   */
  fiyatListesiUret: (listeId: number, secim?: { stok?: boolean; hizmet?: boolean }) =>
    istek<{ eklenen: number; guncellenen: number; korunan: number; fiyatsiz: number; mesaj: string }>(
      `/api/fiyat-listesi/${listeId}/uret`,
      { method: 'POST', body: JSON.stringify({ stok: secim?.stok ?? true, hizmet: secim?.hizmet ?? true }) }),

  /** Excel sablonu (207): dolu=true mevcut satirlari doldurur. Blob URL doner. */
  fiyatListesiSablon: (listeId: number, dolu: boolean) =>
    dosyaIndir(`/api/fiyat-listesi/${listeId}/sablon${dolu ? '?dolu=1' : ''}`),

  /**
   * Excel'den iceri alma (207). YA HEP YA HIC: sunucu bir hata bile bulursa
   * hicbir satir yazmaz ve 422 govdesinde satir numarali hatalar doner
   * (ApiHatasi.hata icinde satirHatalari).
   */
  fiyatListesiIceriAl: (listeId: number, dosya: File) => {
    const form = new FormData();
    form.append('dosya', dosya);
    return dosyaYukle<{ eklenen: number; guncellenen: number; toplam: number; mesaj: string }>(
      `/api/fiyat-listesi/${listeId}/iceri-al`, form);
  },

  /** Belge acilirken gelecek fiyat listesi (205): turun yonune gore cari listesi > varsayilan. */
  belgeVarsayilanListe: (tur: number, tarafId: number, kurumId?: number | null) =>
    istek<{ listeId: number | null; ad: string; yon: number; kdvDahil: number }>(
      `/api/belge/varsayilan-liste?tur=${tur}&tarafId=${tarafId}`
      + (kurumId ? `&kurumId=${kurumId}` : '')),

  /** Arama ekraninin fiyat sutunu (495): coklu kalemin liste fiyati tek istekte. */
  fiyatListesiFiyatlar: (listeId: number,
                         kalemler: { stokId?: number; hizmetId?: number }[]) =>
    gonder<{ listeId: number;
             satirlar: { stokId?: number | null; hizmetId?: number | null;
                         fiyat: number | null; dovizCinsi: string;
                         kdvDahil: number }[] }>(
      `/api/fiyat-listesi/${listeId}/fiyatlar`, { kalemler }),

  /** Tek kalemin liste fiyati - liste henuz uretilmemis olsa da kural isletilir. */
  fiyatListesiFiyat: (listeId: number, kalem: { stokId?: number; hizmetId?: number }) =>
    istek<{ fiyat: number | null; dovizCinsi: string; kdvDahil: number; kaynak: string }>(
      `/api/fiyat-listesi/${listeId}/fiyat?`
      + (kalem.stokId ? `stokId=${kalem.stokId}` : `hizmetId=${kalem.hizmetId}`)),

  /**
   * Yururlukteki kampanya (274) - belge basligindaki rozet. Basvuruda ODEYEN
   * KURUM verilir: odemeyi yapan taraf fiyati belirler.
   */
  fiyatKampanya: (taraf: { tarafId?: number | null; kurumId?: number | null }) =>
    istek<{ kampanyaId: number | null; kod: string; ad: string;
            fiyatListesiId: number | null;
            /** 1 karsilama ORANI (OSS) · 2 KATILIM PAYI sabit tutar (SGK). */
            paylasimModu: number; varsayilanKarsilama: number }>(
      '/api/fiyat/kampanya?'
      + (taraf.kurumId ? `kurumId=${taraf.kurumId}&` : '')
      + (taraf.tarafId ? `tarafId=${taraf.tarafId}` : '')),

  /**
   * Kalem fiyati LISTE + KAMPANYA (274). Baz fiyat listeden gelir, kampanya
   * uzerine indirim isler; kampanyanin kendi listesi varsa baz O olur.
   */
  fiyatKalem: (kalem: { stokId?: number; hizmetId?: number },
               kaynak: { tarafId?: number | null; kurumId?: number | null;
                         listeId?: number | null; sozlesmeId?: number | null;
                         sgkKullan?: number | null }) =>
    istek<{ fiyat: number | null; bazFiyat: number | null; dovizCinsi: string;
            kdvDahil: number; kaynak: string; kampanyaId: number | null;
            listeId: number | null; satirId: number | null; tip: number | null;
            iskontoTipi: number | null; iskonto: number | null;
            /** Odeme rotasi (483): 1 Ozel · 2 OSS · 3 TSS · 4 Karma · 5 SGK. */
            rota: number; sgkGerekli: boolean;
            /** null ise SUT LISTESINDE YOK - bedel ekrandan istenir. */
            sgkFiyat: number | null; sgkListesiId: number | null;
            sgkKdvDahil: number; sgkKatilim: number }>(
      '/api/fiyat/kalem?'
      + (kalem.stokId ? `stokId=${kalem.stokId}` : `hizmetId=${kalem.hizmetId}`)
      + (kaynak.tarafId ? `&tarafId=${kaynak.tarafId}` : '')
      + (kaynak.kurumId ? `&kurumId=${kaynak.kurumId}` : '')
      + (kaynak.listeId ? `&listeId=${kaynak.listeId}` : '')
      // SOZLESME (483): SUT listesi ve rota ondan cikar - kurumun tek
      //   sozlesmesi yoksa sunucu hangi tarifeyi uygulayacagini bilemez.
      + (kaynak.sozlesmeId ? `&sozlesmeId=${kaynak.sozlesmeId}` : '')
      + (kaynak.sgkKullan != null ? `&sgkKullan=${kaynak.sgkKullan}` : '')),

  /** Depo bazli min/max seviye (099). Miktarlara DOKUNMAZ. */
  stokDurumLimit: (stokId: number, depoId: number,
                   minStok: number | null, maxStok: number | null) =>
    gonder<StokDurumYaniti>(`/api/kart/stok/${stokId}/durum/limit`,
                            { depoId, minStok, maxStok }, 'PUT'),

  // -------------------------------------------------------- ana sayfa ----
  /** Panel: kutular + listeler TEK istekte (acilista bes cagri yapmamak icin). */
  panel: () => istek<PanelYaniti>('/api/panel'),

};
