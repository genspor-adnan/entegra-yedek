import { useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * KRİTİK BULGU BİLDİRİMİ (318).
 *
 * Kritik bulgu iki adımdır: radyolog raporda "kritik bulgu var" der, sonra
 * ilgili hekime HABER VERİR. İkinci adım bu ekrandır; kime, hangi yolla ve ne
 * zaman haber verildiği hukuki izdir, sözlü teyit de kayda geçer.
 *
 * Bildirim kaydı yazılınca istem takip listesinde "Teyit bekliyor"a düşer;
 * teyit işaretlenip kapatılırsa listeden çıkar.
 */

const YOLLAR = [
  { deger: 1, ad: 'Telefon' },
  { deger: 2, ad: 'Yüz yüze' },
  { deger: 3, ad: 'Mesaj / sistem' },
];

export function KritikBildirimModali({ istemId, accessionNo, hasta, tetkik, bulgu,
                                       bildirilenAd, onKapat, onTamam }: {
  istemId: number;
  accessionNo: string;
  hasta?: string;
  tetkik?: string;
  /** Rapor ekranında yazılmış bulgu metni - varsa ön dolu gelir. */
  bulgu?: string;
  /** Daha önce bildirilen hekim (yeniden bildirimde). */
  bildirilenAd?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [metin, setMetin] = useState(bulgu ?? '');
  const [kime, setKime] = useState(bildirilenAd ?? '');
  const [yol, setYol] = useState(1);
  const [teyit, setTeyit] = useState(true);
  const [not, setNot] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const kaydet = async (kapat: boolean) => {
    setHata('');
    if (!metin.trim()) { setHata('Kritik bulgu metni yazılmalı.'); return }
    if (!kime.trim()) { setHata('Bildirilen kişi yazılmalı - kime haber verildiği kayda geçmeli.'); return }
    setKaydediyor(true);
    try {
      await api.radyolojiKritikBulgu(istemId, {
        bulgu: metin, bildirilenAd: kime, yol,
        geriBildirim: not,
        teyitAlindi: teyit ? 1 : 0,
        // Teyit alinmadan takip KAPATILMAZ: kapatma "haber gitti ve karsi
        //   taraf aldigini soyledi" demektir.
        kapat: kapat && teyit,
      });
      mesaj(`Kritik bulgu bildirimi kaydedildi: ${accessionNo}`);
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Kritik Bulgu Bildirimi — ${accessionNo}`} onKapat={onKapat} dar
           alt={
             <>
               <button className="d onay" disabled={kaydediyor}
                       onClick={() => void kaydet(false)}>
                 {kaydediyor ? '⏳ Kaydediliyor…' : '📞 Bildirimi Kaydet'}
               </button>
               <button className="d" disabled={kaydediyor || !teyit}
                       title={teyit ? 'Bildirimi kaydet ve takibi kapat'
                                    : 'Kapatmak için teyit alınmış olmalı'}
                       onClick={() => void kaydet(true)}>✔ Kaydet ve Kapat</button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>{hasta ?? ''}{tetkik ? ` · ${tetkik}` : ''}</h6>
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket zorunlu-isaret">Kritik Bulgu</span>
            <textarea rows={3} value={metin} maxLength={300}
                      onChange={e => setMetin(e.target.value)} />
          </label>
          <label className="alan">
            <span className="etiket zorunlu-isaret">Bildirilen kişi</span>
            <input value={kime} maxLength={120} placeholder="ör. Acil Servis · Dr. M. Şen"
                   onChange={e => setKime(e.target.value)} />
          </label>
          <label className="alan">
            <span className="etiket">Bildirim yolu</span>
            <select value={yol} onChange={e => setYol(Number(e.target.value))}>
              {YOLLAR.map(y => <option key={y.deger} value={y.deger}>{y.ad}</option>)}
            </select>
          </label>
          <label className="alan onay-satiri">
            <input type="checkbox" checked={teyit} onChange={e => setTeyit(e.target.checked)} />
            <span>Karşı taraf bulguyu aldığını <b>teyit etti</b></span>
          </label>
          <label className="alan">
            <span className="etiket">Not</span>
            <input value={not} maxLength={300}
                   placeholder="ör. hasta acile alındı, tedavi başlandı"
                   onChange={e => setNot(e.target.value)} />
          </label>
        </div>
        <div className="not">
          Bildirim kaydı silinmez: kime, hangi yolla ve ne zaman haber verildiği
          hasta güvenliği kaydıdır. Teyit alınmadıysa takip <b>açık</b> kalır ve
          listede süre saymaya devam eder.
        </div>
      </div>
    </Modal>
  );
}
