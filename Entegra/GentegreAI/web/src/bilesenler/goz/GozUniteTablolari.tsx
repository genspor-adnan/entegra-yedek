import type { GozUniteOzeti } from '../../api/uclar/goz';
import { c } from '../../dil/ceviri';
import { GOZ_ISTASYON, GOZ_PANO_ESIK } from './gozPanoSabitleri';

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

const ISTASYON = GOZ_ISTASYON;
const {
  siraUyari: SIRA_UYARI, beklemeKritikDk: BEKLEME_KRITIK, gecikmeUyariDk: GECIKME_UYARI,
} = GOZ_PANO_ESIK;

export function GozUniteTablolari({ veri }: { veri: GozUniteOzeti | null }) {
  if (!veri) return null;
  // İkisi de boşsa şerit hiç çizilmez: boş iki tablo, ekranda yer kaplayan
  //   ama hiçbir şey söylemeyen bir kutu olurdu.
  if (veri.odalar.length === 0 && veri.hekimler.length === 0) return null;

  return (
    <div className="unite-tablolar">
      <div className="kagrup">
        <h6>{c('Oda ve cihaz doluluğu')}<span>darboğaz burada görünür</span></h6>
        <table className="izlem-tablo">
          <thead>
            <tr><th>Kaynak</th><th>{c('Kim')}</th><th>İş</th>
                <th className="sag">Süre</th><th className="sag">Sıra</th></tr>
          </thead>
          <tbody>
            {veri.odalar.length === 0 && (
              <tr><td colSpan={5} className="sonuk">
                {c('Oda / cihaz tanımlanmamış - Göz › Oda / Cihaz Tanımı.')}
              </td></tr>
            )}
            {veri.odalar.map(o => (
              <tr key={`${o.kaynakId ?? 'x'}-${o.oda}`} className={o.bos ? 'sonuk' : undefined}>
                <td>
                  <b>{o.oda}</b>
                  {/* TÜR VE SAHİP ADIN ALTINDA: "Oda 1 · Dr. Aksoy" mockup'ta
                      tek satır - kaynağın kime ait olduğu, sıranın kimde
                      tıkandığını okumanın yarısı. */}
                  {(o.turAdi || o.sahip) && (
                    <span className="sonuk"> {[o.turAdi, o.sahip].filter(Boolean).join(' · ')}</span>
                  )}
                  {/* TANIMSIZ KAYNAK İŞARETLENİR: doluluk yazım hatasıyla
                      ikiye bölünmesin diye tanıma davet eder (976). */}
                  {!o.tanimli && <span className="rozet gri"> {c('tanımsız')}</span>}
                </td>
                {/* BOŞ KAYNAK DA SATIR: mockup'ın söylediği cümle "HFA sırası
                    dört kişiyken muayene odası boş duruyor" - atıl kaynak
                    görünmezse pano bu cümleyi kuramaz. */}
                <td>{o.bos ? <span className="sonuk">{c('boş')}</span> : (o.hasta || '—')}</td>
                <td className="sonuk">{o.bos ? '—' : (ISTASYON[o.istasyon] ?? '—')}</td>
                <td className="sag">{o.bos ? '—' : `${o.sureDk} dk`}</td>
                <td className="sag">
                  {/* SIRA UZUNSA ROZET: sayının kendisi "4" ile "1" arasındaki
                      farkı yeterince anlatmıyor. */}
                  {o.sayi > SIRA_UYARI
                    ? <span className="rozet hata">{o.sayi}</span>
                    : o.enUzunDk >= BEKLEME_KRITIK
                      ? <span className="rozet sari">{o.sayi}</span>
                      : o.sayi || '—'}
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
        <h6>{c('Hekim ve tekniker yükü')}<span>bugün</span></h6>
        <table className="izlem-tablo">
          <thead>
            <tr><th>Kişi</th><th className="sag">Tamam</th><th className="sag">Bekleyen</th>
                <th className="sag">{c('Ort. süre')}</th><th className="sag">{c('En uzun')}</th>
                <th className="sag">{c('Gecikme')}</th></tr>
          </thead>
          <tbody>
            {veri.hekimler.length === 0 && (
              <tr><td colSpan={6} className="sonuk">
                Bugün istasyonlara personel atanmamış.
              </td></tr>
            )}
            {veri.hekimler.map(h => (
              <tr key={h.personelId}>
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
                {/* GECİKME RANDEVUYA GÖRE (976): randevusuz hastada ÖLÇÜLEMEZ
                    ve "—" yazar - sıfır yazmak "zamanında" demek olurdu ve
                    randevusuz çalışan bir ünite kendini hep zamanında sanırdı. */}
                <td className="sag" title={h.randevulu
                      ? `${h.randevulu} ${c('randevulu hastadan')}`
                      : c('randevulu hasta yok - gecikme ölçülemez')}>
                  {h.gecikmeDk === null ? <span className="sonuk">—</span>
                    : h.gecikmeDk >= GECIKME_UYARI
                      ? <span className="rozet sari">+{h.gecikmeDk} dk</span>
                      : h.gecikmeDk > 0 ? `+${h.gecikmeDk} dk`
                        : <span className="rozet ok">{c('zamanında')}</span>}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
        <div className="not">
          <b>{c('Tekniker de bu tabloda:')}</b> ön tetkik ünitenin girişidir ve tıkanırsa hekim
          odası boş kalır. Yalnız hekim sayılsaydı panonun söylediği "hekimler yavaş"
          olurdu — oysa sıra girişte.
        </div>
      </div>
    </div>
  );
}
