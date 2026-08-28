import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni, type ListeSatiri } from '../api/sozlesme';
import { para, para4 } from './bicim';

/**
 * HIZMET KARTI > Fiyatlar sekmesi ALT BLOGU (kullanici): kalemin gectigi
 * FIYAT LISTESI satirlari - "bu hizmet hangi listede kactan satiliyor".
 * Salt okunur: satirlar fiyat listesi kartindan yonetilir; buradaki blok
 * yalniz toplu bakis verir. Kartin kendi fiyatlari ustteki detay griddedir.
 */
export function HizmetListeFiyatlari({ hizmetId }: { hizmetId: number }) {
  const [satirlar, setSatirlar] = useState<ListeSatiri[] | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('fiyat-listesi-satir', {
          sayfa: 1, boyut: 200,
          sirala: [{ alan: 'listeAdi', yon: 'asc' }],
          filtre: { alan: 'hizmetId', op: 'esit', deger: hizmetId },
        });
        if (!iptal) setSatirlar(y.satirlar);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
    })();
    return () => { iptal = true };
  }, [hizmetId]);

  if (hata) return <div className="hata-kutusu" style={{ marginTop: 12 }}>{hata}</div>;
  if (!satirlar) return <div className="not" style={{ marginTop: 12 }}>Liste fiyatları yükleniyor…</div>;
  if (satirlar.length === 0)
    return <div className="not" style={{ marginTop: 12 }}>Bu hizmet hiçbir fiyat listesinde yer almıyor.</div>;

  return (
    <div className="kagrup" style={{ marginTop: 12 }}>
      <h6>Fiyat Listelerindeki Fiyatları</h6>
      <table className="detay-tablo">
        <thead>
          <tr><th>Liste</th><th style={{ textAlign: 'right' }}>Fiyat</th><th>Döviz</th>
              <th>KDV</th><th>Yazım</th><th style={{ textAlign: 'right' }}>Çarpan</th><th>Durum</th></tr>
        </thead>
        <tbody>
          {satirlar.map((s, i) => (
            <tr key={i}>
              <td>{String(s.listeAdi ?? '')}</td>
              <td style={{ textAlign: 'right' }}>{para.format(Number(s.fiyat) || 0)}</td>
              <td>{String(s.dovizCinsi ?? '')}</td>
              <td>{String(s.kdvDahil ?? '')}</td>
              <td>{String(s.yazim ?? '')}</td>
              <td style={{ textAlign: 'right' }}>
                {s.carpan == null || s.carpan === '' ? '' : para4.format(Number(s.carpan))}
              </td>
              <td>{String(s.durumAdi ?? '')}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
