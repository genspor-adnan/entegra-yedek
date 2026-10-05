import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { GozGecmisSatiri, GozKontrol, GozMuayeneIsleri, GozMuayeneOnizleme, GozOyku, GozHastaOyku } from '../../api/uclar/goz';
import { tarihYaz } from '../../bilesenler/bicim';
import { guvenli } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';

/**
 * GÖZ MUAYENE KARTI v4 (mockup Ekranlar/Goz/goz_muayene_karti_v4.html).
 *
 *   useGozKontrol      sol gezinti durumları + kontrol listesi (sunucunun Tamamla kuralı)
 *   GozSagOzet         sağda hep görünen OD / OS özeti, GİB eğilimi, tanılar, uyarılar
 *   GozKuralSeridi     altta tamamlama koşulları + Tamamla
 *   GozOzetSekmesi     açılış sayfası: 5 kutu, derlenmiş metin, kontrol listesi, bekleyenler, son muayeneler
 *   GozOykuV4Sekmesi   tek satır şikâyet / hikâye + hızlı şikâyet + hastanın göz öyküsü
 */

export function useGozKontrol(id: number, yenile: number) {
  const [k, setK] = useState<GozKontrol | null>(null);
  useEffect(() => { if (id > 0) api.gozKontrol(id).then(setK).catch(() => setK(null)) }, [id, yenile]);
  return k;
}

/** Sol gezinti aşamaları - sekme başlıkları kartOzellestirme'dekiyle aynı. */
export const GOZ_SEKME_GRUPLARI = [
  { baslik: null, sekmeler: ['Özet'] },
  { baslik: '1 · Öykü', sekmeler: ['Şikâyet & Öykü'] },
  { baslik: '2 · Ölçüm', sekmeler: ['Görme & Refraksiyon', 'Tonometri & Pakimetri', 'Ön Segment', 'Fundus',
                                     'Motilite · Pupil · Alan', 'Gonyoskopi & Ek Testler'] },
  { baslik: '3 · Karar', sekmeler: ['Tanılar', 'Tanı & Plan', 'e-Reçete', 'İstem & Sonuç', 'İşlem & Ücret'] },
  { baslik: '4 · Kayıt', sekmeler: ['Karşılaştırma', 'Görüntüler'] },
];

const ond = (v: number | null | undefined, k = 2) =>
  v === null || v === undefined ? '—' : Number(v).toLocaleString('tr-TR', { maximumFractionDigits: k });

function useVeri<T>(f: () => Promise<T>, bag: unknown[]) {
  const [v, setV] = useState<T | null>(null);
  useEffect(() => { f().then(setV).catch(() => setV(null)) }, bag);   // eslint-disable-line react-hooks/exhaustive-deps
  return v;
}

function Trend({ l }: { l: GozGecmisSatiri[] }) {
  const s = [...l].reverse();
  const enCok = Math.max(25, ...s.flatMap(r => [Number(r.gibOd ?? 0), Number(r.gibOs ?? 0)]));
  const i = (v: number | null, h: number | null, sn: string) =>
    <i className={v !== null && v > (h ?? 21) ? 'y' : sn} style={{ height: `${v === null ? 0 : (Number(v) / enCok) * 100}%` }} />;
  return (
    <div className="gz-trend" style={{ height: 42 }}>
      {s.map(r => <div key={r.id} className="c">{i(r.gibOd, r.hedefOd, 's')}{i(r.gibOs, r.hedefOs, 'l')}</div>)}
    </div>
  );
}

export function GozSagOzet({ id, yenile }: { id: number; yenile: number }) {
  const o = useVeri<GozMuayeneOnizleme>(() => api.gozMuayeneOnizleme(id), [id, yenile]);
  const k = useVeri<{ satirlar: GozGecmisSatiri[] }>(() => api.gozMuayeneKarsilastirma(id), [id, yenile]);
  const t = useVeri<GozMuayeneIsleri>(() => api.gozMuayeneIsleri(id), [id, yenile]);
  if (!o) return <div className="sonuk rt-kucuk">{c('yükleniyor')}…</div>;
  const m = o.muayene;
  const kr = (bit: number, b: number, v: string) => (b & bit ? <span className="gz-kirmizi">{v}</span> : v);
  const uyarilar = [
    m.gibYuksek & 1 && 'Sağ GİB hedef üstü', m.gibYuksek & 2 && 'Sol GİB hedef üstü',
    m.gormeDusus & 1 && 'Sağ görme düştü', m.gormeDusus & 2 && 'Sol görme düştü',
  ].filter(Boolean) as string[];
  const TARAF: Record<number, string> = { 1: 'OD', 2: 'OS', 3: 'OU' };
  return (
    <div className="gz4-sag">
      <h5>{c('Bu muayene · özet')}</h5>
      <div className="gz-od2">
        <span /><span className="b od">{c('Sağ')}</span><span className="b os">{c('Sol')}</span>
        <span className="b">BCVA</span><span>{kr(1, m.gormeDusus, ond(m.bcvaOd))}</span><span>{kr(2, m.gormeDusus, ond(m.bcvaOs))}</span>
        <span className="b">GİB</span><span>{kr(1, m.gibYuksek, ond(m.gibOd, 1))}</span><span>{kr(2, m.gibYuksek, ond(m.gibOs, 1))}</span>
        <span className="b">{c('Hedef')}</span><span>{ond(m.hedefOd, 0)}</span><span>{ond(m.hedefOs, 0)}</span>
        <span className="b">CCT</span><span>{m.cctOd ?? '—'}</span><span>{m.cctOs ?? '—'}</span>
        <span className="b">C/D</span><span>{ond(m.cdOd)}</span><span>{ond(m.cdOs)}</span>
      </div>
      {k && k.satirlar.length > 1 && (<><h5>{c('GİB eğilimi')}</h5><Trend l={k.satirlar} /></>)}
      <h5>{c('Tanılar')}</h5>
      {t && t.tanilar.length > 0
        ? t.tanilar.map(x => <span key={x.id} className="gz4-cip">{x.kod}{TARAF[x.taraf] ? ` · ${TARAF[x.taraf]}` : ''}</span>)
        : <div className="sonuk rt-kucuk">{c('tanı yok')}</div>}
      {uyarilar.length > 0 && (<><h5>{c('Uyarılar')}</h5>
        {uyarilar.map(u => <div key={u} className="gz-kirmizi rt-kucuk" style={{ fontWeight: 400 }}>⚠ {c(u)}</div>)}</>)}
    </div>
  );
}

export function GozKuralSeridi({ kontrol, sekmeyeGit, onTamamla }: {
  kontrol: GozKontrol | null; sekmeyeGit(b: string): void; onTamamla(): void;
}) {
  const z = (kontrol?.kontrol ?? []).filter(x => x.zorunlu);
  return (
    <div className="gz4-kural">
      <b>{c('Tamamlamak için')}:</b>
      {z.map(x => (
        <span key={x.kod} className={x.durum === 'ok' ? 'ok' : 'yok'} title={x.mesaj || undefined}
              onClick={x.durum === 'ok' ? undefined : () => sekmeyeGit(x.bolum)}>
          {x.durum === 'ok' ? '✓' : '○'} {c(x.ad)}
        </span>
      ))}
      <span style={{ flex: 1 }} />
      <button type="button" className="d onay" onClick={onTamamla}>✔ {c('Tamamla')}</button>
    </div>
  );
}

export function GozOzetSekmesi({ id, kontrol, yenile, sekmeyeGit, onTamamla }: {
  id: number; kontrol: GozKontrol | null; yenile: number; sekmeyeGit(b: string): void; onTamamla(): void;
}) {
  const o = useVeri<GozMuayeneOnizleme>(() => api.gozMuayeneOnizleme(id), [id, yenile]);
  const metin = useVeri<{ bolumler: { baslik: string; metin: string }[] }>(() => api.gozOzetMetin(id), [id, yenile]);
  const is = useVeri<GozMuayeneIsleri>(() => api.gozMuayeneIsleri(id), [id, yenile]);
  const kars = useVeri<{ satirlar: GozGecmisSatiri[] }>(() => api.gozMuayeneKarsilastirma(id), [id, yenile]);
  const m = o?.muayene;
  const ana = is?.tanilar[0];
  const recete = metin?.bolumler.find(b => b.baslik === 'Reçete')?.metin;
  const plan = metin?.bolumler.find(b => b.baslik === 'Değerlendirme & plan')?.metin;
  const kl = kontrol?.kontrol ?? [];
  const z = kl.filter(x => x.zorunlu);
  const bekleyen = (is?.isler ?? []).filter(x => x.tur === 'goruntuleme');
  const kutu = (bas: string, ic: React.ReactNode, alt: string, git: string, uy = false) => (
    <div className={`gz4-kt${uy ? ' uy' : ''}`} onClick={() => sekmeyeGit(git)}><span>{c(bas)}</span><b>{ic}</b><small>{alt}</small></div>
  );
  return (
    <div className="rt-sekme">
      <div className="gz4-kutu5">
        {kutu('Görme (düz.)', m ? <>{ond(m.bcvaOd)} / {m.gormeDusus & 2 ? <span className="gz-kirmizi">{ond(m.bcvaOs)} ↓</span> : ond(m.bcvaOs)}</> : '—',
              c('sağ / sol'), 'Görme & Refraksiyon', !!m && m.gormeDusus > 0)}
        {kutu('GİB', m ? `${ond(m.gibOd, 1)} / ${ond(m.gibOs, 1)}` : '—',
              m && (m.hedefOd !== null || m.hedefOs !== null) ? `${c('hedef')} ${ond(m.hedefOd, 0)} / ${ond(m.hedefOs, 0)}` : c('hedef yok'),
              'Tonometri & Pakimetri', !!m && m.gibYuksek > 0)}
        {kutu('Ana tanı', ana ? ana.kod : '—', ana ? ana.ad.slice(0, 40) : c('tanı girilmemiş'), 'Tanılar')}
        {kutu('Reçete', recete ? recete.split(' · ').length + ' ' + c('ilaç') : '—', recete ? recete.slice(0, 40) : c('reçete yok'), 'e-Reçete')}
        {kutu('Plan / kontrol', plan ? '✓' : '—', m?.kontrolTarihi ? `${c('kontrol')} ${tarihYaz(m.kontrolTarihi)}` : c('kontrol yok'), 'Tanı & Plan')}
      </div>
      <div className="gz4-oz2">
        <div className="gz4-metin">
          {!metin ? <span className="sonuk">{c('yükleniyor')}…</span> : metin.bolumler.length === 0
            ? <span className="sonuk">{c('Henüz yazılmış bir şey yok - öykü ve ölçümler girildikçe burada derlenir.')}</span>
            : metin.bolumler.map(b => <div key={b.baslik}><h6>{c(b.baslik)}</h6><p>{b.metin}</p></div>)}
        </div>
        <div>
          <div className="gz4-kl">
            <h6>{c('Tamamlama kontrolü')} <i>{z.filter(x => x.durum === 'ok').length} / {z.length}</i></h6>
            {kl.map(x => (
              <div key={x.kod} className={`s ${x.durum === 'ok' ? 'ok' : x.zorunlu ? 'yok' : 'opt'}`}>
                <span className="i">{x.durum === 'ok' ? '✓' : x.zorunlu ? '○' : '!'}</span>
                <div>{c(x.ad)}{(x.mesaj || x.zorunlu) && x.durum !== 'ok' && <small>{x.mesaj || c('zorunlu')}</small>}</div>
                {x.durum !== 'ok' && x.bolum && <a onClick={() => sekmeyeGit(x.bolum)}>{c('git')} →</a>}
              </div>
            ))}
            <button type="button" className="d onay" style={{ width: '100%', marginTop: 8 }} onClick={onTamamla}>✔ {c('Tamamla')}</button>
          </div>
          <div className="gz4-kl">
            <h6>{c('Bekleyen istemler')}</h6>
            {bekleyen.length === 0 ? <div className="sonuk rt-kucuk">{c('yok')}</div>
              : bekleyen.map(b => <div key={b.id} className="s opt"><span className="i">⏳</span><div>{c(b.ad)}<small>{b.ayrinti}</small></div></div>)}
          </div>
          <div className="gz4-kl">
            <h6>{c('Son göz muayeneleri')}</h6>
            {(kars?.satirlar ?? []).filter(r => !r.bu).length === 0 ? <div className="sonuk rt-kucuk">{c('ilk muayene')}</div> : (
              <table className="gz4-mini"><tbody>
                <tr><th>{c('Tarih')}</th><th>BCVA</th><th>GİB</th></tr>
                {(kars?.satirlar ?? []).filter(r => !r.bu).slice(0, 4).map(r => (
                  <tr key={r.id}><td>{tarihYaz(r.tarih)}</td><td>{ond(r.bcvaOd)} / {ond(r.bcvaOs)}</td><td>{ond(r.gibOd, 0)} / {ond(r.gibOs, 0)}</td></tr>
                ))}
              </tbody></table>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

// ------------------------------------------------------------- ÖYKÜ (v4) --
const SIKAYETLER = ['Bulanık görme', 'Azalmış yakın görme', 'Kızarıklık', 'Ağrı', 'Kaşıntı', 'Sulanma',
                    'Batma / yabancı cisim', 'Işık hassasiyeti', 'Çift görme', 'Kontrol / reçete'];
const ACIL = ['Işık çakması', 'Uçuşan cisimler', 'Perde inmesi', 'Ani görme kaybı'];
const GOZ = ['sağ gözde', 'sol gözde', 'iki gözde'];
const SURE = ['1 gün', '1 hafta', '1 ay', '2 ay', '1 yıl'];
const SEYIR = ['ani', 'yavaş', 'aralıklı'];

type Oyku = Record<string, unknown> & { damlalar?: { ad: string; goz: string; doz: string; uyum: string }[] };

function Cipler({ secenek, deger, coklu, onDeg, uyari }: {
  secenek: string[]; deger: string | string[] | undefined; coklu?: boolean; onDeg(v: string | string[]): void; uyari?: string[];
}) {
  const sec = Array.isArray(deger) ? deger : deger ? [deger] : [];
  return (
    <span className="gz4-cipler">
      {secenek.map(s => (
        <button key={s} type="button" className={`gz4-c${sec.includes(s) ? ' on' : ''}${uyari?.includes(s) ? ' uy' : ''}`}
                onClick={() => {
                  if (!coklu) return onDeg(sec.includes(s) ? '' : s);
                  // "yok" diğerleriyle birlikte olmaz.
                  const yeni = sec.includes(s) ? sec.filter(x => x !== s)
                    : s === 'yok' ? ['yok'] : [...sec.filter(x => x !== 'yok'), s];
                  onDeg(yeni);
                }}>{c(s)}</button>
      ))}
    </span>
  );
}

export function GozOykuV4Sekmesi({ id, hastaId, yenile }: { id: number; hastaId: number; yenile: number }) {
  const [o, setO] = useState<GozOyku | null>(null);
  const [sikayet, setSikayet] = useState('');
  const [hikaye, setHikaye] = useState('');
  const [genis, setGenis] = useState<string | null>(null);
  const [h, setH] = useState<GozHastaOyku | null>(null);
  const [oyku, setOyku] = useState<Oyku>({});
  const [kirli, setKirli] = useState(false);
  const [durum, setDurum] = useState<string | null>(null);
  const [secim, setSecim] = useState<{ goz?: string; sure?: string; seyir?: string }>({});
  useEffect(() => {
    api.gozOyku(id).then(y => { setO(y); setSikayet(y.sikayet); setHikaye(y.hikaye) }).catch(e => setDurum(hataMetni(e)));
  }, [id, yenile]);
  useEffect(() => {
    if (hastaId > 0) api.gozHastaOyku(hastaId).then(y => { setH(y); setOyku((y.veri ?? {}) as Oyku) }).catch(() => {});
  }, [hastaId, yenile]);
  if (!o) return <div className="sonuk" style={{ padding: 16 }}>{durum ?? `${c('yükleniyor')}…`}</div>;
  const kapali = o.kapali;
  const acil = ACIL.some(a => sikayet.toLocaleLowerCase('tr').includes(a.toLocaleLowerCase('tr')));
  const sikayetEkle = (s: string) => {
    const ek = [s.toLocaleLowerCase('tr'), secim.goz, secim.sure, secim.seyir].filter(Boolean).join(' · ');
    setSikayet(v => (v.trim() ? `${v.trim()}; ${ek}` : ek.charAt(0).toLocaleUpperCase('tr') + ek.slice(1)));
    setKirli(true);
  };
  const oy = (ad: string, v: unknown) => { setOyku(x => ({ ...x, [ad]: v })); setKirli(true) };
  const damlalar = oyku.damlalar ?? [];
  const kaydet = () => void guvenli(async () => {
    if (sikayet !== o.sikayet || hikaye !== o.hikaye) {
      await api.gozOykuYaz(id, { sikayet, hikaye });
      setO({ ...o, sikayet, hikaye });
    }
    if (hastaId > 0) await api.gozHastaOykuYaz(hastaId, oyku);
    setKirli(false);
    setDurum(c('Kaydedildi.'));
  });
  const tek = (ad: 'sikayet' | 'hikaye', bas: string, v: string, set: (s: string) => void) => (
    <>
      <label>{c(bas)}</label>
      {genis === ad
        ? <textarea rows={4} value={v} disabled={kapali} maxLength={4000} onChange={e => { set(e.target.value); setKirli(true) }} />
        : <input value={v} disabled={kapali} maxLength={4000} onChange={e => { set(e.target.value); setKirli(true) }} />}
      <button type="button" className="d kucuk" title={c('Genişlet')} onClick={() => setGenis(g => (g === ad ? null : ad))}>⤢</button>
    </>
  );
  return (
    <div className="rt-sekme">
      <div className="gz4-tek">
        {tek('sikayet', 'Şikâyet', sikayet, setSikayet)}
        {tek('hikaye', 'Hikâye', hikaye, setHikaye)}
      </div>
      {acil && <div className="tl-uyari rt-kucuk" style={{ margin: '6px 0' }}>⚠ {c('Işık çakması / uçuşan cisim / perde / ani kayıp: retina dekolmanı ve vasküler olay ayırıcı tanısı - dilate fundus önerilir.')}</div>}
      {!kapali && (
        <div className="gz4-kart">
          <h6>{c('Hızlı şikâyet')} <a>{c('çipe tıkla = şikâyet satırına eklenir')}</a></h6>
          <div className="gz4-sat"><span className="et">{c('Göz')}</span><Cipler secenek={GOZ} deger={secim.goz} onDeg={v => setSecim(s => ({ ...s, goz: v as string }))} />
            <span className="et">{c('Süre')}</span><Cipler secenek={SURE} deger={secim.sure} onDeg={v => setSecim(s => ({ ...s, sure: v as string }))} />
            <span className="et">{c('Seyir')}</span><Cipler secenek={SEYIR} deger={secim.seyir} onDeg={v => setSecim(s => ({ ...s, seyir: v as string }))} /></div>
          <div className="gz4-cipler" style={{ marginTop: 6 }}>
            {SIKAYETLER.map(s => <button key={s} type="button" className="gz4-c" onClick={() => sikayetEkle(s)}>{c(s)}</button>)}
            {ACIL.map(s => <button key={s} type="button" className="gz4-c uy" onClick={() => sikayetEkle(s)}>{c(s)}</button>)}
          </div>
        </div>
      )}
      <div className="gz4-gr2">
        <div className="gz4-kart">
          <h6>{c('Göz öyküsü')} <a>{h?.zaman ? `${c('son güncelleme')} ${tarihYaz(h.zaman)}${h.kim ? ` · ${h.kim}` : ''}` : c('hastanın - sonraki muayenelerde gelir')}</a></h6>
          <div className="gz4-sat"><span className="et">{c('Ameliyat')}</span>
            <Cipler coklu secenek={['yok', 'katarakt', 'refraktif', 'vitrektomi', 'glokom cerrahisi', 'keratoplasti']} deger={oyku.ameliyat as string[]} onDeg={v => oy('ameliyat', v)} /></div>
          <div className="gz4-sat"><span className="et">{c('Lazer')}</span>
            <Cipler coklu secenek={['yok', 'SLT', 'YAG', 'PRP', 'fokal']} deger={oyku.lazer as string[]} onDeg={v => oy('lazer', v)} /></div>
          <div className="gz4-sat"><span className="et">{c('Travma')}</span><Cipler secenek={['yok', 'var']} deger={oyku.travma as string} onDeg={v => oy('travma', v)} /></div>
          <div className="gz4-sat"><span className="et">{c('Düzeltme')}</span><Cipler secenek={['gözlük', 'kontakt lens', 'yok']} deger={oyku.duzeltme as string} onDeg={v => oy('duzeltme', v)} /></div>
          <div className="gz4-sat"><span className="et">{c('Ambliyopi / şaşılık')}</span><Cipler secenek={['yok', 'var']} deger={oyku.ambliyopi as string} onDeg={v => oy('ambliyopi', v)} /></div>
        </div>
        <div className="gz4-kart">
          <h6>{c('Göz damlaları')} <a onClick={() => oy('damlalar', [...damlalar, { ad: '', goz: 'OU', doz: '', uyum: '' }])}>＋ {c('ekle')}</a></h6>
          {damlalar.length === 0 ? <div className="sonuk rt-kucuk">{c('Kayıtlı damla yok.')}</div> : (
            <table className="gz4-mini"><tbody>
              <tr><th>{c('İlaç')}</th><th>{c('Göz')}</th><th>{c('Doz')}</th><th>{c('Uyum')}</th><th /></tr>
              {damlalar.map((d, i) => {
                const yaz = (ad: string, v: string) => oy('damlalar', damlalar.map((x, j) => (j === i ? { ...x, [ad]: v } : x)));
                return (
                  <tr key={i}>
                    <td><input value={d.ad} onChange={e => yaz('ad', e.target.value)} /></td>
                    <td><select value={d.goz} onChange={e => yaz('goz', e.target.value)}><option>OD</option><option>OS</option><option>OU</option></select></td>
                    <td><input value={d.doz} style={{ width: 80 }} onChange={e => yaz('doz', e.target.value)} /></td>
                    <td><select value={d.uyum} onChange={e => yaz('uyum', e.target.value)}><option value="" />
                      <option value="düzenli">{c('düzenli')}</option><option value="düzensiz">{c('düzensiz')}</option><option value="bırakmış">{c('bırakmış')}</option></select></td>
                    <td><button type="button" className="d kucuk" onClick={() => oy('damlalar', damlalar.filter((_, j) => j !== i))}>×</button></td>
                  </tr>
                );
              })}
            </tbody></table>
          )}
        </div>
        <div className="gz4-kart">
          <h6>{c('Sistemik hastalık & göze etkili ilaçlar')} <a>{c('kronik tanı ve son 12 ay reçetesinden')}</a></h6>
          {(h?.kronik ?? []).length === 0 ? <div className="sonuk rt-kucuk">{c('Kayıtlı kronik tanı yok.')}</div>
            : h!.kronik.map(k => <div key={k.kod} className="gz4-sat"><span className="et">{k.kod}</span>{k.ad}{k.baslangic ? <span className="sonuk"> · {tarihYaz(k.baslangic).slice(-4)}</span> : null}</div>)}
          {(h?.riskler ?? []).map(r => <div key={r.ilac} className="gz4-sat"><span className="et">{c('İlaç')}</span><b>{r.ilac}</b><span className="gz4-risk">{c(r.risk)}</span></div>)}
          {h && h.ilaclar.length > 0 && <div className="sonuk rt-kucuk" style={{ marginTop: 4 }}>{c('Son 12 ay')}: {h.ilaclar.slice(0, 8).join(', ')}</div>}
        </div>
        <div className="gz4-kart">
          <h6>{c('Aile öyküsü')}</h6>
          {([['aile_glokom', 'Glokom'], ['aile_amd', 'AMD'], ['aile_keratokonus', 'Keratokonus'], ['aile_retina', 'Kalıtsal retina']] as const).map(([ad, bas]) => (
            <div key={ad} className="gz4-sat"><span className="et">{c(bas)}</span>
              <Cipler coklu secenek={['yok', 'anne', 'baba', 'kardeş', 'çocuk']} deger={oyku[ad] as string[]} onDeg={v => oy(ad, v)} /></div>
          ))}
        </div>
      </div>
      {!kapali && (
        <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginTop: 10 }}>
          <button type="button" className="d bir" disabled={!kirli} onClick={kaydet}>💾 {c('Öyküyü kaydet')}</button>
          {durum && <span className="sonuk rt-kucuk">{durum}</span>}
          {kirli && <span className="sonuk rt-kucuk">{c('Kaydedilmemiş değişiklik var (kartın Kaydet\'inden ayrı).')}</span>}
        </div>
      )}
    </div>
  );
}
