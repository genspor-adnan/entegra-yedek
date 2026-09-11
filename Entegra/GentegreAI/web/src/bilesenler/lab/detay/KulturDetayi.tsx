import { tarihSaat } from '../../bicim';
import {
  sayi, sirSinifi, } from '../../labKodlari';
import { dizi, metin, kodEki } from './ortak';

/** Panelde cizilen sunucu kaydi - alanlar kaynaga gore degisir. */
type Kayit = Record<string, unknown>;

const ID_YONTEM: Record<number, string> = {
  1: 'MALDI-TOF', 2: 'VITEK', 3: 'Manuel', 4: 'Moleküler', 9: 'Diğer',
};

/** Enfeksiyon kontrolüne bildirilen direnç işaretleri (436). */
const DIRENC: { alan: string; ad: string }[] = [
  { alan: 'mrsa', ad: 'MRSA' }, { alan: 'vre', ad: 'VRE' },
  { alan: 'esbl', ad: 'ESBL' }, { alan: 'karbapenemaz', ad: 'Karbapenemaz' },
  { alan: 'ampc', ad: 'AmpC' },
];

export function KulturDetayi({ veri }: { veri: Kayit }) {
  const k = (veri.kultur ?? {}) as Kayit;
  const besiyeriler = dizi(veri.besiyeriler);
  const okumalar = dizi(veri.okumalar);
  const izolatlar = dizi(veri.izolatlar);
  const antibiyogram = dizi(veri.antibiyogram);

  return (
    <div className="lab-ikili">
      <div className="kagrup">
        <h6>
          💊 Antibiyogram
          <span className="sp">
            {metin(antibiyogram[0]?.standart) || 'EUCAST'}
            {metin(antibiyogram[0]?.standartSurum)
              ? ` ${metin(antibiyogram[0]?.standartSurum)}` : ''} · MIC
          </span>
        </h6>
        <div className="detay-kaydir">
          <table className="detay-tablo">
            <thead>
              <tr>
                <th>Antibiyotik</th><th className="sag">MIC (µg/mL)</th>
                <th className="orta">Zon</th><th className="orta">Yorum</th>
                <th className="orta">Kaynak</th><th className="orta">Raporlanır</th>
              </tr>
            </thead>
            <tbody>
              {antibiyogram.map(a => (
                <tr key={String(a.id)}>
                  <td>
                    {metin(a.ad)}
                    {kodEki(a.ad, a.kod) &&
                      <span className="not"> {kodEki(a.ad, a.kod)}</span>}
                  </td>
                  <td className="sag">
                    {metin(a.micIsaret)}{a.mic === null || a.mic === undefined
                      ? (metin(a.micIsaret) ? '' : '—') : ` ${sayi(a.mic, 3)}`}
                  </td>
                  <td className="orta">{a.zonMm ? `${String(a.zonMm)} mm` : '—'}</td>
                  <td className="orta">
                    <span className={sirSinifi(a.yorum)}>{metin(a.yorum) || '—'}</span>
                  </td>
                  <td className="orta not">
                    {Number(a.kaynak ?? 1) === 2 ? 'disk (manuel)'
                      : Number(a.kaynak ?? 1) === 3 ? 'uzman' : 'cihaz'}
                  </td>
                  {/* KADEMELİ BİLDİRİM: raporda görünmeyen ajan burada da
                      işaretli - "niye yazmıyor" sorusu ekranda cevaplanır. */}
                  <td className="orta">
                    {a.bildir ? <span className="rozet olumlu">Evet</span>
                              : <span className="rozet gri">Kademeli</span>}
                  </td>
                </tr>
              ))}
              {antibiyogram.length === 0 && (
                <tr><td colSpan={6} className="not">Antibiyogram girilmedi.</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {metin(k.uzmanYorum) && <div className="ic sonuk">{metin(k.uzmanYorum)}</div>}
      </div>

      <div>
        <div className="kagrup">
          <h6>
            🧫 Okumalar
            <span className="sp">
              {besiyeriler.map(b => metin(b.ad)).join(' · ') || 'besiyeri yok'}
            </span>
          </h6>
          <table className="detay-tablo">
            <thead>
              <tr>
                <th className="orta">Saat</th><th className="orta">Zaman</th>
                <th className="orta">Üreme</th><th>Bulgu</th><th>Sonraki adım</th>
              </tr>
            </thead>
            <tbody>
              {okumalar.map(o => (
                <tr key={String(o.id)}>
                  <td className="orta">{String(o.saat ?? '')} s</td>
                  <td className="orta not">
                    {o.zaman ? tarihSaat(o.zaman) : '—'}
                  </td>
                  <td className="orta">
                    {o.uremeVar ? <span className="rozet uyari">var</span>
                                : <span className="rozet gri">yok</span>}
                  </td>
                  <td>{metin(o.bulgu) || '—'}</td>
                  <td className="not">{metin(o.sonrakiAdim) || '—'}</td>
                </tr>
              ))}
              {okumalar.length === 0 && (
                <tr><td colSpan={5} className="not">Okuma kaydı yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>

        <div className="kagrup">
          <h6>🔬 İzolatlar</h6>
          <table className="detay-tablo">
            <thead>
              <tr>
                <th className="orta">No</th><th>Organizma</th>
                <th className="sag">Koloni</th><th className="orta">Yöntem</th>
              </tr>
            </thead>
            <tbody>
              {izolatlar.map(i => (
                <tr key={String(i.id)}>
                  <td className="orta">{String(i.izolatNo ?? '')}</td>
                  <td>
                    <b><i>{metin(i.organizma)}</i></b>
                    {kodEki(i.organizma, i.organizmaKod) &&
                      <span className="not"> {kodEki(i.organizma, i.organizmaKod)}</span>}
                    {/* DİRENÇ İŞARETLERİ enfeksiyon kontrolünün konusudur:
                        MRSA/VRE/ESBL/karbapenemaz gizlenirse bildirim
                        yapılmaz. */}
                    {DIRENC.filter(d => Number(i[d.alan] ?? 0) === 1).map(d => (
                      <span className="rozet hata" key={d.alan}
                            style={{ marginLeft: 4 }}>{d.ad}</span>
                    ))}
                  </td>
                  <td className="sag">
                    {i.koloniSayisi ? `${sayi(i.koloniSayisi, 0)} ${metin(i.koloniBirim)}`
                                    : '—'}
                    {i.anlamli === false && <span className="not"> · anlamsız</span>}
                  </td>
                  <td className="orta not">
                    {ID_YONTEM[Number(i.idYontem ?? 0)] ?? '—'}
                    {i.idGuven ? ` ${sayi(i.idGuven, 1)}` : ''}
                  </td>
                </tr>
              ))}
              {izolatlar.length === 0 && (
                <tr><td colSpan={4} className="not">Üreme yok / izolat kaydedilmedi.</td></tr>
              )}
            </tbody>
          </table>
        </div>

        {metin(k.onRapor) && (
          <div className="kagrup">
            <h6>📄 Ön rapor</h6>
            <div className="ic">{metin(k.onRapor)}</div>
          </div>
        )}
      </div>
    </div>
  );
}

/* --------------------------------------------------------------- genetik --
   Mockup lab_genetik.html: varyant tablosu + vaka/kalite bilgisi.        */
/** `lab_varyant.kalitim` / `lab_gen.kalitim` (439). */
