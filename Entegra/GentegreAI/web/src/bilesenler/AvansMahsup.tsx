import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { para } from './bicim';
import { mesaj } from './mesaj';

/**
 * AVANS MAHSUBU (322).
 *
 * Gerçek akış çoğu zaman "önce para, sonra ücret": hasta kapora/peşin öder,
 * tetkik ve ücret satırı sonra girilir. O tahsilat hiçbir satıra bağlanamaz,
 * DAĞITILMAMIŞ kalır - ve prim "tahsil edildikçe" doğduğu için prim de
 * tetiklenmez. Bu şerit o parayı görünür kılar ve tek tıkla satırlara dağıtır.
 *
 * Dağıtılmamış avans yoksa hiçbir şey çizilmez: boş kutu göstermenin faydası
 * yok.
 */
export function AvansMahsup({ belgeId, tarafId, onTamam }: {
  belgeId: number;
  tarafId: number;
  onTamam?(): void;
}) {
  const [satirlar, setSatirlar] = useState<Record<string, unknown>[]>([]);
  const [toplam, setToplam] = useState(0);
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    if (!tarafId || !belgeId) return;
    try {
      const y = await api.kasaAvans(tarafId);
      setSatirlar(y.satirlar ?? []);
      setToplam(Number(y.toplam ?? 0));
    } catch (h) { setHata(hataMetni(h)) }
  }, [tarafId, belgeId]);

  useEffect(() => { void yukle() }, [yukle]);

  if (!hata && toplam <= 0) return null;

  const mahsupEt = async () => {
    setHata(''); setCalisiyor(true);
    try {
      const y = await api.kasaAvansMahsup({ belgeId });
      mesaj(y.dagitilan > 0
        ? `${para.format(y.dagitilan)} avans bu belgenin satırlarına mahsup edildi.`
        : 'Mahsup edilecek açık satır kalmadı.');
      await yukle();
      onTamam?.();
    } catch (h) { setHata(hataMetni(h)) } finally { setCalisiyor(false) }
  };

  return (
    <div className="uyari-kutusu" style={{ display: 'flex', gap: 10, alignItems: 'center',
                                           flexWrap: 'wrap' }}>
      <span>
        Bu carinin <b>{para.format(toplam)}</b> dağıtılmamış tahsilatı var
        {satirlar.length > 1 ? ` (${satirlar.length} işlem)` : ''}.
        {' '}Mahsup edilmezse satırların tahsilatı görünmez ve <b>prim doğmaz</b>.
      </span>
      <button type="button" className="d" disabled={calisiyor}
              style={{ marginLeft: 'auto' }}
              onClick={() => void mahsupEt()}>
        {calisiyor ? '⏳ Mahsup ediliyor…' : '⇄ Bu Belgeye Mahsup Et'}
      </button>
      {hata && <div className="hata-kutusu" style={{ flexBasis: '100%' }}>{hata}</div>}
    </div>
  );
}
