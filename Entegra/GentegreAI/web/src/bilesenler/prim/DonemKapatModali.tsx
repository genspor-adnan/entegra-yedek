import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { mesaj } from '../mesaj';
import { para } from '../bicim';

/**
 * HAKEDİŞ DÖNEMİ KAPATMA (324).
 *
 * Kapatma, kişinin o dönemdeki AÇIK prim satırlarını bir başlığa bağlar ve
 * DONDURUR: kesinleşen satır artık yeniden hesaplanmaz. Sonradan çıkan fark
 * (belge türü değişti, rol düzeltildi, tahsilat iptal edildi) sonraki döneme
 * düzeltme satırı olarak girer.
 *
 * Geri alınamaz olduğu için ayrı yetki ister (prim.donem_kapat).
 */

interface AcikSatir {
  tarafId: number; kisi: string; acikSatir: number; acikTutar: number;
  /** Gelir belgesi kesilmemis (taslak) prim - 339'dan beri URETILMIYOR;
      alanlar eski kayitlar icin sunucuda duruyor, ekranda gosterilmiyor. */
  taslakSatir: number; taslakTutar: number;
  kapananTutar: number; ilkTarih?: string | null; sonTarih?: string | null;
}

/**
 * Ayın ilk/son günü (YEREL) - varsayılan dönem geçen ay değil, bu aydır.
 *
 * toISOString KULLANILMAZ: UTC'ye çevirir ve TR'de (UTC+3) ayın ilk günü bir
 * önceki aya kayar ("01.09" yerine "31.08"). Tarih burada takvim günüdür,
 * an değil - yerel parçalardan kurulur.
 */
const gunMetni = (t: Date) =>
  `${t.getFullYear()}-${String(t.getMonth() + 1).padStart(2, '0')}`
  + `-${String(t.getDate()).padStart(2, '0')}`;
const ayBasi = () => {
  const t = new Date();
  return gunMetni(new Date(t.getFullYear(), t.getMonth(), 1));
};
const ayBitisi = () => {
  const t = new Date();
  return gunMetni(new Date(t.getFullYear(), t.getMonth() + 1, 0));
};

export function DonemKapatModali({ tarafId, kisi, onKapat, onTamam }: {
  /** Listeden seçilen satırın kişisi - boşsa listeden seçilir. */
  tarafId?: number;
  kisi?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [acik, setAcik] = useState<AcikSatir[]>([]);
  const [secili, setSecili] = useState<number | null>(tarafId ?? null);
  const [bas, setBas] = useState(ayBasi);
  const [bit, setBit] = useState(ayBitisi);
  const [hata, setHata] = useState('');
  const [calisiyor, setCalisiyor] = useState(false);

  const yukle = useCallback(async () => {
    setHata('');
    try {
      const y = await api.primAcikHakedis();
      setAcik(y.map(r => ({
        tarafId: Number(r.tarafId), kisi: String(r.kisi ?? ''),
        acikSatir: Number(r.acikSatir ?? 0), acikTutar: Number(r.acikTutar ?? 0),
        taslakSatir: Number(r.taslakSatir ?? 0),
        taslakTutar: Number(r.taslakTutar ?? 0),
        kapananTutar: Number(r.kapananTutar ?? 0),
        ilkTarih: (r.ilkTarih as string) ?? null, sonTarih: (r.sonTarih as string) ?? null,
      })));
    } catch (h) { setHata(hataMetni(h)) }
  }, []);

  useEffect(() => { void yukle() }, [yukle]);

  const kapat = async () => {
    setHata('');
    if (!secili) { setHata('Kapatılacak kişi seçilmeli.'); return }
    setCalisiyor(true);
    try {
      const y = await api.primDonemKapat({ tarafId: secili, baslangic: bas, bitis: bit });
      mesaj(`Dönem kapatıldı: ${para.format(Number(y.toplam ?? 0))} `
            + `(${Number(y.satirSayisi ?? 0)} satır donduruldu).`);
      onTamam?.();
      onKapat();
    } catch (h) { setHata(hataMetni(h)) } finally { setCalisiyor(false) }
  };

  return (
    <Modal baslik="Hakediş Dönemi Kapat" onKapat={onKapat}
           alt={
             <>
               <button className="d onay" disabled={calisiyor || !secili}
                       onClick={() => void kapat()}>
                 {calisiyor ? '⏳ Kapatılıyor…' : '🔒 Dönemi Kapat'}
               </button>
               <button className="d" onClick={onKapat}>✖ Vazgeç</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>Dönem</h6>
        <div className="alan-izgara">
          <label className="alan">
            <span className="etiket zorunlu-isaret">Başlangıç</span>
            <input type="date" value={bas} onChange={e => setBas(e.target.value)} />
          </label>
          <label className="alan">
            <span className="etiket zorunlu-isaret">Bitiş</span>
            <input type="date" value={bit} onChange={e => setBit(e.target.value)} />
          </label>
        </div>
        <div className="not">
          Kapatılan satırlar <b>dondurulur</b>: rol düzeltilse ya da belge türü
          sonradan değişse bile yeniden hesaplanmaz. Fark <b>sonraki döneme</b>
          düzeltme satırı olarak girer - bu yüzden dönem, tahsilatların
          netleştiğinden emin olunduğunda kapatılır.
        </div>
      </div>

      <div className="kagrup">
        <h6>Açık Hakedişler {kisi ? <span className="sonuk">· seçili: {kisi}</span> : null}</h6>
        <table className="detay-tablo">
          <thead>
            <tr><th style={{ width: 32 }} /><th>Kişi</th>
                <th className="hiza-sag">Kapatılabilir satır</th>
                <th className="hiza-sag">Kapatılabilir tutar</th>
                <th className="hiza-sag">Kapanmış</th>
                <th>Tarih aralığı</th></tr>
          </thead>
          <tbody>
            {acik.map(r => (
              <tr key={r.tarafId} className={secili === r.tarafId ? 'secili' : undefined}>
                <td>
                  <input type="radio" checked={secili === r.tarafId}
                         onChange={() => setSecili(r.tarafId)} />
                </td>
                <td>{r.kisi}</td>
                <td className="hiza-sag">{r.acikSatir}</td>
                <td className="hiza-sag"><b>{para.format(r.acikTutar)}</b></td>
                <td className="hiza-sag sonuk">{para.format(r.kapananTutar)}</td>
                <td className="sonuk">
                  {r.ilkTarih ? String(r.ilkTarih).slice(0, 10).split('-').reverse().join('.') : ''}
                  {r.sonTarih ? ` – ${String(r.sonTarih).slice(0, 10).split('-').reverse().join('.')}` : ''}
                </td>
              </tr>
            ))}
            {acik.length === 0 && (
              <tr><td colSpan={6} className="bos">Açık hakediş satırı yok.</td></tr>
            )}
          </tbody>
        </table>
        <div className="not">
          Listedeki tutarlar <b>dönemden bağımsız</b> toplamlardır; kapatma
          yalnız seçilen tarih aralığındaki satırları bağlar. Prim, kalem satış
          tahakkuku / fişi / faturasına dönüşünce doğar (339); başvuru ya da
          sipariş aşamasındaki kalemden hakediş satırı üretilmez.
        </div>
      </div>
    </Modal>
  );
}
