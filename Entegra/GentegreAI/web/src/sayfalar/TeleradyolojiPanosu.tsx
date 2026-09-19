import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { c } from '../dil/ceviri';

/**
 * TELERADYOLOJİ PANOSU (801) — mockup
 * `Ekranlar/Teleradyoloji/telerad_pano.html`.
 *
 * Modülün "bugün ne durumdayız" ekranı. Radyoloji panosuyla AYNI bileşenler
 * (`pano-kutu`, `kagrup`, `detay-tablo`) - iki pano aynı aileden gelsin;
 * ekrana özel CSS yazmak tasarım dilini bölerdi.
 *
 * <b>Her sayaç tıklanır</b> ve çalışma listesini kendi çipiyle açar: pano
 * bakılacak bir yer değil, işe giriş kapısıdır.
 *
 * <b>Sayılar sunucudan, tek uçtan</b> (`/api/telerad/pano`). Kalan dakika ve
 * SLA riski `v_telerad_istek` içinde hesaplanıyor; pano da onu okur - liste
 * ile pano aynı işe iki farklı sayı vermesin.
 *
 * <b>Olmayan panel gösterilmez:</b> mockup'taki nöbet/vardiya, hakediş ve
 * dönem faturası kutuları burada YOK - o işler yapılmadı, uydurma sayı
 * panoyu güvenilmez kılar.
 */

interface Sayaclar {
  bekleyen: number; bekleyenAcil: number; slaKacan: number; okunuyor: number;
  bugunGelen: number; bugunOnaylanan: number; teslimBekleyen: number;
  ekGoruntu: number; goruntuBekleyen: number;
}
interface AyOzeti {
  istek: number; onaylanan: number; sozluOnaylanan: number; slaUyan: number;
  ortRaporDk: number; ortAcilDk: number; ortOkumaDk: number; ucretToplam: number;
}
interface KurumSatiri {
  kurumId: number; kurumAdi: string; istek: number; bekleyen: number;
  sozlu: number; slaUyan: number; ortRaporDk: number; ucret: number;
}
interface ModaliteSatiri {
  modalite: number; modaliteAdi: string; adet: number; ortRaporDk: number;
}
interface RadyologSatiri {
  radyologId: number; radyologAdi: string; bende: number;
  bugunOnaylanan: number; slaKacan: number; ortRaporDk: number;
}
interface SaatSatiri { saat: number; gelen: number; onaylanan: number }

interface PanoYaniti {
  tarih: string; sayaclar: Sayaclar; ay: AyOzeti; kurumlar: KurumSatiri[];
  modalite: ModaliteSatiri[]; radyologlar: RadyologSatiri[]; saatler: SaatSatiri[];
}

/** 195 -> "3 sa 15 dk". Rutin tetkikin SLA'sı gün ölçeğinde olabilir. */
const sure = (dakika: number) => {
  const d = Math.max(0, Math.round(dakika));
  if (d === 0) return '—';
  if (d < 60) return `${d} dk`;
  const sa = Math.floor(d / 60);
  return d % 60 === 0 ? `${sa} sa` : `${sa} sa ${d % 60} dk`;
};

const para = (t: number) =>
  t.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/** Yüzde: payda 0 iken "%0" yazmak yanıltıcı - sözü olan iş yoksa "—". */
const yuzde = (pay: number, payda: number) =>
  payda > 0 ? `%${Math.round((pay * 100) / payda)}` : '—';

const bugunIso = () => {
  const t = new Date();
  return new Date(t.getTime() - t.getTimezoneOffset() * 60000).toISOString().slice(0, 10);
};

export function TeleradyolojiPanosu() {
  const git = useNavigate();
  const [gun, setGun] = useState(bugunIso);
  const [veri, setVeri] = useState<PanoYaniti | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try { setVeri(await api.teleradPano<PanoYaniti>(gun)) }
    catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [gun]);

  useEffect(() => { void yukle() }, [yukle]);

  const s = veri?.sayaclar;
  const ay = veri?.ay;

  // ÇİP ADI ÇALIŞMA LİSTESİNDEKİYLE AYNI: sayaçtan listeye geçen kullanıcı
  //   aynı süzgeci görsün (listeTanimlari.Teleradyoloji).
  const kutular: { anahtar: string; ik: string; deger: number; etiket: string;
                   cip?: string; vurgu?: 'teh' | 'uy' | 'ok' }[] = [
    { anahtar: 'bekleyen', ik: '🕐', deger: s?.bekleyen ?? 0,
      etiket: 'Bekleyen iş', cip: 'Bekleyen', vurgu: 'uy' },
    { anahtar: 'sla', ik: '⏰', deger: s?.slaKacan ?? 0,
      etiket: 'SLA kaçan', cip: 'Bekleyen',
      vurgu: (s?.slaKacan ?? 0) > 0 ? 'teh' : undefined },
    { anahtar: 'okunuyor', ik: '👁', deger: s?.okunuyor ?? 0,
      etiket: 'Okunuyor', cip: 'Okunuyor' },
    { anahtar: 'goruntu', ik: '🖼', deger: s?.goruntuBekleyen ?? 0,
      etiket: 'Görüntü bekleyen', cip: 'Bekleyen' },
    { anahtar: 'teslim', ik: '📦', deger: s?.teslimBekleyen ?? 0,
      etiket: 'Teslim bekleyen', cip: 'Onaylı' },
    { anahtar: 'onaylanan', ik: '✔', deger: s?.bugunOnaylanan ?? 0,
      etiket: 'Bugün onaylanan', cip: 'Onaylı', vurgu: 'ok' },
  ];

  const enBuyukSaat = Math.max(1, ...(veri?.saatler ?? []).map(x => Math.max(x.gelen, x.onaylanan)));

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Teleradyoloji Panosu</h1>
          <span className="yol">{c('Radyoloji › Teleradyoloji › Pano')}</span>
        </div>
        <div className="basarac">
          <input type="date" value={gun} onChange={e => setGun(e.target.value)} />
          <button className="d" onClick={() => setGun(bugunIso())}>Bugün</button>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
          {yukleniyor && <span className="sonuk">Yükleniyor…</span>}
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="pano-sayaclar">
          {kutular.map(k => (
            <button key={k.anahtar} type="button"
                    className={`pano-kutu${k.vurgu ? ` ${k.vurgu}` : ''}`}
                    onClick={() => git(`/teleradyoloji${k.cip ? `?cip=${encodeURIComponent(k.cip)}` : ''}`)}
                    title={c('Çalışma listesini aç')}>
              <span className="ik">{k.ik}</span>
              <span className="s">{k.deger}</span>
              <span className="e">
                {k.etiket}
                {k.anahtar === 'bekleyen' && (s?.bekleyenAcil ?? 0) > 0 && (
                  <span className="sonuk"> · {s?.bekleyenAcil} acil</span>
                )}
                {k.anahtar === 'bekleyen' && (s?.ekGoruntu ?? 0) > 0 && (
                  <span className="sonuk"> · {s?.ekGoruntu} ek görüntü</span>
                )}
              </span>
            </button>
          ))}
        </div>

        <div className="pano-satir">
          {/* ------------------------------------------------- ay özeti ---- */}
          <div className="kagrup">
            <h6>{c('Son 30 Gün')}<span className="sonuk">{c('SLA ve süreler')}</span></h6>
            <table className="detay-tablo">
              <tbody>
                <tr>
                  <td>{c('SLA uyumu')}</td>
                  <td className="hiza-sag">
                    <b>{yuzde(ay?.slaUyan ?? 0, ay?.sozluOnaylanan ?? 0)}</b>
                    <span className="sonuk"> · {ay?.slaUyan ?? 0}/{ay?.sozluOnaylanan ?? 0}</span>
                  </td>
                </tr>
                <tr><td>{c('Ortalama rapor süresi')}</td>
                    <td className="hiza-sag">{sure(ay?.ortRaporDk ?? 0)}</td></tr>
                <tr><td>{c('Ortalama')}<b>acil</b> rapor süresi</td>
                    <td className="hiza-sag">{sure(ay?.ortAcilDk ?? 0)}</td></tr>
                <tr><td>{c('Ortalama okuma süresi')}</td>
                    <td className="hiza-sag">{sure(ay?.ortOkumaDk ?? 0)}</td></tr>
                <tr><td>{c('İstek / onaylanan')}</td>
                    <td className="hiza-sag">{ay?.istek ?? 0} / {ay?.onaylanan ?? 0}</td></tr>
                <tr><td>{c('Tetkik ücreti toplamı')}</td>
                    <td className="hiza-sag">{para(Number(ay?.ucretToplam ?? 0))} ₺</td></tr>
              </tbody>
            </table>
            <div className="pano-not">{c('SLA uyumu')}<b>sözü olan</b> işler üzerinden: sözleşmesi olmayan isteğe
              (SLA 0) "uyduk" demek uydurma olurdu. Rapor süresi <b>görüntünün
              geldiği andan</b> onaya, okuma süresi okumaya başlandığı andan.
              Ücret toplamı dönem faturası değildir.
            </div>
          </div>

          {/* --------------------------------------------- saatlik yığılma -- */}
          <div className="kagrup">
            <h6>{c('Saatlik Geliş / Onay')}<span className="sonuk">{veri?.tarih}</span></h6>
            <div className="pano-ic">
              <div className="telerad-saat">
                {(veri?.saatler ?? []).map(x => (
                  <div key={x.saat} className="sut" title={`${x.saat}:00 · gelen ${x.gelen} · onaylanan ${x.onaylanan}`}>
                    <i className="gel" style={{ height: `${(x.gelen * 100) / enBuyukSaat}%` }} />
                    <i className="ona" style={{ height: `${(x.onaylanan * 100) / enBuyukSaat}%` }} />
                    <span className="sa">{x.saat % 6 === 0 ? x.saat : ''}</span>
                  </div>
                ))}
              </div>
              <div className="pano-not">
                Açık sütun <b>gelen görüntü</b>, koyu sütun <b>onaylanan rapor</b>.
                Yığılma saatini görmek, nöbet ve otomatik dağıtım kuralının ilk girdisidir.
              </div>
            </div>
          </div>
        </div>

        <div className="pano-satir">
          {/* --------------------------------------------- kurum kırılımı -- */}
          <div className="kagrup">
            <h6>{c('Kuruma Göre')}<span className="sonuk">son 30 gün</span></h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th>Kurum</th><th className="hiza-sag">İstek</th>
                  <th className="hiza-sag">Bekleyen</th><th className="hiza-sag">SLA</th>
                  <th className="hiza-sag">{c('Ort. rapor')}</th><th className="hiza-sag">Ücret</th>
                </tr>
              </thead>
              <tbody>
                {(veri?.kurumlar ?? []).map(k => (
                  <tr key={k.kurumId}>
                    <td>{k.kurumAdi}</td>
                    <td className="hiza-sag">{k.istek}</td>
                    <td className="hiza-sag">{k.bekleyen || '—'}</td>
                    <td className="hiza-sag">{yuzde(k.slaUyan, k.sozlu)}</td>
                    <td className="hiza-sag">{sure(k.ortRaporDk)}</td>
                    <td className="hiza-sag">{para(Number(k.ucret))}</td>
                  </tr>
                ))}
                {(veri?.kurumlar ?? []).length === 0 && !yukleniyor && (
                  <tr><td className="bos" colSpan={6}>{c('Son 30 günde istek yok.')}</td></tr>
                )}
              </tbody>
            </table>
          </div>

          {/* -------------------------------------------- modalite dağılımı */}
          <div className="kagrup">
            <h6>{c('Modalite Dağılımı')}<span className="sonuk">son 30 gün</span></h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th>Modalite</th><th>{c('Dağılım')}</th>
                  <th className="hiza-sag">Adet</th><th className="hiza-sag">{c('Ort. rapor')}</th>
                </tr>
              </thead>
              <tbody>
                {(veri?.modalite ?? []).map(m => {
                  const enBuyuk = Math.max(1, ...(veri?.modalite ?? []).map(x => x.adet));
                  return (
                    <tr key={m.modalite}>
                      <td><span className="rozet gri">{m.modaliteAdi}</span></td>
                      <td>
                        <span className="pano-mini"
                              style={{ width: `${Math.round((m.adet * 100) / enBuyuk)}%` }} />
                      </td>
                      <td className="hiza-sag">{m.adet}</td>
                      <td className="hiza-sag">{sure(m.ortRaporDk)}</td>
                    </tr>
                  );
                })}
                {(veri?.modalite ?? []).length === 0 && !yukleniyor && (
                  <tr><td className="bos" colSpan={4}>{c('Son 30 günde istek yok.')}</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        <div className="pano-satir">
          {/* ---------------------------------------------- radyolog yükü -- */}
          <div className="kagrup">
            <h6>{c('Radyolog Yükü')}<span className="sonuk">bende / bugün onaylanan</span></h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th>Radyolog</th><th className="hiza-sag">{c('Bende')}</th>
                  <th className="hiza-sag">{c('Bugün onaylanan')}</th>
                  <th className="hiza-sag">{c('SLA kaçan')}</th><th className="hiza-sag">{c('Ort. rapor')}</th>
                </tr>
              </thead>
              <tbody>
                {(veri?.radyologlar ?? []).map(r => (
                  <tr key={r.radyologId}>
                    <td>{r.radyologAdi}</td>
                    <td className="hiza-sag">{r.bende || '—'}</td>
                    <td className="hiza-sag">{r.bugunOnaylanan || '—'}</td>
                    <td className="hiza-sag">
                      {r.slaKacan > 0 ? <span className="rozet hata">{r.slaKacan}</span> : '—'}
                    </td>
                    <td className="hiza-sag">{sure(r.ortRaporDk)}</td>
                  </tr>
                ))}
                {(veri?.radyologlar ?? []).length === 0 && !yukleniyor && (
                  <tr><td className="bos" colSpan={5}>{c('Atanmış iş yok.')}</td></tr>
                )}
              </tbody>
            </table>
            <div className="pano-not">
              <b>{c('Vardiya')}</b> ve <b>hakediş</b> sütunları yok: nöbet çizelgesi ve Prim bağı
              henüz yazılmadı. Uydurma sayı göstermek yerine sütun hiç açılmadı.
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
