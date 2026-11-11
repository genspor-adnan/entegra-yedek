import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { PacsCalisma } from '../../api/uclar/dicom';
import { guvenli, mesaj } from '../mesaj';
import { c } from '../../dil/ceviri';

/**
 * RADYOLOJİ İSTEM KARTI › PACS GÖRÜNTÜLERİ (kullanıcı 11.11.2026: "ClearCanvas'ta GENTEGRE DEMO hasta görüntüleri var,
 * programdan nasıl görürüm"; "hasta kartındaki PACS görüntülerini rad istem kartına taşı"): sunucu PACS'ı hastanın adı
 * (Soyad^Ad* / Ad^Soyad*) ve kimliği (dosya no / TCKN) ile C-FIND eder; her çalışma OHIF'te yeni sekmede açılır (jetonlu
 * manifest). İstemin kendi çalışması (study_uid ya da accession eşleşen) vurgulu; eşleşmeyen çalışma "🔗 Bağla" ile
 * isteme yazılır (study_uid) - sonra "🖼 Görüntüle" ve rapor onu açar.
 */
const tarihYaz = (t: string) => t && t.length === 8 ? `${t.slice(6, 8)}.${t.slice(4, 6)}.${t.slice(0, 4)}` : t || '—';
const saatYaz = (s: string) => s && s.length >= 4 ? `${s.slice(0, 2)}:${s.slice(2, 4)}` : '';

export function PacsGoruntuleri({ hastaId, istemId, vurguStudyUid, vurguAccession, bagliDegisti }: {
  hastaId: number; istemId?: number; vurguStudyUid?: string; vurguAccession?: string; bagliDegisti?(): void;
}) {
  const [veri, setVeri] = useState<{ aktif: boolean; calismalar: PacsCalisma[] } | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [yenile, setYenile] = useState(0);
  useEffect(() => {
    let iptal = false;
    setVeri(null); setHata(null);
    api.dicomHastaCalismalari(hastaId).then(v => { if (!iptal) setVeri(v) }).catch(h => { if (!iptal) setHata(hataMetni(h)) });
    return () => { iptal = true };
  }, [hastaId, yenile]);

  const bagla = (x: PacsCalisma) => guvenli(async () => {
    if (!istemId) return;
    const y = await api.dicomBagla({ istemId, studyUid: x.studyUid });
    mesaj(y.mesaj); bagliDegisti?.();
  });
  const benim = (x: PacsCalisma) => (!!vurguStudyUid && x.studyUid === vurguStudyUid)
    || (!vurguStudyUid && !!vurguAccession && x.accession === vurguAccession);
  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="sonuk" style={{ padding: 12 }}>{c('PACS sorgulanıyor…')}</div>;
  if (!veri.aktif) return <div className="not" style={{ margin: 12 }}>{c('DICOM sunucusu tanımlı değil (API ayarları › Dicom).')}</div>;
  return (
    <div data-testid="istem-pacs">
      <div style={{ display: 'flex', gap: 8, alignItems: 'center', marginBottom: 6 }}>
        <b>{veri.calismalar.length} {c('çalışma')}</b>
        <span className="sonuk" style={{ fontSize: 11 }}>{c('PACS eşlemesi: hasta adı ve dosya no / TCKN')}</span>
        <button className="d" style={{ marginLeft: 'auto' }} onClick={() => setYenile(t => t + 1)}>⟳</button>
      </div>
      <table className="hi-tablo" style={{ width: '100%' }}>
        {/* Düğmeler tek satır (kırılınca "🖼" ve "Aç" ayrı satıra düşüyordu). */}
        <style>{`[data-testid="istem-pacs"] td button { white-space: nowrap }`}</style>
        <thead><tr>
          <th>{c('Tarih')}</th><th>{c('Modalite')}</th><th>{c('Açıklama')}</th><th>{c('Accession')}</th>
          <th className="sag">{c('Görüntü')}</th><th>{c('PACS hasta')}</th><th>{c('Bu istem')}</th><th></th>
        </tr></thead>
        <tbody>
          {veri.calismalar.map(x => (
            <tr key={x.studyUid} className={`ac${benim(x) ? ' secili' : ''}`} onDoubleClick={() => window.open(x.url, '_blank', 'noopener')} title={x.studyUid}>
              <td>{tarihYaz(x.tarih)} {saatYaz(x.saat)}</td>
              <td><span className="rozet mavi">{x.modaliteler || '—'}</span></td>
              <td>{x.aciklama || '—'}</td>
              <td>{x.accession || '—'}</td>
              <td className="sag">{x.adet}</td>
              <td className="sonuk">{x.hastaAd}{x.hastaNo ? ` · ${x.hastaNo}` : ''}</td>
              <td>{benim(x) ? <span className="rozet olumlu">✓ {c('bağlı')}</span>
                   : istemId ? <button className="d" title={c('Bu çalışmayı isteme bağla (study_uid)')} onClick={() => void bagla(x)}>🔗 {c('Bağla')}</button> : null}</td>
              <td><button className="d bir" onClick={() => window.open(x.url, '_blank', 'noopener')}>🖼 {c('Aç')}</button></td>
            </tr>
          ))}
          {veri.calismalar.length === 0 && <tr><td colSpan={8} className="sonuk" style={{ padding: 12, textAlign: 'center' }}>{c('PACS\'ta bu hastaya ait çalışma bulunamadı.')}</td></tr>}
        </tbody>
      </table>
    </div>
  );
}
