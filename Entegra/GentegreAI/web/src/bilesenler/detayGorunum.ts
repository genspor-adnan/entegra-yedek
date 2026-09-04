import { para4 } from './bicim';
import type { KartAlanMeta } from '../api/sozlesme';

/**
 * DETAY GRIDINDE HUCRE METNI - saf fonksiyon.
 *
 * GenDetayTablo icinde inline duruyordu; dort ayri kural (mantik / kodlu metin
 * / kod / para) birbirine karismisti ve hicbiri test edilemiyordu. Prim
 * satirinda "Belge Türleri" kodlu metin olarak eklenince kural sayisi arti ve
 * ayirmak kacinilmaz hale geldi.
 */
export function detayHucreMetni(
  satir: Record<string, unknown>,
  alan: Pick<KartAlanMeta, 'ad' | 'tip' | 'kodlar'>,
): string {
  const d = satir[alan.ad];

  if (alan.tip === 'mantik') return Number(d) === 1 || d === true ? '✓' : '';

  // KODLU METIN (prim satirinda Belge Türleri): kolon VIRGULLU LISTE tasir.
  //   Bos = kriter yok, yani "Tümü" - bos hucre "doldurulmamis" gibi
  //   okunuyordu. Once TAM ESLESME (combo secenegin kendisi: "15,16"), yoksa
  //   kodlar tek tek cozulur - eski kayitlar baska kombinasyonlar tasiyabilir
  //   ve ham "4,14,15" gridde hicbir sey ifade etmiyordu.
  if (alan.tip === 'metin' && alan.kodlar) {
    const ham = String(d ?? '').trim();
    if (ham === '') return 'Tümü';
    return alan.kodlar[ham]
      ?? ham.split(',').map(x => x.trim()).filter(Boolean)
            .map(k => alan.kodlar![k] ?? k).join(', ');
  }

  if (alan.kodlar) return alan.kodlar[String(d ?? '')] ?? '';

  if (alan.tip === 'para' && d !== null && d !== undefined && d !== '') {
    const s = Number(d);
    // para4: iki haneye EZMEZ - carpan 7,0092'yi 7,01 gostermek yaniltir;
    //   tutarlar zaten iki hanede gelir, fazladan hane basilmaz.
    if (Number.isFinite(s)) return para4.format(s);
  }

  return String(d ?? '');
}
