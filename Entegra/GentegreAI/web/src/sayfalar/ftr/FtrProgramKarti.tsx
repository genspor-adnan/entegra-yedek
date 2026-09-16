import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useLocation, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { FtrProgramKarti as Kart } from '../../api/uclar/ftr';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import { TarafSecici } from '../../bilesenler/TarafArama';
import { tarihSaat, tarihYaz } from '../../bilesenler/bicim';

/**
 * FTR TEDAVİ PROGRAMI (KÜR) KARTI (719) — mockup `Ekranlar/FTR/ftr_program_karti.html`.
 * Program = iş birimi: SUT uygulamaları, seans sayısı/sıklık, fizyoterapist,
 * kabin, Medula rapor hakkı; seanslar buradan planlanır ve açılır. Modal:
 * arkada Tedavi Programları listesi, kapat geldiği yere döner.
 */
const DURUM: Record<number, [string, string]> = { 1: ['Taslak', 'gri'], 2: ['Sürüyor', 'mavi'], 3: ['Ara değerlendirme', 'uyari'], 4: ['Tamamlandı', 'ok'], 5: ['Sonlandırıldı', 'hata'] };
const SEANS: Record<number, string> = { 1: 'gri', 2: 'mavi', 3: 'ok', 4: 'hata', 5: 'gri', 6: 'uyari' };
const YER: Record<number, string> = { 1: 'Klinik', 2: 'Ev', 3: 'Klinik + ev' };
const YANIT: Record<number, string> = { 1: 'İyi yanıt', 2: 'Kısmi yanıt', 3: 'Yanıtsız' };
type Sekme = 'uyg' | 'seans' | 'egz' | 'takip' | 'gunluk';

export function FtrProgramKarti() {
  const { id: param } = useParams();
  const git = useNavigate();
  const konum = useLocation();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const durumS = konum.state as { geri?: string; ustGeri?: string } | null;
  const geri = durumS?.geri ?? sorgu.get('geri') ?? '/ftr-program';
  const kapat = useCallback(() => git(geri, durumS?.ustGeri ? { state: { geri: durumS.ustGeri } } : undefined), [git, geri, durumS?.ustGeri]);
  useEffect(() => { const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() }; window.addEventListener('keydown', f); return () => window.removeEventListener('keydown', f) }, [kapat]);

  const yeni = param === 'yeni';
  const id = yeni ? 0 : Number(param ?? 0);
  const [k, setK] = useState<Kart | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('uyg');
  const [ara, setAra] = useState<{ acik: boolean; q: string; sonuc: { id: number; sutKodu: string; ad: string }[]; ad: string; sure: string; parametre: string; cihaz: string }>({ acik: false, q: '', sonuc: [], ad: '', sure: '15', parametre: '', cihaz: '' });
  const [yeniHasta, setYeniHasta] = useState<{ id: number; ad: string } | null>(null);

  const yukle = useCallback(async () => {
    if (!id) return;
    try { setK(await api.ftrProgramKart(id)); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { void yukle() }, [yukle]);

  const p = k?.program;
  const acik = !!p && p.durum <= 3;
  const yazar = yetki('ftr.program') && acik;
  const geriBurasi = konum.pathname;

  const seansAc = async () => { if (!p) return; await guvenli(async () => { const y = await api.ftrSeansAc(p.id); git(`/ftr-seans/${y.id}`, { state: { geri: geriBurasi, ustGeri: geri } }) }) };
  const planla = async () => {
    if (!p) return;
    if (!await onay(`${p.seans_sayisi} seans, haftada ${p.siklik_haftalik} gün, ${p.saat} saatine planlansın mı? (mevcut planlı seanslar korunur)`)) return;
    await guvenli(async () => { const y = await api.ftrPlanla(p.id); mesaj(`${y.eklenen} seans planlandı.`); await yukle() });
  };
  const sonlandir = async () => {
    if (!p) return;
    const not = await metinSor('Kür sonu / sonlandırma notu:'); if (not === null) return;
    await guvenli(async () => { const y = await api.ftrSonlandir(p.id, { not }); mesaj(y.durum === 4 ? 'Kür tamamlandı.' : `Program sonlandırıldı · ${y.iptalSeans} planlı seans iptal.`); await yukle() });
  };
  const araYap = async (q: string) => { setAra(a => ({ ...a, q })); try { const y = await api.ftrUygulamaAra(q); setAra(a => ({ ...a, sonuc: y.satirlar })) } catch { /* sessiz */ } };
  const uygulamaEkle = async (hizmetId: number | null, ad?: string) => {
    if (!p) return;
    await guvenli(async () => { await api.ftrUygulamaEkle(p.id, { hizmetId, ad: ad || (hizmetId ? undefined : ara.ad), sureDk: Number(ara.sure) || 15, parametre: ara.parametre, cihazAd: ara.cihaz }); setAra(a => ({ ...a, acik: false, q: '', sonuc: [], ad: '' })); await yukle() });
  };
  const uygulamaSil = async (uid: number) => { if (!await onay('Uygulama satırı silinsin mi?')) return; await guvenli(async () => { await api.ftrUygulamaSil(uid); await yukle() }) };
  const yeniProgram = () => { if (!yeniHasta) { mesaj('Hasta seçin.'); return } git(`/ftr-program-kart/yeni?hastaId=${yeniHasta.id}&hastaAd=${encodeURIComponent(yeniHasta.ad)}&geri=${encodeURIComponent(geri)}`) };

  const vasSeyri = useMemo(() => (k?.seanslar ?? []).filter(s => s.durum === 3 && (s.vasOnce != null || s.vasSonra != null)), [k]);

  const Perde = ({ children, baslik }: { children: ReactNode; baslik: ReactNode }) => (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">{baslik}<span className="kapt">Esc ile kapanır</span><button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov ds-kagov">{children}</div>
      </div>
    </div>
  );

  if (yeni) return (
    <Perde baslik={<span>📋 Yeni Tedavi Programı (Kür)</span>}>
      <div className="ds-hdr" style={{ padding: 12 }}>
        <div><label>Hasta</label><TarafSecici etiket="" deger={yeniHasta?.ad ?? ''} kaynaklar={['hasta']} bosMetin="Hasta seçin…" onSec={h => setYeniHasta({ id: h.id, ad: h.unvan })} onTemizle={() => setYeniHasta(null)} /></div>
        <div><label>&nbsp;</label><button className="d bir" onClick={yeniProgram}>📋 Program Kartını Aç</button></div>
      </div>
      <div className="ds-ic sonuk">Program kartında bölge, seans sayısı, sıklık, fizyoterapist, kabin ve rapor hakkı girilir; kaydedince bu ekrana döner ve uygulamalar eklenir. Önce FTR değerlendirmesi yapılması önerilir (Değerlendirmeler).</div>
    </Perde>
  );
  if (hata) return <Perde baslik={<span>📋 Tedavi Programı</span>}><div className="hata-kutusu">{hata}</div></Perde>;
  if (!k || !p) return <Perde baslik={<span>📋 Tedavi Programı</span>}><span className="sonuk">Yükleniyor…</span></Perde>;

  const dr = DURUM[p.durum] ?? ['?', 'gri'];
  const adimlar: [string, boolean, boolean][] = [
    ['Değerlendirme', !!p.degerlendirme_id, false],
    [`Program açıldı · ${tarihYaz(p.baslangic)}`, true, p.durum === 1],
    [`Sürüyor · ${p.yapilan_seans} / ${p.seans_sayisi}`, p.durum >= 2, p.durum === 2],
    [`Ara değerlendirme (${p.ara_degerlendirme_seans}.)`, p.yapilan_seans >= p.ara_degerlendirme_seans, p.durum === 3],
    ['Kür sonu', p.durum >= 4, p.durum >= 4],
  ];

  return (
    <Perde baslik={<>
      <span>📋 Tedavi Programı — {p.program_no} · {p.hasta_adi} · {p.bolge_adi} · {p.seans_sayisi} seans</span>
      <span className="ds-kabas-yol">{p.hekim_adi || 'uzman —'} · {p.fizyoterapist_adi || 'fzt —'} · {p.unite_adi || 'ünite —'}{p.kabin_adi ? ` / ${p.kabin_adi}` : ''} · FTR › Tedavi Programları</span>
      <span className={`rozet ${dr[1]}`}>{dr[0]}</span>
    </>}>
      <div className="ds-arac ds-kart-arac">
        {yazar && <button className="d" onClick={() => git(`/ftr-program-kart/${p.id}?geri=${encodeURIComponent(geriBurasi)}`)}>✎ Düzenle</button>}
        {yazar && <button className="d" onClick={() => { setSekme('uyg'); setAra(a => ({ ...a, acik: true })); void araYap('') }}>＋ Uygulama (SUT)</button>}
        {yazar && <button className="d" onClick={() => void planla()}>🗓 Seansları Planla</button>}
        {yazar && yetki('ftr.seans') && <button className="d onay" onClick={() => void seansAc()}>🏃 Bugünkü Seans</button>}
        <span className="ds-sep" />
        {p.degerlendirme_id && <button className="d" onClick={() => git(`/ftr-degerlendirme/${p.degerlendirme_id}?geri=${encodeURIComponent(geriBurasi)}`)}>🩺 Değerlendirme</button>}
        <button className="d" onClick={() => git(`/ftr-olcek/yeni?hastaId=${p.hasta_id}&programId=${p.id}&geri=${encodeURIComponent(geriBurasi)}`)}>📈 Ölçek Gir</button>
        <button className="d" onClick={() => git(`/hasta/${p.hasta_id}?geri=${encodeURIComponent(geriBurasi)}`)}>↗ Hasta Kartı</button>
        {yazar && yetki('ftr.program.sonlandir') && <button className="d teh" onClick={() => void sonlandir()}>✖ {p.yapilan_seans >= p.seans_sayisi ? 'Kürü Bitir' : 'Programı Sonlandır'}</button>}
        <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        <button className="d ds-sp" onClick={kapat}>✖ Kapat</button>
      </div>
      <div className="ds-adim">{adimlar.map(([ad, gecti, simdi]) => <span key={ad} className={simdi ? 'on' : gecti ? 'ok' : ''}>{ad}</span>)}</div>
      <div className="ds-hdr ds-hdr5" style={{ padding: '4px 10px 8px' }}>
        <div><label>Hasta</label><div className="ds-inp big">{p.hasta_adi}</div></div>
        <div><label>Bölge · tanı</label><div className="ds-inp">{p.bolge_adi}{p.icd_kod ? ` · ${p.icd_kod}` : ''}{p.tani_ad ? ` ${p.tani_ad}` : ''}</div></div>
        <div><label>Seans · sıklık · süre</label><div className="ds-inp">{p.seans_sayisi} seans · {p.siklik_haftalik}/hafta · {p.seans_sure_dk} dk · {p.saat}</div></div>
        <div><label>Fizyoterapist · kabin</label><div className="ds-inp">{p.fizyoterapist_adi || '—'}{p.kabin_adi ? ` · ${p.kabin_adi}` : ''}</div></div>
        <div><label>Ödeyen · rapor</label><div className="ds-inp">{p.odeyen_adi}{p.rapor_no ? <span className="rozet ok">{p.rapor_no} · {p.rapor_seans_hakki} seans</span> : <span className="rozet gri">rapor yok</span>}</div></div>
        <div><label>Başlangıç → tahmini bitiş</label><div className="ds-inp">{tarihYaz(p.baslangic)} → {p.bitis_tahmini ? tarihYaz(p.bitis_tahmini) : '—'}{p.bitis ? ` · bitti ${tarihYaz(p.bitis)}` : ''}</div></div>
        <div><label>Durum</label><div className="ds-inp"><span className={`rozet ${dr[1]}`}>{dr[0]}</span> {p.yapilan_seans} yapıldı · {p.devamsiz} devamsız</div></div>
        <div><label>Sonraki seans</label><div className="ds-inp">{p.sonraki_seans ? tarihYaz(p.sonraki_seans) : <span className="sonuk">planlanmadı</span>}</div></div>
        <div><label>Yıllık hak (bölge)</label><div className="ds-inp">{p.rapor_seans_hakki ? `${p.rapor_seans_hakki} · ` : ''}<span className={`rozet ${p.kalan_hak < p.seans_sayisi - p.yapilan_seans ? 'uyari' : 'ok'}`}>kalan {p.kalan_hak}</span>{p.kalan_hak < p.seans_sayisi - p.yapilan_seans ? <span className="sonuk"> · {p.seans_sayisi - p.yapilan_seans - p.kalan_hak} seans hak dışı</span> : null}</div></div>
        <div><label>Yanıt</label><div className="ds-inp">{p.yanit ? YANIT[p.yanit] : <span className="sonuk">kür sonunda</span>}</div></div>
      </div>
      <div className="ds-ozet6" style={{ gridTemplateColumns: 'repeat(6,1fr)' }}>
        <div><span>Seans</span><b>{p.yapilan_seans} / {p.seans_sayisi}</b><div className="ds-bar" style={{ margin: '3px 0 0' }}><i style={{ width: `${p.seans_sayisi ? Math.min(100, p.yapilan_seans / p.seans_sayisi * 100) : 0}%`, background: 'var(--ok)' }} /></div></div>
        <div><span>VAS</span><b>{p.vas_ilk ?? '—'} → {p.vas_son ?? '—'}</b><i>ilk → son seans</i></div>
        <div><span>Devamsızlık</span><b className={p.devamsiz >= 3 ? 'ds-kir' : ''}>{p.devamsiz}</b></div>
        <div><span>Uygulama</span><b>{k.uygulamalar.length}</b><i>{k.uygulamalar.reduce((a, u) => a + u.sureDk, 0)} dk / seans</i></div>
        <div><span>Ölçek</span><b>{k.olcekler.length}</b><i>{k.olcekler.filter(o => o.asama === 3).length} kür sonu</i></div>
        <div><span>Planlı seans</span><b>{k.seanslar.filter(s => s.durum === 1).length}</b></div>
      </div>
      <div className="ka-sekmeler">
        {([['uyg', `Uygulamalar (${k.uygulamalar.length})`], ['seans', `Seans Takvimi (${k.seanslar.length})`], ['egz', `Egzersiz (${k.egzersizler.length})`], ['takip', `Takip & Ölçekler (${k.olcekler.length})`], ['gunluk', `Günlük (${k.gunluk.length})`]] as [Sekme, string][])
          .map(([s, ad]) => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{ad}</div>)}
      </div>

      {sekme === 'uyg' && (
        <div className="ds-grp ds-grp-ic">
          {ara.acik && (
            <div className="ds-islem-ara">
              <div className="ds-arac"><b>Uygulama ekle</b>
                <input autoFocus placeholder="SUT kodu / ad ara…" value={ara.q} onChange={e => void araYap(e.target.value)} style={{ minWidth: 220 }} />
                <label className="sonuk">Süre <input value={ara.sure} onChange={e => setAra(a => ({ ...a, sure: e.target.value }))} style={{ width: 40 }} /></label>
                <label className="sonuk">Parametre <input value={ara.parametre} onChange={e => setAra(a => ({ ...a, parametre: e.target.value }))} style={{ width: 140 }} placeholder="1 MHz · 1,5 W/cm²" /></label>
                <label className="sonuk">Cihaz <input value={ara.cihaz} onChange={e => setAra(a => ({ ...a, cihaz: e.target.value }))} style={{ width: 80 }} placeholder="US-2" /></label>
                <label className="sonuk">Serbest ad <input value={ara.ad} onChange={e => setAra(a => ({ ...a, ad: e.target.value }))} style={{ width: 140 }} placeholder="Hotpack" /></label>
                <button className="d onay" disabled={!ara.ad} onClick={() => void uygulamaEkle(null, ara.ad)}>Ekle (serbest)</button>
                <button className="d" onClick={() => setAra(a => ({ ...a, acik: false }))}>Kapat</button></div>
              <div className="ds-dg" style={{ maxHeight: 200, overflowY: 'auto' }}><table>
                <thead><tr><th>SUT</th><th>Uygulama</th><th /></tr></thead>
                <tbody>{ara.sonuc.map(x => <tr key={x.id}><td className="sonuk">{x.sutKodu}</td><td>{x.ad}</td><td><button className="d onay" onClick={() => void uygulamaEkle(x.id)}>Ekle</button></td></tr>)}
                  {ara.sonuc.length === 0 && <tr><td colSpan={3} className="sonuk">Sonuç yok - hizmet kartında "FTR uygulaması" işaretli (ya da SUT 9.xx) hizmetler listelenir; serbest ad ile de eklenebilir.</td></tr>}</tbody>
              </table></div>
            </div>
          )}
          <div className="ds-dg"><table className="ds-plan">
            <thead><tr><th className="orta">#</th><th>SUT · uygulama</th><th>Bölge</th><th className="orta">Süre</th><th>Parametre</th><th>Cihaz / kabin</th><th className="orta">Seans</th><th>Not</th><th /></tr></thead>
            <tbody>
              {k.uygulamalar.map(u => <tr key={u.id}><td className="orta sonuk">{u.sira}</td><td>{u.sutKodu ? <span className="sonuk">{u.sutKodu} · </span> : ''}{u.ad}</td><td>{u.bolgeMetin || p.bolge_adi}</td><td className="orta">{u.sureDk} dk</td><td>{u.parametre || '—'}</td><td>{u.cihazAd || p.kabin_adi || '—'}</td><td className="orta">{u.seansBas}–{u.seansBit ?? p.seans_sayisi}</td><td>{u.notMetin}</td>
                <td className="ds-satir-arac">{yazar && <button className="d" onClick={() => void uygulamaSil(u.id)}>✖</button>}</td></tr>)}
              {k.uygulamalar.length === 0 && <tr><td colSpan={9} className="sonuk">Uygulama yok - "＋ Uygulama (SUT)" ile ekleyin; seans açılınca bu liste seansa kopyalanır.</td></tr>}
              {k.uygulamalar.length > 0 && <tr className="grup"><td colSpan={3}>Seans paketi · {k.uygulamalar.length} uygulama</td><td className="orta">≈ {k.uygulamalar.reduce((a, u) => a + u.sureDk, 0)} dk</td><td colSpan={5} className="sonuk">SUT paket: uygulamalar seans paketi içinde, ayrı ücretlenmez</td></tr>}
            </tbody>
          </table></div>
          <div className="ds-ic sonuk">Kontrendikasyon uyarısı hasta özet verisinden (kalp pili/TENS, gebelik-malignite/US, duyu kaybı/hotpack) — Tıbbi Özet'e girilen komorbiditeler seans ekranında rozet olarak görünür.</div>
        </div>
      )}

      {sekme === 'seans' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-gb">Seans takvimi <span className="ds-sp sonuk">planlı seans hasta gelince açılır; gelmeyen seans yakılmaz, program uzar</span></div>
          <div className="ds-dg"><table>
            <thead><tr><th className="orta">Seans</th><th>Tarih</th><th className="orta">Saat</th><th>Fizyoterapist · kabin</th><th className="orta">Uygulama</th><th className="orta">VAS önce → sonra</th><th className="orta">Süre</th><th>Durum</th><th /></tr></thead>
            <tbody>
              {k.seanslar.map(s => <tr key={s.id} className={s.durum === 4 || s.durum === 5 ? 'soluk' : ''}>
                <td className="orta">{s.sira}</td><td>{tarihYaz(s.tarih)}</td><td className="orta">{s.saat}</td><td>{[s.fizyoterapist, s.kabin].filter(Boolean).join(' · ') || '—'}</td>
                <td className="orta">{s.uygulamaSayisi ? `${s.yapilanUygulama}/${s.uygulamaSayisi}` : '—'}</td><td className="orta">{s.vasOnce ?? '—'} → {s.vasSonra ?? '—'}</td><td className="orta">{s.durum === 3 || s.durum === 6 ? `${s.sureDk} dk` : '—'}</td>
                <td><span className={`rozet ${SEANS[s.durum] ?? 'gri'}`}>{s.durumAdi}{s.sira === p.ara_degerlendirme_seans ? ' · ara değ.' : ''}</span></td>
                <td className="ds-satir-arac"><button className="d" onClick={() => git(`/ftr-seans/${s.id}`, { state: { geri: geriBurasi, ustGeri: geri } })}>{s.durum === 2 ? '🏃 Devam' : 'Aç'}</button></td></tr>)}
              {k.seanslar.length === 0 && <tr><td colSpan={9} className="sonuk">Seans yok. "🗓 Seansları Planla" sıklığa göre takvimi üretir; "🏃 Bugünkü Seans" ilk seansı açar.</td></tr>}
            </tbody>
          </table></div>
        </div>
      )}

      {sekme === 'egz' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-gb">Egzersiz programı <span className="ds-sp sonuk">klinik + ev · aşamaya göre</span></div>
          <div className="ds-dg"><table>
            <thead><tr><th className="orta">#</th><th>Egzersiz</th><th>Set × tekrar</th><th>Yer</th><th className="orta">Aşama</th><th>Not</th></tr></thead>
            <tbody>
              {k.egzersizler.map(e => <tr key={e.id}><td className="orta sonuk">{e.sira}</td><td>{e.ad}</td><td>{e.setTekrar}</td><td>{YER[e.yer]}</td><td className="orta">{e.asamaBas}–{e.asamaBit ?? p.seans_sayisi}</td><td>{e.notMetin}</td></tr>)}
              {k.egzersizler.length === 0 && <tr><td colSpan={6} className="sonuk">Egzersiz yok - program kartını düzenleyip "Egzersiz Programı" detayına ekleyin.</td></tr>}
            </tbody>
          </table></div>
          <div className="ds-arac">{yazar && <button className="d" onClick={() => git(`/ftr-program-kart/${p.id}?geri=${encodeURIComponent(geriBurasi)}`)}>✎ Egzersiz ekle / düzenle</button>}<span className="ds-sp sonuk">Ev programı PDF ve hasta portalı sonraki sürümde.</span></div>
        </div>
      )}

      {sekme === 'takip' && (
        <div className="ds-odo-alan" style={{ gridTemplateColumns: '1fr 1fr' }}>
          <div className="ds-sol">
            <div className="ds-grp ds-grp-ic"><div className="ds-gb">VAS seyri (seans öncesi → sonrası)</div>
              <div className="ds-dg"><table><thead><tr><th className="orta">Seans</th><th>Tarih</th><th className="orta">Önce</th><th className="orta">Sonra</th><th>Eğilim</th></tr></thead>
                <tbody>{vasSeyri.map(s => <tr key={s.id}><td className="orta">{s.sira}</td><td>{tarihYaz(s.tarih)}</td><td className="orta">{s.vasOnce ?? '—'}</td><td className="orta">{s.vasSonra ?? '—'}</td>
                  <td><div className="ds-bar" style={{ margin: 0, width: 120 }}><i style={{ width: `${((s.vasSonra ?? s.vasOnce ?? 0) / 10) * 100}%`, background: (s.vasSonra ?? 10) <= 3 ? 'var(--ok)' : (s.vasSonra ?? 10) <= 6 ? '#d9a12b' : 'var(--hata)' }} /></div></td></tr>)}
                  {vasSeyri.length === 0 && <tr><td colSpan={5} className="sonuk">Henüz VAS kaydı yok (seans ekranından girilir).</td></tr>}</tbody></table></div>
            </div>
          </div>
          <div className="ds-sag">
            <div className="ds-grp"><div className="ds-gb">Ölçekler <span className="ds-sp sonuk">kür başı / ara / kür sonu</span></div>
              <div className="ds-dg"><table><thead><tr><th>Ölçek</th><th>Aşama</th><th>Tarih</th><th className="sag">Skor</th><th className="sag">Hedef</th></tr></thead>
                <tbody>{k.olcekler.map(o => <tr key={o.id}><td>{o.olcekAdi}</td><td><span className="rozet gri">{o.asamaAdi}</span></td><td>{tarihYaz(o.tarih)}</td><td className="sag">{o.skor}</td><td className="sag">{o.hedef ?? '—'}</td></tr>)}
                  {k.olcekler.length === 0 && <tr><td colSpan={5} className="sonuk">Ölçek yok - "📈 Ölçek Gir" (kür başı + kür sonu zorunlu: klinik kalite göstergesi).</td></tr>}</tbody></table></div>
              <div className="ds-arac"><button className="d bir" onClick={() => git(`/ftr-olcek/yeni?hastaId=${p.hasta_id}&programId=${p.id}&geri=${encodeURIComponent(geriBurasi)}`)}>📈 Ölçek gir</button>
                {p.durum === 3 && <span className="rozet uyari">Ara değerlendirme bekleniyor: uzman ölçek + karar</span>}</div>
            </div>
          </div>
        </div>
      )}

      {sekme === 'gunluk' && (
        <div className="ds-grp ds-grp-ic">
          <div className="ds-dg"><table><thead><tr><th>Zaman</th><th>Kullanıcı</th><th>İşlem</th><th>Bilgi</th></tr></thead>
            <tbody>{k.gunluk.map((g, i) => <tr key={i}><td>{tarihSaat(g.tarih)}</td><td>{g.kullanici || '—'}</td><td>{g.tabloId === 1185 ? 'seans' : 'program'} · {['sildi', 'ekledi', 'değiştirdi'][g.islemTipi] ?? g.islemTipi}</td><td className="sonuk" style={{ whiteSpace: 'normal', maxWidth: 500 }}>{g.bilgi.replace(/[{}"]/g, '').slice(0, 240)}</td></tr>)}
              {k.gunluk.length === 0 && <tr><td colSpan={4} className="sonuk">Kayıt yok.</td></tr>}</tbody></table></div>
        </div>
      )}
    </Perde>
  );
}
