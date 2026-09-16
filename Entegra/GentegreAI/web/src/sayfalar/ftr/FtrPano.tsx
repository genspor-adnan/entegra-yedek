import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { FtrPano as Pano } from '../../api/uclar/ftr';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import { tarihYaz } from '../../bilesenler/bicim';

/**
 * FTR ÜNİTE PANOSU (719) — mockup `Ekranlar/FTR/ftr_unite_panosu.html`.
 * Kabin kartları (sürüyor / bekliyor / boş), bekleyen sırası, fizyoterapist
 * yükü, günün programı. Kart tıkla → seans ekranı; 30 sn'de bir tazelenir.
 */
const TUR: Record<number, string> = { 1: 'Kabin', 2: 'Egzersiz salonu', 3: 'Hidroterapi', 4: 'Manuel terapi', 5: 'Robotik', 6: 'Grup' };
type Gorunum = 'kabin' | 'sira' | 'fzt' | 'program';

export function FtrPano() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const [pano, setPano] = useState<Pano | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [uniteId, setUniteId] = useState<number | null>(null);
  const [gorunum, setGorunum] = useState<Gorunum>('kabin');
  const [tik, setTik] = useState(0);
  const yukle = useCallback(async () => { try { setPano(await api.ftrPano(uniteId)); setHata(null) } catch (h) { setHata(hataMetni(h)) } }, [uniteId]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => { const t = setInterval(() => { setTik(x => x + 1); void yukle() }, 30000); return () => clearInterval(t) }, [yukle]);

  const seanslar = pano?.seanslar ?? [];
  const suren = seanslar.filter(s => s.durum === 2), bekleyen = seanslar.filter(s => s.durum === 1), yapilan = seanslar.filter(s => s.durum === 3), gelmeyen = seanslar.filter(s => s.durum === 4);
  const dk = (b?: string | null) => (b ? Math.max(0, Math.floor((Date.now() - new Date(b).getTime()) / 60000)) : 0);
  const baslat = async (s: Pano['seanslar'][number]) => { if (!yetki('ftr.seans')) return; await guvenli(async () => { const y = await api.ftrSeansAc(s.programId, { kabinId: s.kabinId ?? undefined }); git(`/ftr-seans/${y.id}`, { state: { geri: '/ftr-pano' } }) }) };
  const gelmedi = async (s: Pano['seanslar'][number]) => { await guvenli(async () => { const y = await api.ftrSeansGelmedi(s.id); mesaj(`Devamsızlık ${y.devamsiz}${y.uyari ? ` — ${y.uyari}` : ''}`); await yukle() }) };
  const ac = (s: Pano['seanslar'][number]) => git(`/ftr-seans/${s.id}`, { state: { geri: '/ftr-pano' } });
  void tik;

  return (
    <>
      <div className="sayfabas"><div className="basrow"><h1>Ünite Panosu</h1><span className="yol">FTR › Ünite Panosu</span>
        <div className="sag" style={{ display: 'flex', gap: 6 }}>
          <button className="d bir" onClick={() => git('/ftr-program')}>📋 Programlar</button>
          <button className="d" onClick={() => git('/ftr-seans')}>Seanslar</button>
          <button className="d" onClick={() => git('/ftr-unite')}>🚪 Üniteler</button>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        </div></div></div>
      <div className="cp-sayfa">
        <div className="cp-arac">
          <select value={uniteId ?? pano?.uniteId ?? ''} onChange={e => setUniteId(e.target.value ? Number(e.target.value) : null)}>{(pano?.uniteler ?? []).map(u => <option key={u.id} value={u.id}>{u.kod} · {u.ad}</option>)}</select>
          <b>{pano ? tarihYaz(String(pano.gun).slice(0, 10)) : ''}</b>
          <span className="sonuk">bugün {seanslar.length} seans · {yapilan.length} yapıldı · {suren.length} sürüyor · {bekleyen.length} bekliyor · {gelmeyen.length} gelmedi</span>
          <span style={{ marginLeft: 'auto', display: 'inline-flex', gap: 6 }}>
            {([['kabin', 'Kabinler'], ['sira', `Bekleyenler (${bekleyen.length})`], ['fzt', 'Fizyoterapist yükü'], ['program', 'Günün programı']] as [Gorunum, string][]).map(([k, ad]) => <span key={k} className={`cip${gorunum === k ? ' on' : ''}`} onClick={() => setGorunum(k)}>{ad}</span>)}
          </span>
        </div>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="ds-ozet6" style={{ gridTemplateColumns: 'repeat(5,1fr)', padding: 0 }}>
          <div><span>Bugün seans</span><b>{seanslar.length}</b><i>{yapilan.length} yapıldı · {suren.length} sürüyor · {bekleyen.length} bekliyor</i></div>
          <div><span>Kabin doluluk</span><b>{new Set(suren.map(s => s.kabinId)).size} / {(pano?.kabinler ?? []).filter(k => k.aktif).length}</b></div>
          <div><span>Bekleyen (planlı)</span><b className={bekleyen.length > 5 ? 'ds-kir' : ''}>{bekleyen.length}</b></div>
          <div><span>Fizyoterapist</span><b>{(pano?.fizyoterapistler ?? []).length}</b><i>{(pano?.fizyoterapistler ?? []).map(f => f.bugun).join(' / ') || '—'}</i></div>
          <div><span>Gelmedi</span><b className={gelmeyen.length ? 'ds-kir' : ''}>{gelmeyen.length}</b></div>
        </div>

        {gorunum === 'kabin' && (
          <div className="ft-kabinler">
            {(pano?.kabinler ?? []).map(kb => {
              const sr = suren.filter(s => s.kabinId === kb.id); const bk = bekleyen.filter(s => s.kabinId === kb.id);
              const sinif = !kb.aktif ? 'bakim' : sr.length ? 'dolu' : bk.length ? 'bekle' : 'bos';
              return (
                <div key={kb.id} className={`ft-kb ${sinif}`}>
                  <div className="ft-kbh">{kb.ad}<span className="sonuk" style={{ fontWeight: 400 }}> · {TUR[kb.tur]}</span>{sr[0]?.baslangic && <span className="ft-sayac">⏱ {dk(sr[0].baslangic)} dk</span>}</div>
                  {sr.map(s => <div key={s.id} className="ft-kart" onClick={() => ac(s)}>
                    <b>{s.hasta}</b> <span className="sonuk">· {s.bolge}</span><div className="sonuk">{s.programNo} · {s.sira}/{s.seansSayisi}</div>
                    <div>{s.yapilanlar ? `${s.yapilanlar} ✔` : ''}{s.sonrakiUygulama ? <span> · <b>{s.sonrakiUygulama}</b> ⏵</span> : ''}</div>
                    <div className="sonuk">{s.fizyoterapist}</div>
                  </div>)}
                  {bk.map(s => <div key={s.id} className="ft-kart ft-kart-bekle" onClick={() => void baslat(s)}>
                    <b>{s.hasta}</b> <span className="sonuk">· {s.bolge} · {s.saat}</span><div className="sonuk">{s.programNo} · {s.sira}/{s.seansSayisi} · bekliyor</div>
                    <div><button className="d mini onay" onClick={e => { e.stopPropagation(); void baslat(s) }}>🏃 Başlat</button></div>
                  </div>)}
                  {!sr.length && !bk.length && <div className="sonuk">{kb.aktif ? 'boş' : 'pasif / bakımda'}{kb.cihazlar ? ` · ${kb.cihazlar}` : ''}</div>}
                </div>
              );
            })}
            {(pano?.kabinler ?? []).length === 0 && <div className="sonuk">Ünitede kabin yok - FTR › Ayarlar › Üniteler & Kabinler.</div>}
          </div>
        )}

        {gorunum === 'sira' && (
          <div className="ds-grp"><div className="ds-gb">Bekleyenler & sıra <span className="ds-sp sonuk">planlı seanslar · saat sırasıyla</span></div>
            <div className="ds-dg"><table><thead><tr><th>Saat</th><th>Hasta</th><th>Program</th><th className="orta">Seans</th><th>Fizyoterapist</th><th>Kabin</th><th>Durum</th><th /></tr></thead>
              <tbody>
                {[...bekleyen, ...gelmeyen].map(s => <tr key={s.id} className={s.durum === 4 ? 'soluk' : ''}><td>{s.saat}</td><td><b>{s.hasta}</b> · {s.bolge}</td><td>{s.programNo}</td><td className="orta">{s.sira}/{s.seansSayisi}{s.sira === 1 ? ' · ilk' : ''}</td><td>{s.fizyoterapist || '—'}</td><td>{s.kabin || '—'}</td>
                  <td><span className={`rozet ${s.durum === 4 ? 'hata' : 'gri'}`}>{s.durumAdi}</span></td>
                  <td className="ds-satir-arac">{s.durum === 1 && yetki('ftr.seans') && <><button className="d onay" onClick={() => void baslat(s)}>🏃 Başlat</button> <button className="d" onClick={() => void gelmedi(s)}>⛔ Gelmedi</button></>}</td></tr>)}
                {bekleyen.length === 0 && gelmeyen.length === 0 && <tr><td colSpan={8} className="sonuk">Bekleyen yok.</td></tr>}
              </tbody></table></div>
          </div>
        )}

        {gorunum === 'fzt' && (
          <div className="ds-grp"><div className="ds-gb">Fizyoterapist yükü (bugün)</div>
            <div className="ds-dg"><table><thead><tr><th>Fizyoterapist</th><th className="orta">Bugün seans</th><th className="orta">Yapıldı</th><th className="orta">Sürüyor</th><th className="orta">Bekleyen</th><th>Yük</th></tr></thead>
              <tbody>{(pano?.fizyoterapistler ?? []).map(f => <tr key={f.id}><td>{f.ad}</td><td className="orta">{f.bugun}</td><td className="orta">{f.yapilan}</td><td className="orta">{f.suren}</td><td className="orta">{f.bugun - f.yapilan - f.suren}</td><td><span className={`rozet ${f.bugun >= 12 ? 'hata' : f.bugun >= 8 ? 'uyari' : 'ok'}`}>{f.bugun >= 12 ? 'yüksek' : f.bugun >= 8 ? 'orta' : 'normal'}</span></td></tr>)}
                {(pano?.fizyoterapistler ?? []).length === 0 && <tr><td colSpan={6} className="sonuk">Bugün atanmış fizyoterapist yok.</td></tr>}</tbody></table></div>
          </div>
        )}

        {gorunum === 'program' && (
          <div className="ds-grp"><div className="ds-gb">Günün programı</div>
            <div className="ds-dg"><table><thead><tr><th>Saat</th><th>Hasta</th><th>Program</th><th className="orta">Seans</th><th>Kabin</th><th>Fizyoterapist</th><th className="orta">Uygulama</th><th>Durum</th><th /></tr></thead>
              <tbody>{seanslar.map(s => <tr key={s.id} className={s.durum === 4 || s.durum === 5 ? 'soluk' : ''}><td>{s.saat}</td><td><b>{s.hasta}</b> · {s.bolge}</td><td>{s.programNo}</td><td className="orta">{s.sira}/{s.seansSayisi}</td><td>{s.kabin || '—'}</td><td>{s.fizyoterapist || '—'}</td><td className="orta">{s.uygulamaSayisi ? `${s.yapilanUygulama}/${s.uygulamaSayisi}` : '—'}</td>
                <td><span className={`rozet ${s.durum === 2 ? 'mavi' : s.durum === 3 ? 'ok' : s.durum === 4 ? 'hata' : 'gri'}`}>{s.durumAdi}</span></td><td className="ds-satir-arac"><button className="d" onClick={() => ac(s)}>Aç</button></td></tr>)}
                {seanslar.length === 0 && <tr><td colSpan={9} className="sonuk">Bugün seans yok.</td></tr>}</tbody></table></div>
          </div>
        )}
      </div>
    </>
  );
}
