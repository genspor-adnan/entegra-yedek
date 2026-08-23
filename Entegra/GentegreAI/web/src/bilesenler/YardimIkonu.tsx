import { useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';

/**
 * Alan/opsiyon yanindaki "?" ikonu — GENEL KURAL (kullanici karari):
 * aciklama ekranin altina paragraf olarak yazilmaz, alanin saginda "?" durur ve
 * basilinca metin gosterilir.
 *
 * Metnin kaynagi `public.help` (db/103). Iki kullanim var:
 *  - metin PROP olarak verilir (cagiran zaten yuklemistir - or. ayar listesi
 *    yardim metnini ayarla birlikte getirir, ek istek olmaz),
 *  - ya da yalniz `anahtar` verilir; ikon ilk TIKLAMADA metni ceker (ekran
 *    acilirken onlarca yardim metni indirmemek icin tembel yukleme).
 *
 * Metni olmayan anahtarda ikon HIC gorunmez: bos balon acan bir "?" gurultudur.
 */
export function YardimIkonu({ anahtar, baslik, metin }: {
  anahtar: string;
  baslik?: string;
  /** Onceden yuklenmis metin. Bos string = "metin yok" -> ikon gizlenir. */
  metin?: string;
}) {
  const [acik, setAcik] = useState(false);
  const [yuklenen, setYuklenen] = useState<{ baslik: string; metin: string } | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const kutuRef = useRef<HTMLSpanElement | null>(null);

  // Disari tiklayinca / Esc ile kapanir (mockup'taki kucuk balon davranisi).
  useEffect(() => {
    if (!acik) return;
    const disari = (e: MouseEvent) => {
      if (kutuRef.current && !kutuRef.current.contains(e.target as Node)) setAcik(false);
    };
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    document.addEventListener('mousedown', disari);
    document.addEventListener('keydown', tus);
    return () => {
      document.removeEventListener('mousedown', disari);
      document.removeEventListener('keydown', tus);
    };
  }, [acik]);

  // metin prop'u VERILMISSE (bos olsa da) sunucuya gidilmez: cagiran zaten biliyor.
  const propVar = metin !== undefined;
  if (propVar && !metin) return null;

  const gosterilen = propVar
    ? { baslik: baslik ?? '', metin: metin ?? '' }
    : yuklenen;

  async function ac() {
    if (acik) { setAcik(false); return }
    setAcik(true);
    if (propVar || yuklenen || yukleniyor) return;
    setYukleniyor(true);
    try {
      const y = await api.yardim(anahtar);
      setYuklenen({ baslik: y?.baslik ?? '', metin: y?.metin ?? '' });
    } catch {
      setYuklenen({ baslik: '', metin: 'Yardım metni alınamadı.' });
    } finally { setYukleniyor(false) }
  }

  return (
    <span className="yardim-sar" ref={kutuRef}>
      <button type="button" className="yardim-ikon" title="Açıklama"
              aria-label="Açıklama" onClick={() => void ac()}>?</button>
      {acik && (
        <span className="yardim-balon">
          {yukleniyor ? 'Yükleniyor…' : (
            <>
              {gosterilen?.baslik && <b>{gosterilen.baslik}</b>}
              {/* Metin duz yazi; satir aralari korunur (white-space: pre-line). */}
              <span className="yardim-metin">{gosterilen?.metin || 'Açıklama yok.'}</span>
            </>
          )}
        </span>
      )}
    </span>
  );
}
