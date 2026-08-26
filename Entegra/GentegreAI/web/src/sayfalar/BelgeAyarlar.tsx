import { useState } from 'react';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';
import { EBelgeAyarlari } from './eBelgeAyarlari';

/**
 * SATIS / ALIS BELGE AYARLARI (Yönetim › Ayarlar › Satış|Alış Belgeleri).
 *
 * Iki ekran ayni bilesenden cizilir: fark yalnizca YON (satis / alis) ve
 * satista fazladan e-Belge sekmesi. e-Belge yalniz GIDEN belgede anlamlidir -
 * alis faturasini GIB'e biz gondermeyiz, tedarikciden geliriz.
 *
 * Ayarlar `public.referans` tablosunda; anahtarlar yon onekiyle ayrilir
 * (`belge.satis.*` / `belge.alis.*`) - ayni ayarin iki yonde farkli degeri
 * olabilsin diye. Yonden bagimsiz olanlar `belge.*` altinda kalir ve Genel
 * Ayarlar'da durur; burada TEKRARLANMAZ.
 */
export function BelgeAyarlar({ yon }: { yon: 'satis' | 'alis' }) {
  const satisMi = yon === 'satis';
  const sekmeler = satisMi
    ? [{ anahtar: 'genel', baslik: 'Genel' }, { anahtar: 'ebelge', baslik: 'e-Belge' }]
    : [{ anahtar: 'genel', baslik: 'Genel' }];

  const [aktif, setAktif] = useState('genel');
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();

  const alan = (anahtar: string, etiket: string,
                ek?: Partial<Parameters<typeof AyarAlani>[0]>) => (
    <AyarAlani anahtar={anahtar} etiket={etiket} ayarlar={ayarlar} onYaz={yaz} {...ek} />
  );

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>{satisMi ? 'Satış Belgeleri' : 'Alış Belgeleri'}</h1>
          <span className="yol">
            Yönetim › Ayarlar › {satisMi ? 'Satış Belgeleri' : 'Alış Belgeleri'}
          </span>
        </div>
      </div>

      <div className="katab">
        {sekmeler.map(s => (
          <div key={s.anahtar}
               className={`kat${s.anahtar === aktif ? ' on' : ''}`}
               onClick={() => setAktif(s.anahtar)}>
            {s.baslik}
          </div>
        ))}
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : aktif === 'genel' ? (
          <div className="kagrup">
            <h6>Belge Girişi</h6>
            <div className="alan-izgara tek-sutun ayar-formu">
              {alan(`belge.${yon}.vade_gun`, 'Varsayılan vade (gün)', { tip: 'sayi' })}
              {alan(`belge.${yon}.varsayilan_seri`, 'Varsayılan seri', { tip: 'metin' })}
            </div>
          </div>
        ) : (
          // Delphi'deki "Opsiyonlar > Fatura > E-Belge" sekmesinin karsiligi.
          <EBelgeAyarlari />
        )}
      </div>
    </>
  );
}

export const SatisAyarlar = () => <BelgeAyarlar yon="satis" />;
export const AlisAyarlar = () => <BelgeAyarlar yon="alis" />;
