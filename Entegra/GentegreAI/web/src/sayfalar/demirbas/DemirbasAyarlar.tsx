import { useState } from 'react';
import { AyarAlani, useAyarlar } from '../../bilesenler/AyarAlani';
import { KodListesiModali } from '../../bilesenler/KodListesiModali';

/**
 * DEMİRBAŞ AYARLARI (1007, Sabit Varlıklar › Ayarlar › Demirbaş) - kasa /
 * stok ayarlarıyla aynı desen (AyarAlani, referans anahtarları).
 *
 * Kullanıcı 10.10.2026: "gerekiyorsa ayarlar da ekle". Zimmet ekranının
 * davranışını belirleyen ayarlar + demirbaş kartının kod listeleri.
 */
export function DemirbasAyarlar() {
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();
  const [liste, setListe] = useState<{ kod: string; baslik: string } | null>(null);

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Demirbaş Ayarları</h1>
          <span className="yol">Sabit Varlıklar › Ayarlar › Demirbaş</span>
        </div>
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (<>
        <div className="kagrup">
          <h6>Zimmet</h6>
          <div className="alan-izgara tek-sutun ayar-formu">
            {/* İADE LOKASYONU: iade alınan demirbaş depoya döner; boşsa yeri değişmez. */}
            <AyarAlani anahtar="demirbas.iade_lokasyon" etiket="İade alınan demirbaşın lokasyonu"
                       tip="secenek" listeKod="demirbas.lokasyon" ayarlar={ayarlar} onYaz={yaz} />
            <AyarAlani anahtar="demirbas.tutanak_metni" etiket="Zimmet tutanağı taahhüt metni"
                       tip="uzunMetin" genis ayarlar={ayarlar} onYaz={yaz} />
          </div>
        </div>

        <div className="kagrup">
          <h6>Amortisman (yeni demirbaş varsayılanı)</h6>
          <div className="alan-izgara tek-sutun ayar-formu">
            <AyarAlani anahtar="demirbas.amortisman_yontem" etiket="Amortisman yöntemi"
                       tip="secenek" secenekler={[{ deger: '1', ad: 'Normal (doğrusal)' },
                                                  { deger: '2', ad: 'Azalan bakiyeler' }]}
                       ayarlar={ayarlar} onYaz={yaz} />
            <AyarAlani anahtar="demirbas.amortisman_omur" etiket="Faydalı ömür (yıl, 0 = boş)"
                       tip="sayi" ayarlar={ayarlar} onYaz={yaz} />
          </div>
        </div>

        <div className="kagrup">
          <h6>Kod listeleri</h6>
          <div className="ayar-formu" style={{ display: 'flex', gap: 8, padding: '6px 10px' }}>
            <button onClick={() => setListe({ kod: 'demirbas.kategori', baslik: 'Demirbaş Kategorileri' })}>
              🗂 Kategoriler
            </button>
            <button onClick={() => setListe({ kod: 'demirbas.lokasyon', baslik: 'Demirbaş Lokasyonları' })}>
              📍 Lokasyonlar
            </button>
          </div>
        </div>
      </>)}

      {liste && <KodListesiModali kod={liste.kod} baslik={liste.baslik} onKapat={() => setListe(null)} />}
    </>
  );
}

export default DemirbasAyarlar;
