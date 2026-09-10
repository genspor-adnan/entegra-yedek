import { useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * KONSÜLTASYON CEVABI (318).
 *
 * İstek rapor ekranından yazılır; cevap çoğunlukla BAŞKA biri tarafından ve
 * başka bir zamanda yazılır - bu yüzden takip listesinden açılan küçük bir
 * pencere. Cevap yazılınca kayıt "Cevaplandı"ya döner ve rapor askıdan çıkar.
 */
export function KonsultasyonCevapModali({ istemId, konsultasyonId, accessionNo,
                                          hasta, tetkik, soru, mevcutGorus,
                                          onKapat, onTamam }: {
  istemId: number;
  konsultasyonId: number;
  accessionNo: string;
  hasta?: string;
  tetkik?: string;
  soru?: string;
  mevcutGorus?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [gorus, setGorus] = useState(mevcutGorus ?? '');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const kaydet = async () => {
    setHata('');
    if (!gorus.trim()) { setHata('Görüş yazılmalı.'); return }
    setKaydediyor(true);
    try {
      // Gorus dolu gonderilince uc kaydi "donmus" (durum 2) sayar - ayri bir
      //   "cevapla" ucu yok, ayni uc iki isi de goruyor.
      await api.radyolojiKonsultasyon(istemId, { gorus }, konsultasyonId);
      mesaj(`Konsültasyon cevabı kaydedildi: ${accessionNo}`);
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Konsültasyon Cevabı — ${accessionNo}`} onKapat={onKapat} dar
           alt={
             <>
               <button className="d onay" disabled={kaydediyor} onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Kaydediliyor…' : '✔ Cevabı Kaydet'}
               </button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>{hasta ?? ''}{tetkik ? ` · ${tetkik}` : ''}</h6>
        {soru && (
          <div className="not" style={{ margin: '0 10px 8px' }}>
            <b>Sorulan:</b> {soru}
          </div>
        )}
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket zorunlu-isaret">Görüş</span>
            <textarea rows={6} value={gorus}
                      onChange={e => setGorus(e.target.value)} />
          </label>
        </div>
        <div className="not">
          Cevap kaydedilince konsültasyon <b>Cevaplandı</b>'ya döner ve rapora
          iliştirilir.
        </div>
      </div>
    </Modal>
  );
}
