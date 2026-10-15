import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { Modal } from '../../bilesenler/Modal';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';

export type KonsIslem = 'yonlendir' | 'reddet';

/**
 * YÖNLENDİR / REDDET (mockup konsultasyon_karti.html - 3). Gerekçe zorunlu; yönlendirmede
 * istem kapanmaz, yeni hedefe taşınır ve süre sayacı sıfırlanmaz. Bölüm / hekim seçenekleri
 * kartın kendi metasından (karttaki hedef alanlarıyla aynı liste).
 */
export function KonsultasyonIslemPenceresi({ id, islem: ilk, onKapat, onTamam }: {
  id: number; islem: KonsIslem; onKapat(): void; onTamam(): void;
}) {
  const [islem, setIslem] = useState<KonsIslem>(ilk);
  const [bolumler, setBolumler] = useState<[string, string][]>([]);
  const [hekimler, setHekimler] = useState<[string, string][]>([]);
  const [bolum, setBolum] = useState('');
  const [hekim, setHekim] = useState('');
  const [gerekce, setGerekce] = useState('');
  const [calisiyor, setCalisiyor] = useState(false);
  useEffect(() => {
    void api.kartAlanlari('konsultasyon').then(m => {
      const kod = (ad: string) => Object.entries(m.alanlar.find(a => a.ad === ad)?.kodlar ?? {})
        .sort((a, b) => a[1].localeCompare(b[1], 'tr'));
      setBolumler(kod('hedefBolumId')); setHekimler(kod('hedefHekimId'));
    }).catch(() => { /* seçenek yoksa kutu boş kalır */ });
  }, []);

  const gonder = () => guvenli(async () => {
    if (!gerekce.trim()) { mesaj(c('Gerekçe zorunlu.')); return }
    if (islem === 'yonlendir' && !bolum) { mesaj(c('Yeni hedef bölümü seçin.')); return }
    setCalisiyor(true);
    try {
      const y = islem === 'yonlendir'
        ? await api.konsultasyonYonlendir(id, Number(bolum), hekim ? Number(hekim) : null, gerekce.trim())
        : await api.konsultasyonReddet(id, gerekce.trim());
      mesaj(y.mesaj);
      onTamam();
    } finally { setCalisiyor(false) }
  });

  return (
    <Modal baslik={c('↪ Konsültasyonu Yönlendir / Reddet')} dar buyutmeYok onKapat={onKapat}
      alt={<>
        <button type="button" className="d" onClick={onKapat}>{c('Vazgeç')}</button>
        <span style={{ flex: 1 }} />
        <button type="button" className={`d ${islem === 'reddet' ? 'sil' : 'bir'}`} disabled={calisiyor} onClick={() => void gonder()}>
          {islem === 'yonlendir' ? c('Yönlendir') : c('Reddet')}</button>
      </>}>
      <div className="kns-form">
        <label>{c('İşlem')}</label>
        <div className="kns-secim">
          <button type="button" className={islem === 'yonlendir' ? 'on' : ''} onClick={() => setIslem('yonlendir')}>{c('Yönlendir')}</button>
          <button type="button" className={islem === 'reddet' ? 'on' : ''} onClick={() => setIslem('reddet')}>{c('Reddet')}</button>
        </div>
        {islem === 'yonlendir' && <>
          <label>{c('Yeni hedef bölüm')} *</label>
          <select value={bolum} onChange={e => setBolum(e.target.value)}>
            <option value="">{c('— seçin —')}</option>
            {bolumler.map(([k, a]) => <option key={k} value={k}>{a}</option>)}
          </select>
          <label>{c('Hekim')}</label>
          <select value={hekim} onChange={e => setHekim(e.target.value)}>
            <option value="">{c('Bölüme gönder (bölümün hekimi yanıtlar)')}</option>
            {hekimler.map(([k, a]) => <option key={k} value={k}>{a}</option>)}
          </select>
        </>}
        <label>{c('Gerekçe')} *</label>
        <textarea rows={3} maxLength={400} value={gerekce} onChange={e => setGerekce(e.target.value)} />
      </div>
      <div className="uyari-kutusu bilgi">
        {islem === 'yonlendir'
          ? c('İstem kapanmaz, yeni hedefe taşınır; süre sayacı sıfırlanmaz. İsteyen hekim bilgilenir.')
          : c('İstem gerekçeyle kapanır; isteyen hekim bilgilenir ve yeni istek açabilir.')}
      </div>
    </Modal>
  );
}
