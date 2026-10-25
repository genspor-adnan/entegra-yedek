import { useCallback, useContext, useEffect, useMemo, useRef, useState } from 'react';
import { useLocation, useNavigate, useParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { StokSayimSatiri, StokSayimYaniti } from '../../api/uclar/stok';
import { mesaj, onay } from '../../bilesenler/mesaj';
import { tarihSaat } from '../../bilesenler/bicim';
import { CiktiMenusu } from '../../bilesenler/cikti/CiktiMenusu';
import { StokAramaPenceresi } from '../../bilesenler/StokAramaPenceresi';
import { EkranSekmesiBaglami, LISTE_TAZELE_OLAYI } from '../../bilesenler/sekmeBaglami';
import { useOturum } from '../../kimlik/OturumBaglami';
import { c } from '../../dil/ceviri';
import { stil as icmalStili } from '../hasta/icmal/icmalStil';
import { SAYIM_A4_STILI, SayimA4 } from './SayimA4';

/**
 * STOK SAYIM KARTI (1169, sade sürüm - mockup Ekranlar/Stok/stok_sayim_karti_ver2.html).
 *
 * Kullanıcı (24.10.2026): Delphi'de sayım farkını Giriş / Çıkış fişi (tipi Sayım
 * Fazlası / Sayım Eksiği) keserek düzeltiyordu - bu ekran onun otomatik hali.
 * Sayılan miktar yazılır ya da okutulur; fark ve fişler SUNUCUDA hesaplanır,
 * istemci yalnız gösterir (fark tutarı = fark x satırın birim maliyeti).
 *
 *  - Sistem = sayım açıldığı andaki bakiye. Sayılmayan satıra dokunulmaz.
 *  - Lotlu stokta her lot ayrı satır; okutulan lotlu stokun birden çok satırı
 *    varsa artırılmaz, satırlar süzülür - lotu kullanıcı seçer.
 *  - "Farkları Fişle ve Kapat" en fazla iki fiş keser, sayım kapanır (salt okunur).
 */
const GOSTERIM_SINIRI = 400;

const sayi = (n: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: 3 });
const tl = (n: number) => n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const ayYil = (t: string | null) => t ? new Date(t).toLocaleDateString('tr-TR', { month: '2-digit', year: 'numeric' }) : '—';
const farkOf = (s: StokSayimSatiri) => s.sayilan == null ? null : s.sayilan - s.sistem;

type Suzgec = 'tumu' | 'sayilmadi' | 'fark';

export function StokSayimKartiSayfa() {
  const { id } = useParams();
  const git = useNavigate();
  const konum = useLocation();
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const kapat = () => { if (ekranSekmesi) ekranSekmesi.kapat(); else git('/stok-sayim') };
  useEffect(() => { ekranSekmesi?.baslik(c(id === 'yeni' ? 'Yeni Sayım' : 'Sayım'), konum.pathname) },
    [ekranSekmesi, konum.pathname, id]);
  if (id === 'yeni') return <YeniSayim onKapat={kapat} onAcildi={yeni => git(`/stok-sayim/${yeni}`, { replace: true })} />;
  const sayimId = Number(id);
  return sayimId > 0 ? <StokSayimKarti sayimId={sayimId} onKapat={kapat} /> : null;
}

// ------------------------------------------------------------ yeni sayım ----
function YeniSayim({ onKapat, onAcildi }: { onKapat(): void; onAcildi(id: number): void }) {
  const [depolar, setDepolar] = useState<{ id: number; ad: string; varsayilan: boolean }[]>([]);
  const [kategoriler, setKategoriler] = useState<{ id: number; ad: string }[]>([]);
  const [depoId, setDepoId] = useState(0);
  const [kapsam, setKapsam] = useState(0);
  const [kategoriId, setKategoriId] = useState(0);
  const [aciklama, setAciklama] = useState('');
  const [mesgul, setMesgul] = useState(false);

  useEffect(() => {
    void api.liste('depo', { sayfa: 1, boyut: 200, sirala: [{ alan: 'ad', yon: 'asc' }],
                             filtre: { alan: 'durum', op: 'esit', deger: 1 } })
      .then(y => {
        const d = y.satirlar.map(s => ({ id: Number(s.id), ad: String(s.ad ?? ''), varsayilan: Number(s.varsayilan ?? 0) === 1 }));
        setDepolar(d);
        setDepoId(o => o || (d.find(x => x.varsayilan) ?? d[0])?.id || 0);
      }).catch(() => setDepolar([]));
    void api.liste('kategori', { sayfa: 1, boyut: 1000, sirala: [{ alan: 'ad', yon: 'asc' }],
                                 filtre: { alan: 'tur', op: 'esit', deger: 1 } })
      .then(y => setKategoriler(y.satirlar.map(s => ({ id: Number(s.id), ad: String(s.ad ?? '') }))))
      .catch(() => setKategoriler([]));
  }, []);

  const ac = async () => {
    if (!depoId) { mesaj(c('Depo seçin.')); return }
    if (kapsam === 1 && !kategoriId) { mesaj(c('Kategori seçin.')); return }
    setMesgul(true);
    try {
      const y = await api.stokSayimAc({ depoId, kapsam, kategoriId: kapsam === 1 ? kategoriId : null, aciklama });
      window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'stok-sayim' }));
      onAcildi(y.id);
    } catch (e) { mesaj(hataMetni(e)) } finally { setMesgul(false) }
  };

  return (
    <div className="sahne ss">
      <div className="ss-bas">
        <div className="ss-avatar">🧮</div>
        <div className="ss-kim">
          <div className="ss-ad">{c('Yeni Stok Sayımı')}</div>
          <div className="ss-alt">{c('Sistem miktarları sayımı başlattığınız andaki depo bakiyesinden alınır.')}</div>
        </div>
        <div className="ss-islem"><button type="button" className="d" onClick={onKapat}>✖ {c('Kapat')}</button></div>
      </div>
      <div className="ss-alanlar">
        <label>{c('Depo')}</label>
        <select className="zorunlu" value={depoId} onChange={e => setDepoId(Number(e.target.value))}>
          {depolar.length === 0 && <option value={0}>—</option>}
          {depolar.map(d => <option key={d.id} value={d.id}>{d.ad}</option>)}
        </select>
        <label>{c('Açıklama')}</label>
        <input value={aciklama} maxLength={250} onChange={e => setAciklama(e.target.value)} placeholder={c('ör. Ekim sonu sayımı')} />
        <label>{c('Kapsam')}</label>
        <div className="ss-kapsam">
          {[[0, 'Tüm depo'], [1, 'Kategori'], [2, 'Seçili stoklar']].map(([k, ad]) => (
            <label key={k}><input type="radio" checked={kapsam === k} onChange={() => setKapsam(Number(k))} /> {c(String(ad))}</label>
          ))}
        </div>
        {kapsam === 1 ? <>
          <label>{c('Kategori')}</label>
          <select className="zorunlu" value={kategoriId} onChange={e => setKategoriId(Number(e.target.value))}>
            <option value={0}>— {c('seçin')} —</option>
            {kategoriler.map(k => <option key={k.id} value={k.id}>{k.ad}</option>)}
          </select>
        </> : <><span /><span className="ss-not">
          {kapsam === 0 ? c('Depodaki bütün aktif stoklar (stoğu 0 olanlar dahil); lotlu stokta her lot ayrı satır.')
                        : c('Liste boş açılır - okuttukça ya da "Stok Ekle" ile dolar.')}
        </span></>}
      </div>
      <div className="ss-dugmeler">
        <button type="button" className="d bir" disabled={mesgul} onClick={() => void ac()}>▶ {c('Sayımı Başlat')}</button>
      </div>
    </div>
  );
}

// ----------------------------------------------------------- sayım kartı ----
function StokSayimKarti({ sayimId, onKapat }: { sayimId: number; onKapat(): void }) {
  const { yetki, kullanici } = useOturum();
  const git = useNavigate();
  const [veri, setVeri] = useState<StokSayimYaniti | null>(null);
  const [hata, setHata] = useState('');
  const [suzgec, setSuzgec] = useState<Suzgec>('tumu');
  const [ara, setAra] = useState('');
  /** Okutulan lotlu stokun satırları (lot seçimi) - süzgeç yerine bunlar gösterilir. */
  const [lotSec, setLotSec] = useState<number[] | null>(null);
  const [okutMetni, setOkutMetni] = useState('');
  const [son, setSon] = useState('');
  const [stokAra, setStokAra] = useState(false);
  const [mesgul, setMesgul] = useState(false);
  /**
   * SON OKUTULAN SATIR (kullanıcı 24.10.2026: "stok ara ile 1 stok ekledim kapattım
   * sayım listeye gelmedi"): stok tüm-depo kapsamında zaten listedeydi, sayılanı
   * artmıştı ama satırı ekranın dışındaydı. Satır vurgulanır, görünür alana kayar,
   * gösterim sınırının dışındaysa da çizilir.
   */
  const [sonSatir, setSonSatir] = useState(0);
  const okutRef = useRef<HTMLInputElement>(null);
  const [antet, setAntet] = useState<Record<string, unknown> | null>(null);
  useEffect(() => { api.dokumAntet().then(a => setAntet(a.kurum)).catch(() => setAntet(null)) }, []);

  const yukle = useCallback(async () => {
    try { setVeri(await api.stokSayim(sayimId)); setHata('') } catch (e) { setHata(hataMetni(e)) }
  }, [sayimId]);
  useEffect(() => { void yukle() }, [yukle]);

  const acik = veri?.baslik.durum === 0;
  const degistirir = acik && yetki('stok.sayim', 'degistir');

  const ozet = useMemo(() => {
    const s = veri?.satirlar ?? [];
    let sayilan = 0, esit = 0, fazla = 0, eksik = 0, fazlaTl = 0, eksikTl = 0, sistemT = 0, sayilanT = 0;
    for (const x of s) {
      const f = farkOf(x);
      sistemT += x.sistem;
      if (f == null) continue;
      sayilan++; sayilanT += x.sayilan ?? 0;
      if (f === 0) esit++;
      else if (f > 0) { fazla++; fazlaTl += f * x.birimMaliyet }
      else { eksik++; eksikTl += f * x.birimMaliyet }
    }
    return { toplam: s.length, sayilan, esit, fazla, eksik, fazlaTl, eksikTl, sistemT, sayilanT };
  }, [veri]);

  const gorunen = useMemo(() => {
    const s = veri?.satirlar ?? [];
    if (lotSec) return s.filter(x => lotSec.includes(x.id));
    const q = ara.trim().toLocaleLowerCase('tr');
    return s.filter(x => {
      const f = farkOf(x);
      if (suzgec === 'sayilmadi' && f != null) return false;
      if (suzgec === 'fark' && (f == null || f === 0)) return false;
      return !q || x.stokAdi.toLocaleLowerCase('tr').includes(q) || x.stokKodu.toLocaleLowerCase('tr').includes(q)
        || x.lot.toLocaleLowerCase('tr').includes(q);
    });
  }, [veri, suzgec, ara, lotSec]);

  /** Çizilen satırlar: sınır + (dışında kaldıysa) son okutulan satır en üstte. */
  const cizilen = useMemo(() => {
    const ilk = gorunen.slice(0, GOSTERIM_SINIRI);
    const son = sonSatir && !ilk.some(x => x.id === sonSatir) ? gorunen.find(x => x.id === sonSatir) : undefined;
    return son ? [son, ...ilk] : ilk;
  }, [gorunen, sonSatir]);
  /**
   * İZLEMLİ STOK = ANA SATIR + AÇILAN LOT GRİDİ (kullanıcı 24.10.2026: "eğer izleme varsa belge
   * satırları gibi aşağı açılan izlem gridi olmalı"). Ana satır lotların toplamını gösterir;
   * sayılan lot satırına yazılır. Lot seçiminde (okutma) ve son okutulan lotun grubu açık gelir.
   */
  type Oge = { tip: 'tek'; s: StokSayimSatiri } | { tip: 'grup'; stokId: number; satirlar: StokSayimSatiri[] };
  const ogeler = useMemo(() => {
    const r: Oge[] = [];
    const yer = new Map<number, number>();
    for (const s of cizilen) {
      if (!s.izlemeAdi) { r.push({ tip: 'tek', s }); continue }
      const k = yer.get(s.stokId);
      if (k != null) (r[k] as Extract<Oge, { tip: 'grup' }>).satirlar.push(s);
      else { yer.set(s.stokId, r.length); r.push({ tip: 'grup', stokId: s.stokId, satirlar: [s] }) }
    }
    return r;
  }, [cizilen]);
  const [acikGrup, setAcikGrup] = useState<Set<number>>(() => new Set());
  const grupCevir = (stokId: number) => setAcikGrup(a => { const n = new Set(a); n.has(stokId) ? n.delete(stokId) : n.add(stokId); return n });

  useEffect(() => {
    if (!sonSatir) return;
    const s = veri?.satirlar.find(x => x.id === sonSatir);
    if (s?.izlemeAdi) setAcikGrup(a => a.has(s.stokId) ? a : new Set(a).add(s.stokId));
    // Grup açıldıktan sonra kaydır (bir sonraki çizimde satır DOM'da).
    setTimeout(() => document.querySelector(`.ss-grid tr[data-satir="${sonSatir}"]`)?.scrollIntoView?.({ block: 'nearest' }), 0);
  }, [sonSatir, cizilen, veri]);

  /** Tek satırı yerinde günceller (tüm kartı yeniden çekmeden). */
  const satirYaz = (satirId: number, sayilan: number | null) =>
    setVeri(v => v && { ...v, satirlar: v.satirlar.map(x => x.id === satirId ? { ...x, sayilan } : x) });

  const sayilanKaydet = async (satir: StokSayimSatiri, metin: string) => {
    const t = metin.trim().replace(/\./g, '').replace(',', '.');
    const deger = t === '' ? null : Number(t);
    // Değişmeyen değer yazılmaz - sisteme eşitlenmiş EKSİ lotsuz bakiye (ör. -30) hücreden geçerken uyarı vermesin.
    if (deger === satir.sayilan) return;
    if (deger != null && (!Number.isFinite(deger) || deger < 0)) { mesaj(c('Geçerli bir miktar girin.')); return }
    await sayilanYaz(satir, deger);
  };

  /** Sürmekte olan kayıtlar - "Kaydet (sonra devam)" kapatmadan önce bitmelerini bekler. */
  const bekleyen = useRef(new Set<Promise<unknown>>());
  const izle = <T,>(p: Promise<T>) => {
    bekleyen.current.add(p);
    // finally() zinciri p reddedilince yakalanmamış hata olurdu; hata p'den çağırana gider.
    p.finally(() => bekleyen.current.delete(p)).catch(() => {});
    return p;
  };

  const sayilanYaz = async (satir: StokSayimSatiri, deger: number | null) => {
    if (deger === satir.sayilan) return;
    try { await izle(api.stokSayimSayilan(satir.id, deger)); satirYaz(satir.id, deger) } catch (e) { mesaj(hataMetni(e)) }
  };

  /**
   * KAYDET (SONRA DEVAM) - kullanıcı 24.10.2026. Sayılan zaten hücreden çıkınca yazılır;
   * düğme açık hücreyi bırakıp bekleyen kayıtları bitirir ve kartı kapatır. Sayım AÇIK
   * kalır, listeden açılıp kalınan yerden sürdürülür.
   */
  const kaydetCik = async () => {
    (document.activeElement as HTMLElement | null)?.blur();
    setMesgul(true);
    try {
      await new Promise(r => setTimeout(r, 0));   // blur'un başlattığı kayıt kümeye girsin
      await Promise.allSettled([...bekleyen.current]);
      window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'stok-sayim' }));
      onKapat();
    } finally { setMesgul(false) }
  };

  const okut = async (g: { kod?: string; stokId?: number }) => {
    try {
      const y = await api.stokSayimOkut(sayimId, g);
      if (y.lotSec) {
        // Sunucu lot satırlarını YENİ eklemiş olabilir (seçili stoklar sayımı) - önce kartı tazele.
        if (y.satirIdleri.some(i => !veri?.satirlar.some(x => x.id === i))) await yukle();
        setLotSec(y.satirIdleri);
        setSon(`${y.stokAdi}: ${y.satirIdleri.length > 1 ? c('birden çok lot var - sayılanı ilgili lot satırına yazın')
                                                           : c('lotlu stok - sayılanı lot satırına yazın')}`);
        return;
      }
      setLotSec(null);
      if (y.eklendi) await yukle(); else satirYaz(y.satirId, y.sayilan);
      setSonSatir(y.satirId);
      setSon(`✔ ${y.stokAdi} · ${c('sayılan')} ${sayi(y.sayilan)}${y.eklendi ? ` (${c('listeye eklendi')})` : ` (${c('listede vardı, sayılanı arttı')})`}`);
    } catch (e) { setSon(''); mesaj(hataMetni(e)) }
  };

  const kapatFisle = async () => {
    if (!veri) return;
    const sayilmayan = ozet.toplam - ozet.sayilan;
    const metin = `${c('Farklar fişlenecek ve sayım kapanacak')}:\n`
      + `• ${c('Sayım Fazlası (Giriş Fişi)')}: ${ozet.fazla} ${c('kalem')}\n`
      + `• ${c('Sayım Eksiği (Çıkış Fişi)')}: ${ozet.eksik} ${c('kalem')}\n`
      + (sayilmayan > 0 ? `• ${sayilmayan} ${c('kalem sayılmadı - bunlara dokunulmaz.')}\n` : '')
      + c('Kapanan sayım değiştirilemez. Devam edilsin mi?');
    if (!await onay(metin)) return;
    setMesgul(true);
    try {
      const y = await api.stokSayimKapat(sayimId);
      window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'stok-sayim' }));
      await yukle();
      mesaj(y.fazlaKalem + y.eksikKalem === 0
        ? c('Fark yok - fiş kesilmedi, sayım kapandı.')
        : `${c('Sayım kapandı')}: ${y.fazlaKalem} ${c('fazla')}, ${y.eksikKalem} ${c('eksik kalem fişlendi.')}`
          + (y.uyarilar.length ? `\n${y.uyarilar.join('\n')}` : ''));
    } catch (e) { mesaj(hataMetni(e)) } finally { setMesgul(false) }
  };

  const sil = async () => {
    if (!await onay(c('Açık sayım ve girilen bütün sayılan miktarlar silinecek. Emin misiniz?'), true)) return;
    try {
      await api.stokSayimSil(sayimId);
      window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'stok-sayim' }));
      onKapat();
    } catch (e) { mesaj(hataMetni(e)) }
  };

  if (hata) return <div className="sahne ss"><div className="ss-uyari">{hata}</div><button type="button" className="d" onClick={onKapat}>✖ {c('Kapat')}</button></div>;
  if (!veri) return <div className="sahne ss"><div className="ss-not">{c('Yükleniyor…')}</div></div>;
  const b = veri.baslik;
  const kapsamAdi = b.kapsam === 0 ? c('Tüm depo') : b.kapsam === 1 ? `${c('Kategori')}: ${b.kategoriAdi}` : c('Seçili stoklar');

  return (
    <div className="sahne ss">
      <style>{icmalStili + SAYIM_A4_STILI}</style>
      <div className="ss-bas">
        <div className="ss-avatar">🧮</div>
        <div className="ss-kim">
          <div className="ss-ad">{b.sayimNo}
            <span className={`rozet ${acik ? 'mavi' : 'ok'}`}>{acik ? `● ${c('Açık')}` : `✔ ${c('Kapandı')}`}</span></div>
          <div className="ss-alt">{b.depoAdi} · {kapsamAdi} · {c('Sayım tarihi')} <b>{tarihSaat(b.sayimTarihi)}</b>
            {!acik && b.kapanisTarihi && <> · {c('Kapanış')} <b>{tarihSaat(b.kapanisTarihi)}</b></>}</div>
        </div>
        <div className="ss-islem">
          {degistirir && <button type="button" className="d bir" disabled={mesgul} onClick={() => void kaydetCik()}
                                 title={c('Girilenler kaydedilir, sayım açık kalır - listeden açıp devam edin')}>💾 {c('Kaydet (sonra devam)')}</button>}
          {degistirir && <button type="button" className="d onay" disabled={mesgul} onClick={() => void kapatFisle()}>✔ {c('Farkları Fişle ve Kapat')}</button>}
          <span className="hi-arac ss-cikti">
            <CiktiMenusu etiket={c('Sayım Listesi')} dosyaAdi={`Sayım Listesi ${b.sayimNo}`}>
              <SayimA4 v={veri} satirlar={gorunen} kapsamAdi={kapsamAdi} antet={antet} duzenleyen={kullanici?.ad ?? ''}
                       suzgecAdi={lotSec ? c('Lot seçimi') : suzgec === 'sayilmadi' ? c('Sayılmadı') : suzgec === 'fark' ? c('Fark var')
                         : ara.trim() ? `${c('Arama')}: ${ara.trim()}` : ''} />
            </CiktiMenusu>
          </span>
          {acik && yetki('stok.sayim', 'sil') && <button type="button" className="d" onClick={() => void sil()}>🗑 {c('Sil')}</button>}
          <button type="button" className="d" onClick={onKapat}>✖ {c('Kapat')}</button>
        </div>
      </div>

      <div className="ss-alanlar">
        <label>{c('Depo')}</label><div className="ss-k">{b.depoAdi}</div>
        <label>{c('Sayım Tarihi')}</label><div className="ss-k">{tarihSaat(b.sayimTarihi)}</div>
        <label>{c('Kapsam')}</label><div className="ss-k">{kapsamAdi}</div>
        <label>{c('Açıklama')}</label>
        {degistirir
          ? <input defaultValue={b.aciklama} maxLength={250}
                   onBlur={e => { if (e.target.value !== b.aciklama) void izle(api.stokSayimAciklama(sayimId, e.target.value)).catch(x => mesaj(hataMetni(x))) }} />
          : <div className="ss-k">{b.aciklama || '—'}</div>}
      </div>

      <div className="ss-ozet">
        <div><span>{c('Sayılan')}</span><b>{sayi(ozet.sayilan)} / {sayi(ozet.toplam)}</b>
          <div className="ss-bar"><i style={{ width: `${ozet.toplam ? (100 * ozet.sayilan) / ozet.toplam : 0}%` }} /></div>
          <small>{c('kalan')} {sayi(ozet.toplam - ozet.sayilan)} {c('kalem')}</small></div>
        <div><span>{c('Fark yok')}</span><b className="arti">{sayi(ozet.esit)}</b><small>{c('sistemle aynı')}</small></div>
        <div><span>{c('Fazla')}</span><b className="arti">{sayi(ozet.fazla)} {c('kalem')} · +{tl(ozet.fazlaTl)} ₺</b><small>{c('Sayım Fazlası giriş fişine')}</small></div>
        <div><span>{c('Eksik')}</span><b className="eksi">{sayi(ozet.eksik)} {c('kalem')} · {tl(ozet.eksikTl)} ₺</b><small>{c('Sayım Eksiği çıkış fişine')}</small></div>
      </div>

      {degistirir && (
        <div className="ss-okut">
          <form className="ss-okut-giris" onSubmit={e => { e.preventDefault(); const k = okutMetni.trim(); if (k) { void okut({ kod: k }); setOkutMetni('') } }}>
            ▦ <input ref={okutRef} autoFocus value={okutMetni} onChange={e => setOkutMetni(e.target.value)}
                     placeholder={c('Barkod okut ya da stok kodu yaz…')} /><kbd>Enter</kbd>
          </form>
          <button type="button" className="d" onClick={() => setStokAra(true)}>＋ {c('Stok Ekle')}</button>
          <div className="ss-son">{son}</div>
        </div>
      )}

      <div className="ss-filtre">
        {lotSec ? <>
          <span className="rozet sari">{c('Lot seçin')}</span>
          <button type="button" className="d" onClick={() => { setLotSec(null); okutRef.current?.focus() }}>✖ {c('Lot seçimini kapat')}</button>
        </> : <>
          {([['tumu', 'Tümü', ozet.toplam], ['sayilmadi', 'Sayılmadı', ozet.toplam - ozet.sayilan], ['fark', 'Fark var', ozet.fazla + ozet.eksik]] as const)
            .map(([k, ad, n]) => (
              <button key={k} type="button" className={`d${suzgec === k ? ' bir' : ''}`} onClick={() => setSuzgec(k)}>{c(ad)} {sayi(n)}</button>
            ))}
          <span className="ss-bosluk" />
          <input className="ss-ara" value={ara} onChange={e => setAra(e.target.value)} placeholder={`🔍 ${c('Stok ara…')}`} />
        </>}
      </div>

      <div className="ss-grid">
        <table>
          <thead><tr>
            <th>{c('Stok Kodu')}</th><th>{c('Stok Adı')}</th><th>{c('Birim')}</th><th>{c('İzleme')}</th>
            <th className="sag">{c('Sistem')}</th><th className="sag">{c('Sayılan')}</th><th className="sag">{c('Fark')}</th>
            <th className="sag">{c('Birim Maliyet')}</th><th className="sag">{c('Fark ₺')}</th>
          </tr></thead>
          <tbody>
            {(() => {
              // Sayılan kutularının sırası (Enter / Tab / ↑↓ geçişi) yalnız ÇİZİLEN kutular üzerinden.
              let sira = 0;
              const satirTr = (s: StokSayimSatiri, lotSatiri: boolean) => {
                const i = sira++;
                const f = farkOf(s);
                const renk = f == null || f === 0 ? 'soluk' : f > 0 ? 'arti' : 'eksi';
                return (
                  <tr key={s.id} data-satir={s.id}
                      className={[f == null ? 'sayilmadi' : f !== 0 ? 'farkli' : '', s.id === sonSatir ? 'ss-son-satir' : '',
                                  lotSatiri ? 'ss-lot' : ''].join(' ')}>
                    {/* LOT / SKT KOLONU YOK (kullanıcı 24.10.2026): lot bilgisi açılan lot satırında,
                        stok adı hücresinde yazar. */}
                    {lotSatiri
                      ? <><td className="ss-lot-ok">└</td>
                          <td>{s.lot ? <>{c('Lot')} <b>{s.lot}</b></> : <span className="soluk">{c('lotsuz bakiye')}</span>}
                            {s.skt && <span className="soluk"> · SKT {ayYil(s.skt)}</span>}</td>
                          <td /><td /></>
                      : <><td>{s.stokKodu}</td><td>{s.stokAdi}</td><td>{s.birim}</td>
                          <td><span className="soluk">—</span></td></>}
                    {/* SİSTEME TIK = SAYILAN (kullanıcı 24.10.2026): rafta sistemdeki kadar varsa
                        aynı sayıyı elle yazmaya gerek kalmasın. Negatif bakiye sayılan olamaz. */}
                    <td className={`sag${degistirir && s.sistem >= 0 ? ' ss-sistem' : ''}`}
                        title={degistirir && s.sistem >= 0 ? c('Tıkla: sayılan = sistem') : undefined}
                        onClick={degistirir && s.sistem >= 0 ? () => { setSonSatir(s.id); void sayilanYaz(s, s.sistem) } : undefined}>
                      {sayi(s.sistem)}</td>
                    <td className="sag ss-giris">
                      {degistirir
                        ? <input key={`${s.id}-${s.sayilan}`} data-sira={i} defaultValue={s.sayilan == null ? '' : String(s.sayilan).replace('.', ',')}
                                 placeholder="—" inputMode="decimal"
                                 onFocus={e => e.target.select()}
                                 onBlur={e => void sayilanKaydet(s, e.target.value)}
                                 /* SATIRLAR ARASI (kullanıcı 24.10.2026): Enter / Tab / ↓ alttaki,
                                    Shift+Tab / ↑ üstteki sayılan kutusuna geçer (kayıt blur'da). */
                                 onKeyDown={e => {
                                   const geri = e.key === 'ArrowUp' || (e.key === 'Tab' && e.shiftKey);
                                   const ileri = e.key === 'Enter' || e.key === 'ArrowDown' || (e.key === 'Tab' && !e.shiftKey);
                                   if (!geri && !ileri) return;
                                   const hedef = document.querySelector<HTMLInputElement>(`.ss-grid input[data-sira="${i + (geri ? -1 : 1)}"]`);
                                   if (!hedef) { if (e.key === 'Enter') { e.preventDefault(); (e.target as HTMLInputElement).blur() } return }
                                   e.preventDefault();
                                   hedef.focus();
                                 }} />
                        : (s.sayilan == null ? '—' : sayi(s.sayilan))}
                    </td>
                    <td className={`sag ${renk}`}>{f == null ? '' : `${f > 0 ? '+' : ''}${sayi(f)}`}</td>
                    <td className="sag">{tl(s.birimMaliyet)}</td>
                    <td className={`sag ${renk}`}>{f ? tl(f * s.birimMaliyet) : ''}</td>
                  </tr>
                );
              };

              return ogeler.map(o => {
                if (o.tip === 'tek') return satirTr(o.s, false);
                const ilk = o.satirlar[0];
                const acik = !!lotSec || acikGrup.has(o.stokId);
                const sayilmis = o.satirlar.filter(x => x.sayilan != null);
                const sistemT = o.satirlar.reduce((t, x) => t + x.sistem, 0);
                const sayilanT = sayilmis.reduce((t, x) => t + (x.sayilan ?? 0), 0);
                const farkT = sayilmis.reduce((t, x) => t + ((x.sayilan ?? 0) - x.sistem), 0);
                const farkTl = sayilmis.reduce((t, x) => t + ((x.sayilan ?? 0) - x.sistem) * x.birimMaliyet, 0);
                const renk = sayilmis.length === 0 || farkT === 0 ? 'soluk' : farkT > 0 ? 'arti' : 'eksi';
                const doldurulabilir = degistirir && o.satirlar.every(x => x.sistem >= 0);
                return [
                  <tr key={`g${o.stokId}`} className={['ss-ana', sayilmis.length === 0 ? 'sayilmadi' : farkT !== 0 ? 'farkli' : ''].join(' ')}>
                    <td>{ilk.stokKodu}</td><td>{ilk.stokAdi}</td><td>{ilk.birim}</td>
                    {/* AÇMA OKU İZLEME SÜTUNUNDA (kullanıcı 24.10.2026). */}
                    <td>
                      <button type="button" className="ss-ac" aria-expanded={acik} onClick={() => grupCevir(o.stokId)}
                              title={acik ? c('Lotları gizle') : c('Lotları göster')}>
                        {acik ? '▾' : '▸'} <span className="rozet bilgi" style={{ whiteSpace: 'nowrap' }}>{ilk.izlemeAdi}</span>
                        {' '}<span className="soluk">{o.satirlar.length} {c('lot')}
                          {sayilmis.length > 0 && sayilmis.length < o.satirlar.length && <> · {sayilmis.length} {c('sayıldı')}</>}</span>
                      </button>
                    </td>
                    {/* Ana satırda sisteme tık: BÜTÜN lotlar sistemdeki kadar sayılır. */}
                    <td className={`sag${doldurulabilir ? ' ss-sistem' : ''}`}
                        title={doldurulabilir ? c('Tıkla: bütün lotlarda sayılan = sistem') : undefined}
                        onClick={doldurulabilir ? () => { setAcikGrup(a => new Set(a).add(o.stokId)); o.satirlar.forEach(x => void sayilanYaz(x, x.sistem)) } : undefined}>
                      {sayi(sistemT)}</td>
                    <td className="sag"><b>{sayilmis.length ? sayi(sayilanT) : '—'}</b></td>
                    <td className={`sag ${renk}`}>{sayilmis.length && farkT ? `${farkT > 0 ? '+' : ''}${sayi(farkT)}` : ''}</td>
                    <td className="sag">{tl(ilk.birimMaliyet)}</td>
                    <td className={`sag ${renk}`}>{farkTl ? tl(farkTl) : ''}</td>
                  </tr>,
                  ...(acik ? o.satirlar.map(x => satirTr(x, true)) : []),
                ];
              });
            })()}
          </tbody>
          <tfoot><tr>
            <td colSpan={4}>{sayi(ozet.toplam)} {c('satır')} · {sayi(ozet.sayilan)} {c('sayıldı')}</td>
            <td className="sag">{sayi(ozet.sistemT)}</td><td className="sag">{sayi(ozet.sayilanT)}</td><td />
            <td /><td className={`sag ${ozet.fazlaTl + ozet.eksikTl < 0 ? 'eksi' : 'arti'}`}>{tl(ozet.fazlaTl + ozet.eksikTl)}</td>
          </tr></tfoot>
        </table>
        {gorunen.length > GOSTERIM_SINIRI && (
          <div className="ss-not">{c('İlk')} {GOSTERIM_SINIRI} / {sayi(gorunen.length)} {c('satır gösteriliyor - aramayla daraltın.')}</div>
        )}
      </div>

      <div className="ss-fisler">
        <div className="ss-fis g">
          <h5>⬆ {c('Giriş Fişi · tip Sayım Fazlası')}<span className="rozet ok">{sayi(ozet.fazla)} {c('kalem')} · +{tl(ozet.fazlaTl)} ₺</span></h5>
          {b.girisBelgeId
            ? <a href="#" onClick={e => { e.preventDefault(); git(`/giris-fis/${b.girisBelgeId}`) }}>{c('Fiş')} {b.girisBelgeNo} →</a>
            : <small>{c('Tarih = sayım tarihi · açıklama')} "{b.sayimNo} {c('sayım farkı')}" · {c('lot bazında')}.</small>}
        </div>
        <div className="ss-fis c">
          <h5>⬇ {c('Çıkış Fişi · tip Sayım Eksiği')}<span className="rozet hata">{sayi(ozet.eksik)} {c('kalem')} · {tl(ozet.eksikTl)} ₺</span></h5>
          {b.cikisBelgeId
            ? <a href="#" onClick={e => { e.preventDefault(); git(`/cikis-fis/${b.cikisBelgeId}`) }}>{c('Fiş')} {b.cikisBelgeNo} →</a>
            : <small>{c('Sayılan lottan düşer · maliyet ortalama maliyetten.')}</small>}
        </div>
      </div>

      {acik && ozet.toplam - ozet.sayilan > 0 && (
        <div className="ss-uyari">{sayi(ozet.toplam - ozet.sayilan)} {c('kalem sayılmadı. Sayılmayan kaleme dokunulmaz (fark yazılmaz). Rafta hiç olmayan kalemi sıfırlamak için sayılan hücresine 0 yazın.')}</div>
      )}

      {stokAra && (
        <StokAramaPenceresi etkin yalnizStok onKapat={() => { setStokAra(false); okutRef.current?.focus() }}
          onSec={s => void okut({ stokId: Number(s.id) })} />
      )}
    </div>
  );
}
