import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { EFaturaMesaji } from '../../api/uclar/efatura';
import { Modal } from '../Modal';
import { MESAJ_OLAYI } from './efaturaIslem';

/**
 * MESAJ GEÇMİŞİ (Delphi TEBelgeMesajDlg): belgenin e-Fatura yolculuğu - hazırlama,
 * gönderim isteği / yanıtı, hatalar. App kökünde bir kez; menüden olayla açılır.
 */
export function EFaturaMesajKatmani() {
  const [acik, setAcik] = useState<{ belgeId: number; baslik: string } | null>(null);
  const [satirlar, setSatirlar] = useState<EFaturaMesaji[] | null>(null);
  const [hata, setHata] = useState('');
  const [secili, setSecili] = useState<number | null>(null);

  useEffect(() => {
    const dinle = (e: Event) => setAcik((e as CustomEvent).detail);
    window.addEventListener(MESAJ_OLAYI, dinle);
    return () => window.removeEventListener(MESAJ_OLAYI, dinle);
  }, []);
  useEffect(() => {
    if (!acik) return;
    setSatirlar(null); setHata(''); setSecili(null);
    api.efaturaMesajlar(acik.belgeId).then(y => setSatirlar(y.mesajlar)).catch(h => setHata(hataMetni(h)));
  }, [acik]);

  if (!acik) return null;
  const kapat = () => setAcik(null);
  const detay = secili != null ? satirlar?.[secili] : null;
  return (
    <Modal baslik={`e-Fatura Mesaj Geçmişi — ${acik.baslik}`} onKapat={kapat}
           alt={<button className="d kapat-dugmesi" onClick={kapat}>Kapat</button>}>
      <div className="kagrup">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {satirlar && satirlar.length === 0 && <div className="not" style={{ padding: 10 }}>Bu belge için henüz e-Fatura işlemi yapılmamış.</div>}
        {satirlar && satirlar.length > 0 && (
          <table className="grid">
            <thead><tr><th style={{ width: 140 }}>Tarih</th><th style={{ width: 110 }}>İşlem</th><th style={{ width: 110 }}>Tür</th>
              <th style={{ width: 60 }}>HTTP</th><th style={{ width: 70 }}>Servis</th><th>Mesaj</th><th style={{ width: 120 }}>Kullanıcı</th></tr></thead>
            <tbody>
              {satirlar.map((m, i) => (
                <tr key={i} className={secili === i ? 'secili' : m.tip === 'Hata' ? 'efm-hata' : ''} onClick={() => setSecili(i)}
                    style={{ cursor: 'pointer' }}>
                  <td>{new Date(m.tarih).toLocaleString('tr-TR')}</td><td>{m.islem}</td><td>{m.tip}</td>
                  <td>{m.httpKodu || ''}</td><td>{m.servis}</td>
                  <td style={{ maxWidth: 420, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{m.mesaj}</td>
                  <td>{m.kullanici}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
        {detay && <pre className="efm-detay">{detay.mesaj}</pre>}
      </div>
      <style>{`.efm-hata td { color: var(--kirmizi, #c0392b); }
.efm-detay { margin-top: 8px; max-height: 240px; overflow: auto; white-space: pre-wrap; word-break: break-all;
  font-size: 11px; background: var(--zemin-2, #f6f8fb); border: 1px solid var(--cizgi); padding: 6px; }`}</style>
    </Modal>
  );
}
