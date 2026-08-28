import { useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';

/**
 * ÜTS ALMA BİLDİRİMİ (223) - askıdaki envanter satırından: VBI hazırdır,
 * kullanıcı yalnız adedi onaylar/kısar ("verilen miktardan az alma" ÜTS'de
 * geçerli bir akış). Başarıda askı adeti sunucuda düşer.
 */
export function UtsAlmaModali({ envanterId, urunNo, kurumUnvan, askiAdet, seriNo,
                                onKapat, onTamam }: {
  envanterId: number;
  urunNo: string;
  kurumUnvan: string;
  askiAdet: number;
  seriNo: string;
  onKapat(): void;
  onTamam(mesaj: string): void;
}) {
  // Tekil (seri no'lu) üründe adet hep 1'dir - kısma yalnız lot bazlı gelişte.
  const tekil = seriNo.trim().length > 0;
  const [adet, setAdet] = useState(String(askiAdet || 1));
  const [gonderiyor, setGonderiyor] = useState(false);
  const [hata, setHata] = useState('');

  const gonder = async () => {
    setGonderiyor(true); setHata('');
    try {
      const y = await api.utsAlmaBildir({
        envanterId,
        adet: tekil ? 1 : Number(adet.replace(',', '.')) || 0,
      });
      if (!y.basarili) { setHata(y.mesaj); return }
      onTamam(y.mesaj);
    } catch (h) {
      setHata(hataMetni(h));
    } finally {
      setGonderiyor(false);
    }
  };

  return (
    <Modal baslik="ÜTS Alma Bildirimi" dar onKapat={onKapat}
      alt={<>
        <button className="d bir" disabled={gonderiyor} onClick={() => void gonder()}>
          {gonderiyor ? 'Gönderiliyor…' : '📥 ÜTS’ye Bildir'}
        </button>
        <button className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                onClick={onKapat}>Vazgeç</button>
      </>}>
      <div className="alan-izgara tek-sutun" style={{ padding: 10 }}>
        <div>
          <b>{urunNo}</b>{seriNo ? ` · Seri: ${seriNo}` : ''}<br />
          Veren: {kurumUnvan || '—'} · Askıda: {askiAdet}
        </div>
        {!tekil && (
          <label className="alan">
            <span className="etiket">Alınacak Adet</span>
            <input className="hiza-sag" value={adet} disabled={gonderiyor}
                   onChange={e => setAdet(e.target.value)} />
          </label>
        )}
        {hata && <div className="hata-kutusu">{hata}</div>}
      </div>
    </Modal>
  );
}
