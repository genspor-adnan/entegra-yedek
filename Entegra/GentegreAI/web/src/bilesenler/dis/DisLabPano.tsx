import { useCallback, useEffect, useMemo, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { DisLabPano as Pano, DisLabPanoKarti as Kart } from '../../api/uclar/dis';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay } from '../mesaj';
import { para, tarihSaat, tarihYaz } from '../bicim';

/**
 * LAB İŞ EMİRLERİ KANBAN (711) — mockup `Ekranlar/Dis Klinigi/dis_lab_kanban.html`.
 * Lab İş Emirleri listesinin "Kanban" ek görünümü. Kolon = `dis_lab_isemri.asama`
 * (2-4 tek "Labda" kolonunda rozetle), sürükle-bırak = aşama geçişi
 * (`POST /lab-isemri/{id}/asama`, geçmiş + log 1134). Kart rengi SLA'dan:
 * beklenen geçti kırmızı, 2 gün kaldı sarı. Sağda seçili kart + tek tık geçişler.
 */
const ASAMA: Record<number, [string, string]> = { 1: ['Ölçü bekliyor', 'gri'], 2: ['Gönderildi', 'mavi'], 3: ['Tasarım onayı', 'mor'], 4: ['Üretim', 'mavi'], 5: ['Geldi', 'uyari'], 6: ['Prova', 'uyari'], 7: ['Geri gönderildi', 'hata'], 8: ['Teslim edildi', 'ok'], 9: ['İptal', 'gri'] };
const TUR: Record<number, string> = { 1: 'Kron', 2: 'Köprü', 3: 'İmplant üstü', 4: 'Total protez', 5: 'Parsiyel protez', 6: 'Ortodonti apareyi', 7: 'Gece plağı', 8: 'Diğer' };
const OLCU: Record<number, string> = { 1: 'Geleneksel', 2: 'Dijital tarama' };
const KOLONLAR: { k: string; ad: string; alt: string; asamalar: number[]; sinif: string; hedef: number }[] = [
  { k: 'olcu',    ad: '1 · Ölçü bekliyor',     alt: 'klinikte',            asamalar: [1],       sinif: 'olcu',    hedef: 1 },
  { k: 'labda',   ad: '2 · Gönderildi / Labda', alt: 'üretim',             asamalar: [2, 3, 4], sinif: 'labda',   hedef: 2 },
  { k: 'tasarim', ad: '3 · Tasarım onayı',     alt: 'hekim onaylar',       asamalar: [3],       sinif: 'tasarim', hedef: 3 },
  { k: 'geldi',   ad: '4 · Geldi · prova',     alt: 'klinikte',            asamalar: [5, 6],    sinif: 'geldi',   hedef: 5 },
  { k: 'geri',    ad: '5 · Geri gönderildi',   alt: 'düzeltme',            asamalar: [7],       sinif: 'duzelt',  hedef: 7 },
  { k: 'teslim',  ad: '6 · Teslim edildi',     alt: 'son 30 gün · ücretlenir', asamalar: [8],   sinif: 'teslim',  hedef: 8 },
];
type Suzgec = 'acik' | 'geciken' | 'hafta' | 'bugun' | 'teslim';
type Gorunum = 'kanban' | 'lab' | 'kurye';

const gun = (a: string | null | undefined) => (a ? Math.ceil((new Date(String(a).slice(0, 10)).getTime() - new Date(new Date().toDateString()).getTime()) / 86400000) : null);

export function DisLabPano({ yenile }: { yenile?: number }) {
  const git = useNavigate();
  const konum = useLocation();
  const { yetki } = useOturum();
  const [pano, setPano] = useState<Pano | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [labId, setLabId] = useState<number | null>(null);
  const [hekimId, setHekimId] = useState<number | null>(null);
  const [suzgec, setSuzgec] = useState<Suzgec>('acik');
  const [gorunum, setGorunum] = useState<Gorunum>('kanban');
  const [ara, setAra] = useState('');
  const [secili, setSecili] = useState<number | null>(null);
  const [gecmis, setGecmis] = useState<{ asama: number; zaman: string; kullanici: string; not_: string }[]>([]);
  const [surukle, setSurukle] = useState<number | null>(null);
  const [hedefKolon, setHedefKolon] = useState<string | null>(null);
  const [seciliKurye, setSeciliKurye] = useState<Set<number>>(new Set());
  const yazar = yetki('dis.lab');
  const geriParam = encodeURIComponent(konum.pathname);

  const yukle = useCallback(async () => {
    try { setPano(await api.disLabPano({ labId, hekimId })); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [labId, hekimId]);
  useEffect(() => { void yukle() }, [yukle, yenile]);
  useEffect(() => { if (!secili) { setGecmis([]); return } api.disLabAsamalar(secili).then(y => setGecmis(y.asamalar)).catch(() => setGecmis([])) }, [secili, pano]);

  const kartlar = useMemo(() => {
    let k = pano?.kartlar ?? [];
    const q = ara.trim().toLocaleLowerCase('tr');
    if (q) k = k.filter(x => `${x.isemriNo} ${x.hasta} ${x.disNolar} ${x.lab} ${x.islem}`.toLocaleLowerCase('tr').includes(q));
    if (suzgec === 'acik') k = k.filter(x => x.asama < 8);
    else if (suzgec === 'geciken') k = k.filter(x => x.gecikti);
    else if (suzgec === 'hafta') k = k.filter(x => x.asama < 5 && x.beklenen && (gun(x.beklenen) ?? 99) <= 7);
    else if (suzgec === 'bugun') k = k.filter(x => (x.asama === 5 || x.asama === 6) && x.sonAsamaZamani && String(x.sonAsamaZamani).slice(0, 10) === String(pano?.bugun ?? '').slice(0, 10));
    else if (suzgec === 'teslim') k = k.filter(x => x.asama === 8);
    return k;
  }, [pano, ara, suzgec]);
  const tumu = pano?.kartlar ?? [];
  const sec = useMemo(() => tumu.find(x => x.id === secili) ?? null, [tumu, secili]);
  const sayilar = {
    acik: tumu.filter(x => x.asama < 8).length, geciken: tumu.filter(x => x.gecikti).length,
    hafta: tumu.filter(x => x.asama < 5 && x.beklenen && (gun(x.beklenen) ?? 99) <= 7).length,
    bugun: tumu.filter(x => (x.asama === 5 || x.asama === 6) && x.sonAsamaZamani && String(x.sonAsamaZamani).slice(0, 10) === String(pano?.bugun ?? '').slice(0, 10)).length,
    teslim: tumu.filter(x => x.asama === 8).length,
  };

  // ---- aşama geçişi
  const asamaYap = async (k: Kart, asama: number, notIste = false) => {
    if (!yazar) return;
    if (k.asama === asama) return;
    if (asama === 8 && k.asama < 5) { mesaj('Gelmemiş iş teslim edilemez; önce "Geldi".'); return }
    if (asama === 7 && k.asama < 5) { mesaj('Gelmemiş iş geri gönderilmez.'); return }
    let not: string | undefined;
    if (asama === 7 || notIste) {
      const n = await metinSor(asama === 7 ? 'Geri gönderme nedeni (renk / oturmama / kontak / kırık):' : 'Not:');
      if (n === null) return;
      not = n;
    }
    if (asama === 8 && !await onay(`${k.isemriNo} teslim edildi olarak işaretlensin mi? Plan satırı hekim tarafından "yapıldı" yapılır.`)) return;
    await guvenli(async () => { await api.disLabAsama(k.id, { asama, not }); await yukle() });
  };
  const birak = async (kolonK: string) => {
    const kol = KOLONLAR.find(c => c.k === kolonK); const k = tumu.find(x => x.id === surukle);
    setSurukle(null); setHedefKolon(null);
    if (!kol || !k) return;
    await asamaYap(k, kol.hedef);
  };
  const kuryeGonder = async () => {
    const ids = [...seciliKurye]; if (!ids.length) { mesaj('İş emri seçin.'); return }
    if (!await onay(`${ids.length} iş emri "Gönderildi" yapılsın mı? Gönderim tarihi bugün, beklenen tarih lab SLA'sından.`)) return;
    await guvenli(async () => { for (const id of ids) await api.disLabAsama(id, { asama: 2 }); setSeciliKurye(new Set()); mesaj(`${ids.length} iş emri gönderildi.`); await yukle() });
  };

  const KartCiz = ({ k, kisa }: { k: Kart; kisa?: boolean }) => {
    const kalan = gun(k.beklenen);
    const yuzde = k.gonderim && k.beklenen ? Math.max(0, Math.min(100, Math.round((Date.now() - new Date(k.gonderim).getTime()) / Math.max(1, new Date(k.beklenen).getTime() - new Date(k.gonderim).getTime()) * 100))) : k.asama >= 5 ? 100 : 0;
    const sinif = k.gecikti ? 'gec' : (kalan != null && kalan <= 2 && k.asama < 5) || (k.asama >= 5 && k.asama < 8 && !k.randevu) ? 'yakin' : '';
    const [asamaAd, asamaRenk] = ASAMA[k.asama] ?? ['?', 'gri'];
    return (
      <div className={`ds-kb-kart ${sinif}${secili === k.id ? ' sel' : ''}`} draggable={yazar && k.asama < 8} onClick={() => setSecili(k.id)}
        onDragStart={() => setSurukle(k.id)} onDragEnd={() => { setSurukle(null); setHedefKolon(null) }} onDoubleClick={() => git(`/dis-lab-isemri/${k.id}?geri=${geriParam}`)}>
        <div className="ds-kb-no">🧪 {k.isemriNo}
          {k.gecikti ? <span className="rozet hata">gecikti</span> : k.asama === 3 ? <span className="rozet mor">onay?</span> : (k.asama === 2 || k.asama === 4) && kalan != null && kalan <= 2 ? <span className="rozet uyari">{kalan <= 0 ? 'bugün' : kalan === 1 ? 'yarın' : `${kalan} gün`}</span> : k.asama >= 5 ? <span className={`rozet ${asamaRenk}`}>{asamaAd}</span> : k.planNo ? <span className="rozet gri">{k.planNo}</span> : null}
        </div>
        <div className="ds-kb-hasta">{k.hasta} <span className="sonuk">· diş {k.disNolar || '—'}</span></div>
        <div className="ds-kb-is">{[TUR[k.isTuru], k.malzeme, k.renk].filter(Boolean).join(' · ')}{k.islem && !kisa ? <span className="sonuk"> · {k.islem}</span> : ''}</div>
        {!kisa && <div className="ds-kb-alt"><span className="ds-kb-tag lab">{k.lab}</span><span>{k.hekim || '—'}</span>
          {k.kaliteKontrol === 1 && <span className="ds-kb-tag kk">KK ✔</span>}
          {k.geriSayisi > 0 && <span className="ds-kb-tag">{k.geriSayisi + 1}. tur</span>}
          {k.randevu ? <span className="ds-kb-tag rnd">🗓 {tarihSaat(k.randevu)}</span> : k.asama >= 5 && k.asama < 8 ? <span className="ds-kb-tag rnd">⚠ randevu ver</span> : null}</div>}
        <div className="ds-kb-alt"><span>⏳ {k.asama === 1 ? (k.randevu ? `ölçü · ${tarihSaat(k.randevu)}` : 'ölçü alınacak') : k.asama === 8 ? `teslim ${k.teslim ? tarihYaz(k.teslim) : ''}` : k.beklenen ? `bekl. ${tarihYaz(k.beklenen)}${kalan != null && k.asama < 5 ? ` · ${kalan < 0 ? `${-kalan} gün geçti` : `${kalan} gün`}` : ''}` : 'beklenen —'}</span>
          <div className={`ds-bar ds-kb-bar${k.gecikti ? ' k' : k.asama === 7 ? ' s' : k.asama >= 5 ? ' o' : ''}`}><i style={{ width: `${yuzde}%` }} /></div></div>
      </div>
    );
  };

  const Kolon = ({ kol, liste, kisa }: { kol: typeof KOLONLAR[number]; liste: Kart[]; kisa?: boolean }) => (
    <div className={`ds-kb-kol ${kol.sinif}${kisa ? ' ds-kb-kol-kisa' : ''}${hedefKolon === kol.k ? ' hedef' : ''}`}
      onDragOver={e => { if (surukle) { e.preventDefault(); setHedefKolon(kol.k) } }} onDragLeave={() => setHedefKolon(h => (h === kol.k ? null : h))}
      onDrop={e => { e.preventDefault(); void birak(kol.k) }}>
      <div className="ds-kb-bas">{kisa ? kol.ad.replace(/^\d · /, '') : kol.ad} {!kisa && <span className="ds-kb-top">{kol.alt}</span>}<span className="ds-kb-say">{liste.length}</span></div>
      <div className="ds-kb-govde">
        {liste.map(k => <KartCiz key={k.id} k={k} kisa={kisa} />)}
        {!kisa && kol.k === 'olcu' && <div className="ds-kb-ekle">ölçü alındı → "Gönderildi"ye sürükle · kurye listesine düşer</div>}
        {!kisa && kol.k === 'tasarim' && <div className="ds-kb-ekle">✔ onay → Üretim (labda) · ✖ ret → Geri gönderildi + not</div>}
        {!kisa && kol.k === 'geri' && <div className="ds-kb-ekle">Geri gönderim nedeni zorunlu · lab performansına işler</div>}
        {!kisa && kol.k === 'teslim' && <div className="ds-kb-ekle">Teslim = plan satırı "yapıldı" (hekim, simantasyon seansı) + ücret · lab maliyeti hakedişten düşer</div>}
      </div>
    </div>
  );

  if (hata) return <div className="hata-kutusu" style={{ margin: 10 }}>{hata}</div>;
  if (!pano) return <div className="sonuk" style={{ padding: 12 }}>Yükleniyor…</div>;

  const kolonListe = (kol: typeof KOLONLAR[number], k: Kart[]) => k.filter(x => kol.asamalar.includes(x.asama) && !(kol.k === 'labda' && x.asama === 3));
  const kuryeGidecek = tumu.filter(x => x.asama === 1);
  const kuryeGelen = tumu.filter(x => (x.asama === 5 || x.asama === 6));

  return (
    <div className="ds-kb-sayfa">
      <div className="ds-arac">
        <input placeholder="🔍 iş emri no · hasta · diş · lab…" value={ara} onChange={e => setAra(e.target.value)} style={{ minWidth: 220 }} />
        {([['acik', `Açık işler (${sayilar.acik})`], ['geciken', `Gecikenler (${sayilar.geciken})`], ['hafta', `Bu hafta beklenen (${sayilar.hafta})`], ['bugun', `Bugün gelen (${sayilar.bugun})`], ['teslim', `Teslim · 30 gün (${sayilar.teslim})`]] as [Suzgec, string][])
          .map(([k, ad]) => <span key={k} className={`cip${suzgec === k ? ' on' : ''}`} onClick={() => setSuzgec(k)}>{ad}</span>)}
        <span className="ds-sp">
          <select value={labId ?? ''} onChange={e => setLabId(e.target.value ? Number(e.target.value) : null)}><option value="">Lab: Tümü</option>{pano.lablar.map(l => <option key={l.id} value={l.id}>{l.ad}</option>)}</select>
          <select value={hekimId ?? ''} onChange={e => setHekimId(e.target.value ? Number(e.target.value) : null)}><option value="">Hekim: Tümü</option>{pano.hekimler.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}</select>
          {([['kanban', '🗂 Kanban'], ['lab', '🏭 Laba göre'], ['kurye', '📤 Kurye günü']] as [Gorunum, string][]).map(([k, ad]) => <span key={k} className={`cip${gorunum === k ? ' on' : ''}`} onClick={() => setGorunum(k)}>{ad}</span>)}
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
        </span>
      </div>
      <div className="ds-kb-lej"><span><i style={{ background: 'var(--hata)' }} />Gecikti</span><span><i style={{ background: '#d9a12b' }} />2 gün içinde / randevusuz</span><span>SLA çubuğu: gönderim → beklenen</span><span className="ds-sp">Kart tıkla → sağda ayrıntı · çift tık → kart · sürükle → aşama değişir</span></div>

      {gorunum === 'kanban' && (
        <div className="ds-kb-ikili">
          <div className="ds-kb">{KOLONLAR.map(kol => <Kolon key={kol.k} kol={kol} liste={kolonListe(kol, kartlar)} />)}</div>
          <div className="ds-kb-detay">
            {sec ? (<>
              <div className="ds-grp"><div className="ds-gb">🧪 {sec.isemriNo} <span className={`rozet ${ASAMA[sec.asama]?.[1]}`}>{ASAMA[sec.asama]?.[0]}</span><span className="ds-sp sonuk">{sec.lab}{sec.gonderim && sec.beklenen ? ` · gün ${Math.max(0, gun(sec.gonderim) != null ? -(gun(sec.gonderim)!) : 0)} / ${sec.slaGun}` : ''}</span></div>
                <div className="ds-hdr" style={{ padding: '4px 10px 8px', gridTemplateColumns: '1fr 1fr' }}>
                  <div><label>Hasta</label><div className="ds-inp">{sec.hasta}</div></div>
                  <div><label>Plan satırı</label><div className="ds-inp">{sec.planNo ? `${sec.planNo} · #${sec.planSira} · ${sec.islem}` : <span className="sonuk">plan dışı</span>}</div></div>
                  <div><label>Diş / iş</label><div className="ds-inp">{sec.disNolar || '—'} · {TUR[sec.isTuru] ?? ''}</div></div>
                  <div><label>Renk · ölçü</label><div className="ds-inp">{[sec.renk, OLCU[sec.olcuTipi]].filter(Boolean).join(' · ') || '—'}</div></div>
                  <div><label>Hekim</label><div className="ds-inp">{sec.hekim || '—'}</div></div>
                  <div><label>Gönderim → beklenen</label><div className="ds-inp">{sec.gonderim ? tarihYaz(sec.gonderim) : '—'} → {sec.beklenen ? tarihYaz(sec.beklenen) : '—'} (SLA {sec.slaGun} gün)</div></div>
                  <div><label>Lab / hasta fiyatı</label><div className="ds-inp">{para.format(sec.labFiyat)} / {para.format(sec.hastaFiyat)}</div></div>
                  <div><label>Prova / teslim randevusu</label><div className="ds-inp">{sec.randevu ? tarihSaat(sec.randevu) : <span className="rozet uyari">yok</span>}</div></div>
                </div>
                {sec.ekIstek && <div className="ds-ic"><label className="sonuk">Ek istek</label><div className="ds-inp" style={{ whiteSpace: 'normal' }}>{sec.ekIstek}</div></div>}
              </div>
              <div className="ds-grp"><div className="ds-gb">Aşama geçişi <span className="ds-sp sonuk">tek tık · log 1134</span></div>
                <div className="ds-kb-asamalar">
                  {sec.asama === 1 && <button className="d bir" disabled={!yazar} onClick={() => void asamaYap(sec, 2)}>📤 Gönderildi (kurye / portal)</button>}
                  {(sec.asama === 2 || sec.asama === 4) && <button className="d" disabled={!yazar} onClick={() => void asamaYap(sec, 3)}>🎨 Tasarım onayına al (lab görsel yolladı)</button>}
                  {sec.asama === 3 && <button className="d onay" disabled={!yazar} onClick={() => void asamaYap(sec, 4)}>✔ Tasarım onay → Üretim</button>}
                  {sec.asama === 3 && <button className="d teh" disabled={!yazar} onClick={() => void asamaYap(sec, 7)}>✖ Tasarım ret → Geri gönder (not)</button>}
                  {(sec.asama >= 2 && sec.asama <= 4) && <button className="d onay" disabled={!yazar} onClick={() => void asamaYap(sec, 5)}>📥 Geldi · kalite kontrol</button>}
                  {sec.asama === 5 && <button className="d" disabled={!yazar} onClick={() => void asamaYap(sec, 6)}>🪑 Prova yapıldı</button>}
                  {(sec.asama === 5 || sec.asama === 6) && <button className="d teh" disabled={!yazar} onClick={() => void asamaYap(sec, 7)}>↩ Geri gönder (neden)</button>}
                  {sec.asama === 7 && <button className="d" disabled={!yazar} onClick={() => void asamaYap(sec, 4)}>🏭 Düzeltme labda (üretim)</button>}
                  {(sec.asama === 5 || sec.asama === 6) && <button className="d onay" disabled={!yazar} onClick={() => void asamaYap(sec, 8)}>✔ Teslim et</button>}
                  {sec.asama < 8 && <button className="d" onClick={() => git(`/randevu/yeni?hastaId=${sec.hastaId}&geri=${geriParam}`)}>🗓 Prova / teslim randevusu ver</button>}
                  {sec.asama < 8 && sec.asama !== 9 && <button className="d" disabled={!yazar} onClick={async () => { if (await onay(`${sec.isemriNo} iptal edilsin mi?`)) await asamaYap(sec, 9) }}>✖ İptal</button>}
                  <button className="d" onClick={() => git(`/dis-lab-isemri/${sec.id}?geri=${geriParam}`)}>📄 İş emri kartı</button>
                  {sec.planSatirId && <button className="d" onClick={() => git(`/dis-hasta/${sec.hastaId}`, { state: { geri: konum.pathname } })}>🦷 Hasta kartı</button>}
                </div>
              </div>
              <div className="ds-grp"><div className="ds-gb">Aşama geçmişi</div>
                <ul className="ds-kb-liste">
                  {gecmis.map((g, i) => <li key={i}>{tarihSaat(g.zaman)} · <b>{ASAMA[g.asama]?.[0] ?? g.asama}</b>{g.kullanici ? ` · ${g.kullanici}` : ''}{g.not_ ? <span className="sonuk"> · {g.not_}</span> : ''}</li>)}
                  {gecmis.length === 0 && <li className="sonuk">Kayıt yok (iş emri açıldı).</li>}
                </ul>
              </div>
            </>) : <div className="ds-ic sonuk">Bir kart seçin: ayrıntı, aşama geçişleri ve geçmiş burada.</div>}
          </div>
        </div>
      )}

      {gorunum === 'lab' && (
        <div className="ds-kb-kulvar">
          <div className="ds-kb-lej"><span>Her lab bir kulvar; kolonlar aynı aşama. Labın yükü ve gecikmesi bir bakışta.</span></div>
          {pano.lablar.filter(l => !labId || l.id === labId).map(l => { const k = kartlar.filter(x => x.labId === l.id); return (
            <div key={l.id} className="ds-kb-swim">
              <div className="ds-kb-lab"><b>{l.ad}</b><br /><span className="sonuk">{k.filter(x => x.asama < 8).length} açık · {k.filter(x => x.gecikti).length} gecikme · SLA {l.slaGun} gün{l.kuryeGunleri ? ` · kurye ${l.kuryeGunleri}` : ''}</span></div>
              <div className="ds-kb ds-kb-kisa">{KOLONLAR.map(kol => <Kolon key={kol.k} kol={kol} liste={kolonListe(kol, k)} kisa />)}</div>
            </div>) })}
        </div>
      )}

      {gorunum === 'kurye' && (
        <div className="ds-odo-alan" style={{ gridTemplateColumns: '1fr 1fr' }}>
          <div className="ds-sol">
            <div className="ds-grp ds-grp-ic"><div className="ds-gb">📤 Gidecek (ölçü alındı → laba) <span className="ds-sp sonuk">{tarihYaz(pano.bugun)}</span></div>
              <div className="ds-dg"><table>
                <thead><tr><th className="orta"><input type="checkbox" checked={kuryeGidecek.length > 0 && kuryeGidecek.every(x => seciliKurye.has(x.id))} onChange={e => setSeciliKurye(e.target.checked ? new Set(kuryeGidecek.map(x => x.id)) : new Set())} /></th><th>İş emri</th><th>Hasta</th><th className="orta">Diş</th><th>İş · malzeme · renk</th><th>Lab</th><th>Ölçü</th><th>Beklenen (SLA)</th></tr></thead>
                <tbody>
                  {kuryeGidecek.map(k => <tr key={k.id} className={seciliKurye.has(k.id) ? 'sel' : ''}>
                    <td className="orta"><input type="checkbox" checked={seciliKurye.has(k.id)} onChange={e => setSeciliKurye(s => { const n = new Set(s); if (e.target.checked) n.add(k.id); else n.delete(k.id); return n })} /></td>
                    <td>{k.isemriNo}</td><td>{k.hasta}</td><td className="orta">{k.disNolar || '—'}</td><td>{[TUR[k.isTuru], k.malzeme, k.renk].filter(Boolean).join(' · ')}</td><td>{k.lab}</td>
                    <td>{OLCU[k.olcuTipi] ?? '—'}</td><td>{tarihYaz(new Date(Date.now() + k.slaGun * 86400000).toISOString())} ({k.slaGun} gün)</td></tr>)}
                  {kuryeGidecek.length === 0 && <tr><td colSpan={8} className="sonuk">Ölçü bekleyen iş emri yok.</td></tr>}
                </tbody>
              </table></div>
              <div className="ds-arac">{yazar && <button className="d bir" onClick={() => void kuryeGonder()}>📤 Seçilenleri "Gönderildi" yap ({seciliKurye.size})</button>}<span className="ds-sp sonuk">gönderim = bugün · beklenen = bugün + lab SLA · lab formu: kart › Yazdır</span></div>
            </div>
          </div>
          <div className="ds-sag">
            <div className="ds-grp"><div className="ds-gb">📥 Gelen (labdan) · kalite kontrol</div>
              <div className="ds-dg"><table>
                <thead><tr><th>İş emri</th><th>Hasta</th><th className="orta">Diş</th><th>Lab</th><th className="orta">KK</th><th>Prova randevusu</th><th /></tr></thead>
                <tbody>
                  {kuryeGelen.map(k => <tr key={k.id}><td>{k.isemriNo}</td><td>{k.hasta}</td><td className="orta">{k.disNolar || '—'}</td><td>{k.lab}</td>
                    <td className="orta">{k.kaliteKontrol === 1 ? <span className="rozet ok">✔</span> : <span className="rozet uyari">bekliyor</span>}</td>
                    <td>{k.randevu ? tarihSaat(k.randevu) : <span className="rozet hata">yok</span>}</td>
                    <td><button className="d" onClick={() => { setSecili(k.id); setGorunum('kanban') }}>Aç</button></td></tr>)}
                  {kuryeGelen.length === 0 && <tr><td colSpan={7} className="sonuk">Gelen iş yok.</td></tr>}
                </tbody>
              </table></div>
              <div className="ds-ic sonuk">Kalite kontrol iş emri kartında (renk / oturma / kontak / okluzyon); ✖ ise "Geri gönderildi" + neden. Prova randevusu verilmeden kart "Geldi"de kalır.</div>
            </div>
            <div className="ds-grp"><div className="ds-gb">Kurye / portal</div>
              <div className="ds-ic">{pano.lablar.map(l => <div key={l.id}><b>{l.ad}</b>: SLA {l.slaGun} gün{l.kuryeGunleri ? ` · kurye ${l.kuryeGunleri}` : ' · kurye günü tanımsız'}</div>)}</div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
