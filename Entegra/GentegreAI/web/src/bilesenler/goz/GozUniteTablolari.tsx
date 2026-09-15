import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { GozUniteOzeti } from '../../api/uclar/goz';

/**
 * ODA / CİHAZ DOLULUĞU ve HEKİM YÜKÜ — mockup
 * `Ekranlar/Goz/goz_unite_panosu.html` alt iki tablosu.
 *
 * <b>Pano HASTAYI değil KAYNAĞI sayar.</b> Bekleme çoğu zaman hekimden değil
 * tek cihazdan doğuyor: "bugün neden geç kaldık" sorusunun cevabı, HFA sırası
 * dört kişiyken boş duran muayene odasıdır. Hasta bazlı bakan pano bunu
 * gizler.
 *
 * <b>Tekniker hekim tablosunda.</b> Ön tetkik ünitenin girişidir; tıkanırsa
 * hekim odası boş kalır. Yalnız hekim sayan pano "hekimler yavaş" der, oysa
 * sıra girişte.
 *
 * Sayılar ünite özetiyle AYNI istekten gelir (`/api/goz/unite-ozet`): ikinci
 * bir uç, aynı ekranda iki farklı "4 kişi" üretmenin en kısa yoluydu.
 */

const ISTASYON: Record<number, string> = {
  1: 'Kabul', 2: 'Ön tetkik', 3: 'Muayene',
  4: 'Görüntüleme', 5: 'Karar / işlem', 6: 'Tamamlandı',
};

/** Sıra bu sayıyı geçince kaynak "tıkalı" sayılır (mockup: HFA 4 kişi). */
const SIRA_UYARI = 3;
/** Bu dakikayı geçen bekleme kırmızı. */
const BEKLEME_KRITIK = 30;

export function GozUniteTablolari({ yenile }: { yenile?: number }) {
  const [veri, setVeri] = useState<GozUniteOzeti | null>(null);

  const yukle = useCallback(async () => {
    try { setVeri(await api.gozUniteOzeti()) } catch { /* sessiz */ }
  }, []);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (!veri) return null;
  // İkisi de boşsa şerit hiç çizilmez: boş iki tablo, ekranda yer kaplayan
  //   ama hiçbir şey söylemeyen bir kutu olurdu.
  if (veri.odalar.length === 0 && veri.hekimler.length === 0) return null;

  return (
    <div className="unite-tablolar">
      <div className="kagrup">
        <h6>Oda ve cihaz doluluğu <span>darboğaz burada görünür</span></h6>
        <table className="izlem-tablo">
          <thead>
            <tr><th>Kaynak</th><th>Kim</th><th>İş</th>
                <th className="sag">Süre</th><th className="sag">Sıra</th></tr>
          </thead>
          <tbody>
            {veri.odalar.length === 0 && (
              <tr><td colSpan={5} className="sonuk">Oda/cihaz ataması yapılmamış.</td></tr>
            )}
            {veri.odalar.map(o => (
              <tr key={o.oda}>
                <td><b>{o.oda}</b></td>
                <td>{o.hasta || '—'}</td>
                <td className="sonuk">{ISTASYON[o.istasyon] ?? '—'}</td>
                <td className="sag">{o.sureDk} dk</td>
                <td className="sag">
                  {/* SIRA UZUNSA ROZET: sayının kendisi "4" ile "1" arasındaki
                      farkı yeterince anlatmıyor. */}
                  {o.sayi > SIRA_UYARI
                    ? <span className="rozet hata">{o.sayi}</span>
                    : o.enUzunDk >= BEKLEME_KRITIK
                      ? <span className="rozet sari">{o.sayi}</span>
                      : o.sayi}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="not">
          Pano <b>kaynağı</b> gösteriyor, hastayı değil: bekleme çoğu zaman hekimden
          değil <b>tek cihazdan</b> doğuyor. Sıra dört kişiyken muayene odasının boş
          durduğu ancak burada görünür.
        </div>
      </div>

      <div className="kagrup">
        <h6>Hekim ve tekniker yükü <span>bugün</span></h6>
        <table className="izlem-tablo">
          <thead>
            <tr><th>Kişi</th><th className="sag">Tamam</th><th className="sag">Bekleyen</th>
                <th className="sag">Ort. süre</th><th className="sag">En uzun</th></tr>
          </thead>
          <tbody>
            {veri.hekimler.length === 0 && (
              <tr><td colSpan={5} className="sonuk">
                Bugün istasyonlara personel atanmamış.
              </td></tr>
            )}
            {veri.hekimler.map(h => (
              <tr key={h.personel}>
                <td>{h.personel}</td>
                <td className="sag">{h.tamamlanan}</td>
                <td className="sag">
                  {h.bekleyen > SIRA_UYARI
                    ? <span className="rozet sari">{h.bekleyen}</span>
                    : h.bekleyen}
                </td>
                <td className="sag">{h.ortDk ? `${h.ortDk} dk` : '—'}</td>
                <td className="sag">
                  {h.enUzunDk >= BEKLEME_KRITIK
                    ? <span className="rozet hata">{h.enUzunDk} dk</span>
                    : h.enUzunDk ? `${h.enUzunDk} dk` : '—'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="not">
          <b>Tekniker de bu tabloda:</b> ön tetkik ünitenin girişidir ve tıkanırsa hekim
          odası boş kalır. Yalnız hekim sayılsaydı panonun söylediği "hekimler yavaş"
          olurdu — oysa sıra girişte.
        </div>
      </div>
    </div>
  );
}
