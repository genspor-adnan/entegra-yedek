import { useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CalismaSablonEtki, CalismaSablonTaslak } from '../../api/uclar/ayar';
import { Modal } from '../Modal';
import { guvenli, mesaj, onay } from '../mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { GUN_AD, Grp, KANALLAR, SLOTLAR, bugunIso, dk, gun10, gunMetni, metin, sayi, tarihSaat } from './calismaOrtak';

/**
 * ÇALIŞMA ŞABLONU KARTI — mockup `Ekranlar/Randevu/calisma_sablonu_karti.html`.
 *
 * Şablon randevu düzeninin TEK KAYNAĞIDIR: takvim, uygun saatler ve kayıt
 * anındaki mesai dışı kontrolü buradan türer. Mockup'a göre:
 *   (1) günler "1,2,3" metni yerine 7 düğme;
 *   (2) iki blok, aradaki boşluk öğle arası; canlı önizleme günlük slotu gösterir;
 *   (3) kanallar onay kutusu;
 *   (4) sağ panel kaydetmeden ÖNCE etkiyi söyler: doluluk, dışarıda kalacak
 *       randevular, çakışan aktif şablon (kayıt 945 tetiğinde engellenir).
 * Yazma generic kart ucuyla (`calisma-sablon`); kural sunucuda, kart yalnız
 * gösterir. Yeni şablonun düzeni ⚙ Varsayılanlar'dan gelir.
 */

interface Deger {
  hekimId: number; departmanId: number; subeId: number | null; ad: string; aktif: number;
  gunler: number[]; bas1: string; bit1: string; ikinci: boolean; bas2: string; bit2: string;
  slotDk: number; kanallar: string[]; gunlukKota: number; portalYuzde: number; kontrolYuzde: number;
  tekrar: number; gecerliBas: string; gecerliBit: string; aciklama: string;
}

const bos = (): Deger => ({
  hekimId: 0, departmanId: 0, subeId: null, ad: 'Standart hafta', aktif: 1,
  gunler: [1, 2, 3, 4, 5], bas1: '09:00', bit1: '12:30', ikinci: true, bas2: '13:30', bit2: '17:00',
  slotDk: 15, kanallar: ['B', 'P', 'C'], gunlukKota: 0, portalYuzde: 0, kontrolYuzde: 0,
  tekrar: 1, gecerliBas: bugunIso(), gecerliBit: '', aciklama: '',
});

const kartaCevir = (k: Record<string, unknown>): Deger => {
  const bas2 = metin(k.bas2), bit2 = metin(k.bit2);
  return {
    hekimId: sayi(k.hekimId), departmanId: sayi(k.departmanId), subeId: k.subeId == null ? null : sayi(k.subeId),
    ad: metin(k.ad), aktif: sayi(k.aktif),
    gunler: metin(k.gunler).split(',').map(Number).filter(x => x >= 1 && x <= 7),
    bas1: metin(k.bas1), bit1: metin(k.bit1), ikinci: !!bas2, bas2, bit2,
    slotDk: sayi(k.slotDk) || 15, kanallar: metin(k.kanallar).split(',').filter(Boolean),
    gunlukKota: sayi(k.gunlukKota), portalYuzde: sayi(k.portalYuzde), kontrolYuzde: sayi(k.kontrolYuzde),
    tekrar: sayi(k.tekrar) || 1, gecerliBas: gun10(k.gecerliBas), gecerliBit: gun10(k.gecerliBit),
    aciklama: metin(k.aciklama),
  };
};

const govde = (v: Deger): Record<string, unknown> => ({
  hekimId: v.hekimId || null, departmanId: v.departmanId || null, subeId: v.subeId, ad: v.ad.trim(), aktif: v.aktif,
  gunler: [...v.gunler].sort((a, b) => a - b).join(','), bas1: v.bas1, bit1: v.bit1,
  bas2: v.ikinci ? v.bas2 : null, bit2: v.ikinci ? v.bit2 : null, slotDk: v.slotDk,
  kanallar: KANALLAR.map(([k]) => k).filter(k => v.kanallar.includes(k)).join(','),
  gunlukKota: v.gunlukKota, portalYuzde: v.portalYuzde, kontrolYuzde: v.kontrolYuzde,
  tekrar: v.tekrar, gecerliBas: v.gecerliBas || null, gecerliBit: v.gecerliBit || null, aciklama: v.aciklama.trim(),
});

/** Formun blokları (dakika). Geçersiz saat bloğu üretmez. */
const bloklar = (v: Deger) => {
  const l: [number, number][] = [];
  if (dk(v.bit1) > dk(v.bas1)) l.push([dk(v.bas1), dk(v.bit1)]);
  if (v.ikinci && dk(v.bit2) > dk(v.bas2)) l.push([dk(v.bas2), dk(v.bit2)]);
  return l;
};

/** ilkHekim / ilkDepartman: yeni şablon bu doktor ve bölümle açılır (listede "şablonu olmayan doktor"). */
export function CalismaSablonKarti({ id, ilkHekim, ilkDepartman, onKapat }: {
  id: number | 'yeni'; ilkHekim?: number; ilkDepartman?: number; onKapat(): void;
}) {
  const git = useNavigate();
  const { yetki } = useOturum();
  const yazar = yetki('randevu.plan');
  const [kayitId, setKayitId] = useState<number | null>(id === 'yeni' ? null : id);
  const [d, setD] = useState<Deger>(bos);
  const [ilk, setIlk] = useState<Deger | null>(null);
  const [surum, setSurum] = useState<string | undefined>();
  const [kodlar, setKodlar] = useState<Record<string, Record<string, string>>>({});
  const [etki, setEtki] = useState<CalismaSablonEtki | null>(null);
  const [disaridaAcik, setDisaridaAcik] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);

  const yaz = <K extends keyof Deger>(k: K, v: Deger[K]) => setD(o => ({ ...o, [k]: v }));

  const oku = async (kid: number) => {
    const y = await api.kartOku('calisma-sablon', kid);
    const v = kartaCevir(y.kart);
    setKayitId(kid); setD(v); setIlk(v); setSurum(y.kart.surum as string | undefined);
  };

  useEffect(() => {
    let iptal = false;
    (async () => {
      try {
        const m = await api.kartAlanlari('calisma-sablon');
        if (iptal) return;
        setKodlar(Object.fromEntries(m.alanlar.map(a => [a.ad, a.kodlar ?? {}])));
        if (id === 'yeni') {
          // YENİ ŞABLON: ⚙ Varsayılanlar'ın düzeni.
          const v = await api.calismaSablonVarsayilan();
          if (iptal) return;
          setD(o => ({
            ...o, gunler: v.gunler.split(',').map(Number).filter(x => x >= 1 && x <= 7),
            bas1: v.bas1, bit1: v.bit1, ikinci: !!v.bas2, bas2: v.bas2 ?? '', bit2: v.bit2 ?? '', slotDk: v.slotDk,
            hekimId: ilkHekim ?? o.hekimId, departmanId: ilkDepartman ?? o.departmanId,
          }));
        } else await oku(id);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  }, [id]);

  // ETKİ PANELİ: form değiştikçe (gecikmeli) sunucuya sorulur.
  const taslak = useMemo<CalismaSablonTaslak | null>(() => d.hekimId > 0 && bloklar(d).length > 0 && d.gecerliBas ? {
    id: kayitId, hekimId: d.hekimId, departmanId: d.departmanId || null,
    gunler: [...d.gunler].sort().join(','), bas1: d.bas1, bit1: d.bit1,
    bas2: d.ikinci ? d.bas2 : null, bit2: d.ikinci ? d.bit2 : null,
    slotDk: d.slotDk, tekrar: d.tekrar, gecerliBas: d.gecerliBas, gecerliBit: d.gecerliBit || null,
  } : null, [d, kayitId]);
  const taslakAnahtar = JSON.stringify(taslak);
  useEffect(() => {
    if (!taslak) { setEtki(null); return }
    let iptal = false;
    const z = setTimeout(() => {
      api.calismaSablonEtki(taslak).then(y => { if (!iptal) setEtki(y) }).catch(() => { /* panel sessiz */ });
    }, 400);
    return () => { iptal = true; clearTimeout(z) };
  }, [taslakAnahtar]);   // eslint-disable-line react-hooks/exhaustive-deps

  // ÖNİZLEME: 08-19 cetveli, saatler dışına taşarsa genişler.
  const bl = bloklar(d);
  const cetBas = Math.min(8 * 60, ...bl.map(b => Math.floor(b[0] / 60) * 60));
  const cetBit = Math.max(19 * 60, ...bl.map(b => Math.ceil(b[1] / 60) * 60));
  const genislik = cetBit - cetBas;
  const gunSlot = bl.reduce((t, b) => t + Math.floor((b[1] - b[0]) / Math.max(d.slotDk, 1)), 0);
  const gunDk = bl.reduce((t, b) => t + b[1] - b[0], 0);
  const ogle = d.ikinci && dk(d.bas2) > dk(d.bit1) ? `${d.bit1}–${d.bas2}` : '';

  const dogrula = (v: Deger) => {
    if (!(v.hekimId > 0)) return c('Doktor seçilmeli.');
    if (!(v.departmanId > 0)) return c('Bölüm seçilmeli.');
    if (v.gunler.length === 0) return c('En az bir çalışma günü seçin.');
    if (Number.isNaN(dk(v.bas1)) || Number.isNaN(dk(v.bit1)) || dk(v.bas1) >= dk(v.bit1))
      return c('1. blok saatleri SS:DD biçiminde olmalı ve başlangıç bitişten önce gelmeli.');
    if (v.ikinci && (Number.isNaN(dk(v.bas2)) || Number.isNaN(dk(v.bit2)) || dk(v.bas2) >= dk(v.bit2) || dk(v.bas2) < dk(v.bit1)))
      return c('2. blok 1. bloktan sonra başlamalı ve başlangıç bitişten önce gelmeli.');
    if (!v.gecerliBas) return c('Başlangıç tarihi girilmeli.');
    if (v.gecerliBit && v.gecerliBit < v.gecerliBas) return c('Bitiş başlangıçtan önce olamaz.');
    return null;
  };

  const kaydet = (ek?: Partial<Deger>) => guvenli(async () => {
    const v = { ...d, ...ek };
    const h = dogrula(v);
    if (h) { setHata(h); return }
    setHata(null); setKaydediyor(true);
    try {
      if (kayitId === null) {
        const y = await api.kartEkle('calisma-sablon', { kart: govde(v) });
        const yeniId = sayi(y.kart.id);
        await oku(yeniId);
        git(`/calisma-sablon/${yeniId}`, { replace: true });
      } else {
        const once = ilk ? govde(ilk) : {};
        const fark = Object.fromEntries(Object.entries(govde(v)).filter(([k, x]) => once[k] !== x));
        if (Object.keys(fark).length > 0) await api.kartGuncelle('calisma-sablon', kayitId, { surum, kart: fark });
        await oku(kayitId);
      }
      mesaj(c('Şablon kaydedildi.'));
    } finally { setKaydediyor(false) }
  });

  const kopyala = () => {
    // Kopya YENİ kayıttır: aynı düzen, ad "(kopya)". Aynı doktorda aynı saatler
    //   çakışır - sağ panel kaydetmeden önce söyler.
    setKayitId(null); setIlk(null); setSurum(undefined); setEtki(null);
    //   URL kaydedilene kadar eski kimlikte kalır (değiştirmek kartı yeniden okuturdu).
    setD(o => ({ ...o, ad: `${o.ad} (kopya)`.slice(0, 80), aktif: 1 }));
    mesaj(c('Kopya oluşturuldu - doktor ya da günleri değiştirip kaydedin.'));
  };

  const sil = () => guvenli(async () => {
    if (kayitId === null) return;
    if (!await onay(c('Şablon silinecek. Takvimdeki bu düzen kalkar; mevcut randevular silinmez. Devam edilsin mi?'), true)) return;
    await api.kartSil('calisma-sablon', kayitId);
    onKapat();
  });

  const ad = (alan: string, v: number | null) => (v ? kodlar[alan]?.[String(v)] : '') ?? '';
  const baslik = [ad('hekimId', d.hekimId), ad('departmanId', d.departmanId)].filter(Boolean).join(' · ');
  const secenekler = (alan: string) => Object.entries(kodlar[alan] ?? {}).sort((a, b) => a[1].localeCompare(b[1], 'tr'));
  const bitti = (b: string | null) => !!b && b < bugunIso();
  const durumRozet = (aktif: boolean, bit: string | null, bu?: boolean) =>
    bu ? <span className="rozet ok">{c('Bu kart')}</span>
      : !aktif ? <span className="rozet gri">{c('Pasif')}</span>
      : bitti(bit) ? <span className="rozet gri">{c('Süresi bitti')}</span>
      : <span className="rozet ok">{c('Aktif')}</span>;
  const sayiAlan = (k: 'gunlukKota' | 'portalYuzde' | 'kontrolYuzde', ust: number) => (
    <input type="number" min={0} max={ust} value={d[k]} disabled={!yazar}
           onChange={e => yaz(k, Math.max(0, Math.min(ust, Number(e.target.value) || 0)))} />
  );

  return (
    <Modal baslik={`📋 ${c('Çalışma Şablonu')}${baslik ? ' — ' + baslik : kayitId === null ? ' — ' + c('Yeni') : ''}`}
      ekSinif="kart-calisma" buyutmeYok onKapat={onKapat}
      ustSerit={<div className="ck-kimlik ck-k5">
          <label className="rk-fld"><span className="ck-etiket">{c('Doktor')} <b className="ak-zor">*</b></span>
            <select className="ck-buyuk" value={d.hekimId || ''} disabled={!yazar} onChange={e => yaz('hekimId', Number(e.target.value) || 0)}>
              <option value="">{c('Seçin…')}</option>
              {secenekler('hekimId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
            </select></label>
          <label className="rk-fld"><span className="ck-etiket">{c('Bölüm')} <b className="ak-zor">*</b></span>
            <select value={d.departmanId || ''} disabled={!yazar} onChange={e => yaz('departmanId', Number(e.target.value) || 0)}>
              <option value="">{c('Seçin…')}</option>
              {secenekler('departmanId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
            </select></label>
          <label className="rk-fld"><span className="ck-etiket">{c('Şube')}</span>
            <select value={d.subeId ?? ''} disabled={!yazar} onChange={e => yaz('subeId', e.target.value ? Number(e.target.value) : null)}>
              <option value="">{c('Tümü')}</option>
              {secenekler('subeId').map(([k, a]) => <option key={k} value={k}>{a}</option>)}
            </select></label>
          <label className="rk-fld"><span className="ck-etiket">{c('Şablon Adı')}</span>
            <input value={d.ad} maxLength={80} disabled={!yazar} onChange={e => yaz('ad', e.target.value)} /></label>
          <div className="rk-fld"><span className="ck-etiket">{c('Durum')}</span>
            <div className="ck-durum">{d.aktif === 1
              ? (bitti(d.gecerliBit) ? <span className="rozet gri">{c('Süresi bitti')}</span> : <span className="rozet ok">{c('Aktif')}</span>)
              : <span className="rozet gri">{c('Pasif')}</span>}</div></div>
        </div>}
      alt={<>
          {yazar && <button type="button" className="d bir" disabled={kaydediyor || yukleniyor} onClick={() => void kaydet()}>💾 {c('Kaydet')}</button>}
          {yazar && kayitId !== null && <button type="button" className="d" onClick={kopyala}>⧉ {c('Kopyala')}</button>}
          {yazar && kayitId !== null && ilk !== null && (
            <button type="button" className="d" disabled={kaydediyor} onClick={() => void kaydet({ aktif: d.aktif === 1 ? 0 : 1 })}>
              {d.aktif === 1 ? `⏸ ${c('Pasife Al')}` : `▶ ${c('Aktifleştir')}`}</button>
          )}
          {yazar && kayitId !== null && <button type="button" className="d teh" onClick={() => void sil()}>🗑 {c('Sil')}</button>}
          <span className="ck-bosluk" />
          <button type="button" className="d kapat-dugmesi" onClick={onKapat}>{c('Kapat')}</button>
      </>}>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {yukleniyor ? <div className="yukleniyor-satir">{c('Yükleniyor…')}</div> : (
      <div className="ck-govde">
        <div className="ck-sol">
          <Grp baslik={<>🗓 {c('Haftalık Düzen')}</>} ek={c('günlere tıklayın · bloklar her seçili gün için geçerli')}>
            <div className="ck-iz">
              <div className="rk-fld ck-tam"><span className="ck-etiket">{c('Çalışma günleri')} <b className="ak-zor">*</b></span>
                <div className="cs-gunler">
                  {GUN_AD.map((g, i) => (
                    <button key={g} type="button" disabled={!yazar} className={`cs-gun${d.gunler.includes(i + 1) ? ' on' : ''}`}
                            onClick={() => yaz('gunler', d.gunler.includes(i + 1) ? d.gunler.filter(x => x !== i + 1) : [...d.gunler, i + 1])}>{c(g)}</button>
                  ))}
                </div></div>

              <div className="rk-fld ck-tam"><span className="ck-etiket">{c('Çalışma blokları')} <b className="ak-zor">*</b></span>
                <div className="ck-blok"><span className="ck-etk">{c('1. blok')}{d.ikinci ? ` (${c('sabah')})` : ''}</span>
                  <input value={d.bas1} disabled={!yazar} placeholder="09:00" onChange={e => yaz('bas1', e.target.value)} />
                  <span className="sonuk">–</span>
                  <input value={d.bit1} disabled={!yazar} placeholder="12:30" onChange={e => yaz('bit1', e.target.value)} /></div>
                {d.ikinci ? (
                  <div className="ck-blok"><span className="ck-etk">{c('2. blok (öğleden sonra)')}</span>
                    <input value={d.bas2} disabled={!yazar} placeholder="13:30" onChange={e => yaz('bas2', e.target.value)} />
                    <span className="sonuk">–</span>
                    <input value={d.bit2} disabled={!yazar} placeholder="17:00" onChange={e => yaz('bit2', e.target.value)} />
                    {yazar && <button type="button" className="d ck-kucuk" title={c('2. bloğu kaldır')} onClick={() => yaz('ikinci', false)}>✕</button>}
                  </div>
                ) : yazar && (
                  <div className="ck-blok"><span className="ck-etk" />
                    <button type="button" className="d ck-kucuk" onClick={() => setD(o => ({ ...o, ikinci: true, bas2: o.bas2 || '13:30', bit2: o.bit2 || '17:00' }))}>＋ {c('2. blok')}</button></div>
                )}
                <div className="ck-blok"><span className="ck-etk" />
                  <span className="sonuk ck-not">{ogle
                    ? `${c('Bloklar arası boşluk = öğle arası')} (${ogle}). ${c('Tek blok da girilebilir.')}`
                    : c('Tek blok: öğle arası yok. İkinci blok eklenirse aradaki boşluk öğle arası olur.')}</span></div>
              </div>

              <div className="rk-fld ck-tam"><span className="ck-etiket">{c('Randevu aralığı (slot)')} <b className="ak-zor">*</b></span>
                <div className="ck-cipler">
                  {SLOTLAR.map(s => (
                    <button key={s} type="button" disabled={!yazar} className={`ck-cip${d.slotDk === s ? ' on' : ''}`} onClick={() => yaz('slotDk', s)}>{s} dk</button>
                  ))}
                </div></div>
            </div>

            {/* CANLI ÖNİZLEME: günlük zaman çizgisi */}
            <div className="ck-zaman">
              <div className="ck-zsatir ck-cetvel"><span />
                <div>{Array.from({ length: genislik / 60 + 1 }, (_, i) => <span key={i}>{String(cetBas / 60 + i).padStart(2, '0')}</span>)}</div><span /></div>
              {GUN_AD.map((g, i) => {
                const on = d.gunler.includes(i + 1);
                return (
                  <div key={g} className={`ck-zsatir${on ? '' : ' soluk'}`}>
                    <span className="ck-g">{c(g)}</span>
                    <div className="ck-serit" style={{ backgroundSize: `${100 / (genislik / 60)}% 100%` }}>
                      {on && bl.map(([b, e], j) => (
                        <i key={j} style={{ left: `${(100 * (b - cetBas)) / genislik}%`, width: `${(100 * (e - b)) / genislik}%` }} />
                      ))}
                    </div>
                    <span className="ck-s">{on && gunSlot ? `${gunSlot} slot` : '—'}</span>
                  </div>
                );
              })}
            </div>
          </Grp>

          <Grp baslik={<>📡 {c('Kanal & Kota')}</>} ilkKapali>
            <div className="ck-iz ck-uc">
              <div className="rk-fld ck-tam"><span className="ck-etiket">{c('Hangi kanaldan randevu alınabilir')}</span>
                <div className="ck-kanallar">
                  {KANALLAR.map(([k, a]) => (
                    <label key={k} className="cs-onay">
                      <input type="checkbox" disabled={!yazar} checked={d.kanallar.includes(k)}
                             onChange={e => yaz('kanallar', e.target.checked ? [...d.kanallar, k] : d.kanallar.filter(x => x !== k))} />{c(a)}
                    </label>
                  ))}
                </div></div>
              <label className="rk-fld"><span className="ck-etiket">{c('Günlük kota (0 = sınırsız)')}</span>{sayiAlan('gunlukKota', 999)}</label>
              <label className="rk-fld"><span className="ck-etiket">{c('Portal payı %')}</span>{sayiAlan('portalYuzde', 100)}</label>
              <label className="rk-fld"><span className="ck-etiket">{c('Kontrol hastası payı %')}</span>{sayiAlan('kontrolYuzde', 100)}</label>
            </div>
          </Grp>

          <Grp baslik={<>📆 {c('Geçerlilik')}</>} ilkKapali={kayitId !== null}>
            <div className="ck-iz ck-uc">
              <div className="rk-fld"><span className="ck-etiket">{c('Tekrar')}</span>
                <div className="ck-cipler">
                  {[[1, 'Her hafta'], [2, 'İki haftada bir']].map(([k, a]) => (
                    <button key={k} type="button" disabled={!yazar} className={`ck-cip${d.tekrar === k ? ' on' : ''}`} onClick={() => yaz('tekrar', k as number)}>{c(a as string)}</button>
                  ))}
                </div></div>
              <label className="rk-fld"><span className="ck-etiket">{c('Başlangıç')} <b className="ak-zor">*</b></span>
                <input type="date" value={d.gecerliBas} disabled={!yazar} onChange={e => yaz('gecerliBas', e.target.value)} /></label>
              <label className="rk-fld"><span className="ck-etiket">{c('Bitiş (boş = süresiz)')}</span>
                <input type="date" value={d.gecerliBit} disabled={!yazar} onChange={e => yaz('gecerliBit', e.target.value)} /></label>
              <label className="rk-fld ck-tam"><span className="ck-etiket">{c('Açıklama')}</span>
                <input value={d.aciklama} maxLength={300} disabled={!yazar} onChange={e => yaz('aciklama', e.target.value)} /></label>
            </div>
          </Grp>
        </div>

        {/* SAĞ: etki paneli */}
        <div className="ck-sag">
          <Grp sinif="ck-grp-sag" baslik={<>📊 {c('Bu şablonun etkisi')}</>}>
            <div className="ck-iz">
              <div className="rk-fld"><span className="ck-etiket">{c('Haftalık slot')}</span>
                <div><b className="ck-sayi">{gunSlot * d.gunler.length}</b> ({d.gunler.length} {c('gün')} × {gunSlot})</div></div>
              <div className="rk-fld"><span className="ck-etiket">{c('Haftalık çalışma')}</span>
                <div><b className="ck-sayi">{Math.round((gunDk * d.gunler.length) / 6) / 10}</b> {c('saat')}</div></div>
              <div className="rk-fld"><span className="ck-etiket">{c('Önümüzdeki 2 hafta')}</span>
                <div>{etki ? <><b className="ck-sayi">{etki.randevu14}</b> {c('randevu dolu')}</> : '—'}</div></div>
              <div className="rk-fld"><span className="ck-etiket">{c('Doluluk')}</span>
                <div>{etki ? <b className="ck-sayi">%{etki.doluluk}</b> : '—'}</div></div>
            </div>
          </Grp>

          {etki && etki.disarida.length > 0 && (
            <div className="uyari-kutusu ck-kutu">⚠ <b>{etki.disarida.length} {c('randevu')}</b> {c('yeni saatlerin dışında kalıyor')}{ogle ? ` (${ogle} ${c('arası dahil')})` : ''}.
              {' '}{c('Kaydedince bu randevular takvimde "mesai dışı" taralı görünür; yeniden saat vermek için listeyi açın.')}
              {' '}<button type="button" className="ck-bag" onClick={() => setDisaridaAcik(a => !a)}>
                {disaridaAcik ? c('Gizle') : c('Randevuları göster')}</button>
              {disaridaAcik && (
                <ul className="ck-liste">
                  {etki.disarida.map(r => (
                    <li key={r.id}><button type="button" className="ck-bag" onClick={() => git(`/randevu/${r.id}`)}>
                      {tarihSaat(r.baslangic)}</button> · {r.hasta} · {r.sureDk} dk</li>
                  ))}
                </ul>
              )}
            </div>
          )}

          {etki && etki.cakisan.length > 0 ? (
            <div className="hata-kutusu ck-kutu">⛔ {c('Aynı gün ve saatte aktif şablon var - kayıt engellenir')}:
              <ul className="ck-liste">{etki.cakisan.map(x => <li key={x.id}><b>{x.ad}</b> · {x.departman} · {x.saat}</li>)}</ul></div>
          ) : (
            <div className="ck-bilgi ck-kutu">ℹ {c('Aynı gün ve saatte iki aktif şablon çakışırsa kayıt engellenir')}
              {etki ? ` (${c('çakışma yok')})` : ''}. {c('İzin, kongre ve saat değişikliği şablonu değiştirmeden')}
              {' '}<button type="button" className="ck-bag" onClick={() => git(`/calisma-istisna/yeni${d.hekimId ? `?hekimId=${d.hekimId}` : ''}`)}>{c('İzin & İstisnalar')}</button>{c('\'dan girilir.')}</div>
          )}

          <Grp sinif="ck-grp-sag" baslik={c('Doktorun diğer şablonları')} ilkKapali ek={etki ? String(etki.digerleri.length) : undefined}>
            <table className="ck-dg">
              <thead><tr><th>{c('Şablon')}</th><th>{c('Bölüm')}</th><th>{c('Günler')}</th><th>{c('Durum')}</th></tr></thead>
              <tbody>
                {(etki?.digerleri ?? []).map(x => (
                  <tr key={x.id} className={x.id === kayitId ? '' : 'ck-tik'}
                      onClick={() => x.id !== kayitId && git(`/calisma-sablon/${x.id}`)}>
                    <td>{x.ad}</td><td>{x.departman}</td><td>{gunMetni(x.gunler)}</td>
                    <td>{durumRozet(x.aktif, x.gecerliBit, x.id === kayitId)}</td></tr>
                ))}
                {etki && etki.digerleri.length === 0 && <tr><td colSpan={4} className="sonuk">{c('Başka şablon yok.')}</td></tr>}
                {!etki && <tr><td colSpan={4} className="sonuk">{c('Doktor seçin.')}</td></tr>}
              </tbody>
            </table>
          </Grp>
        </div>
      </div>
      )}
      <div className="ck-ozet">
              <span>{c('Şablon No')}: <b>{kayitId ? `ŞB-${String(kayitId).padStart(4, '0')}` : '—'}</b></span>
              {etki?.kayit && <span>{c('Oluşturan')}: <b>{etki.kayit.ekleyen || '—'} · {tarihSaat(etki.kayit.eklemeTarihi)}</b></span>}
              {etki?.kayit?.degistirmeTarihi && <span>{c('Son değişiklik')}: <b>{etki.kayit.degistiren || '—'} · {tarihSaat(etki.kayit.degistirmeTarihi)}</b></span>}
            </div>
    </Modal>
  );
}
