import { useCallback, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { DisIslemSecenegi, DisSeansKarti as Kart } from '../../api/uclar/dis';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { TarafSecici } from '../../bilesenler/TarafArama';
import { para, tarihSaat } from '../../bilesenler/bicim';

/**
 * SEANS KARTI — mockup `Ekranlar/Dis Klinigi/dis_seans_kaydi.html` (Uygulama
 * sekmesi "yapılan işlemler listesi" olarak yeniden çizildi).
 *
 * Bir seansta birden çok işlem: her satır bir plan satırına (ya da plan dışı
 * hizmete) bağlı; "bu seansta tamamlandı" işareti seans bitince satırı
 * yapıldı yapar (ücret + odontogram), işaretsiz plan satırı bir seans ilerler.
 * Uygulama notu / çalışma boyu / komplikasyon İŞLEME yazılır (708); hastaya
 * talimat ve sonraki seans SEANSA.
 *
 * Modal: arkada Seanslar listesi; Esc / Kapat geldiği yere döner.
 */
const KURAL: Record<number, string> = { 1: 'Tamamlanınca', 2: 'Seans başına oran', 3: 'Adet' };
const SATIR: Record<number, [string, string]> = { 0: ['Plan dışı', 'uyari'], 1: ['Planlı', 'gri'], 2: ['Sürüyor', 'mavi'], 3: ['Yapıldı', 'ok'], 4: ['İptal', 'hata'], 5: ['Ertelendi', 'uyari'] };
type Sekme = 'islem' | 'anestezi' | 'sarf' | 'ucret';

export function DisSeansKarti() {
  const { id: param } = useParams();
  const git = useNavigate();
  const konum = useLocation();
  const { yetki } = useOturum();
  const durum = konum.state as { geri?: string; ustGeri?: string } | null;
  const geri = durum?.geri ?? '/dis-seans';
  const ustGeri = durum?.ustGeri;
  const kapat = useCallback(() => git(geri, ustGeri ? { state: { geri: ustGeri } } : undefined), [git, geri, ustGeri]);
  useEffect(() => { const f = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() }; window.addEventListener('keydown', f); return () => window.removeEventListener('keydown', f) }, [kapat]);

  const yeni = param === 'yeni';
  const id = yeni ? 0 : Number(param ?? 0);
  const [kart, setKart] = useState<Kart | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<Sekme>('islem');
  const [secili, setSecili] = useState<number | null>(null);
  const [taslak, setTaslak] = useState<Record<string, string>>({});
  const [seansTaslak, setSeansTaslak] = useState<Record<string, string>>({});
  const [planSecim, setPlanSecim] = useState(false);
  const [hizmetAra, setHizmetAra] = useState<{ acik: boolean; q: string; sonuc: DisIslemSecenegi[]; disNo: string; yz: string }>({ acik: false, q: '', sonuc: [], disNo: '', yz: '' });
  const [tik, setTik] = useState(0);
  const [yeniHasta, setYeniHasta] = useState<{ id: number; ad: string } | null>(null);

  const yukle = useCallback(async () => {
    if (!id) return;
    try {
      const k = await api.disSeansKart(id);
      setKart(k); setHata(null);
      setSecili(s => s ?? k.islemler[0]?.id ?? null);
      setSeansTaslak({ uygulamaNotu: k.seans.uygulamaNotu, komplikasyon: k.seans.komplikasyon, hastayaTalimat: k.seans.hastayaTalimat, sonrakiPlan: k.seans.sonrakiPlan,
        anesteziTur: k.seans.anesteziTur, anesteziIlac: k.seans.anesteziIlac, anesteziDoz: k.seans.anesteziDoz, sterilizasyonPaket: k.seans.sterilizasyonPaket });
    } catch (h) { setHata(hataMetni(h)) }
  }, [id]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => { const t = setInterval(() => setTik(x => x + 1), 1000); return () => clearInterval(t) }, []);

  const s = kart?.seans;
  const sec = useMemo(() => kart?.islemler.find(i => i.id === secili) ?? null, [kart, secili]);
  useEffect(() => { if (sec) setTaslak({ uygulamaNotu: sec.uygulamaNotu, calismaBoyu: sec.calismaBoyu, komplikasyon: sec.komplikasyon, sonrakiPlan: sec.sonrakiPlan }) }, [sec?.id]); // eslint-disable-line react-hooks/exhaustive-deps

  const sayac = useMemo(() => {
    if (!s) return '';
    const bas = new Date(s.baslangic).getTime();
    const son = s.bitis ? new Date(s.bitis).getTime() : new Date(kart!.simdi).getTime() + tik * 1000;
    const sn = Math.max(0, Math.floor((son - bas) / 1000));
    return `${String(Math.floor(sn / 3600)).padStart(2, '0')}:${String(Math.floor((sn % 3600) / 60)).padStart(2, '0')}:${String(sn % 60).padStart(2, '0')}`;
  }, [s, kart, tik]);

  const acik = s?.durum === 1;
  const yazar = yetki('dis.seans') && acik;

  // ---- yazma
  const islemEkle = async (g: { planSatirId?: number; hizmetId?: number; disNo?: number; yuzeyler?: string }) => {
    await guvenli(async () => { const y = await api.disSeansIslemEkle(id, g); setPlanSecim(false); setHizmetAra(a => ({ ...a, acik: false })); await yukle(); setSecili(y.id); });
  };
  const islemGuncelle = async (iid: number, g: Record<string, unknown>) => { await guvenli(async () => { await api.disSeansIslemGuncelle(iid, g); await yukle(); }) };
  const islemSil = async (iid: number) => { if (!await onay('İşlem satırı silinsin mi?')) return; await guvenli(async () => { await api.disSeansIslemSil(iid); if (secili === iid) setSecili(null); await yukle(); }) };
  const seansKaydet = async (alanlar: Record<string, string>) => { await guvenli(async () => { await api.disSeansGuncelle(id, alanlar); mesaj('Kaydedildi.'); await yukle(); }) };
  const bitir = async () => {
    if (!kart) return;
    const tamam = kart.islemler.filter(i => i.tamamlandi).length, suren = kart.islemler.filter(i => !i.tamamlandi && i.planSatirId).length;
    if (!await onay(`Seans bitirilsin mi? ${tamam} işlem yapıldı olur (ücret + odontogram), ${suren} plan satırı bir seans ilerler.`)) return;
    await guvenli(async () => {
      const y = await api.disSeansBitir(id);
      mesaj(`Seans bitti · ${y.yapilan} tamamlandı · ${y.ilerleyen} ilerledi${y.ucret ? ` · ücret ${para.format(y.ucret)}` : ''}${y.uyari ? ` — ${y.uyari}` : ''}`);
      await yukle();
    });
  };
  const hizmetAraYap = async (q: string) => { setHizmetAra(a => ({ ...a, q })); try { const y = await api.disIslemAra(q); setHizmetAra(a => ({ ...a, sonuc: y.satirlar })) } catch { /* sessiz */ } };
  const yeniSeans = async () => {
    if (!yeniHasta) { mesaj('Hasta seçin.'); return }
    await guvenli(async () => { const y = await api.disSeansAc({ hastaId: yeniHasta.id }); if (y.basvuruAcildi) mesaj(`Başvuru ${y.basvuruNo} açıldı (ödeyen: ${y.odeyen}).`); git(`/dis-seans/${y.id}`, { state: { geri } }); });
  };

  const Perde = ({ children, baslik }: { children: ReactNode; baslik: ReactNode }) => (
    <div className="kaperde" onClick={kapat}>
      <div className="kawin tam" onClick={e => e.stopPropagation()}>
        <div className="kabas">{baslik}<span className="kapt">Esc ile kapanır</span><button className="kabas-dugme" onClick={kapat} title="Kapat">✖</button></div>
        <div className="kagov ds-kagov">{children}</div>
      </div>
    </div>
  );

  if (yeni) return (
    <Perde baslik={<span>🪑 Yeni Seans</span>}>
      <div className="ds-hdr" style={{ padding: 12 }}>
        <div><label>Hasta</label><TarafSecici etiket="" deger={yeniHasta?.ad ?? ''} kaynaklar={['hasta']} bosMetin="Hasta seçin…" onSec={h => setYeniHasta({ id: h.id, ad: h.unvan })} onTemizle={() => setYeniHasta(null)} /></div>
        <div><label>&nbsp;</label><button className="d bir" onClick={() => void yeniSeans()}>🪑 Seans Aç</button></div>
      </div>
      <div className="ds-ic sonuk">Randevudan açmak için Günlük Akış'ı kullanın: ünit, hekim, başvuru ve plan satırı otomatik gelir. Bugün açık başvuru yoksa açılır.</div>
    </Perde>
  );
  if (hata) return <Perde baslik={<span>🪑 Seans</span>}><div className="hata-kutusu">{hata}</div></Perde>;
  if (!kart || !s) return <Perde baslik={<span>🪑 Seans</span>}><span className="sonuk">Yükleniyor…</span></Perde>;

  const ucretlenen = kart.islemler.reduce((a, i) => a + (i.tamamlandi ? i.net : i.ucretKurali === 2 && i.planSatirId ? i.net / Math.max(1, i.seansSayisi) : 0), 0);
  const bakiye = kart.planOzet ? kart.planOzet.yapilan - kart.planOzet.tahsil : 0;

  return (
    <Perde baslik={<>
      <span>🪑 Seans Kaydı — {s.hasta}{s.yas != null ? ` · ${s.yas}` : ''} · {kart.islemler.length} işlem</span>
      <span className="ds-kabas-yol">{s.unit || 'ünit —'} · {s.hekim || 'hekim —'} · {tarihSaat(s.baslangic)} · seans {s.id}{s.planNo ? ` · plan ${s.planNo}` : ''}{s.belgeNo ? ` · başvuru ${s.belgeNo}` : ''}</span>
      <span className={`rozet ${acik ? 'mavi' : s.durum === 2 ? 'ok' : 'gri'}`}>{acik ? 'Açık' : s.durum === 2 ? 'Bitti' : 'İptal'}</span>
    </>}>
      <div className="ds-arac ds-kart-arac">
        {yazar && <button className="d onay" onClick={() => void bitir()} disabled={!yetki('dis.seans.bitir') && false}>✔ Seansı Bitir</button>}
        <button className="d" onClick={() => git(`/dis-hasta/${s.hastaId}`, { state: { geri: konum.pathname, ustGeri: geri } })}>🦷 Odontogram / Plan</button>
        {yazar && <button className="d" title={sec?.labGerekir ? `Seçili işlem için (${sec.disNo}) lab iş emri` : 'Bu hasta adına lab iş emri'}
          onClick={() => git(`/dis-lab-isemri/yeni?hastaId=${s.hastaId}&hastaAd=${encodeURIComponent(s.hasta)}${s.hekimId ? `&hekimId=${s.hekimId}` : ''}`
            + (sec?.planSatirId ? `&planSatirId=${sec.planSatirId}` : '') + (sec?.disNo ? `&disNolar=${sec.disNo}` : '')
            + `&geri=${encodeURIComponent(konum.pathname)}`)}>🧪 Lab İş Emri{sec?.labGerekir ? ` (${sec.disNo})` : ''}</button>}
        <button className="d" onClick={() => git(`/dis-lab-isemri?hastaId=${s.hastaId}&geri=${encodeURIComponent(konum.pathname)}`)}>🧪 Lab İşleri</button>
        <span className="rozet gri" title="Seans süresi">⏱ {sayac}</span>
        <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        <button className="d ds-sp" onClick={kapat}>✖ Kapat</button>
      </div>
      <div className="ds-hdr" style={{ padding: '8px 10px' }}>
        <div><label>Hasta</label><div className="ds-inp big">{s.hasta}{s.alerji && s.alerji.split(', ').map(a => <span key={a} className="rozet hata">{a}</span>)}</div></div>
        <div><label>Bu seans</label><div className="ds-inp">{kart.islemler.length ? kart.islemler.map(i => `${i.disNo || ''} ${i.islem}${i.planSatirId ? ` ${i.seansNo}/${i.seansSayisi}` : ''}`.trim()).join(' + ') : <span className="sonuk">işlem eklenmedi</span>}</div></div>
        <div><label>Önceki seans notu</label><div className="ds-inp">{s.oncekiNot ? s.oncekiNot.replace('T', ' ').slice(0, 160) : <span className="sonuk">{s.oncekiSeans ? `${s.oncekiSeans} önceki seans` : 'ilk seans'}</span>}</div></div>
        <div><label>Başvuru / plan</label><div className="ds-inp">{s.belgeNo ? <span className="rozet ok">başvuru {s.belgeNo}</span> : <span className="rozet uyari">başvuru yok</span>}{s.planNo ? <span className="rozet mavi">{s.planNo}</span> : <span className="rozet gri">plan yok</span>}</div></div>
      </div>

      <div className="ka-sekmeler">
        {([['islem', `Yapılan İşlemler (${kart.islemler.length})`], ['anestezi', 'Anestezi & Seans Notu'], ['sarf', `Malzeme & Sarf (${kart.sarf.length})`], ['ucret', 'Ücret & Tahsilat']] as [Sekme, string][])
          .map(([k, ad]) => <div key={k} className={`ka-sekme${sekme === k ? ' on' : ''}`} onClick={() => setSekme(k)}>{ad}</div>)}
      </div>

      {sekme === 'islem' && (
        <div className="ds-odo-alan" style={{ gridTemplateColumns: 'minmax(0,1fr) 360px' }}>
          <div className="ds-sol">
            <div className="ds-grp ds-grp-ic">
              <div className="ds-gb">Yapılan işlemler <span className="ds-sp sonuk">seans → plan satırı 1:N · her satır bir işlem</span></div>
              <div className="ds-dg"><table className="ds-plan">
                <thead><tr><th className="orta">#</th><th className="orta">Diş</th><th className="orta">Yüzey</th><th>İşlem (plan satırı)</th><th className="orta">Seans</th><th className="orta">Bu seansta tamamlandı</th><th>Ücretlendirme</th><th className="sag">Ücret</th><th className="orta">Durum</th><th /></tr></thead>
                <tbody>
                  {kart.islemler.map((i, n) => (
                    <tr key={i.id} className={secili === i.id ? 'dis-sec' : ''} onClick={() => setSecili(i.id)}>
                      <td className="orta sonuk">{n + 1}</td>
                      <td className="orta"><b>{i.disNo || '—'}</b></td><td className="orta">{i.yuzeyler || '—'}</td>
                      <td>{secili === i.id ? '▸ ' : ''}{i.sutKodu || i.kod ? <span className="sonuk">{i.sutKodu || i.kod} · </span> : ''}{i.islem}
                        {i.planSatirId ? <span className="rozet mavi" style={{ marginLeft: 4 }}>{i.planNo} / {i.planSira}</span> : <span className="rozet uyari" style={{ marginLeft: 4 }}>plan dışı</span>}
                        {i.labGerekir && <span className="rozet gri" style={{ marginLeft: 4 }}>lab</span>}</td>
                      <td className="orta">{i.planSatirId ? `${i.seansNo}/${i.seansSayisi}` : '—'}</td>
                      <td className="orta"><input type="checkbox" checked={i.tamamlandi} disabled={!yazar || i.satirDurum === 3} onChange={e => void islemGuncelle(i.id, { tamamlandi: e.target.checked })} onClick={e => e.stopPropagation()} /></td>
                      <td>{i.planSatirId ? KURAL[i.ucretKurali] : 'Adet'}</td>
                      <td className="sag">{i.ucret ? para.format(i.ucret) : i.planSatirId ? para.format(i.ucretKurali === 2 ? i.net / Math.max(1, i.seansSayisi) : i.net) : '—'}</td>
                      <td className="orta"><span className={`rozet ${i.satirDurum === 3 || i.ucret ? 'ok' : i.tamamlandi ? 'ok' : SATIR[i.satirDurum]?.[1] ?? 'gri'}`}>{i.ucret ? 'Ücretlendi' : i.satirDurum === 3 ? 'Yapıldı' : i.tamamlandi ? 'Tamamlanacak' : i.planSatirId ? (i.seansNo > 1 ? 'Sürüyor' : 'Başladı') : 'Plansız'}</span></td>
                      <td className="ds-satir-arac">{yazar && !i.ucret && <button className="d" onClick={e => { e.stopPropagation(); void islemSil(i.id) }}>✖</button>}</td>
                    </tr>
                  ))}
                  {kart.islemler.length === 0 && <tr><td colSpan={10} className="sonuk">İşlem yok - plan satırından ya da plan dışı hizmetten ekleyin.</td></tr>}
                  {kart.islemler.length > 0 && <tr className="grup"><td colSpan={7}>Bu seans · {kart.islemler.length} işlem · tamamlanan {kart.islemler.filter(i => i.tamamlandi).length} · süren {kart.islemler.filter(i => !i.tamamlandi && i.planSatirId).length}</td><td className="sag">{para.format(ucretlenen)}</td><td colSpan={2} /></tr>}
                </tbody>
              </table></div>
              {yazar && (
                <div className="ds-arac">
                  <button className="d bir" onClick={() => setPlanSecim(p => !p)}>＋ Plan satırından ekle ({kart.acikSatirlar.length})</button>
                  <button className="d" onClick={() => { setHizmetAra(a => ({ ...a, acik: true })); void hizmetAraYap('') }}>＋ Plan dışı işlem (SUT)</button>
                  <span className="ds-sp sonuk">"Bu seansta tamamlandı" → seans bitince yapıldı + başvuru satırı + odontogram; işaretsiz plan satırı bir seans ilerler.</span>
                </div>
              )}
              {planSecim && (
                <div className="ds-dg" style={{ borderTop: '1px solid var(--cizgi2)', maxHeight: 220, overflowY: 'auto' }}><table>
                  <thead><tr><th>Plan</th><th className="orta">Faz</th><th className="orta">Diş</th><th>İşlem</th><th className="orta">Seans</th><th className="sag">Net</th><th /></tr></thead>
                  <tbody>
                    {kart.acikSatirlar.map(x => <tr key={x.id}><td>{x.planNo} / {x.sira}</td><td className="orta">{x.faz}</td><td className="orta">{x.disNo || '—'}{x.yuzeyler ? ' ' + x.yuzeyler : ''}</td><td>{x.islem}</td><td className="orta">{x.yapilanSeans}/{x.seansSayisi}</td><td className="sag">{para.format(x.net)}</td>
                      <td><button className="d onay" onClick={() => void islemEkle({ planSatirId: x.id })}>Ekle</button></td></tr>)}
                    {kart.acikSatirlar.length === 0 && <tr><td colSpan={7} className="sonuk">Açık plan satırı yok.</td></tr>}
                  </tbody>
                </table></div>
              )}
              {hizmetAra.acik && (
                <div className="ds-islem-ara">
                  <div className="ds-arac"><b>Plan dışı işlem</b>
                    <input autoFocus placeholder="İşlem ara…" value={hizmetAra.q} onChange={e => void hizmetAraYap(e.target.value)} style={{ minWidth: 240 }} />
                    <label className="sonuk">Diş <input value={hizmetAra.disNo} onChange={e => setHizmetAra(a => ({ ...a, disNo: e.target.value }))} style={{ width: 50 }} /></label>
                    <label className="sonuk">Yüzey <input value={hizmetAra.yz} onChange={e => setHizmetAra(a => ({ ...a, yz: e.target.value }))} style={{ width: 60 }} /></label>
                    <button className="d" onClick={() => setHizmetAra(a => ({ ...a, acik: false }))}>Kapat</button></div>
                  <div className="ds-dg" style={{ maxHeight: 200, overflowY: 'auto' }}><table>
                    <thead><tr><th>Kod</th><th>İşlem</th><th className="sag">Fiyat</th><th /></tr></thead>
                    <tbody>{hizmetAra.sonuc.map(x => <tr key={x.id}><td className="sonuk">{x.kod}</td><td>{x.ad}</td><td className="sag">{para.format(x.fiyat)}</td>
                      <td><button className="d onay" onClick={() => void islemEkle({ hizmetId: x.id, disNo: Number(hizmetAra.disNo) || 0, yuzeyler: hizmetAra.yz })}>Ekle</button></td></tr>)}</tbody>
                  </table></div>
                  <div className="ds-ic sonuk">Plan dışı işlem ücretlenmez; ücret için plana bağlanmalı (hasta kartı › plan satırı ekle).</div>
                </div>
              )}
            </div>

            {sec && (
              <div className="ds-grp ds-grp-ic ds-plan-alt">
                <div className="ds-gb ds-gb-duz">Seçili işlem — {sec.disNo || '—'} · {sec.islem}{sec.planSatirId ? ` · seans ${sec.seansNo}/${sec.seansSayisi}` : ''} <span className="ds-sp sonuk">uygulama ayrıntısı işlem satırına yazılır</span></div>
                <div className="ds-hdr" style={{ padding: '4px 10px 8px', gridTemplateColumns: '1fr 1fr' }}>
                  <div style={{ gridColumn: '1 / 3' }}><label>Uygulama notu</label><textarea rows={3} style={{ width: '100%' }} value={taslak.uygulamaNotu ?? ''} disabled={!yazar} onChange={e => setTaslak(t => ({ ...t, uygulamaNotu: e.target.value }))} /></div>
                  <div><label>Çalışma boyu (mm) · kanal bazlı</label><input style={{ width: '100%' }} value={taslak.calismaBoyu ?? ''} disabled={!yazar} placeholder="MB 20,5 · DB 20 · P 21,5" onChange={e => setTaslak(t => ({ ...t, calismaBoyu: e.target.value }))} /></div>
                  <div><label>Komplikasyon</label><input style={{ width: '100%' }} value={taslak.komplikasyon ?? ''} disabled={!yazar} placeholder="Yok · eğe kırığı / perforasyon / taşkın irrigasyon" onChange={e => setTaslak(t => ({ ...t, komplikasyon: e.target.value }))} /></div>
                  <div style={{ gridColumn: '1 / 3' }}><label>Sonraki seans planı (bu satır)</label><input style={{ width: '100%' }} value={taslak.sonrakiPlan ?? ''} disabled={!yazar} onChange={e => setTaslak(t => ({ ...t, sonrakiPlan: e.target.value }))} /></div>
                </div>
                {yazar && <div className="ds-arac"><button className="d onay" onClick={() => void islemGuncelle(sec.id, taslak)}>💾 İşlemi kaydet</button></div>}
              </div>
            )}
          </div>

          <div className="ds-sag">
            <div className="ds-grp"><div className="ds-gb">Ekip & süre</div>
              <div className="ds-ic">
                <div><span className="sonuk">Hekim</span> · {s.hekim || '—'} <span className="sonuk">(uygulayan · prim)</span></div>
                <div><span className="sonuk">Asistan</span> · {s.asistan || '—'}</div>
                <div><span className="sonuk">Başlangıç / bitiş</span> · {tarihSaat(s.baslangic)} — {s.bitis ? tarihSaat(s.bitis) : <span className="sonuk">devam</span>} · {s.bitis ? `${s.sureDk} dk` : sayac}</div>
                <div><span className="sonuk">Ünit</span> · {s.unit || '—'}{s.sterilizasyonPaket ? ` · sterilizasyon ${s.sterilizasyonPaket}` : ''}</div>
              </div>
            </div>
            <div className="ds-grp"><div className="ds-gb">Seans notu & hastaya talimat <span className="ds-sp sonuk">seans geneli</span></div>
              <div className="ds-ic">
                <label className="sonuk">Hastaya talimat</label>
                <textarea rows={2} style={{ width: '100%' }} value={seansTaslak.hastayaTalimat ?? ''} disabled={!yazar} onChange={e => setSeansTaslak(t => ({ ...t, hastayaTalimat: e.target.value }))} />
                <label className="sonuk">Sonraki seans</label>
                <input style={{ width: '100%' }} value={seansTaslak.sonrakiPlan ?? ''} disabled={!yazar} placeholder="10.09 10:00 · Ünit 1 · 26 dolum · 60 dk" onChange={e => setSeansTaslak(t => ({ ...t, sonrakiPlan: e.target.value }))} />
                {yazar && <div style={{ marginTop: 6 }}><button className="d onay" onClick={() => void seansKaydet({ hastayaTalimat: seansTaslak.hastayaTalimat, sonrakiPlan: seansTaslak.sonrakiPlan })}>💾 Kaydet</button></div>}
              </div>
            </div>
            <div className="ds-grp"><div className="ds-gb">Kurallar</div>
              <div className="ds-ic sonuk">Tek seanslık iş plandan eklenince "tamamlandı" işaretli gelir; çok seanslıda son seans değilse işaretsiz. Ücretlenmiş satır silinmez. Bitirilen seans değiştirilmez.</div>
            </div>
          </div>
        </div>
      )}

      {sekme === 'anestezi' && (
        <div className="ds-grp" style={{ margin: 10 }}>
          <div className="ds-gb">Anestezi & seans notu</div>
          <div className="ds-hdr" style={{ padding: 10 }}>
            <div><label>Anestezi türü</label><input style={{ width: '100%' }} value={seansTaslak.anesteziTur ?? ''} disabled={!yazar} placeholder="İnfiltratif / rejyonel" onChange={e => setSeansTaslak(t => ({ ...t, anesteziTur: e.target.value }))} /></div>
            <div><label>İlaç</label><input style={{ width: '100%' }} value={seansTaslak.anesteziIlac ?? ''} disabled={!yazar} placeholder="Artikain %4 + epi 1:100k" onChange={e => setSeansTaslak(t => ({ ...t, anesteziIlac: e.target.value }))} /></div>
            <div><label>Doz</label><input style={{ width: '100%' }} value={seansTaslak.anesteziDoz ?? ''} disabled={!yazar} placeholder="1,7 mL × 1" onChange={e => setSeansTaslak(t => ({ ...t, anesteziDoz: e.target.value }))} /></div>
            <div><label>Saat</label><div className="ds-inp">{s.anesteziSaat ?? <span className="sonuk">ilaç kaydedilince</span>}</div></div>
            <div style={{ gridColumn: '1 / 3' }}><label>Seans notu (genel)</label><textarea rows={3} style={{ width: '100%' }} value={seansTaslak.uygulamaNotu ?? ''} disabled={!yazar} onChange={e => setSeansTaslak(t => ({ ...t, uygulamaNotu: e.target.value }))} /></div>
            <div><label>Komplikasyon (seans)</label><input style={{ width: '100%' }} value={seansTaslak.komplikasyon ?? ''} disabled={!yazar} onChange={e => setSeansTaslak(t => ({ ...t, komplikasyon: e.target.value }))} /></div>
            <div><label>Sterilizasyon paketi</label><input style={{ width: '100%' }} value={seansTaslak.sterilizasyonPaket ?? ''} disabled={!yazar} placeholder="#S-2609" onChange={e => setSeansTaslak(t => ({ ...t, sterilizasyonPaket: e.target.value }))} /></div>
          </div>
          {yazar && <div className="ds-arac"><button className="d onay" onClick={() => void seansKaydet(seansTaslak)}>💾 Kaydet</button>
            {s.alerji && <span className="rozet hata">Alerji: {s.alerji} - reçetede kontrol edilir</span>}</div>}
        </div>
      )}

      {sekme === 'sarf' && (
        <div className="ds-grp" style={{ margin: 10 }}>
          <div className="ds-gb">Malzeme & sarf <span className="ds-sp sonuk">işlem seti (hizmet_sarf_seti) otomatik düşüm sonraki sürümde</span></div>
          <div className="ds-dg"><table>
            <thead><tr><th>Malzeme</th><th className="sag">Miktar</th><th>Birim</th><th className="orta">Kaynak</th><th className="sag">Maliyet</th></tr></thead>
            <tbody>
              {kart.sarf.map(f => <tr key={f.id}><td>{f.malzeme}</td><td className="sag">{f.miktar}</td><td>{f.birim}</td><td className="orta">{['', 'set', 'elle', 'barkod'][f.kaynak] ?? ''}</td><td className="sag">{para.format(f.maliyet)}</td></tr>)}
              {kart.sarf.length === 0 && <tr><td colSpan={5} className="sonuk">Sarf kaydı yok.</td></tr>}
              {kart.sarf.length > 0 && <tr className="grup"><td colSpan={4}>Toplam sarf</td><td className="sag">{para.format(kart.sarf.reduce((a, f) => a + f.maliyet, 0))}</td></tr>}
            </tbody>
          </table></div>
        </div>
      )}

      {sekme === 'ucret' && (
        <div className="ds-grp" style={{ margin: 10 }}>
          <div className="ds-gb">Ücret & tahsilat</div>
          <div className="ds-ozet6" style={{ gridTemplateColumns: 'repeat(4,1fr)', padding: 10 }}>
            <div><span>Bu seansın ücreti (bitince)</span><b>{para.format(ucretlenen)}</b></div>
            <div><span>Plan yapılan</span><b>{para.format(kart.planOzet?.yapilan ?? 0)}</b></div>
            <div><span>Tahsil</span><b>{para.format(kart.planOzet?.tahsil ?? 0)}</b></div>
            <div><span>Bakiye (yapılan − tahsil)</span><b className={bakiye > 0 ? 'ds-kir' : ''}>{para.format(bakiye)}</b></div>
          </div>
          <div className="ds-arac">
            {kart.planOzet?.odemePlaniId ? <button className="d" onClick={() => git(`/dis-odeme-plani/${kart.planOzet!.odemePlaniId}?geri=${encodeURIComponent(konum.pathname)}`)}>💳 Ödeme planı</button> : <span className="sonuk">ödeme planı yok</span>}
            {s.belgeId && <button className="d" onClick={() => git(`/basvuru/${s.belgeId}?geri=${encodeURIComponent(konum.pathname)}`)}>🧾 Başvuru (fiş / fatura)</button>}
            <span className="ds-sp sonuk">Ücret seans bitince başvuru satırına düşer (tür 19); tahsilat ve fiş kasa modülüyle.</span>
          </div>
        </div>
      )}
    </Perde>
  );
}
