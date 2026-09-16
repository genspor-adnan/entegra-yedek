import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { FtrSeansKarti as Kart } from '../../api/uclar/ftr';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { tarihSaat, tarihYaz } from '../../bilesenler/bicim';

/**
 * FTR SEANS UYGULAMA KARTI (719) — mockup `Ekranlar/FTR/ftr_seans.html`.
 * Günün seansı: uygulama işaretleri (sayaç), VAS önce/sonra, ev uyumu, not,
 * imza; "Seansı Bitir" → yapıldı, program sayacı, ara değerlendirme / kür
 * sonu geçişi. Modal, kapat geldiği yere döner (program kartı / pano / liste).
 */
const VAS = Array.from({ length: 11 }, (_, i) => i);
const YER: Record<number, string> = { 1: 'Klinik', 2: 'Ev', 3: 'Klinik + ev' };
type Sekme = 'uyg' | 'egz' | 'not';

export function FtrSeansKarti() {
  const { id: param } = useParams();
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const durumS = konum.state as { geri?: string; ustGeri?: string } | null;
  const geri = durumS?.geri ?? sorgu.get('geri') ?? '/ftr-seans';
  const kapat = useCallback(() => git(geri, durumS?.ustGeri ? { state: { geri: durumS.ustGeri } } : undefined), [git, geri, durumS?.ustGeri]);
  useEffect(() => { const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() }; window.addEventListener('keydown', f); return () => window.removeEventListener('keydown', f) }, [kapat]);

  const yeni = param === 'yeni';
  const id = yeni ? 0 : Number(param ?? 0);
  const [k, setK] = useState<Kart | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('uyg');
  const [taslak, setTaslak] = useState<Record<string, string>>({});
  const [tik, setTik] = useState(0);

  const yukle = useCallback(async () => {
    if (!id) return;
    try { const y = await api.ftrSeansKart(id); setK(y); setHata(null); setTaslak({ uygulamaNotu: y.seans.uygulama_notu, komplikasyon: y.seans.komplikasyon, hastayaTalimat: '', evUyum: y.seans.ev_uyum }) } catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => { const t = setInterval(() => setTik(x => x + 1), 1000); return () => clearInterval(t) }, []);

  const s = k?.seans; const p = k?.program;
  const acik = !!s && (s.durum === 1 || s.durum === 2);
  const yazar = yetki('ftr.seans') && acik;
  const sayac = useMemo(() => {
    if (!s?.baslangic) return '';
    const bas = new Date(s.baslangic).getTime(); const son = s.bitis ? new Date(s.bitis).getTime() : new Date(k!.simdi).getTime() + tik * 1000;
    const sn = Math.max(0, Math.floor((son - bas) / 1000));
    return `${String(Math.floor(sn / 3600)).padStart(2, '0')}:${String(Math.floor((sn % 3600) / 60)).padStart(2, '0')}:${String(sn % 60).padStart(2, '0')}`;
  }, [s, k, tik]);

  const guncelle = async (g: Record<string, unknown>) => { await guvenli(async () => { await api.ftrSeansGuncelle(id, g); await yukle() }) };
  const uygulama = async (uid: number, yapildi: boolean) => {
    let neden: string | undefined;
    if (!yapildi) { const n = await metinSor('Yapılmama nedeni (ağrı artışı / cihaz arızası / süre):'); if (n === null) return; neden = n }
    await guvenli(async () => { await api.ftrSeansUygulamaGuncelle(uid, { yapildi, neden }); await yukle() });
  };
  const bitir = async () => {
    if (!k) return;
    const yap = k.uygulamalar.filter(u => u.yapildi).length;
    if (!await onay(`Seans bitirilsin mi? ${yap}/${k.uygulamalar.length} uygulama yapıldı; seans "yapıldı" olur, program sayacı ilerler.`)) return;
    await guvenli(async () => { const y = await api.ftrSeansBitir(id); mesaj(`Seans bitti · ${y.yapilan}/${y.seansSayisi}${y.uyari ? ` — ${y.uyari}` : ''}`); await yukle() });
  };
  const yarim = async () => { const n = await metinSor('Yarım bırakma nedeni:'); if (n === null) return; await guvenli(async () => { await api.ftrSeansYarim(id, n); await yukle() }) };
  const gelmedi = async () => { if (!await onay('Hasta gelmedi olarak işaretlensin mi? Seans yakılmaz, program uzar.')) return; await guvenli(async () => { const y = await api.ftrSeansGelmedi(id); mesaj(`Devamsızlık ${y.devamsiz}${y.uyari ? ` — ${y.uyari}` : ''}`); await yukle() }) };

  const Perde = ({ children, baslik }: { children: ReactNode; baslik: ReactNode }) => (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">{baslik}<span className="kapt">Esc ile kapanır</span><button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov ds-kagov">{children}</div>
      </div>
    </div>
  );

  if (yeni) return <Perde baslik={<span>🏃 Seans</span>}><div className="ds-ic">Seans, program kartındaki "🏃 Bugünkü Seans" ya da Ünite Panosu'ndan açılır. <button className="d" onClick={() => git('/ftr-program')}>Programlar</button></div></Perde>;
  if (hata) return <Perde baslik={<span>🏃 Seans</span>}><div className="hata-kutusu">{hata}</div></Perde>;
  if (!k || !s) return <Perde baslik={<span>🏃 Seans</span>}><span className="sonuk">Yükleniyor…</span></Perde>;

  const VasSec = ({ alan, deger }: { alan: 'vasOnce' | 'vasSonra'; deger?: number | null }) => (
    <div className="ft-vas">{VAS.map(v => <i key={v} className={deger === v ? 'sec' : ''} onClick={() => yazar && void guncelle({ [alan]: v })}>{v}</i>)}</div>
  );

  return (
    <Perde baslik={<>
      <span>🏃 Seans Uygulama — {s.hasta_adi} · {s.bolge_adi} · Seans {s.sira} / {s.seans_sayisi}</span>
      <span className="ds-kabas-yol">{s.program_no} · {s.fizyoterapist_adi || 'fzt —'} · {s.kabin_adi || 'kabin —'} · {tarihYaz(s.tarih)} {s.saat}</span>
      <span className={`rozet ${s.durum === 2 ? 'mavi' : s.durum === 3 ? 'ok' : s.durum === 4 ? 'hata' : 'gri'}`}>{s.durum_adi}</span>
      {s.baslangic && <span className="rozet gri" title="Seans süresi">⏱ {sayac}</span>}
    </>}>
      <div className="ds-arac ds-kart-arac">
        {yazar && s.durum === 2 && <button className="d onay" onClick={() => void bitir()}>✔ Seansı Bitir</button>}
        {yazar && s.durum === 1 && p && <button className="d onay" onClick={() => void guvenli(async () => { const y = await api.ftrSeansAc(p.id); if (y.id !== id) git(`/ftr-seans/${y.id}`, { state: durumS ?? undefined }); else await yukle() })}>🏃 Seansı Başlat</button>}
        {yazar && s.durum === 2 && <button className="d" onClick={() => void yarim()}>⏸ Yarım Bırak</button>}
        {yazar && s.durum === 1 && <button className="d teh" onClick={() => void gelmedi()}>⛔ Gelmedi</button>}
        <span className="ds-sep" />
        {p && <button className="d" onClick={() => git(`/ftr-program/${p.id}`, { state: { geri: konum.pathname, ustGeri: geri } })}>📋 Program</button>}
        <button className="d" onClick={() => git(`/hasta/${s.hasta_id}?geri=${encodeURIComponent(konum.pathname)}`)}>↗ Hasta Kartı</button>
        {yazar && <button className="d" onClick={() => void guncelle({ imza: true })} disabled={s.imza === 1}>✍ {s.imza === 1 ? 'İmzalandı' : 'Hasta İmzası'}</button>}
        <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        <button className="d ds-sp" onClick={kapat}>✖ Kapat</button>
      </div>
      <div className="ds-hdr ds-hdr5" style={{ padding: '4px 10px 8px' }}>
        <div><label>Hasta</label><div className="ds-inp big">{s.hasta_adi}</div></div>
        <div><label>Program</label><div className="ds-inp">{s.program_no} · {s.bolge_adi} · {s.seans_sayisi} seans{p?.hekim_adi ? ` · ${p.hekim_adi}` : ''}</div></div>
        <div><label>VAS seans öncesi</label><div className="ds-inp" style={{ padding: 2 }}><VasSec alan="vasOnce" deger={s.vas_once} /></div></div>
        <div><label>Önceki seans</label><div className="ds-inp">{k.onceki ? `${k.onceki.sira}. · ${tarihYaz(k.onceki.tarih)} · VAS ${k.onceki.vasOnce ?? '—'}→${k.onceki.vasSonra ?? '—'}${k.onceki.not ? ` · "${k.onceki.not.slice(0, 60)}"` : ''}` : <span className="sonuk">ilk seans</span>}</div></div>
        <div><label>Ev programı uyumu</label><select value={taslak.evUyum ?? ''} disabled={!yazar} onChange={e => { setTaslak(t => ({ ...t, evUyum: e.target.value })); void guncelle({ evUyum: e.target.value }) }} style={{ width: '100%' }}><option value="">—</option><option>Yaptı (tam)</option><option>Yaptı (kısmi)</option><option>Yapmadı</option></select></div>
      </div>
      <div className="ka-sekmeler">
        {([['uyg', `Uygulamalar (${k.uygulamalar.filter(u => u.yapildi).length}/${k.uygulamalar.length})`], ['egz', `Egzersiz (${k.egzersizler.length})`], ['not', 'Seans Notu & Sonuç']] as [Sekme, string][])
          .map(([x, ad]) => <div key={x} className={`ka-sekme${sekme === x ? ' on' : ''}`} onClick={() => setSekme(x)}>{ad}</div>)}
      </div>

      {sekme === 'uyg' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-dg"><table className="ds-plan">
            <thead><tr><th className="orta">✔</th><th>Uygulama (SUT)</th><th className="orta">Süre</th><th>Parametre</th><th>Cihaz</th><th>Durum</th><th /></tr></thead>
            <tbody>
              {k.uygulamalar.map(u => <tr key={u.id} className={u.yapildi ? '' : u.neden ? 'soluk' : ''}>
                <td className="orta"><input type="checkbox" checked={u.yapildi} disabled={!yazar} onChange={e => void uygulama(u.id, e.target.checked)} /></td>
                <td>{u.ad}</td><td className="orta">{u.sureDk} dk</td><td>{u.parametre || '—'}</td><td>{u.cihazAd || '—'}</td>
                <td>{u.yapildi ? <span className="rozet ok">{u.baslangic && u.bitis ? `${tarihSaat(u.baslangic).slice(-5)}–${tarihSaat(u.bitis).slice(-5)}` : 'yapıldı'}</span> : u.neden ? <span className="rozet hata" title={u.neden}>yapılmadı · {u.neden}</span> : <span className="rozet gri">bekliyor</span>}</td>
                <td className="ds-satir-arac">{yazar && !u.yapildi && !u.neden && <button className="d" title="Yapılmadı (neden)" onClick={() => void uygulama(u.id, false)}>✖</button>}</td></tr>)}
              {k.uygulamalar.length === 0 && <tr><td colSpan={7} className="sonuk">Uygulama yok - program kartına uygulama ekleyin; seans açılırken kopyalanır.</td></tr>}
            </tbody>
          </table></div>
          <div className="ds-ic sonuk">İşaretlenen uygulama seans hizmet kaydına girer; yapılmayan "neden" ile geçilir. Toplam hedef ≈ {k.uygulamalar.reduce((a, u) => a + u.sureDk, 0)} dk.</div>
        </div>
      )}

      {sekme === 'egz' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-dg"><table><thead><tr><th>Egzersiz</th><th>Set × tekrar</th><th>Yer</th><th className="orta">Aşama</th></tr></thead>
            <tbody>{k.egzersizler.map(e => <tr key={e.id} className={s.sira < e.asamaBas || (e.asamaBit != null && s.sira > e.asamaBit) ? 'soluk' : ''}><td>{e.ad}</td><td>{e.setTekrar}</td><td>{YER[e.yer]}</td><td className="orta">{e.asamaBas}–{e.asamaBit ?? '…'}{s.sira >= e.asamaBas && (e.asamaBit == null || s.sira <= e.asamaBit) ? ' · bu seans' : ''}</td></tr>)}
              {k.egzersizler.length === 0 && <tr><td colSpan={4} className="sonuk">Egzersiz tanımlı değil.</td></tr>}</tbody></table></div>
        </div>
      )}

      {sekme === 'not' && (
        <div className="ds-odo-alan" style={{ gridTemplateColumns: '1fr 1fr' }}>
          <div className="ds-sol">
            <div className="ds-grp ds-grp-ic"><div className="ds-gb">Seans notu</div>
              <div className="ds-hdr" style={{ padding: '4px 10px 8px', gridTemplateColumns: '1fr 1fr' }}>
                <div style={{ gridColumn: '1 / 3' }}><label>Uygulama notu</label><textarea rows={3} style={{ width: '100%' }} value={taslak.uygulamaNotu ?? ''} disabled={!yazar} onChange={e => setTaslak(t => ({ ...t, uygulamaNotu: e.target.value }))} /></div>
                <div><label>VAS seans sonrası</label><div className="ds-inp" style={{ padding: 2 }}><VasSec alan="vasSonra" deger={s.vas_sonra} /></div></div>
                <div><label>Komplikasyon / yan etki</label><input style={{ width: '100%' }} value={taslak.komplikasyon ?? ''} disabled={!yazar} placeholder="Yok" onChange={e => setTaslak(t => ({ ...t, komplikasyon: e.target.value }))} /></div>
                <div style={{ gridColumn: '1 / 3' }}><label>Hastaya talimat</label><input style={{ width: '100%' }} value={taslak.hastayaTalimat ?? ''} disabled={!yazar} placeholder="Ev egzersizi 2×/gün · ağrı artarsa ara" onChange={e => setTaslak(t => ({ ...t, hastayaTalimat: e.target.value }))} /></div>
              </div>
              {yazar && <div className="ds-arac"><button className="d onay" onClick={() => void guncelle({ uygulamaNotu: taslak.uygulamaNotu, komplikasyon: taslak.komplikasyon, hastayaTalimat: taslak.hastayaTalimat })}>💾 Kaydet</button></div>}
            </div>
          </div>
          <div className="ds-sag">
            <div className="ds-grp"><div className="ds-gb">Sonuç</div>
              <div className="ds-ic">
                <p>Süre <b>{s.baslangic ? sayac : '—'}</b> · {k.uygulamalar.filter(u => u.yapildi).length}/{k.uygulamalar.length} uygulama · VAS {s.vas_once ?? '—'} → {s.vas_sonra ?? '—'}</p>
                <p>Hasta imzası: {s.imza === 1 ? <span className="rozet ok">alındı</span> : <span className="rozet gri">seans bitince</span>}</p>
                <p className="sonuk">"Seansı Bitir" → seans yapıldı; program sayacı {p ? `${p.yapilan_seans}/${p.seans_sayisi}` : ''}; {p?.ara_degerlendirme_seans}. seansta ara değerlendirme, sonuncuda kür sonu. Hizmet kaydı / hakediş sonraki adımda.</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </Perde>
  );
}
