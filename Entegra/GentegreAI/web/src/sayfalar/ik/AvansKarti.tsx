import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { devamDurumu, personelTalepDurumu } from '../../bilesenler/taleplerim/personelTalebi';
import { api } from '../../api/istemci';
import { hataMetni, type DokumanSatiri } from '../../api/sozlesme';
import { Modal } from '../../bilesenler/Modal';
import { TarafArama } from '../../bilesenler/TarafArama';
import { guvenli, metinSor, onay } from '../../bilesenler/mesaj';
import { para, tarihSaat, tutarOku, bugunIso } from '../../bilesenler/bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { useTaleplerim } from '../../bilesenler/taleplerim/taleplerimBaglami';
import { talepleriYenile } from '../../bilesenler/taleplerim/useTaleplerimOzeti';
import { c } from '../../dil/ceviri';

/**
 * PERSONEL AVANSI KARTI `/personel-avans/:id` (960, mockup Ekranlar/IK/avans_karti.html).
 *
 * Sol: tutar (hızlı çipler), taksit (azami kurum ayarı), ilk kesinti dönemi,
 * aylık kesinti, gerekçe (seçimli), açıklama; kesinti planı (taslakta canlı,
 * ödenince gerçek satırlar); ödeme (yalnız onaylıda). Sağ: maaşa oranı, açık
 * avans uyarısı, onay zinciri, geçmiş, belgeler, akış. Onaya gidince kilitli.
 */
const KAYNAK = 'personelAvans';
const AVANS_TUR = 1257;
const DURUM: Record<number, [string, string]> = {
  0: ['Taslak', 'tl-c-gri'], 1: ['Onayda', 'tl-c-bek'], 2: ['Onaylandı · ödenecek', 'tl-c-mavi'], 3: ['Reddedildi', 'tl-c-red'],
  4: ['Ödendi · kesintide', 'tl-c-mavi'], 5: ['Kapandı', 'tl-c-ok'], 8: ['İptal', 'tl-c-gri'],
};
const s10 = (v: unknown) => String(v ?? '').slice(0, 10);
/** "2026-11" → "Kasım 2026" */
const donemAd = (d: string) => {
  if (!/^\d{4}-\d{2}$/.test(d)) return d || '—';
  return new Date(`${d}-01T00:00:00`).toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' });
};
const sonrakiAy = (n = 1) => {
  const d = new Date(); d.setDate(1); d.setMonth(d.getMonth() + n);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
};
const ayEkle = (donem: string, n: number) => {
  const d = new Date(`${donem}-01T00:00:00`); d.setMonth(d.getMonth() + n);
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
};
const yazP = (n: number) => para.format(Math.round(n * 100) / 100);

interface Deger { tarafId: number; tutar: string; taksit: number; ilkDonem: string; gerekce: string; aciklama: string }

/** Kimlik değişince kart baştan kurulur. */
export function AvansKarti() {
  const { id } = useParams();
  return <AvansKartiIc key={id ?? ''} param={id} />;
}

function AvansKartiIc({ param }: { param: string | undefined }) {
  const git = useNavigate();
  // PERSONEL LİSTESİNDEN (Yeni Talep ▾): seçili personel dolu gelir, Kapat listeye döner.
  const pt = personelTalepDurumu(useLocation().state);
  const { yetki, aksiyonVar } = useOturum();
  const oz = useTaleplerim();
  const [kayitId, setKayitId] = useState<number | null>(param === 'yeni' ? null : Number(param));
  const [d, setD] = useState<Deger>({ tarafId: pt.personel?.id ?? 0, tutar: '', taksit: 1, ilkDonem: sonrakiAy(), gerekce: '', aciklama: '' });
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [ro, setRo] = useState({ avansNo: '', durum: 0, talepTarihi: '', redNeden: '', iptalNeden: '', odemeTarihi: '', odemeIslemId: 0 });
  const [surum, setSurum] = useState<string | undefined>();
  const [kodlar, setKodlar] = useState<Record<string, Record<string, string>>>({});
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [b, setB] = useState<any>(null);
  const [zincir, setZincir] = useState<{ id: number; sira: number; ad: string; durum: number; kararZamani: string | null; gerekce: string; termin: string | null }[]>([]);
  const [ekler, setEkler] = useState<DokumanSatiri[]>([]);
  const [gerekceler, setGerekceler] = useState<string[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const [arama, setArama] = useState(false);
  const [secilenAd, setSecilenAd] = useState(pt.personel?.ad ?? '');
  const [odeme, setOdeme] = useState({ acik: false, hesapId: 0, nakit: false, tarih: bugunIso() });
  const dosyaRef = useRef<HTMLInputElement>(null);

  const kapat = useCallback(() => git(pt.geri ?? '/personel-avans'), [git, pt.geri]);
  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));
  const kilitli = ro.durum !== 0;
  const yazar = yetki('ik.avans', kayitId ? 'degistir' : 'ekle');

  const oku = useCallback(async (kid: number) => {
    const y = await api.kartOku(KAYNAK, kid);
    const k = y.kart as Record<string, unknown>;
    const v: Deger = {
      tarafId: Number(k.tarafId ?? 0), tutar: k.tutar == null ? '' : Number(k.tutar).toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 }), taksit: Number(k.taksitSayisi ?? 1),
      ilkDonem: String(k.ilkDonem ?? ''), gerekce: String(k.gerekce ?? ''), aciklama: String(k.aciklama ?? ''),
    };
    setD(v); setIlk(v); setSurum(k.surum as string | undefined);
    setRo({ avansNo: String(k.avansNo ?? ''), durum: Number(k.durum ?? 0), talepTarihi: s10(k.talepTarihi),
            redNeden: String(k.redNeden ?? ''), iptalNeden: String(k.iptalNeden ?? ''),
            odemeTarihi: s10(k.odemeTarihi), odemeIslemId: Number(k.odemeIslemId ?? 0) });
    api.onayZinciri(AVANS_TUR, kid).then(z => setZincir(z.adimlar)).catch(() => setZincir([]));
    api.dokumanlar(KAYNAK, kid).then(setEkler).catch(() => setEkler([]));
  }, []);

  useEffect(() => {
    api.kartAlanlari(KAYNAK).then(m => setKodlar(Object.fromEntries(m.alanlar.map(a => [a.ad, a.kodlar ?? {}])))).catch(() => {});
    api.kodListe('ik.avans_gerekce').then(y => setGerekceler(y.degerler.filter(x => x.aktif !== 0).map(x => x.ad))).catch(() => setGerekceler([]));
    if (kayitId) oku(kayitId).catch(e => setHata(hataMetni(e)));
  }, [kayitId, oku]);

  const anahtar = JSON.stringify([d.tarafId, kayitId, ro.durum, ro.odemeIslemId]);
  const baglamYukle = useCallback(() => {
    if (!(d.tarafId > 0)) { setB(null); return }
    const p = new URLSearchParams({ tarafId: String(d.tarafId) });
    if (kayitId) p.set('avansId', String(kayitId));
    api.avansBaglam(p).then(y => {
      setB(y);
      setOdeme(o => ({ ...o, hesapId: o.hesapId || (y.hesaplar?.[0]?.id ?? 0) }));
    }).catch(e => setHata(hataMetni(e)));
  }, [d.tarafId, kayitId]);
  useEffect(() => { baglamYukle() }, [anahtar]);   // eslint-disable-line react-hooks/exhaustive-deps

  const tutar = tutarOku(d.tutar) || 0;
  const aylik = d.taksit > 0 ? Math.round((tutar / d.taksit) * 100) / 100 : 0;
  // PLAN: ödenmişse gerçek satırlar; değilse sunucudaki formülle canlı (son taksit kalanı alır).
  const plan = useMemo(() => {
    if (b?.kesintiler?.length) return b.kesintiler.map((k: { sira: number; donem: string; tutar: number; durum: number; kesintiTarihi: string | null; aciklama: string }) => ({ ...k }));
    if (!(tutar > 0) || !d.ilkDonem) return [];
    const taban = Math.floor((tutar / d.taksit) * 100) / 100;
    return Array.from({ length: d.taksit }, (_, i) => ({
      sira: i + 1, donem: ayEkle(d.ilkDonem, i), tutar: i === d.taksit - 1 ? Math.round((tutar - taban * (d.taksit - 1)) * 100) / 100 : taban,
      durum: 0, kesintiTarihi: null, aciklama: '',
    }));
  }, [b, tutar, d.taksit, d.ilkDonem]);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const kesilen = plan.filter((k: any) => k.durum === 1).reduce((t: number, k: any) => t + Number(k.tutar), 0);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const siradaki = plan.find((k: any) => k.durum === 0);

  const azami = b?.azamiTaksit ?? 6;
  const netMaas = b?.personel?.netMaas ? Number(b.personel.netMaas) : null;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const digerAylik = (b?.aciklar ?? []).reduce((t: number, a: any) => t + Number(a.aylik ?? 0), 0);
  const buAylik = ro.durum >= 4 ? Number(siradaki?.tutar ?? 0) : aylik;
  const oran = netMaas ? ((digerAylik + buAylik) / netMaas) * 100 : null;
  const esik = Number(b?.oranEsik ?? 25);
  const personelAd = b?.personel?.ad || secilenAd || kodlar.tarafId?.[String(d.tarafId)] || '';
  const benimSiram = !!oz?.veri?.onaylar?.some(o => o.kaynakTur === AVANS_TUR && o.kaynakId === kayitId);

  const dogrula = (): string | null => {
    if (!(d.tarafId > 0)) return c('Personel seçilmeli.');
    if (!(tutar > 0)) return c('Tutar girilmeli.');
    if (d.taksit < 1 || d.taksit > azami) return `${c('Taksit 1 ile')} ${azami} ${c('arasında olmalı.')}`;
    if (!/^\d{4}-\d{2}$/.test(d.ilkDonem)) return c('İlk kesinti dönemi seçilmeli.');
    if (!d.gerekce.trim()) return c('Gerekçe girilmeli.');
    return null;
  };

  const kaydet = async (): Promise<number | null> => {
    const h = dogrula();
    if (h) { setHata(h); return null }
    setHata(null);
    if (!kayitId) {
      const y = await api.avansAc({ tarafId: d.tarafId, tutar, taksitSayisi: d.taksit, ilkDonem: d.ilkDonem, gerekce: d.gerekce,
                                    aciklama: d.aciklama.trim() || undefined });
      setKayitId(y.id);
      git(`/personel-avans/${y.id}`, { replace: true, ...devamDurumu(pt) });
      return y.id;
    }
    const alan: Record<string, unknown> = { tutar, taksitSayisi: d.taksit, ilkDonem: d.ilkDonem, gerekce: d.gerekce, aciklama: d.aciklama };
    const eski: Record<string, unknown> = ilk ? { tutar: tutarOku(ilk.tutar), taksitSayisi: ilk.taksit, ilkDonem: ilk.ilkDonem, gerekce: ilk.gerekce, aciklama: ilk.aciklama } : {};
    const fark = Object.fromEntries(Object.entries(alan).filter(([k, v]) => v !== eski[k]));
    if (Object.keys(fark).length) await api.kartGuncelle(KAYNAK, kayitId, { surum, kart: fark });
    await oku(kayitId);
    return kayitId;
  };

  const calis = (is: () => Promise<unknown>) => async () => {
    setMesgul(true);
    try { await is(); talepleriYenile(); baglamYukle() } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };
  const gonder = calis(async () => { const kid = await kaydet(); if (kid) { await api.avansGonder(kid); await oku(kid) } });
  const iptalEt = calis(async () => {
    if (!kayitId) return;
    const g = await metinSor(c('İptal nedeni'), '', c('Neden'));
    if (g) { await api.avansIptal(kayitId, g); await oku(kayitId) }
  });
  const ode = calis(async () => {
    if (!kayitId || !odeme.hesapId) { setHata(c('Ödeme hesabı seçin.')); return }
    if (!await onay(`${yazP(tutar)} ${c('avans ödensin mi? Kasa işlemi yazılır ve kesinti planı açılır.')}`)) return;
    await api.avansOde(kayitId, { hesapId: odeme.hesapId, tur: odeme.nakit ? 31 : 32, tarih: odeme.tarih });
    setOdeme(o => ({ ...o, acik: false }));
    await oku(kayitId);
  });
  const kesinti = calis(async () => {
    if (!kayitId || !siradaki) return;
    if (!await onay(`${donemAd(siradaki.donem)} ${c('dönemi')} ${yazP(Number(siradaki.tutar))} ${c('kesildi olarak işlensin mi?')}`)) return;
    await api.avansKesinti(kayitId, {});
    await oku(kayitId);
  });
  const karar = (k: 'onayla' | 'reddet' | 'bilgi-iste') => calis(async () => {
    if (!kayitId) return;
    const gerekce = k === 'onayla' ? undefined : await metinSor(k === 'reddet' ? c('Red gerekçesi') : c('Ne bilgisi isteniyor?'), '', c('Gerekçe'));
    if (k !== 'onayla' && !gerekce) return;
    await api.onayKarar(AVANS_TUR, kayitId, { karar: k, gerekce: gerekce ?? undefined });
    await oku(kayitId);
  });
  const hatirlat = calis(async () => { if (kayitId) await api.avansHatirlat(kayitId) });

  const yazdir = () => {
    const w = window.open('', '_blank');
    if (!w) return;
    const satir = (k: string, v: string) => `<tr><th>${k}</th><td>${(v || '—').replace(/</g, '&lt;')}</td></tr>`;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const planHtml = plan.map((k: any) => `<tr><td>${k.sira}</td><td>${donemAd(k.donem)}</td><td style="text-align:right">${yazP(Number(k.tutar))}</td></tr>`).join('');
    w.document.write(`<!doctype html><meta charset="utf-8"><title>Avans Formu ${ro.avansNo}</title>
      <style>body{font:13px Arial;margin:32px}h2{margin:0 0 16px}table{border-collapse:collapse;width:100%;margin-bottom:14px}
      th,td{border:1px solid #999;padding:6px 8px;text-align:left}th{width:30%;background:#f2f2f2}
      .imza{display:flex;gap:24px;margin-top:40px}.imza div{flex:1;border-top:1px solid #333;padding-top:6px;text-align:center}</style>
      <h2>PERSONEL AVANS FORMU</h2><table>
      ${satir('Avans no', ro.avansNo)}${satir('Personel', personelAd)}${satir('Bölüm / görev', [b?.personel?.bolum, b?.personel?.gorev].filter(Boolean).join(' · '))}
      ${satir('Tutar', `${yazP(tutar)} ₺`)}${satir('Taksit', `${d.taksit} × ${yazP(aylik)} ₺ · ilk dönem ${donemAd(d.ilkDonem)}`)}
      ${satir('Gerekçe', d.gerekce)}${satir('Açıklama', d.aciklama)}</table>
      <table><tr><th>Sıra</th><th>Dönem</th><th style="text-align:right">Tutar</th></tr>${planHtml}</table>
      <p>Yukarıdaki tutarın maaşımdan belirtilen dönemlerde kesilmesini kabul ederim.</p>
      <div class="imza"><div>Personel</div><div>Birim âmiri</div><div>Mali işler</div></div>
      <script>setTimeout(()=>print(),300)</script>`);
    w.document.close();
  };

  const alt = (
    <>
      {yazar && !kilitli && <button type="button" className="d bir" disabled={mesgul} onClick={() => void calis(async () => { await kaydet() })()}>💾 {c('Kaydet')}</button>}
      {yazar && !kilitli && <button type="button" className="d" disabled={mesgul} onClick={() => void gonder()}>📨 {c('Onaya gönder')}</button>}
      {kayitId && ro.durum === 2 && aksiyonVar('ik.avans_ode') && <button type="button" className="d" onClick={() => setOdeme(o => ({ ...o, acik: true }))}>💳 {c('Öde')}…</button>}
      {kayitId && ro.durum === 4 && yazar && siradaki && <button type="button" className="d" disabled={mesgul} onClick={() => void kesinti()}>✂ {c('Kesinti işle')}</button>}
      {kayitId && <button type="button" className="d" onClick={yazdir}>🖨 {c('Avans formu')}</button>}
      {kayitId && yazar && ro.durum < 4 && ro.durum !== 3 && <button type="button" className="d tl-tehlike" disabled={mesgul} onClick={() => void iptalEt()}>✖ {c('İptal et')}</button>}
      <span className="ck-bosluk" />
      <button type="button" className="d" onClick={kapat}>{c('Kapat')}</button>
    </>
  );

  return (
    <Modal baslik={`💸 ${c('Personel Avansı')}${ro.avansNo ? ` — ${ro.avansNo}` : ''}${personelAd ? ` · ${personelAd}` : ''}`}
           ekSinif="kart-calisma" buyutmeYok alt={alt} onKapat={kapat}>
      <div className="ck-kimlik it-kimlik">
        <div className="rk-fld"><span className="ck-etiket">{c('Personel')} <b className="ak-zor">*</b></span>
          <span className="ikili" style={{ display: 'flex', gap: 4, width: '100%' }}>
            <input readOnly className="ck-buyuk" style={{ flex: 1 }} value={personelAd} placeholder={`— ${c('seçiniz')} —`}
                   disabled={!!kayitId} onClick={() => !kayitId && setArama(true)} />
            <button type="button" className="d mini" title={c('Ara')} disabled={!!kayitId} onClick={() => setArama(true)}>…</button>
          </span>
          {b?.personel && <span className="sonuk tl-kucuk">{[b.personel.bolum, b.personel.gorev].filter(Boolean).join(' · ')}</span>}</div>
        <div className="rk-fld"><span className="ck-etiket">{c('Avans no')}</span><input value={ro.avansNo} disabled /></div>
        <div className="rk-fld"><span className="ck-etiket">{c('Talep tarihi')}</span><input value={ro.talepTarihi ? ro.talepTarihi.split('-').reverse().join('.') : ''} disabled /></div>
        <div className="rk-fld"><span className="ck-etiket">{c('Durum')}</span>
          <div className="ck-durum"><span className={`tl-chip ${DURUM[ro.durum]?.[1] ?? ''}`}>{c(DURUM[ro.durum]?.[0] ?? '')}
            {ro.durum === 1 && zincir.find(a => a.durum === 0) ? ` · ${zincir.find(a => a.durum === 0)!.ad}` : ''}</span></div></div>
      </div>
      {hata && <div className="hata-kutusu" style={{ margin: '8px 12px 0' }}>{hata}</div>}
      {(ro.redNeden || ro.iptalNeden) && <div className="tl-uyari" style={{ margin: '8px 12px 0' }}>{ro.redNeden ? `${c('Red nedeni')}: ${ro.redNeden}` : `${c('İptal nedeni')}: ${ro.iptalNeden}`}</div>}

      <div className="ck-govde">
        <div className="ck-sol">
          <div className="ck-grp">
            <h6>{c('Avans')}{kilitli && <span className="ck-ek">🔒 {c('onaya gitti - tutar / taksit / dönem kilitli')}</span>}</h6>
            <div className="ck-iz">
              <div className="rk-fld"><span className="ck-etiket">{c('Tutar')} <b className="ak-zor">*</b></span>
                <div className="av-tutar">
                  <input inputMode="decimal" value={d.tutar} disabled={kilitli} onChange={e => yaz('tutar', e.target.value)} placeholder="0,00" />
                  <span>₺</span>
                  {!kilitli && [1000, 2500, 5000].map(t => <button key={t} type="button" className="ck-cip" onClick={() => yaz('tutar', String(t))}>{t.toLocaleString('tr-TR')}</button>)}
                  {!kilitli && netMaas ? <button type="button" className="ck-cip" onClick={() => yaz('tutar', String(Math.round(netMaas / 2)))}>{c("maaşın %50'si")}</button> : null}
                </div></div>
              <div className="rk-fld"><span className="ck-etiket">{c('Taksit')}</span>
                <div className="av-taksit">
                  {Array.from({ length: Math.max(azami, 8) }, (_, i) => i + 1).map(n => (
                    <button key={n} type="button" disabled={kilitli || n > azami} className={d.taksit === n ? 'av-on' : ''} onClick={() => yaz('taksit', n)}>{n}</button>
                  ))}
                </div>
                <span className="sonuk tl-kucuk">{c('azami')} {azami} {c('taksit (kurum ayarı)')}</span></div>
              <label className="rk-fld"><span className="ck-etiket">{c('İlk kesinti dönemi')} <b className="ak-zor">*</b></span>
                <input type="month" value={d.ilkDonem} disabled={kilitli} onChange={e => yaz('ilkDonem', e.target.value)} /></label>
              <div className="rk-fld"><span className="ck-etiket">{c('Aylık kesinti')}</span>
                <input disabled value={tutar > 0 ? `${yazP(aylik)} ₺ × ${d.taksit} · ${c('son dönem')} ${donemAd(ayEkle(d.ilkDonem || sonrakiAy(), d.taksit - 1))}` : ''} /></div>
              <div className="rk-fld ck-tam"><span className="ck-etiket">{c('Gerekçe')} <b className="ak-zor">*</b></span>
                <input list="av-gerekce" value={d.gerekce} maxLength={200} disabled={kilitli} onChange={e => yaz('gerekce', e.target.value)} placeholder={c('seçin ya da yazın')} />
                <datalist id="av-gerekce">{gerekceler.map(g => <option key={g} value={g} />)}</datalist></div>
              <label className="rk-fld ck-tam"><span className="ck-etiket">{c('Açıklama')}</span>
                <input value={d.aciklama} maxLength={300} disabled={kilitli} onChange={e => yaz('aciklama', e.target.value)} /></label>
            </div>
          </div>

          <div className="ck-grp">
            <h6>{c('Kesinti planı')}<span className="ck-ek">{plan.length} {c('taksit')} · {b?.kesintiler?.length ? c('ödendi - plan sabit') : c('ödeme sonrası kesinti işlenir')}</span></h6>
            <div style={{ padding: '8px 12px 12px' }}>
              {plan.length === 0 ? <div className="sonuk">{c('Tutar ve dönem girin.')}</div> : (
                <table className="av-plan">
                  <thead><tr><th>{c('Sıra')}</th><th>{c('Dönem')}</th><th className="r">{c('Tutar')}</th><th>{c('Durum')}</th><th>{c('Kesinti tarihi')}</th><th>{c('Not')}</th></tr></thead>
                  <tbody>
                    {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                    {plan.map((k: any) => (
                      <tr key={k.sira} className={k.durum === 1 ? 'av-kesildi' : siradaki?.sira === k.sira && b?.kesintiler?.length ? 'av-sira' : ''}>
                        <td>{k.sira}</td><td>{donemAd(k.donem)}</td><td className="r">{yazP(Number(k.tutar))}</td>
                        <td><span className={`tl-chip ${k.durum === 1 ? 'tl-c-ok' : siradaki?.sira === k.sira && b?.kesintiler?.length ? 'tl-c-bek' : 'tl-c-gri'}`}>
                          {k.durum === 1 ? c('Kesildi') : k.durum === 2 ? c('İptal') : siradaki?.sira === k.sira && b?.kesintiler?.length ? c('Sırada') : c('Bekliyor')}</span></td>
                        <td>{k.kesintiTarihi ? s10(k.kesintiTarihi).split('-').reverse().join('.') : '—'}</td><td>{k.aciklama}</td>
                      </tr>
                    ))}
                    <tr className="av-toplam"><td colSpan={2}>{c('Toplam')}</td><td className="r">{yazP(tutar)}</td>
                      <td colSpan={3}>{c('kesilen')} {yazP(kesilen)} · {c('kalan')} {yazP(tutar - kesilen)}</td></tr>
                  </tbody>
                </table>
              )}
            </div>
          </div>

          {kayitId && ro.durum >= 2 && ro.durum !== 3 && ro.durum !== 8 && (
            <div className="ck-grp">
              <h6>{c('Ödeme')}<span className="ck-ek">{ro.odemeIslemId ? c('ödendi') : c('onaylandı - ödenecek')}</span></h6>
              {ro.odemeIslemId ? (
                <div className="ck-iz">
                  <div className="rk-fld"><span className="ck-etiket">{c('Ödeme tarihi')}</span><input disabled value={ro.odemeTarihi.split('-').reverse().join('.')} /></div>
                  <div className="rk-fld"><span className="ck-etiket">{c('Kasa işlemi')}</span>
                    <button type="button" className="cl-bag" onClick={() => git(`/kasa-islem/${ro.odemeIslemId}`)}>#{ro.odemeIslemId} ↗</button></div>
                </div>
              ) : odeme.acik ? (
                <div className="ck-iz">
                  <label className="rk-fld"><span className="ck-etiket">{c('Ödeme hesabı')} <b className="ak-zor">*</b></span>
                    <select value={odeme.hesapId} onChange={e => setOdeme(o => ({ ...o, hesapId: Number(e.target.value) }))}>
                      {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                      {(b?.hesaplar ?? []).map((h: any) => <option key={h.id} value={h.id}>{h.ad}</option>)}
                    </select></label>
                  <div className="rk-fld"><span className="ck-etiket">{c('Ödeme şekli')}</span>
                    <div className="ck-cipler">
                      <button type="button" className={`ck-cip${!odeme.nakit ? ' on' : ''}`} onClick={() => setOdeme(o => ({ ...o, nakit: false }))}>{c('Havale / EFT')}</button>
                      <button type="button" className={`ck-cip${odeme.nakit ? ' on' : ''}`} onClick={() => setOdeme(o => ({ ...o, nakit: true }))}>{c('Nakit')}</button>
                    </div></div>
                  <label className="rk-fld"><span className="ck-etiket">{c('Ödeme tarihi')}</span>
                    <input type="date" value={odeme.tarih} onChange={e => setOdeme(o => ({ ...o, tarih: e.target.value }))} /></label>
                  <div className="rk-fld"><span className="ck-etiket">&nbsp;</span>
                    <div className="ck-ikili"><button type="button" className="d bir" disabled={mesgul} onClick={() => void ode()}>💳 {c('Ödemeyi yap')} · {yazP(tutar)}</button>
                      <button type="button" className="d" onClick={() => setOdeme(o => ({ ...o, acik: false }))}>{c('Vazgeç')}</button></div></div>
                </div>
              ) : (
                <div className="tl-bilgi" style={{ margin: 12 }}>{c('Onaylanan avans ödenmeyi bekliyor. "Öde…" kasa işlemini yazar ve kesinti planını açar.')}</div>
              )}
            </div>
          )}
        </div>

        <div className="ck-sag">
          <div className="ck-grp ck-grp-sag">
            <h6>{c('Maaşa oranı')}<span className="ck-ek">{netMaas ? `${c('net maaş')} ${yazP(netMaas)} ₺` : c('net maaş girilmemiş')}</span></h6>
            <div className="it-bakiye av-maas">
              <div>{c('Aylık kesinti')}<b>{yazP(buAylik)} ₺</b></div>
              <div>{c('Diğer avanslar')}<b>{yazP(digerAylik)} ₺</b></div>
              <div className={oran != null && esik > 0 && oran > esik ? 'it-eksi' : oran != null ? 'it-son' : ''}>{c('Toplam / net')}<b>{oran == null ? '—' : `%${oran.toLocaleString('tr-TR', { maximumFractionDigits: 1 })}`}</b></div>
            </div>
            {oran != null && (
              <div className="tl-bakiye" style={{ margin: '0 12px 8px' }}>
                <i style={{ width: `${Math.min(100, (digerAylik / netMaas!) * 100)}%`, background: '#2f6db3' }} />
                <i style={{ width: `${Math.min(100, (buAylik / netMaas!) * 100)}%`, background: '#e0a33a' }} /></div>
            )}
            {oran != null && esik > 0 && oran > esik && (
              <div className="tl-uyari" style={{ margin: '0 12px 10px' }}>⚠ {c('Aylık kesinti net maaşın')} %{esik} {c("'ini aşıyor. Engel değil; onaycı görür.")}</div>
            )}
            {!netMaas && <div className="sonuk tl-kucuk" style={{ padding: '0 12px 10px' }}>{c('Personel kartında "Aylık Net Maaş" girilirse oran hesaplanır.')}</div>}
          </div>

          {(b?.aciklar?.length ?? 0) > 0 && (
            <div className="tl-uyari" style={{ margin: '12px 12px 0' }}>⚠ {c('Bu personelin')} <b>{b.aciklar.length} {c('açık avansı')}</b> {c('var')}
              {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
              {' '}({b.aciklar.map((a: any) => `${a.no} · ${c('kalan')} ${yazP(Number(a.kalan))} ₺`).join('; ')}). {c('Onay zincirine "açık avans" basamağı eklenir.')}</div>
          )}

          {kayitId && ro.durum > 0 && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Onay zinciri')}<span className="ck-ek">{zincir.length ? `${zincir.length} ${c('basamak')}` : ''}</span></h6>
              <div className="it-zincir">
                {zincir.length === 0 && <div className="sonuk">{c('Zincir yok.')}</div>}
                {zincir.map(a => {
                  const st = a.durum === 1 || a.durum === 4 ? 'ok' : a.durum === 2 ? 'red' : a.durum === 0 ? 'su' : 'atla';
                  const sira = zincir.find(x => x.durum === 0)?.id === a.id;
                  return (
                    <div key={a.id} className={`it-bs it-bs-${st}`}>
                      <i>{st === 'ok' ? '✓' : st === 'red' ? '✕' : a.sira}</i>
                      <span><b>{a.ad}</b><small>{a.kararZamani ? tarihSaat(a.kararZamani) : sira ? `${c('bekliyor')}${a.termin ? ` · ${c('termin')} ${tarihSaat(a.termin)}` : ''}` : ''}
                        {a.gerekce ? ` · “${a.gerekce}”` : ''}</small></span>
                      {sira && yazar && <button type="button" className="d" onClick={() => void hatirlat()}>🔔 {c('Hatırlat')}</button>}
                    </div>
                  );
                })}
              </div>
              {benimSiram && (
                <div className="tl-eylem" style={{ padding: '0 12px 10px' }}>
                  <button type="button" className="d tl-ok" onClick={() => void karar('onayla')()}>✔ {c('Onayla')}</button>
                  <button type="button" className="d tl-tehlike" onClick={() => void karar('reddet')()}>✕ {c('Reddet')}</button>
                  <button type="button" className="d" onClick={() => void karar('bilgi-iste')()}>? {c('Bilgi iste')}</button>
                </div>
              )}
            </div>
          )}

          {(b?.gecmis?.length ?? 0) > 0 && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Avans geçmişi')}<span className="ck-ek">{c('son 12 ay')}</span></h6>
              <table className="av-gecmis">
                <tbody>
                  {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                  {b.gecmis.map((g: any, i: number) => (
                    <tr key={i}><td>{g.no}</td><td>{s10(g.tarih).split('-').reverse().join('.')}</td><td className="r">{yazP(Number(g.tutar))} ₺</td>
                      <td><span className={`tl-chip ${DURUM[g.durum]?.[1] ?? ''}`}>{g.durum === 4 ? `${c('Kesintide')} · ${g.kesilen}/${g.taksit}` : c(DURUM[g.durum]?.[0] ?? '')}</span></td></tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}

          {kayitId && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Belgeler')}<span className="ck-ek">{ekler.length}</span></h6>
              <div className="tl-ekler" style={{ padding: '8px 12px' }}>
                {ekler.map(f => (
                  <span key={f.id} className="tl-ek">
                    <button type="button" className="cl-bag" onClick={async () => { const w = window.open('', '_blank'); const u = await api.dokumanIcerikUrl(f.id); if (w) w.location.href = u }}>📎 {f.ad}</button>
                    {yazar && <button type="button" className="cl-bag sonuk" onClick={() => void guvenli(async () => {
                      if (await onay(`${f.ad} ${c('silinsin mi?')}`)) setEkler(await api.dokumanSil(KAYNAK, kayitId, f.id));
                    })}> ✕</button>}</span>
                ))}
                <button type="button" className="tl-ek" onClick={() => dosyaRef.current?.click()}>＋ {c('Ekle')}</button>
                <input ref={dosyaRef} type="file" multiple hidden onChange={e => {
                  const l = Array.from(e.target.files ?? []); e.target.value = '';
                  void guvenli(async () => { let son = ekler; for (const f of l) son = await api.dokumanYukle(KAYNAK, kayitId, f, false); setEkler(son) });
                }} />
              </div>
            </div>
          )}

          {kayitId && (b?.akis?.length ?? 0) > 0 && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Akış')}<span className="ck-ek">{c('en yeni altta')}</span></h6>
              <div className="it-akis">
                {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                {b.akis.map((a: any, i: number) => (
                  <div key={i} className={a.tur === 'red' || a.tur === 'iptal' ? 'tl-gec' : ''}>
                    {a.tur === 'olustu' ? c('Talep oluşturuldu') : a.tur === 'gonderildi' ? `${c('Onaya gönderildi')}${a.metin ? `: ${a.metin}` : ''}`
                      : a.tur === 'onay' ? `✓ ${a.metin} ${c('onayladı')}` : a.tur === 'red' ? `✕ ${a.metin} ${c('reddetti')}`
                      : a.tur === 'bilgi' ? `? ${a.metin} ${c('bilgi istedi')}` : a.tur === 'odendi' ? `💳 ${c('Ödendi')} · ${a.metin}`
                      : a.tur === 'kesinti' ? `✂ ${c('Kesinti')} · ${a.metin}` : a.tur === 'iptal' ? `${c('İptal edildi')}${a.metin ? `: ${a.metin}` : ''}` : a.metin}
                    <small>{[a.kim, a.zaman ? tarihSaat(a.zaman) : ''].filter(Boolean).join(' · ')}</small>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
      {arama && (
        <TarafArama acik kaynaklar={['personel']} kartYok yerTutucu={c('Personel ara…')}
          onKapat={() => setArama(false)}
          onSec={sec => { setD(o => ({ ...o, tarafId: sec.id })); setSecilenAd(sec.unvan); setArama(false) }} />
      )}
    </Modal>
  );
}
