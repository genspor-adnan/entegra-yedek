import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import type { YetkiSatiri } from '../api/sozlesme';
import { ApiHatasi } from '../api/sozlesme';

type Sutun = 'gor' | 'ekle' | 'degistir' | 'sil';
const SUTUNLAR: { ad: Sutun; baslik: string }[] = [
  { ad: 'gor', baslik: 'Gör' },
  { ad: 'ekle', baslik: 'Ekle' },
  { ad: 'degistir', baslik: 'Değiştir' },
  { ad: 'sil', baslik: 'Sil' },
];

/**
 * Rol kartı "Yetki Matrisi" sekmesi (kullanici: "role verdigimiz yetki dogrultusunda
 * menuleri Gorme/Ekleme/Duzeltme/Silme islem yapabilirdi"). Generic Detay mekanizmasina
 * UYMAZ - satir ekle/sil yok, SABIT `yetki` listesi uzerinde checkbox matrisi. Tum satirlar
 * TEK Kaydet ile birlikte gonderilir (satir-satir degil).
 */
export function RolYetkiMatrisi({ rolId, saltOkunur }: { rolId: number; saltOkunur: boolean }) {
  const [satirlar, setSatirlar] = useState<YetkiSatiri[] | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);

  useEffect(() => {
    setYukleniyor(true);
    setHata(null);
    api.rolYetkileri(rolId)
      .then(setSatirlar)
      .catch(h => setHata(h instanceof ApiHatasi ? h.message : String(h)))
      .finally(() => setYukleniyor(false));
  }, [rolId]);

  const degis = (yetkiId: number, sutun: Sutun, deger: boolean) => {
    setSatirlar(s => s?.map(satir => {
      if (satir.yetkiId !== yetkiId) return satir;
      // "Gör" kapatilirsa Ekle/Degistir/Sil de anlamsiz - birlikte kapatilir.
      if (sutun === 'gor' && !deger) return { ...satir, gor: false, ekle: false, degistir: false, sil: false };
      // Ekle/Degistir/Sil'den biri acilirsa Gor de otomatik acilir (gormeden islem olmaz).
      if (sutun !== 'gor' && deger) return { ...satir, gor: true, [sutun]: true };
      return { ...satir, [sutun]: deger };
    }) ?? s);
  };

  const kaydet = async () => {
    if (!satirlar) return;
    setKaydediyor(true);
    setHata(null);
    setBilgi(null);
    try {
      const guncel = await api.rolYetkiKaydet(rolId, satirlar.map(s => ({
        yetkiId: s.yetkiId, gor: s.gor, ekle: s.ekle, degistir: s.degistir, sil: s.sil,
      })));
      setSatirlar(guncel);
      setBilgi('Yetki matrisi kaydedildi.');
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally {
      setKaydediyor(false);
    }
  };

  return (
    <div className="kagrup">
      <h6>
        Yetki Matrisi
        {!saltOkunur && (
          <button type="button" className="d bir" disabled={kaydediyor || !satirlar} onClick={() => void kaydet()}>
            {kaydediyor ? 'Kaydediliyor…' : 'Kaydet'}
          </button>
        )}
      </h6>
      {hata && <div className="alan-hata" style={{ margin: '0 10px' }}>{hata}</div>}
      {bilgi && <div className="bilgi-kutusu" style={{ margin: '0 10px 10px' }}>{bilgi}</div>}
      <table className="detay-tablo">
        <thead>
          <tr>
            <th>Yetki</th>
            {SUTUNLAR.map(s => <th key={s.ad} style={{ textAlign: 'center' }}>{s.baslik}</th>)}
          </tr>
        </thead>
        <tbody>
          {yukleniyor && <tr><td colSpan={5}>Yükleniyor…</td></tr>}
          {!yukleniyor && satirlar?.length === 0 && <tr><td colSpan={5} className="bos">Tanımlı yetki yok.</td></tr>}
          {satirlar?.map(satir => (
            <tr key={satir.yetkiId}>
              <td>{satir.ad}</td>
              {SUTUNLAR.map(s => (
                <td key={s.ad} style={{ textAlign: 'center' }}>
                  <input
                    type="checkbox"
                    checked={satir[s.ad]}
                    disabled={saltOkunur}
                    onChange={e => degis(satir.yetkiId, s.ad, e.target.checked)}
                  />
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
