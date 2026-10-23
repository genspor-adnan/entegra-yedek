import { useEffect, useMemo, useRef, useState } from 'react';
import { Navigate, useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { AcilisBakiyesi, Devir as Veri, DevirTuru, TopluDevirSonucu } from '../../api/uclar/devir';
import { para, tutarOku } from '../../bilesenler/bicim';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { HesapSecici } from '../ekstre/Ekstre';
import { stil as icmalStili } from '../hasta/icmal/icmalStil';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { DevirFormu, TUR_AD, tarihOku } from './DevirFormu';

/**
 * DEVİR GİRİŞİ - TEK EKRAN `/devir?tur=&id=` (mockup Ekranlar/devir_girisi.html, kullanıcı
 * 24.10.2026: "jenerik devir girişi mockup'ı kodla"). Ekstre deseni (1158): tür seçici (yalnız
 * yetkili türler), hesap seçici (cari: jenerik cari arama), üç görünüm:
 *  · Tek Hesap   DevirFormu - türe özgü giriş, kontroller, kaydet / kaldır
 *  · Toplu       Excel'den yapıştır (ilk sütun tür), sunucu denetler, hazır satırlar yazılır
 *  · Açılış Bak. karttaki eski hesap.acilis_bakiye değerleri → tür 2 devir satırına çevir
 * Kartlardaki "💼 Devir / Açılış" aynı formu pencerede açar (DevirPenceresi).
 */
type Gorunum = 'tek' | 'toplu' | 'acilis';
const TUR_IKON: Record<DevirTuru, string> = { cari: '👥', kasa: '💵', banka: '🏦', pos: '💳', kredi: '📑', kredikarti: '💳' };
const KART_YOLU: Record<DevirTuru, string> = { cari: '/cari', kasa: '/kasa-hesap', banka: '/banka-hesap', pos: '/pos-hesap', kredi: '/kredi-hesap', kredikarti: '/kredi-karti' };

/** Eski /cari-devir yolu. */
export function DevirYonlendir() {
  const [arama] = useSearchParams();
  const q = new URLSearchParams(arama); q.set('tur', 'cari'); if (!q.get('gor')) q.set('gor', 'toplu');
  return <Navigate to={`/devir?${q}`} replace />;
}

export function Devir() {
  const [arama, setArama] = useSearchParams();
  const git = useNavigate();
  const { yetki } = useOturum();
  const tur = (arama.get('tur') || 'cari') as DevirTuru | 'hesap';
  const id = Number(arama.get('id') ?? 0);
  const gor = (arama.get('gor') ?? 'tek') as Gorunum;
  const [v, setV] = useState<Veri | null>(null);
  const [turler, setTurler] = useState<DevirTuru[]>([]);
  const [yenile, setYenile] = useState(0);
  const degistir = (d: Record<string, string>) => {
    const yeni = new URLSearchParams(arama);
    for (const [k, x] of Object.entries(d)) { if (x) yeni.set(k, x); else yeni.delete(k) }
    setArama(yeni, { replace: true });
  };
  // Yetkili türler: hesap seçilmeden de bilinsin (tür seçici) - id 0 ile sunucu hesap aramaz.
  useEffect(() => {
    if (turler.length) return;
    api.devirOku(tur === 'hesap' ? 'kasa' : tur, 0).then(d => setTurler(d.turler)).catch(() => {
      api.devirOku('cari', 0).then(d => setTurler(d.turler)).catch(() => setTurler([]));
    });
  }, [tur, turler.length]);
  const gercekTur: DevirTuru = v?.tur ?? (tur === 'hesap' ? 'kasa' : tur);
  const h = id > 0 ? v?.hesap : null;
  const baslik = h ? `${TUR_AD[gercekTur]} — ${h.ad}` : TUR_AD[gercekTur];

  return (
    <div className="hi dv">
      <style>{icmalStili + DEVIR_STILI}</style>
      <div className="sayfabas">
        <div className="basrow"><h1>💼 {c('Devir Girişi')} — {gor === 'toplu' ? c('Toplu') : gor === 'acilis' ? c('Mevcut açılış bakiyeleri') : baslik}</h1>
          <span className="yol">Finans › {c('Devir Girişi')}</span></div>
      </div>

      <div className="hi-arac">
        <span className="sp" />
        {h && yetki('finans.ekstre', 'gor') && <button type="button" onClick={() => git(`/ekstre?tur=${gercekTur}&id=${h.id}`)}>📄 {c('Ekstre')}</button>}
        {h && <button type="button" onClick={() => git(`${KART_YOLU[gercekTur]}/${h.id}`)}>🗂 {c('Kartı Aç')}</button>}
        <button type="button" className={gor === 'toplu' ? 'hi-ana' : ''} onClick={() => degistir({ gor: gor === 'toplu' ? '' : 'toplu' })}>📋 {c('Toplu Giriş')}</button>
        <button type="button" className={gor === 'acilis' ? 'hi-ana' : ''} onClick={() => degistir({ gor: gor === 'acilis' ? '' : 'acilis' })}>⇄ {c('Açılış Bakiyeleri')}</button>
      </div>

      {gor === 'tek' && (
        <div className="hi-serit">
          <div className="ek-seg">
            {(Object.keys(TUR_AD) as DevirTuru[]).filter(t => turler.length === 0 ? t === gercekTur : turler.includes(t)).map(t => (
              <button key={t} type="button" className={t === gercekTur ? 'on' : ''}
                      onClick={() => { if (t !== gercekTur) { const q = new URLSearchParams(arama); q.set('tur', t); q.delete('id'); setArama(q, { replace: true }); setV(null) } }}>
                {TUR_IKON[t]} {TUR_AD[t]}</button>))}
          </div>
          <HesapSecici tur={gercekTur} secili={h ? { id: h.id, ad: h.ad, altBilgi: h.altBilgi, kod: h.kod } : null}
                       onSec={(s: { id: number }) => degistir({ id: String(s.id) })} />
          <span className="sp" />
          {h && <span className={'bo-rz ' + ((v?.satirlar.length ?? 0) > 0 ? 'ok' : 'sari')}>
            {(v?.satirlar.length ?? 0) > 0 ? `${c('Devir girilmiş')} · ${tarihKisa(v!.satirlar[0].tarih)} · ${para.format(v!.satirlar.reduce((x, s) => x + s.yerel, 0))}` : c('Devir girilmemiş')}</span>}
        </div>
      )}

      <div className="hi-govde">
        {gor === 'tek' && (id > 0
          ? <div className="dv-kutu"><DevirFormu key={`${tur}-${id}-${yenile}`} tur={tur} id={id} onYuklendi={setV} onKaydedildi={() => setYenile(t => t + 1)} /></div>
          : <div className="ek-bos">{c('Devir girilecek')} {TUR_AD[gercekTur].toLocaleLowerCase('tr-TR')} {c('hesabını yukarıdaki kutudan seçin; ya da Toplu Giriş ile Excel\'den yapıştırın.')}</div>)}
        {gor === 'toplu' && <TopluGiris turler={turler} git={git} />}
        {gor === 'acilis' && <AcilisBakiyeleri />}
      </div>
    </div>
  );
}

// =============================================================== toplu giriş ==
type TopluSatir = { tur: string; hesap: string; tutar: number; doviz: string; kur: number | null; vade: string | null; belgeNo: string; aciklama: string };
const SUTUNLAR = 'tür (cari / kasa / banka / pos / kredi / kredikarti) · hesap (kod / VKN / ünvan / ad) · tutar (+ borçlu·giriş, − alacaklı·çıkış) · para · kur · vade · belge no · açıklama';
const DURUM: Record<string, [string, string]> = {
  hazir: ['Hazır', 'ok'], cari_yok: ['Bulunamadı', 'hata'], coklu: ['Birden çok eşleşme', 'hata'],
  devir_var: ['Devri var', 'uyari'], hareket_once: ['Önceden hareketi var', 'uyari'], hata: ['Hatalı', 'hata'],
};
const TUR_KISA: Record<string, string> = { c: 'cari', k: 'kasa', b: 'banka', p: 'pos', r: 'kredi', v: 'kredikarti', kk: 'kredikarti', 'kredi karti': 'kredikarti', 'kredi kartı': 'kredikarti' };

function TopluGiris({ turler, git }: { turler: DevirTuru[]; git(yol: string): void }) {
  const { yetki } = useOturum();
  const yazabilir = yetki('finans.devir', 'ekle');
  const [tarih, setTarih] = useState(`${new Date().getFullYear() - 1}-12-31`);
  const [eslestirme, setEslestirme] = useState<'kod' | 'vkn' | 'unvan'>('kod');
  const [metin, setMetin] = useState('');
  const [sonuc, setSonuc] = useState<TopluDevirSonucu | null>(null);
  const [calisiyor, setCalisiyor] = useState(false);
  const alan = useRef<HTMLTextAreaElement | null>(null);
  const [ipucu, setIpucu] = useState(false);

  // İlk sütun tür; tür yazılmamışsa (eski cari şablonu: hesap · tutar …) satır cari sayılır.
  const satirlar = useMemo<TopluSatir[]>(() => metin.split(/\r?\n/).map(l => l.split('\t')).filter(p => (p[0] ?? '').trim()).map(p => {
    const ilk = p[0].trim().toLocaleLowerCase('tr-TR').replace(/ı/g, 'i');
    const turlu = ilk in TUR_KISA || Object.keys(TUR_AD).includes(ilk);
    const q = turlu ? p.slice(1) : p;
    return {
      tur: turlu ? (TUR_KISA[ilk] ?? ilk) : 'cari', hesap: (q[0] ?? '').trim(), tutar: tutarOku(q[1] ?? ''), doviz: (q[2] ?? '').trim().toUpperCase(),
      kur: tutarOku(q[3] ?? '') || null, vade: tarihOku(q[4] ?? '') || null, belgeNo: (q[5] ?? '').trim(), aciklama: (q[6] ?? '').trim(),
    };
  }).filter(s => s.hesap && s.tutar !== 0), [metin]);

  const gonder = async (kontrol: boolean) => {
    if (satirlar.length === 0) { mesaj(`Satır yok. Excel'den yapıştırın: ${SUTUNLAR}`); return }
    setCalisiyor(true);
    try {
      const y = await api.devirToplu({ tarih, eslestirme, kontrol, satirlar: satirlar.map(s => ({ ...s, doviz: s.doviz || undefined })) });
      setSonuc(y);
      if (!kontrol) {
        mesaj(`${y.yazilan} devir satırı kaydedildi.${y.sonuc.length - y.hazir > 0 ? ` ${y.sonuc.length - y.hazir} satır kaydedilmedi (durum sütunu).` : ''}`);
        const kalan = new Set(y.sonuc.filter(s => s.durum !== 'hazir').map(s => s.sira));
        const ham = metin.split(/\r?\n/).filter(l => l.trim());
        setMetin(ham.filter((_, i) => kalan.has(i)).join('\n'));
        setSonuc(null);
      }
    } catch (e) { mesaj(hataMetni(e)) } finally { setCalisiyor(false) }
  };
  const durumu = (i: number) => sonuc?.sonuc.find(s => s.sira === i);
  const hatali = sonuc ? sonuc.sonuc.length - sonuc.hazir : 0;
  const yonAd = (s: TopluSatir) => (s.tur === 'cari' ? (s.tutar > 0 ? 'B' : 'A') : (s.tutar > 0 ? 'G' : 'Ç'));

  return (
    <div className="dv-toplu">
      <div className="cdg-arac">
        <button className="d" disabled={calisiyor || satirlar.length === 0} onClick={() => void gonder(true)}>🔎 {c('Denetle')}</button>
        {yazabilir && <button className="d bir" disabled={calisiyor || !sonuc || sonuc.hazir === 0}
          onClick={async () => { if (await onay(`${sonuc!.hazir} hazır satır ${tarih} tarihli devir olarak kaydedilsin mi?`)) void gonder(false) }}>
          💾 {c('Kaydet')} {sonuc ? `(${sonuc.hazir} ${c('hazır satır')})` : ''}</button>}
        <button className="d" onClick={() => { alan.current?.focus(); alan.current?.select(); setIpucu(true) }}>📋 {c("Excel'den yapıştır")}</button>
        <span className="sp" />
        <label className="sel">📅 {c('Devir tarihi')}: <input type="date" value={tarih} onChange={e => { setTarih(e.target.value); setSonuc(null) }} /></label>
        <label className="sel">{c('Cari eşleştirme')}: <select value={eslestirme} onChange={e => { setEslestirme(e.target.value as typeof eslestirme); setSonuc(null) }}>
          <option value="kod">{c('Cari kodu')}</option><option value="vkn">{c('VKN / TCKN')}</option><option value="unvan">{c('Ünvan (tam)')}</option></select></label>
        {sonuc && hatali > 0 && <span className="rozet hata">{hatali} {c('satırda sorun')}</span>}
        {sonuc && <span className="rozet ok">{sonuc.hazir} {c('satır hazır')}</span>}
      </div>
      <div className="cdg-iki">
        <div className="cdg-giris">
          <h4>{c('Yapıştırılan satırlar')} <span>{SUTUNLAR}</span></h4>
          {ipucu && <div className="cdg-ipucu">{c("Excel'de satırları kopyalayın (Ctrl+C), sonra bu alana Ctrl+V ile yapıştırın.")}</div>}
          <textarea ref={alan} onPaste={() => setIpucu(false)} value={metin} spellCheck={false}
                    placeholder={'cari\tM-01318\t157320,00\tTL\t\t24.01.2026\nkasa\tK-01\t12450\nbanka\tTR62 … 96\t1238900\nkredi\t300.01\t640000\t\t\t15.01.2026'}
                    onChange={e => { setMetin(e.target.value); setSonuc(null) }} />
          <div className="not">{c('Hesap türleri:')} {turler.map(t => TUR_AD[t]).join(' · ') || '—'}. {c('Tür sütunu yoksa satır cari sayılır (eski şablon).')}</div>
        </div>
        <div className="cdg-sonuc">
          <table className="detay-tablo">
            <thead><tr><th>#</th><th>{c('Tür')}</th><th>{c('Hesap')}</th><th>{c('Eşleşen')}</th><th>{c('Yön')}</th><th className="hiza-sag">{c('Tutar')}</th><th>{c('Para')}</th>
              <th className="hiza-sag">{c('Kur')}</th><th>{c('Vade')}</th><th>{c('Belge no')}</th><th>{c('Durum')}</th></tr></thead>
            <tbody>
              {satirlar.length === 0 && <tr><td colSpan={11} className="bos">{c("Soldaki alana Excel'den yapıştırın, sonra Denetle.")}</td></tr>}
              {satirlar.map((s, i) => {
                const d = durumu(i);
                const [ad, sinif] = d ? DURUM[d.durum] ?? [d.durum, ''] : ['—', ''];
                const t = (s.tur in TUR_AD ? s.tur : 'cari') as DevirTuru;
                return (
                  <tr key={i} className={d && d.durum !== 'hazir' ? 'cdg-hatali' : undefined}>
                    <td>{i + 1}</td><td>{TUR_IKON[t]} {TUR_AD[t] ?? s.tur}</td><td>{s.hesap}</td>
                    <td>{d?.hesapId ? <a className="lnk" onClick={() => git(`${KART_YOLU[t]}/${d.hesapId}`)}>{d.hesapKod} · {d.hesapAd}</a> : <span className="soluk">—</span>}</td>
                    <td><span className={'rozet ' + (s.tutar > 0 ? (t === 'cari' ? 'hata' : 'ok') : (t === 'cari' ? 'ok' : 'hata'))}>{yonAd(s)}</span></td>
                    <td className="hiza-sag">{para.format(Math.abs(s.tutar))}</td><td>{s.doviz || (t === 'cari' ? 'TL' : '')}</td>
                    <td className="hiza-sag">{s.kur ? s.kur.toLocaleString('tr-TR', { maximumFractionDigits: 4 }) : ''}</td>
                    <td>{s.vade ? s.vade.split('-').reverse().join('.') : ''}</td><td>{s.belgeNo}</td>
                    <td>{d ? <span className={'rozet ' + sinif} title={d.mesaj}>{ad}</span> : <span className="soluk">{c('denetlenmedi')}</span>}
                      {d && d.durum !== 'hazir' && <div className="cdg-mesaj">{d.mesaj}</div>}</td>
                  </tr>);
              })}
            </tbody>
          </table>
          <div className="not">{c('Hatalı satır kaydedilmez; hazır satırlar kaydedilince listeden çıkar. Kur boşsa devir tarihindeki TCMB alış kuru; hesap satırının para birimi hesabınki olmalı. Devri olan hesap burada değişmez - kartından ya da Tek Hesap görünümünden düzenlenir.')}</div>
        </div>
      </div>
    </div>
  );
}

// ==================================================== mevcut açılış bakiyeleri ==
function AcilisBakiyeleri() {
  const { yetki } = useOturum();
  const [l, setL] = useState<AcilisBakiyesi[] | null>(null);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [calisiyor, setCalisiyor] = useState(false);
  const yukle = () => api.devirAcilisBakiyeleri().then(y => { setL(y.hesaplar); setSecili(new Set()) }).catch(e => { mesaj(hataMetni(e)); setL([]) });
  useEffect(() => { void yukle() }, []);
  const cevrilebilir = (x: AcilisBakiyesi) => !x.devirVar && !(x.acilisTarihi && x.ilkHareket && x.ilkHareket.slice(0, 10) < x.acilisTarihi.slice(0, 10));
  const cevir = async () => {
    const idler = [...secili];
    if (!(await onay(`${idler.length} hesabın karttaki açılış bakiyesi devir satırına çevrilsin mi? Kart alanı sıfırlanır.`))) return;
    setCalisiyor(true);
    try { const y = await api.devirAcilisCevir(idler); mesaj(`${y.cevrilen} hesap çevrildi${y.atlanan.length ? `, ${y.atlanan.length} atlandı` : ''}.`); await yukle() }
    catch (e) { mesaj(hataMetni(e)) } finally { setCalisiyor(false) }
  };
  if (!l) return <div className="ek-bos">{c('Yükleniyor')}…</div>;
  const uygun = l.filter(cevrilebilir);
  return (
    <div className="dv-toplu">
      <div className="cdg-arac">
        {yetki('finans.devir', 'ekle') && <button className="d bir" disabled={calisiyor || secili.size === 0} onClick={() => void cevir()}>⇄ {c('Seçilenleri devir satırına çevir')} ({secili.size})</button>}
        <button className="d" onClick={() => setSecili(new Set(uygun.map(x => x.id)))}>{c('Hepsini seç')}</button>
        <span className="sp" />
        {l.length - uygun.length > 0 && <span className="rozet uyari">{l.length - uygun.length} {c('hesapta devir var ya da açılış tarihi ilk hareketten sonra')}</span>}
      </div>
      <table className="detay-tablo">
        <thead><tr><th /><th>{c('Tür')}</th><th>{c('Hesap')}</th><th>{c('Para')}</th><th className="hiza-sag">{c('Karttaki açılış bakiyesi')}</th><th>{c('Açılış tarihi')}</th>
          <th className="hiza-sag">{c('Hareket bakiyesi')}</th><th className="hiza-sag">{c('Devirli bakiye')}</th><th>{c('İlk hareket')}</th><th>{c('Durum')}</th></tr></thead>
        <tbody>
          {l.length === 0 && <tr><td colSpan={10} className="bos">{c('Karttan çevrilecek açılış bakiyesi kalmadı.')}</td></tr>}
          {l.map(x => {
            const t = (x.tur in TUR_AD ? x.tur : 'kasa') as DevirTuru;
            const ok = cevrilebilir(x);
            return (
              <tr key={x.id}>
                <td><input type="checkbox" className="grid-cb" disabled={!ok} checked={secili.has(x.id)}
                           onChange={e => setSecili(s => { const y = new Set(s); if (e.target.checked) y.add(x.id); else y.delete(x.id); return y })} /></td>
                <td>{TUR_IKON[t]} {TUR_AD[t]}</td><td><b>{x.ad}</b>{x.kod ? <span className="soluk"> · {x.kod}</span> : null}</td><td>{x.doviz}</td>
                <td className="hiza-sag">{para.format(x.acilisBakiye)}</td><td>{x.acilisTarihi ? tarihKisa(x.acilisTarihi) : <span className="soluk">— ({c('ilk hareketin öncesi')})</span>}</td>
                <td className="hiza-sag">{para.format(x.hareketBakiye)}</td><td className="hiza-sag"><b>{para.format(x.hareketBakiye + x.acilisBakiye)}</b></td>
                <td>{x.ilkHareket ? tarihKisa(x.ilkHareket) : '—'}</td>
                <td>{x.devirVar ? <span className="rozet uyari">{c('Devri var')}</span> : ok ? <span className="rozet ok">{c('Çevrilebilir')}</span>
                  : <span className="rozet uyari">{c('Açılış tarihi ilk hareketten sonra - tarih düzeltilmeli')}</span>}</td>
              </tr>);
          })}
        </tbody>
      </table>
      <div className="not">{c('Çevirme: hesap başına tür 2 devir satırı (tarih = karttaki açılış tarihi, yoksa ilk hareketin bir gün öncesi, o da yoksa yıl başının bir gün öncesi); karttaki alan sıfırlanır. Eski alanı hiçbir bakiye okumuyordu - çevirince ekstre, hesap bakiyesi ve gün sonu devri görür.')}</div>
    </div>
  );
}

const DEVIR_STILI = `
.dv .hi-serit .sel { border-radius:13px; padding-left:10px; padding-right:10px; }
.ek-seg { display:flex; border:1px solid #cdd6e0; border-radius:13px; overflow:hidden; background:#fff; }
.ek-seg button { border:0; border-right:1px solid #e3e9f0; background:none; padding:4px 11px; font-size:12px; color:#4d5d6e; cursor:pointer; white-space:nowrap; }
.ek-seg button:last-child { border-right:0; }
.ek-seg button.on { background:linear-gradient(#4d8fd6,#2f6db3); color:#fff; font-weight:bold; }
.ek-sec { position:relative; min-width:320px; }
.ek-sec-kutu { display:flex; align-items:center; gap:6px; padding:2px 10px; cursor:pointer; font-size:12px; border-radius:13px; }
.ek-sec-kutu input { border:0; outline:0; flex:1; font-size:12px; min-width:180px; }
.ek-sec-kutu .ok { margin-left:auto; color:#6b7a8b; }
.ek-sec-liste { position:absolute; z-index:30; top:100%; left:0; right:0; margin-top:2px; background:#fff; border:1px solid #cdd6e0; border-radius:8px; box-shadow:0 6px 18px rgba(0,0,0,.12); max-height:320px; overflow:auto; }
.ek-sec-satir { padding:5px 10px; font-size:12px; cursor:pointer; display:flex; justify-content:space-between; gap:8px; }
.ek-sec-satir span { color:#6b7a8b; font-size:11px; white-space:nowrap; }
.ek-sec-satir.on { background:#eef4fb; } .ek-sec-satir.pasif b { color:#9aa7b4; font-weight:normal; }
.ek-sec-bos { padding:8px 10px; font-size:12px; color:#6b7a8b; }
.ek-bos { margin:24px 12px; padding:22px; text-align:center; color:#6b7a8b; border:1px dashed #cdd6e0; border-radius:6px; background:#fff; }
.dv-kutu { background:var(--yuz,#fff); border:1px solid #e3e9f0; border-radius:4px; padding:12px; }
.dv-toplu { display:flex; flex-direction:column; gap:8px; }
.cdg-arac { display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
.cdg-arac .sel { display:flex; gap:4px; align-items:center; font-size:12px; }
.cdg-iki { display:grid; grid-template-columns:minmax(260px, 1fr) 2.4fr; gap:12px; }
.cdg-giris { display:flex; flex-direction:column; }
.cdg-giris h4 { margin:0 0 6px; font-size:12px; display:flex; flex-direction:column; gap:2px; }
.cdg-giris h4 span { font-weight:normal; font-size:10.5px; color:var(--soluk); }
.cdg-giris textarea { min-height:380px; font-family:Consolas, monospace; font-size:11.5px; white-space:pre; }
.cdg-hatali td { background:var(--hatazem); }
.cdg-ipucu { font-size:11.5px; padding:6px 8px; margin-bottom:6px; border-radius:4px; background:var(--uyarizem); color:var(--uyari); }
.cdg-giris textarea:focus { outline:2px solid var(--vurgu); }
.cdg-mesaj { font-size:10.5px; color:var(--hata); }
.dv .detay-tablo .bos { text-align:center; color:var(--soluk); padding:14px; }
@media (max-width: 1000px) { .cdg-iki { grid-template-columns:1fr; } }
`;

export default Devir;
