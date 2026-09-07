import { useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * MUAYENE › BUGÜNKÜ SONUÇLAR (461) — mockup `muayene_karti.html` sağ
 * sütununda vitalin altındaki küçük tablo.
 *
 * <b>Neden özet:</b> hekim anamnezi yazarken "bugün ne çıktı" sorusunun
 * cevabını yanında ister. Ayrıntı (istem başlıkları, kültür, genetik,
 * radyoloji, "gördüm" işareti) <b>İstem &amp; Sonuçlar</b> sekmesinde durur -
 * burası onun yerini almaz, kısayolu olur.
 *
 * <b>Bayrak sunucudan gelir</b>: H/L/HH/LL ve panik işareti laboratuvarın
 * referans aralığından hesaplanır; ekranda eşik yorumlanmaz.
 */

type Satir = Record<string, unknown>;

const metin = (v: unknown) => String(v ?? '').trim();

const BAYRAK_OK: Record<string, string> = { LL: '↓↓', HH: '↑↑', L: '↓', H: '↑', N: '' };

/** Panik kırmızı, tek yön sarı, normal nötr - lab ekranlarıyla aynı dil. */
const bayrakSinifi = (b: string) =>
  b === 'LL' || b === 'HH' ? 'rozet hata' : b === 'L' || b === 'H' ? 'rozet uyari' : '';

export function MuayeneSonucOzeti({ muayeneId }: { muayeneId: number }) {
  const [sonuclar, setSonuclar] = useState<Satir[]>([]);
  const [bekleyen, setBekleyen] = useState(0);
  const [yuklendi, setYuklendi] = useState(false);

  useEffect(() => {
    if (!(muayeneId > 0)) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.muayeneSonuclari(muayeneId) as unknown as {
          istemler?: Satir[]; sonuclar?: Satir[];
        };
        if (iptal) return;
        setSonuclar(y.sonuclar ?? []);
        // Sonucu gelmemiş tetkik sayısı: eksiklik de bilgidir.
        const istenen = (y.istemler ?? []).reduce((t, i) => t + Number(i.tetkik ?? 0), 0);
        const onayli = (y.istemler ?? []).reduce((t, i) => t + Number(i.onayli ?? 0), 0);
        setBekleyen(Math.max(0, istenen - onayli));
      } catch { /* ozet zorunlu degil */ }
      finally { if (!iptal) setYuklendi(true) }
    })();
    return () => { iptal = true };
  }, [muayeneId]);

  if (!(muayeneId > 0)) return null;

  const panik = sonuclar.filter(s => Number(s.panik ?? 0) === 1).length;
  // Panikler ÜSTTE: hekimin görmesi gereken tek satır buysa, listenin
  //   ortasında kaybolmamalı.
  const sirali = [...sonuclar].sort((a, b) =>
    Number(b.panik ?? 0) - Number(a.panik ?? 0));

  return (
    <div className="kagrup sonuc-ozet">
      <h6>
        Bugünkü sonuçlar
        <span className="sonuk">
          {yuklendi
            ? ` · ${sonuclar.length} sonuç${bekleyen > 0 ? ` · ${bekleyen} bekliyor` : ''}`
            : ' · …'}
        </span>
        {panik > 0 && <span className="rozet hata">{panik} panik</span>}
      </h6>

      {sonuclar.length === 0 ? (
        <div className="bos">
          {yuklendi
            ? (bekleyen > 0 ? 'Sonuç bekleniyor.' : 'Bu muayenede sonuç yok.')
            : '…'}
        </div>
      ) : (
        <table className="detay-tablo">
          <thead>
            <tr><th>Tetkik</th><th className="sag">Sonuç</th><th>Ref.</th>
              <th className="orta">Bayrak</th></tr>
          </thead>
          <tbody>
            {sirali.slice(0, 12).map((s, i) => {
              const b = metin(s.bayrak).toUpperCase();
              return (
                <tr key={i}>
                  <td title={metin(s.yorum)}>{metin(s.ad) || metin(s.kod)}</td>
                  <td className="sag">
                    {/* Kultur/genetik sonucu METIN olabilir ("Klebsiella…"):
                        dar kolonda tasmasin diye kirpilir, tamami baslikta. */}
                    <span className="sonuc-deger" title={metin(s.deger)}>
                      {metin(s.deger) || '—'}
                    </span>
                    {metin(s.birim) ? <span className="sonuk"> {metin(s.birim)}</span> : null}
                  </td>
                  <td className="sonuk">{metin(s.referansMetin) || '—'}</td>
                  <td className="orta">
                    {Number(s.panik ?? 0) === 1
                      ? <span className="rozet hata">PANİK</span>
                      : b && b !== 'N'
                        ? <span className={bayrakSinifi(b)}>{BAYRAK_OK[b] ?? b}</span>
                        : <span className="sonuk">—</span>}
                  </td>
                </tr>
              );
            })}
            {sirali.length > 12 && (
              <tr><td colSpan={4} className="sonuk">
                +{sirali.length - 12} sonuç — İstem &amp; Sonuçlar sekmesinde
              </td></tr>
            )}
          </tbody>
        </table>
      )}
    </div>
  );
}
