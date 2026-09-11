import { useEffect, useRef, useState } from 'react';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * GRID SATIR SECIMI - onay kutulari, tek satir hedefi ve klavye/fare kurallari.
 *
 * GENEL KURAL — UYGULAMADAKI TUM GRIDLERDE AYNI (kullanici karari):
 *   duz tik      : YALNIZ o satir secili kalir, onceki isaretler kalkar
 *   Ctrl/Cmd+tik : o satiri secime ekler / cikarir
 *   Shift+tik    : son "ankor" satirdan buraya kadar araligi secer
 * (Explorer / Excel davranisi.) Onay kutusu tek satiri ekler-cikarir ve satir
 * tiklamasini tetiklemez.
 *
 * Onay kutusu ve tek-satir secimi (aksiyon/duzenle hedefi) AYNI durumu
 * paylasir: TEK kutu isaretliyken o satir hedef olur, sifir ya da birden
 * fazlasinda hedef belirsizdir (null).
 */
export function useGridSecimi(opts: {
  satirlar: ListeSatiri[];
  /** Kaynak degisince (baska liste ekrani) secim sifirlanir. */
  kaynak: string;
  sayfa: number;
  /** Acilista secili gelecek satirin id'si (ekstreden listeye donus). */
  seciliBaslangicId?: number | null;
  onSecimDegisti?(satir: ListeSatiri | null): void;
}) {
  const { satirlar, kaynak, sayfa, seciliBaslangicId, onSecimDegisti } = opts;

  const [seciliSatir, setSeciliSatir] = useState<ListeSatiri | null>(null);
  const [secili, setSecili] = useState<Set<string>>(new Set());
  const ankorRef = useRef<number | null>(null);

  useEffect(() => { setSecili(new Set()) }, [kaynak]);

  const sayfaIdleri = () => satirlar.map((s, i) => String(s.id ?? i));

  const secimiUygula = (yeni: Set<string>) => {
    setSecili(yeni);
    if (yeni.size === 1) {
      const tekId = [...yeni][0];
      const idx = satirlar.findIndex((s, i) => String(s.id ?? i) === tekId);
      setSeciliSatir(idx >= 0 ? satirlar[idx] : null);
    } else {
      setSeciliSatir(null);
    }
  };

  const satirSecimiDegistir = (id: string, index: number) => {
    const yeni = new Set(secili);
    yeni.has(id) ? yeni.delete(id) : yeni.add(id);
    secimiUygula(yeni);
    ankorRef.current = index;
  };

  /**
   * SAYFA DEGISINCE SECIM TEMIZLENIR (cip degisimiyle ayni gerekce):
   * isaretli satirlar artik ekranda degildir; secim kalinca sayac gorunenle
   * uyusmuyor ve toplu aksiyon EKRANDA OLMAYAN satiri isliyordu.
   */
  const oncekiSayfaRef = useRef(sayfa);
  useEffect(() => {
    if (oncekiSayfaRef.current === sayfa) return;
    oncekiSayfaRef.current = sayfa;
    secimiUygula(new Set());
  // secimiUygula her render'da yeniden kuruluyor - bagimliliga girerse
  //   effect her render calisir ve secimi aninda siler.
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [sayfa]);

  /**
   * ISTISNA: secimin kendisi "islem hedefi isaretleme" olan ekranlar - ör. belge
   * DONUSUM modali - duz tikta digerlerini KALDIRMAZ; orada coklu isaret asildir.
   */
  const satirTiklandi = (e: React.MouseEvent, id: string, index: number) => {
    if (e.shiftKey && ankorRef.current !== null) {
      const bas = Math.min(ankorRef.current, index);
      const son = Math.max(ankorRef.current, index);
      const yeni = new Set(secili);
      for (let k = bas; k <= son; k++) yeni.add(String(satirlar[k].id ?? k));
      secimiUygula(yeni);
      return;
    }
    if (e.ctrlKey || e.metaKey) {
      const yeni = new Set(secili);
      yeni.has(id) ? yeni.delete(id) : yeni.add(id);
      secimiUygula(yeni);
      ankorRef.current = index;
      return;
    }
    secimiUygula(new Set([id]));
    ankorRef.current = index;
  };

  const hepsiSecili = satirlar.length > 0 && sayfaIdleri().every(id => secili.has(id));
  const bazisiSecili = !hepsiSecili && sayfaIdleri().some(id => secili.has(id));

  // Ekstreden listeye donunce ayni satir secili gelsin (seciliBaslangicId).
  const ilkSecimUygulandi = useRef(false);
  useEffect(() => {
    if (ilkSecimUygulandi.current || !seciliBaslangicId || satirlar.length === 0) return;
    const bulunan = satirlar.find(r => Number(r.id) === seciliBaslangicId);
    if (bulunan) { setSeciliSatir(bulunan); setSecili(new Set([String(seciliBaslangicId)])) }
    ilkSecimUygulandi.current = true;
  }, [satirlar, seciliBaslangicId]);

  // Secim degisince disariya bildir (ör. "Ekstre" dugmesinin aktifligi).
  useEffect(() => { onSecimDegisti?.(seciliSatir) }, [seciliSatir, onSecimDegisti]);

  /** Baslik onay kutusu: kismi secimde "indeterminate" cizilir. */
  const hepsiRef = useRef<HTMLInputElement | null>(null);
  useEffect(() => {
    if (hepsiRef.current) hepsiRef.current.indeterminate = bazisiSecili;
  }, [bazisiSecili]);

  return { secili, secimiUygula, seciliSatir, setSeciliSatir,
           satirSecimiDegistir, satirTiklandi, sayfaIdleri,
           hepsiSecili, bazisiSecili, hepsiRef };
}
