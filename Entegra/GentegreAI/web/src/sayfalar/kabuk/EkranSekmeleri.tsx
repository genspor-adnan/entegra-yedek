import { useEffect, useRef, useState } from 'react';
import { NavigationType, UNSAFE_LocationContext, type Location } from 'react-router-dom';
import { EkranSekmesiBaglami, SekmeGorunurBaglami } from '../../bilesenler/sekmeBaglami';
import { PALET_AC_OLAYI } from '../Baslangic';
import { menuYolu, yolEslesir } from '../../bilesenler/taleplerim/personelTalebi';
import { c } from '../../dil/ceviri';
import { MenuIkon, type MenuSatiri } from './menuAgaci';

/**
 * EKRAN SEKMELERİ (ana ekran v3, mockup Ekranlar/Ayarlar/ana_ekran_sekmeli_v3.html).
 *
 * Açılan her ekran üstte sekme olur ve CANLI kalır: sekmeye dönünce ekran (açık
 * kart, kaydedilmemiş değişiklik, kaydırma) kaldığı yerdedir. Gizli sekme kendi
 * adresini görmeye devam eder (LocationContext dondurulur) - başka sekmenin
 * adresine tepki vermez; penceresi görünmez ve Esc almaz (SekmeGorunurBaglami).
 *
 *  - Sekme anahtarı MENÜ ÖĞESİDİR: aynı ekran ikinci sekme açmaz, karttan
 *    karta geçiş aynı sekmede kalır. Menüde olmayan yol kendi adresiyle sekmedir.
 *  - Başlangıç (/panel) sabit, kapanmaz.
 *  - En fazla SEKME_SINIRI sekme: aşınca en uzun süredir bakılmayan kapanır, söylenir.
 */
export const SEKME_SINIRI = 8;
const BASLANGIC = '/panel';

interface Sekme { anahtar: string; baslik: string; ikon: string; konum: Location; erisim: number;
                 /** Kart sekmesinin listesi (kartYolu): sekme listenin HEMEN YANINDA açılır. */
                 ust?: string }

const SEKME_TAKMA: Record<string, string> = { '/cari-ekstre': '/ekstre', '/hesap-ekstre': '/ekstre', '/cari-devir': '/devir' };

function sekmeBul(satirlar: MenuSatiri[], konum: Location, ek?: Record<string, { ad: string; ikon: string }>,
                  kartSekmeleri?: Record<string, { ad: string; ikon: string }>) {
  // KART KENDİ SEKMESİNDE (liste tanımı yeniSekmede): "/hasta/yeni" ve "/hasta/123" ayrı
  //   sekme; yeni kayıt tanımdaki başlıkla, kayıtlı kart (ad kart yüklenince gelir) "Kart".
  // KART İKONU = LİSTENİN İKONU (kullanıcı 23.10.2026: "sekmelerde kart logoları o kartla ilgili
  //   listenin ikonu ile aynı olsun"): yeni kayıt da kayıtlı kart da listenin ikonunu taşır.
  for (const [kartYolu, { ad: yeniBaslik, ikon }] of Object.entries(kartSekmeleri ?? {})) {
    const kalan = konum.pathname.startsWith(kartYolu + '/') ? konum.pathname.slice(kartYolu.length + 1) : '';
    const m = kalan && !kalan.includes('/') ? [kalan, kalan] : null;
    // TEK KART SEKMESİ (kullanıcı: "tek hasta kartı açık olsun.. yeni hasta tıklandığında diğerini
    //   kapatıp yerine bunu koysun"): anahtar listenin kart sekmesidir, kaydın kendisi değil -
    //   başka kart açılınca aynı sekme, aynı yerde yeni kartla dolar.
    if (m) return m[1] === 'yeni' ? { anahtar: `${kartYolu}#kart`, baslik: yeniBaslik, ikon, ust: kartYolu }
                                   : { anahtar: `${kartYolu}#kart`, baslik: 'Kart', ikon, ust: kartYolu };
  }
  // ESKİ EKSTRE YOLLARI (1158): /cari-ekstre ve /hesap-ekstre /ekstre'ye yönlenir - yönlendirme
  //   anındaki sekme de Ekstre sekmesi sayılsın; yoksa boş bir "Hesap Ekstresi" sekmesi kalıyordu.
  const yol = SEKME_TAKMA[konum.pathname] ?? menuYolu(konum.pathname, konum.state);
  if (yol === '/' || yolEslesir(yol, BASLANGIC)) return { anahtar: BASLANGIC, baslik: 'Başlangıç', ikon: '🏠' };
  // Menüde olmayan bilinen ekran (gösterge paneli) kendi adıyla.
  if (ek?.[konum.pathname]) return { anahtar: konum.pathname, baslik: ek[konum.pathname].ad, ikon: ek[konum.pathname].ikon };
  const hepsi = satirlar.flatMap(s => (s.tur === 'duz' ? [s.m] : s.alt));
  const m = hepsi.filter(x => yolEslesir(yol, x.yol.split('?')[0])).sort((a, b) => b.yol.length - a.yol.length)[0];
  return m ? { anahtar: m.yol.split('?')[0], baslik: m.ad, ikon: m.ic }
           : { anahtar: konum.pathname, baslik: konum.pathname.replace(/^\//, ''), ikon: '▫' };
}

/**
 * AÇIK SEKMELER F5'TE GERİ GELİR (kullanıcı 15.10.2026: "F5 ile refresh yaptım liste kayboldu ama
 * reçete kartı kaldı"): sekme listesi (adres, başlık, ikon) ve ekranların verdiği başlıklar tarayıcı
 * OTURUMUNDA saklanır - sekme / tarayıcı kapanınca sıfırlanır. Geri gelen sekmenin ekranı ilk
 * tıklamada kurulur. Depolama kapalıysa eski davranış (yalnız adresteki sekme).
 */
const DEPO_ANAHTARI = 'gentegre.ekranSekmeleri';
type SakliSekme = Omit<Sekme, 'konum'> & { konum: Pick<Location, 'pathname' | 'search'> };
function sekmeleriOku(): { sekmeler: Sekme[]; basliklar: Record<string, string> } {
  try {
    const d = JSON.parse(sessionStorage.getItem(DEPO_ANAHTARI) ?? 'null') as
      { sekmeler?: SakliSekme[]; basliklar?: Record<string, string> } | null;
    return {
      sekmeler: (d?.sekmeler ?? []).map(x => ({ ...x, erisim: x.erisim || 0,
        konum: { pathname: x.konum.pathname, search: x.konum.search ?? '', hash: '', state: null, key: 'sakli' } })),
      basliklar: d?.basliklar ?? {},
    };
  } catch { return { sekmeler: [], basliklar: {} } }
}
function sekmeleriYaz(sekmeler: Sekme[], basliklar: Record<string, string>) {
  try {
    const yollar = new Set(sekmeler.map(x => x.konum.pathname));
    sessionStorage.setItem(DEPO_ANAHTARI, JSON.stringify({
      sekmeler: sekmeler.map(x => ({ anahtar: x.anahtar, baslik: x.baslik, ikon: x.ikon, ust: x.ust, erisim: x.erisim,
                                     konum: { pathname: x.konum.pathname, search: x.konum.search } })),
      // Yalnız açık sekmelerin başlıkları (kapanan kartların adları birikmesin).
      basliklar: Object.fromEntries(Object.entries(basliklar).filter(([y]) => yollar.has(y))),
    }));
  } catch { /* depolama kapalı */ }
}

export function useEkranSekmeleri({ satirlar, konum, navTuru, outlet, git, ekBasliklar, kartSekmeleri }: {
  satirlar: MenuSatiri[];
  /** Menüde olmayan ekranların sekme başlığı (yol -> ad, ikon). */
  ekBasliklar?: Record<string, { ad: string; ikon: string }>;
  /** Kartı kendi sekmesinde açılan listeler: kartYolu -> yeni kayıt sekme başlığı. */
  kartSekmeleri?: Record<string, { ad: string; ikon: string }>;
  konum: Location;
  navTuru: NavigationType;
  outlet: React.ReactNode;
  git(yol: string, secenek?: { state?: unknown; replace?: boolean }): void;
}) {
  const [ilk] = useState(sekmeleriOku);
  const [sekmeler, setSekmeler] = useState<Sekme[]>(ilk.sekmeler);
  const [bildirim, setBildirim] = useState('');
  /** Her sekmenin SON çizilen ekranı (gizliyken bu çizilir - durum korunur). */
  const ekranlar = useRef(new Map<string, React.ReactNode>());

  const simdiki = sekmeBul(satirlar, konum, ekBasliklar, kartSekmeleri);
  /** Ekranın kendisinin verdiği sekme başlığı (ör. hasta kartında hastanın adı). */
  const [ozelBaslik, setOzelBaslik] = useState<Record<string, string>>(ilk.basliklar);
  useEffect(() => { sekmeleriYaz(sekmeler, ozelBaslik) }, [sekmeler, ozelBaslik]);
  // Başlık ADRESE bağlı: tek kart sekmesinde başka kart açılınca eski hastanın adı kalmaz.
  const ad = (s: { baslik: string; konum: Location }) => ozelBaslik[s.konum.pathname] ?? s.baslik;
  /** Kart sekmelerinin "kayıtsız değişiklik var mı" sorusu (bkz. kartaGit). */
  const kirliler = useRef(new Map<string, () => boolean>());
  ekranlar.current.set(simdiki.anahtar, outlet);

  // Adres değişince sekme açılır / güncellenir; sınır aşılırsa en eskisi kapanır.
  useEffect(() => {
    setSekmeler(onceki => {
      const var_ = onceki.find(s => s.anahtar === simdiki.anahtar);
      let yeni: Sekme[];
      if (var_) yeni = onceki.map(s => s.anahtar === simdiki.anahtar ? { ...s, ...simdiki, konum, erisim: Date.now() } : s);
      else {
        // KART SEKMESİ listesinin hemen yanına (kullanıcı: "hasta kartı hemen yanına yeni sekme
        //   olarak açılacak"); liste yoksa sona. Diğer ekranlar sona.
        const yeniSekme: Sekme = { ...simdiki, konum, erisim: Date.now() };
        const listeI = simdiki.ust ? onceki.findIndex(s => s.anahtar === simdiki.ust) : -1;
        yeni = listeI >= 0 ? [...onceki.slice(0, listeI + 1), yeniSekme, ...onceki.slice(listeI + 1)] : [...onceki, yeniSekme];
      }
      const kapanabilir = yeni.filter(s => s.anahtar !== BASLANGIC);
      if (kapanabilir.length > SEKME_SINIRI) {
        const eski = kapanabilir.filter(s => s.anahtar !== simdiki.anahtar).sort((a, b) => a.erisim - b.erisim)[0];
        yeni = yeni.filter(s => s !== eski);
        ekranlar.current.delete(eski.anahtar);
        setBildirim(`${SEKME_SINIRI} ${c('sekme sınırı')}: "${c(eski.baslik)}" ${c('kapatıldı (en uzun süredir bakılmayan).')}`);
      }
      return yeni;
    });
  // YALNIZ ADRES DEĞİŞİNCE: menü satırları her çizimde yeniden kurulur, bağımlılık
  //   olsa effect her çizimde çalışıp döngüye girerdi.
  //   Adres de bağımlılıkta: geçmişe dışarıdan yazılan girişlerin anahtarı aynı olabilir.
  }, [konum.key, konum.pathname, konum.search]);   // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (!bildirim) return;
    const t = setTimeout(() => setBildirim(''), 4000);
    return () => clearTimeout(t);
  }, [bildirim]);

  // Çizilecek liste: ilk çizimde geçerli sekme henüz state'te yoksa SONA eklenir
  //   (effect ekleyince yeri değişmez - ekran yeniden kurulmaz).
  //   BAŞLANGIÇ (🏠) HER ZAMAN EN SOLDA (kullanıcı 14.10.2026) - sonradan açılsa da.
  const liste = (sekmeler.some(s => s.anahtar === simdiki.anahtar)
    ? sekmeler : [...sekmeler, { ...simdiki, konum, erisim: Date.now() }])
    .slice().sort((a, b) => Number(b.anahtar === BASLANGIC) - Number(a.anahtar === BASLANGIC));
  const baslangicVar = liste.some(s => s.anahtar === BASLANGIC);

  const ac = (s: Sekme) => git(s.konum.pathname + s.konum.search, { state: s.konum.state });
  /**
   * SEKME × = EKRANIN KAPAT DÜĞMESİ (kullanıcı): ekran bir kapatma işleyicisi verdiyse (kart:
   * kayıtsız değişiklik varsa "kaydedilsin mi?") o çalışır; sekme işleyici kapatınca kapanır.
   * Arka sekmede soru görünmez - önce o sekme öne alınır.
   */
  const kapatIsleyicileri = useRef(new Map<string, () => void>());
  const kapatIste = (anahtar: string) => {
    const f = kapatIsleyicileri.current.get(anahtar);
    if (!f) { kapat(anahtar); return }
    const s = liste.find(x => x.anahtar === anahtar);
    if (s && anahtar !== simdiki.anahtar) { ac(s); setTimeout(f, 50) } else f();
  };
  /**
   * KARTA GİT - KİRLİ KART KORUNUR (tek kart sekmesi, "yerine bunu koysun"): açık kartta kayıtsız
   * değişiklik varken aynı kart sekmesine başka kayıt AÇILMAZ - o kart öne alınır, kullanıcı
   * uyarılır. Gezinmeden ÖNCE sorulur: gelen adresle kart yeniden çizilirse değişiklik kaybolurdu.
   */
  const kartaGit = (yol: string) => {
    const [yolu, sorgu = ''] = yol.split('?');
    const hedef = sekmeBul(satirlar, { pathname: yolu, search: sorgu ? `?${sorgu}` : '', hash: '', state: null, key: '' },
                           ekBasliklar, kartSekmeleri);
    const s = liste.find(x => x.anahtar === hedef.anahtar);
    if (s && hedef.ust && s.konum.pathname !== yolu && kirliler.current.get(s.anahtar)?.()) {
      ac(s);
      setBildirim(c('Açık kartta kaydedilmemiş değişiklik var - önce kaydedin ya da kapatın.'));
      return;
    }
    git(yol);
  };
  const kapat = (anahtar: string, hedef?: string) => {
    kapatIsleyicileri.current.delete(anahtar);
    if (anahtar === BASLANGIC) return;
    const i = liste.findIndex(s => s.anahtar === anahtar);
    ekranlar.current.delete(anahtar);
    setSekmeler(o => o.filter(s => s.anahtar !== anahtar));
    if (hedef) { git(hedef); return }
    if (anahtar === simdiki.anahtar) {
      const komsu = liste.filter(s => s.anahtar !== anahtar)[Math.max(0, i - 1)];
      if (komsu) ac(komsu); else git(BASLANGIC);
    }
  };

  // KISAYOLLAR: Alt+W sekmeyi kapat (Ctrl+W tarayıcının), Ctrl+1..9 sekmeye git, Ctrl+Home başlangıç.
  useEffect(() => {
    const tus = (e: KeyboardEvent) => {
      if (e.altKey && e.key.toLowerCase() === 'w') { e.preventDefault(); kapatIste(simdiki.anahtar) }
      else if (e.ctrlKey && e.key === 'Home') { e.preventDefault(); git(BASLANGIC) }
      else if (e.ctrlKey && !e.shiftKey && /^[1-9]$/.test(e.key)) {
        const s = liste[Number(e.key) - 1]; if (s) { e.preventDefault(); ac(s) }
      }
    };
    window.addEventListener('keydown', tus);
    return () => window.removeEventListener('keydown', tus);
  });

  const cubuk = (
    <div className="ekran-sekmeleri" role="tablist">
      {!baslangicVar && (
        <div className="es-sekme es-ev" role="tab" title={c('Başlangıç (Ctrl+Home)')} onClick={() => git(BASLANGIC)}>🏠</div>
      )}
      {liste.map(s => (
        <div key={s.anahtar} role="tab" aria-selected={s.anahtar === simdiki.anahtar}
             className={`es-sekme${s.anahtar === simdiki.anahtar ? ' on' : ''}${s.anahtar === BASLANGIC ? ' es-ev' : ''}`}
             title={c(ad(s))}
             onClick={() => ac(s)}
             onAuxClick={e => { if (e.button === 1) { e.preventDefault(); kapatIste(s.anahtar) } }}>
          {/* Menüdeki ikonun AYNISI: '@icmal' ve yüklenen görsel ikonlar metin değil (sekmede "@icmal" yazıyordu). */}
          <span className="es-ikon">{s.ikon.startsWith('@') || s.ikon.startsWith('data:image/') ? <MenuIkon ic={s.ikon} /> : s.ikon}</span>
          {s.anahtar !== BASLANGIC && <span className="es-ad">{c(ad(s))}</span>}
          {s.anahtar !== BASLANGIC && (
            <span className="es-x" title={c('Kapat (Alt+W)')}
                  onClick={e => { e.stopPropagation(); kapatIste(s.anahtar) }}>×</span>
          )}
        </div>
      ))}
      {/* ＋ (kullanıcı): sekmelerin sağında - arama (komut paleti) açılır. */}
      <span className="es-sekme es-ekle" role="button" title={c('Ekran aç / yeni işlem (Ctrl+K)')}
            onClick={() => window.dispatchEvent(new Event(PALET_AC_OLAYI))}>＋</span>
      <span className="es-sayi">{liste.filter(s => s.anahtar !== BASLANGIC).length} / {SEKME_SINIRI}</span>
      {bildirim && <div className="es-bildirim">{bildirim}</div>}
    </div>
  );

  const govde = liste.map(s => {
    const aktif = s.anahtar === simdiki.anahtar;
    return (
      <div key={s.anahtar} className="es-govde" hidden={!aktif}>
        <SekmeGorunurBaglami.Provider value={aktif}>
         <EkranSekmesiBaglami.Provider value={{
           kapat: hedef => kapat(s.anahtar, hedef),
           kartaGit,
           kapatmaIsleyicisi: (f, kirli) => {
             if (f) kapatIsleyicileri.current.set(s.anahtar, f); else kapatIsleyicileri.current.delete(s.anahtar);
             if (f && kirli) kirliler.current.set(s.anahtar, kirli); else kirliler.current.delete(s.anahtar);
           },
           // Yol ÇAĞIRANDAN: kart yüklenirken sekmenin kayıtlı adresi henüz eski olabilir.
           baslik: (b, yol) => setOzelBaslik(o => (o[yol] === b ? o : { ...o, [yol]: b })) }}>
          <UNSAFE_LocationContext.Provider
            value={{ location: aktif ? konum : s.konum, navigationType: aktif ? navTuru : NavigationType.Pop }}>
            {aktif ? outlet : ekranlar.current.get(s.anahtar)}
          </UNSAFE_LocationContext.Provider>
         </EkranSekmesiBaglami.Provider>
        </SekmeGorunurBaglami.Provider>
      </div>
    );
  });

  return { cubuk, govde, kartaGit };
}
