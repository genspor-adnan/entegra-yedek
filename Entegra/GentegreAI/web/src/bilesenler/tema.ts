/**
 * GECE / GUNDUZ MODU.
 *
 * Renkler `tema.css`te DEGISKEN (`--zem`, `--yuz`, `--yazi`...); gece modu bu
 * degiskenleri `<html data-tema="gece">` altinda yeniden tanimlar. Bilesenlerde
 * tek satir bile degismez - hepsi zaten degiskenleri kullaniyor.
 *
 * SECIM TARAYICIDA (localStorage): kullanicinin GOZUNE ve calistigi ekrana bagli
 * bir tercih; ayni hesap gunduz masaustunde, gece dizustunde farkli olabilir.
 * Sunucuya yazsaydik iki cihaz birbirini ezerdi.
 *
 * Varsayilan "sistem": isletim sisteminin koyu tema ayari izlenir.
 */

export type Tema = 'sistem' | 'gunduz' | 'gece';

const ANAHTAR = 'gentegre.tema';

export function temaOku(): Tema {
  try {
    const d = localStorage.getItem(ANAHTAR);
    return d === 'gece' || d === 'gunduz' ? d : 'sistem';
  } catch {
    return 'sistem';                       // gizli sekmede localStorage kapali olabilir
  }
}

/** Secimi uygular ve saklar. "sistem" isaretlemez - CSS medya sorgusu devreye girer. */
export function temaUygula(tema: Tema) {
  const kok = document.documentElement;
  if (tema === 'sistem') kok.removeAttribute('data-tema');
  else kok.setAttribute('data-tema', tema);
  try { localStorage.setItem(ANAHTAR, tema) } catch { /* yoksay */ }
}

/** Uygulama acilirken bir kez - ekran ilk boyamada dogru renklerle gelsin. */
export function temaBaslat() {
  temaUygula(temaOku());
}

/** Uc durumlu dongu: sistem -> gunduz -> gece -> sistem. */
export function temaSonraki(su: Tema): Tema {
  return su === 'sistem' ? 'gunduz' : su === 'gunduz' ? 'gece' : 'sistem';
}

export const TEMA_ADI: Record<Tema, string> = {
  sistem: 'Sistem',
  gunduz: 'Gündüz',
  gece: 'Gece',
};

export const TEMA_IKON: Record<Tema, string> = {
  sistem: '🖥️',
  gunduz: '☀️',
  gece: '🌙',
};
