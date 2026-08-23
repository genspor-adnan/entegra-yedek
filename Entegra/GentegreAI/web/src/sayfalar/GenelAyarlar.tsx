import { useState } from 'react';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';

const SEKMELER = [
  { anahtar: 'genel',    baslik: 'Genel' },
  { anahtar: 'guvenlik', baslik: 'Güvenlik' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * Genel Ayarlar (Yönetim › Ayarlar › Genel) — firma geneli DAVRANIS ayarlari.
 *
 * Ayarlar `public.referans` tablosunda ve sunucuda BEYAZ LISTE ile korunuyor
 * (AyarDeposu). Alan cizimi/kayit AyarAlani'nda ortak: etiket ustte, "?" ikonu
 * saginda, kayit aninda.
 */
export function GenelAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();

  const alan = (anahtar: string, etiket: string,
                ek?: Partial<Parameters<typeof AyarAlani>[0]>) => (
    <AyarAlani anahtar={anahtar} etiket={etiket} ayarlar={ayarlar} onYaz={yaz} {...ek} />
  );

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Genel Ayarlar</h1>
          <span className="yol">Yönetim › Ayarlar › Genel</span>
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

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : aktif === 'genel' ? (
          <>
            <div className="kagrup">
              <h6>Genel</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('genel.yerel_para', 'Yerel para birimi', { tip: 'metin' })}
              </div>
            </div>

            <div className="kagrup">
              <h6>Belge Girişi</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('belge.geri_gun_siniri', 'Belgeler geriye dönük kaç güne kadar girilebilir')}
              </div>
            </div>

            <div className="kagrup">
              <h6>Listeler</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('liste.sayfa_boyu', 'Sayfa boyu (bir sayfadaki kayıt sayısı)')}
              </div>
            </div>
          </>
        ) : (
          <>
            <div className="kagrup">
              <h6>Oturum</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('guvenlik.jwt_dakika', 'Oturum süresi (dakika)')}
                {alan('guvenlik.refresh_gun', 'Oturumu açık tutma (gün)')}
                {/* Etiket KISA: uzun cumle satiri dagitiyordu, ayrinti "?" ikonunda. */}
                {alan('guvenlik.tek_oturum', 'Tek oturum', { tip: 'mantik' })}
              </div>
            </div>

            <div className="kagrup">
              <h6>Parola ve Kilit</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('guvenlik.parola_min_uzunluk', 'En az parola uzunluğu')}
                {alan('guvenlik.hatali_giris_siniri', 'Kaç hatalı girişten sonra kilitlensin')}
                {alan('guvenlik.kilit_dakika', 'Kilit süresi (dakika)')}
              </div>
            </div>
          </>
        )}
      </div>
    </>
  );
}
