import { useState } from 'react';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';
import { NumaraGridi } from '../bilesenler/NumaralamaSekmesi';

const SEKMELER = [
  { anahtar: 'genel',   baslik: 'Genel' },
  { anahtar: 'hasta',   baslik: 'Hasta' },
  { anahtar: 'basvuru', baslik: 'Başvuru' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * KAYIT KABUL AYARLARI (Yönetim › Modül Ayarları › Kayıt Kabul, kullanici).
 * Kasa/Stok ayarlariyla ayni desen: liste degil, ayar konularini sekmelerde
 * toplayan ozel sayfa.
 *
 * Genel ve Hasta sekmeleri bilerek simdiden duruyor - hasta kartı ve kabul
 * akisinin ayarlari buraya eklenecek; ekran o zaman yeniden kurgulanmasin.
 */
export function KayitKabulAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();


  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>Kayıt Kabul Ayarları</h1>
          <span className="yol">Yönetim › Modül Ayarları › Kayıt Kabul</span>
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

      {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}

      {!yukleniyor && aktif === 'genel' && (
        <>
        <div className="kagrup">
          <h6>Genel</h6>
          <div className="not">
            Kayıt kabul modülünün genel davranış ayarları buraya eklenecek.
            Randevu düzeni (gün/saat, bölümler) ayrı ekranda: Kayıt Kabul ›
            Randevu Ayarları.
          </div>
        </div>
        </>
      )}

      {!yukleniyor && aktif === 'hasta' && (
        <>
          {/* DOSYA NO numaralandirma tablosunda (358, kullanici): on ek, hane,
              baslangic ve "elle mi yazilacak" karari ayni satirda durur -
              ayri bir "otomatik uretilsin" ayari yok. */}
          <NumaraGridi kaynak="numara-hasta" baslik="Dosya No Numaralandırma" />
          <div className="not">
            <b>Numarayı kullanıcı elle yazsın</b> işaretliyse hasta kartında Dosya No
            zorunludur. İşaret kaldırılırsa alan boş bırakılabilir; kayıt sırasında
            <b> Ön Ek + Başlama No</b> düzenine göre sıradaki numara verilir
            (örn. <b>H-</b> ve <b>00000100</b> → <b>H-00000100</b>). Elle numara
            yazılırsa her iki durumda da yazılan numara korunur.
            {' '}Ön ekte <b>YYYY</b> yılın tamamını, <b>YY</b> son iki hanesini yazar
            (<b>YYYY-</b> + <b>000005</b> → <b>2026-000005</b>); yıl yer tutucusu
            varsa sayaç da yıl başında <b>1’den</b> başlar.
          </div>
        </>
      )}

      {!yukleniyor && aktif === 'basvuru' && (
        <>
        <div className="kagrup">
          <h6>Başvuru</h6>
          <div className="alan-izgara tek-sutun ayar-formu">
            {/* TAHSILATTA POS (kullanici): basvuruya POS tahsilati islenince
                ne olacak. Otomatik/soran secenekte TAHSIL EDILEN KADAR satis
                fisi kesilir (352 tutar bazli donusum); kalan basvuruda acik
                kalir ve istenirse tahakkuka cevrilir. */}
            <AyarAlani anahtar="basvuru.pos_aksiyon"
                       etiket="Tahsilatta POS"
                       tip="secenek"
                       secenekler={[
                         { deger: '0', ad: 'Aksiyon Yok' },
                         { deger: '1', ad: 'Otomatik Fiş Oluşsun' },
                         { deger: '2', ad: 'Fatura/Fiş kesilmesin mi sorusu sorulsun' },
                       ]}
                       ayarlar={ayarlar} onYaz={yaz} />
          </div>
        </div>
        {/* PROTOKOL NO da numaralandirma tablosunda (358). */}
        <NumaraGridi kaynak="numara-basvuru" baslik="Protokol No Numaralandırma" />
        <div className="not">
          Protokol numarası kaydederken <b>Ön Ek + Başlama No</b> düzenine göre
          verilir. Ön ekte <b>YYYY</b> / <b>YY</b> yazarsanız yıl otomatik geçer
          (<b>YYYY-</b> → <b>2026-000005</b>) ve sayaç her yıl 1’den başlar. <b>Numarayı kullanıcı elle yazsın</b> işaretlenirse kayıt kabul
          memuru protokol numarasını başvuru kartında yazabilir; boş bırakılırsa
          numara yine sistemce verilir — başvuru numarasız kalmaz.
        </div>
        </>
      )}
    </>
  );
}
