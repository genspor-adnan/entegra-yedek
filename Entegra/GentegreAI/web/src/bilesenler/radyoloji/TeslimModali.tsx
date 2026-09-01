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

/**
 * TESLIM KALEMLERI (318): bir teslimde hastaya AYNI ANDA rapor + film + CD
 * verilir - tek "tür" secimi bunu anlatamiyordu. Eski `tur` kolonu geriye
 * donuk uyumluluk icin ilk isaretli kalemden turetilir.
 */
const KALEMLER = [
  { anahtar: 'rapor',   ad: 'Rapor (basılı)', tur: 2 },
  { anahtar: 'film',    ad: 'Film',           tur: 4 },
  { anahtar: 'cd',      ad: 'CD / DVD',       tur: 3 },
  { anahtar: 'dijital', ad: 'Dijital bağlantı / e-posta', tur: 5 },
] as const;

export function TeslimModali({ istemId, accessionNo, cdIstendi, onKapat, onTamam }: {
  istemId: number;
  accessionNo?: string;
  /** Kabulde "CD istendi" isaretliyse CD kutusu onden isaretli gelir (311). */
  cdIstendi?: boolean;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [secili, setSecili] = useState<Record<string, boolean>>(
    { rapor: true, film: false, cd: !!cdIstendi, dijital: false });
  const [alanAd, setAlanAd] = useState('');
  const [yakinlik, setYakinlik] = useState('');
  const [kimlik, setKimlik] = useState(true);
  const [aciklama, setAciklama] = useState('');
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);

  const kaydet = async () => {
    setHata('');
    if (!alanAd.trim()) { setHata('Teslim alan kişi yazılmalı.'); return }
    const isaretli = KALEMLER.filter(k => secili[k.anahtar]);
    if (isaretli.length === 0) { setHata('En az bir teslim kalemi seçilmeli.'); return }
    setKaydediyor(true);
    try {
      await api.radyolojiTeslim(istemId, {
        // Eski tek-deger kolonu: ilk isaretli kalem (geriye donuk uyum).
        tur: isaretli[0].tur,
        raporVerildi:   secili.rapor ? 1 : 0,
        filmVerildi:    secili.film ? 1 : 0,
        cdVerildi:      secili.cd ? 1 : 0,
        dijitalVerildi: secili.dijital ? 1 : 0,
        alanAd, alanYakinlik: yakinlik,
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
          <span className="etiket zorunlu-isaret">Teslim edilen</span>
          <span className="deger-serit" style={{ flexWrap: 'wrap', gap: 12 }}>
            {KALEMLER.map(k => (
              <label key={k.anahtar} className="satir-ici">
                <input type="checkbox" checked={!!secili[k.anahtar]}
                       onChange={e => setSecili(s => ({ ...s, [k.anahtar]: e.target.checked }))} />
                {k.ad}
              </label>
            ))}
          </span>
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
