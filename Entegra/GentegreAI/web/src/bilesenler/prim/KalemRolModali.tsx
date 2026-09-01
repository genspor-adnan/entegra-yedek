import { useCallback, useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { Modal } from '../Modal';
import { TarafArama } from '../TarafArama';
import { mesaj } from '../mesaj';
import { para } from '../bicim';

/**
 * KALEM PRİM ROLLERİ (324).
 *
 * Prim, kişiye değil KALEME bağlanır: "bu tetkiği kim gönderdi, kim yaptı,
 * kim raporladı". Bir kalemde birden çok rol, bir rolde birden çok kişi
 * olabilir (iki cerrah %50/%50) - bu yüzden satır listesi.
 *
 * Roller kaydedilince o kalemin tahsilat dağıtımlarından prim YENİDEN
 * hesaplanır; kesinleşmiş (dönemi kapanmış) satırlara dokunulmaz.
 */

interface RolSatiri {
  id?: number; rol: number; rolAdi?: string;
  tarafId: number; kisi: string; payYuzde: number;
}
interface PrimSatiri {
  id: number; tarafId: number; kisi: string; rol: number;
  tarih: string; taban: number; deger: number; tutar: number; durum: number;
}

/** Kod listesi rad/prim.rol ile aynı sıra - sunucu adı da döndürüyor. */
const ROLLER = [
  { deger: 1, ad: 'Gönderen' }, { deger: 2, ad: 'İsteyen' },
  { deger: 3, ad: 'Uygulayan' }, { deger: 4, ad: 'Yapan' },
  { deger: 5, ad: 'Raporlayan' }, { deger: 6, ad: 'Onaylayan' },
  { deger: 7, ad: 'Anestezi' }, { deger: 8, ad: 'Asistan' },
  { deger: 9, ad: 'Teknisyen' },
];

export function KalemRolModali({ belgeSatirId, kalemAdi, onKapat, onTamam }: {
  belgeSatirId: number;
  kalemAdi?: string;
  onKapat(): void;
  onTamam?(): void;
}) {
  const [satirlar, setSatirlar] = useState<RolSatiri[]>([]);
  const [primler, setPrimler] = useState<PrimSatiri[]>([]);
  const [arama, setArama] = useState<number | null>(null);   // hangi satır için
  const [hata, setHata] = useState('');
  const [kaydediyor, setKaydediyor] = useState(false);

  const yukle = useCallback(async () => {
    setHata('');
    try {
      const y = await api.primKalemRolleri(belgeSatirId);
      setSatirlar((y.satirlar ?? []).map(r => ({
        id: Number(r.id), rol: Number(r.rol), rolAdi: String(r.rolAdi ?? ''),
        tarafId: Number(r.tarafId), kisi: String(r.kisi ?? ''),
        payYuzde: Number(r.payYuzde ?? 100),
      })));
      setPrimler((y.primler ?? []).map(p => ({
        id: Number(p.id), tarafId: Number(p.tarafId), kisi: String(p.kisi ?? ''),
        rol: Number(p.rol), tarih: String(p.tarih ?? ''),
        taban: Number(p.taban ?? 0), deger: Number(p.deger ?? 0),
        tutar: Number(p.tutar ?? 0), durum: Number(p.durum ?? 1),
      })));
    } catch (h) { setHata(hataMetni(h)) }
  }, [belgeSatirId]);

  useEffect(() => { void yukle() }, [yukle]);

  const ekle = () => setSatirlar(s =>
    [...s, { rol: 1, tarafId: 0, kisi: '', payYuzde: 100 }]);
  const sil = (i: number) => setSatirlar(s => s.filter((_, x) => x !== i));
  const yaz = (i: number, y: Partial<RolSatiri>) =>
    setSatirlar(s => s.map((r, x) => (x === i ? { ...r, ...y } : r)));

  const kaydet = async () => {
    setHata('');
    const eksik = satirlar.find(r => !r.tarafId);
    if (eksik) { setHata('Kişi seçilmemiş satır var.'); return }
    setKaydediyor(true);
    try {
      const y = await api.primKalemRolleriYaz(belgeSatirId, {
        satirlar: satirlar.map(r => ({ rol: r.rol, tarafId: r.tarafId,
                                       payYuzde: r.payYuzde })),
      });
      mesaj(y.primSatiri > 0
        ? `Roller kaydedildi; ${y.primSatiri} prim satırı yeniden hesaplandı.`
        : 'Roller kaydedildi. Tahsilat yapılınca prim doğacak.');
      await yukle();
      onTamam?.();
    } catch (h) { setHata(hataMetni(h)) } finally { setKaydediyor(false) }
  };

  return (
    <Modal baslik={`Prim Rolleri${kalemAdi ? ` — ${kalemAdi}` : ''}`} onKapat={onKapat}
           alt={
             <>
               <button className="d onay" disabled={kaydediyor} onClick={() => void kaydet()}>
                 {kaydediyor ? '⏳ Kaydediliyor…' : '💾 Rolleri Kaydet'}
               </button>
               <button className="d" onClick={ekle}>＋ Satır</button>
               <button className="d" onClick={onKapat}>✖ Kapat</button>
             </>
           }>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kagrup">
        <h6>Roller <span className="sonuk">bir kalemde çok rol, bir rolde çok kişi olabilir</span></h6>
        <table className="detay-tablo">
          <thead>
            <tr><th style={{ width: 150 }}>Rol</th><th>Kişi</th>
                <th className="hiza-sag" style={{ width: 110 }}>Pay %</th>
                <th style={{ width: 36 }} /></tr>
          </thead>
          <tbody>
            {satirlar.map((r, i) => (
              <tr key={i}>
                <td>
                  <select value={r.rol} onChange={e => yaz(i, { rol: Number(e.target.value) })}>
                    {ROLLER.map(x => <option key={x.deger} value={x.deger}>{x.ad}</option>)}
                  </select>
                </td>
                <td>
                  <button type="button" className="d" style={{ width: '100%', textAlign: 'left' }}
                          onClick={() => setArama(i)}>
                    {r.kisi || '— kişi seç —'}
                  </button>
                </td>
                <td className="hiza-sag">
                  <input type="number" min={0} max={100} step="0.01" style={{ width: 84 }}
                         value={r.payYuzde}
                         onChange={e => yaz(i, { payYuzde: Number(e.target.value) })} />
                </td>
                <td><button type="button" className="d teh" onClick={() => sil(i)}>✖</button></td>
              </tr>
            ))}
            {satirlar.length === 0 && (
              <tr><td colSpan={4} className="bos">
                Rol tanımlanmamış - bu kalemden prim doğmaz.</td></tr>
            )}
          </tbody>
        </table>
        <div className="not">
          Aynı roldeki pay yüzdeleri toplamı <b>%100'ü aşamaz</b> (iki cerrah
          %50/%50). Prim <b>tahsil edildikçe</b> doğar: roller burada dursa da
          tutar, o kalemin parası tahsil edildikçe hesaplanır.
        </div>
      </div>

      {primler.length > 0 && (
        <div className="kagrup">
          <h6>Bu Kalemden Doğan Primler</h6>
          <table className="detay-tablo">
            <thead>
              <tr><th>Kişi</th><th>Rol</th><th>Tarih</th>
                  <th className="hiza-sag">Taban (matrah)</th>
                  <th className="hiza-sag">Oran</th>
                  <th className="hiza-sag">Prim</th><th>Durum</th></tr>
            </thead>
            <tbody>
              {primler.map(p => (
                <tr key={p.id}>
                  <td>{p.kisi}</td>
                  <td>{ROLLER.find(x => x.deger === p.rol)?.ad ?? p.rol}</td>
                  <td>{p.tarih.slice(0, 10).split('-').reverse().join('.')}</td>
                  <td className="hiza-sag">{para.format(p.taban)}</td>
                  <td className="hiza-sag">{para.format(p.deger)}</td>
                  <td className="hiza-sag"><b>{para.format(p.tutar)}</b></td>
                  <td>
                    <span className={`rozet ${p.durum === 2 ? 'ok' : 'gri'}`}>
                      {p.durum === 2 ? 'Kesinleşti' : 'Açık'}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div className="not">
            <b>Kesinleşmiş</b> satırlar dönem kapanışında dondurulmuştur -
            rol değişse de yeniden hesaplanmaz; fark sonraki döneme düzeltme
            olarak girer.
          </div>
        </div>
      )}

      <TarafArama
        acik={arama !== null}
        kaynaklar={['personel', 'dis-hekim']}
        yerTutucu="Hekim / personel ara…"
        onKapat={() => setArama(null)}
        onSec={sec => {
          if (arama !== null) yaz(arama, { tarafId: sec.id, kisi: sec.unvan });
          setArama(null);
        }}
      />
    </Modal>
  );
}
