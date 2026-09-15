import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { GozUniteOzeti as Ozet } from '../../api/uclar/goz';

/**
 * GÖZ ÜNİTE PANOSU SAYAÇLARI — mockup
 * `Ekranlar/Goz/goz_unite_panosu.html` üst şeridi.
 *
 * <b>Panonun ilk bakışta söylediği şey "ünite tıkalı mı".</b> Kanban "kim
 * nerede"yi gösteriyor; kutular ünitenin o anki hâlini tek satırda veriyor —
 * ikisini ayırmanın sebebi, sütunları sayarak yığılmayı anlamanın zaman
 * almasıdır.
 *
 * <b>Sayılar SUNUCUDAN gelir</b> (`/api/goz/unite-ozet`). Kanbanın elindeki
 * satırlardan hesaplanamazlar: kanban yalnız AÇIK istasyonları görüyor,
 * "bugün kaç hasta geldi / kaçı tamamlandı / ortalama ziyaret" ise kapanmış
 * satırlardan çıkıyor. İstemcide sayılsaydı pano hep eksik bir gün gösterirdi.
 *
 * <b>Darboğaz kutusu tahmin değil ölçüm:</b> en uzun bekleyen istasyonun ADI
 * yazılır. "Ünite yoğun" kimseye iş yaptırmaz; "görüntülemede 4 kişi, en uzunu
 * 31 dk" ikinci cihazı ya da randevu aralığını gündeme getirir.
 */

const ISTASYON: Record<number, string> = {
  1: 'Kabul', 2: 'Ön tetkik', 3: 'Muayene',
  4: 'Görüntüleme', 5: 'Karar / işlem', 6: 'Tamamlandı',
};

/** Bekleme hedefi (dk): üstü sarı. Kurum ayarı olana kadar tek yerde. */
const BEKLEME_HEDEF = 15;
/** Bu süreyi geçen bekleme kırmızı: hasta "unutuldum" demeden önceki eşik. */
const BEKLEME_KRITIK = 30;

export function GozUniteOzeti({ yenile }: { yenile?: number }) {
  const [veri, setVeri] = useState<Ozet | null>(null);

  const yukle = useCallback(async () => {
    // Şerit zorunlu değil: hatası kanbanı ve listeyi düşürmemeli.
    try { setVeri(await api.gozUniteOzeti()) } catch { /* sessiz */ }
  }, []);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (!veri) return null;
  const g = veri.gunOzet;
  const a = veri.acik;
  const d = veri.darbogaz;

  return (
    <div className="unite-ozet">
      <div className="k">
        <span>BUGÜN ZİYARET</span>
        <b>{g?.ziyaret ?? 0}</b>
        <i>{g?.tamamlanan ?? 0} tamamlandı</i>
      </div>

      <div className="k">
        <span>ÜNİTEDE</span>
        <b>{g?.unitede ?? 0}</b>
        {/* İstasyon kırılımı kutunun altında: "22 hasta" tek başına nerede
            olduklarını söylemiyor. */}
        <i>{veri.istasyonlar.length > 0
          ? veri.istasyonlar.map(i => `${i.sayi} ${(ISTASYON[i.istasyon] ?? '').toLowerCase()}`)
              .join(' · ')
          : 'açık istasyon yok'}</i>
      </div>

      <div className={`k${(a?.ortBeklemeDk ?? 0) > BEKLEME_HEDEF ? ' uy' : ''}`}>
        <span>ORT. BEKLEME</span>
        <b>{a?.ortBeklemeDk ?? 0} dk</b>
        <i>hedef ≤ {BEKLEME_HEDEF} dk</i>
      </div>

      <div className={`k${(a?.enUzunDk ?? 0) >= BEKLEME_KRITIK ? ' teh' : ''}`}>
        <span>EN UZUN BEKLEME</span>
        <b>{a?.enUzunDk ?? 0} dk</b>
        {/* Sayının yanında ADI: "31 dk" tek başına kimseyi harekete geçirmiyor. */}
        <i>{veri.enUzun
          ? `${veri.enUzun.hasta} · ${(ISTASYON[veri.enUzun.istasyon] ?? '').toLowerCase()}`
          : 'bekleyen yok'}</i>
      </div>

      <div className="k">
        <span>DİLATASYONDA</span>
        <b>{a?.dilatasyonda ?? 0}</b>
        {/* HAZIR / BEKLEYEN AYRIMI: damlası tamamlanan hasta çağrılabilir,
            öteki çağrılırsa geri gönderilir ve hekimin sırası bozulur. */}
        <i>{a?.dilatasyonHazir ?? 0} hazır ·{' '}
          {Math.max((a?.dilatasyonda ?? 0) - (a?.dilatasyonHazir ?? 0), 0)} bekliyor</i>
      </div>

      <div className={`k${d && d.enUzunDk >= BEKLEME_KRITIK ? ' teh'
                          : d && d.enUzunDk > BEKLEME_HEDEF ? ' uy' : ''}`}>
        <span>DARBOĞAZ</span>
        <b>{d ? (ISTASYON[d.istasyon] ?? '—') : '—'}</b>
        <i>{d ? `${d.sayi} kişi · en uzun ${d.enUzunDk} dk` : 'yığılma yok'}</i>
      </div>

      <div className="k iyi">
        <span>ORT. ZİYARET</span>
        <b>{g?.ortZiyaretDk ?? 0} dk</b>
        {/* Yalnız TAMAMLANAN ziyaretlerden: hâlâ ünitede olanı ortalamaya
            katmak, günün ortasında süreyi olduğundan kısa gösterirdi. */}
        <i>kabul → çıkış</i>
      </div>
    </div>
  );
}
