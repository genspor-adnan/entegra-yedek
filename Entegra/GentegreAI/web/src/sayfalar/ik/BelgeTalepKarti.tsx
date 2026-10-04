import { useCallback, useEffect, useRef, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { devamDurumu, personelTalepDurumu } from '../../bilesenler/taleplerim/personelTalebi';
import { api } from '../../api/istemci';
import { TABAN } from '../../api/cekirdek';
import { hataMetni, type DokumanSatiri } from '../../api/sozlesme';
import type { BelgeYazisi } from '../../api/uclar/izin';
import { Modal } from '../../bilesenler/Modal';
import { TarafArama } from '../../bilesenler/TarafArama';
import { guvenli, metinSor, onay, mesaj } from '../../bilesenler/mesaj';
import { tarihSaat, tutarOku, bugunIso } from '../../bilesenler/bicim';
import { code128Desen } from '../../bilesenler/barkod128';
import { useOturum } from '../../kimlik/OturumBaglami';
import { talepleriYenile } from '../../bilesenler/taleplerim/useTaleplerimOzeti';
import { c } from '../../dil/ceviri';

/**
 * BELGE TALEP KARTI `/personel-belge-talep/:id` (962, mockup Ekranlar/IK/belge_talep_karti.html).
 *
 * Sol: tür, amaç, muhatap, nüsha, teslim şekli (e-posta / kargo adresi),
 * istenen tarih, açıklama, maaş (yalnız maaş yazısı) + A4 YAZI ÖNİZLEME
 * (şablon seçimi, eksik yer tutucu kırmızı, metni düzenle = dondur, doğrulama
 * barkodu). Sağ: süreç adımları, hazırlık / teslim, istenen tarih uyarısı,
 * önceki talepler, belgeler, akış. Talep açılışta sürece girer (taslak yok).
 */
const KAYNAK = 'personelBelgeTalep';
const TURLER: { kod: number; ic: string; ad: string; ne: string }[] = [
  { kod: 1, ic: '🧾', ad: 'Çalışma belgesi', ne: 'görev, giriş tarihi' },
  { kod: 2, ic: '💰', ad: 'Maaş yazısı', ne: 'net / brüt tutar' },
  { kod: 3, ic: '✈️', ad: 'Vize yazısı', ne: 'izin + ülke + dönüş' },
  { kod: 4, ic: '🏛', ad: 'SGK hizmet dökümü', ne: "e-Devlet'ten" },
  { kod: 9, ic: '⋯', ad: 'Diğer', ne: 'serbest yazı' },
];
const DURUM: Record<number, [string, string]> = {
  0: ['Taslak', 'tl-c-gri'], 1: ['Onayda', 'tl-c-bek'], 2: ['Hazırlanacak', 'tl-c-bek'], 3: ['Reddedildi', 'tl-c-red'],
  4: ['Hazır', 'tl-c-mavi'], 5: ['Teslim edildi', 'tl-c-ok'], 8: ['İptal', 'tl-c-gri'],
};
const TESLIM: [number, string][] = [[1, 'Elden'], [2, 'E-posta'], [3, 'Kargo']];
const s10 = (v: unknown) => String(v ?? '').slice(0, 10);
const trTarih = (v: string) => v ? v.split('-').reverse().join('.') : '';

interface Deger {
  tarafId: number; tur: number; amac: string; muhatap: string; adet: number; teslimSekli: number;
  teslimEposta: string; teslimAdres: string; istenenTarih: string; aciklama: string; maasTutar: string; maasTuru: number;
}

/** Code128 doğrulama barkodu. */
function Barkod({ metin }: { metin: string }) {
  const desen = code128Desen(metin);
  if (!desen) return null;
  const m = 1.2, h = 32;
  const cubuk: { x: number; g: number }[] = [];
  let x = 0;
  for (let i = 0; i < desen.length;) {
    let n = 1;
    while (i + n < desen.length && desen[i + n] === desen[i]) n++;
    if (desen[i] === '1') cubuk.push({ x, g: n * m });
    x += n * m; i += n;
  }
  return (
    <svg width={desen.length * m} height={h} viewBox={`0 0 ${desen.length * m} ${h}`} shapeRendering="crispEdges" role="img" aria-label={metin}>
      {cubuk.map((c2, i) => <rect key={i} x={c2.x} y={0} width={c2.g} height={h} fill="#000" />)}
    </svg>
  );
}

/** Metin: boş yer tutucular ({{...}}) kırmızı. */
function Govde({ metin }: { metin: string }) {
  const parca = metin.split(/(\{\{[^}]+\}\})/g);
  return <>{parca.map((p, i) => /^\{\{.+\}\}$/.test(p) ? <span key={i} className="bk-eksik">{p}</span> : p)}</>;
}

export function BelgeTalepKarti() {
  const { id } = useParams();
  return <BelgeTalepKartiIc key={id ?? ''} param={id} />;
}

function BelgeTalepKartiIc({ param }: { param: string | undefined }) {
  const git = useNavigate();
  // PERSONEL LİSTESİNDEN (Yeni Talep ▾): seçili personel dolu gelir, Kapat listeye döner.
  const pt = personelTalepDurumu(useLocation().state);
  const { yetki } = useOturum();
  const [kayitId, setKayitId] = useState<number | null>(param === 'yeni' ? null : Number(param));
  const [d, setD] = useState<Deger>({ tarafId: pt.personel?.id ?? 0, tur: 1, amac: '', muhatap: '', adet: 1, teslimSekli: 1, teslimEposta: '',
                                      teslimAdres: '', istenenTarih: '', aciklama: '', maasTutar: '', maasTuru: 1 });
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [ro, setRo] = useState({ talepNo: '', talepTarihi: '', durum: 0, otomatik: false, redNeden: '', hazirlayan: '',
                                 hazirlamaTarihi: '', teslimTarihi: '', kod: '' });
  const [surum, setSurum] = useState<string | undefined>();
  const [kodlar, setKodlar] = useState<Record<string, Record<string, string>>>({});
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [b, setB] = useState<any>(null);
  const [yazi, setYazi] = useState<BelgeYazisi | null>(null);
  const [sablon, setSablon] = useState<number | null>(null);
  const [duzenle, setDuzenle] = useState<{ baslik: string; govde: string } | null>(null);
  const [amaclar, setAmaclar] = useState<string[]>([]);
  const [ekler, setEkler] = useState<DokumanSatiri[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [mesgul, setMesgul] = useState(false);
  const [arama, setArama] = useState(false);
  const [secilenAd, setSecilenAd] = useState(pt.personel?.ad ?? '');
  const dosyaRef = useRef<HTMLInputElement>(null);

  const kapat = useCallback(() => git(pt.geri ?? '/personel-belge-talep'), [git, pt.geri]);
  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));
  const yazar = yetki('ik.belge_talep', kayitId ? 'degistir' : 'ekle');
  const kilitli = ro.durum >= 3;   // reddedildi / hazırlandı / teslim / iptal

  const yaziYukle = useCallback(async (kid: number, sid: number | null) => {
    try { setYazi(await api.belgeTalepYazi(kid, sid ?? undefined)) } catch { setYazi(null) }
  }, []);

  const oku = useCallback(async (kid: number) => {
    const y = await api.kartOku(KAYNAK, kid);
    const k = y.kart as Record<string, unknown>;
    const v: Deger = {
      tarafId: Number(k.tarafId ?? 0), tur: Number(k.tur ?? 1), amac: String(k.amac ?? ''), muhatap: String(k.muhatap ?? ''),
      adet: Number(k.adet ?? 1), teslimSekli: Number(k.teslimSekli ?? 1), teslimEposta: String(k.teslimEposta ?? ''),
      teslimAdres: String(k.teslimAdres ?? ''), istenenTarih: s10(k.istenenTarih), aciklama: String(k.aciklama ?? ''),
      maasTutar: k.maasTutar == null ? '' : Number(k.maasTutar).toLocaleString('tr-TR', { minimumFractionDigits: 2 }),
      maasTuru: Number(k.maasTuru ?? 1),
    };
    setD(v); setIlk(v); setSurum(k.surum as string | undefined);
    setRo({ talepNo: String(k.talepNo ?? ''), talepTarihi: s10(k.talepTarihi), durum: Number(k.durum ?? 0),
            otomatik: Number(k.otomatikOnay ?? 0) === 1 || k.otomatikOnay === true, redNeden: String(k.redNeden ?? ''),
            hazirlayan: String(k.hazirlayanId ?? ''), hazirlamaTarihi: String(k.hazirlamaTarihi ?? ''),
            teslimTarihi: String(k.teslimTarihi ?? ''), kod: String(k.dogrulamaKodu ?? '') });
    void yaziYukle(kid, null);
    api.dokumanlar(KAYNAK, kid).then(setEkler).catch(() => setEkler([]));
  }, [yaziYukle]);

  useEffect(() => {
    api.kartAlanlari(KAYNAK).then(m => setKodlar(Object.fromEntries(m.alanlar.map(a => [a.ad, a.kodlar ?? {}])))).catch(() => {});
    api.kodListe('ik.belge_amac').then(y => setAmaclar(y.degerler.filter(x => x.aktif !== 0).map(x => x.ad))).catch(() => setAmaclar([]));
    if (kayitId) oku(kayitId).catch(e => setHata(hataMetni(e)));
  }, [kayitId, oku]);

  useEffect(() => {
    if (!(d.tarafId > 0)) { setB(null); return }
    const p = new URLSearchParams({ tarafId: String(d.tarafId) });
    if (kayitId) p.set('talepId', String(kayitId));
    api.belgeBaglam(p).then(y => {
      setB(y);
      // E-POSTA VARSAYILANI: kişinin kayıtlı adresi (yeni talepte).
      if (!kayitId && y.personel?.eposta) setD(o => o.teslimEposta ? o : { ...o, teslimEposta: y.personel.eposta });
    }).catch(e => setHata(hataMetni(e)));
  }, [d.tarafId, kayitId, ro.durum]);

  const personelAd = b?.personel?.ad || secilenAd || '';

  const kaydet = async (): Promise<number | null> => {
    if (!(d.tarafId > 0)) { setHata(c('Personel seçilmeli.')); return null }
    if (!d.amac.trim()) { setHata(c('Belgenin ne için istendiğini yazın.')); return null }
    if (d.teslimSekli === 2 && !/\S+@\S+\.\S+/.test(d.teslimEposta)) { setHata(c('Teslim e-posta adresi geçerli değil.')); return null }
    if (d.teslimSekli === 3 && !d.teslimAdres.trim()) { setHata(c('Kargo adresi girilmeli.')); return null }
    setHata(null);
    if (!kayitId) {
      const y = await api.belgeTalepAc({
        tarafId: d.tarafId, tur: d.tur, amac: d.amac.trim(), muhatap: d.muhatap.trim() || undefined, adet: d.adet,
        teslimSekli: d.teslimSekli, aciklama: d.aciklama.trim() || undefined, istenenTarih: d.istenenTarih || undefined,
        teslimEposta: d.teslimSekli === 2 ? d.teslimEposta.trim() : undefined, teslimAdres: d.teslimSekli === 3 ? d.teslimAdres.trim() : undefined,
      });
      if (d.tur === 2 && tutarOku(d.maasTutar) > 0) {
        const k = await api.kartOku(KAYNAK, y.id);
        await api.kartGuncelle(KAYNAK, y.id, { surum: (k.kart as Record<string, unknown>).surum as string, kart: { maasTutar: tutarOku(d.maasTutar), maasTuru: d.maasTuru } });
      }
      setKayitId(y.id);
      git(`/personel-belge-talep/${y.id}`, { replace: true, ...devamDurumu(pt) });
      if (y.mesaj) void mesaj(y.mesaj);
      return y.id;
    }
    const alan: Record<string, unknown> = { tur: d.tur, amac: d.amac.trim(), muhatap: d.muhatap.trim(), adet: d.adet, teslimSekli: d.teslimSekli,
      teslimEposta: d.teslimEposta.trim(), teslimAdres: d.teslimAdres.trim(), istenenTarih: d.istenenTarih || null, aciklama: d.aciklama.trim(),
      maasTutar: d.maasTutar ? tutarOku(d.maasTutar) : null, maasTuru: d.maasTuru };
    const eski: Record<string, unknown> = ilk ? { tur: ilk.tur, amac: ilk.amac, muhatap: ilk.muhatap, adet: ilk.adet, teslimSekli: ilk.teslimSekli,
      teslimEposta: ilk.teslimEposta, teslimAdres: ilk.teslimAdres, istenenTarih: ilk.istenenTarih || null, aciklama: ilk.aciklama,
      maasTutar: ilk.maasTutar ? tutarOku(ilk.maasTutar) : null, maasTuru: ilk.maasTuru } : {};
    const fark = Object.fromEntries(Object.entries(alan).filter(([k, v]) => v !== eski[k]));
    if (Object.keys(fark).length) await api.kartGuncelle(KAYNAK, kayitId, { surum, kart: fark });
    await oku(kayitId);
    return kayitId;
  };

  const calis = (is: () => Promise<unknown>) => async () => {
    setMesgul(true);
    try { await is(); talepleriYenile() } catch (e) { setHata(hataMetni(e)) } finally { setMesgul(false) }
  };
  const hazirla = calis(async () => { const id = await kaydet(); if (id) { await api.belgeTalepHazirla(id); await oku(id) } });
  const teslim = calis(async () => {
    if (!kayitId) return;
    const n = await metinSor(c('Teslim notu (teslim alan, kargo no…)'), '', c('Not'));
    if (n === null) return;
    await api.belgeTalepTeslim(kayitId, n || undefined); await oku(kayitId);
  });
  const epostaGonder = calis(async () => {
    if (!kayitId || !await onay(`${d.teslimEposta} ${c('adresine e-postayla gönderilsin ve teslim edildi işaretlensin mi?')}`)) return;
    await api.belgeTalepEposta(kayitId); await oku(kayitId);
  });
  const reddet = calis(async () => {
    if (!kayitId) return;
    const g = await metinSor(c('Red gerekçesi (personele söylenecek)'), '', c('Gerekçe'));
    if (g) { await api.belgeTalepReddet(kayitId, g); await oku(kayitId) }
  });
  const yaziKaydet = calis(async () => {
    if (!kayitId || !duzenle) return;
    await api.belgeTalepYaziKaydet(kayitId, { baslik: duzenle.baslik, govde: duzenle.govde, sablonId: yazi?.sablonId || undefined });
    setDuzenle(null); await yaziYukle(kayitId, null);
  });

  const asama = ro.durum === 3 || ro.durum === 8 ? -1 : ro.durum === 1 ? 1 : ro.durum === 2 ? 2 : ro.durum === 4 ? 3 : ro.durum === 5 ? 5 : 0;
  const istenenGecti = d.istenenTarih && ro.durum < 4 && d.istenenTarih <= bugunIso();
  // DOĞRULAMA ADRESİ API tabanından (dev 5180, yayında /ai) - paylaşım bağlantılarıyla aynı.
  const dogrulamaUrl = ro.kod ? `${TABAN}/api/belge-dogrula/${ro.kod}` : '';

  const alt = (
    <>
      {yazar && !kilitli && <button type="button" className="d bir" disabled={mesgul} onClick={() => void calis(async () => { await kaydet() })()}>💾 {c('Kaydet')}</button>}
      {kayitId && yazar && ro.durum === 2 && (
        <button type="button" className="d tl-ok" disabled={mesgul || (yazi?.eksik.length ?? 0) > 0}
                title={(yazi?.eksik.length ?? 0) > 0 ? c('Boş yer tutucu var') : undefined} onClick={() => void hazirla()}>✔ {c('Hazırla')}</button>
      )}
      {kayitId && yazar && ro.durum === 4 && <button type="button" className="d" disabled={mesgul} onClick={() => void teslim()}>📦 {c('Teslim et')}…</button>}
      {kayitId && <button type="button" className="d" onClick={() => window.open(`/belge-talep/yazi/${kayitId}`, '_blank')}>🖨 {c('Yazdır / PDF')}</button>}
      {kayitId && yazar && ro.durum === 4 && d.teslimSekli === 2 && <button type="button" className="d" disabled={mesgul} onClick={() => void epostaGonder()}>✉ {c('E-posta ile gönder')}</button>}
      {kayitId && yazar && (ro.durum === 1 || ro.durum === 2 || ro.durum === 4) && <button type="button" className="d tl-tehlike" disabled={mesgul} onClick={() => void reddet()}>✕ {c('Reddet')}</button>}
      <span className="ck-bosluk" />
      <button type="button" className="d" onClick={kapat}>{c('Kapat')}</button>
    </>
  );

  return (
    <Modal baslik={`📄 ${c('Belge Talebi')}${ro.talepNo ? ` — ${ro.talepNo}` : ''}${personelAd ? ` · ${personelAd}` : ''}`}
           ekSinif="kart-calisma" buyutmeYok alt={alt} onKapat={kapat}>
      <div className="ck-kimlik it-kimlik">
        <div className="rk-fld"><span className="ck-etiket">{c('Personel')} <b className="ak-zor">*</b></span>
          <span className="ikili" style={{ display: 'flex', gap: 4, width: '100%' }}>
            <input readOnly className="ck-buyuk" style={{ flex: 1 }} value={personelAd} placeholder={`— ${c('seçiniz')} —`}
                   disabled={!!kayitId} onClick={() => !kayitId && setArama(true)} />
            <button type="button" className="d mini" title={c('Ara')} disabled={!!kayitId} onClick={() => setArama(true)}>…</button>
          </span>
          {b?.personel && <span className="sonuk tl-kucuk">{[b.personel.bolum, b.personel.gorev].filter(Boolean).join(' · ')}</span>}</div>
        <div className="rk-fld"><span className="ck-etiket">{c('Talep no')}</span><input value={ro.talepNo} disabled /></div>
        <div className="rk-fld"><span className="ck-etiket">{c('Talep tarihi')}</span><input value={trTarih(ro.talepTarihi)} disabled /></div>
        <div className="rk-fld"><span className="ck-etiket">{c('Durum')}</span>
          <div className="ck-durum"><span className={`tl-chip ${DURUM[ro.durum]?.[1] ?? ''}`}>{c(DURUM[ro.durum]?.[0] ?? '')}
            {ro.otomatik && ro.durum === 2 ? ` · ${c('otomatik onay')}` : ''}</span></div></div>
      </div>
      {hata && <div className="hata-kutusu" style={{ margin: '8px 12px 0' }}>{hata}</div>}
      {ro.redNeden && <div className="tl-uyari" style={{ margin: '8px 12px 0' }}>{c('Red nedeni')}: {ro.redNeden}</div>}

      <div className="ck-govde">
        <div className="ck-sol">
          <div className="ck-grp">
            <h6>{c('Talep')}{kilitli && <span className="ck-ek">🔒 {c('hazırlandı / kapandı - kilitli')}</span>}</h6>
            <div className="ck-iz">
              <div className="ck-tam it-turler">
                {TURLER.map(t => (
                  <button key={t.kod} type="button" disabled={kilitli} className={d.tur === t.kod ? 'it-on' : ''} onClick={() => yaz('tur', t.kod)}>
                    <b>{t.ic} {c(t.ad)}</b><span>{c(t.ne)}</span></button>
                ))}
              </div>
              <div className="rk-fld"><span className="ck-etiket">{c('Ne için (amaç)')} <b className="ak-zor">*</b></span>
                <input list="bk-amac" value={d.amac} maxLength={200} disabled={kilitli} onChange={e => yaz('amac', e.target.value)} placeholder={c('seçin ya da yazın')} />
                <datalist id="bk-amac">{amaclar.map(a => <option key={a} value={a} />)}</datalist></div>
              <label className="rk-fld"><span className="ck-etiket">{c('Muhatap')}</span>
                <input value={d.muhatap} maxLength={200} disabled={kilitli} placeholder={c('boş = ilgili makama')} onChange={e => yaz('muhatap', e.target.value)} /></label>
              <label className="rk-fld"><span className="ck-etiket">{c('Nüsha')}</span>
                <input type="number" min={1} max={10} style={{ width: 70 }} value={d.adet} disabled={kilitli} onChange={e => yaz('adet', Math.max(1, Number(e.target.value) || 1))} /></label>
              <div className="rk-fld"><span className="ck-etiket">{c('Teslim şekli')}</span>
                <div className="ck-cipler">
                  {TESLIM.map(([k, a]) => <button key={k} type="button" disabled={kilitli} className={`ck-cip${d.teslimSekli === k ? ' on' : ''}`} onClick={() => yaz('teslimSekli', k)}>{c(a)}</button>)}
                </div></div>
              {d.teslimSekli === 2 && (
                <label className="rk-fld"><span className="ck-etiket">{c('E-posta')} <b className="ak-zor">*</b></span>
                  <input type="email" value={d.teslimEposta} maxLength={150} disabled={kilitli} onChange={e => yaz('teslimEposta', e.target.value)} /></label>
              )}
              {d.teslimSekli === 3 && (
                <label className="rk-fld"><span className="ck-etiket">{c('Kargo adresi')} <b className="ak-zor">*</b></span>
                  <input value={d.teslimAdres} maxLength={300} disabled={kilitli} onChange={e => yaz('teslimAdres', e.target.value)} /></label>
              )}
              <label className="rk-fld"><span className="ck-etiket">{c('İstenen tarih')}</span>
                <input type="date" value={d.istenenTarih} disabled={kilitli} onChange={e => yaz('istenenTarih', e.target.value)} /></label>
              <label className="rk-fld ck-tam"><span className="ck-etiket">{c('Açıklama')}</span>
                <input value={d.aciklama} maxLength={300} disabled={kilitli} onChange={e => yaz('aciklama', e.target.value)} /></label>
              <label className="rk-fld"><span className="ck-etiket">{c('Maaş tutarı')} <span className="sonuk">({c('yalnız maaş yazısı')})</span></span>
                <input inputMode="decimal" value={d.maasTutar} disabled={kilitli || d.tur !== 2} onChange={e => yaz('maasTutar', e.target.value)} /></label>
              <label className="rk-fld"><span className="ck-etiket">{c('Maaş türü')}</span>
                <select value={d.maasTuru} disabled={kilitli || d.tur !== 2} onChange={e => yaz('maasTuru', Number(e.target.value))}>
                  {Object.entries(kodlar.maasTuru ?? { 1: 'Net', 2: 'Brüt' }).map(([k, a]) => <option key={k} value={k}>{a}</option>)}
                </select></label>
            </div>
          </div>

          <div className="ck-grp">
            <h6>{c('Yazı önizleme')}<span className="ck-ek">{yazi ? `${yazi.donmus ? c('dondurulmuş metin') : `${c('şablon')} "${yazi.sablonAd}"`} · A4` : ''}</span></h6>
            {!kayitId ? <div className="tl-bilgi" style={{ margin: 12 }}>{c('Talep kaydedilince yazı şablondan üretilir ve burada görünür.')}</div> : !yazi ? (
              <div className="sonuk" style={{ padding: 12 }}>{c('yükleniyor')}…</div>
            ) : (<>
              <div className="bk-yazibar">
                <span>{c('Şablon')}</span>
                <select value={sablon ?? yazi.sablonId ?? ''} disabled={kilitli || yazi.donmus}
                        onChange={e => { const s = Number(e.target.value) || null; setSablon(s); void yaziYukle(kayitId, s) }}>
                  {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                  {(b?.sablonlar ?? []).filter((s: any) => !s.tur || s.tur === d.tur).map((s: any) => <option key={s.id} value={s.id}>{s.ad}</option>)}
                </select>
                {yazar && ro.durum <= 2 && <button type="button" className="d" onClick={() => setDuzenle({ baslik: yazi.baslik, govde: yazi.govde })}>✎ {c('Metni düzenle')}</button>}
                {yazi.eksik.length > 0 && <span className="bk-uyar">⚠ {yazi.eksik.length} {c('yer tutucu boş')}: <b>{yazi.eksik.join(', ')}</b></span>}
              </div>
              {duzenle ? (
                <div className="bk-duzenle">
                  <input value={duzenle.baslik} onChange={e => setDuzenle(o => o && ({ ...o, baslik: e.target.value }))} />
                  <textarea rows={14} value={duzenle.govde} onChange={e => setDuzenle(o => o && ({ ...o, govde: e.target.value }))} />
                  <div className="ck-ikili"><button type="button" className="d bir" disabled={mesgul} onClick={() => void yaziKaydet()}>💾 {c('Metni dondur')}</button>
                    <button type="button" className="d" onClick={() => setDuzenle(null)}>{c('Vazgeç')}</button>
                    <span className="sonuk tl-kucuk">{c('Dondurulan metin şablon değişse de bu talep için aynı kalır.')}</span></div>
                </div>
              ) : (
                <div className="bk-a4">
                  <div className="bk-antet"><div className="bk-logo">{(yazi.antet.unvan || 'G').slice(0, 1)}</div>
                    <div><b>{yazi.antet.unvan}</b><small>{[yazi.antet.adres, [yazi.antet.ilce, yazi.antet.il].filter(Boolean).join(' / '), yazi.antet.telefon].filter(Boolean).join(' · ')}</small></div></div>
                  <div className="bk-sayi">{c('Sayı')}: {yazi.talepNo}<br />{c('Tarih')}: {new Date().toLocaleDateString('tr-TR')}</div>
                  <h3>{yazi.baslik}</h3>
                  <div className="bk-metin"><Govde metin={yazi.govde} /></div>
                  {yazi.altNot && <div className="bk-not">{yazi.altNot}</div>}
                  <div className="bk-imza">{yazi.imzaUnvan}<br />({c('imza / kaşe')})</div>
                  {ro.kod ? (
                    <div className="bk-dogrula"><Barkod metin={ro.kod} /><span>{c('Doğrulama')}: <b>{ro.kod}</b><br />{dogrulamaUrl}</span></div>
                  ) : <div className="bk-dogrula sonuk">{c('Doğrulama kodu hazırlanınca basılır.')}</div>}
                </div>
              )}
              <div className="tl-bilgi" style={{ margin: '0 12px 12px' }}>{c('Kırmızı = boş yer tutucu: doldurulmadan Hazırla basılamaz. "Metni düzenle" bu talebin metnini dondurur.')}</div>
            </>)}
          </div>
        </div>

        <div className="ck-sag">
          <div className="ck-grp ck-grp-sag">
            <h6>{c('Süreç')}</h6>
            {asama < 0 ? <div className="tl-uyari" style={{ margin: 12 }}>{ro.durum === 3 ? c('Reddedildi') : c('İptal edildi')}</div> : (
              <div className="bk-adimlar">
                {[[c('Talep'), trTarih(ro.talepTarihi).slice(0, 5)], [c('Onay'), ro.otomatik ? c('otomatik') : ''], [c('Hazırlanıyor'), ''], [c('Hazır'), ro.hazirlamaTarihi ? tarihSaat(ro.hazirlamaTarihi).slice(0, 5) : ''], [c('Teslim'), ro.teslimTarihi ? tarihSaat(ro.teslimTarihi).slice(0, 5) : '']]
                  .map(([ad, alt2], i) => {
                    const st = i < asama || asama === 5 ? 'ok' : i === asama ? 'su' : '';
                    return [i > 0 && <span key={`c${i}`} className={`bk-cz${i <= asama ? ' ok' : ''}`} />,
                            <div key={i} className={`bk-ad ${st}`}><i>{st === 'ok' ? '✓' : i + 1}</i>{ad}{alt2 && <small>{alt2}</small>}</div>];
                  })}
              </div>
            )}
            {ro.otomatik && <div className="tl-bilgi" style={{ margin: '0 12px 12px' }}>{c('Otomatik onay açık: talep doğrudan hazırlık kuyruğuna düştü.')}</div>}
          </div>

          {kayitId && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Hazırlık / teslim')}</h6>
              <div className="it-akis">
                <div>{c('Hazırlayan')}<small>{ro.hazirlayan ? (kodlar.hazirlayanId?.[ro.hazirlayan] ?? ro.hazirlayan) : c('— (Hazırla\'ya basan)')}</small></div>
                <div>{c('Hazırlanma')}<small>{ro.hazirlamaTarihi ? tarihSaat(ro.hazirlamaTarihi) : '—'}</small></div>
                <div>{c('Teslim')}<small>{ro.teslimTarihi ? `${tarihSaat(ro.teslimTarihi)} · ${TESLIM.find(x => x[0] === d.teslimSekli)?.[1] ?? ''}` : '—'}</small></div>
              </div>
            </div>
          )}

          {istenenGecti && (
            <div className="tl-uyari" style={{ margin: '12px 12px 0' }}>⏰ {c('İstenen tarih')} <b>{trTarih(d.istenenTarih)}</b> {d.istenenTarih < bugunIso() ? c('geçti') : c('- bugün')}. {c('Hazırlık kuyruğunda öne alın.')}</div>
          )}

          {(b?.gecmis?.length ?? 0) > 0 && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Önceki belge talepleri')}<span className="ck-ek">{c('son 12 ay')}</span></h6>
              <table className="av-gecmis"><tbody>
                {/* eslint-disable-next-line @typescript-eslint/no-explicit-any */}
                {b.gecmis.map((g: any, i: number) => (
                  <tr key={i}><td>{g.no}</td><td>{c(TURLER.find(t => t.kod === g.tur)?.ad ?? '')}</td><td>{trTarih(s10(g.tarih))}</td>
                    <td><span className={`tl-chip ${DURUM[g.durum]?.[1] ?? ''}`}>{c(DURUM[g.durum]?.[0] ?? '')}</span></td></tr>
                ))}
              </tbody></table>
            </div>
          )}

          {kayitId && (
            <div className="ck-grp ck-grp-sag">
              <h6>{c('Belgeler')}<span className="ck-ek">{c('hazırlanan yazı + ekler')}</span></h6>
              <div className="tl-ekler" style={{ padding: '8px 12px' }}>
                {ro.durum >= 4 && <button type="button" className="tl-ek" onClick={() => window.open(`/belge-talep/yazi/${kayitId}`, '_blank')}>📄 {yazi?.baslik || c('Hazırlanan yazı')}</button>}
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
                    {a.tur === 'olustu' ? c('Talep oluşturuldu') : a.tur === 'otomatik' ? c('Otomatik onaylandı · hazırlık kuyruğunda')
                      : a.tur === 'onay' ? `✓ ${a.metin} ${c('onayladı')}` : a.tur === 'bilgi' ? `? ${a.metin} ${c('bilgi istedi')}`
                      : a.tur === 'hazir' ? `✔ ${c('Hazırlandı')}${a.metin ? ` · ${c('doğrulama')} ${a.metin}` : ''}`
                      : a.tur === 'teslim' ? `📦 ${c('Teslim edildi')} · ${a.metin}` : a.tur === 'red' ? `✕ ${c('Reddedildi')}${a.metin ? `: ${a.metin}` : ''}` : a.metin}
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
          onSec={sec => { setD(o => ({ ...o, tarafId: sec.id, teslimEposta: '' })); setSecilenAd(sec.unvan); setArama(false) }} />
      )}
    </Modal>
  );
}
