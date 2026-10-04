import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { devamDurumu, personelTalepDurumu } from '../../bilesenler/taleplerim/personelTalebi';
import { api } from '../../api/istemci';
import { hataMetni, type DokumanSatiri } from '../../api/sozlesme';
import type { IzinBakiyesi } from '../../api/uclar/izin';
import { Modal } from '../../bilesenler/Modal';
import { TarafArama } from '../../bilesenler/TarafArama';
import { SaatSec, dk } from '../../bilesenler/calisma/calismaOrtak';
import { guvenli, metinSor, onay } from '../../bilesenler/mesaj';
import { tarihSaat } from '../../bilesenler/bicim';
import { useOturum } from '../../kimlik/OturumBaglami';
import { useTaleplerim } from '../../bilesenler/taleplerim/taleplerimBaglami';
import { talepleriYenile, gunYaz } from '../../bilesenler/taleplerim/useTaleplerimOzeti';
import { c } from '../../dil/ceviri';

/**
 * İZİN TALEP KARTI `/personel-izin/:id` (959, mockup Ekranlar/IK/izin_talep_karti.html).
 *
 * Sol: tür, süre (gün boyu / saatli), tarih, gün sayımı, vekil, izinde ulaşım
 * ve adres, belge no, açıklama + gün sayısı ve işe dönüş, ay takvimi, ekipte
 * aynı günler. Sağ: bakiye, randevu etkisi, onay zinciri, belgeler, akış.
 * Taslakken alanlar açık; onaya gidince kilitli (belge eklenir).
 * Kayıt: yeni talep /api/ik/izin (gün sunucuda), düzenleme generic kart.
 */
const KAYNAK = 'personelIzin';
const IZIN_TUR = 904;
const TURLER: { kod: number; ic: string; ad: string; ne: string }[] = [
  { kod: 1, ic: '🌴', ad: 'Yıllık', ne: 'bakiyeden düşer' },
  { kod: 2, ic: '⏱', ad: 'Mazeret', ne: 'yarım gün olabilir' },
  { kod: 3, ic: '🩺', ad: 'Rapor', ne: 'belge no zorunlu' },
  { kod: 4, ic: '💸', ad: 'Ücretsiz', ne: 'bordrodan kesilir' },
  { kod: 9, ic: '⋯', ad: 'Diğer', ne: 'evlilik, ölüm, doğum' },
];
const DURUM: Record<number, [string, string]> = {
  0: ['Taslak', 'tl-c-gri'], 1: ['Onayda', 'tl-c-bek'], 2: ['Onaylı', 'tl-c-ok'], 3: ['Reddedildi', 'tl-c-red'], 4: ['İptal', 'tl-c-gri'],
};
const GUN_KISA = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

interface Deger {
  tarafId: number; tur: number; bas: string; bit: string; saatBas: string; saatBit: string;
  isGunu: boolean; yerineId: number | null; belgeNo: string; aciklama: string; izinAdres: string; izinTel: string;
}
const bos = (tarafId = 0): Deger => ({
  tarafId, tur: 1, bas: '', bit: '', saatBas: '', saatBit: '', isGunu: true, yerineId: null,
  belgeNo: '', aciklama: '', izinAdres: '', izinTel: '',
});
const s10 = (v: unknown) => String(v ?? '').slice(0, 10);

interface Baglam {
  personel: { ad: string; gorev: string; bolum: string | null } | null;
  bakiye: IzinBakiyesi;
  sure: { gun: number; donus: string; saatli: boolean } | null;
  tatiller: { tarih: string; ad: string; yarim: number }[];
  ekip: { gunler: string[]; enAz: number; toplam: number; kalan: number[];
          kisiler: { id: number; ad: string; durumlar: (string | null)[] }[] } | null;
  randevu: number;
  akis: { tur: string; zaman: string | null; kim: string; metin: string }[];
}

/** Kimlik değişince (yeni ↔ kayıt, Kopyala) kart baştan kurulur - durum sızmasın. */
export function IzinTalepKarti() {
  const { id } = useParams();
  return <IzinTalepKartiIc key={id ?? ''} param={id} />;
}

function IzinTalepKartiIc({ param }: { param: string | undefined }) {
  const git = useNavigate();
  const konum = useLocation();
  const { yetki } = useOturum();
  const oz = useTaleplerim();
  const yeni = param === 'yeni';
  const [kayitId, setKayitId] = useState<number | null>(yeni ? null : Number(param));
  // PERSONEL LİSTESİNDEN (Yeni Talep ▾): seçili personel dolu gelir, Kapat listeye döner.
  const pt = personelTalepDurumu(konum.state);
  const [d, setD] = useState<Deger>(() => ({ ...bos(), ...(pt.personel ? { tarafId: pt.personel.id } : {}),
    ...((konum.state as { kopya?: Partial<Deger> } | null)?.kopya ?? {}) }));
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [ro, setRo] = useState<{ izinNo: string; durum: number; talepTarihi: string; redNeden: string; iptalNeden: string; gun: number }>(
    { izinNo: '', durum: 0, talepTarihi: '', redNeden: '', iptalNeden: '', gun: 0 });
  const [surum, setSurum] = useState<string | undefined>();
  const [kodlar, setKodlar] = useState<Record<string, Record<string, string>>>({});
  const [b, setB] = useState<Baglam | null>(null);
  const [zincir, setZincir] = useState<{ id: number; sira: number; ad: string; durum: number; kararZamani: string | null; gerekce: string; termin: string | null }[]>([]);
  const [ekler, setEkler] = useState<DokumanSatiri[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const dosyaRef = useRef<HTMLInputElement>(null);
  /** JENERİK ARAMA (kullanıcı: "personel seçimi jenerik aramadan gelsin"): personel / vekil. */
  const [arama, setArama] = useState<'tarafId' | 'yerineId' | null>(null);
  const [secilenAd, setSecilenAd] = useState<Record<string, string>>(pt.personel ? { tarafId: pt.personel.ad } : {});

  const kapat = useCallback(() => git(pt.geri ?? '/personel-izin'), [git, pt.geri]);
  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));
  const kilitli = ro.durum !== 0;
  const yazar = yetki('ik.izin', kayitId ? 'degistir' : 'ekle');

  const oku = useCallback(async (kid: number) => {
    const y = await api.kartOku(KAYNAK, kid);
    const k = y.kart as Record<string, unknown>;
    const v: Deger = {
      tarafId: Number(k.tarafId ?? 0), tur: Number(k.tur ?? 1), bas: s10(k.baslangicTarihi), bit: s10(k.bitisTarihi),
      saatBas: String(k.saatBas ?? ''), saatBit: String(k.saatBit ?? ''), isGunu: Number(k.isGunu ?? 0) === 1 || k.isGunu === true,
      yerineId: k.yerineId ? Number(k.yerineId) : null, belgeNo: String(k.belgeNo ?? ''), aciklama: String(k.aciklama ?? ''),
      izinAdres: String(k.izinAdres ?? ''), izinTel: String(k.izinTel ?? ''),
    };
    setD(v); setIlk(v); setSurum(k.surum as string | undefined);
    setRo({ izinNo: String(k.izinNo ?? ''), durum: Number(k.durum ?? 0), talepTarihi: s10(k.talepTarihi),
            redNeden: String(k.redNeden ?? ''), iptalNeden: String(k.iptalNeden ?? ''), gun: Number(k.gun ?? 0) });
    api.onayZinciri(IZIN_TUR, kid).then(z => setZincir(z.adimlar)).catch(() => setZincir([]));
    api.dokumanlar(KAYNAK, kid).then(setEkler).catch(() => setEkler([]));
  }, []);

  useEffect(() => {
    api.kartAlanlari(KAYNAK).then(m => setKodlar(Object.fromEntries(m.alanlar.map(a => [a.ad, a.kodlar ?? {}])))).catch(() => {});
    if (kayitId) oku(kayitId).catch(e => setHata(hataMetni(e)));
  }, [kayitId, oku]);

  // BAĞLAM: personel / tarih / saat değişince (kayıt gerekmez).
  const anahtar = JSON.stringify([d.tarafId, d.bas, d.bit, d.isGunu, d.saatBas, d.saatBit, kayitId, ro.durum]);
  useEffect(() => {
    if (!(d.tarafId > 0)) { setB(null); return }
    const z = setTimeout(() => {
      const p = new URLSearchParams({ tarafId: String(d.tarafId) });
      if (d.bas) p.set('bas', d.bas);
      if (d.bit || d.bas) p.set('bit', d.bit || d.bas);
      p.set('isGunu', String(d.isGunu));
      if (d.saatBas && d.saatBit) { p.set('saatBas', d.saatBas); p.set('saatBit', d.saatBit) }
      if (kayitId) p.set('izinId', String(kayitId));
      api.izinBaglam(p).then(setB).catch(e => setHata(hataMetni(e)));
    }, 300);
    return () => clearTimeout(z);
  }, [anahtar]);   // eslint-disable-line react-hooks/exhaustive-deps

  const saatli = !!(d.saatBas || d.saatBit);
  const setSaatli = (on: boolean) => setD(o => on ? { ...o, bit: o.bas, saatBas: o.saatBas || '09:00', saatBit: o.saatBit || '13:00' } : { ...o, saatBas: '', saatBit: '' });

  const dogrula = (): string | null => {
    if (!(d.tarafId > 0)) return c('Personel seçilmeli.');
    if (!d.bas || !d.bit) return c('Tarih aralığı girilmeli.');
    if (d.bit < d.bas) return c('Bitiş başlangıçtan önce olamaz.');
    if (saatli && d.bas !== d.bit) return c('Saatli izin tek günlüktür.');
    if (saatli && (!d.saatBas || !d.saatBit || dk(d.saatBit) <= dk(d.saatBas))) return c('İki saati de girin; bitiş başlangıçtan sonra olmalı.');
    if (d.tur === 3 && !d.belgeNo.trim()) return c('Raporda belge no zorunlu.');
    return null;
  };

  /** Kaydet; yeni ise kimliği döner. */
  const kaydet = async (): Promise<number | null> => {
    const h = dogrula();
    if (h) { setHata(h); return null }
    setHata(null);
    if (!kayitId) {
      const y = await api.izinAc({
        tarafId: d.tarafId, tur: d.tur, baslangic: d.bas, bitis: d.bit, isGunu: d.isGunu,
        aciklama: d.aciklama || undefined, belgeNo: d.belgeNo || undefined, yerineId: d.yerineId ?? undefined,
        saatBas: saatli ? d.saatBas : undefined, saatBit: saatli ? d.saatBit : undefined,
        izinAdres: d.izinAdres || undefined, izinTel: d.izinTel || undefined,
      });
      setKayitId(y.id);
      git(`/personel-izin/${y.id}`, { replace: true, ...devamDurumu(pt) });
      return y.id;
    }
    const alan: Record<string, unknown> = {
      tarafId: d.tarafId, tur: d.tur, baslangicTarihi: d.bas, bitisTarihi: d.bit, saatBas: d.saatBas || null,
      saatBit: d.saatBit || null, isGunu: d.isGunu ? 1 : 0, yerineId: d.yerineId, belgeNo: d.belgeNo,
      aciklama: d.aciklama, izinAdres: d.izinAdres, izinTel: d.izinTel,
    };
    const eski: Record<string, unknown> = ilk ? {
      tarafId: ilk.tarafId, tur: ilk.tur, baslangicTarihi: ilk.bas, bitisTarihi: ilk.bit, saatBas: ilk.saatBas || null,
      saatBit: ilk.saatBit || null, isGunu: ilk.isGunu ? 1 : 0, yerineId: ilk.yerineId, belgeNo: ilk.belgeNo,
      aciklama: ilk.aciklama, izinAdres: ilk.izinAdres, izinTel: ilk.izinTel,
    } : {};
    const fark = Object.fromEntries(Object.entries(alan).filter(([k, v]) => v !== eski[k]));
    if (Object.keys(fark).length) await api.kartGuncelle(KAYNAK, kayitId, { surum, kart: fark });
    await oku(kayitId);
    return kayitId;
  };

  const calis = (is: () => Promise<unknown>) => async () => {
    setMesgul(true);
    try { await is(); talepleriYenile() } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };

  const gonder = calis(async () => {
    const kid = await kaydet();
    if (!kid) return;
    await api.izinGonder(kid);
    await oku(kid);
  });
  const iptalEt = calis(async () => {
    if (!kayitId) return;
    const g = await metinSor(c('İptal nedeni'), '', c('Neden'));
    if (!g) return;
    await api.izinIptal(kayitId, g);
    await oku(kayitId);
  });
  const karar = (k: 'onayla' | 'reddet' | 'bilgi-iste') => calis(async () => {
    if (!kayitId) return;
    const gerekce = k === 'onayla' ? undefined : await metinSor(k === 'reddet' ? c('Red gerekçesi') : c('Ne bilgisi isteniyor?'), '', c('Gerekçe'));
    if (k !== 'onayla' && !gerekce) return;
    await api.onayKarar(IZIN_TUR, kayitId, { karar: k, gerekce: gerekce ?? undefined });
    await oku(kayitId);
  });
  const hatirlat = calis(async () => { if (kayitId) await api.izinHatirlat(kayitId) });
  const kopyala = () => git('/personel-izin/yeni', {
    state: { kopya: { ...d, bas: '', bit: '', saatBas: '', saatBit: '' } },
  });

  const benimSiram = !!oz?.veri?.onaylar?.some(o => o.kaynakTur === IZIN_TUR && o.kaynakId === kayitId);
  const personelAd = b?.personel?.ad || secilenAd.tarafId || kodlar.tarafId?.[String(d.tarafId)] || '';
  const vekilAd = d.yerineId ? (secilenAd.yerineId ?? kodlar.yerineId?.[String(d.yerineId)] ?? '') : '';
  const turAd = TURLER.find(t => t.kod === d.tur)?.ad ?? '';

  const yazdir = () => {
    const w = window.open('', '_blank');
    if (!w) return;
    const satir = (k: string, v: string) => `<tr><th>${k}</th><td>${(v || '—').replace(/</g, '&lt;')}</td></tr>`;
    w.document.write(`<!doctype html><meta charset="utf-8"><title>İzin Formu ${ro.izinNo}</title>
      <style>body{font:13px Arial;margin:32px}h2{margin:0 0 16px}table{border-collapse:collapse;width:100%}
      th,td{border:1px solid #999;padding:6px 8px;text-align:left}th{width:30%;background:#f2f2f2}
      .imza{display:flex;gap:24px;margin-top:40px}.imza div{flex:1;border-top:1px solid #333;padding-top:6px;text-align:center}</style>
      <h2>İZİN FORMU</h2><table>
      ${satir('İzin no', ro.izinNo)}${satir('Personel', personelAd)}${satir('Bölüm / görev', [b?.personel?.bolum, b?.personel?.gorev].filter(Boolean).join(' · '))}
      ${satir('İzin türü', turAd)}${satir('Tarih', `${d.bas.split('-').reverse().join('.')} – ${d.bit.split('-').reverse().join('.')}${saatli ? ` (${d.saatBas}–${d.saatBit})` : ''}`)}
      ${satir('Süre', `${gunYaz(b?.sure?.gun ?? ro.gun)} gün`)}${satir('İşe dönüş', b?.sure ? b.sure.donus.split('-').reverse().join('.') : '')}
      ${satir('Vekil', vekilAd)}${satir('İzin adresi / ulaşım', [d.izinAdres, d.izinTel].filter(Boolean).join(' · '))}
      ${satir('Açıklama', d.aciklama)}</table>
      <div class="imza"><div>Personel</div><div>Birim âmiri</div><div>İnsan Kaynakları</div></div>
      <script>setTimeout(()=>print(),300)</script>`);
    w.document.close();
  };

  // TAKVİM: başlangıç (yoksa bugün) ayı.
  const takvim = useMemo(() => {
    const ref = d.bas ? new Date(d.bas + 'T00:00:00') : new Date();
    const ilkGun = new Date(ref.getFullYear(), ref.getMonth(), 1);
    const kaydir = (ilkGun.getDay() + 6) % 7;
    const sonGun = new Date(ref.getFullYear(), ref.getMonth() + 1, 0).getDate();
    const tatil = new Map((b?.tatiller ?? []).map(t => [s10(t.tarih), t]));
    const hucreler: { n: number | null; iso: string; sinif: string; not: string }[] = [];
    for (let i = 0; i < kaydir; i++) hucreler.push({ n: null, iso: '', sinif: 'it-bos', not: '' });
    for (let g = 1; g <= sonGun; g++) {
      const t = new Date(ref.getFullYear(), ref.getMonth(), g);
      const iso = `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, '0')}-${String(g).padStart(2, '0')}`;
      const hs = t.getDay() === 0 || t.getDay() === 6;
      const ttl = tatil.get(iso);
      const icinde = d.bas && iso >= d.bas && iso <= (d.bit || d.bas);
      const donus = b?.sure && s10(b.sure.donus) === iso;
      hucreler.push({
        n: g, iso,
        sinif: icinde ? (saatli ? 'it-yarim' : 'it-izin') : ttl ? 'it-tatil' : hs ? 'it-hs' : '',
        not: icinde ? (saatli ? `${d.saatBas}–${d.saatBit}` : c('izin')) : ttl ? `${ttl.ad}${ttl.yarim ? ' ½' : ''}` : donus ? c('dönüş') : '',
      });
    }
    return { ad: ref.toLocaleDateString('tr-TR', { month: 'long', year: 'numeric' }), hucreler };
  }, [d.bas, d.bit, saatli, d.saatBas, d.saatBit, b]);

  const kalanUyari = b?.ekip && b.ekip.enAz > 0
    ? b.ekip.gunler.filter((_, i) => b.ekip!.kalan[i] < b.ekip!.enAz) : [];
  const bk = b?.bakiye;
  const hak = bk ? (bk.hakGun ?? 0) + bk.devirGun + bk.ekGun : 0;
  const buTalep = d.tur === 1 ? (b?.sure?.gun ?? 0) : 0;
  // KAYITLI TALEP BAKİYEDE ZATEN SAYILI (taslak ve onayda "onayda", onaylı "kullanılan /
  //   planlanan"): eski günü geri ekle, ekrandaki güncel günü düş - iki kez düşülmesin.
  const sayili = kayitId && ro.durum <= 2 && ilk?.tur === 1 ? ro.gun : 0;
  const kalanBakiye = bk ? bk.kalan + sayili - buTalep : 0;
  const yuzde = (n: number) => `${hak > 0 ? Math.max(0, Math.min(100, (n / hak) * 100)) : 0}%`;

  const alt = (
    <>
      {yazar && !kilitli && <button type="button" className="d bir" disabled={mesgul} onClick={() => void calis(async () => { await kaydet() })()}>💾 {c('Kaydet')}</button>}
      {yazar && !kilitli && <button type="button" className="d" disabled={mesgul} onClick={() => void gonder()}>📨 {c('Onaya gönder')}</button>}
      {kayitId && <button type="button" className="d" onClick={yazdir}>🖨 {c('İzin formu')}</button>}
      {kayitId && yazar && <button type="button" className="d" onClick={kopyala}>⧉ {c('Kopyala')}</button>}
      {kayitId && yazar && ro.durum <= 2 && <button type="button" className="d tl-tehlike" disabled={mesgul} onClick={() => void iptalEt()}>✖ {c('İptal et')}</button>}
      <span className="ck-bosluk" />
      <button type="button" className="d" onClick={kapat}>{c('Kapat')}</button>
    </>
  );

  return (
    <Modal baslik={`✈️ ${c('İzin Talebi')}${ro.izinNo ? ` — ${ro.izinNo}` : ''}${personelAd ? ` · ${personelAd}` : ''}`}
           ekSinif="kart-calisma" buyutmeYok alt={alt} onKapat={kapat}>
      <div className="ck-kimlik it-kimlik">
        <label className="rk-fld"><span className="ck-etiket">{c('Personel')} <b className="ak-zor">*</b></span>
          <span className="ikili" style={{ display: 'flex', gap: 4, width: '100%' }}>
            <input readOnly className="ck-buyuk" style={{ flex: 1 }} value={secilenAd.tarafId ?? (d.tarafId ? kodlar.tarafId?.[String(d.tarafId)] ?? '' : '')}
                   placeholder={`— ${c('seçiniz')} —`} disabled={!!kayitId} onClick={() => !kayitId && setArama('tarafId')} />
            <button type="button" className="d mini" title={c('Ara')} disabled={!!kayitId} onClick={() => setArama('tarafId')}>…</button>
          </span>
          {b?.personel && <span className="sonuk tl-kucuk">{[b.personel.bolum, b.personel.gorev].filter(Boolean).join(' · ')}</span>}</label>
        <div className="rk-fld"><span className="ck-etiket">{c('İzin no')}</span><input value={ro.izinNo} disabled /></div>
        <div className="rk-fld"><span className="ck-etiket">{c('Talep tarihi')}</span><input value={ro.talepTarihi ? ro.talepTarihi.split('-').reverse().join('.') : ''} disabled /></div>
        <div className="rk-fld"><span className="ck-etiket">{c('Durum')}</span>
          <div className="ck-durum"><span className={`tl-chip ${DURUM[ro.durum][1]}`}>{c(DURUM[ro.durum][0])}
            {ro.durum === 1 && zincir.find(a => a.durum === 0) ? ` · ${zincir.find(a => a.durum === 0)!.ad}` : ''}</span></div></div>
      </div>
      {hata && <div className="hata-kutusu" style={{ margin: '8px 12px 0' }}>{hata}</div>}
      {(ro.redNeden || ro.iptalNeden) && <div className="tl-uyari" style={{ margin: '8px 12px 0' }}>{ro.redNeden ? `${c('Red nedeni')}: ${ro.redNeden}` : `${c('İptal nedeni')}: ${ro.iptalNeden}`}</div>}

      <div className="ck-govde">
        <div className="ck-sol">
          <div className="ck-grp">
            <h6>{c('İzin')}{kilitli && <span className="ck-ek">🔒 {c('onaya gitti - alanlar kilitli')}</span>}</h6>
            <div className="ck-iz">
              <div className="ck-tam it-turler">
                {TURLER.map(t => (
                  <button key={t.kod} type="button" disabled={kilitli} className={d.tur === t.kod ? 'it-on' : ''} onClick={() => yaz('tur', t.kod)}>
                    <b>{t.ic} {c(t.ad)}</b><span>{c(t.ne)}</span></button>
                ))}
              </div>
              <div className="rk-fld"><span className="ck-etiket">{c('Süre')}</span>
                <div className="ck-cipler">
                  <button type="button" disabled={kilitli} className={`ck-cip${!saatli ? ' on' : ''}`} onClick={() => setSaatli(false)}>{c('Gün boyu')}</button>
                  <button type="button" disabled={kilitli} className={`ck-cip${saatli ? ' on' : ''}`} onClick={() => setSaatli(true)}>{c('Saatli (yarım gün)')}</button>
                </div>
                <span className="sonuk tl-kucuk">{c('saatli: tek gün, ≤ 4,5 saat 0,5 gün')}</span></div>
              <div className="rk-fld"><span className="ck-etiket">{c('Tarih aralığı')} <b className="ak-zor">*</b></span>
                <div className="ck-ikili">
                  <input type="date" value={d.bas} disabled={kilitli} onChange={e => setD(o => ({ ...o, bas: e.target.value, bit: saatli || !o.bit || o.bit < e.target.value ? e.target.value : o.bit }))} />
                  <span className="sonuk">–</span>
                  <input type="date" value={d.bit} min={d.bas} disabled={kilitli || saatli} onChange={e => yaz('bit', e.target.value)} />
                </div></div>
              <div className="rk-fld"><span className="ck-etiket">{c('Saat')}</span>
                <div className="ck-ikili">
                  <SaatSec deger={d.saatBas} disabled={kilitli || !saatli} bos={c('gün boyu')} onChange={v => yaz('saatBas', v)} />
                  <span className="sonuk">–</span>
                  <SaatSec deger={d.saatBit} disabled={kilitli || !saatli} sonra={d.saatBas} bos={c('gün boyu')} onChange={v => yaz('saatBit', v)} />
                </div></div>
              <div className="rk-fld"><span className="ck-etiket">{c('Gün sayımı')}</span>
                <div className="ck-cipler">
                  <button type="button" disabled={kilitli} className={`ck-cip${d.isGunu ? ' on' : ''}`} onClick={() => yaz('isGunu', true)}>{c('İş günü')}</button>
                  <button type="button" disabled={kilitli} className={`ck-cip${!d.isGunu ? ' on' : ''}`} onClick={() => yaz('isGunu', false)}>{c('Takvim günü')}</button>
                </div></div>
              <label className="rk-fld"><span className="ck-etiket">{c('Yerine bakan (vekil)')}</span>
                <span className="ikili" style={{ display: 'flex', gap: 4, width: '100%' }}>
                  <input readOnly style={{ flex: 1 }} value={secilenAd.yerineId ?? (vekilAd || '')} placeholder={`— ${c('seçiniz')} —`}
                         disabled={kilitli} onClick={() => !kilitli && setArama('yerineId')} />
                  <button type="button" className="d mini" title={c('Ara')} disabled={kilitli} onClick={() => setArama('yerineId')}>…</button>
                  {d.yerineId && !kilitli ? <button type="button" className="d mini" title={c('Temizle')} onClick={() => yaz('yerineId', null)}>×</button> : null}
                </span></label>
              <label className="rk-fld"><span className="ck-etiket">{c('İzinde ulaşım')}</span>
                <input value={d.izinTel} maxLength={40} disabled={kilitli} onChange={e => yaz('izinTel', e.target.value)} /></label>
              <label className="rk-fld"><span className="ck-etiket">{c('İzin adresi')}</span>
                <input value={d.izinAdres} maxLength={200} disabled={kilitli} onChange={e => yaz('izinAdres', e.target.value)} /></label>
              <label className="rk-fld"><span className="ck-etiket">{c('Rapor / belge no')}{d.tur === 3 && <> <b className="ak-zor">*</b></>}</span>
                <input value={d.belgeNo} maxLength={60} disabled={kilitli} placeholder={d.tur === 3 ? '' : c('— (yalnız rapor)')} onChange={e => yaz('belgeNo', e.target.value)} /></label>
              <label className="rk-fld ck-tam"><span className="ck-etiket">{c('Açıklama')}</span>
                <input value={d.aciklama} maxLength={500} disabled={kilitli} onChange={e => yaz('aciklama', e.target.value)} /></label>
            </div>
            {b?.sure && (
              <div className="it-ozet">📅 <span><b>{gunYaz(b.sure.gun)} {d.isGunu && !b.sure.saatli ? c('iş günü') : c('gün')}</b>
                {' · '}{d.bas.split('-').reverse().join('.').slice(0, 5)}{d.bit !== d.bas ? `–${d.bit.split('-').reverse().join('.').slice(0, 5)}` : ''}
                {d.isGunu && !b.sure.saatli ? ` (${c('hafta sonu ve resmî tatil sayılmaz')})` : ''}</span>
                <span className="it-donus">{c('işe dönüş')}: <b>{new Date(b.sure.donus + 'T00:00:00').toLocaleDateString('tr-TR', { day: '2-digit', month: '2-digit', year: 'numeric', weekday: 'short' })}</b></span></div>
            )}
          </div>

          <div className="ck-grp">
            <h6>{c('Takvim')}<span className="ck-ek">{takvim.ad} · {c('taralı = izin · sarı = resmî tatil')}</span></h6>
            <div className="it-takvim">
              {GUN_KISA.map(g => <div key={g} className="it-gb">{c(g)}</div>)}
              {takvim.hucreler.map((h, i) => (
                <div key={i} className={`it-gun ${h.sinif}`}>{h.n && <span className="it-n">{h.n}</span>}{h.not && <small>{h.not}</small>}</div>
              ))}
            </div>
          </div>

          {b?.ekip && b.ekip.kisiler.length > 0 && (
            <div className="ck-grp">
              <h6>{c('Ekipte aynı günler')}<span className="ck-ek">{b.personel?.bolum} · {b.ekip.toplam} {c('kişi')}{b.ekip.enAz > 0 ? ` · ${c('en az')} ${b.ekip.enAz}` : ''}</span></h6>
              <div style={{ padding: '10px 12px', overflowX: 'auto' }}>
                <table className="it-ekip">
                  <thead><tr><th>{c('Kişi')}</th>{b.ekip.gunler.map(g => <th key={g}>{new Date(g + 'T00:00:00').toLocaleDateString('tr-TR', { weekday: 'short', day: 'numeric' })}</th>)}</tr></thead>
                  <tbody>
                    <tr><td className="it-ad"><b>{personelAd}</b></td>{b.ekip.gunler.map(g => <td key={g} className="it-ben">{c('izin')}</td>)}</tr>
                    {b.ekip.kisiler.map(k => (
                      <tr key={k.id}><td className="it-ad">{k.ad}{k.id === d.yerineId ? ` (${c('vekil')})` : ''}</td>
                        {k.durumlar.map((x, i) => <td key={i} className={x ? (x === 'izin' ? 'it-cak' : 'it-ist') : ''}>{x ? c(x) : ''}</td>)}</tr>
                    ))}
                    <tr><td className="it-ad sonuk">{c('kalan')}</td>
                      {b.ekip.kalan.map((n, i) => <td key={i} className={b.ekip!.enAz > 0 && n < b.ekip!.enAz ? 'it-cak' : 'sonuk'}>{n}</td>)}</tr>
                  </tbody>
                </table>
              </div>
              {kalanUyari.length > 0 && (
                <div className="tl-uyari" style={{ margin: '0 12px 12px' }}>⚠ <b>{kalanUyari.map(g => g.split('-').reverse().join('.').slice(0, 5)).join(', ')}</b>
                  {' '}{c('günlerinde bölümde')} {b.ekip.enAz} {c('kişiden az kalıyor. Engel değil; onaycı bu uyarıyı görür.')}</div>
              )}
            </div>
          )}
        </div>

        <div className="ck-sag">
          {bk && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Bakiye')}<span className="ck-ek">{bk.yil} · {c('yıllık izin')}</span></h6>
              <div className="it-bakiye">
                <div>{c('Hak + devir')}<b>{gunYaz(hak)}</b></div>
                <div>{c('Kullanılan')}<b>{gunYaz(bk.kullanilanGun + bk.planlananGun)}</b></div>
                <div>{c('Bu talep')}<b>{gunYaz(buTalep)}</b></div>
                <div className={kalanBakiye < 0 ? 'it-eksi' : 'it-son'}>{c('Kalan')}<b>{gunYaz(kalanBakiye)}</b></div>
              </div>
              <div className="tl-bakiye" style={{ margin: '0 12px 6px' }}>
                <i style={{ width: yuzde(bk.kullanilanGun + bk.planlananGun), background: '#9cc1ea' }} />
                <i style={{ width: yuzde(buTalep + bk.onaydaGun), background: '#e0a33a' }} /></div>
              {kalanBakiye < 0 && <div className="tl-uyari" style={{ margin: '0 12px 10px' }}>⚠ {c('Bakiye yetersiz - kayıt engellenmez; onay zincirine İK (bakiye aşımı) basamağı eklenir.')}</div>}
              {bk.hakGun == null && <div className="tl-uyari" style={{ margin: '0 12px 10px' }}>⚠ {c('İşe giriş tarihi yok - yıllık hak hesaplanamıyor.')}</div>}
            </div>
          )}

          {(b?.randevu ?? 0) > 0 && (
            <div className="tl-uyari" style={{ margin: '12px 12px 0' }}>⚠ {c('Bu aralıkta')} <b>{b!.randevu} {c('randevu')}</b> {c('var. Onaylanınca çalışma planı kapanır; randevular kendiliğinden taşınmaz.')}
              {' '}<button type="button" className="cl-bag" onClick={() => git('/calisma-istisna')}>{c('Çalışma İstisnaları')} ↗</button></div>
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

          {kayitId && (b?.akis.length ?? 0) > 0 && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Akış')}<span className="ck-ek">{c('en yeni altta')}</span></h6>
              <div className="it-akis">
                {b!.akis.map((a, i) => (
                  <div key={i} className={a.tur === 'red' || a.tur === 'iptal' ? 'tl-gec' : ''}>
                    {a.tur === 'olustu' ? c('Talep oluşturuldu') : a.tur === 'gonderildi' ? `${c('Onaya gönderildi')}${a.metin ? `: ${a.metin}` : ''}`
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
          secimDenetimi={sec => arama === 'yerineId' && sec.id === d.tarafId ? c('Personel kendi vekili olamaz.') : null}
          onKapat={() => setArama(null)}
          onSec={sec => {
            setD(o => ({ ...o, [arama]: sec.id }));
            setSecilenAd(o => ({ ...o, [arama]: sec.unvan }));
            setArama(null);
          }} />
      )}
    </Modal>
  );
}
