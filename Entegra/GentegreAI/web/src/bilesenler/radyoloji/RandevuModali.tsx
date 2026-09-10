import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';

/**
 * İSTEME RANDEVU VERME (316).
 *
 * Radyoloji randevusu AYRI BİR MODÜL DEĞİL: kayıt yine public.randevu'ya
 * gider, yalnız kaynağı hekim değil CİHAZ olur. Bu yüzden ekran da küçük -
 * çakışma, kapasite ve cihaz kapatma kuralları veritabanı tetiğinde (316).
 *
 * SÜRE sırası: burada elle verilen > tetkikin çekim protokolü (314) >
 * cihazın varsayılan süresi. Kullanıcı protokol süresini görür, gerekirse ezer.
 */

interface Cihaz {
  id: number; ad: string; kod: string; modalite: number;
  slotDk: number; varsayilanSure: number; mesai: string;
}

/** "2026-09-01T09:00" - datetime-local'in beklediği biçim, YEREL saat. */
const yerelZaman = (t: Date) =>
  new Date(t.getTime() - t.getTimezoneOffset() * 60000).toISOString().slice(0, 16);

export function RandevuModali({ istemId, accessionNo, tetkikAdi, modalite, sureDk,
                                onKapat, onTamam }: {
  istemId: number;
  accessionNo: string;
  tetkikAdi?: string;
  modalite?: number;
  /** Tetkikin protokol süresi (314) - 0 ise cihaz varsayılanı kullanılır. */
  sureDk?: number;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [cihazlar, setCihazlar] = useState<Cihaz[]>([]);
  const [cihazId, setCihazId] = useState<number | ''>('');
  const [baslangic, setBaslangic] = useState(() => yerelZaman(new Date()));
  const [sure, setSure] = useState<number>(sureDk && sureDk > 0 ? sureDk : 0);
  const [aciklama, setAciklama] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);
  const [hata, setHata] = useState('');

  const yukle = useCallback(async () => {
    try {
      const y = await api.liste('radyoloji-cihaz', {
        sayfa: 1, boyut: 50,
        filtre: { op: 'and', kosullar: [
          { alan: 'durum', op: 'esit', deger: 1 },
          { alan: 'randevuVerilir', op: 'esit', deger: 1 },
        ] },
      });
      const liste = y.satirlar.map(r => ({
        id: Number(r.id), ad: String(r.ad ?? ''), kod: String(r.kod ?? ''),
        modalite: Number(r.modalite ?? 0), slotDk: Number(r.slotDk ?? 15),
        varsayilanSure: Number(r.varsayilanSure ?? 15), mesai: String(r.mesai ?? ''),
      })) as Cihaz[];
      setCihazlar(liste);
      // AYNI MODALITEDEKI ilk cihaz onden secili: MR istemine BT cihazi
      //   secilmesi kullanicinin isi degil, ekranin hatasidir.
      const uygun = liste.find(c => !modalite || c.modalite === modalite);
      if (uygun) setCihazId(uygun.id);
    } catch (h) { setHata(hataMetni(h)) }
  }, [modalite]);

  useEffect(() => { void yukle() }, [yukle]);

  const secili = cihazlar.find(c => c.id === cihazId);
  const gecerliSure = sure > 0 ? sure : (secili?.varsayilanSure ?? 15);

  const kaydet = async () => {
    setHata('');
    if (!cihazId) { setHata('Cihaz seçilmeli.'); return }
    setKaydediyor(true);
    try {
      await api.radyolojiRandevuVer(istemId, {
        cihazId, baslangic, sureDk: gecerliSure, aciklama,
      });
      mesaj(`Randevu verildi: ${accessionNo}`);
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Randevu Ver — ${accessionNo}`} onKapat={onKapat} dar
           alt={
             <>
               <button className="d onay" disabled={kaydediyor} onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Veriliyor…' : '📅 Randevuyu Ver'}
               </button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>Randevu</h6>
        <div className="alan-izgara tek-sutun">
          <label className="alan">
            <span className="etiket">Tetkik</span>
            <input readOnly value={tetkikAdi ?? ''} />
          </label>
          <label className="alan">
            <span className="etiket zorunlu-isaret">Cihaz</span>
            <select value={cihazId}
                    onChange={e => setCihazId(e.target.value ? Number(e.target.value) : '')}>
              <option value="">— seçiniz —</option>
              {cihazlar.map(c => (
                <option key={c.id} value={c.id}>
                  {c.ad}{c.mesai ? ` · ${c.mesai}` : ''}
                </option>
              ))}
            </select>
          </label>
          <label className="alan">
            <span className="etiket zorunlu-isaret">Tarih / Saat</span>
            <input type="datetime-local" value={baslangic}
                   onChange={e => setBaslangic(e.target.value)} />
          </label>
          <label className="alan">
            <span className="etiket">Süre (dk)</span>
            <span className="ikili">
              <input type="number" min={1} value={gecerliSure}
                     onChange={e => setSure(Number(e.target.value))} />
              <span className="alan-notu">
                {sureDk && sureDk > 0 ? 'çekim protokolünden' : 'cihaz varsayılanı'}
              </span>
            </span>
          </label>
          <label className="alan">
            <span className="etiket">Not</span>
            <input value={aciklama} maxLength={200}
                   onChange={e => setAciklama(e.target.value)} />
          </label>
        </div>
        <div className="not">
          Randevu <b>public.randevu</b>'ya yazılır (kaynağı cihaz); çakışma, cihaz
          kapasitesi ve bakım/tatil kapatmaları veritabanı kuralıyla engellenir.
          Kaydedince istemin akış şeridinde <b>Randevu</b> adımı yeşile döner.
        </div>
      </div>
    </Modal>
  );
}
