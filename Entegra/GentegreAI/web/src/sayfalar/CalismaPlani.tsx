import { Fragment, useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni, type CalismaBlok, type CalismaPlaniYaniti } from '../api/sozlesme';
import type { CalismaBugun } from '../api/uclar/ayar';
import { useOturum } from '../kimlik/OturumBaglami';
import { tarihYaz } from '../bilesenler/bicim';
import { c } from '../dil/ceviri';

/**
 * ÇALIŞMA PLANLARI (711) — mockup `Ekranlar/Randevu/calisma_planlari.html`.
 *
 * Plan ELLE ÇİZİLMEZ: şablon tekrar eder, istisna ezer; bu sayfa türetilmiş
 * blokları (`fn_hekim_calisma_bloklari`) gösterir. Üç görünüm:
 *   * Doktor × gün: hücrede mini zaman şeridi + saat + dolu / slot; istisna
 *     türleri renkli, İK izni kesikli, ONAY BEKLEYEN istisna turuncu kesikli
 *     çerçeve (plan henüz uygulamaz ama görünsün); bölüme göre grup, gün
 *     başlığında günün slotu, satır sonunda haftalık saat / doluluk; sağ panel
 *     seçili hücre (slot ızgarası, randevular, eylemler).
 *   * Bölüm doluluğu: bölüm × gün doktor sayısı + doluluk; planlı gün ama
 *     doktor yoksa kırmızı taralı.
 *   * Bugün çalışanlar: "şimdi" çizgili gün şeridi, muayenede / saat dışı /
 *     bugün yok, sıradaki boş saat, gelmeyecek doktorun aktarılmamış randevusu.
 * Satır başındaki kutu: işaretli doktorla İzin / İstisna kartı doktor kilitli açılır.
 */
const GUN_AD = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
const ISTISNA: Record<number, [string, string]> = {
  1: ['✈️', 'İzin'], 2: ['🎓', 'Kongre / eğitim'], 3: ['🕘', 'Saat değişikliği'], 4: ['➕', 'Ek mesai'], 5: ['⛔', 'Kapalı'],
};
const KAPATAN = (t: number) => t === 1 || t === 2 || t === 5;
type Gorunum = 'doktor' | 'bolum' | 'bugun';

const iso = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const haftaBasi = (d: Date) => { const x = new Date(d); const g = (x.getDay() + 6) % 7; x.setDate(x.getDate() - g); x.setHours(0, 0, 0, 0); return x };
const haftaNo = (d: Date) => {
  const t = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
  const g = t.getUTCDay() || 7; t.setUTCDate(t.getUTCDate() + 4 - g);
  return Math.ceil(((t.getTime() - Date.UTC(t.getUTCFullYear(), 0, 1)) / 864e5 + 1) / 7);
};
const dk = (s?: string | null) => (s ? Number(s.slice(0, 2)) * 60 + Number(s.slice(3, 5)) : NaN);
const kisaSaat = (s?: string | null) => (s ?? '').replace(/:00$/, '');
const CETVEL_BAS = 8 * 60, CETVEL_BOY = 11 * 60;                     // 08-19
const sol = (m: number) => `${Math.max(0, Math.min(100, (100 * (m - CETVEL_BAS)) / CETVEL_BOY))}%`;
const gen = (a: number, b: number) => `${Math.max(0, Math.min(100, (100 * (Math.min(b, CETVEL_BAS + CETVEL_BOY) - Math.max(a, CETVEL_BAS))) / CETVEL_BOY))}%`;
const acikMi = (b: CalismaBlok) => (b.kaynak === 1 || b.kaynak === 2) && !!b.saatBas;
const kapasite = (b: CalismaBlok) => (acikMi(b) ? Math.floor((dk(b.saatBit) - dk(b.saatBas)) / Math.max(b.slotDk, 1)) : 0);
const gunIso = (b: { gun: string }) => String(b.gun).slice(0, 10);

interface Satir { anahtar: string; hekimId: number; hekim: string; departmanId: number; departman: string; sube: string; bloklar: CalismaBlok[] }

export function CalismaPlani() {
  const git = useNavigate();
  const { yetki, kullanici } = useOturum();
  // SON AÇILAN EN ÜSTTE (kullanıcı: "son kartı açılan en üstte bulunacak şekilde
  //   listelensin"): kartı açılan doktorlar en yeni başta tutulur (bu tarayıcıda,
  //   kullanıcı başına); bölüme göre grupta o doktorun bölümü de başa gelir.
  const sonAnahtar = `gentegre.calismaPlani.son.${kullanici?.id ?? 0}`;
  const [sonAcilan, setSonAcilan] = useState<number[]>(() => {
    try { return JSON.parse(localStorage.getItem(sonAnahtar) ?? '[]') as number[] } catch { return [] }
  });
  const kartaGit = (hekimId: number, yol: string) => {
    const yeni = [hekimId, ...sonAcilan.filter(x => x !== hekimId)].slice(0, 30);
    setSonAcilan(yeni);
    try { localStorage.setItem(sonAnahtar, JSON.stringify(yeni)) } catch { /* depolama yoksa sıra oturumluk */ }
    git(yol);
  };
  const yazar = yetki('randevu.plan');
  const [bas, setBas] = useState<Date>(() => haftaBasi(new Date()));
  const [veri, setVeri] = useState<CalismaPlaniYaniti | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [hekimId, setHekimId] = useState<number | null>(null);
  const [departmanId, setDepartmanId] = useState<number | null>(null);
  const [sube, setSube] = useState<number | null>(null);
  const [gorunum, setGorunum] = useState<Gorunum>('doktor');
  const [grupla, setGrupla] = useState(true);
  const [yalnizIstisnali, setYalnizIstisnali] = useState(false);
  const [ara, setAra] = useState('');
  const [bugun, setBugun] = useState<CalismaBugun | null>(null);
  const [bugunCip, setBugunCip] = useState<'' | 'muayenede' | 'disi' | 'yok'>('');
  const [secili, setSecili] = useState<{ anahtar: string; gun: string } | null>(null);
  const [gunRandevu, setGunRandevu] = useState<{ id: number; saat: string; sureDk: number; durum: number; hasta: string; tip: string }[] | null>(null);
  // SATIR SEÇİMİ (kullanıcı): işaretli doktorla "İzin / İstisna" kartı doktoru
  //   dolu ve KİLİTLİ açar. İstisna tek doktorludur - tek satır işaretlenir.
  const [isaretli, setIsaretli] = useState<{ hekimId: number; ad: string } | null>(null);

  const gunler = useMemo(() => Array.from({ length: 7 }, (_, i) => { const d = new Date(bas); d.setDate(d.getDate() + i); return d }), [bas]);
  const bugunIso = iso(new Date());
  const yukle = useCallback(async () => {
    try {
      setVeri(await api.calismaPlani({ bas: iso(gunler[0]), bit: iso(gunler[6]), hekimId, departmanId, sube: sube ?? 0, ozet: 1 }));
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [gunler, hekimId, departmanId, sube]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => {
    if (gorunum === 'bugun') api.calismaBugun(undefined, sube ?? 0).then(setBugun).catch(h => setHata(hataMetni(h)));
  }, [gorunum, sube]);

  const bloklar = veri?.bloklar ?? [];
  const bekleyen = veri?.bekleyenIstisnalar ?? [];
  const subeAd = (id: number) => veri?.subeler.find(s => s.id === id)?.ad ?? '';

  // SATIRLAR: doktor × bölüm × şube.
  const satirlar = useMemo(() => {
    const m = new Map<string, Satir>();
    for (const b of bloklar) {
      const k = `${b.hekimId}|${b.departmanId}|${b.subeId}`;
      const r = m.get(k) ?? { anahtar: k, hekimId: b.hekimId, hekim: b.hekim, departmanId: b.departmanId, departman: b.departman || c('Bölümsüz'), sube: subeAd(b.subeId), bloklar: [] };
      r.bloklar.push(b); m.set(k, r);
    }
    let l = [...m.values()];
    const a = ara.trim().toLocaleLowerCase('tr');
    // Doktor ya da bölüm adında arar (kullanıcı: "bölüm de arasın").
    if (a) l = l.filter(r => r.hekim.toLocaleLowerCase('tr').includes(a) || r.departman.toLocaleLowerCase('tr').includes(a));
    if (yalnizIstisnali) l = l.filter(r => r.bloklar.some(b => b.kaynak !== 1) || bekleyen.some(p => p.hekimId === r.hekimId));
    const sira = (id: number) => { const i = sonAcilan.indexOf(id); return i < 0 ? 1e9 : i };
    const bolumSira = new Map<string, number>();
    for (const r of l) bolumSira.set(r.departman, Math.min(bolumSira.get(r.departman) ?? 1e9, sira(r.hekimId)));
    return l.sort((x, y) =>
      (grupla ? (bolumSira.get(x.departman)! - bolumSira.get(y.departman)!) || x.departman.localeCompare(y.departman, 'tr') : 0)
      || sira(x.hekimId) - sira(y.hekimId)
      || x.hekim.localeCompare(y.hekim, 'tr'));
  }, [bloklar, bekleyen, ara, yalnizIstisnali, grupla, veri, sonAcilan]);   // eslint-disable-line react-hooks/exhaustive-deps

  const gunBloklari = (r: Satir, g: string) => r.bloklar.filter(b => gunIso(b) === g);
  const bekleyenGun = (hid: number, g: string) => bekleyen.find(p => p.hekimId === hid && String(p.bas).slice(0, 10) <= g && String(p.bit).slice(0, 10) >= g);
  const satirOzet = (bl: CalismaBlok[]) => {
    const ac = bl.filter(acikMi);
    const kap = ac.reduce((t, b) => t + kapasite(b), 0);
    const dolu = ac.reduce((t, b) => t + (b.dolu ?? 0), 0);
    const dkm = ac.reduce((t, b) => t + dk(b.saatBit) - dk(b.saatBas), 0);
    return { kap, dolu, saat: Math.round(dkm / 6) / 10, yuzde: kap ? Math.round((100 * dolu) / kap) : 0 };
  };

  // ÖZET ŞERİDİ (görünür hafta, süzgeçten bağımsız değil - sayfanın süzgeciyle).
  const ozet = useMemo(() => {
    const acik = bloklar.filter(acikMi);
    const kapali = bloklar.filter(b => b.kaynak === 3 || b.kaynak === 4);
    const bolumGun = new Map<string, { ad: string; gun: string; acik: number; kapali: number }>();
    for (const b of bloklar) {
      const k = `${b.departmanId}|${gunIso(b)}`;
      const v = bolumGun.get(k) ?? { ad: b.departman, gun: gunIso(b), acik: 0, kapali: 0 };
      if (acikMi(b)) v.acik++; else if (b.kaynak === 3 || b.kaynak === 4) v.kapali++;
      bolumGun.set(k, v);
    }
    const doktorsuz = [...bolumGun.values()].filter(v => v.acik === 0 && v.kapali > 0);
    const bolumDol = new Map<string, { kap: number; dolu: number }>();
    for (const b of acik) { const v = bolumDol.get(b.departman) ?? { kap: 0, dolu: 0 }; v.kap += kapasite(b); v.dolu += b.dolu ?? 0; bolumDol.set(b.departman, v) }
    const enDolu = [...bolumDol.entries()].filter(([, v]) => v.kap > 0).sort((a, b) => b[1].dolu / b[1].kap - a[1].dolu / a[1].kap)[0];
    const kap = acik.reduce((t, b) => t + kapasite(b), 0);
    const dolu = acik.reduce((t, b) => t + (b.dolu ?? 0), 0);
    return {
      doktor: new Set(acik.map(b => b.hekimId)).size, bolum: new Set(acik.map(b => b.departmanId)).size, sube: new Set(acik.map(b => b.subeId)).size,
      kap, dolu, yuzde: kap ? Math.round((100 * dolu) / kap) : 0,
      enDolu: enDolu ? `${enDolu[0]} %${Math.round((100 * enDolu[1].dolu) / enDolu[1].kap)}` : '',
      izinli: new Set(kapali.map(b => b.hekimId)).size, kapaliGun: new Set(kapali.map(b => `${b.hekimId}|${gunIso(b)}`)).size,
      doktorsuz,
    };
  }, [bloklar]);

  // Seçili hücre: o günün randevuları.
  const seciliSatir = secili ? satirlar.find(r => r.anahtar === secili.anahtar) ?? null : null;
  useEffect(() => {
    if (!secili || !seciliSatir) { setGunRandevu(null); return }
    let iptal = false;
    api.calismaGun(seciliSatir.hekimId, secili.gun).then(y => { if (!iptal) setGunRandevu(y.randevular) }).catch(() => { if (!iptal) setGunRandevu([]) });
    return () => { iptal = true };
  }, [secili?.anahtar, secili?.gun]);   // eslint-disable-line react-hooks/exhaustive-deps

  const hucreAc = (r: Satir, g: string) => {
    const bl = gunBloklari(r, g);
    const ist = bl.find(b => b.istisnaId);
    const sab = bl.find(b => b.sablonId);
    const p = bekleyenGun(r.hekimId, g);
    if (ist?.istisnaId) kartaGit(r.hekimId, `/calisma-istisna/${ist.istisnaId}?geri=%2Fcalisma-plani`);
    else if (p) kartaGit(r.hekimId, `/calisma-istisna/${p.id}?geri=%2Fcalisma-plani`);
    else if (sab?.sablonId) kartaGit(r.hekimId, `/calisma-sablon/${sab.sablonId}?geri=%2Fcalisma-plani`);
    else if (bl.some(b => b.kaynak === 4)) kartaGit(r.hekimId, '/personel-izin');
    else if (yazar) kartaGit(r.hekimId, `/calisma-istisna/yeni?hekimId=${r.hekimId}&sabit=1&tur=4&tarih=${g}&geri=%2Fcalisma-plani`);
  };

  const Hucre = (r: Satir, g: string) => {
    const bl = gunBloklari(r, g);
    const kap = bl.find(b => b.kaynak === 3 || b.kaynak === 4);
    const p = bekleyenGun(r.hekimId, g);
    const sec = secili?.anahtar === r.anahtar && secili.gun === g;
    const tik = () => setSecili({ anahtar: r.anahtar, gun: g });
    // SAATLİ KAPANIŞ (948): gün açık kalır, kapanan saat bloktan kırpılmıştır -
    //   hücre açık bloklarla çizilir, kapanış altına not düşülür.
    const acikVar = bl.some(acikMi);
    if (kap && !acikVar) {
      const [ic, ad] = kap.kaynak === 4 ? ['🌴', kap.aciklama || c('İK izni')] : ISTISNA[kap.istisnaTur ?? 5] ?? ISTISNA[5];
      return <div className={`pl-hc kapali${kap.kaynak === 4 ? ' ik' : ''}${sec ? ' sel' : ''}`} onClick={tik} onDoubleClick={() => hucreAc(r, g)}>
        {ic} {c(ad)}<small>{kap.kaynak === 4 ? c('İK izni') : kap.aciklama}</small></div>;
    }
    if (p && KAPATAN(p.tur) && !(p.saatBas && p.saatBit) && !kap) {
      const [ic, ad] = ISTISNA[p.tur];
      return <div className={`pl-hc kapali bekliyor${sec ? ' sel' : ''}`} onClick={tik} onDoubleClick={() => hucreAc(r, g)}
                  title={c('Onay bekliyor - onaylanana kadar plan açık, randevu verilebilir')}>
        {ic} {c(ad)}<small>{c('onay bekliyor')}{p.randevu ? ` · ${p.randevu} rnd` : ''}</small></div>;
    }
    const ac = bl.filter(acikMi).sort((a, b) => dk(a.saatBas) - dk(b.saatBas));
    if (ac.length === 0) return <div className="pl-bos" onDoubleClick={() => hucreAc(r, g)} title={yazar ? c('Çift tık: bu güne ek mesai') : undefined}>—</div>;
    const saat = ac.find(b => b.istisnaTur === 3);
    const ek = ac.find(b => b.istisnaTur === 4);
    const o = satirOzet(ac);
    const sinif = o.kap > 0 && o.dolu >= o.kap ? 'dolu' : o.yuzde >= 80 ? 'yuk' : '';
    const ad = ac.find(b => b.sablon && b.sablon !== 'Standart hafta')?.sablon;
    return (
      <div className={`pl-hc${saat ? ' ist' : ek ? ' ekm' : ''}${p ? ' bekliyor' : ''}${sec ? ' sel' : ''}`} onClick={tik} onDoubleClick={() => hucreAc(r, g)}
           title={ac.map(b => `${b.saatBas}–${b.saatBit} · ${b.slotDk} dk · ${b.kanallar}`).join('\n') + (p ? `\n${c('Onay bekleyen istisna')}: ${c(ISTISNA[p.tur][1])}` : '')}>
        <div className="z">{ac.map((b, i) => <i key={i} className={b.istisnaTur === 4 ? 'ek' : b.istisnaTur === 3 ? 'sd' : ''}
                                                style={{ left: sol(dk(b.saatBas)), width: gen(dk(b.saatBas), dk(b.saatBit)) }} />)}</div>
        {kap && <div className="k">{ISTISNA[kap.istisnaTur ?? 1]?.[0]} {kap.aciklama.split(' · ')[0]}</div>}
        {p && KAPATAN(p.tur) && p.saatBas && <div className="k">{ISTISNA[p.tur][0]} {p.saatBas}–{p.saatBit} · {c('onay bekliyor')}</div>}
        <div className="t"><span>{ek && ac.length === 1 ? '+ ' : ''}{kisaSaat(ac[0].saatBas)}–{kisaSaat(ac[ac.length - 1].saatBit)}
          {saat ? ` ${c('değişti')}` : ek ? ` ${c('ek')}` : ad ? ` · ${ad}` : ''}</span><em className={sinif}>{o.dolu}/{o.kap}</em></div>
      </div>
    );
  };

  // BÖLÜM DOLULUĞU
  const bolumSatirlari = useMemo(() => {
    const m = new Map<number, { ad: string; doktor: Set<number>; gun: Record<string, { dr: Set<number>; kap: number; dolu: number; kapali: number; ek: boolean }> }>();
    for (const b of bloklar) {
      const r = m.get(b.departmanId) ?? { ad: b.departman, doktor: new Set<number>(), gun: {} };
      const g = r.gun[gunIso(b)] ??= { dr: new Set<number>(), kap: 0, dolu: 0, kapali: 0, ek: false };
      if (acikMi(b)) { g.dr.add(b.hekimId); g.kap += kapasite(b); g.dolu += b.dolu ?? 0; r.doktor.add(b.hekimId); if (b.istisnaTur === 4) g.ek = true }
      else if (b.kaynak === 3 || b.kaynak === 4) g.kapali++;
      m.set(b.departmanId, r);
    }
    return [...m.entries()].map(([id, v]) => ({ id, ...v })).sort((a, b) => a.ad.localeCompare(b.ad, 'tr'));
  }, [bloklar]);

  const isaretleSec = (r: Satir, on: boolean) => setIsaretli(on ? { hekimId: r.hekimId, ad: r.hekim } : null);
  const istisnaYolu = (hid?: number) => hid ? `/calisma-istisna/yeni?hekimId=${hid}&sabit=1&geri=%2Fcalisma-plani` : '/calisma-istisna/yeni?geri=%2Fcalisma-plani';

  // Sağ panel verisi
  const seciliBloklar = seciliSatir && secili ? gunBloklari(seciliSatir, secili.gun) : [];
  const seciliAcik = seciliBloklar.filter(acikMi).sort((a, b) => dk(a.saatBas) - dk(b.saatBas));
  const seciliKapali = seciliBloklar.find(b => b.kaynak === 3 || b.kaynak === 4);
  const seciliBekleyen = seciliSatir && secili ? bekleyenGun(seciliSatir.hekimId, secili.gun) : undefined;
  const slotlar = seciliAcik.flatMap(b => {
    const l: { saat: string; dolu: boolean }[] = [];
    for (let t = dk(b.saatBas); t + b.slotDk <= dk(b.saatBit); t += Math.max(b.slotDk, 5)) {
      const s = `${String(Math.floor(t / 60)).padStart(2, '0')}:${String(t % 60).padStart(2, '0')}`;
      l.push({ saat: s, dolu: (gunRandevu ?? []).some(r => dk(r.saat) < t + b.slotDk && t < dk(r.saat) + Math.max(r.sureDk, 1)) });
    }
    return l;
  });
  const haftaIstisnalari = seciliSatir ? [
    ...[...new Map(seciliSatir.bloklar.filter(b => b.istisnaId).map(b => [b.istisnaId!, b])).values()].map(b => ({
      id: b.istisnaId!, tur: b.istisnaTur ?? 5, bekliyor: false, gunler: seciliSatir.bloklar.filter(x => x.istisnaId === b.istisnaId).map(gunIso), randevu: 0,
    })),
    ...bekleyen.filter(p => p.hekimId === seciliSatir.hekimId).map(p => ({ id: p.id, tur: p.tur, bekliyor: true, gunler: [String(p.bas).slice(0, 10), String(p.bit).slice(0, 10)], randevu: p.randevu })),
  ] : [];

  const bugunSatirlari = (bugun?.satirlar ?? []).filter(s => departmanId === null || s.departmanId === departmanId);
  const bugunSay = { muayenede: bugunSatirlari.filter(s => s.durum === 'muayenede').length, disi: bugunSatirlari.filter(s => s.durum === 'saat-disi' || s.durum === 'bitti').length, yok: bugunSatirlari.filter(s => s.durum === 'yok').length };
  const bugunGoster = bugunSatirlari.filter(s => !bugunCip || (bugunCip === 'muayenede' ? s.durum === 'muayenede' : bugunCip === 'yok' ? s.durum === 'yok' : s.durum === 'saat-disi' || s.durum === 'bitti'));

  return (
    <>
      <div className="sayfabas"><div className="basrow"><h1>{c('Çalışma Planları')}</h1>
        <span className="yol">{c('Randevu › Çalışma Planları')} · {c('şablondan türer, istisna ezer — elle çizilmez')}</span></div></div>
      <div className="pl-sayfa">
        <div className="cl-arac">
          {yazar && <button type="button" className="d bir" onClick={() => git('/calisma-sablon/yeni?geri=%2Fcalisma-plani')}>＋ {c('Şablon')}</button>}
          {/* Izin / istisna, sablonlar, istisnalar, takvim dugmeleri kaldirildi (kullanici);
              isaretli doktorla izin / istisna secim seridinde. */}
          <span className="cl-ayrac" />
          {([['doktor', 'Doktor × gün'], ['bolum', 'Bölüm doluluğu'], ['bugun', 'Bugün çalışanlar']] as [Gorunum, string][]).map(([k, a]) => (
            <button key={k} type="button" className={`ck-cip${gorunum === k ? ' on' : ''}`} onClick={() => setGorunum(k)}>{c(a)}</button>
          ))}
        </div>
        {gorunum !== 'bugun' && (
          <div className="cl-arac">
            <button type="button" className="d ck-kucuk" onClick={() => setBas(b => { const d = new Date(b); d.setDate(d.getDate() - 7); return d })}>‹</button>
            <button type="button" className="d ck-kucuk" onClick={() => setBas(haftaBasi(new Date()))}>{c('Bu hafta')}</button>
            <button type="button" className="d ck-kucuk" onClick={() => setBas(b => { const d = new Date(b); d.setDate(d.getDate() + 7); return d })}>›</button>
            <b className="pl-hafta">{tarihYaz(iso(gunler[0])).slice(0, 5)} – {tarihYaz(iso(gunler[6]))}</b>
            <span className="sonuk">{haftaNo(gunler[0])}. {c('hafta')}</span>
          </div>
        )}
        {gorunum !== 'bugun' && (
          <div className="cl-arac">
            {/* AYRI SATIR (kullanıcı): doktor ara solda, şube / bölüm / doktor ve çipler sağında. */}
            {gorunum === 'doktor' && <input className="pl-ara" value={ara} placeholder={`🔍 ${c('Doktor / Bölüm ara…')}`} onChange={e => setAra(e.target.value)} />}
            <select value={sube ?? ''} onChange={e => setSube(e.target.value ? Number(e.target.value) : null)}><option value="">{c('Şube: Tümü')}</option>{veri?.subeler.map(s => <option key={s.id} value={s.id}>{s.ad}</option>)}</select>
            <select value={departmanId ?? ''} onChange={e => setDepartmanId(e.target.value ? Number(e.target.value) : null)}><option value="">{c('Bölüm: Tümü')}</option>{veri?.bolumler.map(b => <option key={b.id} value={b.id}>{b.ad}{b.randevusuz ? ` (${c('randevusuz')})` : ''}</option>)}</select>
            <select value={hekimId ?? ''} onChange={e => setHekimId(e.target.value ? Number(e.target.value) : null)}><option value="">{c('Doktor: Tümü')}</option>{veri?.hekimler.map(h => <option key={h.id} value={h.id}>{h.ad}</option>)}</select>
            {gorunum === 'doktor' && <>
              <button type="button" className={`ck-cip${grupla ? ' on' : ''}`} onClick={() => setGrupla(g => !g)}>{c('Bölüme göre grupla')}</button>
              <button type="button" className={`ck-cip${yalnizIstisnali ? ' on' : ''}`} onClick={() => setYalnizIstisnali(v => !v)}>{c('Yalnız istisnalı')}</button>
            </>}
          </div>
        )}

        {gorunum !== 'bugun' && (
          <div className="cl-ozetler pl-ozet5">
            <div className="cl-kpi"><span className="k">{c('Bu hafta çalışan')}</span><span className="v">{ozet.doktor} {c('doktor')}</span>
              <span className="a">{ozet.bolum} {c('bölüm')} · {ozet.sube} {c('şube')}</span></div>
            <div className="cl-kpi"><span className="k">{c('Kapasite / dolu')}</span><span className="v">{ozet.kap.toLocaleString('tr-TR')} / {ozet.dolu.toLocaleString('tr-TR')}</span>
              <span className="a">{c('doluluk')} %{ozet.yuzde}{ozet.enDolu ? ` · ${c('en dolu')} ${ozet.enDolu}` : ''}</span></div>
            <button type="button" className={`cl-kpi${ozet.izinli ? ' dikkat' : ''}`} onClick={() => { setGorunum('doktor'); setYalnizIstisnali(v => !v) }}>
              <span className="k">{c('İzinli / kongrede')}</span><span className="v">{ozet.izinli} {c('doktor')}</span>
              <span className="a">{c('bu hafta')} {ozet.kapaliGun} {c('gün kapalı')} · <u>{yalnizIstisnali ? c('tümünü göster') : c('göster')}</u></span></button>
            <button type="button" className={`cl-kpi${ozet.doktorsuz.length ? ' kirmizi' : ''}`} onClick={() => setGorunum('bolum')}>
              <span className="k">{c('Doktorsuz bölüm-gün')}</span><span className="v">{ozet.doktorsuz.length}</span>
              <span className="a">{ozet.doktorsuz.slice(0, 3).map(v => `${v.ad} ${GUN_AD[(new Date(v.gun + 'T00:00:00').getDay() + 6) % 7]}`).join(' · ') || '—'}{ozet.doktorsuz.length ? <> · <u>{c('göster')}</u></> : null}</span></button>
            <button type="button" className={`cl-kpi${veri?.islemBekleyen ? ' dikkat' : ''}`} onClick={() => git('/calisma-istisna')}>
              <span className="k">{c('İşlem bekleyen randevu')}</span><span className="v">{veri?.islemBekleyen ?? 0}</span>
              <span className="a">{c('kapanan günlerde')} · <u>{c('istisnaya git')}</u></span></button>
          </div>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}

        {gorunum === 'doktor' && (<>
          <div className="pl-lej">
            <span><i className="l-sab" />{c('şablon (tekrar eder)')}</span><span><i className="l-sd" />{c('saat değişikliği')}</span>
            <span><i className="l-ek" />{c('ek mesai')}</span><span><i className="l-kap" />{c('izin / kongre / kapalı')}</span>
            <span><i className="l-bek" />{c('istisna onay bekliyor')}</span>
            <span className="cl-sag">{c('hücre: saat · dolu / slot (turuncu %80+, kırmızı dolu) · mini şerit 08–19')}</span>
          </div>
          {isaretli && (
            <div className="cl-toplu">☑ <b>{c('1 doktor seçili')}</b> — {isaretli.ad}
              {yazar && <button type="button" className="d ck-kucuk" onClick={() => kartaGit(isaretli.hekimId, istisnaYolu(isaretli.hekimId))}>✈️ {c('İzin / istisna…')}</button>}
              <button type="button" className="d ck-kucuk" onClick={() => git(`/calisma-sablon?ara=${encodeURIComponent(isaretli.ad.replace(/^(Prof\.|Doç\.|Op\.|Uzm\.)?\s*Dr\.\s*/i, ''))}`)}>📋 {c('Şablonlarını aç')}</button>
              <button type="button" className="d ck-kucuk" onClick={() => git(`/randevu?hekimId=${isaretli.hekimId}`)}>📅 {c('Randevuları')}</button>
              <button type="button" className="cl-bag cl-sag" onClick={() => setIsaretli(null)}>{c('Seçimi kaldır')} ✕</button>
            </div>
          )}
          <div className="pl-govde">
            <div className="pl-plan">
              <div className="pl-hb">{c('Doktor')}</div>
              {gunler.map((d, i) => {
                const g = iso(d);
                const kap = bloklar.filter(b => gunIso(b) === g).reduce((t, b) => t + kapasite(b), 0);
                return <div key={i} className={`pl-hb${g === bugunIso ? ' bugun' : ''}${i >= 5 ? ' hs' : ''}`}>
                  <span>{c(GUN_AD[i])} {d.getDate()}{g === bugunIso ? ` · ${c('bugün')}` : ''}</span><small>{kap ? kap.toLocaleString('tr-TR') : '—'}</small></div>;
              })}
              <div className="pl-hb orta">{c('Hafta')}</div>
              {satirlar.map((r, ri) => {
                const o = satirOzet(r.bloklar);
                const grupBas = grupla && (ri === 0 || satirlar[ri - 1].departman !== r.departman);
                const grup = grupBas ? satirlar.filter(x => x.departman === r.departman) : [];
                const go = grupBas ? satirOzet(grup.flatMap(x => x.bloklar)) : null;
                return (
                  <Fragment key={r.anahtar}>
                    {grupBas && <div className="pl-grup">{r.departman}<span>{new Set(grup.map(x => x.hekimId)).size} {c('doktor')} · {c('doluluk')} %{go!.yuzde}</span></div>}
                    <label className="pl-hk" title={c('İşaretle: İzin / İstisna bu doktor için açılır')}>
                      <input type="checkbox" checked={isaretli?.hekimId === r.hekimId} onChange={e => isaretleSec(r, e.target.checked)} />
                      <span><b>{r.hekim}</b><small>{r.departman} · {r.sube || c('Tümü')}</small></span></label>
                    {gunler.map((d, i) => <div key={i} className={iso(d) === bugunIso ? 'bugunk' : ''}>{Hucre(r, iso(d))}</div>)}
                    <div className="pl-top"><b>{o.saat} {c('sa')}</b>{o.kap ? `%${o.yuzde}` : '—'}</div>
                  </Fragment>
                );
              })}
              {veri && satirlar.length === 0 && <div className="pl-tam sonuk">{c('Bu haftada blok yok. "＋ Şablon" ile doktor × bölüm çalışma düzeni tanımlayın.')}</div>}
            </div>

            {/* SAĞ: seçili hücre */}
            <div className="pl-sag">
              {seciliSatir && secili ? (
                <div className="ck-grp pl-kutu">
                  <h6>{seciliSatir.hekim} · {c(GUN_AD[(new Date(secili.gun + 'T00:00:00').getDay() + 6) % 7])} {tarihYaz(secili.gun).slice(0, 5)}
                    <span className="ck-ek">{seciliKapali ? (seciliKapali.kaynak === 4 ? c('İK izni') : c('istisna')) : seciliAcik.some(b => b.kaynak === 2) ? c('istisna') : seciliAcik.length ? c('şablon') : ''}</span></h6>
                  <div className="pl-ic">
                    {seciliKapali ? (
                      <div className="pl-sat"><span>{c('Kaynak')}</span><span>{seciliKapali.kaynak === 4
                        ? <>🌴 {c('İK izni')} · {seciliKapali.aciklama || c('izin')} <span className="sonuk">({c('İzinler ekranından yönetilir')})</span></>
                        : <>{ISTISNA[seciliKapali.istisnaTur ?? 5]?.[0]} {c(ISTISNA[seciliKapali.istisnaTur ?? 5]?.[1] ?? '')}{seciliKapali.aciklama ? ` · ${seciliKapali.aciklama}` : ''}</>}</span></div>
                    ) : seciliAcik.length > 0 ? (<>
                      <div className="pl-sat"><span>{c('Kaynak')}</span><span>{seciliAcik.map(b => b.kaynak === 2
                        ? `${ISTISNA[b.istisnaTur ?? 3]?.[0]} ${c(ISTISNA[b.istisnaTur ?? 3]?.[1] ?? '')}`
                        : `📋 ${c('Şablon')} "${b.sablon || ''}"`).filter((x, i, a) => a.indexOf(x) === i).join(' · ')}</span></div>
                      <div className="pl-sat"><span>{c('Saat / slot')}</span><span>{seciliAcik.map(b => `${b.saatBas}–${b.saatBit}`).join(' · ')} · {seciliAcik[0].slotDk} dk</span></div>
                      <div className="pl-sat"><span>{c('Kanal')}</span><span className="cl-kanal">{[['B', 'B'], ['P', 'P'], ['C', 'Ç']].map(([k, a]) => <span key={k} className={seciliAcik[0].kanallar.includes(k) ? 'on' : ''}>{a}</span>)}</span></div>
                      {(() => { const o = satirOzet(seciliAcik); return (
                        <div className="pl-sat"><span>{c('Doluluk')}</span><span className="pl-dol"><span className="b"><i style={{ width: `${o.yuzde}%` }} className={o.yuzde >= 80 ? 'yuk' : ''} /></span>{o.dolu} / {o.kap}</span></div>) })()}
                      <div className="pl-slotlar">{slotlar.map((s, i) => <span key={i} className={s.dolu ? 'dl' : ''}>{s.saat}</span>)}</div>
                    </>) : <div className="sonuk">{c('Bu gün plan yok.')}{yazar ? ` ${c('Çift tık: ek mesai.')}` : ''}</div>}
                    {seciliBekleyen && <div className="uyari-kutusu">⏳ {c('Onay bekleyen')} <b>{c(ISTISNA[seciliBekleyen.tur][1])}</b>
                      {seciliBekleyen.randevu ? ` · ${seciliBekleyen.randevu} ${c('randevu işlem bekliyor')}` : ''}</div>}
                    {gunRandevu && gunRandevu.length > 0 && (
                      <div className="pl-rl">{gunRandevu.slice(0, 4).map(r => <div key={r.id}><b>{r.saat}</b>{r.hasta}{r.tip ? ` · ${r.tip}` : ''}</div>)}
                        {gunRandevu.length > 4 && <div className="sonuk">… {gunRandevu.length - 4} {c('randevu daha')}</div>}</div>
                    )}
                    <div className="pl-eylem">
                      {seciliAcik.find(b => b.sablonId) && <button type="button" className="d ck-kucuk" onClick={() => kartaGit(seciliSatir.hekimId, `/calisma-sablon/${seciliAcik.find(b => b.sablonId)!.sablonId}?geri=%2Fcalisma-plani`)}>📋 {c('Şablonu aç')}</button>}
                      {(seciliBloklar.find(b => b.istisnaId) || seciliBekleyen) && <button type="button" className="d ck-kucuk"
                        onClick={() => kartaGit(seciliSatir.hekimId, `/calisma-istisna/${seciliBloklar.find(b => b.istisnaId)?.istisnaId ?? seciliBekleyen!.id}?geri=%2Fcalisma-plani`)}>✈️ {c('İstisnayı aç')}</button>}
                      {seciliKapali?.kaynak === 4 && <button type="button" className="d ck-kucuk" onClick={() => git('/personel-izin')}>🌴 {c('İzinlere git')}</button>}
                      {yazar && !seciliKapali && <button type="button" className="d ck-kucuk"
                        onClick={() => kartaGit(seciliSatir.hekimId, `/calisma-istisna/yeni?hekimId=${seciliSatir.hekimId}&sabit=1&tarih=${secili.gun}&geri=%2Fcalisma-plani`)}>✈️ {c('Bu güne istisna')}</button>}
                      <button type="button" className="d ck-kucuk" onClick={() => git(`/randevu?hekimId=${seciliSatir.hekimId}`)}>📅 {c('Randevuları')}</button>
                    </div>
                  </div>
                </div>
              ) : <div className="ck-bilgi ck-kutu">ℹ {c('Hücreye tıklayın: kaynak, saat / slot / kanal, doluluk, slotlar ve randevular burada. Çift tık şablon / istisna kartını açar; boş hücreye çift tık = o güne ek mesai.')}</div>}

              {seciliSatir && haftaIstisnalari.length > 0 && (
                <div className="ck-grp pl-kutu">
                  <h6>{c('Bu hafta istisnaları')}<span className="ck-ek">{seciliSatir.hekim}</span></h6>
                  <div className="pl-ic">{haftaIstisnalari.map(x => (
                    <div key={`${x.bekliyor}${x.id}`}>{ISTISNA[x.tur]?.[0]} <b>{c(ISTISNA[x.tur]?.[1] ?? '')}</b>{' '}
                      {tarihYaz(x.gunler[0]).slice(0, 5)}{x.gunler.length > 1 && x.gunler[x.gunler.length - 1] !== x.gunler[0] ? `–${tarihYaz(x.gunler[x.gunler.length - 1]).slice(0, 5)}` : ''}{' '}
                      {x.bekliyor ? <span className="rozet uyari">{c('Onay bekliyor')}</span> : <span className="rozet ok">{c('Onaylı')}</span>}
                      {x.randevu > 0 && <div className="pl-kirmizi">{x.randevu} {c('randevu işlem bekliyor')}</div>}
                      {' '}<button type="button" className="cl-bag" onClick={() => kartaGit(seciliSatir.hekimId, `/calisma-istisna/${x.id}?geri=%2Fcalisma-plani`)}>{c('kartı aç')}</button></div>
                  ))}</div>
                </div>
              )}
            </div>
          </div>
        </>)}

        {gorunum === 'bolum' && (
          <div className="pl-isi-kap">
            <div className="pl-isi">
              <div className="hb">{c('Bölüm')}</div>
              {gunler.map((d, i) => <div key={i} className={`hb${iso(d) === bugunIso ? ' bugun' : ''}`}>{c(GUN_AD[i])} {d.getDate()}</div>)}
              <div className="hb">{c('Hafta')}</div>
              {bolumSatirlari.map(r => {
                let tk = 0, td = 0;
                return (
                  <Fragment key={r.id}>
                    <div className="ad">{r.ad}<small>{r.doktor.size} {c('doktor')}</small></div>
                    {gunler.map((d, i) => {
                      const g = r.gun[iso(d)];
                      if (!g) return <div key={i} className="rs">—</div>;
                      tk += g.kap; td += g.dolu;
                      if (g.dr.size === 0) return <div key={i} className={g.kapali ? 'h0' : 'rs'}>{g.kapali ? <>{c('doktor yok')}<small>{g.kapali} {c('kapalı')}</small></> : '—'}</div>;
                      const y = g.kap ? Math.round((100 * g.dolu) / g.kap) : 0;
                      return <button key={i} type="button" className={`h${Math.min(g.dr.size, 3)}`} title={c('Bu günün doktorları')}
                                     onClick={() => { setDepartmanId(r.id); setGorunum('doktor') }}>
                        {g.dr.size} dr<small>%{y}{g.ek ? ` · ${c('ek mesai')}` : ''}{g.kapali ? ` · ${g.kapali} ${c('kapalı')}` : ''}</small></button>;
                    })}
                    <div><b>{tk ? `%${Math.round((100 * td) / tk)}` : '—'}</b></div>
                  </Fragment>
                );
              })}
              {(veri?.bolumler ?? []).filter(b => b.randevusuz && !bolumSatirlari.some(r => r.id === b.id)).map(b => (
                <Fragment key={`r${b.id}`}>
                  <div className="ad">{b.ad}<small>{c('randevusuz kabul')}</small></div>
                  {gunler.map((_, i) => <div key={i} className="rs">{c('randevusuz')}</div>)}
                  <div>—</div>
                </Fragment>
              ))}
            </div>
            <div className="pl-lej">
              <span><i className="pi-h1" />{c('1 doktor')}</span><span><i className="pi-h2" />{c('2 doktor')}</span><span><i className="pi-h3" />{c('3+ doktor')}</span>
              <span><i className="l-kap" />{c('planlı gün ama doktor yok')}</span>
              <span>{c('hücreye tık = o bölümün doktorları (doktor × gün görünümü süzülür)')}</span>
            </div>
          </div>
        )}

        {gorunum === 'bugun' && (
          <div className="cl-tablo">
            <div className="cl-arac pl-bugun-arac">
              <b>{bugun ? tarihYaz(String(bugun.gun).slice(0, 10)) : ''}{bugun?.simdi ? ` · ${c('saat')} ${bugun.simdi}` : ''}</b>
              <span className="sonuk">· {c('kayıt kabul bu listeyi görür')}</span>
              {([['', 'Tümü', bugunSatirlari.length], ['muayenede', 'Şu an muayenede', bugunSay.muayenede], ['disi', 'Saat dışı', bugunSay.disi], ['yok', 'Bugün yok', bugunSay.yok]] as ['' | 'muayenede' | 'disi' | 'yok', string, number][]).map(([k, a, n]) => (
                <button key={k} type="button" className={`ck-cip${bugunCip === k ? ' on' : ''}`} onClick={() => setBugunCip(k)}>{c(a)} <b>{n}</b></button>
              ))}
              <select className="cl-sag" value={departmanId ?? ''} onChange={e => setDepartmanId(e.target.value ? Number(e.target.value) : null)}>
                <option value="">{c('Bölüm: Tümü')}</option>{veri?.bolumler.map(b => <option key={b.id} value={b.id}>{b.ad}</option>)}</select>
            </div>
            <table className="cl-grid">
              <thead><tr><th>{c('Doktor')}</th><th>{c('Saatler (08–19, kırmızı çizgi = şimdi)')}</th><th>{c('Durum')}</th>
                <th>{c('Randevu')}</th><th>{c('Gelen')}</th><th>{c('Sıradaki boş')}</th><th>{c('Kanal')}</th></tr></thead>
              <tbody>
                {bugunGoster.map((s, i) => (
                  <Fragment key={`${s.hekimId}|${s.departmanId}`}>
                    {(i === 0 || bugunGoster[i - 1].departman !== s.departman) && <tr className="grupbas"><td colSpan={7}>{s.departman}</td></tr>}
                    <tr>
                      <td><b className="pl-ad">{s.hekim}</b></td>
                      <td>{s.durum === 'yok'
                        ? <span className="pl-kirmizi">{s.ik ? '🌴' : ''} {s.neden}</span>
                        : <div className="pl-gs">{s.bloklar.map((b, j) => <i key={j} className={b.istisna ? 'ist' : ''} style={{ left: sol(dk(b.bas)), width: gen(dk(b.bas), dk(b.bit)) }} />)}
                          {bugun?.simdi && <b style={{ left: sol(dk(bugun.simdi)) }} />}</div>}</td>
                      <td>{s.durum === 'muayenede' ? <span className="rozet ok">{c('muayenede')}</span>
                        : s.durum === 'yok' ? <span className="rozet uyari">{c('bugün yok')}</span>
                        : s.durum === 'bitti' ? <span className="rozet gri">{c('mesai bitti')}</span>
                        : <span className="rozet gri">{c('saat dışı')}</span>}</td>
                      <td>{s.durum === 'yok' ? (s.randevu ? <span className="pl-kirmizi">{s.randevu} · {c('aktarılmalı')}</span> : '—') : `${s.randevu} / ${s.slot}`}</td>
                      <td>{s.durum === 'yok' ? '—' : s.gelen}</td>
                      <td>{s.durum === 'yok' ? '—' : s.siradakiBos ? <span className="rozet mavi">{s.siradakiBos}</span> : <span className="rozet hata">{c('dolu')}</span>}</td>
                      <td>{s.durum === 'yok' ? '—' : <span className="cl-kanal">{[['B', 'B'], ['P', 'P'], ['C', 'Ç']].map(([k, a]) => <span key={k} className={s.kanallar.includes(k) ? 'on' : ''}>{a}</span>)}</span>}</td>
                    </tr>
                  </Fragment>
                ))}
                {(bugun?.randevusuz ?? []).length > 0 && !bugunCip && (<>
                  <tr className="grupbas"><td colSpan={7}>{(bugun?.randevusuz ?? []).map(d => d.ad).join(' · ')}</td></tr>
                  <tr><td colSpan={2} className="sonuk"><i>{c('randevusuz kabul — plan gerektirmez, kayıt kabulde hep görünür')}</i></td>
                    <td><span className="rozet mavi">{c('randevusuz')}</span></td><td>—</td><td>—</td><td>—</td><td>—</td></tr>
                </>)}
                {bugun && bugunGoster.length === 0 && <tr><td colSpan={7} className="sonuk">{c('Bugün planlı doktor yok.')}</td></tr>}
              </tbody>
            </table>
          </div>
        )}
      </div>
    </>
  );
}
