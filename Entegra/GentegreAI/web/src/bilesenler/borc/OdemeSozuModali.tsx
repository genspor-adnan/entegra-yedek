import { useState } from 'react';
import { api } from '../../api/istemci';
import { paraYaz } from '../bicim';
import { guvenli, mesaj } from '../mesaj';
import { Modal } from '../Modal';
import { c } from '../../dil/ceviri';

/**
 * ÖDEME SÖZÜ / PLANI PENCERESİ (kullanıcı 19.11.2026: "hasta borç takibi listesinde ödeme sözü plan modal olarak
 * açılsın.. başvuru tahsilat sekmesindeyken de çağrılabilsin.. 3 nokta menü en alta Ödeme Sözü/Plan").
 *
 * Hasta Borç Takibi'ndeki satır içi formun yerine; aynı pencere başvuru kartının Tahsilat sekmesi "⋯" menüsünden de
 * açılır. Kayıt hasta bazında (`/api/hasta-borc/soz`): hastanın mevcut sözü / planı sunucuda kaldırılıp yenisi yazılır.
 * Plan kaydı: toplam tutar + ilk taksit tarihi + taksit sayısı. Penceredeki taksit tablosu yalnız bilgi (eşit bölüm,
 * ayda bir; kuruş farkı son taksitte) - hastaya söylenecek tutarları görmek için.
 */
const bugun = () => new Date().toLocaleDateString('sv-SE');
const ayEkle = (g: string, n: number) => {
  const [y, a, d] = g.split('-').map(Number);
  const t = new Date(y, a - 1 + n, 1);
  const son = new Date(t.getFullYear(), t.getMonth() + 1, 0).getDate();
  t.setDate(Math.min(d, son));
  return t.toLocaleDateString('sv-SE');
};
const tr = (g: string) => g.split('-').reverse().join('.');

export function OdemeSozuModali({ hastaId, hastaAdi, borc, borcEtiketi, mevcutVar, onKapat, onKaydedildi }: {
  hastaId: number;
  hastaAdi: string;
  /** Varsayılan tutar (borç takibinde hastanın açık borcu, başvuruda bu başvurunun hasta payı kalanı). */
  borc: number;
  /** Borç tutarının ne olduğu ("açık borç" / "bu başvurunun kalanı"). */
  borcEtiketi?: string;
  /** Hastanın kayıtlı sözü / planı var mı (biliniyorsa uyarı). */
  mevcutVar?: boolean;
  onKapat(): void;
  onKaydedildi?(): void;
}) {
  const [tur, setTur] = useState<2 | 3>(2);
  const [tutar, setTutar] = useState(borc > 0 ? String(Math.round(borc * 100) / 100) : '');
  const [vade, setVade] = useState(bugun());
  const [taksit, setTaksit] = useState('3');
  const [aciklama, setAciklama] = useState('');
  const [calisiyor, setCalisiyor] = useState(false);

  const sayi = Number(tutar.replace(',', '.')) || 0;
  const n = Math.max(2, Math.min(36, Number(taksit) || 0));
  const taksitler = tur === 3 && sayi > 0 && Number(taksit) >= 2
    ? Array.from({ length: n }, (_, i) => {
        const pay = Math.floor((sayi / n) * 100) / 100;
        return { tarih: ayEkle(vade, i), tutar: i === n - 1 ? Math.round((sayi - pay * (n - 1)) * 100) / 100 : pay };
      })
    : [];

  const kaydet = () => void guvenli(async () => {
    if (!(sayi > 0)) { mesaj(c('Tutar girin.')); return }
    if (!vade) { mesaj(c('Tarih seçin.')); return }
    if (tur === 3 && !(Number(taksit) >= 2 && Number(taksit) <= 36)) { mesaj(c('Taksit sayısı 2 ile 36 arasında olmalı.')); return }
    setCalisiyor(true);
    try {
      await api.hastaBorcSoz({ hastaId, tur, tutar: sayi, vade,
        taksitSayisi: tur === 3 ? Number(taksit) : undefined, aciklama: aciklama.trim() });
      mesaj(tur === 3 ? c('Ödeme planı kaydedildi.') : c('Ödeme sözü kaydedildi.'));
      onKaydedildi?.();
      onKapat();
    } finally { setCalisiyor(false) }
  });

  return (
    <Modal baslik={`🤝 ${c('Ödeme Sözü / Plan')} — ${hastaAdi}`} dar buyutmeYok onKapat={onKapat}
           alt={<>
             <button type="button" className="d bir" disabled={calisiyor} onClick={kaydet}>💾 {c('Kaydet')}</button>
             {/* "Kapat" sağa yaslı (kullanıcı 19.11.2026). */}
             <button type="button" className="d" style={{ marginLeft: 'auto' }} onClick={onKapat}>✖ {c('Kapat')}</button>
           </>}>
      <div className="kagrup os-pencere">
        <div className="os-ust">
          <span className="sonuk">{borcEtiketi ?? c('Açık borç')}</span> <b>{paraYaz(borc)}</b>
          {mevcutVar && <span className="kucuk sonuk"> · {c('Mevcut söz / plan kaydedince kaldırılır.')}</span>}
        </div>
        <div className="cipler">
          <button type="button" className={`cip${tur === 2 ? ' on' : ''}`} onClick={() => setTur(2)}>🤝 {c('Ödeme sözü')}</button>
          <button type="button" className={`cip${tur === 3 ? ' on' : ''}`} onClick={() => setTur(3)}>📅 {c('Ödeme planı (taksit)')}</button>
        </div>
        <div className="alan-izgara tek-sutun">
          <label className="alan"><span className="etiket zorunlu-isaret">{c('Tutar')}</span>
            <input value={tutar} inputMode="decimal" aria-label={c('Tutar')} onChange={e => setTutar(e.target.value)} /></label>
          <label className="alan"><span className="etiket zorunlu-isaret">{tur === 3 ? c('İlk taksit') : c('Söz tarihi (vade)')}</span>
            <input type="date" value={vade} min={bugun()} aria-label={c('Tarih')} onChange={e => setVade(e.target.value)} /></label>
          {tur === 3 && (
            <label className="alan"><span className="etiket zorunlu-isaret">{c('Taksit sayısı')}</span>
              <input type="number" min={2} max={36} value={taksit} aria-label={c('Taksit sayısı')}
                     onChange={e => setTaksit(e.target.value)} /></label>
          )}
          <label className="alan"><span className="etiket">{c('Açıklama')}</span>
            <input value={aciklama} maxLength={300} placeholder={c('ör. maaş gününde ödeyecek')}
                   onChange={e => setAciklama(e.target.value)} /></label>
        </div>
        {taksitler.length > 0 && (
          <table className="detay-tablo os-taksit">
            <thead><tr><th>#</th><th>{c('Tarih')}</th><th className="hiza-sag">{c('Tutar')}</th></tr></thead>
            <tbody>{taksitler.map((t, i) => (
              <tr key={i}><td>{i + 1}</td><td>{tr(t.tarih)}</td><td className="hiza-sag">{paraYaz(t.tutar)}</td></tr>
            ))}</tbody>
          </table>
        )}
      </div>
    </Modal>
  );
}
