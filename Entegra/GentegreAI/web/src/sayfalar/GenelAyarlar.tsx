import { useState } from 'react';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';
import { NumaralamaSekmesi } from '../bilesenler/NumaralamaSekmesi';

const SEKMELER = [
  // Guvenlik 2. sirada (kullanici).
  { anahtar: 'genel',      baslik: 'Genel' },
  { anahtar: 'guvenlik',   baslik: 'Güvenlik' },
  { anahtar: 'numaralama', baslik: 'Belge No' },
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
              {/* ILK SATIR (kullanici): Urun modu | Yerel para | Doviz yan yana
                  ama AYRIK - sabit genislikli kolonlar + genis bosluk; tam
                  genislik 1fr kolonlar editleri bitistiriyordu. Para/doviz
                  combolari genel.doviz kod listesinden; ETIKETLERINE
                  tiklaninca liste icerigi jenerik modalda yonetilir. */}
              <div className="alan-izgara ayar-formu"
                   style={{ gridTemplateColumns: 'repeat(auto-fill, 240px)',
                            columnGap: 56, justifyContent: 'start' }}>
                {/* Urun modu (215): menu/marka/mesaj basliklari buna gore.
                    Degisiklik acik oturumlara SONRAKI giris/yenilemede iner. */}
                {alan('genel.urun_modu', 'Ürün modu', {
                  tip: 'secenek',
                  secenekler: [
                    { deger: '1', ad: 'Gentegre AI (ERP)' },
                    { deger: '2', ad: 'GenoTIP AI (HBYS)' },
                  ],
                })}
                {alan('genel.yerel_para', 'Yerel para birimi', { listeKod: 'genel.doviz' })}
                {alan('genel.varsayilan_doviz', 'Döviz', { listeKod: 'genel.doviz' })}
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
        ) : aktif === 'numaralama' ? (
          // Belge / tahsilat / odeme numaralandirmasi (152) - dort grid.
          <NumaralamaSekmesi />
        ) : (
          <>
            <div className="kagrup">
              <h6>Oturum</h6>
              <div className="alan-izgara ayar-formu">
                {alan('guvenlik.jwt_dakika', 'Oturum süresi (dakika)')}
                {alan('guvenlik.refresh_gun', 'Oturumu açık tutma (gün)')}
                {/* Etiket KISA: uzun cumle satiri dagitiyordu, ayrinti "?" ikonunda. */}
                {alan('guvenlik.tek_oturum', 'Tek oturum', { tip: 'mantik' })}
              </div>
            </div>

            <div className="kagrup">
              <h6>Parola ve Kilit</h6>
              <div className="alan-izgara ayar-formu">
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
