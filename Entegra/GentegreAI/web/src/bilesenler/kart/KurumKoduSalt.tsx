import { useEffect, useState } from 'react';
import { istek } from '../../api/cekirdek';
import { c } from '../../dil/ceviri';

/**
 * ENTEGRASYON HESABI › KURUM / TESİS KODU (1321, kullanıcı: "her yerde geçerli ana ayarlar enabız ayarları olsun").
 * Alan DÜZENLENEBİLİR; altında ne işe yaradığı yazar:
 *   - ENABIZ: SKRS kurum kodu - her yerde geçerli (TeleRadyoloji, MEDULA, Teleradyoloji teslimi buradan okur);
 *   - MEDULA: tesis kodu yalnız e-Nabız hesabında MEDULA tesis kodu yoksa kullanılır - varsa geçerli değer gösterilir.
 */
export function KurumKoduSalt({ kod, subeId, deger, yaz, salt }: { kod: string; subeId: number; deger: string; yaz(v: string): void; salt: boolean }) {
  const [kimlik, setKimlik] = useState<{ tesis: string; kaynak: string } | null>(null);
  useEffect(() => {
    if (kod !== 'MEDULA') return;
    istek<{ kimlik: { tesis: string; kaynak: string } | null }>(`/api/entegrasyon/teleradyoloji/baglam?subeId=${subeId}`)
      .then(y => setKimlik(y.kimlik)).catch(() => setKimlik(null));
  }, [kod, subeId]);
  const enabizden = kod === 'MEDULA' && kimlik?.kaynak?.startsWith('e-Nabız') && !!kimlik.tesis;
  return (
    <div className="kurum-kodu-salt">
      <input className="inp" value={deger} disabled={salt} onChange={e => yaz(e.target.value)} />
      <small className="sonuk">
        {kod === 'ENABIZ'
          ? c('SKRS kurum kodu - her yerde geçerli: TeleRadyoloji, MEDULA, Teleradyoloji teslimi buradan okur (şube satırı → kurum geneli). MEDULA tesis kodu ve Bakanlık adı "Kurum Kimliği" sekmesinde.')
          : enabizden
            ? <>{c('Geçerli tesis kodu e-Nabız hesabından')}: <b>{kimlik!.tesis}</b>{kimlik!.tesis !== deger && deger ? ` - ${c('bu alan kullanılmıyor')}` : ''}</>
            : c('MEDULA tesis kodu - e-Nabız hesabında tesis kodu yoksa bu kullanılır.')}
      </small>
    </div>
  );
}
