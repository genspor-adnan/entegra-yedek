import type { MouseEvent } from 'react';
import { alanMakrolari, makroEkle, makroKullanildi, type Makro } from './muayeneMakro';
import { c } from '../dil/ceviri';

/**
 * MAKRO İPUCU (kullanıcı: "makro kısayollarını alan altında ipucu olarak
 * göster"): alanda geçerli kısayollar alanın altında küçük çip; üzerine gelince
 * açılacak metin görünür. Makro yoksa hiç çizilmez.
 *
 * ÇİPE TIK (kullanıcı: "tıklayınca makro alana yazılsın"): metin alandaki
 * imlecin yerine (alan hiç odaklanmadıysa sona) girer, alan odağı geri alır.
 * Alan elemanı aynı etiketteki `data-alan` kutusudur; yazım kartın kendi
 * yazıcısıyla (`yaz`) - React durumu tek kaynak.
 */
export function MakroIpucu({ alan, makrolar, yaz }: {
  alan: string;
  makrolar: readonly Makro[];
  yaz?(v: string): void;
}) {
  const liste = alanMakrolari(alan, makrolar);
  if (liste.length === 0) return null;

  const tikla = (e: MouseEvent<HTMLButtonElement>, m: Makro) => {
    e.preventDefault();
    if (!yaz) return;
    const kutu = e.currentTarget.closest('label')
      ?.querySelector<HTMLTextAreaElement | HTMLInputElement>(`[data-alan="${alan}"]`);
    const metin = kutu?.value ?? '';
    // Alan odakta değilse (çipe tık odağı çalmaz: mousedown engelli) sona ekle.
    const imlec = kutu && document.activeElement === kutu && typeof kutu.selectionStart === 'number'
      ? kutu.selectionStart : metin.length;
    const s = makroEkle(metin, imlec, m.metin);
    yaz(s.deger);
    makroKullanildi(m);
    if (kutu) requestAnimationFrame(() => {
      try { kutu.focus(); kutu.setSelectionRange(s.imlec, s.imlec) } catch { /* kutu gitti */ }
    });
  };

  return (
    <span className="makro-ipucu">
      ⌨
      {liste.map(m => (
        <button key={`${m.kisayol}-${m.alan}`} type="button" disabled={!yaz}
                title={`${m.metin}\n\n${m.kullanim ? `${m.kullanim} ${c('kez kullanıldı')} · ` : ''}${c('Tıklayın: alana yazılır · ya da kısayolu yazıp boşluk basın')}`}
                onMouseDown={e => e.preventDefault()}
                onClick={e => tikla(e, m)}>{m.kisayol}</button>
      ))}
      <small>{c('tıkla ya da yaz + boşluk')}</small>
    </span>
  );
}
