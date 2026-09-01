import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * RADYOLOJİ PANOSU (320) — mockup Ekranlar/radyoloji_panosu.html.
 *
 * "Bugün ne durumdayız" ekranı. Her sayaç TIKLANIR ve ilgili listeyi kendi
 * süzgeciyle açar: pano bakılacak bir yer değil, işe giriş kapısıdır.
 *
 * Sayılar tek uçtan gelir (/api/radyoloji/pano) - altı ayrı istek atmak hem
 * yavaş hem de ekranın yarısının dolu yarısının boş görünmesi demekti.
 */

interface Sayaclar {
  randevu: number; cekimBekleyen: number; raporlanacak: number;
  acikKritik: number; teslimBekleyen: number; tamamlanan: number;
  konsultasyon: number; randevusuz: number;
}
interface Cihaz {
  id: number; ad: string; modaliteAdi: string; randevuVerilir: number;
  mesai: string; mesaiDk: number; kapaliDk: number; doluDk: number; bugunIs: number;
}
interface ModaliteSatiri {
  modalite: number; modaliteAdi: string; toplam: number; bugun: number;
  raporsuz: number; ortRaporDk: number;
}
interface RadyologSatiri {
  radyolog: string; acik: number; onaylanan: number; ortDk: number;
}
interface Uyari { tip: string; ik: string; metin: string; yol: string }

interface PanoYaniti {
  tarih: string; sayaclar: Sayaclar; cihazlar: Cihaz[];
  modalite: ModaliteSatiri[]; radyologlar: RadyologSatiri[]; uyarilar: Uyari[];
}

/** 195 -> "3 sa 15 dk", 42 -> "42 dk". Rapor süreleri saatlerce sürebilir. */
const sure = (dakika: number) => {
  const d = Math.max(0, Math.round(dakika));
  if (d === 0) return '—';
  if (d < 60) return `${d} dk`;
  const sa = Math.floor(d / 60);
  return d % 60 === 0 ? `${sa} sa` : `${sa} sa ${d % 60} dk`;
};

const bugunIso = () => {
  const t = new Date();
  return new Date(t.getTime() - t.getTimezoneOffset() * 60000).toISOString().slice(0, 10);
};

export function RadyolojiPanosu() {
  const git = useNavigate();
  const [gun, setGun] = useState(bugunIso);
  const [veri, setVeri] = useState<PanoYaniti | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try { setVeri(await api.radyolojiPano(gun)) }
    catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [gun]);

  useEffect(() => { void yukle() }, [yukle]);

  const s = veri?.sayaclar;
  const kutular: { anahtar: string; ik: string; deger: number; etiket: string;
                   yol: string; vurgu?: 'teh' | 'uy' | 'ok' }[] = [
    { anahtar: 'randevu',  ik: '📅', deger: s?.randevu ?? 0,
      etiket: 'Bugünkü randevu',  yol: '/randevu' },
    { anahtar: 'cekim',    ik: '🕐', deger: s?.cekimBekleyen ?? 0,
      etiket: 'Çekim bekleyen',   yol: '/radyoloji' },
    { anahtar: 'rapor',    ik: '✎',  deger: s?.raporlanacak ?? 0,
      etiket: 'Raporlanacak',     yol: '/radyoloji', vurgu: 'uy' },
    { anahtar: 'kritik',   ik: '🚨', deger: s?.acikKritik ?? 0,
      etiket: 'Açık kritik bulgu', yol: '/radyoloji-kritik',
      vurgu: (s?.acikKritik ?? 0) > 0 ? 'teh' : undefined },
    { anahtar: 'teslim',   ik: '📦', deger: s?.teslimBekleyen ?? 0,
      etiket: 'Teslim bekleyen',  yol: '/radyoloji-teslim' },
    { anahtar: 'tamam',    ik: '✔',  deger: s?.tamamlanan ?? 0,
      etiket: 'Bugün onaylanan',  yol: '/radyoloji', vurgu: 'ok' },
  ];

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Radyoloji Panosu</h1>
          <span className="yol">Radyoloji › Pano</span>
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
                    onClick={() => git(k.yol)} title="Listeyi aç">
              <span className="ik">{k.ik}</span>
              <span className="s">{k.deger}</span>
              <span className="e">{k.etiket}</span>
            </button>
          ))}
        </div>

        <div className="pano-satir">
          {/* ------------------------------------------------ cihaz doluluk */}
          <div className="kagrup">
            <h6>Cihaz Doluluğu <span className="sonuk">mesai saatleri üzerinden</span></h6>
            <div className="pano-ic">
              {(veri?.cihazlar ?? []).map(c => {
                // Payda: mesai eksi kapatma. Walk-in cihazda mesai hesabi
                //   anlamsiz - oran yerine yapilan is sayisi gosterilir.
                const payda = Math.max(0, c.mesaiDk - c.kapaliDk);
                const oran = c.randevuVerilir === 1 && payda > 0
                  ? Math.min(100, Math.round((c.doluDk * 100) / payda)) : null;
                const kapaliOran = c.mesaiDk > 0
                  ? Math.min(100, Math.round((c.kapaliDk * 100) / c.mesaiDk)) : 0;
                return (
                  <div key={c.id} className="pano-cihaz">
                    <div className="ad">
                      {c.ad}
                      <span className="sonuk">
                        {c.modaliteAdi}{c.mesai ? ` · ${c.mesai}` : ''}
                        {c.randevuVerilir === 1 ? '' : ' · randevusuz (walk-in)'}
                      </span>
                    </div>
                    <div className="cubuk" title={`Dolu ${sure(c.doluDk)} / uygun ${sure(payda)}`}>
                      <i className="dolu" style={{ width: `${oran ?? 0}%` }} />
                      {kapaliOran > 0 && <i className="kap" style={{ width: `${kapaliOran}%` }} />}
                    </div>
                    <div className="oran">
                      {oran === null ? `${c.bugunIs} iş` : `%${oran}`}
                    </div>
                  </div>
                );
              })}
              {(veri?.cihazlar ?? []).length === 0 && (
                <div className="bos">Tanımlı cihaz yok.</div>
              )}
              <div className="pano-not">
                Taralı bölüm <b>bakım/tatil kapatması</b>; o aralık randevuya kapalıdır
                ve doluluk paydasından düşülür.
              </div>
            </div>
          </div>

          {/* ------------------------------------------- dikkat gerektiren */}
          <div className="kagrup">
            <h6>Dikkat Gerektirenler</h6>
            <div className="pano-ic">
              {(veri?.uyarilar ?? []).map((u, i) => (
                <button key={i} type="button" className={`pano-uyari ${u.tip}`}
                        onClick={() => git(u.yol)} title="İlgili listeyi aç">
                  <span>{u.ik}</span><span>{u.metin}</span>
                </button>
              ))}
              {(veri?.uyarilar ?? []).length === 0 && !yukleniyor && (
                <div className="bos">Bekleyen bir şey yok — her şey yolunda.</div>
              )}
            </div>
          </div>
        </div>

        <div className="pano-satir">
          {/* ---------------------------------------------- modalite dagilim */}
          <div className="kagrup">
            <h6>Modalite Dağılımı <span className="sonuk">son 30 gün</span></h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th>Modalite</th><th>Dağılım</th>
                  <th className="hiza-sag">Bugün</th><th className="hiza-sag">30 gün</th>
                  <th className="hiza-sag">Raporsuz</th><th className="hiza-sag">Ort. rapor</th>
                </tr>
              </thead>
              <tbody>
                {(veri?.modalite ?? []).map(m => {
                  const enBuyuk = Math.max(1, ...(veri?.modalite ?? []).map(x => x.toplam));
                  return (
                    <tr key={m.modalite}>
                      <td><span className="rozet mor">{m.modaliteAdi || m.modalite}</span></td>
                      <td>
                        <span className="pano-mini"
                              style={{ width: `${Math.round((m.toplam * 100) / enBuyuk)}%` }} />
                      </td>
                      <td className="hiza-sag">{m.bugun}</td>
                      <td className="hiza-sag">{m.toplam}</td>
                      <td className="hiza-sag">{m.raporsuz}</td>
                      <td className="hiza-sag">{sure(m.ortRaporDk)}</td>
                    </tr>
                  );
                })}
                {(veri?.modalite ?? []).length === 0 && (
                  <tr><td className="bos" colSpan={6}>Son 30 günde çekim yok.</td></tr>
                )}
              </tbody>
            </table>
          </div>

          {/* ------------------------------------------------ radyolog yuku */}
          <div className="kagrup">
            <h6>Radyolog Yükü <span className="sonuk">açık rapor / bugün onaylanan</span></h6>
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th>Radyolog</th><th className="hiza-sag">Açık</th>
                  <th className="hiza-sag">Onaylanan</th><th className="hiza-sag">Ort. onay</th>
                </tr>
              </thead>
              <tbody>
                {(veri?.radyologlar ?? []).map(r => (
                  <tr key={r.radyolog}>
                    <td>{r.radyolog}</td>
                    <td className="hiza-sag">{r.acik}</td>
                    <td className="hiza-sag">{r.onaylanan}</td>
                    <td className="hiza-sag">{sure(r.ortDk)}</td>
                  </tr>
                ))}
                {(veri?.radyologlar ?? []).length === 0 && (
                  <tr><td className="bos" colSpan={4}>Açık ya da bugün onaylanmış rapor yok.</td></tr>
                )}
              </tbody>
            </table>
            <div className="pano-not">
              Asistan raporları onaya düşer: <b>Onaylanan</b> sütunu uzman onayını sayar.
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
