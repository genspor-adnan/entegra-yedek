import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { SahaPerformansi } from '../../api/uclar/disHekim';
import { paraYaz } from '../../bilesenler/bicim';
import { stil as hastaIcmalStili } from '../hasta/icmal/icmalStil';
import { stil as kurumIcmalStili } from '../kurum/icmal/kurumIcmalStil';
import { ayAraligi, degisimRozeti } from './performansOrtak';

/**
 * SAHA PERFORMANSI `/saha-performans` (1292, mockup Ekranlar/Radyoloji/temsilci_ziyaret.html §6; kullanıcı 10.11.2026:
 * "yönetimin de temsilcilerin ve doktorların performansını görmeleri gerekiyor"). Dönem × şube; sekmeler Temsilciler ·
 * Doktorlar · Şubeler · Talepler. Rakamlar SUNUCUDAN (SahaPerformansUclari): gönderim = radyoloji istemi, temsilci =
 * başvurunun satici_id'si, prim = hakediş satırları (rol 1 / 10). Yalnız okur.
 */
type Sekme = 'temsilci' | 'doktor' | 'sube' | 'talep';
type DoktorSuzgec = 'tum' | 'yukselen' | 'dusen' | 'sessiz' | 'yeni' | 'ziyaretsiz';

const tarihYaz = (d: string | null | undefined) => d ? new Date(d).toLocaleDateString('tr-TR') : '—';
const yuzdeYaz = (d: number | null | undefined) => d == null ? '—' : `%${d}`;

export function SahaPerformans() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const buAy = (() => { const d = new Date(); return ayAraligi(d.getFullYear(), d.getMonth() + 1) })();
  const bas = arama.get('bas') ?? buAy.bas;
  const bit = arama.get('bit') ?? buAy.bit;
  const sube = Number(arama.get('sube') ?? 0);
  const [veri, setVeri] = useState<SahaPerformansi | null>(null);
  const [hata, setHata] = useState('');
  const [sekme, setSekme] = useState<Sekme>('temsilci');
  const [suzgec, setSuzgec] = useState<DoktorSuzgec>('tum');
  const [ara, setAra] = useState('');

  const degistir = useCallback((d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, v] of Object.entries(d)) { if (v && v !== '0') yeni.set(k, v); else yeni.delete(k) }
    setArama(yeni, { replace: true });
  }, [arama, setArama]);

  useEffect(() => {
    setHata('');
    api.sahaPerformans(bas, bit, sube).then(setVeri).catch(h => setHata(hataMetni(h)));
  }, [bas, bit, sube]);

  const ayKaydir = (n: number) => {
    const d = new Date(`${bas}T00:00:00`);
    const y = new Date(d.getFullYear(), d.getMonth() + n, 1);
    const a = ayAraligi(y.getFullYear(), y.getMonth() + 1);
    degistir({ bas: a.bas, bit: a.bit });
  };
  const kutu = (baslik: string, deg: string, alt: string, sinif = '') => (
    <div className={'hi-kutu ' + sinif}><div className="bas">{baslik}</div><div className="deg">{deg}</div><div className="alt">{alt}</div></div>
  );
  const rozet = (d: number | null | undefined) => { const r = degisimRozeti(d); return <span className={`ki-rozet ${r.renk}`}>{r.ad}</span> };

  const o = veri?.ozet;
  const doktorlar = (veri?.doktorlar ?? []).filter(d =>
    (suzgec === 'tum' || (suzgec === 'yukselen' && d.degisim >= 5) || (suzgec === 'dusen' && d.dusen)
      || (suzgec === 'sessiz' && d.sessiz) || (suzgec === 'yeni' && d.yeni) || (suzgec === 'ziyaretsiz' && d.ziyaretEdilmeyen))
    && (!ara || `${d.ad} ${d.kurum} ${d.temsilciler}`.toLocaleLowerCase('tr-TR').includes(ara.toLocaleLowerCase('tr-TR'))));
  const sekmeler: [Sekme, string, number][] = veri ? [
    ['temsilci', 'Temsilciler', veri.temsilciler.length], ['doktor', 'Doktorlar', veri.doktorlar.length],
    ['sube', 'Şubeler', veri.subeler.length], ['talep', 'Talepler', veri.talepler.length]] : [];

  return (
    <div className="hi">
      <style>{hastaIcmalStili + kurumIcmalStili + SAHA_STILI}</style>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Saha Performansı</h1>
          <span className="yol">Kurumlar & Sigorta › Saha Performansı</span>
        </div>
      </div>
      <div className="hi-arac">
        <span className="ki-soluk">Gönderim = radyoloji istemi · temsilci = başvurunun temsilcisi · prim = hakediş (gönderen / temsilci)</span>
        <span className="sp" />
        <button onClick={() => git('/dis-hekim-plan')}>🗓 Ziyaret Planı</button>
        <button onClick={() => git('/dis-hekim-vade')}>⏰ Ziyaret Vadesi</button>
        <button onClick={() => git('/dis-hekim-talep')}>📋 Talepler</button>
      </div>
      {hata && <div className="hata-kutusu">{hata}</div>}

      {veri && o && (<>
        <div className="hi-serit">
          <div className="sel">📅 Dönem:
            <button className="ki-ok" title="Önceki ay" onClick={() => ayKaydir(-1)}>‹</button>
            <input type="date" value={bas} onChange={e => e.target.value && degistir({ bas: e.target.value })} />–
            <input type="date" value={bit} onChange={e => e.target.value && degistir({ bit: e.target.value })} />
            <button className="ki-ok" title="Sonraki ay" onClick={() => ayKaydir(1)}>›</button>
          </div>
          <div className="sel">🏥 Şube:
            <select value={sube} onChange={e => degistir({ sube: e.target.value })}>
              <option value={0}>Tümü</option>
              {veri.subeAdlari.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}
            </select>
          </div>
          <span className="ki-soluk">Karşılaştırma: {tarihYaz(veri.donem.oncekiBas)} – {tarihYaz(veri.donem.oncekiBit)}</span>
        </div>

        <div className="hi-ozet sp-ozet">
          {kutu('Gönderim (istem)', String(o.gonderim), `önceki ${o.onceki}`)}
          {kutu('Gönderim tutarı', paraYaz(o.tutar), `önceki ${paraYaz(o.oncekiTutar)}`)}
          {kutu('Değişim', degisimRozeti(o.degisim).ad, 'önceki döneme göre', degisimRozeti(o.degisim).renk)}
          {kutu('Ziyaret', String(o.ziyaret), `plan uyumu ${yuzdeYaz(o.planUyumu)}`)}
          {kutu('Gönderimi düşen hekim', String(o.dusenHekim), `60 gün sessiz ${o.sessizHekim}`, o.dusenHekim > 0 ? 'kir' : '')}
          {kutu('Gönderen primi', paraYaz(o.gonderenPrimi), 'dönem hakedişi')}
          {kutu('Temsilci primi', paraYaz(o.temsilciPrimi), `${o.temsilci} temsilci`)}
          {kutu('Dış doktor', String(o.hekim), 'kayıtlı, aktif')}
        </div>

        <div className="hi-sekmeler">
          {sekmeler.map(([k, ad, n]) => (
            <button key={k} className={sekme === k ? 'on' : ''} onClick={() => setSekme(k)}>{ad} <span className="b">{n}</span></button>
          ))}
        </div>

        {sekme === 'temsilci' && (
          <table className="hi-tablo sp-tablo">
            <thead><tr>
              <th>Temsilci</th><th>Şube</th><th className="sag">Hekim</th><th className="sag">Aktif*</th>
              <th className="sag">Ziyaret</th><th className="sag">Plan uyumu</th><th className="sag">Gönderim</th><th className="sag">Önceki</th><th className="sag">Değişim</th>
              <th className="sag">Tutar</th><th className="sag">Yeni hekim</th><th className="sag">Kaybedilen**</th><th className="sag">Açık talep</th><th className="sag">Termini geçen</th><th className="sag">Prim</th>
            </tr></thead>
            <tbody>
              {veri.temsilciler.map(t => (
                <tr key={`${t.id}-${t.subeId}`} className="ac" title="Çift tık: haftalık plan" onDoubleClick={() => git(`/dis-hekim-plan`)}>
                  <td>{t.ad}</td><td>{t.subeAd}</td><td className="sag">{t.hekim}</td><td className="sag">{t.aktifHekim}</td>
                  <td className="sag">{t.ziyaret}</td><td className="sag">{yuzdeYaz(t.planUyumu)}</td>
                  <td className="sag">{t.gonderim}</td><td className="sag">{t.onceki}</td><td className="sag">{rozet(t.degisim)}</td>
                  <td className="sag">{paraYaz(t.tutar)}</td><td className="sag">{t.yeniHekim}</td><td className="sag">{t.kaybedilen}</td>
                  <td className="sag">{t.acikTalep}</td><td className={'sag' + (t.terminiGecen > 0 ? ' kir' : '')}>{t.terminiGecen}</td>
                  <td className="sag">{paraYaz(t.prim)}</td>
                </tr>
              ))}
              {veri.temsilciler.length === 0 && <tr><td colSpan={15} className="ki-soluk">Şube temsilcisi tanımlı dış doktor yok.</td></tr>}
            </tbody>
          </table>
        )}
        {sekme === 'temsilci' && <div className="sp-not">* Aktif hekim = dönemde en az bir gönderim. ** Kaybedilen = önceki dönemde gönderip bu dönem göndermeyen. Plan uyumu = yapılan / (yapılan + geçmiş planlı + iptal).</div>}

        {sekme === 'doktor' && (<>
          <div className="hi-serit">
            {([['tum', 'Tümü'], ['yukselen', 'Yükselen'], ['dusen', 'Düşen'], ['sessiz', '60 gün sessiz'], ['yeni', 'Yeni (3 ay)'], ['ziyaretsiz', 'Ziyaret edilmeyen']] as [DoktorSuzgec, string][])
              .map(([k, ad]) => <button key={k} className={'ki-cip' + (suzgec === k ? ' on' : '')} onClick={() => setSuzgec(k)}>{ad}</button>)}
            <span className="sp" />
            <input placeholder="hekim / kurum / temsilci…" value={ara} onChange={e => setAra(e.target.value)} style={{ width: 220 }} />
          </div>
          <table className="hi-tablo sp-tablo">
            <thead><tr>
              <th>Dış Doktor</th><th>Branş</th><th>Kurum</th><th>Şube / Temsilci</th>
              <th className="sag">Gönderim</th><th className="sag">Önceki</th><th className="sag">Değişim</th><th className="sag">Tutar</th><th>Modalite</th>
              <th>Son gönderim</th><th>Son ziyaret</th><th className="sag">Ziyaret</th><th className="sag">Açık talep</th><th className="sag">Gönderen primi</th>
            </tr></thead>
            <tbody>
              {doktorlar.map(d => (
                <tr key={d.id} className={'ac' + (d.dusen || d.ziyaretEdilmeyen ? ' sp-kir' : '')} title="Çift tık: dış doktor kartı" onDoubleClick={() => git(`/dis-hekim/${d.id}`)}>
                  <td>{d.ad}</td><td>{d.brans}</td><td>{d.kurum}</td><td>{d.temsilciler}</td>
                  <td className="sag">{d.gonderim}</td><td className="sag">{d.onceki}</td>
                  <td className="sag">{d.sessiz ? <span className="ki-rozet kir">sessiz {d.sonGonderim ? `${Math.round((Date.now() - new Date(d.sonGonderim).getTime()) / 86400000)} g` : ''}</span> : d.yeni && d.onceki === 0 ? <span className="ki-rozet ok">yeni</span> : rozet(d.degisim)}</td>
                  <td className="sag">{paraYaz(d.tutar)}</td><td>{d.modaliteler}</td>
                  <td>{tarihYaz(d.sonGonderim)}</td><td className={d.ziyaretEdilmeyen ? 'kir' : ''}>{tarihYaz(d.sonZiyaret)}{d.gecikme > 0 ? ` (+${d.gecikme} g)` : ''}</td>
                  <td className="sag">{d.ziyaret}</td><td className="sag">{d.acikTalep}</td><td className="sag">{paraYaz(d.gonderenPrimi)}</td>
                </tr>
              ))}
              {doktorlar.length === 0 && <tr><td colSpan={14} className="ki-soluk">Kayıt yok.</td></tr>}
            </tbody>
          </table>
        </>)}

        {sekme === 'sube' && (
          <table className="hi-tablo sp-tablo">
            <thead><tr>
              <th>Şube</th><th className="sag">Temsilci</th><th className="sag">Hekim</th><th className="sag">Aktif hekim</th><th className="sag">Ziyaret</th><th className="sag">Plan uyumu</th>
              <th className="sag">Gönderim</th><th className="sag">Önceki</th><th className="sag">Değişim</th><th className="sag">Tutar</th><th className="sag">Hekim başı</th><th className="sag">Temsilci primi</th>
            </tr></thead>
            <tbody>
              {veri.subeler.map(s => (
                <tr key={s.subeId}>
                  <td>{s.subeAd}</td><td className="sag">{s.temsilci}</td><td className="sag">{s.hekim}</td><td className="sag">{s.aktifHekim}</td>
                  <td className="sag">{s.ziyaret}</td><td className="sag">{yuzdeYaz(s.planUyumu)}</td>
                  <td className="sag">{s.gonderim}</td><td className="sag">{s.onceki}</td><td className="sag">{rozet(s.degisim)}</td>
                  <td className="sag">{paraYaz(s.tutar)}</td><td className="sag">{s.aktifHekim ? (s.gonderim / s.aktifHekim).toFixed(1).replace('.', ',') : '—'}</td>
                  <td className="sag">{paraYaz(s.temsilciPrimi)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}

        {sekme === 'talep' && (
          <table className="hi-tablo sp-tablo">
            <thead><tr><th>Tür</th><th className="sag">Açık</th><th className="sag">Onayda</th><th className="sag">Termini geçen</th><th className="sag">Dönemde kapanan</th><th className="sag">Ort. kapanma (gün)</th><th>En çok (sorumlu)</th></tr></thead>
            <tbody>
              {veri.talepler.map(t => (
                <tr key={t.tur} className="ac" onDoubleClick={() => git('/dis-hekim-talep')}>
                  <td>{t.tur}</td><td className="sag">{t.acik}</td><td className="sag">{t.onayda}</td>
                  <td className={'sag' + (t.terminiGecen > 0 ? ' kir' : '')}>{t.terminiGecen}</td>
                  <td className="sag">{t.kapanan}</td><td className="sag">{String(t.ortKapanmaGun).replace('.', ',')}</td><td>{t.encok}</td>
                </tr>
              ))}
              {veri.talepler.length === 0 && <tr><td colSpan={7} className="ki-soluk">Talep yok.</td></tr>}
            </tbody>
          </table>
        )}
      </>)}
    </div>
  );
}

const SAHA_STILI = `
.ki-rozet { display:inline-block; border-radius:9px; padding:1px 7px; font-size:10.5px; border:1px solid #d4dde6; background:#eef1f5; color:#5b6b7c; }
.ki-rozet.ok { background:#e2f3e8; color:#2e7d46; border-color:#bfe3cb; } .ki-rozet.kir { background:#fbe5e5; color:#9d3434; border-color:#efc3c3; }
.ki-rozet.sari { background:#fff4e0; color:#9a5b00; border-color:#f0d3a0; } .ki-rozet.pas { background:#f3f6fa; color:#3a5573; }
.hi-kutu.kir .deg { color:#b3261e; } .hi-kutu.ok .deg { color:#2e7d46; } .hi-kutu.sari .deg { color:#9a5b00; }
.sp-ozet { grid-template-columns: repeat(8, 1fr); }
.hi-sekmeler { display:flex; gap:2px; padding:6px 12px 0; background:#f3f6fa; border-bottom:1px solid var(--cizgi,#cdd6e0); }
.hi-sekmeler button { border:1px solid var(--cizgi,#cdd6e0); border-bottom:none; border-radius:4px 4px 0 0; background:#e9eef4; color:#6b7a8b; padding:6px 12px; font-size:12px; cursor:pointer; }
.hi-sekmeler button.on { background:#fff; color:#14315a; font-weight:bold; }
.hi-sekmeler .b { display:inline-block; min-width:16px; text-align:center; background:#cdd9e6; color:#34506e; border-radius:9px; font-size:10px; padding:0 5px; margin-left:4px; }
.sp-tablo td, .sp-tablo th { white-space:nowrap; }
.sp-tablo tr.sp-kir td { background:#fff6f6; }
.sp-not { padding:6px 12px; font-size:11px; color:var(--soluk,#6b7a8b); }
.ki-cip { border:1px solid var(--cizgi,#cdd6e0); border-radius:12px; padding:2px 10px; font-size:11px; background:#f7f9fc; color:#3a5573; cursor:pointer; }
.ki-cip.on { background:#2f6db3; color:#fff; border-color:#2f6db3; }
`;
