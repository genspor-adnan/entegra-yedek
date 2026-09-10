import { useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * CİHAZ KAPATMA (318) - bakım / arıza / tatil.
 *
 * Kapatılan aralık randevuya kapalıdır; kural veritabanı tetiğindedir (316),
 * bu ekran onu YAZAR ve takvimde taralı blok olarak görünür kılar.
 *
 * Aralığa düşen MEVCUT randevular otomatik taşınmaz: tetik yalnız yeni/değişen
 * kaydı denetler. Kaç randevunun etkilendiği kaydettikten sonra bildirilir -
 * kullanıcı onları elle taşımalıdır.
 */

const NEDENLER = [
  { deger: 1, ad: 'Bakım / kalibrasyon' },
  { deger: 2, ad: 'Arıza' },
  { deger: 3, ad: 'Tatil / izin' },
  { deger: 9, ad: 'Diğer' },
];

export function CihazKapatmaModali({ cihazId, cihazAdi, baslangic, bitis,
                                     onKapat, onTamam }: {
  cihazId: number;
  cihazAdi: string;
  /** Takvimde işaretlenen aralık (yerel "yyyy-MM-ddTHH:mm"). */
  baslangic: string;
  bitis: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [bas, setBas] = useState(baslangic);
  const [bit, setBit] = useState(bitis);
  const [neden, setNeden] = useState(1);
  const [aciklama, setAciklama] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const kaydet = async () => {
    setHata('');
    if (bit <= bas) { setHata('Bitiş, başlangıçtan sonra olmalı.'); return }
    setKaydediyor(true);
    try {
      const y = await api.radyolojiKapatmaEkle(cihazId, {
        baslangic: bas, bitis: bit, nedenTur: neden, aciklama,
      });
      mesaj(y.etkilenenRandevu > 0
        ? `Cihaz kapatıldı. DİKKAT: bu aralıkta ${y.etkilenenRandevu} randevu var — `
          + 'taşınmaları gerekiyor.'
        : 'Cihaz kapatıldı.');
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Cihazı Kapat — ${cihazAdi}`} onKapat={onKapat} dar
           alt={
             <>
               <button className="d onay" disabled={kaydediyor} onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Kaydediliyor…' : '🔒 Kapatmayı Kaydet'}
               </button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>Kapatma</h6>
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket zorunlu-isaret">Neden</span>
            <select value={neden} onChange={e => setNeden(Number(e.target.value))}>
              {NEDENLER.map(n => <option key={n.deger} value={n.deger}>{n.ad}</option>)}
            </select>
          </label>
          <label className="alan">
            <span className="etiket zorunlu-isaret">Başlangıç</span>
            <input type="datetime-local" value={bas} onChange={e => setBas(e.target.value)} />
          </label>
          <label className="alan">
            <span className="etiket zorunlu-isaret">Bitiş</span>
            <input type="datetime-local" value={bit} onChange={e => setBit(e.target.value)} />
          </label>
          <label className="alan">
            <span className="etiket">Açıklama</span>
            <input value={aciklama} maxLength={200}
                   placeholder="ör. yıllık kalibrasyon — teknik servis"
                   onChange={e => setAciklama(e.target.value)} />
          </label>
        </div>
        <div className="not">
          Kapalı aralık takvimde <b>taralı</b> görünür ve o saatlere randevu
          verilemez. Aralıkta <b>mevcut randevu</b> varsa otomatik taşınmaz —
          kaydettikten sonra kaç randevunun etkilendiği bildirilir.
        </div>
      </div>
    </Modal>
  );
}
