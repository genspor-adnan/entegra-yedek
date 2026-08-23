import { useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type ListeSatiri } from '../api/sozlesme';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';

const SEKMELER = [
  { anahtar: 'genel', baslik: 'Genel' },
  { anahtar: 'depo',  baslik: 'Depolar' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * Stok Ayarlari (Yönetim › Ayarlar). Liste ekrani DEGIL: birden fazla ayar
 * konusunu sekmelerde toplar. Bugun yalnizca "Depolar" dolu - "Genel" sekmesi
 * bilerek bos: stok modulunun genel ayarlari (varsayilan birim, negatif stok
 * izni vb.) henuz semada yok, yer tutucu olarak duruyor.
 */
export function StokAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  // Depo karti (GenForm) - 'yeni' ekleme, sayi duzenleme.
  const [depoKart, setDepoKart] = useState<number | 'yeni' | null>(null);
  const [yenile, setYenile] = useState(0);
  const [hata, setHata] = useState<string | null>(null);
  // "Genel" sekmesi artik bos degil: stok davranis ayarlari (public.referans).
  const { ayarlar, yukleniyor: ayarYukleniyor, hata: ayarHatasi, bilgi, yaz } = useAyarlar();

  async function depoAksiyonu(kod: string, satir: ListeSatiri | null) {
    setHata(null);
    try {
      switch (kod) {
        case 'depo.yeni':    setDepoKart('yeni'); return;
        case 'depo.duzenle': if (satir) setDepoKart(Number(satir.id)); return;
        case 'depo.sil':
          if (!satir) return;
          if (!confirm(`"${String(satir.ad ?? '')}" deposu silinecek. Onaylıyor musunuz?`)) return;
          await api.kartSil('depo', Number(satir.id));
          setYenile(t => t + 1);
          return;
      }
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    }
  }

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Stok Ayarları</h1>
          <span className="yol">Yönetim › Ayarlar › Stok Ayarları</span>
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

      {(hata || ayarHatasi) && <div className="hata-kutusu">{hata ?? ayarHatasi}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {aktif === 'genel' && (
        ayarYukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
        <div className="kagrup">
          <h6>Genel</h6>
          <div className="alan-izgara tek-sutun ayar-formu">
            <AyarAlani anahtar="stok.negatif_davranis" etiket="Negatif stok davranışı"
                       tip="secenek"
                       secenekler={[
                         { deger: '0', ad: 'Serbest — bakiye eksiye düşebilir' },
                         { deger: '1', ad: 'Uyar — kaydet, uyarı göster' },
                         { deger: '2', ad: 'Engelle — belgeyi kaydetme' },
                       ]}
                       ayarlar={ayarlar} onYaz={yaz} />
          </div>
        </div>
        )
      )}

      {aktif === 'depo' && (
        // Arac cubugu + secim onay kutusu + sag tus GenGrid'den gelir; aksiyonlar
        //   katalogdaki "depo-liste" ekranindan (Ekle / Düzenle / Sil).
        <GenGrid
          key="depo"
          kaynak="depo"
          gomulu
          seritGizli
          aracCubuguSol
          aksiyonEkrani="depo-liste"
          yenile={yenile}
          onSatirAc={satir => setDepoKart(Number(satir.id))}
          onAksiyon={(kod, satir) => { void depoAksiyonu(kod, satir) }}
        />
      )}

      {depoKart !== null && (
        <GenForm
          kaynak="depo"
          id={depoKart}
          baslik="Depo"
          onKapat={() => setDepoKart(null)}
          onKaydedildi={() => { setDepoKart(null); setYenile(t => t + 1) }}
        />
      )}
    </>
  );
}
