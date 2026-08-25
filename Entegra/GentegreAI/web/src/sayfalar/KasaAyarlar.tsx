import { useState } from 'react';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';

const SEKMELER = [
  { anahtar: 'genel', baslik: 'Genel' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * KASA AYARLARI (Yönetim › Ayarlar › Kasa) - stok ayarlariyla ayni desen:
 * liste degil, ayar konularini sekmelerde toplayan ozel sayfa.
 *
 * Bugun tek sekme var ("Genel") ama sekme cubugu bilerek duruyor: cek/senet
 * portfoy ve kredi ayarlari (F5-F6) buraya eklenecek; o zaman ekran yeniden
 * kurgulanmasin.
 */
export function KasaAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Kasa Ayarları</h1>
          <span className="yol">Yönetim › Ayarlar › Kasa</span>
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
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {aktif === 'genel' && (
        yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
        <div className="kagrup">
          <h6>Genel</h6>
          <div className="alan-izgara tek-sutun ayar-formu">
            {/* 149: gerceklesmis tahsilat/odeme kac gun duzeltilebilir.
                0 kapali (iptal + yeni girme zorunlu), -1 sinirsiz. */}
            <AyarAlani anahtar="kasa.duzenleme_gun"
                       etiket="Tahsilat / ödeme kilitlenme gün sayısı"
                       tip="sayi"
                       ayarlar={ayarlar} onYaz={yaz} />
            <div className="not">
              Gerçekleşmiş tahsilat/ödeme, işlem tarihinden bu kadar gün sonra
              kilitlenir ve düzeltilemez; düzeltme yerine iptal edilip yeniden
              girilir. <b>0</b> = düzeltme tamamen kapalı, <b>-1</b> = süre sınırı yok
              (kapanmış muhasebe dönemi yine kilitlidir).
            </div>
          </div>
        </div>
        )
      )}
    </>
  );
}
