import { useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { Modal } from './Modal';

/**
 * KAYNAK ARAMA PENCERESİ — bir liste kaynağında (ICD, ilaç, tetkik…) arayıp
 * tek satır seçtiren genel pencere.
 *
 * <b>Neden ayrı pencere:</b> binlerce satırlı katalogda combo kullanılamaz
 * (ICD ~20 bin satır), tek satırlık "önce yaz sonra listeden seç" akışı ise
 * hekimi iki adıma zorluyordu. Pencere yazdıkça arar - kod ya da adın bir
 * parçası yeter.
 *
 * <b>Arama SUNUCUDA:</b> filtre liste sözleşmesiyle gider (`kod` başlar /
 * `ad` içerir); ekran katalog taşımaz, yetkisiz kaynak zaten hiç dönmez.
 */

type Satir = Record<string, unknown>;

export function KaynakArama({ kaynak, baslik, kodAlani = 'kod', adAlani = 'ad',
                              ekKosul, onceki, oncekiBaslik = 'Öncekiler',
                              onSec, onKapat }: {
  kaynak: string;
  baslik: string;
  kodAlani?: string;
  adAlani?: string;
  /** Kaynağa özel sabit süzgeç (ör. yalnız aktif kayıtlar). */
  ekKosul?: { alan: string; op: 'esit'; deger: unknown };
  /** Ekrana özel üçüncü liste (ör. bu HASTANIN önceki tanıları). */
  onceki?: () => Promise<{ kod: string; ad: string }[]>;
  oncekiBaslik?: string;
  onSec(satir: Satir): void;
  onKapat(): void;
}) {
  const [metin, setMetin] = useState('');
  /** Hazır listeler: '' arama · 'sik' · 'son' · 'onceki' (kullanıcı). */
  // 'son' listesi UÇTA duruyor ama düğmesi yok (kullanıcı): sık kullanılan
  //   zaten son kullanılanı kapsıyordu, iki düğme aynı işi yapıyordu.
  const [kip, setKip] = useState<'' | 'sik' | 'onceki'>('');
  const [satirlar, setSatirlar] = useState<Satir[]>([]);
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const kutu = useRef<HTMLInputElement | null>(null);

  useEffect(() => { kutu.current?.focus() }, []);

  /**
   * SIK / SON / ÖNCEKİ listeleri (461): poliklinikte tanı dağılımı dardır -
   * hekimin yazdığı ilk beş kod işin çoğunu görür. Aramadan önce bunları
   * göstermek hem yazmayı kaldırır hem de AYNI hastalığın hep AYNI kodla
   * yazılmasını sağlar; iki farklı ICD ile yazılan hastalık raporu ve
   * e-Nabız paketini ikiye böler.
   */
  useEffect(() => {
    if (kip === '') return;
    let iptal = false;
    setYukleniyor(true);
    void (async () => {
      try {
        if (kip === 'onceki') {
          const liste = onceki ? await onceki() : [];
          if (!iptal) setSatirlar(liste as unknown as Satir[]);
        } else {
          const y = await api.katalogKullanilan(kaynak);
          if (!iptal) setSatirlar(y.sik as unknown as Satir[]);
        }
        if (!iptal) setHata(null);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
      finally { if (!iptal) setYukleniyor(false) }
    })();
    return () => { iptal = true };
  }, [kip, kaynak, onceki]);

  // DEBOUNCE: her tuşta sorgu atmak 20 bin satırlık katalogda sunucuyu
  //   gereksiz yorar; 300 ms yazma duraklaması yeterli.
  useEffect(() => {
    const anahtar = metin.trim();
    if (anahtar.length < 2) { if (kip === '') setSatirlar([]); return }
    let iptal = false;
    const zaman = setTimeout(() => {
      setYukleniyor(true);
      void (async () => {
        try {
          const y = await api.liste(kaynak, {
            sayfa: 1, boyut: 50,
            filtre: {
              op: 'and',
              kosullar: [
                ...(ekKosul ? [ekKosul] : []),
                { op: 'or', kosullar: [
                  { alan: kodAlani, op: 'baslar', deger: anahtar },
                  { alan: adAlani, op: 'icerir', deger: anahtar },
                ] },
              ],
            },
          });
          if (!iptal) { setSatirlar(y.satirlar as Satir[]); setHata(null) }
        } catch (h) { if (!iptal) setHata(hataMetni(h)) }
        finally { if (!iptal) setYukleniyor(false) }
      })();
    }, 300);
    return () => { iptal = true; clearTimeout(zaman) };
  }, [metin, kaynak, kodAlani, adAlani, ekKosul, kip]);

  return (
    <Modal baslik={baslik} dar enUst onKapat={onKapat}
           alt={<button type="button" className="d" onClick={onKapat}>Kapat</button>}>
      <div className="kaynak-arama">
        <div className="kaynak-arama-arac">
          <span className="ara-kutu">
            <span>🔍</span>
            <input ref={kutu} value={metin} placeholder="Kod ya da ad…"
                   onChange={e => { setMetin(e.target.value); setKip('') }} />
          </span>
          <button type="button" className={`d${kip === 'sik' ? ' bir' : ''}`}
                  onClick={() => { setMetin(''); setKip(kip === 'sik' ? '' : 'sik') }}>
            ⭐ Sık Kullandıklarım
          </button>
          {onceki && (
            <button type="button" className={`d${kip === 'onceki' ? ' bir' : ''}`}
                    onClick={() => { setMetin(''); setKip(kip === 'onceki' ? '' : 'onceki') }}>
              📁 {oncekiBaslik}
            </button>
          )}
        </div>

        {hata && <div className="hata-kutusu">{hata}</div>}
        {!hata && kip === '' && metin.trim().length < 2 && (
          <p className="not">En az iki harf/rakam yazın ya da hazır listelerden seçin.</p>
        )}
        {!hata && satirlar.length === 0 && (kip !== '' || metin.trim().length >= 2) && (
          <p className="not">{yukleniyor ? 'Yükleniyor…' : 'Kayıt yok.'}</p>
        )}

        {satirlar.length > 0 && (
          <table className="detay-tablo">
            <thead><tr><th style={{ width: 120 }}>Kod</th><th>Ad</th></tr></thead>
            <tbody>
              {satirlar.map((r, i) => (
                <tr key={i} className="tiklanir" onClick={() => onSec(r)}>
                  <td><b>{String(r[kodAlani] ?? '')}</b></td>
                  <td>{String(r[adAlani] ?? '')}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </Modal>
  );
}
