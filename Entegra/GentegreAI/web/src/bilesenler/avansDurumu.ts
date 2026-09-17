import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * HASTANIN AÇIK AVANSI (322/779/781) — tek okuyucu.
 *
 * Tahsilat sekmesinde avans ÜÇ yerde konuşuyor: uyarı şeridi ("bu carinin
 * dağıtılmamış tahsilatı var"), "⋯" menüsündeki **Avans Kullan** ve onun
 * etkinliği. Üçü ayrı ayrı sorsaydı aynı ekranda üç istek olur ve mahsuptan
 * sonra biri tazelenip öteki bayat kalırdı — memur "kullandım ama hâlâ
 * yazıyor" derdi. Durum burada tek yerde tutulur.
 *
 * `dagitilmamis` tahsilat = avans: hasta parayı önce yatırmış, ücret satırı
 * sonra girilmiştir. 780'den beri görünüm İADE edilmiş tutarı da düşer, yani
 * buradaki toplam gerçekten "mahsup edilebilir para"dır.
 */
/** Hastanin ACIK avans islemi - iade menusu bunlari sirayla listeler. */
export interface AcikAvans {
  kasaIslemId: number;
  islemTarihi: string;
  /** Mahsup/iade edilebilir kalan. */
  kalan: number;
}

export function useAvansDurumu(tarafId?: number | null) {
  const [toplam, setToplam] = useState(0);
  const [satirlar, setSatirlar] = useState<AcikAvans[]>([]);
  const [adet, setAdet] = useState(0);
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState('');

  const tazele = useCallback(async () => {
    if (!tarafId) { setToplam(0); setAdet(0); return }
    try {
      const y = await api.kasaAvans(tarafId);
      const satir = (y.satirlar ?? []).map(k => ({
        kasaIslemId: Number(k.kasaIslemId ?? 0),
        islemTarihi: String(k.islemTarihi ?? ''),
        kalan: Number(k.dagitilmamis ?? 0),
      })).filter(k => k.kasaIslemId > 0 && k.kalan > 0);
      setToplam(Number(y.toplam ?? 0));
      setSatirlar(satir);
      setAdet(satir.length);
      setHata('');
    } catch (h) {
      // Yetkisi olmayan kullanıcıda şerit ÇİZİLMEZ, ekran çalışmaya devam
      //   eder: avans bilgisi tahsilatın önkoşulu değil.
      setToplam(0); setSatirlar([]); setAdet(0); setHata(hataMetni(h));
    }
  }, [tarafId]);

  useEffect(() => { void tazele() }, [tazele]);

  /**
   * Açık avansı BU BELGENİN satırlarına dağıtır. Mahsup sunucuda yapılır
   * (`/api/kasa-islem/avans-mahsup`): hangi kovaya ne kadar gideceğini satır
   * bazlı kalanlar belirler, istemci tutar bölüştürmez.
   */
  const mahsupEt = useCallback(async (belgeId: number, tutar?: number) => {
    setHata(''); setCalisiyor(true);
    try {
      // `tutar` verilmezse avansin TAMAMI dagitilir (belgenin acik satirlari
      //   kadar); verilirse o kadari - kismi kullanim (783).
      const y = await api.kasaAvansMahsup({ belgeId, ...(tutar ? { tutar } : {}) });
      await tazele();
      return y;
    } catch (h) {
      setHata(hataMetni(h));
      return null;
    } finally { setCalisiyor(false) }
  }, [tazele]);

  return { toplam, satirlar, adet, calisiyor, hata, tazele, mahsupEt };
}

/** Kancanin donusu - serit ve tahsilat cubugu ayni nesneyi paylasir. */
export type AvansDurumu = ReturnType<typeof useAvansDurumu>;
