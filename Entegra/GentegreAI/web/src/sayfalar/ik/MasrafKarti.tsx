import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { devamDurumu, personelTalepDurumu } from '../../bilesenler/taleplerim/personelTalebi';
import { api } from '../../api/istemci';
import { hataMetni, type DokumanSatiri } from '../../api/sozlesme';
import { Modal } from '../../bilesenler/Modal';
import { TarafArama } from '../../bilesenler/TarafArama';
import { metinSor } from '../../bilesenler/mesaj';
import { para, tarihSaat, tutarOku, bugunIso } from '../../bilesenler/bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { useTaleplerim } from '../../bilesenler/taleplerim/taleplerimBaglami';
import { talepleriYenile } from '../../bilesenler/taleplerim/useTaleplerimOzeti';
import { c } from '../../dil/ceviri';

/**
 * MASRAF BEYANI KARTI `/personel-masraf/:id` (961, mockup Ekranlar/IK/masraf_karti.html).
 *
 * Sol: beyan (konu, ilgili izin, açıklama) ve harcamalar tablosu - satır içinde
 * düzenlenir, her satır bir belgedir, fiş görüntüsü satıra belge no ile bağlanır.
 * Sağ: fiş önizleme, gönderim öncesi kontrol, gider dağılımı, onay zinciri,
 * son beyanlar, akış. Onaya gidince satırlar kilitli; fiş eklenebilir.
 * Kayıt: başlık generic kart, satırlar kendi uçları (ekle / düzenle / sil).
 */
const KAYNAK = 'personelMasraf';
const MASRAF_TUR = 1312;
const DURUM: Record<number, [string, string]> = {
  0: ['Taslak', 'tl-c-gri'], 1: ['Onayda', 'tl-c-bek'], 2: ['Onaylandı', 'tl-c-ok'], 3: ['Reddedildi', 'tl-c-red'], 8: ['İptal', 'tl-c-gri'],
};
const BELGE: [number, string][] = [[1, 'Fatura'], [2, 'Fiş'], [3, 'e-Arşiv'], [4, 'Bilet'], [5, 'Gider pusulası'], [9, 'Diğer']];
const s10 = (v: unknown) => String(v ?? '').slice(0, 10);
const yazP = (n: number) => para.format(Math.round(n * 100) / 100);
const tl = (n: number) => n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

interface Satir {
  anahtar: string; id: number | null; masrafId: number | null; masrafAd: string; tarih: string; belgeTuru: number;
  belgeNo: string; tutar: string; kdv: string; aciklama: string; fisId: number | null; bekleyenFis: File | null;
}
let sayac = 0;
const yeniSatir = (o: Partial<Satir> = {}): Satir => ({
  anahtar: `y${++sayac}`, id: null, masrafId: null, masrafAd: '', tarih: bugunIso(), belgeTuru: 2, belgeNo: '',
  tutar: '', kdv: '', aciklama: '', fisId: null, bekleyenFis: null, ...o,
});

export function MasrafKarti() {
  const { id } = useParams();
  return <MasrafKartiIc key={id ?? ''} param={id} />;
}

function MasrafKartiIc({ param }: { param: string | undefined }) {
  const git = useNavigate();
  // PERSONEL LİSTESİNDEN (Yeni Talep ▾): seçili personel dolu gelir, Kapat listeye döner.
  const pt = personelTalepDurumu(useLocation().state);
  const { yetki } = useOturum();
  const oz = useTaleplerim();
  const [kayitId, setKayitId] = useState<number | null>(param === 'yeni' ? null : Number(param));
  const [bas, setBas] = useState({ tarafId: pt.personel?.id ?? 0, beyanTarihi: bugunIso(), konu: '', ilgiliIzinId: null as number | null, aciklama: '' });
  const [ilkBas, setIlkBas] = useState<typeof bas | null>(null);
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [ilkSatirlar, setIlkSatirlar] = useState<Satir[]>([]);
  const [seciliSatir, setSeciliSatir] = useState<string | null>(null);
  const [ro, setRo] = useState({ beyanNo: '', durum: 0, redNeden: '', iptalNeden: '' });
  const [surum, setSurum] = useState<string | undefined>();
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [b, setB] = useState<any>(null);
  const [zincir, setZincir] = useState<{ id: number; sira: number; ad: string; durum: number; kararZamani: string | null; gerekce: string; termin: string | null }[]>([]);
  const [ekler, setEkler] = useState<DokumanSatiri[]>([]);
  const [konular, setKonular] = useState<string[]>([]);
  const [onizUrl, setOnizUrl] = useState<{ id: number; url: string } | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const [arama, setArama] = useState(false);
  const [secilenAd, setSecilenAd] = useState(pt.personel?.ad ?? '');
  const fisRef = useRef<HTMLInputElement>(null);
  const yeniFisRef = useRef<HTMLInputElement>(null);
  const fisHedef = useRef<string | null>(null);

  const kapat = useCallback(() => git(pt.geri ?? '/personel-masraf'), [git, pt.geri]);
  const kilitli = ro.durum !== 0;
  const yazar = yetki('ik.masraf', kayitId ? 'degistir' : 'ekle');
  const yazB = <K extends keyof typeof bas>(k: K, v: (typeof bas)[K]) => setBas(o => ({ ...o, [k]: v }));
  const yazS = (anahtar: string, k: keyof Satir, v: unknown) => setSatirlar(l => l.map(s => s.anahtar === anahtar ? { ...s, [k]: v } : s));

  const baglamYukle = useCallback(async (tarafId: number, bid: number | null) => {
    if (!(tarafId > 0)) { setB(null); return null }
    const p = new URLSearchParams({ tarafId: String(tarafId) });
    if (bid) p.set('beyanId', String(bid));
    const y = await api.masrafBaglam(p);
    setB(y);
    return y;
  }, []);

  const oku = useCallback(async (kid: number) => {
    const y = await api.kartOku(KAYNAK, kid);
    const k = y.kart as Record<string, unknown>;
    const v = { tarafId: Number(k.tarafId ?? 0), beyanTarihi: s10(k.beyanTarihi), konu: String(k.konu ?? ''),
                ilgiliIzinId: k.ilgiliIzinId ? Number(k.ilgiliIzinId) : null, aciklama: String(k.aciklama ?? '') };
    setBas(v); setIlkBas(v); setSurum(k.surum as string | undefined);
    setRo({ beyanNo: String(k.beyanNo ?? ''), durum: Number(k.durum ?? 0), redNeden: String(k.redNeden ?? ''), iptalNeden: String(k.iptalNeden ?? '') });
    const bg = await baglamYukle(v.tarafId, kid);
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const ss: Satir[] = (bg?.satirlar ?? []).map((r: any) => ({
      anahtar: `s${r.id}`, id: r.id, masrafId: r.masrafId, masrafAd: r.masrafAd, tarih: s10(r.harcamaTarihi),
      belgeTuru: Number(r.belgeTuru ?? 2), belgeNo: r.belgeNo ?? '', tutar: tl(Number(r.tutar)), kdv: tl(Number(r.kdvTutar ?? 0)),
      aciklama: r.aciklama ?? '', fisId: r.fisId ?? null, bekleyenFis: null,
    }));
    setSatirlar(ss); setIlkSatirlar(ss);
    if (!seciliSatir && ss.length) setSeciliSatir(ss[0].anahtar);
    api.onayZinciri(MASRAF_TUR, kid).then(z => setZincir(z.adimlar)).catch(() => setZincir([]));
    api.dokumanlar(KAYNAK, kid).then(setEkler).catch(() => setEkler([]));
  }, [baglamYukle]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    api.kodListe('ik.masraf_konu').then(y => setKonular(y.degerler.filter(x => x.aktif !== 0).map(x => x.ad))).catch(() => setKonular([]));
    if (kayitId) oku(kayitId).catch(e => setHata(hataMetni(e)));
    else setSatirlar([yeniSatir()]);
  }, [kayitId, oku]);
  useEffect(() => { if (!kayitId && bas.tarafId) baglamYukle(bas.tarafId, null).catch(() => {}) }, [bas.tarafId, kayitId, baglamYukle]);

  // FİŞ ÖNİZLEME: seçili satırın fişi.
  const secili = satirlar.find(s => s.anahtar === seciliSatir) ?? null;
  useEffect(() => {
    const fid = secili?.fisId;
    if (!fid) { setOnizUrl(null); return }
    if (onizUrl?.id === fid) return;
    api.dokumanIcerikUrl(fid).then(url => setOnizUrl({ id: fid, url })).catch(() => setOnizUrl(null));
  }, [secili?.fisId]); // eslint-disable-line react-hooks/exhaustive-deps
  const onizDok = ekler.find(e => e.id === secili?.fisId);

  const toplam = satirlar.reduce((t, s) => t + (tutarOku(s.tutar) || 0), 0);
  const kdv = satirlar.reduce((t, s) => t + (tutarOku(s.kdv) || 0), 0);
  const dagilim = useMemo(() => {
    const m = new Map<string, number>();
    for (const s of satirlar) if (tutarOku(s.tutar) > 0) m.set(s.masrafAd || c('Kalemsiz'), (m.get(s.masrafAd || c('Kalemsiz')) ?? 0) + tutarOku(s.tutar));
    return [...m.entries()].sort((a, x) => x[1] - a[1]);
  }, [satirlar]);

  // KONTROL: istemci (belge no, tutar, fiş) + sunucu (mükerrer, eski, sınır) + âmir.
  const kontrol = useMemo(() => {
    const l: { tur: 'ok' | 'uy' | 'er'; metin: string }[] = [];
    const dolu = satirlar.filter(s => s.belgeNo.trim() || tutarOku(s.tutar) > 0);
    const belgesiz = dolu.filter(s => !s.belgeNo.trim()).length;
    l.push(belgesiz ? { tur: 'er', metin: `${belgesiz} ${c('satırda belge no yok')}` } : { tur: 'ok', metin: c('Her satırda belge no var') });
    const tutarsiz = dolu.filter(s => !(tutarOku(s.tutar) > 0)).length;
    if (tutarsiz) l.push({ tur: 'er', metin: `${tutarsiz} ${c('satırda tutar yok')}` });
    const fissiz = dolu.filter(s => !s.fisId && !s.bekleyenFis).map(s => satirlar.indexOf(s) + 1);
    l.push(fissiz.length ? { tur: 'uy', metin: `${c('Fiş görüntüsü yok')}: ${c('satır')} ${fissiz.join(', ')}` } : { tur: 'ok', metin: c('Her satırın fişi var') });
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const sunucu: any[] = b?.kontrol ?? [];
    const muk = sunucu.filter(k => k.tur === 'mukerrer');
    l.push(muk.length ? { tur: 'uy', metin: muk.map(k => `${c('Satır')} ${k.sira}: ${k.metin}`).join(' · ') } : { tur: 'ok', metin: c('Mükerrer belge yok') });
    const eski = sunucu.filter(k => k.tur === 'eski');
    l.push(eski.length ? { tur: 'uy', metin: `${b?.gecmisGun} ${c('günden eski')}: ${eski.map(k => `${c('satır')} ${k.sira}`).join(', ')}` }
      : { tur: 'ok', metin: `${c('Harcamalar son')} ${b?.gecmisGun ?? 60} ${c('günde')}` });
    for (const k of sunucu.filter(x => x.tur === 'sinir')) l.push({ tur: 'uy', metin: k.metin });
    if (b?.personel) l.push(b.personel.amirVar ? { tur: 'ok', metin: c('Personelin âmiri tanımlı - onaya gidebilir') }
      : { tur: 'er', metin: c('Personelin âmiri tanımlı değil - onaya gönderilemez') });
    return l;
  }, [satirlar, b]);

  /** Satırı kaydedip kimliğini döner (fiş bağlamak için). */
  const satirYaz = async (bid: number, s: Satir) => {
    const g = { masrafId: s.masrafId ?? undefined, harcamaTarihi: s.tarih || undefined, belgeTuru: s.belgeTuru,
                belgeNo: s.belgeNo.trim(), tutar: tutarOku(s.tutar), kdvTutar: tutarOku(s.kdv) || undefined, aciklama: s.aciklama.trim() || undefined };
    if (s.id) { await api.masrafSatirGuncelle(s.id, g); return s.id }
    return (await api.masrafSatirEkle(bid, g)).satirId;
  };
  const fisBagla = async (bid: number, belgeNo: string, f: File) => {
    const once = new Set((await api.dokumanlar(KAYNAK, bid)).map(d => d.id));
    const son = await api.dokumanYukle(KAYNAK, bid, f, false);
    const yeni = son.find(d => !once.has(d.id));
    if (yeni) await api.dokumanDuzenle(KAYNAK, bid, yeni.id, yeni.ad, belgeNo.trim());
  };

  const kaydet = async (): Promise<number | null> => {
    if (!(bas.tarafId > 0)) { setHata(c('Personel seçilmeli.')); return null }
    if (!bas.konu.trim()) { setHata(c('Konu / amaç girilmeli.')); return null }
    const dolu = satirlar.filter(s => s.belgeNo.trim() || tutarOku(s.tutar) > 0 || s.bekleyenFis);
    if (dolu.some(s => !s.belgeNo.trim())) { setHata(c('Her satırda belge no zorunlu (belgesiz masraf beyan edilmez).')); return null }
    if (dolu.some(s => !(tutarOku(s.tutar) > 0))) { setHata(c('Her satırda tutar girilmeli.')); return null }
    setHata(null);
    let bid = kayitId;
    if (!bid) {
      bid = (await api.masrafAc({ tarafId: bas.tarafId, beyanTarihi: bas.beyanTarihi, aciklama: bas.aciklama || undefined,
                                  konu: bas.konu.trim(), ilgiliIzinId: bas.ilgiliIzinId })).id;
      // YENİ KAYIT HEMEN KİMLİĞİNE GEÇER: satır yazımı yarıda kalırsa ikinci "Kaydet" yeni beyan açmasın.
      setKayitId(bid);
    } else {
      const alan: Record<string, unknown> = { beyanTarihi: bas.beyanTarihi, konu: bas.konu.trim(), ilgiliIzinId: bas.ilgiliIzinId, aciklama: bas.aciklama };
      const eski: Record<string, unknown> = ilkBas ? { beyanTarihi: ilkBas.beyanTarihi, konu: ilkBas.konu, ilgiliIzinId: ilkBas.ilgiliIzinId, aciklama: ilkBas.aciklama } : {};
      const fark = Object.fromEntries(Object.entries(alan).filter(([k, v]) => v !== eski[k]));
      if (Object.keys(fark).length) await api.kartGuncelle(KAYNAK, bid, { surum, kart: fark });
    }
    // SATIRLAR: silinen → sil, değişen / yeni → yaz, bekleyen fiş → bağla.
    for (const e of ilkSatirlar) if (!satirlar.some(s => s.id === e.id)) await api.masrafSatirSil(e.id!);
    for (const s of dolu) {
      const e = ilkSatirlar.find(x => x.id === s.id);
      const degisti = !e || ['masrafId', 'tarih', 'belgeTuru', 'belgeNo', 'tutar', 'kdv', 'aciklama'].some(k => e[k as keyof Satir] !== s[k as keyof Satir]);
      if (degisti) await satirYaz(bid, s);
      if (s.bekleyenFis) await fisBagla(bid, s.belgeNo, s.bekleyenFis);
    }
    if (!kayitId) git(`/personel-masraf/${bid}`, { replace: true, ...devamDurumu(pt) });
    else await oku(bid);
    return bid;
  };

  const calis = (is: () => Promise<unknown>) => async () => {
    setMesgul(true);
    try { await is(); talepleriYenile() } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };
  const gonder = calis(async () => { const id = await kaydet(); if (id) { await api.masrafGonder(id); await oku(id) } });
  const iptalEt = calis(async () => {
    if (!kayitId) return;
    const g = await metinSor(c('İptal nedeni'), '', c('Neden'));
    if (g) { await api.masrafIptal(kayitId, g); await oku(kayitId) }
  });
  const karar = (k: 'onayla' | 'reddet' | 'bilgi-iste') => calis(async () => {
    if (!kayitId) return;
    const gerekce = k === 'onayla' ? undefined : await metinSor(k === 'reddet' ? c('Red gerekçesi') : c('Ne bilgisi isteniyor?'), '', c('Gerekçe'));
    if (k !== 'onayla' && !gerekce) return;
    await api.onayKarar(MASRAF_TUR, kayitId, { karar: k, gerekce: gerekce ?? undefined });
    await oku(kayitId);
  });
  const hatirlat = calis(async () => { if (kayitId) await api.masrafHatirlat(kayitId) });
  const kopyala = () => {
    // Kopya taslakta kaydedilmeden açılır: başlık ve kalemler, belge no / fiş yok.
    git('/personel-masraf/yeni');
  };

  // FİŞ YÜKLE: kayıtlı satırda hemen bağlanır; yeni satırda kayıtta.
  const fisSec = (anahtar: string) => { fisHedef.current = anahtar; fisRef.current?.click() };
  const fisGeldi = (f: File | undefined) => {
    const a = fisHedef.current;
    if (!f || !a) return;
    const s = satirlar.find(x => x.anahtar === a);
    if (!s) return;
    if (kayitId && s.id && s.belgeNo.trim() && (kilitli || ilkSatirlar.some(e => e.id === s.id && e.belgeNo === s.belgeNo))) {
      void calis(async () => { await fisBagla(kayitId, s.belgeNo, f); await oku(kayitId) })();
    } else yazS(a, 'bekleyenFis', f);
  };
  const fistenEkle = (f: File | undefined) => {
    if (!f) return;
    const s = yeniSatir({ bekleyenFis: f, aciklama: f.name.replace(/\.[^.]+$/, '') });
    setSatirlar(l => [...l.filter(x => x.belgeNo.trim() || x.tutar.trim() || x.bekleyenFis || x.id), s]);
    setSeciliSatir(s.anahtar);
  };

  const yazdir = () => {
    const w = window.open('', '_blank');
    if (!w) return;
    const satirlarHtml = satirlar.filter(s => s.belgeNo.trim()).map((s, i) => `<tr><td>${i + 1}</td><td>${s.tarih.split('-').reverse().join('.')}</td><td>${s.masrafAd}</td>
      <td>${BELGE.find(x => x[0] === s.belgeTuru)?.[1] ?? ''} ${s.belgeNo}</td><td style="text-align:right">${s.tutar}</td><td style="text-align:right">${s.kdv}</td><td>${s.aciklama}</td></tr>`).join('');
    w.document.write(`<!doctype html><meta charset="utf-8"><title>Masraf Formu ${ro.beyanNo}</title>
      <style>body{font:12px Arial;margin:28px}h2{margin:0 0 12px}table{border-collapse:collapse;width:100%;margin-bottom:12px}
      th,td{border:1px solid #999;padding:5px 7px;text-align:left}th{background:#f2f2f2}
      .imza{display:flex;gap:24px;margin-top:40px}.imza div{flex:1;border-top:1px solid #333;padding-top:6px;text-align:center}</style>
      <h2>MASRAF BEYAN FORMU</h2>
      <table><tr><th>Beyan no</th><td>${ro.beyanNo || '—'}</td><th>Tarih</th><td>${bas.beyanTarihi.split('-').reverse().join('.')}</td></tr>
      <tr><th>Personel</th><td>${personelAd}</td><th>Konu</th><td>${bas.konu}</td></tr><tr><th>Açıklama</th><td colspan="3">${bas.aciklama}</td></tr></table>
      <table><tr><th>#</th><th>Tarih</th><th>Gider kalemi</th><th>Belge</th><th>Tutar</th><th>KDV</th><th>Açıklama</th></tr>${satirlarHtml}
      <tr><th colspan="4">Toplam</th><th style="text-align:right">${yazP(toplam)}</th><th style="text-align:right">${yazP(kdv)}</th><th></th></tr></table>
      <div class="imza"><div>Beyan eden</div><div>Birim âmiri</div><div>Mali işler</div></div>
      <script>setTimeout(()=>print(),300)</script>`);
    w.document.close();
  };

  const personelAd = b?.personel?.ad || secilenAd || '';
  const benimSiram = !!oz?.veri?.onaylar?.some(o => o.kaynakTur === MASRAF_TUR && o.kaynakId === kayitId);

  const alt = (
    <>
      {yazar && !kilitli && <button type="button" className="d bir" disabled={mesgul} onClick={() => void calis(async () => { await kaydet() })()}>💾 {c('Kaydet')}</button>}
      {yazar && !kilitli && <button type="button" className="d" disabled={mesgul} onClick={() => void gonder()}>📨 {c('Onaya gönder')}</button>}
      {kayitId && <button type="button" className="d" onClick={yazdir}>🖨 {c('Masraf formu')}</button>}
      {kayitId && yazar && <button type="button" className="d" onClick={kopyala}>⧉ {c('Yeni beyan')}</button>}
      {kayitId && yazar && ro.durum <= 1 && <button type="button" className="d tl-tehlike" disabled={mesgul} onClick={() => void iptalEt()}>✖ {c('İptal et')}</button>}
      <span className="ck-bosluk" />
      <button type="button" className="d" onClick={kapat}>{c('Kapat')}</button>
    </>
  );

  return (
    <Modal baslik={`🧾 ${c('Masraf Beyanı')}${ro.beyanNo ? ` — ${ro.beyanNo}` : ''}${personelAd ? ` · ${personelAd}` : ''}`}
           ekSinif="kart-calisma" buyutmeYok alt={alt} onKapat={kapat}>
      <div className="ck-kimlik it-kimlik">
        <div className="rk-fld"><span className="ck-etiket">{c('Personel')} <b className="ak-zor">*</b></span>
          <span className="ikili" style={{ display: 'flex', gap: 4, width: '100%' }}>
            <input readOnly className="ck-buyuk" style={{ flex: 1 }} value={personelAd} placeholder={`— ${c('seçiniz')} —`}
                   disabled={!!kayitId} onClick={() => !kayitId && setArama(true)} />
            <button type="button" className="d mini" title={c('Ara')} disabled={!!kayitId} onClick={() => setArama(true)}>…</button>
          </span>
          {b?.personel && <span className="sonuk tl-kucuk">{[b.personel.bolum, b.personel.gorev].filter(Boolean).join(' · ')}</span>}</div>
        <div className="rk-fld"><span className="ck-etiket">{c('Beyan no')}</span><input value={ro.beyanNo} disabled /></div>
        <label className="rk-fld"><span className="ck-etiket">{c('Beyan tarihi')}</span>
          <input type="date" value={bas.beyanTarihi} disabled={kilitli} onChange={e => yazB('beyanTarihi', e.target.value)} /></label>
        <div className="rk-fld"><span className="ck-etiket">{c('Durum')}</span>
          <div className="ck-durum"><span className={`tl-chip ${DURUM[ro.durum]?.[1] ?? ''}`}>{c(DURUM[ro.durum]?.[0] ?? '')}
            {ro.durum === 1 && zincir.find(a => a.durum === 0) ? ` · ${zincir.find(a => a.durum === 0)!.ad}` : ''}</span></div></div>
      </div>
      {hata && <div className="hata-kutusu" style={{ margin: '8px 12px 0' }}>{hata}</div>}
      {(ro.redNeden || ro.iptalNeden) && <div className="tl-uyari" style={{ margin: '8px 12px 0' }}>{ro.redNeden ? `${c('Red nedeni')}: ${ro.redNeden}` : `${c('İptal nedeni')}: ${ro.iptalNeden}`}</div>}

      <div className="ck-govde">
        <div className="ck-sol">
          <div className="ck-grp">
            <h6>{c('Beyan')}{kilitli && <span className="ck-ek">🔒 {c('onaya gitti - satırlar kilitli, fiş eklenebilir')}</span>}</h6>
            <div className="ck-iz">
              <div className="rk-fld"><span className="ck-etiket">{c('Konu / amaç')} <b className="ak-zor">*</b></span>
                <input list="mk-konu" value={bas.konu} maxLength={100} disabled={kilitli} onChange={e => yazB('konu', e.target.value)} placeholder={c('seçin ya da yazın')} />
                <datalist id="mk-konu">{konular.map(k => <option key={k} value={k} />)}</datalist></div>
              <label className="rk-fld"><span className="ck-etiket">{c('İlgili izin')}</span>
                <select value={bas.ilgiliIzinId ?? ''} disabled={kilitli} onChange={e => yazB('ilgiliIzinId', e.target.value ? Number(e.target.value) : null)}>
                  <option value="">—</option>
                  {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                  {(b?.izinler ?? []).map((z: any) => <option key={z.id} value={z.id}>{z.ad}</option>)}
                </select></label>
              <label className="rk-fld ck-tam"><span className="ck-etiket">{c('Açıklama')}</span>
                <input value={bas.aciklama} maxLength={300} disabled={kilitli} onChange={e => yazB('aciklama', e.target.value)} /></label>
            </div>
          </div>

          <div className="ck-grp">
            <h6>{c('Harcamalar')}<span className="ck-ek">{c('her satır bir belgedir · belgesiz satır yazılamaz')}</span></h6>
            <div style={{ padding: '8px 12px 0', overflowX: 'auto' }}>
              <table className="mk-satirlar">
                <thead><tr><th>#</th><th>{c('Tarih')}</th><th>{c('Gider kalemi')}</th><th>{c('Belge')}</th><th>{c('Belge no')}</th>
                  <th className="r">{c('Tutar')}</th><th className="r">{c('KDV')}</th><th>{c('Açıklama')}</th><th>{c('Fiş')}</th><th /></tr></thead>
                <tbody>
                  {satirlar.map((s, i) => {
                    // eslint-disable-next-line @typescript-eslint/no-explicit-any
                    const uyar = (b?.kontrol ?? []).some((k: any) => k.sira === i + 1 && s.id);
                    return (
                      <tr key={s.anahtar} className={`${seciliSatir === s.anahtar ? 'mk-secili' : ''}${uyar ? ' mk-uyar' : ''}`} onClick={() => setSeciliSatir(s.anahtar)}>
                        <td>{i + 1}</td>
                        <td><input type="date" value={s.tarih} disabled={kilitli} onChange={e => yazS(s.anahtar, 'tarih', e.target.value)} /></td>
                        <td><input list="mk-kalem" value={s.masrafAd} disabled={kilitli} placeholder={c('ara…')}
                                   onChange={e => {
                                     // eslint-disable-next-line @typescript-eslint/no-explicit-any
                                     const k = (b?.kalemler ?? []).find((x: any) => x.ad === e.target.value);
                                     setSatirlar(l => l.map(x => x.anahtar === s.anahtar ? { ...x, masrafAd: e.target.value, masrafId: k ? k.id : null } : x));
                                   }} /></td>
                        <td><select value={s.belgeTuru} disabled={kilitli} onChange={e => yazS(s.anahtar, 'belgeTuru', Number(e.target.value))}>
                          {BELGE.map(([k, a]) => <option key={k} value={k}>{c(a)}</option>)}</select></td>
                        <td><input value={s.belgeNo} maxLength={60} disabled={kilitli} onChange={e => yazS(s.anahtar, 'belgeNo', e.target.value)} /></td>
                        <td><input className="r" inputMode="decimal" value={s.tutar} disabled={kilitli} onChange={e => yazS(s.anahtar, 'tutar', e.target.value)} /></td>
                        <td><input className="r" inputMode="decimal" value={s.kdv} disabled={kilitli} onChange={e => yazS(s.anahtar, 'kdv', e.target.value)} /></td>
                        <td><input value={s.aciklama} maxLength={300} disabled={kilitli} onChange={e => yazS(s.anahtar, 'aciklama', e.target.value)} /></td>
                        <td>{s.fisId ? <button type="button" className="mk-fis mk-fis-var" title={c('Fişi gör')} onClick={() => setSeciliSatir(s.anahtar)}>📎</button>
                          : s.bekleyenFis ? <span className="mk-fis mk-fis-var" title={s.bekleyenFis.name}>⏳</span>
                          : <button type="button" className="mk-fis mk-fis-yok" title={c('Fiş ekle')} disabled={!yazar} onClick={e => { e.stopPropagation(); fisSec(s.anahtar) }}>＋</button>}</td>
                        <td>{!kilitli && <button type="button" className="cl-bag sonuk" title={c('Satırı sil')}
                              onClick={e => { e.stopPropagation(); setSatirlar(l => l.filter(x => x.anahtar !== s.anahtar)) }}>✕</button>}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
              <datalist id="mk-kalem">{/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                {(b?.kalemler ?? []).map((k: any) => <option key={k.id} value={k.ad}>{k.kod}</option>)}</datalist>
            </div>
            {!kilitli && (
              <div className="mk-ekle">
                <button type="button" className="d" onClick={() => { const s = yeniSatir(); setSatirlar(l => [...l, s]); setSeciliSatir(s.anahtar) }}>＋ {c('Satır')}</button>
                <button type="button" className="d" onClick={() => yeniFisRef.current?.click()}>📷 {c('Fiş fotoğrafından ekle')}</button>
                <button type="button" className="d" disabled={!secili} onClick={() => {
                  if (!secili) return;
                  const s = yeniSatir({ ...secili, anahtar: '', id: null, belgeNo: '', fisId: null, bekleyenFis: null });
                  s.anahtar = `y${++sayac}`;
                  setSatirlar(l => [...l, s]); setSeciliSatir(s.anahtar);
                }}>⧉ {c('Satırı çoğalt')}</button>
              </div>
            )}
            <input ref={fisRef} type="file" accept="image/*,application/pdf" capture="environment" hidden onChange={e => { fisGeldi(e.target.files?.[0]); e.target.value = '' }} />
            <input ref={yeniFisRef} type="file" accept="image/*,application/pdf" capture="environment" hidden onChange={e => { fistenEkle(e.target.files?.[0]); e.target.value = '' }} />
            <div className="mk-toplam">
              <span>{satirlar.filter(s => s.belgeNo.trim()).length} {c('belge')}</span>
              <span>{c('KDV')}: <b>{yazP(kdv)}</b></span>
              <span>{c('KDV hariç')}: <b>{yazP(toplam - kdv)}</b></span>
              <span>{c('Toplam')}: <b>{yazP(toplam)} ₺</b></span>
            </div>
          </div>
        </div>

        <div className="ck-sag">
          <div className="ck-grp ck-grp-sag">
            <h6>{c('Fiş önizleme')}<span className="ck-ek">{secili ? `${c('satır')} ${satirlar.indexOf(secili) + 1}${secili.belgeNo ? ` · ${secili.belgeNo}` : ''}` : ''}</span></h6>
            <div className="mk-oniz">
              {onizUrl && onizDok?.contentType?.startsWith('image/')
                ? <img src={onizUrl.url} alt={onizDok.ad} onClick={() => window.open(onizUrl.url, '_blank')} />
                : onizUrl ? <button type="button" className="d" onClick={() => window.open(onizUrl.url, '_blank')}>📄 {onizDok?.ad ?? c('Fişi aç')}</button>
                : secili?.bekleyenFis ? <span className="sonuk">⏳ {secili.bekleyenFis.name} — {c('kayıtta yüklenir')}</span>
                : <span className="sonuk">{secili ? c('Bu satırın fişi yok.') : c('Satır seçin.')}</span>}
            </div>
          </div>

          <div className="ck-grp ck-grp-sag">
            <h6>{c('Kontrol')}<span className="ck-ek">{c('göndermeden önce')}</span></h6>
            <div className="mk-kontrol">
              {kontrol.map((k, i) => <div key={i} className={`mk-k-${k.tur}`}>{k.metin}</div>)}
            </div>
          </div>

          {dagilim.length > 0 && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Gider dağılımı')}</h6>
              <div className="mk-dagilim">
                {dagilim.map(([ad, t]) => (
                  <div key={ad} className="mk-dg"><span title={ad}>{ad}</span><span className="mk-cb"><i style={{ width: `${toplam ? (t / toplam) * 100 : 0}%` }} /></span><span className="r">{tl(t)}</span></div>
                ))}
              </div>
            </div>
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
                      <span><b>{a.ad}</b><small>{a.kararZamani ? tarihSaat(a.kararZamani) : sira ? c('bekliyor') : ''}{a.gerekce ? ` · “${a.gerekce}”` : ''}</small></span>
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
              <div className="tl-bilgi" style={{ margin: '0 12px 12px' }}>{c('Ödeme bu modülde değil: onaylanan beyan muhasebeye düşer. Talep eden Taleplerim\'de "Bana ödenecek" olarak görür.')}</div>
            </div>
          )}

          {(b?.gecmis?.length ?? 0) > 0 && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Son beyanlar')}<span className="ck-ek">{c('son 12 ay')}</span></h6>
              <table className="av-gecmis"><tbody>
                {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                {b.gecmis.map((g: any, i: number) => (
                  <tr key={i}><td>{g.no}</td><td>{s10(g.tarih).split('-').reverse().join('.')}</td><td className="r">{yazP(Number(g.tutar))} ₺</td>
                    <td><span className={`tl-chip ${DURUM[g.durum]?.[1] ?? ''}`}>{c(DURUM[g.durum]?.[0] ?? '')}</span></td></tr>
                ))}
              </tbody></table>
            </div>
          )}

          {kayitId && (b?.akis?.length ?? 0) > 0 && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Akış')}<span className="ck-ek">{c('en yeni altta')}</span></h6>
              <div className="it-akis">
                {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                {b.akis.map((a: any, i: number) => (
                  <div key={i} className={a.tur === 'red' || a.tur === 'iptal' ? 'tl-gec' : ''}>
                    {a.tur === 'olustu' ? c('Beyan oluşturuldu') : a.tur === 'gonderildi' ? `${c('Onaya gönderildi')}${a.metin ? `: ${a.metin}` : ''}`
                      : a.tur === 'onay' ? `✓ ${a.metin} ${c('onayladı')}` : a.tur === 'red' ? `✕ ${a.metin} ${c('reddetti')}`
                      : a.tur === 'bilgi' ? `? ${a.metin} ${c('bilgi istedi')}` : a.tur === 'iptal' ? `${c('İptal edildi')}${a.metin ? `: ${a.metin}` : ''}` : a.metin}
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
          onSec={sec => { setBas(o => ({ ...o, tarafId: sec.id })); setSecilenAd(sec.unvan); setArama(false) }} />
      )}
    </Modal>
  );
}
