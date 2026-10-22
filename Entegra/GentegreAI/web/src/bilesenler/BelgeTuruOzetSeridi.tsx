import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { BelgeTuruOzeti } from '../api/uclar/belgeTakip';
import { c } from '../dil/ceviri';

/**
 * İK › BELGE TÜRLERİ ÜST ŞERİDİ (mockup Ekranlar/IK/personel_belge_turu.html (1) sayaç kartları).
 * Kutu bir giriş kapısıdır: tıklanınca listeyi o çiple açar (`personel-belge-turu` çip sırası,
 * listeTanimlari.PersonelBelge.ts: 0 aktif, 1 zorunlu, 2 süreli, 3 eksiği olan, 4 isteğe bağlı).
 */
export function BelgeTuruOzetSeridi({ yenile, onCip }: { yenile?: number; onCip?(indeks: number): void }) {
  const [o, setO] = useState<BelgeTuruOzeti | null>(null);
  const yukle = useCallback(async () => {
    try { setO(await api.belgeTuruOzet()) } catch { /* şerit zorunlu değil */ }
  }, []);
  useEffect(() => { void yukle() }, [yukle, yenile]);
  if (!o) return null;

  const kutular: { anahtar: string; etiket: string; deger: number; alt: string; vurgu?: 'uyari' | 'hata'; cip: number }[] = [
    { anahtar: 'aktif', etiket: 'Aktif tür', deger: o.aktif, alt: o.pasif ? `${o.pasif} pasif` : 'tümü', cip: 0 },
    { anahtar: 'zorunlu', etiket: 'Zorunlu (kapsamı tanımlı)', deger: o.zorunlu, alt: 'kime zorunlu belli', cip: 1 },
    { anahtar: 'sureli', etiket: 'Süreli (yenilenen)', deger: o.sureli, alt: 'geçerlilik süresi var', cip: 2 },
    { anahtar: 'eksik', etiket: 'Personelde eksiği olan', deger: o.eksigiOlan, alt: 'eksik ya da süresi dolmuş',
      vurgu: o.eksigiOlan > 0 ? 'hata' : undefined, cip: 3 },
    { anahtar: 'istege', etiket: 'İsteğe bağlı (kapsamsız)', deger: o.istegeBagli, alt: 'eksik sayılmaz',
      vurgu: o.istegeBagli > 0 ? 'uyari' : undefined, cip: 4 },
  ];
  return (
    <div className="kul-ozet" style={{ gridTemplateColumns: `repeat(${kutular.length}, 1fr)` }}>
      {kutular.map(k => (
        <button type="button" className="k" key={k.anahtar} title={c('Listeyi bu süzgeçle aç')} onClick={() => onCip?.(k.cip)}>
          <span className="bas">{k.etiket}</span>
          <span className={`deg${k.vurgu ? ` ${k.vurgu}` : ''}`}>{k.deger.toLocaleString('tr')}</span>
          <span className="alt">{k.alt}</span>
        </button>
      ))}
    </div>
  );
}
