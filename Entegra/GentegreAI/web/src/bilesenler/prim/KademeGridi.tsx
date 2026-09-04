import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';

interface Kademe { adetAlt: string; adetUst: string; deger: string }

/**
 * PLAN SATIRI KADEMELERI (388) - "adede gore artan oran".
 *
 * Kademe, plan satirinin cocugudur (kartin torunu) ve kart cercevesi torun
 * detayi baglamaz; bu yuzden kendi uclariyla calisan kucuk bir bilesen ve
 * SATIR MODALINE gomulu (kullanici secimi).
 *
 * TAM LISTE YAZILIR: kademeler bir ARALIK KUMESIDIR - tek tek satir
 * ekleyip silmek araligi gecici olarak tutarsiz birakir. Kullanici tabloyu
 * tamamlar, "Kademeleri Kaydet" tek islemde yerine koyar.
 */
export function KademeGridi({ planSatirId }: { planSatirId: number | null }) {
  const [satirlar, setSatirlar] = useState<Kademe[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [bilgi, setBilgi] = useState<string | null>(null);

  useEffect(() => {
    if (!planSatirId) { setSatirlar([]); return }
    setYukleniyor(true);
    api.primKademeler(planSatirId)
      .then(y => setSatirlar(y.satirlar.map(k => ({
        adetAlt: String(k.adetAlt ?? 0),
        adetUst: k.adetUst == null ? '' : String(k.adetUst),
        deger: String(k.deger ?? 0),
      }))))
      .catch(h => setHata(hataMetni(h)))
      .finally(() => setYukleniyor(false));
  }, [planSatirId]);

  // SATIR HENUZ KAYDEDILMEMIS: kademe `satir_id`'ye baglanir, o da kayittan
  //   sonra olusur. Bos bir grid gostermek "yazdim ama gitmedi" uretirdi.
  if (!planSatirId) {
    return (
      <div className="not" style={{ padding: 8 }}>
        Kademe tanımlamak için önce satırı kaydedin.
      </div>
    );
  }

  const degis = (i: number, alan: keyof Kademe, deger: string) =>
    setSatirlar(l => l.map((k, j) => (j === i ? { ...k, [alan]: deger } : k)));

  const kaydet = async () => {
    setHata(null); setBilgi(null);
    try {
      await api.primKademeYaz(planSatirId, satirlar.map(k => ({
        adetAlt: Number(k.adetAlt) || 0,
        adetUst: k.adetUst.trim() === '' ? null : Number(k.adetUst),
        deger: Number(String(k.deger).replace(',', '.')) || 0,
      })));
      setBilgi(`${satirlar.length} kademe kaydedildi.`);
    } catch (h) {
      setHata(hataMetni(h));
    }
  };

  return (
    <div className="kagrup" style={{ marginTop: 10 }}>
      <h6>
        Kademeler
        <span className="baslik-eylem">
          <button type="button" className="d bir ikon-dugme" title="Kademe ekle"
                  onClick={() => setSatirlar(l => [...l, { adetAlt: '', adetUst: '', deger: '' }])}>
            ＋
          </button>
          <button type="button" className="d" onClick={() => void kaydet()}>
            Kademeleri Kaydet
          </button>
        </span>
      </h6>

      {/* KADEME DONEM KAPANISINDA ISLER: kalem anindaki tutar ONIZLEMEDIR.
          Bunu yazmazsak "girdim ama tutar degismedi" sorusu kacinilmaz. */}
      <div className="not" style={{ margin: 10 }}>
        Kademe <b>dönem kapanışında</b> uygulanır: kişinin o dönemdeki iş adedine
        göre oran yeniden hesaplanır. Kalem anında yazılan tutar önizlemedir.
        Aralık dışında kalan adetlerde satırın kendi oranı geçerlidir.
      </div>

      {hata && <div className="uyari" style={{ margin: 10 }}>{hata}</div>}
      {bilgi && <div className="not basari" style={{ margin: 10 }}>{bilgi}</div>}

      <table className="detay-tablo">
        <thead>
          <tr>
            <th style={{ width: '30%' }}>Adet (en az)</th>
            <th style={{ width: '30%' }}>Adet (en çok)</th>
            <th style={{ width: '30%' }}>Değer</th>
            <th style={{ width: '10%' }} />
          </tr>
        </thead>
        <tbody>
          {satirlar.map((k, i) => (
            <tr key={i}>
              <td><input inputMode="numeric" value={k.adetAlt}
                         onChange={e => degis(i, 'adetAlt', e.target.value)} /></td>
              {/* BOS = "ve yukarisi" - en fazla bir kademede olabilir (uc dogrular). */}
              <td><input inputMode="numeric" value={k.adetUst} placeholder="ve yukarısı"
                         onChange={e => degis(i, 'adetUst', e.target.value)} /></td>
              <td><input inputMode="decimal" value={k.deger}
                         onChange={e => degis(i, 'deger', e.target.value)} /></td>
              <td className="hiza-orta">
                <button type="button" className="d teh ikon-dugme" title="Kademeyi sil"
                        onClick={() => setSatirlar(l => l.filter((_, j) => j !== i))}>✖</button>
              </td>
            </tr>
          ))}
          {satirlar.length === 0 && (
            <tr><td colSpan={4} className="bos">
              {yukleniyor ? 'Yükleniyor…' : 'Kademe yok — satırın kendi oranı geçerli.'}
            </td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
