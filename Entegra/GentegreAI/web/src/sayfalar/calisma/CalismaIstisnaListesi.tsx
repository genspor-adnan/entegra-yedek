import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { CalismaIstisnaListe, CalismaIstisnaSatiri } from '../../api/uclar/ayar';
import { useOturum } from '../../kimlik/OturumBaglami';
import { CalismaIstisnaKarti } from '../../bilesenler/calisma/CalismaIstisnaKarti';
import { GUN_AD, isoGun, tarihSaat } from '../../bilesenler/calisma/calismaOrtak';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';

/**
 * İZİN & İSTİSNALAR LİSTESİ — mockup `Ekranlar/Randevu/izin_istisnalar_listesi.html`.
 *
 * "Kim, ne zaman, neden yok ve hastalara ne oldu": varsayılan çip Onay
 * bekliyor (yalnız onaylı istisna planı kapatır); tür renkli rozet; tarih
 * aralığı + gün sayısı + "N gün sonra / şu an devam ediyor"; etkilenen
 * randevunun DURUMU (işlem bekleyen sayısı); İK izni salt okunur satır;
 * giren / onaylayan; özet şeridi; toplu onayla / iptal; ikinci görünüm
 * doktor × 4 hafta zaman çizelgesi. Hesaplar sunucuda (`/istisna-liste`).
 */
type Durum = '0' | '1' | '2' | 'tumu';
type Donem = 'hafta' | '30' | 'gecmis' | 'tumu';
const TURLER: Record<number, [string, string, string]> = {
  1: ['✈️', 'İzin', 't-izin'], 2: ['🎓', 'Kongre / eğitim', 't-kongre'], 3: ['🕘', 'Saat değişikliği', 't-saat'],
  4: ['➕', 'Ek mesai', 't-ek'], 5: ['⛔', 'Kapalı', 't-kapali'], 0: ['🌴', 'İK izni', 't-ik'],
};
const DURUM: Record<number, [string, string]> = { 0: ['Onay bekliyor', 'uyari'], 1: ['Onaylı', 'ok'], 2: ['İptal', 'gri'] };
const gunEkle = (d: Date, n: number) => { const x = new Date(d); x.setDate(x.getDate() + n); return x };
const haftaBasi = (d: Date) => { const x = new Date(d); x.setHours(0, 0, 0, 0); return gunEkle(x, -((x.getDay() + 6) % 7)) };
const gun = (iso: string) => new Date(iso.slice(0, 10) + 'T00:00:00');
const kisa = (iso: string) => tarihSaat(iso.slice(0, 10)).slice(0, 5);
const aralik = (b: string, e: string) => b.slice(0, 10) === e.slice(0, 10) ? tarihSaat(b.slice(0, 10)) : `${kisa(b)}–${tarihSaat(e.slice(0, 10))}`;

function donemAraligi(d: Donem): { bas?: string; bit?: string } {
  const bugun = new Date(); bugun.setHours(0, 0, 0, 0);
  if (d === 'hafta') { const h = haftaBasi(bugun); return { bas: isoGun(h), bit: isoGun(gunEkle(h, 6)) } }
  if (d === '30') return { bas: isoGun(bugun), bit: isoGun(gunEkle(bugun, 30)) };
  if (d === 'gecmis') return { bit: isoGun(gunEkle(bugun, -1)) };
  return {};
}

export function CalismaIstisnaListesi() {
  const git = useNavigate();
  const { id } = useParams();
  const [sorgu] = useSearchParams();
  const { yetki } = useOturum();
  const yazar = yetki('randevu.plan');
  const [durum, setDurum] = useState<Durum>('0');
  const [tur, setTur] = useState<string>('');
  const [donem, setDonem] = useState<Donem>('30');
  const [bas, setBas] = useState<string>(() => donemAraligi('30').bas ?? '');
  const [bit, setBit] = useState<string>(() => donemAraligi('30').bit ?? '');
  const [departmanId, setDepartmanId] = useState<number | ''>('');
  const [ara, setAra] = useState('');
  const [araGecikmeli, setAraGecikmeli] = useState('');
  const [gorunum, setGorunum] = useState<'liste' | 'zaman'>('liste');
  const [veri, setVeri] = useState<CalismaIstisnaListe | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [secili, setSecili] = useState<Set<number>>(new Set());
  const [bolumler, setBolumler] = useState<[string, string][]>([]);

  useEffect(() => { const z = setTimeout(() => setAraGecikmeli(ara), 350); return () => clearTimeout(z) }, [ara]);
  useEffect(() => {
    api.kartAlanlari('calisma-istisna')
      .then(m => setBolumler(Object.entries(m.alanlar.find(a => a.ad === 'departmanId')?.kodlar ?? {}).sort((a, b) => a[1].localeCompare(b[1], 'tr'))))
      .catch(() => { /* seçici boş kalır */ });
  }, []);

  const yukle = useCallback(async () => {
    try {
      setVeri(await api.calismaIstisnaListe({ durum, tur, bas, bit, departmanId, ara: araGecikmeli.trim() }));
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) }
  }, [durum, tur, bas, bit, departmanId, araGecikmeli]);
  useEffect(() => { void yukle() }, [yukle]);
  const kartAcik = id !== undefined;
  useEffect(() => { if (!kartAcik) void yukle() }, [kartAcik]);   // eslint-disable-line react-hooks/exhaustive-deps

  const donemSec = (d: Donem) => { const a = donemAraligi(d); setDonem(d); setBas(a.bas ?? ''); setBit(a.bit ?? '') };
  const satirlar = veri?.satirlar ?? [];
  const isaretlenebilir = satirlar.filter(s => s.kaynak === 'istisna');
  const seciliSatirlar = isaretlenebilir.filter(s => secili.has(s.id));
  const tumu = isaretlenebilir.length > 0 && isaretlenebilir.every(s => secili.has(s.id));

  const topluCalistir = (islem: 'onayla' | 'iptal') => guvenli(async () => {
    const idler = seciliSatirlar.map(s => s.id);
    if (idler.length === 0) return;
    const bekleyen = seciliSatirlar.filter(s => s.tur !== 4).reduce((t, s) => t + s.bekleyen, 0);
    const soru = islem === 'iptal'
      ? `${idler.length} ${c('istisna iptal edilecek; plan şablondaki haline döner. Devam edilsin mi?')}`
      : bekleyen > 0 ? `${bekleyen} ${c('randevu için işlem yapılmadı; olduğu gibi kalır ve takvimde kapalı zeminde görünür. Onaylansın mı?')}` : null;
    if (soru && !await onay(soru, islem === 'iptal')) return;
    const y = await api.calismaIstisnaToplu(islem, idler);
    const hatali = y.sonuc.filter(s => !s.basarili);
    mesaj(hatali.length === 0 ? `${y.sonuc.length} ${c('kayıt işlendi.')}`
      : `${y.sonuc.length - hatali.length} / ${y.sonuc.length} ${c('kayıt işlendi.')}\n` + hatali.map(h => `#${h.id}: ${h.mesaj}`).join('\n'));
    setSecili(new Set());
    await yukle();
  });

  const ac = (s: CalismaIstisnaSatiri) => s.kaynak === 'ik' ? git('/personel-izin') : git(`/calisma-istisna/${s.id}`);
  const kartKapat = () => git(sorgu.get('geri') ?? '/calisma-istisna');
  const bugunMs = new Date(new Date().toDateString()).getTime();

  const tarihHucre = (s: CalismaIstisnaSatiri) => {
    const b = gun(s.bas).getTime(), e = gun(s.bit).getTime();
    const gunSay = Math.round((e - b) / 864e5) + 1;
    const fark = Math.round((b - bugunMs) / 864e5);
    const ek = b <= bugunMs && e >= bugunMs ? <small className="simdi">● {c('şu an devam ediyor')}</small>
      : e < bugunMs ? <small>{gunSay} {c('gün')} · {c('geçti')}</small>
      : <small>{gunSay} {c('gün')}{gunSay === 1 ? ` · ${c(GUN_AD[(gun(s.bas).getDay() + 6) % 7])}` : ''} · {fark === 0 ? c('bugün') : `${fark} ${c('gün sonra')}`}</small>;
    return <td className="cl-tarih"><b>{aralik(s.bas, s.bit)}</b>{ek}</td>;
  };

  const etkHucre = (s: CalismaIstisnaSatiri) => {
    if (s.tur === 4) {
      const dkm = s.saatBas && s.saatBit ? (Number(s.saatBit.slice(0, 2)) * 60 + Number(s.saatBit.slice(3))) - (Number(s.saatBas.slice(0, 2)) * 60 + Number(s.saatBas.slice(3))) : 0;
      const gunSay = Math.round((gun(s.bit).getTime() - gun(s.bas).getTime()) / 864e5) + 1;
      const slot = Math.max(0, Math.floor(dkm / Math.max(s.slotDk, 1))) * gunSay;
      return <span className="tamam">+{slot} {c('slot açıldı')} · {s.ekDolu} {c('dolu')}</span>;
    }
    if (s.durum === 2) return <span className="sonuk">—</span>;
    if (s.bekleyen > 0) return <span className="acik">{s.bekleyen} {c('randevu işlem bekliyor')}</span>;
    return gun(s.bit).getTime() < bugunMs ? <span className="sonuk">—</span> : <span className="tamam">✔ {c('bekleyen randevu yok')}</span>;
  };

  // ZAMAN ÇİZELGESİ: başlangıç süzgecinin haftası (yoksa bu hafta) + 4 hafta.
  const zcBas = haftaBasi(bas ? gun(bas) : new Date());
  const zcGunler = Array.from({ length: 28 }, (_, i) => gunEkle(zcBas, i));
  const zcSatirlar = useMemo(() => {
    const m = new Map<number, { ad: string; alt: string; ogeler: CalismaIstisnaSatiri[] }>();
    for (const s of satirlar.filter(x => x.durum !== 2)) {
      const r = m.get(s.hekimId) ?? { ad: s.hekim, alt: s.departman, ogeler: [] };
      r.ogeler.push(s); m.set(s.hekimId, r);
    }
    return [...m.values()].sort((a, b) => a.ad.localeCompare(b.ad, 'tr'));
  }, [satirlar]);
  const zcBasMs = zcBas.getTime();
  const sutun = (iso: string) => Math.round((gun(iso).getTime() - zcBasMs) / 864e5);

  const sayac = veri?.sayac;
  const ozet = veri?.ozet;

  return (
    <>
      <div className="sayfabas"><div className="basrow"><h1>{c('Çalışma İstisnaları')}</h1>
        <span className="yol">{c('Randevu › Ayarlar › Çalışma İstisnaları')} · {c('şablonu değiştirmeden planı ezen kayıtlar')}</span></div></div>
      <div className="cl-sayfa">
        <div className="cl-arac">
          {yazar && <button type="button" className="d bir" onClick={() => git('/calisma-istisna/yeni')}>＋ {c('Yeni İstisna')}</button>}
          <span className="cl-ayrac" />
          {([['0', 'Onay bekliyor', 'bekliyor'], ['1', 'Onaylı', 'onayli'], ['2', 'İptal', 'iptal'], ['tumu', 'Tümü', 'tumu']] as [Durum, string, keyof CalismaIstisnaListe['sayac']][]).map(([k, a, sk]) => (
            <button key={k} type="button" className={`ck-cip${durum === k ? ' on' : ''}${k === '0' && (sayac?.bekliyor ?? 0) > 0 ? ' bek' : ''}`}
                    onClick={() => { setDurum(k); setSecili(new Set()) }}>{c(a)} <b>{sayac?.[sk] ?? ''}</b></button>
          ))}
          <span className="cl-ayrac" />
          <span className="cl-gorunum">
            <button type="button" className={gorunum === 'liste' ? 'on' : ''} onClick={() => setGorunum('liste')}>☰ {c('Liste')}</button>
            <button type="button" className={gorunum === 'zaman' ? 'on' : ''} onClick={() => setGorunum('zaman')}>▬ {c('Zaman çizelgesi')}</button>
          </span>
          <input className="cl-ara" value={ara} placeholder={`🔍 ${c('Doktor / açıklama ara…')}`} onChange={e => setAra(e.target.value)} />
        </div>
        <div className="cl-arac cl-ikinci">
          <span className="sonuk">{c('Tür')}:</span>
          {[['', 'Tümü'], ['2', '🎓 Kongre / eğitim'], ['3', '🕘 Saat değişikliği'], ['4', '➕ Ek mesai'], ['5', '⛔ Kapalı'], ['ik', '🌴 İK izni']].map(([k, a]) => (
            <button key={k} type="button" className={`ck-cip${tur === k ? ' on' : ''}`} onClick={() => setTur(k)}>{c(a)}</button>
          ))}
          <span className="cl-ayrac" />
          <span className="sonuk">{c('Dönem')}:</span>
          {([['hafta', 'Bu hafta'], ['30', 'Önümüzdeki 30 gün'], ['gecmis', 'Geçmiş'], ['tumu', 'Tümü']] as [Donem, string][]).map(([k, a]) => (
            <button key={k} type="button" className={`ck-cip${donem === k ? ' on' : ''}`} onClick={() => donemSec(k)}>{c(a)}</button>
          ))}
          <input type="date" value={bas} onChange={e => { setBas(e.target.value); setDonem('tumu') }} />
          <span className="sonuk">–</span>
          <input type="date" value={bit} onChange={e => { setBit(e.target.value); setDonem('tumu') }} />
          <select value={departmanId} onChange={e => setDepartmanId(e.target.value ? Number(e.target.value) : '')}>
            <option value="">{c('Bölüm: Tümü')}</option>
            {bolumler.map(([k, a]) => <option key={k} value={k}>{a}</option>)}
          </select>
        </div>

        {ozet && (
          <div className="cl-ozetler">
            <button type="button" className={`cl-kpi${ozet.onayBekleyen ? ' dikkat' : ''}`} onClick={() => { setDurum('0'); donemSec('tumu') }}>
              <span className="k">{c('Onay bekleyen')}</span><span className="v">{ozet.onayBekleyen}</span>
              <span className="a">{ozet.onayBekleyen ? (ozet.enEskiGun > 0 ? `${c('en eskisi')} ${ozet.enEskiGun} ${c('gündür bekliyor')}` : c('bugün girildi')) : c('bekleyen yok')}</span></button>
            <button type="button" className={`cl-kpi${ozet.islemBekleyenRandevu ? ' kirmizi' : ''}`} onClick={() => { setDurum('tumu'); donemSec('30') }}>
              <span className="k">{c('İşlem bekleyen randevu')}</span><span className="v">{ozet.islemBekleyenRandevu}</span>
              <span className="a">{c('kapanan günlerde, aktarılmamış')}</span></button>
            <div className="cl-kpi"><span className="k">{c('Bugün izinli / kongrede')}</span><span className="v">{ozet.bugunYok.length} {c('doktor')}</span>
              <span className="a">{ozet.bugunYok.slice(0, 3).join(', ') || '—'}{ozet.bugunYok.length > 3 ? '…' : ''}</span></div>
            <div className="cl-kpi"><span className="k">{c('Önümüzdeki 30 gün')}</span><span className="v">{ozet.otuzGun} {c('kayıt')}</span>
              <span className="a">{Object.entries(ozet.otuzGunTur).map(([t, n]) => `${n} ${c(TURLER[Number(t)]?.[1] ?? '').toLocaleLowerCase('tr')}`).join(' · ') || '—'}</span></div>
          </div>
        )}

        {hata && <div className="hata-kutusu">{hata}</div>}

        {seciliSatirlar.length > 0 && (
          <div className="cl-toplu">☑ <b>{seciliSatirlar.length} {c('kayıt seçili')}</b>
            {seciliSatirlar.some(s => s.durum === 0) && <span className="sonuk">({seciliSatirlar.filter(s => s.durum === 0).length} {c('onay bekliyor')})</span>}
            {yazar && <button type="button" className="d ck-kucuk ok" disabled={!seciliSatirlar.some(s => s.durum === 0)} onClick={() => void topluCalistir('onayla')}>✔ {c('Seçilileri onayla')}</button>}
            {yazar && <button type="button" className="d ck-kucuk" disabled={!seciliSatirlar.some(s => s.durum !== 2)} onClick={() => void topluCalistir('iptal')}>✖ {c('İptal et')}</button>}
            <button type="button" className="cl-bag cl-sag" onClick={() => setSecili(new Set())}>{c('Seçimi kaldır')} ✕</button>
          </div>
        )}

        {gorunum === 'liste' ? (
          <div className="cl-tablo">
            <table className="cl-grid">
              <thead><tr>
                <th style={{ width: 28 }}><input type="checkbox" checked={tumu} disabled={isaretlenebilir.length === 0}
                                                  onChange={e => setSecili(e.target.checked ? new Set(isaretlenebilir.map(s => s.id)) : new Set())} /></th>
                <th>{c('Tür')}</th><th>{c('Doktor · Bölüm')}</th><th>{c('Tarih')}</th><th>{c('Saat')}</th>
                <th>{c('Etkilenen randevu')}</th><th>{c('Durum')}</th><th>{c('Açıklama')}</th><th>{c('Giren / Onaylayan')}</th>
              </tr></thead>
              <tbody>
                {satirlar.map(s => {
                  const [ic, ad, sinif] = TURLER[s.tur] ?? TURLER[1];
                  const ik = s.kaynak === 'ik';
                  const [dAd, dSinif] = DURUM[s.durum] ?? DURUM[0];
                  return (
                    <tr key={`${s.kaynak}${s.id}`} onDoubleClick={() => ac(s)}
                        className={`${ik ? 'ik ' : ''}${s.durum === 2 ? 'iptal ' : ''}${secili.has(s.id) && !ik ? 'secili' : ''}`}
                        title={ik ? c('İK izni - İzinler ekranından yönetilir') : c('Çift tık: istisna kartı')}>
                      <td>{ik ? <input type="checkbox" disabled title={c('İK izni burada düzenlenmez')} />
                        : <input type="checkbox" checked={secili.has(s.id)} onChange={e => setSecili(o => { const y = new Set(o); if (e.target.checked) y.add(s.id); else y.delete(s.id); return y })} />}</td>
                      <td><span className={`cl-tur ${sinif}`}>{ic} {c(ad)}</span></td>
                      <td><div className="cl-dr">{s.hekim}<small>{s.departman}{s.bolumSecili ? '' : ik ? '' : ` · ${c('tüm bölümler')}`}</small></div></td>
                      {tarihHucre(s)}
                      <td>{s.saatBas && s.saatBit ? <>{s.saatBas}–{s.saatBit}{s.tur === 4 && s.kanallar ? <span className="sonuk"> · {s.kanallar.split(',').map(k => ({ B: c('Banko'), P: c('Portal'), C: c('Çağrı') } as Record<string, string>)[k] ?? k).join(', ')}</span> : null}</> : c('gün boyu')}</td>
                      <td className="cl-etk">{etkHucre(s)}</td>
                      <td><span className={`rozet ${dSinif}`}>{c(dAd)}</span></td>
                      <td>{ik ? <>{s.ikTur}{s.aciklama ? ` · ${s.aciklama}` : ''} <button type="button" className="cl-bag sonuk" onClick={() => git('/personel-izin')}>· {c('İzinler ekranından yönetilir')} ↗</button></> : s.aciklama}</td>
                      <td className="cl-kim">{ik ? <>İK{s.izinNo ? ` · ${c('izin no')} ${s.izinNo}` : ''}</> : <>
                        {c('Giren')}: <b>{s.giren || '—'}</b> · {kisa(s.eklemeTarihi)}<br />
                        {c('Onaylayan')}: {s.onayTarihi ? <><b>{s.onaylayan || '—'}</b> · {kisa(s.onayTarihi)}</> : '—'}</>}</td>
                    </tr>
                  );
                })}
                {veri && satirlar.length === 0 && <tr><td colSpan={9} className="sonuk">{c('Kayıt yok.')}</td></tr>}
              </tbody>
            </table>
          </div>
        ) : (
          <div className="cl-zc">
            <div className="cl-zc-sat cl-zc-ust"><div />
              {[0, 1, 2, 3].map(h => <div key={h} className="hafta" style={{ gridColumn: `${2 + h * 7} / span 7` }}>
                {kisa(isoGun(zcGunler[h * 7]))}–{kisa(isoGun(zcGunler[h * 7 + 6]))}</div>)}
            </div>
            <div className="cl-zc-sat cl-zc-ust"><div />
              {zcGunler.map((g, i) => <div key={i} className={`${i % 7 >= 5 ? 'hs' : ''}${g.getTime() === bugunMs ? ' bugun' : ''}`}>{c(GUN_AD[i % 7]).slice(0, 1)}</div>)}
            </div>
            {zcSatirlar.map(r => (
              <div key={r.ad} className="cl-zc-sat">
                <div className="ad">{r.ad}<small>{r.alt}</small></div>
                {r.ogeler.map(s => {
                  const b = Math.max(0, sutun(s.bas)), e = Math.min(27, sutun(s.bit));
                  if (e < 0 || b > 27 || e < b) return null;
                  const [ic, ad, sinif] = TURLER[s.tur] ?? TURLER[1];
                  return (
                    <button key={`${s.kaynak}${s.id}`} type="button" className={`cub cl-tur ${sinif}${s.durum === 0 ? ' bekliyor' : ''}`}
                            style={{ gridColumn: `${2 + b} / span ${e - b + 1}`, gridRow: 1 }}
                            title={`${c(ad)} · ${aralik(s.bas, s.bit)}${s.aciklama ? ' · ' + s.aciklama : ''}${s.durum === 0 ? ' · ' + c('onay bekliyor') : ''}`}
                            onClick={() => ac(s)}>{ic}{e - b >= 1 ? ` ${c(ad)}` : ''}{e - b >= 3 && s.durum === 0 ? ` · ${c('onay bekliyor')}` : ''}</button>
                  );
                })}
              </div>
            ))}
            {zcSatirlar.length === 0 && <div className="sonuk" style={{ padding: 10 }}>{c('Bu süzgeçte kayıt yok.')}</div>}
            <div className="cl-lejant">{[1, 2, 3, 4, 5, 0].map(t => <span key={t} className={`cl-tur ${TURLER[t][2]}`}>{TURLER[t][0]} {c(TURLER[t][1])}</span>)}
              <span className="sonuk">{c('taralı çubuk = onay bekliyor')}</span></div>
          </div>
        )}
        <div className="cl-alt">{c('Kayıt')}: <b>{sayac?.tumu ?? 0}</b> · {c('gösterilen')} <b>{satirlar.length}</b> · {c('İK izinleri salt okunur listelenir')}
          <span className="cl-sag sonuk">{c('Çift tık: istisna kartı')}</span></div>
      </div>

      {kartAcik && (
        <CalismaIstisnaKarti key={id} id={id === 'yeni' ? 'yeni' : Number(id)}
          hekimId={Number(sorgu.get('hekimId')) || undefined}
          hekimSabit={sorgu.get('sabit') === '1' && !!Number(sorgu.get('hekimId'))}
          ilkTur={Number(sorgu.get('tur')) || undefined} ilkTarih={sorgu.get('tarih') ?? undefined}
          onKapat={kartKapat} />
      )}
    </>
  );
}
