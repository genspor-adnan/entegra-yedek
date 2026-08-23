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
  /** Balonun ekran koordinati - asagi bak. */
  const [konum, setKonum] = useState<{ ust: number; sol: number } | null>(null);
  const [yuklenen, setYuklenen] = useState<{ baslik: string; metin: string } | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const kutuRef = useRef<HTMLSpanElement | null>(null);
  const dugmeRef = useRef<HTMLButtonElement | null>(null);

  // Disari tiklayinca / Esc ile kapanir (mockup'taki kucuk balon davranisi).
  useEffect(() => {
    if (!acik) return;
    const disari = (e: MouseEvent) => {
      if (kutuRef.current && !kutuRef.current.contains(e.target as Node)) setAcik(false);
    };
    const tus = (e: KeyboardEvent) => { if (e.key === 'Escape') setAcik(false) };
    // Balon sayfaya degil EKRANA sabit; sayfa kayarsa yerinde kalirdi - kapatilir.
    const kapat = () => setAcik(false);
    document.addEventListener('mousedown', disari);
    document.addEventListener('keydown', tus);
    window.addEventListener('scroll', kapat, true);
    window.addEventListener('resize', kapat);
    return () => {
      document.removeEventListener('mousedown', disari);
      document.removeEventListener('keydown', tus);
      window.removeEventListener('scroll', kapat, true);
      window.removeEventListener('resize', kapat);
    };
  }, [acik]);

  // metin prop'u VERILMISSE (bos olsa da) sunucuya gidilmez: cagiran zaten biliyor.
  const propVar = metin !== undefined;
  if (propVar && !metin) return null;

  const gosterilen = propVar
    ? { baslik: baslik ?? '', metin: metin ?? '' }
    : yuklenen;

  /**
   * Balon POSITION:FIXED cizilir. Sebep: kart/ayar kutusu (.kagrup) taşmayı
   * kirpiyor (overflow:hidden) - akis icinde duran balonun alti kesiliyordu.
   * Konum ikonun ekran koordinatindan hesaplanir; asagi ya da saga tasarsa
   * yukari/sola alinir.
   */
  function konumHesapla() {
    const d = dugmeRef.current?.getBoundingClientRect();
    if (!d) return;
    const genislik = 320, tahminiYukseklik = 180, bosluk = 8;
    const sagaSigar = d.right + genislik / 2 < window.innerWidth;
    const sol = Math.max(bosluk,
      Math.min(sagaSigar ? d.left : window.innerWidth - genislik - bosluk,
               window.innerWidth - genislik - bosluk));
    const altaSigar = d.bottom + tahminiYukseklik + bosluk < window.innerHeight;
    const ust = altaSigar ? d.bottom + 4 : Math.max(bosluk, d.top - tahminiYukseklik - 4);
    setKonum({ ust, sol });
  }

  async function ac() {
    if (acik) { setAcik(false); return }
    konumHesapla();
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
      <button ref={dugmeRef} type="button" className="yardim-ikon" title="Açıklama"
              aria-label="Açıklama" onClick={() => void ac()}>?</button>
      {acik && (
        <span className="yardim-balon"
              style={{ top: konum?.ust ?? 0, left: konum?.sol ?? 0 }}>
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
