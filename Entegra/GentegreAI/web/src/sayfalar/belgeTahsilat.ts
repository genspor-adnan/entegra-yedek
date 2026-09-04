import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { mesaj, onay } from '../bilesenler/mesaj';
import { yerelAnMetni } from '../bilesenler/bicim';
import { type ListeSatiri, hataMetni } from '../api/sozlesme';

/**
 * BELGE TAHSILAT SEKMESI - durum ve akis.
 *
 * Belgeye bagli kasa islemleri (tahsilat/odeme) BelgeKarti icinde yedi ayri
 * state + iki efekt + uc fonksiyon tutuyordu; kartin geri kalaniyla paylastigi
 * tek sey belge kimligi ve cari. Akis kendi basina anlasilir olsun diye burada.
 *
 * Akis: dugme -> (gerekirse belge kaydedilir) -> tahsilatAdimi ->
 *   cek/senet ise once JENERIK KIYMET KARTI, sonra ona BAGLI kasa islemi;
 *   nakit/banka/POS ise dogrudan kasa islemi.
 */

/** Cek/senet ile tahsilat-odeme turleri (23/24 alinan, 33/34 verilen). */
const CEK_SENET_TURLERI = [23, 24, 33, 34];

export interface TahsilatAcilisi {
  tur: number;
  tarafId?: number;
  tarafUnvan?: string;
  belgeId?: number;
  tutar?: string;
  cekSenetId?: number;
}

export function useBelgeTahsilat({ kayitliId, aktifSekme, cari, onKaydedildi, setHata,
                                  onPencereKapandi }: {
  kayitliId: number;
  aktifSekme: string;
  cari: { id: number; unvan: string } | null;
  onKaydedildi?(): void;
  setHata(mesaj: string | null): void;
  /**
   * Tahsilat penceresi kapandi (tur = kasa islem turu). Kart kaydedilmis de
   * olabilir vazgecilmis de - cagiran taraf tahsilat listesine bakarak karar
   * verir. POS aksiyonu (355) buna baglidir.
   */
  onPencereKapandi?(tur: number): void;
}) {
  /** Bu belgeye baglanmis kasa islemleri (Tahsilat sekmesi). */
  const [tahsilatlar, setTahsilatlar] = useState<ListeSatiri[]>([]);
  /** Acik tahsilat modalinin TURU (null = kapali) - fatura arkada acik kalir. */
  const [tahsilatAcik, setTahsilatAcik] = useState<number | null>(null);
  /** Tahsilat kaydedilince listeyi tazelemek icin sayac. */
  const [tahsilatYenile, setTahsilatYenile] = useState(0);
  /** Cek/senet ile tahsilatta once acilan JENERIK kiymet karti (tur + belge). */
  const [cekTuru, setCekTuru] = useState<{ tur: number; belgeId: number } | null>(null);
  /** Kiymet kaydedildikten sonra acilan kasa islemi (ayni kiymete bagli). */
  const [tahsilatAcilis, setTahsilatAcilis] = useState<TahsilatAcilisi | null>(null);
  /** Tahsilat listesinde SECILI kasa islemleri (duzelt/sil dugmeleri bunu
      kullanir). Coklu (kullanici): basliktaki "tumunu sec" kutusu ve yanlis
      girilen birden cok tahsilati birlikte silmek icin - duzeltme yine tek
      satirda calisir. */
  const [seciliTahsilatlar, setSeciliTahsilatlar] = useState<number[]>([]);
  /** DUZELTME icin acilan MEVCUT kasa islemi - yeni tahsilattan ayri state:
      biri tur ile acar, oteki kayit kimligiyle. */
  const [tahsilatKayitId, setTahsilatKayitId] = useState<number | null>(null);

  const tazele = () => setTahsilatYenile(t => t + 1);

  /**
   * HIZLI TAHSILAT (kullanici): kasa kartini ACMADAN gride satir ekler -
   * nakitte varsayilan kasa, banka/POS'ta secilen hesap. Tutar cagirandan
   * gelir (varsayilan: belgenin acik borcu); satir eklendikten sonra tutar
   * gridde tiklanip degistirilebilir.
   *
   * Tahsilat GERCEKLESMIS kaydedilir (taslak degil): kasa kartindaki normal
   * akisla ayni - yalniz alan sorma adimi atlanir.
   */
  const hizliTahsilat = async (tur: number, hesapId: number, tutar: number,
                               hesapAdi = '') => {
    // Hata SESSIZ KALMASIN (kullanici: "seçtim ama satıra eklenmedi"): hizli
    //   akista kart acilmadigi icin sekmedeki hata kutusu gorunmuyordu -
    //   uyarilar pencereyle verilir.
    if (!kayitliId) { mesaj('Önce belgeyi kaydedin.'); return }
    if (!hesapId) { mesaj('Kasa / hesap seçilmeli.'); return }
    if (!(tutar > 0)) { mesaj('Tahsilat tutarı sıfırdan büyük olmalı.'); return }
    setHata(null);
    try {
      const y = await api.kasaEkle({
        islem: {
          tur,
          islemTarihi: yerelAnMetni(new Date()),
          tarafId: cari?.id ?? null,
          hesapId,
          tutar,
          dovizCinsi: 'TL',
          dovizKuru: 1,
          aciklama: hesapAdi ? `Hızlı tahsilat · ${hesapAdi}` : 'Hızlı tahsilat',
        },
        secenekler: { taslak: false, plan: false, kurKontrolu: true, belgeId: kayitliId },
      });

      // TAHSILATI SATIRLARA DAGIT (321/352): belgeye baglamak YETMEZ - fis /
      //   fatura donusumu "tahsil edilen kadar" hesabini `kasa_islem_dagitim`
      //   satirlarindan okur. Dagitim yazilmazsa para tahsil edilmis gorunur
      //   ama "Dönüştürülecek tutar yok" denir; POS sonrasi otomatik fis de
      //   sessizce hic kesilmezdi. Kasa KARTI bunu zaten yaziyor (321), hizli
      //   akista atlaniyordu.
      // Otomatik = satir sirasina gore once hasta payi, sonra kurum payi.
      const yeniId = Number(y.islem?.id ?? 0);
      if (yeniId) {
        try { await api.kasaDagitimYaz(yeniId, { belgeId: kayitliId, otomatik: true }) }
        // Dagitim basarisiz olursa TAHSILAT DURUR: para kasada, belgeye bagli.
        //   Kullanici dagitimi Tahsilat ekranindan elle yapabilir.
        catch { mesaj('Tahsilat kaydedildi ancak satırlara dağıtılamadı - '
                    + 'Tahsilat ekranından dağıtımı kontrol edin.') }
      }
      tazele();
      onKaydedildi?.();
    } catch (h) { setHata(hataMetni(h)); mesaj(hataMetni(h)) }
  };

  /** Gridde tutar hucresi degistirildi: kasa islemini gunceller. */
  const tutarGuncelle = async (id: number, tutar: number) => {
    if (!(tutar > 0)) { setHata('Tahsilat tutarı sıfırdan büyük olmalı.'); return }
    setHata(null);
    try {
      const mevcut = await api.kasaOku(id);
      await api.kasaGuncelle(id, {
        surum: String(mevcut.islem.surum ?? ''),
        islem: { tutar },
      });
      tazele();
      onKaydedildi?.();
    } catch (h) { setHata(hataMetni(h)) }
  };

  // Bu belgeye bagli kasa islemleri (kasa_islem.belge_id). Iptal edilenler
  //   (durum 3) haric - odenmis gibi gorunmesinler.
  // SEKMEDEN BAGIMSIZ yuklenir (kullanici): hasta seridindeki "Açık Borç"
  //   ucretlendirme - tahsilat farkidir, tahsilat sekmesi acilmadan da dogru
  //   gorunmeli. Istek kucuk (tek belgenin kasa islemleri).
  useEffect(() => {
    if (!kayitliId) { setTahsilatlar([]); return }
    void (async () => {
      try {
        const y = await api.liste('kasa-islem', {
          sayfa: 1, boyut: 50,
          // Iptal edilen islem (durum 3) ve onun TERS kaydi listeye girmez -
          //   ikisi de iptalIslemId tasir, toplami sisirmesinler.
          filtre: { op: 'and', kosullar: [
            { alan: 'belgeId', op: 'esit', deger: kayitliId },
            { alan: 'durum', op: 'esitDegil', deger: 3 },
            // Kolon NULL olabiliyor - '= 0' eslesmiyordu, 'bos' dogru kosul.
            { alan: 'iptalIslemId', op: 'bos' },
          ] },
        });
        setTahsilatlar(y.satirlar);
      } catch { setTahsilatlar([]) }
    })();
  }, [kayitliId, aktifSekme, tahsilatYenile]);

  /**
   * Secili kasa islemini siler. GERCEKLESMIS islem silinemez - sunucu
   * "İptal kullanın" der ve mesaj oldugu gibi gosterilir; kart burada
   * ikinci bir kural uydurmaz.
   */
  const tahsilatSil = async (idler: number[]) => {
    if (!idler.length) return;
    if (!await onay(idler.length === 1
        ? 'Seçili tahsilat/ödeme silinecek. Onaylıyor musunuz?'
        : `Seçili ${idler.length} tahsilat/ödeme silinecek. Onaylıyor musunuz?`, true)) return;
    setHata(null);
    // Biri silinemezse (muhasebe fisi disa aktarilmis, belge donusmus...)
    //   sunucunun sebebi gosterilir ama digerlerinin silinmesi surer (354).
    const hatalar: string[] = [];
    for (const id of idler) {
      try { await api.kasaSil(id) } catch (h) { hatalar.push(hataMetni(h)) }
    }
    setSeciliTahsilatlar([]);
    tazele();
    onKaydedildi?.();
    if (hatalar.length) setHata([...new Set(hatalar)].join(' | '));
  };

  /**
   * Tahsilat aracina gore ikinci adim. CEK/SENET once JENERIK KIYMET KARTINI
   * acar (kasa listesindeki akisin aynisi): banka, sube, kesideci, seri no,
   * vade... kasa kartinda sorulamayacak kadar cok alan var. Diger araclar
   * (nakit/banka/POS) dogrudan kasa kartini acar.
   */
  const tahsilatAdimi = (tahsilatTuru: number, id: number) => {
    if (CEK_SENET_TURLERI.includes(tahsilatTuru)) {
      setCekTuru({ tur: tahsilatTuru, belgeId: id });
      return;
    }
    setTahsilatAcik(tahsilatTuru);
  };

  /**
   * Kiymet karti kaydedildi: kasa islemini ayni kiymete BAGLAYARAK ac. Kart
   * sunucudan yeniden okunur - tutar/cari kullanicinin kartta biraktigi son
   * hali olsun.
   */
  const cekKartKaydedildi = async (tur: number, belge: number, csId: number) => {
    setCekTuru(null);
    try {
      const k = await api.kartOku('cek-senet', csId);
      const kart = k.kart as Record<string, unknown>;
      setTahsilatAcilis({
        tur,
        tarafId: Number(kart.tarafId) || cari?.id,
        tarafUnvan: cari?.unvan ?? '',
        belgeId: belge,
        tutar: String(kart.tutar ?? ''),
        cekSenetId: csId,
      });
    } catch {
      // Kiymet kaydedildi ama okunamadi: kullaniciyi bos kartla bas basa
      //   birakmak yerine tahsilat listesini tazele - kagit portfoyde duruyor.
      tazele();
    }
  };

  const tahsilEdilen = tahsilToplami(tahsilatlar);

  return {
    /** Islemin baglanacagi belge - modallar bunu onyukler. */
    belgeId: kayitliId,
    tahsilatlar,
    tahsilEdilen,
    tahsilatAcik, setTahsilatAcik,
    cekTuru, setCekTuru,
    tahsilatAcilis, setTahsilatAcilis,
    seciliTahsilatlar, setSeciliTahsilatlar,
    onPencereKapandi,
    tahsilatKayitId, setTahsilatKayitId,
    tazele, tahsilatSil, tahsilatAdimi, cekKartKaydedildi,
    hizliTahsilat, tutarGuncelle,
  };
}

/**
 * Belgeye baglanmis tahsilatlarin toplami. Yerel tutar varsa o kullanilir
 * (doviz belgede kasa islemi yerel karsiligiyla kapatir).
 */
export function tahsilToplami(satirlar: ListeSatiri[]): number {
  return (satirlar ?? []).reduce(
    (t, x) => t + (Number(x.yerelTutar ?? x.tutar ?? 0) || 0), 0);
}

/**
 * Yeni tahsilat acilirken tutar alanina yazilacak deger: KALAN (kullanici).
 * Once genel toplam onyukleniyordu; ikinci tahsilatta kullanici tutari elle
 * duzeltmek zorunda kaliyor, unutursa belge iki kez tahsil edilmis oluyordu.
 *
 * - Fazla tahsilatta negatife dusmez (0 doner).
 * - Belge toplami yoksa bos birakilir - yanlis sifir yazmaktansa bos.
 */
export function kalanTahsilat(genelToplam: unknown, satirlar: ListeSatiri[]): number {
  const toplam = Number(genelToplam ?? 0) || 0;
  if (!toplam) return 0;
  return Math.max(0, toplam - tahsilToplami(satirlar));
}
