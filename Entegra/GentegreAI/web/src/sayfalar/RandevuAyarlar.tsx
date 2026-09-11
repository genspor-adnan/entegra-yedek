import { useState } from 'react';
import { AyarSekmeSeridi } from '../bilesenler/AyarSekmeSeridi';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';
import { RandevuBolumAyarlari } from '../bilesenler/RandevuBolumAyarlari';

const SEKMELER = [
  { anahtar: 'genel', baslik: 'Genel' },
  // BÖLÜMLER (251, kullanici): randevu verilen bolumler + hekimleri; sag
  //   tarafta o bolume/hekime ait randevu duzeni (master-detail).
  { anahtar: 'bolumler', baslik: 'Bölümler' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * RANDEVU AYARLARI (243) - "randevu altına Randevu Ayarları ekle, gün saat
 * ayarı vb. yapabilelim" (kullanıcı). Kasa/İK ayarlarıyla aynı desen; değerler
 * `referans` tablosunda, takvim görünümü bunları okur.
 */
export function RandevuAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();
  /** Genel Ayarlar degeri - Bölümler sekmesinde "devralinan" yer tutucu. */
  const deger = (anahtar: string, varsayilan: string) =>
    ayarlar.find(a => a.anahtar === anahtar)?.deger || varsayilan;

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Randevu Ayarları</h1>
          <span className="yol">Kayıt Kabul › Randevu Ayarları</span>
        </div>
      </div>

      <AyarSekmeSeridi sekmeler={SEKMELER} aktif={aktif} onSec={a => setAktif(a as typeof aktif)} />

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {aktif === 'bolumler' && (
        yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <RandevuBolumAyarlari genel={{
            baslangicSaat: deger('randevu.baslangic_saat', '09:00'),
            bitisSaat: deger('randevu.bitis_saat', '18:00'),
            slotDk: deger('randevu.slot_dk', '15'),
            varsayilanSure: deger('randevu.varsayilan_sure', '15'),
            calismaGunleri: deger('randevu.calisma_gunleri', '1,2,3,4,5,6'),
            ogleBaslangic: deger('randevu.ogle_baslangic', ''),
            ogleBitis: deger('randevu.ogle_bitis', ''),
          }} />
        )
      )}

      {aktif === 'genel' && (
        yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
          <>
            <div className="kagrup">
              <h6>Çalışma Saatleri</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                <AyarAlani anahtar="randevu.baslangic_saat" etiket="Takvim başlama saati"
                           tip="metin" ayarlar={ayarlar} onYaz={yaz} />
                <AyarAlani anahtar="randevu.bitis_saat" etiket="Takvim bitiş saati"
                           tip="metin" ayarlar={ayarlar} onYaz={yaz} />
                <AyarAlani anahtar="randevu.ogle_baslangic" etiket="Öğle arası başlaması"
                           tip="metin" ayarlar={ayarlar} onYaz={yaz} />
                <AyarAlani anahtar="randevu.ogle_bitis" etiket="Öğle arası bitişi"
                           tip="metin" ayarlar={ayarlar} onYaz={yaz} />
                {/* Gunler 1 Pzt … 7 Paz, virgullu: "1,2,3,4,5". */}
                <AyarAlani anahtar="randevu.calisma_gunleri"
                           etiket="Çalışma günleri (1 Pzt … 7 Paz)"
                           tip="metin" ayarlar={ayarlar} onYaz={yaz} />
              </div>
            </div>

            <div className="kagrup">
              <h6>Randevu Aralığı</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                <AyarAlani anahtar="randevu.slot_dk" etiket="Takvim aralığı (dakika)"
                           tip="sayi" ayarlar={ayarlar} onYaz={yaz} />
                <AyarAlani anahtar="randevu.varsayilan_sure"
                           etiket="Yeni randevunun varsayılan süresi (dakika)"
                           tip="sayi" ayarlar={ayarlar} onYaz={yaz} />
              </div>
            </div>
          </>
        )
      )}
    </>
  );
}
