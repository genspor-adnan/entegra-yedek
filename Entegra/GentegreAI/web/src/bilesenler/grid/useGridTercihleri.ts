import { useEffect, useState } from 'react';
import type { SatirBoyu } from './GridMenu';

/**
 * GRIDIN TARAYICIDA SAKLANAN TERCIHLERI: satir yuksekligi ve yan panelin
 * acik/kapali hali.
 *
 * Ikisi de `localStorage`'a yazilir ve okuma/yazma HER ZAMAN try/catch icinde
 * olmali: gizli sekmede ve site verisi engellendiginde erisim hata firlatir -
 * grid o yuzden hic cizilmemeliydi degil, varsayilanla cizilmeli.
 */
export function useGridTercihleri(kaynak: string, solPanelVar: boolean) {
  /**
   * SATIR YUKSEKLIGI: sik / normal / genis. Uzun listelerde daha cok satir
   * gormek isteyen ile okunakli aralik isteyen kullanici ayni ekrani paylasiyor;
   * secim tarayicida saklanir (kaynak farketmeksizin tek tercih).
   */
  const [satirBoyu, setSatirBoyu] = useState<SatirBoyu>(() => {
    try {
      const v = localStorage.getItem('grid.satirBoyu');
      return v === 'sik' || v === 'genis' ? v : 'normal';
    } catch { return 'normal' }
  });
  const satirBoyuSec = (v: SatirBoyu) => {
    setSatirBoyu(v);
    try { localStorage.setItem('grid.satirBoyu', v) } catch { /* gizli sekme */ }
  };

  // YAN PANEL ACIK/KAPALI, ekran basina hatirlanir: dar ekranda calisan
  //   kullanici paneli kapatip listeye tam genislik verir, her acilista
  //   yeniden kapatmak zorunda kalmasin.
  const yanAnahtar = `gentegre.yanpanel.${kaynak}`;
  const [yanKapali, setYanKapali] = useState(() => {
    try {
      const kayitli = localStorage.getItem(yanAnahtar);
      if (kayitli !== null) return kayitli === '1';
      // UC KOLONLU EKRANDA (sol agac + liste + yan panel) DAR EKRAN:
      //   ilk acilista yan panel KAPALI baslar - 1440'lik ekranda uc kolon
      //   listeyi 600px'e dusurup kolonlari kirpiyordu. Kullanici acabilir,
      //   secimi hatirlanir.
      return solPanelVar && window.innerWidth < 1600;
    } catch { return false }
  });
  useEffect(() => {
    try { localStorage.setItem(yanAnahtar, yanKapali ? '1' : '0') } catch { /* yok say */ }
  }, [yanAnahtar, yanKapali]);

  return { satirBoyu, satirBoyuSec, yanKapali, setYanKapali };
}
