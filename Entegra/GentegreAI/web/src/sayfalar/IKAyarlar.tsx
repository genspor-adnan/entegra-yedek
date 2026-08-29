import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { KodListesiModali } from '../bilesenler/KodListesiModali';
import { YardimIkonu } from '../bilesenler/YardimIkonu';

const SEKMELER = [
  { anahtar: 'genel', baslik: 'Genel' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/** Ayar ekranında yönetilen kod listeleri (kullanıcı: Departman + Görev). */
const LISTELER = [
  { kod: 'taraf.departman', baslik: 'Departman',
    yardim: 'Personel kartındaki Departman seçeneklerini yönetir. '
          + 'Etikete tıklayarak ekleyip düzenleyebilirsiniz; silinen bir değer '
          + 'kullanan kayıtlarda alan boş görünür.' },
  { kod: 'taraf.gorev', baslik: 'Görev',
    yardim: 'Personel kartındaki Görev seçeneklerini yönetir. Kayıtlarda görev '
          + 'artık ID olarak saklanır - buradaki adı değiştirmek tüm kayıtlarda '
          + 'görünen adı değiştirir.' },
] as const;

/**
 * İK AYARLARI (Yönetim › Ayarlar › İK) - kasa/stok ayarlarıyla aynı desen.
 *
 * Genel sekmesinde Departman ve Görev listeleri: combo mevcut değerleri
 * gösterir, "Düzenle" jenerik KodListesiModali'nı açar (ekle/sil/sırala,
 * taslak modeli - Kaydet'e basılana dek sunucuya gitmez).
 */
export function IKAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const [duzenlenen, setDuzenlenen] = useState<typeof LISTELER[number] | null>(null);
  const [degerler, setDegerler] = useState<Record<string, { deger: number; ad: string }[]>>({});
  const [secili, setSecili] = useState<Record<string, string>>({});
  const [hata, setHata] = useState('');
  const [surum, setSurum] = useState(0);

  const yukle = useCallback(async () => {
    try {
      const sonuc: Record<string, { deger: number; ad: string }[]> = {};
      for (const l of LISTELER) {
        const y = await api.kodListe(l.kod);
        sonuc[l.kod] = y.degerler.filter(d => d.aktif !== 0)
          .map(d => ({ deger: d.deger, ad: d.ad }));
      }
      setDegerler(sonuc);
    } catch (h) { setHata(hataMetni(h)) }
  }, []);

  useEffect(() => { void yukle() }, [yukle, surum]);

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>İK Ayarları</h1>
          <span className="yol">Yönetim › Ayarlar › İK</span>
        </div>
      </div>

      <div className="katab">
        {SEKMELER.map(s => (
          <div key={s.anahtar}
               className={`kat${s.anahtar === aktif ? ' on' : ''}`}
               onClick={() => setAktif(s.anahtar)}>
            {s.baslik}
          </div>
        ))}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {aktif === 'genel' && (
        <div className="kagrup">
          <h6>Genel</h6>
          <div className="alan-izgara tek-sutun ayar-formu">
            {/* AyarAlani ile AYNI desen (kullanici: "standart deseni uygula"):
                etiket TIKLANABILIR (✎) ve jenerik kod listesi modalini acar,
                combo listenin icerigini gosterir. */}
            {LISTELER.map(l => {
              const liste = degerler[l.kod] ?? [];
              return (
                <label key={l.kod} className="alan">
                  <span className="etiket" role="button" tabIndex={0}
                        title="Liste içeriğini düzenle" style={{ cursor: 'pointer' }}
                        onClick={e => { e.preventDefault(); setDuzenlenen(l) }}>
                    {l.baslik} ✎
                  </span>
                  <span className="ikili">
                    {/* (?) combonun SOLUNDA (kullanici) - ayar alanlarindaki
                        yerlesimin aynisi. */}
                    <YardimIkonu anahtar={`ayar.ik.${l.kod}`} baslik={l.baslik}
                                 metin={l.yardim} hepGoster />
                    <select value={secili[l.kod] ?? ''}
                            onChange={e => setSecili(s => ({ ...s, [l.kod]: e.target.value }))}>
                      <option value="">
                        {liste.length === 0 ? '(liste boş - etikete tıklayıp ekleyin)'
                                            : `${liste.length} seçenek`}
                      </option>
                      {liste.map(d => (
                        <option key={d.deger} value={String(d.deger)}>{d.ad}</option>
                      ))}
                    </select>
                  </span>
                </label>
              );
            })}
          </div>
        </div>
      )}

      {duzenlenen && (
        <KodListesiModali kod={duzenlenen.kod} baslik={duzenlenen.baslik}
                          onKapat={() => { setDuzenlenen(null); setSurum(s => s + 1) }} />
      )}
    </>
  );
}
