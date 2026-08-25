import { useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type DokumanSatiri } from '../api/sozlesme';

export function KartResimKutusu({ kartAdi, kaynakId, saltOkunur, baslik = 'Resim' }: {
  kartAdi: string;
  kaynakId?: number;
  saltOkunur: boolean;
  baslik?: string;
}) {
  const [url, setUrl] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const dosyaRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    if (!kaynakId) {
      setUrl(null);
      return;
    }
    let iptal = false;
    let blobUrl: string | null = null;
    api.dokumanlar(kartAdi, kaynakId)
      .then((satirlar: DokumanSatiri[]) => {
        const resimler = satirlar.filter(s => s.contentType.startsWith('image/'));
        const resim = resimler.find(s => s.varsayilan) ?? resimler[0];
        if (!resim) {
          setUrl(null);
          return null;
        }
        return api.dokumanIcerikUrl(resim.id);
      })
      .then(u => {
        if (!u || iptal) return;
        blobUrl = u;
        setUrl(u);
      })
      .catch(() => setUrl(null));
    return () => {
      iptal = true;
      if (blobUrl) URL.revokeObjectURL(blobUrl);
    };
  }, [kartAdi, kaynakId]);

  const dosyaSecildi = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const dosya = e.target.files?.[0];
    e.target.value = '';
    if (!dosya || !kaynakId) return;
    setYukleniyor(true);
    setHata(null);
    try {
      const satirlar = await api.dokumanYukle(kartAdi, kaynakId, dosya, true);
      const resimler = satirlar.filter(s => s.contentType.startsWith('image/'));
      const resim = resimler.find(s => s.varsayilan) ?? resimler[0];
      setUrl(resim ? await api.dokumanIcerikUrl(resim.id) : null);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally {
      setYukleniyor(false);
    }
  };

  return (
    <div className="kagrup kagrup-resim">
      <h6>{baslik}</h6>
      {!saltOkunur && kaynakId && (
        <input ref={dosyaRef} type="file" style={{ display: 'none' }}
          accept="image/jpeg,image/png,image/webp,image/gif" onChange={e => void dosyaSecildi(e)} />
      )}
      <div
        className="resim-kutusu"
        title={!kaynakId ? 'Kart kaydedilmeden resim eklenemez' : saltOkunur ? undefined : 'Resim eklemek için tıklayın'}
        style={{ cursor: !saltOkunur && kaynakId ? 'pointer' : 'default', overflow: 'hidden' }}
        onClick={() => { if (!saltOkunur && kaynakId) dosyaRef.current?.click() }}
      >
        {yukleniyor ? '…' : url ? <img src={url} alt={baslik} style={{ width: '100%', height: '100%', objectFit: 'contain' }} /> : '🖼️'}
      </div>
      {hata && <div className="alan-hata" style={{ margin: '4px 10px 0' }}>{hata}</div>}
    </div>
  );
}

/** Kart ici sekme: alan grubu, detay tablosu, ya da henuz baglanmamis yer tutucu. */
