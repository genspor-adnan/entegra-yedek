import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { BelgeTakipOzeti } from '../api/uclar/belgeTakip';
import { c } from '../dil/ceviri';

/**
 * İK › BELGE TAKİBİ ÜST ŞERİDİ (mockup Ekranlar/IK/personel_belge_takibi.html (2) araç çubuğu
 * sayaçları). Kullanıcılar listesindeki şeridin deseni (`.kul-ozet`): kutu bir giriş kapısıdır,
 * tıklanınca listeyi o çiple açar. Sayılar kurum geneli BELGE sayısı, alt satır kaç kişide.
 * Onay bekleyen yükleme / açık vize başvurusu kutuları o aşamalar gelince eklenecek.
 */
export function BelgeTakipOzetSeridi({ yenile, onCip }: {
  yenile?: number;
  /** `personel-belge-ozet` çip dizisindeki sıra (listeTanimlari.PersonelBelge.ts). */
  onCip?(indeks: number): void;
}) {
  const [o, setO] = useState<BelgeTakipOzeti | null>(null);

  const yukle = useCallback(async () => {
    // Şerit zorunlu değil: hatası liste akışını kesmemeli.
    try { setO(await api.belgeTakipOzet()) } catch { /* sessiz */ }
  }, []);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (!o) return null;

  const kutular: { anahtar: string; etiket: string; deger: number; alt: string; vurgu?: 'uyari' | 'hata'; cip: number }[] = [
    { anahtar: 'eksik', etiket: 'Eksik', deger: o.eksik, alt: `${o.eksikKisi} personelde`,
      vurgu: o.eksik > 0 ? 'hata' : undefined, cip: 0 },
    { anahtar: 'doldu', etiket: 'Süresi doldu', deger: o.doldu, alt: `${o.dolduKisi} personelde`,
      vurgu: o.doldu > 0 ? 'hata' : undefined, cip: 0 },
    { anahtar: 'yaklasan', etiket: 'Süresi yaklaşan', deger: o.yaklasan, alt: `${o.yaklasanKisi} personelde`,
      vurgu: o.yaklasan > 0 ? 'uyari' : undefined, cip: 1 },
    { anahtar: 'personel', etiket: 'Aktif personel', deger: o.personel, alt: 'tümünü göster', cip: 2 },
  ];

  return (
    <div className="kul-ozet" style={{ gridTemplateColumns: `repeat(${kutular.length}, 1fr)` }}>
      {kutular.map(k => (
        <button type="button" className="k" key={k.anahtar}
                title={c('Listeyi bu süzgeçle aç')}
                onClick={() => onCip?.(k.cip)}>
          <span className="bas">{k.etiket}</span>
          <span className={`deg${k.vurgu ? ` ${k.vurgu}` : ''}`}>{k.deger.toLocaleString('tr')}</span>
          <span className="alt">{k.alt}</span>
        </button>
      ))}
    </div>
  );
}
