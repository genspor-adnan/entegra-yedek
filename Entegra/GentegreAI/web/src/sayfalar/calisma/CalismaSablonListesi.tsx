import { Fragment, useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CalismaSablonListe, CalismaSablonSatiri } from '../../api/uclar/ayar';
import { useOturum } from '../../kimlik/OturumBaglami';
import { CalismaSablonAraclari } from '../../bilesenler/calisma/CalismaSablonAraclari';
import { CalismaSablonKarti } from '../../bilesenler/calisma/CalismaSablonKarti';
import { GUN_AD, dk, tarihSaat } from '../../bilesenler/calisma/calismaOrtak';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';

/**
 * ÇALIŞMA ŞABLONLARI LİSTESİ — mockup `Ekranlar/Randevu/calisma_sablonlari_listesi.html`.
 *
 * "Hangi doktor ne zaman çalışıyor, neresi eksik" sorusunu tek bakışta:
 * günler 7 kutu (iki haftada bir taralı), saatler 07-20 mini şerit, kanal
 * rozetleri, 2 hafta doluluk, "N gün kaldı"; doktora göre grup; üstte özet
 * şeridi (şablonu olmayan doktor, süresi bitecek şablon); işaretlenen
 * satırlara toplu işlem. Hesaplar sunucuda (`/api/calisma-plani/sablon-liste`).
 *
 * Kart aynı rotada (`/calisma-sablon/:id`) üstte açılır - liste süzgeci kaybolmaz.
 */
type Durum = 'aktif' | 'pasif' | 'biten' | 'tumu';
const CETVEL_BAS = 7 * 60, CETVEL_BOY = 13 * 60;           // 07:00-20:00
const yuzde = (dakika: number) => `${Math.max(0, Math.min(100, (100 * (dakika - CETVEL_BAS)) / CETVEL_BOY))}%`;
const gunFarki = (iso: string) => Math.round((new Date(iso + 'T00:00:00').getTime() - new Date(new Date().toDateString()).getTime()) / 864e5);
const kisa = (iso?: string | null) => (iso ? tarihSaat(iso.slice(0, 10)) : '');

export function CalismaSablonListesi() {
  const git = useNavigate();
  const { id } = useParams();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const yazar = yetki('randevu.plan');
  const [durum, setDurum] = useState<Durum>('aktif');
  const [departmanId, setDepartmanId] = useState<number | ''>('');
  const [subeId, setSubeId] = useState<number | ''>('');
  const [ara, setAra] = useState('');
  const [araGecikmeli, setAraGecikmeli] = useState('');
  const [grupla, setGrupla] = useState(true);
  const [yalnizBitecek, setYalnizBitecek] = useState(false);
  const [sablonsuzAcik, setSablonsuzAcik] = useState(false);
  const [veri, setVeri] = useState<CalismaSablonListe | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [kodlar, setKodlar] = useState<Record<string, Record<string, string>>>({});
  const [toplu, setToplu] = useState<'' | 'kopyala' | 'bitis'>('');
  const [hedefHekim, setHedefHekim] = useState<number | ''>('');
  const [bitis, setBitis] = useState('');

  useEffect(() => { const z = setTimeout(() => setAraGecikmeli(ara), 350); return () => clearTimeout(z) }, [ara]);
  useEffect(() => {
    api.kartAlanlari('calisma-sablon')
      .then(m => setKodlar(Object.fromEntries(m.alanlar.map(a => [a.ad, a.kodlar ?? {}]))))
      .catch(() => { /* seçiciler boş kalır */ });
  }, []);

  const yukle = useCallback(async () => {
    try {
      setVeri(await api.calismaSablonListe({ durum, departmanId, subeId, ara: araGecikmeli.trim() }));
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [durum, departmanId, subeId, araGecikmeli]);
  useEffect(() => { void yukle() }, [yukle]);
  // Kart kapanınca (id kalkınca) liste tazelenir.
  const kartAcik = id !== undefined;
  useEffect(() => { if (!kartAcik) void yukle() }, [kartAcik]);   // eslint-disable-line react-hooks/exhaustive-deps

  const satirlar = useMemo(() => {
    let l = veri?.satirlar ?? [];
    if (yalnizBitecek) { const b = new Set(veri?.ozet.bitecek.map(x => x.id)); l = l.filter(s => b.has(s.id)) }
    return l;
  }, [veri, yalnizBitecek]);
  const gruplar = useMemo(() => {
    const m = new Map<number, CalismaSablonSatiri[]>();
    for (const s of satirlar) { const g = m.get(s.hekimId) ?? []; g.push(s); m.set(s.hekimId, g) }
    return [...m.values()];
  }, [satirlar]);

  const seciliSatirlar = satirlar.filter(s => secili.has(s.id));
  const seciliDoktorlar = [...new Set(seciliSatirlar.map(s => s.hekimId))];
  const isaretle = (sid: number, on: boolean) => setSecili(o => { const y = new Set(o); if (on) y.add(sid); else y.delete(sid); return y });
  const tumu = satirlar.length > 0 && satirlar.every(s => secili.has(s.id));

  const topluCalistir = (islem: 'pasif' | 'bitis' | 'kopyala') => guvenli(async () => {
    const idler = [...secili];
    if (idler.length === 0) return;
    if (islem === 'pasif' && !await onay(`${idler.length} ${c('şablon pasife alınacak; bu düzenle yeni randevu verilemez. Devam edilsin mi?')}`, true)) return;
    if (islem === 'bitis' && !bitis) { setHata(c('Bitiş tarihi seçin.')); return }
    if (islem === 'kopyala' && hedefHekim === '') { setHata(c('Kopyalanacak doktoru seçin.')); return }
    const y = await api.calismaSablonToplu(islem, idler, islem === 'bitis' ? { bitis } : islem === 'kopyala' ? { hedefHekimId: Number(hedefHekim) } : {});
    const hatali = y.sonuc.filter(s => !s.basarili);
    mesaj(hatali.length === 0
      ? `${y.sonuc.length} ${c('şablon işlendi.')}`
      : `${y.sonuc.length - hatali.length} / ${y.sonuc.length} ${c('şablon işlendi.')}\n` + hatali.map(h => `#${h.id}: ${h.mesaj}`).join('\n'));
    setToplu(''); setSecili(new Set());
    await yukle();
  });

  const kartAc = (sid: number) => git(`/calisma-sablon/${sid}`);
  const kartKapat = () => git(sorgu.get('geri') ?? '/calisma-sablon');
  const sayac = veri?.sayac;
  const ozet = veri?.ozet;
  const secenek = (alan: string) => Object.entries(kodlar[alan] ?? {}).sort((a, b) => a[1].localeCompare(b[1], 'tr'));

  // Düz fonksiyon (bileşen değil): her çizimde satırlar yeniden kurulmasın.
  const satir = (s: CalismaSablonSatiri) => {
    const gunler = s.gunler.split(',').map(Number);
    const bloklar = [[s.bas1, s.bit1], [s.bas2, s.bit2]].filter(([b, e]) => b && e && dk(e) > dk(b)) as [string, string][];
    const kalan = s.gecerliBit ? gunFarki(s.gecerliBit.slice(0, 10)) : null;
    return (
      <tr key={s.id} className={`${secili.has(s.id) ? 'secili ' : ''}${!s.aktif || s.biten ? 'pasif ' : ''}${s.cakisma ? 'cakisma' : ''}`}
          onDoubleClick={() => kartAc(s.id)} title={c('Çift tık: şablon kartı')}>
        <td><input type="checkbox" checked={secili.has(s.id)} onChange={e => isaretle(s.id, e.target.checked)} /></td>
        <td><div className="cl-dr">{s.hekim}<small>{s.departman}</small></div></td>
        <td>{s.sube === 'Tüm şubeler' ? c('Tümü') : s.sube}</td>
        <td><button type="button" className="cl-bag" onClick={() => kartAc(s.id)}>{s.ad}</button></td>
        <td><span className="cl-gn">{GUN_AD.map((g, i) => (
          <i key={g} className={gunler.includes(i + 1) ? (s.tekrar === 2 ? 'iki' : 'on') : ''} title={c(g)}>{c(g).slice(0, 1)}</i>
        ))}</span></td>
        <td><div className="cl-ss"><span>{bloklar.map(([b, e]) => `${b}–${e}`).join(' · ')}</span>
          <div className="bar">{bloklar.map(([b, e], i) => <i key={i} style={{ left: yuzde(dk(b)), width: `calc(${yuzde(dk(e))} - ${yuzde(dk(b))})` }} />)}</div></div></td>
        <td className="orta">{s.slotDk} dk</td>
        <td><span className="cl-kanal">{[['B', 'B'], ['P', 'P'], ['C', 'Ç']].map(([k, a]) => <span key={k} className={s.kanallar.includes(k) ? 'on' : ''}>{a}</span>)}</span></td>
        <td>{s.tekrar === 2 ? `${c('İki haftada bir')} · ` : ''}{kisa(s.gecerliBas)} –{' '}
          {s.gecerliBit ? <b className={kalan !== null && kalan >= 0 && kalan <= 30 ? 'cl-uyar' : ''}>{kisa(s.gecerliBit)}</b> : ''}</td>
        <td>{s.doluluk == null ? '—' : <span className="cl-dol"><span className="b"><i className={s.doluluk >= 80 ? 'yuk' : ''} style={{ width: `${s.doluluk}%` }} /></span>%{s.doluluk}</span>}</td>
        <td>{s.cakisma ? <span className="rozet hata">{c('Çakışma')}</span>
          : !s.aktif ? <span className="rozet gri">{c('Pasif')}</span>
          : s.biten ? <span className="rozet gri">{c('Süresi bitti')}</span>
          : kalan !== null && kalan <= 30 ? <span className="rozet uyari">{kalan} {c('gün kaldı')}</span>
          : <span className="rozet ok">{c('Aktif')}</span>}</td>
      </tr>
    );
  };

  return (
    <>
      <div className="sayfabas"><div className="basrow"><h1>{c('Çalışma Şablonları')}</h1>
        <span className="yol">{c('Randevu › Ayarlar › Çalışma Şablonları')} · {c('randevu düzeninin tek kaynağı')}</span></div></div>
      <div className="cl-sayfa">
        <div className="cl-arac">
          {yazar && <button type="button" className="d bir" onClick={() => git('/calisma-sablon/yeni')}>＋ {c('Yeni Şablon')}</button>}
          {yazar && <CalismaSablonAraclari onDegisti={() => void yukle()} />}
          <span className="cl-ayrac" />
          {([['aktif', 'Aktif'], ['pasif', 'Pasif'], ['biten', 'Süresi biten'], ['tumu', 'Tümü']] as [Durum, string][]).map(([k, a]) => (
            <button key={k} type="button" className={`ck-cip${durum === k && !yalnizBitecek ? ' on' : ''}`}
                    onClick={() => { setDurum(k); setYalnizBitecek(false); setSecili(new Set()) }}>
              {c(a)} <b>{sayac?.[k] ?? ''}</b></button>
          ))}
          <span className="cl-ayrac" />
          <select value={departmanId} onChange={e => setDepartmanId(e.target.value ? Number(e.target.value) : '')}>
            <option value="">{c('Bölüm: Tümü')}</option>
            {secenek('departmanId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
          </select>
          <select value={subeId} onChange={e => setSubeId(e.target.value ? Number(e.target.value) : '')}>
            <option value="">{c('Şube: Tümü')}</option>
            {secenek('subeId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
          </select>
          <button type="button" className={`ck-cip${grupla ? ' on' : ''}`} onClick={() => setGrupla(g => !g)}>{c('Doktora göre grupla')}</button>
          <input className="cl-ara" value={ara} placeholder={`🔍 ${c('Doktor / bölüm ara…')}`} onChange={e => setAra(e.target.value)} />
        </div>

        {ozet && (
          <div className="cl-ozetler">
            <div className="cl-kpi"><span className="k">{c('Aktif şablon')}</span><span className="v">{ozet.aktifSablon}</span>
              <span className="a">{ozet.doktor} {c('doktor')} · {ozet.bolum} {c('bölüm')}</span></div>
            <div className="cl-kpi"><span className="k">{c('Haftalık kapasite')}</span><span className="v">{ozet.haftalikSlot.toLocaleString('tr-TR')} slot</span>
              <span className="a">{c('önümüzdeki 2 hafta doluluk')} %{ozet.doluluk}</span></div>
            <button type="button" className={`cl-kpi${ozet.sablonsuz.length ? ' dikkat' : ''}`} onClick={() => setSablonsuzAcik(a => !a)}>
              <span className="k">{c('Şablonu olmayan doktor')}</span><span className="v">{ozet.sablonsuz.length}</span>
              <span className="a">{c('randevu listelerinde görünmüyor')} · <u>{sablonsuzAcik ? c('gizle') : c('göster')}</u></span></button>
            <button type="button" className={`cl-kpi${ozet.bitecek.length ? ' dikkat' : ''}`}
                    onClick={() => { setYalnizBitecek(b => !b); setDurum('aktif') }}>
              <span className="k">{c('30 gün içinde süresi bitecek')}</span><span className="v">{ozet.bitecek.length}</span>
              <span className="a">{ozet.bitecek.slice(0, 2).map(b => `"${b.ad}" (${b.hekim})`).join(', ') || '—'}{ozet.bitecek.length ? <> · <u>{yalnizBitecek ? c('tümünü göster') : c('göster')}</u></> : null}</span></button>
          </div>
        )}

        {sablonsuzAcik && ozet && ozet.sablonsuz.length > 0 && (
          <div className="uyari-kutusu cl-sablonsuz">⚠ <b>{c('Şablonu olmayan doktorlar')}</b> — {c('randevu verilemez; tıklayın, şablonu açın')}:
            <span className="cl-doktorlar">{ozet.sablonsuz.map(d => (
              <button key={d.id} type="button" disabled={!yazar}
                      onClick={() => git(`/calisma-sablon/yeni?hekimId=${d.id}${d.departmanId ? `&departmanId=${d.departmanId}` : ''}`)}>
                {d.ad}{d.departman ? ` · ${d.departman}` : ''}</button>
            ))}</span></div>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}

        {secili.size > 0 && (
          <div className="cl-toplu">☑ <b>{secili.size} {c('şablon seçili')}</b>
            {toplu === 'kopyala' ? (<>
              <select value={hedefHekim} onChange={e => setHedefHekim(e.target.value ? Number(e.target.value) : '')}>
                <option value="">{c('Doktor seçin…')}</option>
                {secenek('hekimId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
              </select>
              <button type="button" className="d ck-kucuk bir" disabled={hedefHekim === ''} onClick={() => void topluCalistir('kopyala')}>✔ {c('Kopyala')}</button>
              <button type="button" className="d ck-kucuk" onClick={() => setToplu('')}>{c('Vazgeç')}</button>
            </>) : toplu === 'bitis' ? (<>
              <input type="date" value={bitis} onChange={e => setBitis(e.target.value)} />
              <button type="button" className="d ck-kucuk bir" disabled={!bitis} onClick={() => void topluCalistir('bitis')}>✔ {c('Bitiş ver')}</button>
              <button type="button" className="d ck-kucuk" onClick={() => setToplu('')}>{c('Vazgeç')}</button>
            </>) : yazar && (<>
              <button type="button" className="d ck-kucuk" onClick={() => setToplu('kopyala')}>⧉ {c('Başka doktora kopyala…')}</button>
              <button type="button" className="d ck-kucuk" onClick={() => setToplu('bitis')}>📆 {c('Bitiş tarihi ver…')}</button>
              <button type="button" className="d ck-kucuk" onClick={() => void topluCalistir('pasif')}>⏸ {c('Pasife al')}</button>
              <button type="button" className="d ck-kucuk" disabled={seciliDoktorlar.length !== 1}
                      title={seciliDoktorlar.length !== 1 ? c('İstisna tek doktorludur - tek doktorun şablonlarını seçin') : undefined}
                      onClick={() => git(`/calisma-istisna/yeni?hekimId=${seciliDoktorlar[0]}&sabit=1&geri=%2Fcalisma-sablon`)}>
                🏖 {c('Seçili doktora izin / istisna…')}</button>
            </>)}
            <button type="button" className="cl-bag cl-sag" onClick={() => setSecili(new Set())}>{c('Seçimi kaldır')} ✕</button>
          </div>
        )}

        <div className="cl-tablo">
          <table className="cl-grid">
            <thead><tr>
              <th style={{ width: 28 }}><input type="checkbox" checked={tumu} disabled={satirlar.length === 0}
                                                onChange={e => setSecili(e.target.checked ? new Set(satirlar.map(s => s.id)) : new Set())} /></th>
              <th>{c('Doktor · Bölüm')}</th><th>{c('Şube')}</th><th>{c('Şablon')}</th><th>{c('Günler')}</th><th>{c('Saatler')}</th>
              <th className="orta">{c('Slot')}</th><th>{c('Kanal')}</th><th>{c('Geçerlilik')}</th><th>{c('2 hafta doluluk')}</th><th>{c('Durum')}</th>
            </tr></thead>
            <tbody>
              {grupla ? gruplar.map(g => {
                const saat = g.filter(s => s.aktif && !s.biten).reduce((t, s) => {
                  const gun = s.gunler.split(',').filter(Boolean).length;
                  const dkm = [[s.bas1, s.bit1], [s.bas2, s.bit2]].reduce((u, [b, e]) => u + (b && e && dk(e) > dk(b) ? dk(e) - dk(b) : 0), 0);
                  return t + (dkm * gun) / (s.tekrar === 2 ? 2 : 1);
                }, 0);
                return (
                  <Fragment key={g[0].hekimId}>
                    <tr className="grupbas"><td colSpan={11}>{g[0].hekim}
                      <span>{[...new Set(g.map(s => s.departman))].join(', ')} · {g.length} {c('şablon')}{saat ? ` · ${c('haftada')} ${Math.round(saat / 6) / 10} ${c('saat')}` : ''}</span></td></tr>
                    {g.map(satir)}
                  </Fragment>
                );
              }) : satirlar.map(satir)}
              {veri && satirlar.length === 0 && <tr><td colSpan={11} className="sonuk">{c('Kayıt yok.')}</td></tr>}
            </tbody>
          </table>
        </div>
        <div className="cl-alt">{c('Kayıt')}: <b>{sayac?.tumu ?? 0}</b> · {c('gösterilen')} <b>{satirlar.length}</b>
          <span className="cl-sag sonuk">{c('Çift tık: şablon kartı')}</span></div>
      </div>

      {kartAcik && (
        <CalismaSablonKarti key={id} id={id === 'yeni' ? 'yeni' : Number(id)}
          ilkHekim={Number(sorgu.get('hekimId')) || undefined} ilkDepartman={Number(sorgu.get('departmanId')) || undefined}
          onKapat={kartKapat} />
      )}
    </>
  );
}
