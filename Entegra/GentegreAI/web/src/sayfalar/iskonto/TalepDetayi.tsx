import type { IskontoTalebi } from '../../api/sozlesme';
import { para, tarihSaat } from '../../bilesenler/bicim';
import { DURUM_ROZET, dakikaFarki, indirim, sure } from './ortak';

/**
 * TALEP DETAYI — kalem kırılımı, gerekçe ve KARAR paneli.
 *
 * Karar burada verilir, zilde değil: zil satırı "kim, ne kadar" der ama hangi
 * hizmetler, hangi hasta, hangi oran görülmeden onay bir imza atmaktır.
 *
 * Bileşen KARAR VERMEZ - düğmeler sayfaya haber eder; istek, yenileme ve hata
 * yönetimi tek yerde (sayfa) kalsın.
 */
export function TalepDetayi({ talep, tavan, kararOran, setKararOran,
                              kararNot, setKararNot, calisiyor, onKarar, onBasvuru }: {
  talep: IskontoTalebi;
  /** Kullanıcının iskonto tavanı (`basvuru.iskonto`). */
  tavan: number;
  kararOran: string; setKararOran(v: string): void;
  kararNot: string; setKararNot(v: string): void;
  calisiyor: boolean;
  onKarar(tur: 'onay' | 'kismi' | 'ret'): void;
  onBasvuru(belgeId: number): void;
}) {
  const yeterli = tavan >= talep.oran;
  return (
    <>
      <div className="isk-detay-serit">
        <span className="kutu">👤 <b>{talep.hasta || '—'}</b></span>
        <span className="kutu">
          🧾 <b>{talep.belgeNo}</b>
          {talep.kurum ? ` · ${talep.kurum}` : ''}
          {talep.doktor ? ` · ${talep.doktor}` : ''}
        </span>
        <span className="kutu">🏷 Talep <b>#{talep.id}</b> · {tarihSaat(talep.istekTs)}</span>
        <span className="kutu">👩 İsteyen: <b>{talep.isteyen}</b></span>
        {talep.durum === 0 && (
          <span className="rozet hata">
            Bekliyor · {sure(dakikaFarki(talep.istekTs))}
          </span>
        )}
      </div>

      <div className="isk-detay">
        <div>
          <div className="kagrup">
            <h6>Kalem Bazında İskonto
              <span className="sonuk">indirim hizmet satırına yazılır</span></h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th>Hizmet</th>
                  <th className="hiza-sag" style={{ width: 110 }}>Tutar</th>
                  <th className="hiza-sag" style={{ width: 90 }}>İstenen</th>
                  <th className="hiza-sag" style={{ width: 110 }}>İnd. tutar</th>
                  <th className="hiza-sag" style={{ width: 110 }}>Net</th>
                </tr>
              </thead>
              <tbody>
                {talep.kalemler.map((k, i) => {
                  const ind = k.tutar * k.oran / 100;
                  return (
                    <tr key={i}>
                      <td>{k.ad}</td>
                      <td className="hiza-sag">{para.format(k.tutar)}</td>
                      <td className="hiza-sag">%{k.oran}</td>
                      <td className="hiza-sag">{para.format(ind)}</td>
                      <td className="hiza-sag"><b>{para.format(k.tutar - ind)}</b></td>
                    </tr>
                  );
                })}
                <tr className="genel">
                  <td>TOPLAM</td>
                  <td className="hiza-sag">{para.format(talep.tutar)}</td>
                  <td className="hiza-sag">%{talep.oran}</td>
                  <td className="hiza-sag">{para.format(indirim(talep))}</td>
                  <td className="hiza-sag">{para.format(talep.tutar - indirim(talep))}</td>
                </tr>
              </tbody>
            </table>
            <div className="pano-not">
              Oranlar <b>kalem kalem</b> saklanır — tümüne aynı oranı uygulamak
              zorunlu değildir. Kısmi onayda hepsi <b>aynı oranda</b> düşer,
              böylece görevlinin kurduğu denge korunur.
            </div>
          </div>

          <div className="kagrup">
            <h6>Talep Gerekçesi <span className="sonuk">banko beyanı</span></h6>
            <div className="isk-gerekce">“{talep.gerekce || '—'}”</div>
          </div>
        </div>

        {/* ---------------------------------------------- karar paneli */}
        <div className="isk-karar">
          <div className="kagrup">
            <h6>Yetki Durumu</h6>
            <div className="isk-sat"><span>İsteyen</span><b>{talep.isteyen}</b></div>
            <div className="isk-sat teh">
              <span>Talep</span>
              <b>%{talep.oran} · {para.format(indirim(talep))}</b>
            </div>
            <div className="isk-sat"><span>Sizin limitiniz</span><b>%{tavan}</b></div>
            <div className={`isk-sat ${yeterli ? 'ok' : 'teh'}`}>
              <span>Karar</span>
              <b>{yeterli ? 'Yetkiniz yeterli' : 'Yetkiniz yetmiyor — üst role gider'}</b>
            </div>
          </div>

          <div className="kagrup">
            <h6>Karar <span className="sonuk">ret gerekçesi zorunlu</span></h6>
            {talep.durum !== 0 ? (
              <div className="isk-gerekce">
                <b>{DURUM_ROZET[talep.durum]?.ad}</b>
                {talep.durum === 1 && ` · %${talep.onaylananOran} uygulandı`}
                {' · '}{talep.onaylayan || '—'}
                {talep.kararNotu && <div className="sonuk">“{talep.kararNotu}”</div>}
              </div>
            ) : (
              <div className="alan-izgara">
                <label className="alan">
                  <span>Onaylanan oran (%)</span>
                  <input className="hiza-sag" value={kararOran}
                         onChange={e => setKararOran(e.target.value)} />
                </label>
                <label className="alan gen">
                  <span>Karar notu</span>
                  <textarea rows={3} value={kararNot}
                            onChange={e => setKararNot(e.target.value)} />
                </label>
              </div>
            )}

            {talep.durum === 0 && (
              <>
                <div className="isk-karar-dugmeler">
                  <button type="button" className="d ok"
                          disabled={calisiyor || !yeterli}
                          title={yeterli ? 'İstenen oranı aynen onaylar'
                                         : `Yetkiniz %${tavan}`}
                          onClick={() => onKarar('onay')}>
                    ✔ Onayla (%{talep.oran})
                  </button>
                  <button type="button" className="d bir" disabled={calisiyor}
                          title="Talebi düşürerek onaylar"
                          onClick={() => onKarar('kismi')}>
                    ✂ Kısmi Onayla
                  </button>
                  <button type="button" className="d teh" disabled={calisiyor}
                          onClick={() => onKarar('ret')}>✖ Reddet</button>
                </div>
                <div className="pano-not">
                  Kısmi onay talebi <b>düşürerek</b> onaylar: banko %{talep.oran}
                  {' '}istedi, siz daha azını verirsiniz. Reddetmekle aynı şey
                  değildir — hasta yine indirim alır.
                </div>
              </>
            )}
            <div className="isk-karar-dugmeler">
              <button type="button" className="d"
                      onClick={() => onBasvuru(talep.belgeId)}>
                📝 Başvuruyu Aç
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
