import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { onay } from '../../bilesenler/mesaj';
import { hataMetni, type BelgeYaniti } from '../../api/sozlesme';

/**
 * BELGE DONUSUMLERI (F8 zinciri) - Faturalama sekmesinin tum durumu.
 *
 * `BelgeKarti` govdesinde yedi ayri durum + iki yardimci olarak duruyordu.
 * Tek yerde toplandiginda "bu belgeden ne turedi" sorusunun cevabi da,
 * turetilmis belgeyi acma/silme de ayni dosyada.
 */
export interface DonusumBaglami {
  /** Kayitli belgenin id'si (0 = henuz kaydedilmedi). */
  kayitliId: number;
  /** Acik sekme - liste yalniz "fatura" sekmesinde cekilir. */
  aktifSekme: string;
  setHata(v: string | null): void;
  setSonuc(v: BelgeYaniti): void;
}

export function useBelgeDonusumleri({ kayitliId, aktifSekme, setHata, setSonuc }: DonusumBaglami) {
  /** Donusum MODALI: acilacak hedef belge turu (null = kapali). */
  const [hedefTur, setHedefTur] = useState<number | null>(null);
  /**
   * KURUM TAHAKKUKU (331): donusum modali PAY secili acilir (2 = kurum payi).
   */
  const [pay, setPay] = useState(0);
  const [liste, setListe] = useState<Record<string, unknown>[]>([]);
  /** Hizli donusum olcusu (kullanici): 'adet' kalan miktar · 'tutar' tahsil edilen. */
  const [olcu, setOlcu] = useState<'adet' | 'tutar'>('adet');
  /**
   * Turetilmis belgenin kartini acar - USTTE IKINCI KART olarak.
   *
   * Once turun liste rotasina (`/satis-fisi/114347`) gidiliyordu; o rotalar
   * KAYITLI DEGIL (belge listelerinde `kartYolu` yok, App yalniz `/<rota>`
   * uretiyor) - tiklayinca hicbir sey acilmiyordu. Kart zaten `id` + `onKapat`
   * ile tek basina calisiyor: fis/tahakkuk basvurunun USTUNDE acilir, kapaninca
   * donusum listesi tazelenir.
   */
  const [acilan, setAcilan] = useState<number | null>(null);

  // Faturalama sekmesi: bu belgeden turetilmis belgeler (F8 zinciri).
  const yukle = useCallback(async (id?: number) => {
    // Id DISARIDAN verilebilir: yeni kaydedilen belgede `kayitliId` state'i
    //   henuz guncellenmemis olur (setAcilanId asenkron) - hizli donusum
    //   listesi bos kalmasin.
    const hedef = id ?? kayitliId;
    if (!hedef) { setListe([]); return }
    try { setListe(await api.belgeDonusumler(hedef)) } catch { setListe([]) }
  }, [kayitliId]);

  useEffect(() => {
    // TAHSILAT SEKMESI DE OKUR (kullanici): kurum tahakkuku tahsilat listesinin
    //   ilk satiri olarak gosteriliyor - liste yalniz "fatura" sekmesinde
    //   cekilirse orada bos kaliyordu.
    if (!kayitliId || (aktifSekme !== 'fatura' && aktifSekme !== 'tahsilat')) return;
    void yukle();
  }, [kayitliId, aktifSekme, yukle]);

  const ac = (id: number) => setAcilan(id);

  /**
   * Secili turetilmis belgeleri siler. Kaynak satirin kapatilan/kalan sayaci
   * DB tarafinda silme tetigiyle geri doner - bu yuzden belge de tazelenir.
   * Silinemeyen belgede (kasa islemi bagli, e-Belge gonderilmis...) sunucunun
   * sebebi gosterilir ve digerlerinin silinmesi surer.
   */
  const sil = async (idler: number[]) => {
    if (!idler.length) return;
    if (!await onay(idler.length === 1
        ? 'Seçili belge silinecek. Onaylıyor musunuz?'
        : `Seçili ${idler.length} belge silinecek. Onaylıyor musunuz?`, true)) return;
    setHata(null);
    const hatalar: string[] = [];
    for (const id of idler) {
      try { await api.belgeSil(id) } catch (h) { hatalar.push(hataMetni(h)) }
    }
    await yukle();
    if (kayitliId) { try { setSonuc(await api.belgeOku(kayitliId)) } catch { /* yoksay */ } }
    if (hatalar.length) setHata(hatalar.join(' | '));
  };

  return { hedefTur, setHedefTur, pay, setPay, liste, yukle,
           olcu, setOlcu, acilan, setAcilan, ac, sil };
}

export type BelgeDonusumleri = ReturnType<typeof useBelgeDonusumleri>;
