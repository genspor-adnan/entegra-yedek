import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
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

export function useBelgeTahsilat({ kayitliId, aktifSekme, cari, onKaydedildi, setHata }: {
  kayitliId: number;
  aktifSekme: string;
  cari: { id: number; unvan: string } | null;
  onKaydedildi?(): void;
  setHata(mesaj: string | null): void;
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
  /** Tahsilat listesinde secili kasa islemi (duzelt/sil dugmeleri bunu kullanir). */
  const [seciliTahsilat, setSeciliTahsilat] = useState<number | null>(null);
  /** DUZELTME icin acilan MEVCUT kasa islemi - yeni tahsilattan ayri state:
      biri tur ile acar, oteki kayit kimligiyle. */
  const [tahsilatKayitId, setTahsilatKayitId] = useState<number | null>(null);

  const tazele = () => setTahsilatYenile(t => t + 1);

  // Bu belgeye bagli kasa islemleri (kasa_islem.belge_id). Iptal edilenler
  //   (durum 3) haric - odenmis gibi gorunmesinler.
  useEffect(() => {
    if (!kayitliId || aktifSekme !== 'tahsilat') return;
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
  const tahsilatSil = async (id: number) => {
    if (!window.confirm('Seçili tahsilat/ödeme silinecek. Onaylıyor musunuz?')) return;
    setHata(null);
    try {
      await api.kasaSil(id);
      setSeciliTahsilat(null);
      tazele();
      onKaydedildi?.();
    } catch (h) {
      setHata(hataMetni(h));
    }
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
    seciliTahsilat, setSeciliTahsilat,
    tahsilatKayitId, setTahsilatKayitId,
    tazele, tahsilatSil, tahsilatAdimi, cekKartKaydedildi,
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
