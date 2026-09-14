import { para } from '../../bilesenler/bicim';
import type { GerekceSatiri, IsteyenSatiri } from './ortak';

/** Red oranı bu eşiği aşan isteyen için uyarı çıkar. */
const RED_ESIGI = 25;

/**
 * GEÇMİŞ & ANALİZ — indirimi değil, indirimin SEBEBİNİ izler.
 *
 * "Şikâyet telafisi" kaleminin büyümesi bir indirim sorunu değil HİZMET
 * sorunudur; yüksek red oranı ise limitin gerçeğe uymadığını gösterir (her
 * gün aşılan bir limit yanlış konmuştur). Bu iki tablo o iki soruyu sorar.
 */
export function GecmisAnaliz({ gerekceler, isteyenler, gun }: {
  gerekceler: GerekceSatiri[];
  isteyenler: IsteyenSatiri[];
  /** Analiz aralığı (gün) - başlıkta yazar. */
  gun: number;
}) {
  return (
    <>
      <div className="kagrup">
        <h6>Gerekçeye Göre İskonto
          <span className="sonuk">{gun === 1 ? 'bugün' : `son ${gun} gün`}</span></h6>
        <table className="detay-tablo">
          <thead>
            <tr>
              <th>Gerekçe</th>
              <th className="hiza-sag" style={{ width: 90 }}>Adet</th>
              <th className="hiza-sag" style={{ width: 130 }}>Verilen tutar</th>
              <th className="hiza-sag" style={{ width: 100 }}>Ort. oran</th>
              <th className="hiza-sag" style={{ width: 100 }}>Red oranı</th>
            </tr>
          </thead>
          <tbody>
            {gerekceler.map(g => (
              <tr key={g.ad}>
                <td>{g.ad}</td>
                <td className="hiza-sag">{g.adet}</td>
                <td className="hiza-sag">{para.format(g.tutar)}</td>
                <td className="hiza-sag">%{g.ortOran.toFixed(1)}</td>
                <td className="hiza-sag">
                  %{g.adet > 0 ? (g.red / g.adet * 100).toFixed(0) : 0}
                </td>
              </tr>
            ))}
            {gerekceler.length === 0 && (
              <tr><td colSpan={5} className="bos">Bu aralıkta karar yok.</td></tr>
            )}
          </tbody>
        </table>
        <div className="pano-not">
          Analiz indirimi değil, indirimin <b>sebebini</b> izler: “şikâyet
          telafisi” kaleminin büyümesi bir indirim sorunu değil hizmet sorunudur.
        </div>
      </div>

      <div className="kagrup">
        <h6>İsteyene Göre
          <span className="sonuk">kimin talebi ne kadar onaylanıyor</span></h6>
        <table className="detay-tablo">
          <thead>
            <tr>
              <th>İsteyen</th>
              <th className="hiza-sag" style={{ width: 90 }}>Talep</th>
              <th className="hiza-sag" style={{ width: 90 }}>Onay</th>
              <th className="hiza-sag" style={{ width: 90 }}>Kısmi</th>
              <th className="hiza-sag" style={{ width: 90 }}>Red</th>
              <th className="hiza-sag" style={{ width: 130 }}>Verilen tutar</th>
              <th style={{ width: 240 }}>Değerlendirme</th>
            </tr>
          </thead>
          <tbody>
            {isteyenler.map(i => {
              const redOran = i.talep > 0 ? i.red / i.talep * 100 : 0;
              return (
                <tr key={i.ad}>
                  <td>{i.ad}</td>
                  <td className="hiza-sag">{i.talep}</td>
                  <td className="hiza-sag">{i.onay}</td>
                  <td className="hiza-sag">{i.kismi}</td>
                  <td className="hiza-sag">{i.red}</td>
                  <td className="hiza-sag">{para.format(i.tutar)}</td>
                  <td>
                    {redOran >= RED_ESIGI
                      ? <span className="rozet hata">
                          Red oranı %{redOran.toFixed(0)} — limit/eğitim gözden geçirilmeli
                        </span>
                      : <span className="rozet ok">Olağan</span>}
                  </td>
                </tr>
              );
            })}
            {isteyenler.length === 0 && (
              <tr><td colSpan={7} className="bos">Bu aralıkta talep yok.</td></tr>
            )}
          </tbody>
        </table>
        <div className="pano-not">
          Yüksek red oranı iki şeyin belirtisidir: ya limit gerçeğe uymuyor
          (her gün aşılıyorsa limit yanlıştır), ya da talep disiplini zayıf.
        </div>
      </div>
    </>
  );
}
