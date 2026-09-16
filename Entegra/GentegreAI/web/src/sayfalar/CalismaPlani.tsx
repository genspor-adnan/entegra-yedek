import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni, type CalismaBlok, type CalismaPlaniYaniti } from '../api/sozlesme';
import { useOturum } from '../kimlik/OturumBaglami';
import { tarihYaz } from '../bilesenler/bicim';

/**
 * HEKİM ÇALIŞMA PLANI (711) — mockup `Ekranlar/Muayene/hekim_calisma_plani.html`.
 *
 * Haftalık plan ELLE ÇİZİLMEZ: şablon (her hafta / iki haftada bir) kendiliğinden
 * tekrar eder, istisna (izin, kongre, saat değişikliği, ek mesai) o günü ezer.
 * Bu sayfa türetilmiş blokları gösterir (`fn_hekim_calisma_bloklari`); şablon ve
 * istisna kayıtları generic listelerde (Randevu › Ayarlar). "Randevu verilebilir"
 * bayraklarının yerini aldı: hekim/bölüm listeleri plandan türer.
 */
const GUN_AD = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const ISTISNA: Record<number, string> = { 1: 'İzin', 2: 'Kongre / eğitim', 3: 'Saat değişikliği', 4: 'Ek mesai', 5: 'Kapalı' };
type Gorunum = 'hekim' | 'bolum' | 'bugun';

const iso = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const haftaBasi = (d: Date) => { const x = new Date(d); const g = (x.getDay() + 6) % 7; x.setDate(x.getDate() - g); x.setHours(0, 0, 0, 0); return x };

export function CalismaPlani() {
  const git = useNavigate();
  const { yetki } = useOturum();
  const yazar = yetki('randevu.plan');
  const [bas, setBas] = useState<Date>(() => haftaBasi(new Date()));
  const [veri, setVeri] = useState<CalismaPlaniYaniti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [hekimId, setHekimId] = useState<number | null>(null);
  const [departmanId, setDepartmanId] = useState<number | null>(null);
  const [sube, setSube] = useState<number | null>(null);
  const [gorunum, setGorunum] = useState<Gorunum>('hekim');
  const [bugun, setBugun] = useState<Awaited<ReturnType<typeof api.calismaBugun>> | null>(null);
  const [secili, setSecili] = useState<CalismaBlok | null>(null);

  const gunler = useMemo(() => Array.from({ length: 7 }, (_, i) => { const d = new Date(bas); d.setDate(d.getDate() + i); return d }), [bas]);
  const yukle = useCallback(async () => {
    try {
      setVeri(await api.calismaPlani({ bas: iso(gunler[0]), bit: iso(gunler[6]), hekimId, departmanId, sube: sube ?? 0 }));
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [gunler, hekimId, departmanId, sube]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => { if (gorunum === 'bugun') api.calismaBugun(undefined, sube ?? 0).then(setBugun).catch(h => setHata(hataMetni(h))) }, [gorunum, sube]);

  const bugunIso = iso(new Date());
  const bloklar = veri?.bloklar ?? [];
  // Satırlar: hekim görünümünde hekim × bölüm, bölüm görünümünde bölüm × hekim.
  const satirlar = useMemo(() => {
    const m = new Map<string, { baslik: string; alt: string; bloklar: CalismaBlok[] }>();
    for (const b of bloklar) {
      const k = gorunum === 'bolum' ? `${b.departmanId}|${b.hekimId}` : `${b.hekimId}|${b.departmanId}|${b.subeId}`;
      const sb = veri?.subeler.find(s => s.id === b.subeId)?.ad ?? '';
      const r = m.get(k) ?? { baslik: gorunum === 'bolum' ? b.departman || 'Bölümsüz' : b.hekim, alt: gorunum === 'bolum' ? b.hekim : `${b.departman}${sb ? ' · ' + sb : ''}`, bloklar: [] };
      r.bloklar.push(b); m.set(k, r);
    }
    return [...m.entries()].sort((a, b) => a[1].baslik.localeCompare(b[1].baslik, 'tr') || a[1].alt.localeCompare(b[1].alt, 'tr'));
  }, [bloklar, gorunum, veri]);

  const Blok = ({ b }: { b: CalismaBlok }) => (
    <div className={`cp-blok${b.kaynak === 3 ? ' kapali' : b.kaynak === 2 ? ' ist' : ''}${secili === b ? ' sel' : ''}`}
      title={b.kaynak === 3 ? `${ISTISNA[b.istisnaTur ?? 0]}${b.aciklama ? ' · ' + b.aciklama : ''}` : `${b.hekim} · ${b.departman} · ${b.saatBas}–${b.saatBit} · slot ${b.slotDk} dk · ${b.kanallar}${b.randevu ? ` · ${b.randevu} randevu` : ''}`}
      onClick={() => setSecili(b)}>
      {b.kaynak === 3 ? <>{ISTISNA[b.istisnaTur ?? 0]}{b.aciklama ? ` · ${b.aciklama}` : ''}</>
        : <>{b.saatBas}–{b.saatBit} · {b.slotDk} dk<span className="k">{b.kanallar.replace(/,/g, ' ')}</span>{b.kaynak === 2 ? <span className="k">· {ISTISNA[b.istisnaTur ?? 0]}</span> : null}{b.randevu ? <span className="k">· {b.randevu} rnd</span> : null}</>}
    </div>
  );

  return (
    <>
      <div className="sayfabas"><div className="basrow"><h1>Çalışma Planları</h1><span className="yol">Randevu › Çalışma Planları</span>
        <div className="sag" style={{ display: 'flex', gap: 6 }}>
          {yazar && <button className="d bir" onClick={() => git('/calisma-sablon/yeni')}>＋ Şablon</button>}
          {yazar && <button className="d" onClick={() => git('/calisma-istisna/yeni')}>🏖 İzin / İstisna</button>}
          <button className="d" onClick={() => git('/calisma-sablon')}>📋 Şablonlar</button>
          <button className="d" onClick={() => git('/calisma-istisna')}>İstisnalar</button>
          <button className="d" onClick={() => git('/randevu')}>📅 Takvim</button>
        </div></div></div>
      <div className="cp-sayfa">
        <div className="cp-arac">
          <button className="d" onClick={() => setBas(b => { const d = new Date(b); d.setDate(d.getDate() - 7); return d })}>‹ Önceki</button>
          <button className="d" onClick={() => setBas(haftaBasi(new Date()))}>Bu hafta</button>
          <button className="d" onClick={() => setBas(b => { const d = new Date(b); d.setDate(d.getDate() + 7); return d })}>Sonraki ›</button>
          <b>{tarihYaz(iso(gunler[0]))} – {tarihYaz(iso(gunler[6]))}</b>
          <span style={{ marginLeft: 'auto', display: 'inline-flex', gap: 6, flexWrap: 'wrap' }}>
            <select value={sube ?? ''} onChange={e => setSube(e.target.value ? Number(e.target.value) : null)}><option value="">Şube: Tümü</option>{veri?.subeler.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}</select>
            <select value={departmanId ?? ''} onChange={e => setDepartmanId(e.target.value ? Number(e.target.value) : null)}><option value="">Bölüm: Tümü</option>{veri?.bolumler.map(b => <option key={b.id} value={b.id}>{b.ad}{b.randevusuz ? ' (randevusuz)' : ''}</option>)}</select>
            <select value={hekimId ?? ''} onChange={e => setHekimId(e.target.value ? Number(e.target.value) : null)}><option value="">Hekim: Tümü</option>{veri?.hekimler.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}</select>
            {([['hekim', 'Hekim × bölüm'], ['bolum', 'Bölüm toplu'], ['bugun', 'Bugün çalışanlar']] as [Gorunum, string][]).map(([k, ad]) => <span key={k} className={`cip${gorunum === k ? ' on' : ''}`} onClick={() => setGorunum(k)}>{ad}</span>)}
          </span>
        </div>
        <div className="cp-lej"><span><i style={{ background: '#eef4fc', border: '1px solid #cfe0f5' }} />şablon (her hafta kendiliğinden)</span><span><i style={{ background: '#e2f3e8' }} />istisna: saat değişikliği / ek mesai</span><span><i style={{ background: '#fbe9e7' }} />izin / kongre / kapalı</span><span className="sonuk">Plan elle çizilmez: şablon tekrar eder, yalnız istisna girilir. Hekim/bölüm randevu listeleri bu plandan türer.</span></div>
        {hata && <div className="hata-kutusu">{hata}</div>}

        {gorunum !== 'bugun' && (
          <div className="cp-ikili">
            <div className="cp-plan">
              <div className="cp-hb">{gorunum === 'bolum' ? 'Bölüm · Hekim' : 'Hekim · Bölüm'}</div>
              {gunler.map((d, i) => <div key={i} className={`cp-hb${iso(d) === bugunIso ? ' bugun' : ''}`}>{GUN_AD[i]} {d.getDate()}</div>)}
              {satirlar.map(([k, r]) => (<div key={k} style={{ display: 'contents' }}>
                <div className="cp-hk">{r.baslik}<small>{r.alt}</small></div>
                {gunler.map((d, i) => { const g = iso(d); const bl = r.bloklar.filter(b => String(b.gun).slice(0, 10) === g); return (
                  <div key={i}>{bl.length ? bl.map((b, j) => <Blok key={j} b={b} />) : <div className="cp-blok bos">—</div>}</div>) })}
              </div>))}
              {satirlar.length === 0 && <div style={{ gridColumn: '1 / -1' }} className="sonuk">Bu haftada blok yok. "＋ Şablon" ile hekim × bölüm çalışma düzeni tanımlayın.</div>}
            </div>
            <div className="ds-grp">
              <div className="ds-gb">{secili ? `${secili.hekim} · ${secili.departman}` : 'Seçili blok'}</div>
              {secili ? (
                <div className="ds-ic">
                  <div><span className="sonuk">Gün</span> · {tarihYaz(String(secili.gun).slice(0, 10))} {secili.saatBas ? `${secili.saatBas}–${secili.saatBit}` : ''}</div>
                  <div><span className="sonuk">Kaynak</span> · {secili.kaynak === 1 ? 'şablon (tekrar eden)' : secili.kaynak === 2 ? `istisna · ${ISTISNA[secili.istisnaTur ?? 0]}` : `kapalı · ${ISTISNA[secili.istisnaTur ?? 0]}`}</div>
                  {secili.kaynak !== 3 && <div><span className="sonuk">Slot / kanal</span> · {secili.slotDk} dk · {secili.kanallar} · {secili.randevu} randevu</div>}
                  {secili.aciklama && <div className="sonuk">{secili.aciklama}</div>}
                  <div style={{ display: 'flex', gap: 4, marginTop: 6, flexWrap: 'wrap' }}>
                    {secili.sablonId && <button className="d" onClick={() => git(`/calisma-sablon/${secili.sablonId}?geri=%2Fcalisma-plani`)}>📋 Şablonu aç</button>}
                    {secili.istisnaId && <button className="d" onClick={() => git(`/calisma-istisna/${secili.istisnaId}?geri=%2Fcalisma-plani`)}>🏖 İstisnayı aç</button>}
                    {yazar && secili.kaynak !== 3 && <button className="d" onClick={() => git(`/calisma-istisna/yeni?hekimId=${secili.hekimId}&geri=%2Fcalisma-plani`)}>＋ Bu hekime istisna</button>}
                    <button className="d" onClick={() => git(`/randevu?hekimId=${secili.hekimId}`)}>📅 Randevuları</button>
                  </div>
                </div>
              ) : <div className="ds-ic sonuk">Blok tıklayın: kaynak, slot, kanal, randevu sayısı; şablon / istisna kartına geçiş.</div>}
              <div className="ds-gb">Kurallar</div>
              <div className="ds-ic sonuk">Şablon = hekim × şube × bölüm × günler × saat × slot × kanal; "her hafta" ya da "iki haftada bir" tekrar eder, bitiş boşsa süresiz. İstisna o günü ezer: izin / kongre / kapalı bloğu kaldırır, saat değişikliği yerine yeni saat koyar, ek mesai blok ekler. Aktif şablonu olan hekim randevu ve başvuru listelerinde görünür; hekimsiz bölüm (acil, lab) "randevusuz kabul" ile.</div>
            </div>
          </div>
        )}

        {gorunum === 'bugun' && (
          <div className="ds-grp">
            <div className="ds-gb">Bugün çalışan bölüm / hekim <span className="ds-sp sonuk">{bugun ? tarihYaz(String(bugun.gun).slice(0, 10)) : ''} · kayıt kabul bu listeyi görür</span></div>
            <div className="ds-dg"><table>
              <thead><tr><th>Bölüm</th><th>Hekim</th><th>Saatler</th><th>Şu an</th><th className="orta">Randevu</th><th className="orta">Gelen</th><th className="orta">Kanal</th></tr></thead>
              <tbody>
                {(bugun?.satirlar ?? []).map((s, i) => <tr key={i}><td>{s.departman}</td><td>{s.hekim}</td><td>{s.saatler}</td>
                  <td>{s.simdi ? <span className="rozet ok">muayenede</span> : <span className="rozet gri">saat dışı</span>}{s.kaynak === 2 ? <span className="rozet uyari" style={{ marginLeft: 4 }}>istisna</span> : null}</td>
                  <td className="orta">{s.randevu}</td><td className="orta">{s.gelen}</td><td className="orta">{s.kanallar}</td></tr>)}
                {(bugun?.randevusuz ?? []).map(d => <tr key={'r' + d.id} className="soluk"><td>{d.ad}</td><td>—</td><td>—</td><td><span className="rozet mavi">randevusuz kabul</span></td><td className="orta">—</td><td className="orta">—</td><td className="orta">—</td></tr>)}
                {bugun && bugun.satirlar.length === 0 && bugun.randevusuz.length === 0 && <tr><td colSpan={7} className="sonuk">Bugün planlı hekim yok.</td></tr>}
              </tbody>
            </table></div>
          </div>
        )}
      </div>
    </>
  );
}
