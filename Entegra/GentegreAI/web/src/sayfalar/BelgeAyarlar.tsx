import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';
import { c } from '../dil/ceviri';

/**
 * SATIS / ALIS BELGE AYARLARI (Yönetim › Ayarlar › Satış|Alış Belgeleri).
 *
 * Iki ekran ayni bilesenden cizilir: fark yalnizca YON (satis / alis).
 * e-BELGE SEKMESİ KALKTI (1270/1271, kullanıcı 05.11.2026): şube özeti gridi Satış › Ayarlar › Fatura Ayarları ›
 * Genel'in altına taşındı (MukellefOzeti); e-Belge kurulumu tek ekranda.
 *
 * Ayarlar `public.referans` tablosunda; anahtarlar yon onekiyle ayrilir
 * (`belge.satis.*` / `belge.alis.*`) - ayni ayarin iki yonde farkli degeri
 * olabilsin diye. Yonden bagimsiz olanlar `belge.*` altinda kalir ve Genel
 * Ayarlar'da durur; burada TEKRARLANMAZ.
 */
export function BelgeAyarlar({ yon }: { yon: 'satis' | 'alis' }) {
  const satisMi = yon === 'satis';
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

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <div className="kagrup">
            <h6>{c('Belge Girişi')}</h6>
            <div className="alan-izgara tek-sutun ayar-formu">
              {alan(`belge.${yon}.vade_gun`, 'Varsayılan vade (gün)', { tip: 'sayi' })}
              {/* "Varsayılan seri" KALKTI (1271, kullanıcı 05.11.2026): sunucuda okunmuyordu. Seri belge kaydında
                  şubeden (Fatura Ayarları › Genel › Varsayılan Seri), e-Belge'de Seri Bilgileri kuralından gelir. */}
            </div>
          </div>
        )}
      </div>
    </>
  );
}

export const SatisAyarlar = () => <BelgeAyarlar yon="satis" />;
export const AlisAyarlar = () => <BelgeAyarlar yon="alis" />;
