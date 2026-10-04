import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni, type Kosul, type ListeSatiri } from '../../api/sozlesme';
import type { CihazDoz, CihazGostergeYaniti, CihazKullanim, CihazOzet } from '../../api/uclar/radyolojiTanim';
import { sayi, tarihSaat } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';
import { Modal } from '../../bilesenler/Modal';

/**
 * RADYOLOJİ CİHAZ LİSTESİ + KARTI PARÇALARI (967, mockup
 * Ekranlar/Radyoloji/radyoloji_cihaz_listesi_v2.html · radyoloji_cihaz_karti_v2.html).
 *
 *   useCihazSuzgeci        gösterge kutusu + konum + şu an durumu → Liste filtre zinciri
 *   CihazGostergesi        gridin üstü; kutu = süzgeç (tekrar tıkla = kaldır)
 *   CihazSolPanel          konum (oda) + şu an durumu - GenGrid sol paneli (katlanır)
 *   CihazOnizlemePaneli    seçili cihaz - GenGrid yan paneli (katlanır)
 *   CihazKapasite / CihazBaglantiTest / CihazKullanimSekmesi / CihazDozSekmesi  kart parçaları
 */
export type CihazGostergeKodu = 'calisiyor' | 'bakim' | 'ariza' | 'qa' | 'baglanti';

export function useCihazSuzgeci(aktif: boolean) {
  const [gosterge, setGosterge] = useState<CihazGostergeKodu | null>(null);
  const [oda, setOda] = useState<string | null>(null);
  const [suAn, setSuAn] = useState<number | null>(null);
  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    if (gosterge === 'calisiyor') l.push({ alan: 'suAnKod', op: 'esit', deger: 1 });
    if (gosterge === 'bakim') l.push({ alan: 'suAnKod', op: 'esit', deger: 2 });
    if (gosterge === 'ariza') l.push({ alan: 'suAnKod', op: 'esit', deger: 3 });
    if (gosterge === 'qa') l.push({ alan: 'qaGeciken', op: 'buyuk', deger: 0 });
    if (gosterge === 'baglanti') l.push({ alan: 'goruntuEksik', op: 'buyuk', deger: 0 });
    if (oda !== null) l.push(oda === '(oda yok)' ? { alan: 'oda', op: 'esit', deger: '' } : { alan: 'oda', op: 'esit', deger: oda });
    if (suAn !== null) l.push({ alan: 'suAnKod', op: 'esit', deger: suAn });
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { gosterge, setGosterge, oda, setOda, suAn, setSuAn, filtre };
}
export type CihazSuzgeci = ReturnType<typeof useCihazSuzgeci>;

export function useCihazGostergesi(aktif: boolean, yenile: number) {
  const [v, setV] = useState<CihazGostergeYaniti | null>(null);
  useEffect(() => { if (aktif) api.radCihazGosterge().then(setV).catch(() => setV(null)) }, [aktif, yenile]);
  return v;
}

export function CihazGostergesi({ veri, s }: { veri: CihazGostergeYaniti | null; s: CihazSuzgeci }) {
  const g = veri?.gosterge;
  const kutular: { kod: CihazGostergeKodu | null; deger?: number; ad: string; sinif?: string }[] = [
    { kod: null, deger: g?.aktif, ad: 'Aktif cihaz' },
    { kod: 'calisiyor', deger: g?.calisiyor, ad: 'Şu an çalışıyor' },
    { kod: 'bakim', deger: g?.bakim, ad: 'Bakım / kapalı', sinif: g?.bakim ? 'uyari' : undefined },
    { kod: 'ariza', deger: g?.ariza, ad: 'Arızada', sinif: g?.ariza ? 'kirmizi' : undefined },
    { kod: 'qa', deger: g?.qaGecikti, ad: 'QA / lisans gecikti', sinif: g?.qaGecikti ? 'kirmizi' : undefined },
    { kod: 'baglanti', deger: g?.baglanti, ad: 'Görüntüsü eksik çekim', sinif: g?.baglanti ? 'uyari' : undefined },
  ];
  return (
    <div className="pl-kpi rc-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" className={`pl-k${s.gosterge === k.kod ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                onClick={() => s.setGosterge(k.kod === null || s.gosterge === k.kod ? null : k.kod)}>
          <b>{k.deger ?? '…'}</b><span>{c(k.ad)}</span>
        </button>
      ))}
    </div>
  );
}

const SU_AN: [number, string, string][] = [[1, 'Çalışıyor', '#2e7d46'], [2, 'Bakımda / kapalı', '#e0a33a'], [3, 'Arızada', '#b3261e'], [0, 'Pasif', '#b9c4d0']];

export function CihazSolPanel({ veri, s }: { veri: CihazGostergeYaniti | null; s: CihazSuzgeci }) {
  const toplam = (veri?.konumlar ?? []).reduce((a, b) => a + b.sayi, 0);
  return (
    <div className="rt-agac">
      <h6>{c('Konum')}</h6>
      <button type="button" className={`rt-dal${s.oda === null ? ' on' : ''}`} onClick={() => s.setOda(null)}><span>{c('Tümü')}</span><i>{toplam}</i></button>
      {(veri?.konumlar ?? []).map(k => (
        <button key={k.oda} type="button" className={`rt-dal${s.oda === k.oda ? ' on' : ''}`} onClick={() => s.setOda(k.oda)}>
          <span>{k.oda}</span><i>{k.sayi}</i></button>
      ))}
      <h6 style={{ marginTop: 12 }}>{c('Durum')}</h6>
      {SU_AN.map(([kod, ad, renk]) => (
        <button key={kod} type="button" className={`rt-dal${s.suAn === kod ? ' on' : ''}`} onClick={() => s.setSuAn(s.suAn === kod ? null : kod)}>
          <span><span className="rc-nokta" style={{ background: renk }} />{c(ad)}</span></button>
      ))}
    </div>
  );
}

function Satir({ s, d }: { s: string; d: React.ReactNode }) {
  return <div className="rt-satir"><span>{s}</span><b>{d}</b></div>;
}

export function CihazOnizlemePaneli({ satir, yenile }: { satir: ListeSatiri | null; yenile: number }) {
  const id = satir ? Number(satir.id) : 0;
  const [o, setO] = useState<CihazOzet | null>(null);
  useEffect(() => { setO(null); if (id > 0) api.radCihazOzet(id).then(setO).catch(() => setO(null)) }, [id, yenile]);
  if (!(id > 0)) return <div className="rt-oniz sonuk">{c('Önizleme için bir cihaz seçin.')}</div>;
  if (!o) return <div className="rt-oniz sonuk">{c('yükleniyor')}…</div>;
  const k = o.cihaz;
  const enCok = Math.max(1, ...o.saatlik.map(x => x.adet));
  const simdi = new Date().getHours();
  return (
    <div className="rt-oniz">
      <div className="rt-bl"><h5>{c('Seçili cihaz')}</h5>
        <div className="rt-ad">{k.kod} · {k.ad}</div>
        {k.model && <Satir s={c('Model')} d={k.model} />}
        <Satir s={c('Oda / sorumlu')} d={[k.oda, k.sorumlu].filter(Boolean).join(' · ') || '—'} />
        <Satir s={c('Mesai / slot')} d={k.mesai} />
        <Satir s={c('Şu an')} d={<span className={`rozet ${k.suAnKod === 1 ? 'olumlu' : k.suAnKod === 3 ? 'hata' : k.suAnKod === 2 ? 'uyari' : 'gri'}`}>{c(k.suAn)}</span>} />
      </div>
      <div className="rt-bl"><h5>{c('Bugün')}</h5>
        <Satir s={c('Randevu')} d={k.bugunRandevu} />
        <Satir s={c('Çekildi / sırada')} d={`${k.bugunCekim} / ${k.sirada}`} />
        <Satir s={c('Sıradaki boş slot')} d={o.bosSlot ?? '—'} />
        {o.saatlik.length > 0 && (
          <>
            <div className="rc-saatlik">{Array.from({ length: 11 }, (_, i) => i + 8).map(sa => {
              const a = o.saatlik.find(x => x.saat === sa)?.adet ?? 0;
              return <i key={sa} title={`${sa}:00 · ${a}`} className={sa === simdi ? 'su' : undefined} style={{ height: `${(a / enCok) * 100}%` }} />;
            })}</div>
            <div className="rc-saat-etiket"><span>08</span><span>13</span><span>18</span></div>
          </>
        )}
      </div>
      {o.kapatma && (
        <div className="rt-bl"><h5>{c('Yaklaşan kapatma')}</h5>
          <Satir s={`${tarihSaat(o.kapatma.baslangic)} - ${tarihSaat(o.kapatma.bitis).slice(11)}`}
                 d={<span className={`rozet ${o.kapatma.nedenTur === 2 ? 'hata' : 'mavi'}`}>{o.kapatma.nedenTur === 2 ? c('Arıza') : o.kapatma.nedenTur === 1 ? c('Bakım') : c('Kapalı')}</span>} />
          <Satir s={c('Etkilenen randevu')} d={o.kapatma.etkilenen} />
        </div>
      )}
      {(k.qaGecikenAd || k.goruntuEksik > 0 || o.dozUstu > 0) && (
        <div className="rt-bl"><h5>{c('Uyarılar')}</h5>
          {k.qaGecikenAd && <div className="tl-uyari rt-kucuk">⛔ {c('Gecikmiş kalite kontrol')}: {k.qaGecikenAd}</div>}
          {k.goruntuEksik > 0 && <div className="tl-uyari rt-kucuk">⚠ {k.goruntuEksik} {c('çekimin görüntüsü PACS\'ta yok (son 2 gün)')}</div>}
          {o.dozUstu > 0 && <div className="tl-uyari rt-kucuk">☢ {o.dozUstu} {c('protokolde ortalama doz hedefin üstünde (30 gün)')}</div>}
        </div>
      )}
    </div>
  );
}

// ------------------------------------------------------------ kart parçaları --
const GUN = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const dk = (s: unknown) => { const m = /^(\d{1,2}):(\d{2})$/.exec(String(s ?? '')); return m ? Number(m[1]) * 60 + Number(m[2]) : null };

/** Randevu ayarları sekmesinin altında: çalışma günleri + günlük / haftalık kapasite (girilen değerlerden). */
export function CihazKapasite({ deger }: { deger: Record<string, unknown> }) {
  const bas = dk(deger.baslangicSaat), bit = dk(deger.bitisSaat), ob = dk(deger.ogleBaslangic), oe = dk(deger.ogleBitis);
  const slot = Number(deger.slotDk ?? 0), es = Math.max(1, Number(deger.eszaman ?? 1)), acil = Number(deger.acilSlot ?? 0);
  const gunler = String(deger.calismaGunleri ?? '').split(',').map(x => Number(x.trim())).filter(x => x >= 1 && x <= 7);
  const randevulu = deger.randevuVerilir === true || Number(deger.randevuVerilir) === 1;
  const gunluk = bas !== null && bit !== null && slot > 0
    ? Math.floor(Math.max(0, bit - bas - (ob !== null && oe !== null ? oe - ob : 0)) / slot) * es : 0;
  return (
    <div className="rc-kapasite">
      <h6 className="rt-baslik">{c('Kapasite')}</h6>
      {!randevulu ? <div className="sonuk">{c('Randevu verilmiyor - cihaz randevusuz (sıra ile) çalışır.')}</div> : (<>
        <div className="rc-gunler">{GUN.map((g, i) => <span key={g} className={gunler.includes(i + 1) ? 'on' : ''}>{c(g)}</span>)}</div>
        <div className="rt-satir"><span>{c('Günlük slot')}</span><b>{gunluk}{acil > 0 ? ` (${c('acil için')} ${acil})` : ''}</b></div>
        <div className="rt-satir"><span>{c('Haftalık kapasite')}</span><b>{gunluk * gunler.length} {c('slot')}</b></div>
      </>)}
    </div>
  );
}

/** Genel sekmesinin altında: IP / port bağlantı testi (TCP - port açık mı). */
export function CihazBaglantiTest({ id }: { id: number }) {
  const [s, setS] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const dene = async () => {
    setMesgul(true); setS(null);
    try {
      const y = await api.radCihazBaglantiTest(id);
      setS(y.acik ? `✅ ${y.ip}:${y.port} ${c('yanıt verdi')} (${y.ms} ms)` : `❌ ${y.ip}:${y.port} - ${y.hata ?? c('yanıt yok')}`);
    } catch (e) { setS(`❌ ${hataMetni(e)}`) } finally { setMesgul(false) }
  };
  return (
    <div className="rc-baglanti">
      <button type="button" className="d" disabled={mesgul} onClick={() => void dene()}>🔌 {c('Bağlantıyı test et')}</button>
      {s && <span>{s}</span>}
      <span className="sonuk rt-kucuk">{c('TCP bağlantısı denenir (port açık mı); DICOM C-ECHO değildir.')}</span>
    </div>
  );
}

export function CihazKullanimSekmesi({ id }: { id: number }) {
  const [k, setK] = useState<CihazKullanim | null>(null);
  useEffect(() => { api.radCihazKullanim(id).then(setK).catch(() => setK(null)) }, [id]);
  if (!k) return <div className="sonuk" style={{ padding: 16 }}>{c('yükleniyor')}…</div>;
  const o = k.ozet;
  const doluluk = o.haftaKapasite ? Math.round((o.randevu / (o.haftaKapasite * 30 / 7)) * 100) : null;
  const enCok = Math.max(1, ...k.gunluk.map(g => g.adet));
  return (
    <div className="rt-sekme">
      <div className="pl-kpi rc-kpi4">
        <div className="pl-k"><b>{o.cekim}</b><span>{c('Çekim · son 30 gün')}</span></div>
        <div className="pl-k"><b>{doluluk !== null ? `%${doluluk}` : '—'}</b><span>{c('Slot doluluğu')}</span></div>
        <div className="pl-k"><b>{o.ortSure != null ? `${o.ortSure} dk` : '—'}</b><span>{c('Ortalama randevu süresi')}</span></div>
        <div className="pl-k"><b>{o.randevu ? `%${Math.round((o.gelmediIptal / o.randevu) * 100)}` : '—'}</b><span>{c('Gelmedi / iptal')}</span></div>
      </div>
      <h6 className="rt-baslik">{c('Günlük çekim · son 30 gün')} <span className="sonuk">({c('gri: hafta sonu')})</span></h6>
      <div className="rc-gunluk">{k.gunluk.map(g => (
        <i key={g.gun} title={`${g.gun.slice(0, 10)} · ${g.adet}`} className={g.hgun >= 6 ? 'hs' : undefined}
           style={{ height: `${Math.max(2, (g.adet / enCok) * 100)}%` }} />
      ))}</div>
      <div className="rt-satir" style={{ marginTop: 8 }}><span>{c('Arıza nedeniyle kayıp')}</span><b>{o.arizaSaat ? `${sayi.format(o.arizaSaat)} ${c('saat')}` : '—'}</b></div>
    </div>
  );
}

export function CihazDozSekmesi({ id }: { id: number }) {
  const [d, setD] = useState<CihazDoz | null>(null);
  useEffect(() => { api.radCihazDoz(id).then(setD).catch(() => setD(null)) }, [id]);
  if (!d) return <div className="sonuk" style={{ padding: 16 }}>{c('yükleniyor')}…</div>;
  const ust = (o: number | null, h: number | null) => o != null && h != null && o > h;
  return (
    <div className="rt-sekme">
      <h6 className="rt-baslik">{c('Doz izleme · son 30 gün')} <span className="sonuk">({c('çekimlerin CTDIvol / DLP değerinden; hedef protokolden')})</span></h6>
      {d.satirlar.length === 0 ? <div className="sonuk">{c('Son 30 günde doz değeri girilmiş çekim yok.')}</div> : (
        <table className="rt-tablo">
          <thead><tr><th>{c('Tetkik')}</th><th className="sag">{c('Çekim')}</th><th className="sag">{c('Ort. CTDIvol')}</th><th className="sag">{c('Hedef')}</th>
            <th className="sag">{c('Ort. DLP')}</th><th className="sag">{c('Hedef')}</th><th className="sag">DRL</th><th>{c('Durum')}</th></tr></thead>
          <tbody>{d.satirlar.map(r => {
            const asim = ust(r.ctdiOrt, r.ctdiHedef) || ust(r.dlpOrt, r.dlpHedef);
            return (
              <tr key={r.tetkik}><td>{r.tetkik}</td><td className="sag">{r.adet}</td>
                <td className="sag">{r.ctdiOrt ?? '—'}</td><td className="sag">{r.ctdiHedef ?? '—'}</td>
                <td className="sag">{r.dlpOrt ?? '—'}</td><td className="sag">{r.dlpHedef ?? '—'}</td><td className="sag">{r.drl ?? '—'}</td>
                <td>{r.ctdiHedef == null && r.dlpHedef == null ? <span className="rozet gri">{c('hedef yok')}</span>
                  : asim ? <span className="rozet uyari">{c('hedef üstü')}</span> : <span className="rozet olumlu">{c('hedefte')}</span>}
                  {r.drlUstu > 0 && <span className="rozet hata" style={{ marginLeft: 4 }}>{r.drlUstu} DRL {c('üstü')}</span>}</td></tr>
            );
          })}</tbody>
        </table>
      )}
    </div>
  );
}

const HGUN = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

/**
 * BU HAFTA KAPASİTE (Randevu ayarları sekmesinin sağı, mockup): gün x saat,
 * hücrede BOŞ slot sayısı; yeşil boş · mavi dolu · kırmızı kapalı / arıza ·
 * gri öğle / çalışmıyor. Sunucu kayıtlı ayardan hesaplar - kaydedilmemiş
 * değişiklik ızgaraya Kaydet'ten sonra yansır.
 */
export function CihazHaftaKapasite({ id, yenile }: { id: number; yenile: number }) {
  const [h, setH] = useState<import('../../api/uclar/radyolojiTanim').CihazHafta | null>(null);
  useEffect(() => { api.radCihazHafta(id).then(setH).catch(() => setH(null)) }, [id, yenile]);
  if (!h) return <div className="sonuk rt-kucuk">{c('yükleniyor')}…</div>;
  if (!h.randevulu) return <div className="sonuk rt-kucuk">{c('Randevu verilmiyor ya da mesai girilmemiş.')}</div>;
  return (
    <div className="rc-hafta">
      <h6 className="rt-baslik">{c('Bu hafta kapasite')} <span className="sonuk">({c('boş slot')} · {c('yeşil boş · mavi dolu · kırmızı kapalı')})</span></h6>
      <table>
        <thead><tr><th />{HGUN.map(g => <th key={g}>{c(g)}</th>)}</tr></thead>
        <tbody>{h.satirlar.map(s => (
          <tr key={s.saat}><th>{s.saat}</th>{s.gunler.map((g, i) => (
            <td key={i} className={`rc-h-${g.tur === 'acik' ? (g.bos === 0 && g.kapasite > 0 ? 'dolu' : 'bos') : g.tur}`}
                title={g.tur === 'acik' ? `${g.dolu} / ${g.kapasite}` : undefined}>
              {g.tur === 'acik' ? g.bos : g.tur === 'ogle' ? c('öğle') : g.tur === 'ariza' ? c('arıza') : g.tur === 'kapali' ? c('kapalı') : '—'}
            </td>
          ))}</tr>
        ))}</tbody>
      </table>
      <div className="rt-satir"><span>{c('Haftalık')}</span><b>{h.dolu ?? 0} / {h.toplam ?? 0} {c('slot dolu')}{h.toplam ? ` (%${Math.round(((h.dolu ?? 0) / h.toplam) * 100)})` : ''}</b></div>
    </div>
  );
}

/** "Kapat / bakıma al" penceresi. */
export function CihazKapatModali({ id, onKapat, onTamam }: { id: number; onKapat(): void; onTamam(etkilenen: number): void }) {
  const simdi = new Date(); simdi.setSeconds(0, 0);
  const yerel = (d: Date) => new Date(d.getTime() - d.getTimezoneOffset() * 60000).toISOString().slice(0, 16);
  const [neden, setNeden] = useState(1);
  const [bas, setBas] = useState(yerel(simdi));
  const [bit, setBit] = useState(yerel(new Date(simdi.getTime() + 4 * 3600000)));
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState<string | null>(null);
  const kaydet = async () => {
    setHata(null);
    try {
      const y = await api.radCihazKapat(id, { nedenTur: neden, baslangic: new Date(bas).toISOString(), bitis: new Date(bit).toISOString(), aciklama });
      onTamam(y.etkilenen);
    } catch (e) { setHata(hataMetni(e)) }
  };
  return (
    <Modal baslik={`⛔ ${c('Cihazı kapat / bakıma al')}`} buyutmeYok onKapat={onKapat}
           alt={<><button type="button" className="d bir" onClick={() => void kaydet()}>{c('Kapat')}</button>
                  <span className="ck-bosluk" /><button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button></>}>
      <div className="rc-kapat">
        <div className="ck-cipler">{([[1, 'Bakım'], [2, 'Arıza'], [3, 'Tatil'], [9, 'Diğer']] as [number, string][]).map(([k, a]) => (
          <button key={k} type="button" className={`ck-cip${neden === k ? ' on' : ''}`} onClick={() => setNeden(k)}>{c(a)}</button>
        ))}</div>
        <label className="rk-fld"><span className="ck-etiket">{c('Başlangıç')}</span><input type="datetime-local" value={bas} onChange={e => setBas(e.target.value)} /></label>
        <label className="rk-fld"><span className="ck-etiket">{c('Bitiş')}</span><input type="datetime-local" value={bit} onChange={e => setBit(e.target.value)} /></label>
        <label className="rk-fld"><span className="ck-etiket">{c('Açıklama')}</span><input value={aciklama} maxLength={200} onChange={e => setAciklama(e.target.value)} /></label>
        {hata && <div className="hata-kutusu">{hata}</div>}
        <div className="sonuk rt-kucuk">{c('Bu aralıkta takvim kapalı çizilir, randevu verilmez. Aralıktaki randevular taşınmaz - sayısı bildirilir.')}</div>
      </div>
    </Modal>
  );
}
