import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { PacsCalisma } from '../../api/uclar/dicom';
import { c } from '../../dil/ceviri';

/**
 * HASTA KARTI › PACS GÖRÜNTÜLERİ (kullanıcı 11.11.2026: "ClearCanvas'ta GENTEGRE DEMO hasta görüntüleri var, programdan
 * nasıl görürüm"): sunucu PACS'ı hasta adı (Soyad^Ad* / Ad^Soyad*) ve kimlik (dosya no / TCKN) ile C-FIND eder; her
 * çalışma OHIF'te yeni sekmede açılır (jetonlu manifest). Radyoloji istemine bağlı olmayan görüntüler de burada.
 */
const tarihYaz = (t: string) => t && t.length === 8 ? `${t.slice(6, 8)}.${t.slice(4, 6)}.${t.slice(0, 4)}` : t || '—';
const saatYaz = (s: string) => s && s.length >= 4 ? `${s.slice(0, 2)}:${s.slice(2, 4)}` : '';

export function PacsGoruntuleri({ hastaId }: { hastaId: number }) {
  const [veri, setVeri] = useState<{ aktif: boolean; calismalar: PacsCalisma[] } | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [yenile, setYenile] = useState(0);
  useEffect(() => {
    let iptal = false;
    setVeri(null); setHata(null);
    api.dicomHastaCalismalari(hastaId).then(v => { if (!iptal) setVeri(v) }).catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [hastaId, yenile]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="sonuk" style={{ padding: 12 }}>{c('PACS sorgulanıyor…')}</div>;
  if (!veri.aktif) return <div className="not" style={{ margin: 12 }}>{c('DICOM sunucusu tanımlı değil (API ayarları › Dicom).')}</div>;
  return (
    <div style={{ padding: '8px 12px' }} data-testid="hasta-pacs">
      <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 6 }}>
        <b>{veri.calismalar.length} {c('çalışma')}</b>
        <span className="sonuk" style={{ fontSize: 11 }}>{c('PACS eşlemesi: hasta adı ve dosya no / TCKN')}</span>
        <button className="d" style={{ marginLeft: 'auto' }} onClick={() => setYenile(t => t + 1)}>⟳</button>
      </div>
      <table className="hi-tablo" style={{ width: '100%' }}>
        <thead><tr>
          <th>{c('Tarih')}</th><th>{c('Modalite')}</th><th>{c('Açıklama')}</th><th>{c('Accession')}</th>
          <th className="sag">{c('Görüntü')}</th><th>{c('PACS hasta')}</th><th></th>
        </tr></thead>
        <tbody>
          {veri.calismalar.map(x => (
            <tr key={x.studyUid} className="ac" onDoubleClick={() => window.open(x.url, '_blank', 'noopener')} title={x.studyUid}>
              <td>{tarihYaz(x.tarih)} {saatYaz(x.saat)}</td>
              <td><span className="rozet mavi">{x.modaliteler || '—'}</span></td>
              <td>{x.aciklama || '—'}</td>
              <td>{x.accession || '—'}</td>
              <td className="sag">{x.adet}</td>
              <td className="sonuk">{x.hastaAd}{x.hastaNo ? ` · ${x.hastaNo}` : ''}</td>
              <td><button className="d bir" onClick={() => window.open(x.url, '_blank', 'noopener')}>🖼 {c('Aç')}</button></td>
            </tr>
          ))}
          {veri.calismalar.length === 0 && <tr><td colSpan={7} className="sonuk" style={{ padding: 12, textAlign: 'center' }}>{c('PACS\'ta bu hastaya ait çalışma bulunamadı.')}</td></tr>}
        </tbody>
      </table>
    </div>
  );
}
