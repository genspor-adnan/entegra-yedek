import { useEffect, useRef, useState } from 'react';
import { NavigationType, UNSAFE_LocationContext, type Location } from 'react-router-dom';
import { SekmeGorunurBaglami } from '../../bilesenler/sekmeBaglami';
import { menuYolu, yolEslesir } from '../../bilesenler/taleplerim/personelTalebi';
import { c } from '../../dil/ceviri';
import type { MenuSatiri } from './menuAgaci';

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

interface Sekme { anahtar: string; baslik: string; ikon: string; konum: Location; erisim: number }

function sekmeBul(satirlar: MenuSatiri[], konum: Location) {
  const yol = menuYolu(konum.pathname, konum.state);
  if (yol === '/' || yolEslesir(yol, BASLANGIC)) return { anahtar: BASLANGIC, baslik: 'Başlangıç', ikon: '🏠' };
  const hepsi = satirlar.flatMap(s => (s.tur === 'duz' ? [s.m] : s.alt));
  const m = hepsi.filter(x => yolEslesir(yol, x.yol.split('?')[0])).sort((a, b) => b.yol.length - a.yol.length)[0];
  return m ? { anahtar: m.yol.split('?')[0], baslik: m.ad, ikon: m.ic }
           : { anahtar: konum.pathname, baslik: konum.pathname.replace(/^\//, ''), ikon: '▫' };
}

export function useEkranSekmeleri({ satirlar, konum, navTuru, outlet, git }: {
  satirlar: MenuSatiri[];
  konum: Location;
  navTuru: NavigationType;
  outlet: React.ReactNode;
  git(yol: string, secenek?: { state?: unknown }): void;
}) {
  const [sekmeler, setSekmeler] = useState<Sekme[]>([]);
  const [bildirim, setBildirim] = useState('');
  /** Her sekmenin SON çizilen ekranı (gizliyken bu çizilir - durum korunur). */
  const ekranlar = useRef(new Map<string, React.ReactNode>());

  const simdiki = sekmeBul(satirlar, konum);
  ekranlar.current.set(simdiki.anahtar, outlet);

  // Adres değişince sekme açılır / güncellenir; sınır aşılırsa en eskisi kapanır.
  useEffect(() => {
    setSekmeler(onceki => {
      const var_ = onceki.find(s => s.anahtar === simdiki.anahtar);
      let yeni = var_
        ? onceki.map(s => s.anahtar === simdiki.anahtar ? { ...s, ...simdiki, konum, erisim: Date.now() } : s)
        : [...onceki, { ...simdiki, konum, erisim: Date.now() }];
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
  }, [konum.key]);   // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (!bildirim) return;
    const t = setTimeout(() => setBildirim(''), 4000);
    return () => clearTimeout(t);
  }, [bildirim]);

  // Çizilecek liste: ilk çizimde geçerli sekme henüz state'te yoksa SONA eklenir
  //   (effect ekleyince yeri değişmez - ekran yeniden kurulmaz).
  const liste = sekmeler.some(s => s.anahtar === simdiki.anahtar)
    ? sekmeler : [...sekmeler, { ...simdiki, konum, erisim: Date.now() }];
  const baslangicVar = liste.some(s => s.anahtar === BASLANGIC);

  const ac = (s: Sekme) => git(s.konum.pathname + s.konum.search, { state: s.konum.state });
  const kapat = (anahtar: string) => {
    if (anahtar === BASLANGIC) return;
    const i = liste.findIndex(s => s.anahtar === anahtar);
    ekranlar.current.delete(anahtar);
    setSekmeler(o => o.filter(s => s.anahtar !== anahtar));
    if (anahtar === simdiki.anahtar) {
      const komsu = liste.filter(s => s.anahtar !== anahtar)[Math.max(0, i - 1)];
      if (komsu) ac(komsu); else git(BASLANGIC);
    }
  };

  // KISAYOLLAR: Alt+W sekmeyi kapat (Ctrl+W tarayıcının), Ctrl+1..9 sekmeye git, Ctrl+Home başlangıç.
  useEffect(() => {
    const tus = (e: KeyboardEvent) => {
      if (e.altKey && e.key.toLowerCase() === 'w') { e.preventDefault(); kapat(simdiki.anahtar) }
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
             title={c(s.baslik)}
             onClick={() => ac(s)}
             onAuxClick={e => { if (e.button === 1) { e.preventDefault(); kapat(s.anahtar) } }}>
          <span className="es-ikon">{s.ikon}</span>
          {s.anahtar !== BASLANGIC && <span className="es-ad">{c(s.baslik)}</span>}
          {s.anahtar !== BASLANGIC && (
            <span className="es-x" title={c('Kapat (Alt+W)')}
                  onClick={e => { e.stopPropagation(); kapat(s.anahtar) }}>×</span>
          )}
        </div>
      ))}
      <span className="es-sayi">{liste.filter(s => s.anahtar !== BASLANGIC).length} / {SEKME_SINIRI}</span>
      {bildirim && <div className="es-bildirim">{bildirim}</div>}
    </div>
  );

  const govde = liste.map(s => {
    const aktif = s.anahtar === simdiki.anahtar;
    return (
      <div key={s.anahtar} className="es-govde" hidden={!aktif}>
        <SekmeGorunurBaglami.Provider value={aktif}>
          <UNSAFE_LocationContext.Provider
            value={{ location: aktif ? konum : s.konum, navigationType: aktif ? navTuru : NavigationType.Pop }}>
            {aktif ? outlet : ekranlar.current.get(s.anahtar)}
          </UNSAFE_LocationContext.Provider>
        </SekmeGorunurBaglami.Provider>
      </div>
    );
  });

  return { cubuk, govde };
}
