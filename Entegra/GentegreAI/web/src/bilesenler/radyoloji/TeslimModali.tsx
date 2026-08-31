import { useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * SONUC TESLIMI (304). Film / CD / basili rapor kime verildi.
 *
 * Sema (283) vardi ama girisi yoktu. Hasta disinda biri aliyorsa YAKINLIK ve
 * kimlik dogrulamasi kayda gecer: sonuc kisisel saglik verisidir, "kime
 * verdik" sorusunun cevabi belgede durmali.
 */

const TESLIM_TURU = [
  { deger: 2, ad: 'Basılı Rapor' },
  { deger: 3, ad: 'CD / DVD' },
  { deger: 4, ad: 'Film' },
  { deger: 1, ad: 'Hasta Portalı' },
  { deger: 5, ad: 'e-Posta' },
];

export function TeslimModali({ istemId, accessionNo, onKapat, onTamam }: {
  istemId: number;
  accessionNo?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [tur, setTur] = useState(2);
  const [alanAd, setAlanAd] = useState('');
  const [yakinlik, setYakinlik] = useState('');
  const [kimlik, setKimlik] = useState(true);
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);

  const kaydet = async () => {
    setHata('');
    if (!alanAd.trim()) { setHata('Teslim alan kişi yazılmalı.'); return }
    setKaydediyor(true);
    try {
      await api.radyolojiTeslim(istemId, {
        tur, alanAd, alanYakinlik: yakinlik,
        kimlikDogrulandi: kimlik ? 1 : 0, aciklama,
      });
      mesaj('Teslim kaydedildi.');
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Sonuç Teslimi${accessionNo ? ` — ${accessionNo}` : ''}`} dar
           onKapat={onKapat}
           alt={
             <>
               <button className="d onay" disabled={kaydediyor}
                       onClick={() => void kaydet()}>✔ Teslim Et</button>
               <button className="d" onClick={onKapat}>✖ Vazgeç</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}
      <div className="alan-izgara tek-sutun">
        <label className="alan">
          <span className="etiket">Teslim Türü</span>
          <select value={tur} onChange={e => setTur(Number(e.target.value))}>
            {TESLIM_TURU.map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
          </select>
        </label>
        <label className="alan">
          <span className="etiket zorunlu-isaret">Teslim Alan</span>
          <input value={alanAd} placeholder="Ad Soyad"
                 onChange={e => setAlanAd(e.target.value)} />
        </label>
        {/* Yakinlik yalniz hasta DISINDA biri alirken anlamli - bos gecilebilir. */}
        <label className="alan">
          <span className="etiket">Yakınlık</span>
          <input value={yakinlik} placeholder="örn. Hastanın kendisi / Eşi / Oğlu"
                 onChange={e => setYakinlik(e.target.value)} />
        </label>
        <label className="alan">
          <span className="etiket">Kimlik</span>
          <span className="deger-serit">
            <input type="checkbox" checked={kimlik}
                   onChange={e => setKimlik(e.target.checked)} />
            <span>Kimlik doğrulandı</span>
          </span>
        </label>
        <label className="alan">
          <span className="etiket">Açıklama</span>
          <input value={aciklama} onChange={e => setAciklama(e.target.value)} />
        </label>
      </div>
      <div className="not">
        Sonuç kişisel sağlık verisidir: hasta dışında biri alıyorsa yakınlığı ve
        kimlik doğrulamasını mutlaka işaretleyin.
      </div>
    </Modal>
  );
}
