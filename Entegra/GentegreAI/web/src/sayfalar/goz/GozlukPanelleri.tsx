import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { Kosul, ListeSatiri } from '../../api/sozlesme';
import type { GozlukGostergeYaniti, GozlukKaynak, GozlukOnceki, GozlukOnizleme } from '../../api/uclar/goz';
import type { EkSekmeBaglami } from '../../bilesenler/GenForm';
import { tarihSaat, tarihYaz } from '../../bilesenler/bicim';
import { c } from '../../dil/ceviri';

/**
 * GÖZLÜK REÇETESİ v2 (972-973, mockup Ekranlar/Goz/goz_gozluk_recetesi_v2.html ·
 * goz_gozluk_recete_listesi_v2.html).
 *
 *   Liste: useGozlukSuzgeci · GozlukGostergesi · GozlukSolPanel · GozlukOnizlemePaneli
 *   Kart : GozlukHastaBandi (kimlik şeridinin üstünde) · GozlukReceteFormu (tek "Reçete"
 *          sekmesi - değerler kart alanlarına baglam.alanYaz ile yazılır, kaydetme kartın yolu)
 */

export const GOZLUK_TUR: Record<number, string> = { 1: 'Uzak', 2: 'Yakın', 3: 'Bifokal', 4: 'Progresif', 5: 'Ara mesafe', 6: 'Güneş' };
const TUR_RENK: Record<number, string> = { 1: '#2f6db3', 2: '#16a085', 3: '#8e44ad', 4: '#d35400', 5: '#2c3e50', 6: '#7f8c8d' };
const DURUM: Record<number, string> = { 0: 'İptal', 1: 'Taslak', 2: 'İmzalı', 3: 'Optikte', 4: 'Teslim edildi' };
const KULLANIM: Record<number, string> = { 1: 'Sürekli', 2: 'Uzak için', 3: 'Okuma', 4: 'Bilgisayar' };
const CAM: Record<number, string> = { 1: 'Organik 1.5', 2: 'Polikarbonat', 3: '1.60', 4: '1.67', 5: '1.74', 6: 'Mineral' };
const KAPLAMA: Record<number, string> = { 1: 'Antirefle', 2: 'Sertlik', 3: 'Mavi ışık', 4: 'Fotokromik', 5: 'Polarize', 6: 'UV400' };
const TASARIM = ['Standart', 'Kısa koridor', 'Ofis'];

export function GozlukTurRozeti({ tur }: { tur: number }) {
  return <span className="gl-tur" style={{ background: TUR_RENK[tur] ?? '#7f8c8d' }}>{c(GOZLUK_TUR[tur] ?? '?')}</span>;
}

const n = (v: unknown) => (v === null || v === undefined || v === '' ? null : Number(v));
/** Reçete yazımı: +1,25 / −0,50 (işaretli, 2 hane). */
export const dpt = (v: unknown) => {
  const x = n(v);
  if (x === null || Number.isNaN(x)) return '—';
  const s = Math.abs(x).toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  return x > 0 ? `+${s}` : x < 0 ? `−${s}` : s;
};

// ------------------------------------------------------------------ LİSTE --
export type GozlukGostergeKodu = 'bugun' | 'taslak' | 'optikte' | 'bitecek' | 'sgkErken' | 'sgkHakDogdu';

export function useGozlukSuzgeci(aktif: boolean) {
  const [gosterge, setGosterge] = useState<GozlukGostergeKodu | null>(null);
  const [tur, setTur] = useState<number | null>(null);
  const [durum, setDurum] = useState<number | null>(null);
  const [optik, setOptik] = useState<number | null | 'yok'>(null);
  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    if (gosterge === 'bugun') l.push({ alan: 'bugun', op: 'esit', deger: 1 });
    if (gosterge === 'taslak') l.push({ alan: 'durum', op: 'esit', deger: 1 });
    if (gosterge === 'optikte') l.push({ alan: 'durum', op: 'esit', deger: 3 });
    if (gosterge === 'bitecek') l.push({ alan: 'bitecek', op: 'esit', deger: 1 });
    if (gosterge === 'sgkErken') l.push({ alan: 'sgkErken', op: 'esit', deger: 1 });
    if (gosterge === 'sgkHakDogdu') l.push({ alan: 'sgkHakDogdu', op: 'esit', deger: 1 });
    if (tur !== null) l.push({ alan: 'tur', op: 'esit', deger: tur });
    if (durum !== null) l.push({ alan: 'durum', op: 'esit', deger: durum });
    if (optik === 'yok') l.push({ alan: 'optikId', op: 'bos' });
    else if (optik !== null) l.push({ alan: 'optikId', op: 'esit', deger: optik });
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { gosterge, setGosterge, tur, setTur, durum, setDurum, optik, setOptik, filtre };
}
export type GozlukSuzgeci = ReturnType<typeof useGozlukSuzgeci>;

export function useGozlukGostergesi(aktif: boolean, yenile: number) {
  const [v, setV] = useState<GozlukGostergeYaniti | null>(null);
  useEffect(() => { if (aktif) api.gozlukGosterge().then(setV).catch(() => setV(null)) }, [aktif, yenile]);
  return v;
}

export function GozlukGostergesi({ veri, s }: { veri: GozlukGostergeYaniti | null; s: GozlukSuzgeci }) {
  const g = veri?.gosterge;
  const kutular: { kod: GozlukGostergeKodu; deger?: number; ad: string; sinif?: string }[] = [
    { kod: 'bugun', deger: g?.bugun, ad: 'Bugün yazılan' },
    { kod: 'taslak', deger: g?.taslak, ad: 'İmza bekleyen (taslak)', sinif: g?.taslak ? 'uyari' : undefined },
    { kod: 'optikte', deger: g?.optikte, ad: 'Optikte, teslim edilmedi' },
    { kod: 'bitecek', deger: g?.bitecek, ad: 'Geçerliliği 30 günde bitecek', sinif: g?.bitecek ? 'uyari' : undefined },
    { kod: 'sgkErken', deger: g?.sgkErken, ad: 'SGK 2 yıl dolmadan yazılan', sinif: g?.sgkErken ? 'kirmizi' : undefined },
    { kod: 'sgkHakDogdu', deger: g?.sgkHakDogdu, ad: 'SGK hakkı yeni doğan (hatırlatma)' },
  ];
  return (
    <div className="pl-kpi rc-kpi">
      {kutular.map(k => (
        <button key={k.ad} type="button" className={`pl-k${s.gosterge === k.kod ? ' on' : ''}${k.sinif ? ` ${k.sinif}` : ''}`}
                onClick={() => s.setGosterge(s.gosterge === k.kod ? null : k.kod)}>
          <b>{k.deger ?? '…'}</b><span>{c(k.ad)}</span>
        </button>
      ))}
    </div>
  );
}

export function GozlukSolPanel({ veri, s }: { veri: GozlukGostergeYaniti | null; s: GozlukSuzgeci }) {
  const toplam = (veri?.turler ?? []).reduce((a, b) => a + b.sayi, 0);
  return (
    <div className="rt-agac">
      <h6>{c('Tür')}</h6>
      <button type="button" className={`rt-dal${s.tur === null ? ' on' : ''}`} onClick={() => s.setTur(null)}><span>{c('Tümü')}</span><i>{toplam}</i></button>
      {(veri?.turler ?? []).map(t => (
        <button key={t.tur} type="button" className={`rt-dal${s.tur === t.tur ? ' on' : ''}`} onClick={() => s.setTur(s.tur === t.tur ? null : t.tur)}>
          <span><GozlukTurRozeti tur={t.tur} /></span><i>{t.sayi}</i></button>
      ))}
      <h6 style={{ marginTop: 12 }}>{c('Durum')}</h6>
      {(veri?.durumlar ?? []).map(d => (
        <button key={d.durum} type="button" className={`rt-dal${s.durum === d.durum ? ' on' : ''}`} onClick={() => s.setDurum(s.durum === d.durum ? null : d.durum)}>
          <span>{c(DURUM[d.durum] ?? String(d.durum))}</span><i>{d.sayi}</i></button>
      ))}
      <h6 style={{ marginTop: 12 }}>{c('Optik')}</h6>
      {(veri?.optikler ?? []).map(o => {
        const k = o.id ?? 'yok';
        return (
          <button key={String(k)} type="button" className={`rt-dal${s.optik === k ? ' on' : ''}`} onClick={() => s.setOptik(s.optik === k ? null : k)}>
            <span>{o.ad}</span><i>{o.sayi}</i></button>
        );
      })}
    </div>
  );
}

function MiniRecete({ r }: { r: Record<string, unknown> }) {
  return (
    <table className="gl-mini">
      <tbody>
        <tr><th /><th>Sph</th><th>Cyl</th><th>Aks</th><th>Add</th><th>PD</th></tr>
        {(['od', 'os'] as const).map(g => (
          <tr key={g}><th>{g.toUpperCase()}</th><td>{dpt(r[`${g}Sph`])}</td><td>{dpt(r[`${g}Cyl`])}</td><td>{String(r[`${g}Aks`] ?? '—')}</td>
            <td>{dpt(r[`${g}Add`] ?? r.add)}</td><td>{r[`${g}Pd`] != null ? Number(r[`${g}Pd`]).toLocaleString('tr-TR') : '—'}</td></tr>
        ))}
      </tbody>
    </table>
  );
}

export function GozlukOnizlemePaneli({ satir, yenile }: { satir: ListeSatiri | null; yenile: number }) {
  const id = satir ? Number(satir.id) : 0;
  const [r, setR] = useState<GozlukOnizleme | null>(null);
  useEffect(() => { setR(null); if (id > 0) api.gozlukOnizleme(id).then(y => setR(y.recete)).catch(() => setR(null)) }, [id, yenile]);
  if (!(id > 0)) return <div className="rt-oniz sonuk">{c('Önizleme için bir reçete seçin.')}</div>;
  if (!r) return <div className="rt-oniz sonuk">{c('yükleniyor')}…</div>;
  const durum = Number(r.durum);
  const adim = (ad: string, ok: boolean, su: boolean, ne: unknown) => (
    <div className={ok ? 'ok' : su ? 'su' : ''}>{c(ad)}<small>{ne ? (String(ne).length > 10 ? tarihSaat(ne) : tarihYaz(String(ne))) : '—'}</small></div>
  );
  const kap = String(r.kaplamalar ?? '').split(',').filter(Boolean).map(k => KAPLAMA[Number(k)]).filter(Boolean);
  return (
    <div className="rt-oniz">
      <div className="rt-bl"><h5>{c('Reçete')}</h5>
        <div className="gl-kagit-mini">
          <div style={{ display: 'flex', justifyContent: 'space-between' }}><b>{String(r.receteNo || `#${r.id}`)}</b><span>{tarihYaz(String(r.tarih))}</span></div>
          <div>{String(r.hasta)} · {c(GOZLUK_TUR[Number(r.tur)] ?? '')}{r.kullanim ? ` · ${c(KULLANIM[Number(r.kullanim)] ?? '')}` : ''}</div>
          <MiniRecete r={r} />
          {(Boolean(r.camMalzeme) || kap.length > 0 || Boolean(r.tasarim)) && <div>{[CAM[Number(r.camMalzeme)], kap.join(', '), String(r.tasarim ?? '')].filter(Boolean).join(' · ')}</div>}
          <div>{r.gecerlilik ? `${c('Geçerlilik')} ${tarihYaz(String(r.gecerlilik))}` : ''}{Number(r.sgk) === 1 ? ` · ${c('SGK’lı')}` : ''}</div>
        </div>
      </div>
      {r.oncekiTarih ? (
        <div className="rt-bl"><h5>{c('Önceki reçeteye göre')}</h5>
          <div className="rt-kucuk">{tarihYaz(String(r.oncekiTarih))} → {c('bu')}: OD sph <b className="gl-fark">{dpt(r.farkOdSph)}</b> · OS sph <b className="gl-fark">{dpt(r.farkOsSph)}</b>
            {r.farkAdd != null ? <> · add <b className="gl-fark">{dpt(r.farkAdd)}</b></> : null}</div>
        </div>
      ) : null}
      <div className="rt-bl"><h5>{c('Teslim takibi')}</h5>
        <div className="gl-adim">
          {adim('Yazıldı', true, false, r.tarih)}
          {adim(durum >= 2 ? 'İmzalandı' : 'İmza bekliyor', durum >= 2, durum === 1, r.imzaZamani)}
          {adim('Optike verildi', durum >= 3, durum === 2, null)}
          {adim('Teslim edildi', durum >= 4, durum === 3, r.teslim)}
        </div>
        {r.optik ? <div className="rt-kucuk" style={{ marginTop: 4 }}>{c('Optik')}: {String(r.optik)}</div> : null}
      </div>
    </div>
  );
}

// ------------------------------------------------------------------- KART --
export function useGozlukKaynak(aktif: boolean, q: { receteId?: number; hastaId?: number; muayeneId?: number }, yenile: number) {
  const [k, setK] = useState<GozlukKaynak | null>(null);
  useEffect(() => {
    setK(null);
    if (aktif && (q.receteId || q.hastaId)) api.gozlukKaynak(q).then(setK).catch(() => setK(null));
  }, [aktif, q.receteId, q.hastaId, q.muayeneId, yenile]);   // eslint-disable-line react-hooks/exhaustive-deps
  return k;
}

/** Kimlik şeridinin üstünde: hasta, muayene, son reçete, SGK hakkı, dilate uyarısı, durum. */
export function GozlukHastaBandi({ k, durum }: { k: GozlukKaynak | null; durum: number }) {
  if (!k) return null;
  const h = k.hasta, m = k.muayene;
  const son = k.oncekiler[0];
  return (
    <div className="gz4-ust">
      <div>
        <div className="ad">{h?.ad ?? '—'}</div>
        <div className="sonuk">{[h?.yas != null ? `${h.yas} ${h.cinsiyet === 1 ? 'E' : h.cinsiyet === 2 ? 'K' : ''}` : '',
          m ? `${c('göz muayenesi')} ${tarihSaat(m.tarih)}` : '', m?.hekim].filter(Boolean).join(' · ')}</div>
      </div>
      <div className="bil">
        <span>{c('Son reçete')}: <b>{son ? tarihYaz(son.tarih) : c('yok')}</b></span>
        <span>{c('SGK gözlük hakkı')}: {k.sgkHakVar ? <b className="gz-yesil">{c('var')}</b>
          : <b className="gz-kirmizi">{c('yok')} ({k.sgkHakTarihi ? tarihYaz(k.sgkHakTarihi) : ''} {c('itibaren')})</b>}</span>
        {m?.dilate === 1 && <span>{c('Dilate')}: <b className="gz-kirmizi">{c('evet - refraksiyon pupil genişken')}</b></span>}
      </div>
      <div className="roz"><span className={`rozet ${durum >= 2 ? 'ok' : 'uyari'}`}>{c(DURUM[durum] ?? 'Taslak')}</span></div>
    </div>
  );
}

const ADLAR = ['Sph', 'Cyl', 'Aks', 'Add', 'Prizma', 'Taban', 'Pd', 'Seg'] as const;

function Cip({ on, onClick, children, kilit }: { on: boolean; onClick(): void; children: React.ReactNode; kilit: boolean }) {
  return <button type="button" className={`gz4-c${on ? ' on' : ''}`} disabled={kilit} onClick={onClick}>{children}</button>;
}

/** Tek "Reçete" sekmesi: değerler + cam + kontroller + önceki reçeteler | sağda A5 önizleme. */
export function GozlukReceteFormu({ b, k, kopyaId }: { b: EkSekmeBaglami; k: GozlukKaynak | null; kopyaId: number | null }) {
  const d = b.deger;
  const kilit = b.saltOkunur || Number(d.durum ?? 1) >= 2;
  const yeni = !d.id;
  const yaz = (ad: string, v: unknown) => { if (!kilit) b.alanYaz(ad, v as never) };
  const [eksiCyl, setEksiCyl] = useState(true);

  // YENİ REÇETE: hekim muayeneden, SGK hakkı kuraldan, geçerlilik 6 ay; kopya ise önceki değerler.
  const [ilk, setIlk] = useState(false);
  useEffect(() => {
    // KART HAZIR OLUNCA: meta ve URL varsayılanları (hastaId) yüklenmeden yazılan değer,
    //   GenForm'un yeni kayıt kurulumunda eziliyordu.
    if (!yeni || ilk || !k || !b.meta || !d.hastaId) return;
    setIlk(true);
    if (!d.hekimId && k.muayene?.hekimId) yaz('hekimId', k.muayene.hekimId);
    yaz('sgkHak', k.sgkHakVar ? 1 : 0);
    if (!d.gecerlilikBitis) { const t = new Date(); t.setMonth(t.getMonth() + 6); yaz('gecerlilikBitis', t.toISOString().slice(0, 10)) }
    if (!d.kullanim) yaz('kullanim', 1);
    const kopya = kopyaId ? k.oncekiler.find(x => x.id === kopyaId) : null;
    if (kopya) oncekiAl(kopya);
  }, [k, yeni, b.meta, d.hastaId]);   // eslint-disable-line react-hooks/exhaustive-deps

  const refr = (tur: number) => (k?.refraksiyon ?? []).filter(r => r.tur === tur);
  const refrAl = (tur: number, ad: string) => {
    const l = refr(tur);
    for (const r of l) {
      const g = r.goz === 1 ? 'od' : 'os';
      yaz(`${g}Sph`, r.sph); yaz(`${g}Cyl`, r.cyl); yaz(`${g}Aks`, r.aks);
      if (r.add != null) yaz(`${g}Add`, r.add);
      if (r.pdUzak != null) yaz(`${g}Pd`, Math.round((Number(r.pdUzak) / 2) * 10) / 10);
      if (r.pdYakin != null) yaz('pdYakin', r.pdYakin);
    }
    yaz('degerKaynak', ad);
  };
  const oncekiAl = (o: GozlukOnceki) => {
    yaz('tur', o.tur);
    yaz('odSph', o.odSph); yaz('odCyl', o.odCyl); yaz('odAks', o.odAks); yaz('odAdd', o.add);
    yaz('osSph', o.osSph); yaz('osCyl', o.osCyl); yaz('osAks', o.osAks); yaz('osAdd', o.add);
    yaz('odPd', o.odPd); yaz('osPd', o.osPd); yaz('pdYakin', o.pdYakin);
    if (o.camMalzeme) yaz('camMalzeme', o.camMalzeme);
    yaz('kaplamalar', o.kaplamalar ?? ''); yaz('tasarim', o.tasarim ?? '');
    yaz('degerKaynak', `Önceki reçete ${tarihYaz(o.tarih)}`);
  };
  // TRANSPOZİSYON: −cyl ↔ +cyl yazımı (sph + cyl, −cyl, aks ± 90).
  const transpoze = (eksi: boolean) => {
    if (eksi === eksiCyl) return;
    setEksiCyl(eksi);
    for (const g of ['od', 'os']) {
      const sph = n(d[`${g}Sph`]), cyl = n(d[`${g}Cyl`]), aks = n(d[`${g}Aks`]);
      if (cyl === null || cyl === 0 || (eksi && cyl < 0) || (!eksi && cyl > 0)) continue;
      yaz(`${g}Sph`, Math.round(((sph ?? 0) + cyl) * 100) / 100);
      yaz(`${g}Cyl`, -cyl);
      if (aks !== null) yaz(`${g}Aks`, aks <= 90 ? aks + 90 : aks - 90);
    }
  };
  const giris = (g: 'od' | 'os', ad: typeof ADLAR[number]) => {
    const alan = `${g}${ad}`;
    const adim = ad === 'Aks' || ad === 'Taban' ? 1 : ad === 'Pd' || ad === 'Seg' ? 0.5 : 0.25;
    return (
      <input type="number" step={adim} value={d[alan] == null ? '' : String(d[alan])} disabled={kilit}
             onChange={e => yaz(alan, e.target.value === '' ? null : Number(e.target.value))} />
    );
  };
  const va = (g: number) => refr(2).find(r => r.goz === g)?.va;
  const se = (g: 'od' | 'os') => (n(d[`${g}Sph`]) ?? 0) + (n(d[`${g}Cyl`]) ?? 0) / 2;
  const add = n(d.odAdd) ?? n(d.osAdd);
  const yakin = (g: 'od' | 'os') => n(d[`${g}Sph`]) === null || add === null ? '—'
    : `${dpt((n(d[`${g}Sph`]) ?? 0) + add)}${n(d[`${g}Cyl`]) ? ` / ${dpt(d[`${g}Cyl`])} × ${d[`${g}Aks`] ?? ''}` : ''}`;
  const kap = String(d.kaplamalar ?? '').split(',').filter(Boolean);
  const kapDegis = (kod: string) => yaz('kaplamalar', (kap.includes(kod) ? kap.filter(x => x !== kod) : [...kap, kod]).sort().join(','));
  const yas = k?.hasta?.yas ?? null;
  const kontroller: [string, string][] = [];
  if (k?.muayene?.dilate === 1) kontroller.push(['uy', 'Dilate muayene: refraksiyon pupil genişken alındı - VA değerini kontrol edin.']);
  for (const [g, ad] of [[1, 'Sağ'], [2, 'Sol']] as const) {
    const v = va(g); if (v != null && v < 0.5) kontroller.push(['uy', `${ad} göz düzeltilmiş VA ${String(v).replace('.', ',')}: reçete görmeyi tam açmıyor.`]);
  }
  if (n(d.odSph) !== null && n(d.osSph) !== null) {
    const f = Math.abs(se('od') - se('os'));
    kontroller.push(f >= 1.5 ? ['kr', `Anizometropi: iki göz farkı ${f.toFixed(2).replace('.', ',')} D - aniseikoni / ambliyopi riski.`] : ['ok', 'Anizometropi yok']);
  }
  if (add !== null && yas !== null) kontroller.push(yas < 38 && add > 0 ? ['uy', `Add ${dpt(add)}: ${yas} yaş için beklenmez.`] : add > 3 ? ['uy', `Add ${dpt(add)} yüksek.`] : ['ok', `Add ${yas} yaş için uygun`]);
  if (Number(d.sgkHak) === 1) kontroller.push(k?.sgkHakVar ? ['ok', 'SGK: son SGK’lı reçeteden 2 yıl geçti'] : ['kr', `SGK: 2 yıl dolmadı (${k?.sgkHakTarihi ? tarihYaz(k.sgkHakTarihi) : ''}) - reçete ücretli olabilir`]);
  const tur = Number(d.tur ?? 1);
  const camAd = CAM[Number(d.camMalzeme)];

  return (
    <div className="gl-govde">
      <div className="gl-sol">
        <div className="gz4-sat"><span className="et">{c('Tür')}</span>
          {Object.entries(GOZLUK_TUR).map(([kod, ad]) => <Cip key={kod} kilit={kilit} on={tur === Number(kod)} onClick={() => yaz('tur', Number(kod))}>{c(ad)}</Cip>)}</div>
        <div className="gz4-sat"><span className="et">{c('Kullanım')}</span>
          {Object.entries(KULLANIM).map(([kod, ad]) => <Cip key={kod} kilit={kilit} on={Number(d.kullanim) === Number(kod)} onClick={() => yaz('kullanim', Number(kod))}>{c(ad)}</Cip>)}</div>

        <div className="gl-bas">
          <b>{c('Reçete değerleri')}</b>
          <span style={{ flex: 1 }} />
          <Cip kilit={kilit} on={eksiCyl} onClick={() => transpoze(true)}>− {c('silindir')}</Cip>
          <Cip kilit={kilit} on={!eksiCyl} onClick={() => transpoze(false)}>+ {c('silindir')}</Cip>
        </div>
        {!kilit && (
          <div className="gl-kaynak">{c('Değerleri al')}:
            <button type="button" className="d kucuk" disabled={refr(2).length === 0} onClick={() => refrAl(2, 'Subjektif refraksiyon')}>⇩ {c('Subjektif (bu muayene)')}</button>
            <button type="button" className="d kucuk" disabled={refr(3).length === 0} onClick={() => refrAl(3, 'Sikloplejik')}>⇩ {c('Sikloplejik')}</button>
            <button type="button" className="d kucuk" disabled={refr(5).length === 0} onClick={() => refrAl(5, 'Mevcut gözlük')}>⇩ {c('Mevcut gözlük')}</button>
            <button type="button" className="d kucuk" disabled={!k?.oncekiler.length} onClick={() => k && oncekiAl(k.oncekiler[0])}>⇩ {c('Önceki reçete')}</button>
          </div>
        )}
        <table className="gl-rx">
          <thead><tr><th /><th>Sph</th><th>Cyl</th><th>Aks</th><th>Add</th><th>{c('Prizma')} Δ</th><th>{c('Taban')}</th><th>PD</th><th>{c('Seg / montaj')}</th><th>VA</th></tr></thead>
          <tbody>
            {(['od', 'os'] as const).map(g => (
              <tr key={g}><td className={`g ${g}`}>{g === 'od' ? c('OD · Sağ') : c('OS · Sol')}</td>
                {ADLAR.map(a => <td key={a}>{giris(g, a)}</td>)}
                <td>{va(g === 'od' ? 1 : 2) != null ? String(va(g === 'od' ? 1 : 2)).replace('.', ',') : '—'}</td></tr>
            ))}
            <tr className="gl-yakin"><td>{c('Yakın')}</td><td colSpan={4}>OD {yakin('od')} · OS {yakin('os')}</td>
              <td colSpan={2} /><td>{c('PD yakın')}<input type="number" step={0.5} value={d.pdYakin == null ? '' : String(d.pdYakin)} disabled={kilit}
                onChange={e => yaz('pdYakin', e.target.value === '' ? null : Number(e.target.value))} /></td><td colSpan={2} /></tr>
          </tbody>
        </table>
        {d.degerKaynak ? <div className="sonuk rt-kucuk">{c('Kaynak')}: {String(d.degerKaynak)}</div> : null}

        <div className="gz4-gr2">
          <div className="gz4-kart">
            <h6>{c('Cam & tasarım')}</h6>
            <div className="gz4-sat"><span className="et">{c('Malzeme')}</span>
              {Object.entries(CAM).map(([kod, ad]) => <Cip key={kod} kilit={kilit} on={Number(d.camMalzeme) === Number(kod)} onClick={() => yaz('camMalzeme', Number(kod))}>{ad}</Cip>)}</div>
            <div className="gz4-sat"><span className="et">{c('Kaplama')}</span>
              {Object.entries(KAPLAMA).map(([kod, ad]) => <Cip key={kod} kilit={kilit} on={kap.includes(kod)} onClick={() => kapDegis(kod)}>{c(ad)}</Cip>)}</div>
            {tur === 4 && <div className="gz4-sat"><span className="et">{c('Progresif')}</span>
              {TASARIM.map(t => <Cip key={t} kilit={kilit} on={d.tasarim === t} onClick={() => yaz('tasarim', t)}>{c(t)}</Cip>)}</div>}
            <div className="gz4-sat"><span className="et">{c('Optiğe not')}</span>
              <input className="gl-not" value={String(d.notOptik ?? '')} disabled={kilit} maxLength={600} onChange={e => yaz('notOptik', e.target.value)} /></div>
          </div>
          <div className="gz4-kart">
            <h6>{c('Kontroller')}</h6>
            {kontroller.length === 0 ? <div className="sonuk rt-kucuk">{c('Değer girildikçe denetlenir.')}</div>
              : kontroller.map(([t, m], i) => <div key={i} className={`gl-k ${t}`}>{t === 'ok' ? '✓' : t === 'kr' ? '⛔' : '⚠'} {c(m)}</div>)}
          </div>
        </div>

        <div className="gz4-kart">
          <h6>{c('Önceki reçeteler')}</h6>
          {!k?.oncekiler.length ? <div className="sonuk rt-kucuk">{c('Önceki reçete yok.')}</div> : (
            <table className="gz4-mini"><tbody>
              <tr><th>{c('Tarih')}</th><th>{c('Tür')}</th><th>OD</th><th>OS</th><th>Add</th><th>{c('Durum')}</th><th /></tr>
              {k.oncekiler.map(o => (
                <tr key={o.id}><td>{tarihYaz(o.tarih)}</td><td>{c(GOZLUK_TUR[o.tur] ?? '')}</td>
                  <td>{dpt(o.odSph)}{o.odCyl ? ` / ${dpt(o.odCyl)} × ${o.odAks ?? ''}` : ''}</td>
                  <td>{dpt(o.osSph)}{o.osCyl ? ` / ${dpt(o.osCyl)} × ${o.osAks ?? ''}` : ''}</td>
                  <td>{dpt(o.add)}</td><td>{c(DURUM[o.durum] ?? '')}</td>
                  <td>{!kilit && <button type="button" className="d kucuk" onClick={() => oncekiAl(o)}>⧉ {c('kopyala')}</button>}</td></tr>
              ))}
            </tbody></table>
          )}
        </div>
      </div>

      <div className="gl-sag">
        <div className="rt-baslik">{c('Önizleme')} <span className="sonuk">A5</span></div>
        <div className="gl-kagit" id="gozluk-onizleme">
          <div className="kb"><div><b>{c('GÖZLÜK REÇETESİ')}</b><br />{c('Göz Polikliniği')}</div>
            <div style={{ textAlign: 'right' }}>{c('No')}: {String(d.receteNo || '—')}<br />{tarihYaz(new Date().toISOString().slice(0, 10))}</div></div>
          <div><b>{c('Hasta')}:</b> {k?.hasta?.ad ?? '—'}{k?.hasta?.yas != null ? ` · ${k.hasta.yas}` : ''}</div>
          <MiniRecete r={d as Record<string, unknown>} />
          <div><b>{c('Tür')}:</b> {c(GOZLUK_TUR[tur] ?? '')}{d.kullanim ? ` · ${c(KULLANIM[Number(d.kullanim)] ?? '')}` : ''}</div>
          {(camAd || kap.length > 0) && <div><b>{c('Cam')}:</b> {[camAd, kap.map(x => c(KAPLAMA[Number(x)])).join(', '), tur === 4 ? d.tasarim : ''].filter(Boolean).join(' · ')}</div>}
          {d.notOptik ? <div><b>{c('Not')}:</b> {String(d.notOptik)}</div> : null}
          <div><b>{c('Geçerlilik')}:</b> {d.gecerlilikBitis ? tarihYaz(String(d.gecerlilikBitis)) : '—'}{Number(d.sgkHak) === 1 ? ` · ${c('SGK’lı')}` : ''}</div>
          <div className="imza"><div className="qr" title={c('Reçete doğrulama QR - imzada üretilir')} />
            <div className="cz">{k?.muayene?.hekim || c('Hekim')}<br />{d.imzaZamani ? `${c('e-imza')} ${tarihSaat(d.imzaZamani)}` : c('(imza bekliyor)')}</div></div>
        </div>
        <div className="sonuk rt-kucuk" style={{ marginTop: 8 }}>{c('İmzalanınca değerler kilitlenir; değişiklik yeni reçete ister. QR: optik okutunca reçete açılır, teslim işaretlenir.')}</div>
      </div>
    </div>
  );
}

/** A5 önizlemeyi yeni pencerede yazdırır. */
export function gozlukYazdir() {
  const el = document.getElementById('gozluk-onizleme');
  if (!el) return;
  const w = window.open('', '_blank', 'width=620,height=800');
  if (!w) return;
  const css = Array.from(document.querySelectorAll('style, link[rel=stylesheet]')).map(x => x.outerHTML).join('');
  w.document.write(`<!doctype html><html><head><meta charset="utf-8"><title>Gözlük Reçetesi</title>${css}
    <style>@page{size:A5;margin:10mm} body{background:#fff;padding:0} .gl-kagit{box-shadow:none;border:none}</style></head>
    <body>${el.outerHTML}</body></html>`);
  w.document.close();
  w.onload = () => { w.focus(); w.print() };
}
