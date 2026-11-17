import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';
import { AyarSayfaBasligi } from '../bilesenler/AyarSayfaBasligi';
import { c } from '../dil/ceviri';

/**
 * KAYIT KABUL AYARLARI → İKİ EKRAN (kullanıcı 17.11.2026: "Kayıt Kabul Ayarları'nda hasta sekmesini 'Hasta Kartı
 * Ayarları' ve Başvuru sekmesini de 'Başvuru Kartı Ayarları' şeklinde 2 menü halinde Kayıt Kabul ana menüsü altında
 * Ayarlar menüsü altına oluştur"). Eski sekmeli sayfa (Genel / Hasta / Başvuru) bölündü; Genel boş yer tutucuydu, kalktı.
 * İki ekran da `kayit_kabul.ayar` yetkisiyle açılır; yazdıkları anahtarlar EkranKodlari.KayitKabulAyarAnahtarlari.
 * Eski adres (/kayit-kabul-ayarlar) Başvuru Kartı Ayarları'na yönlenir (App.tsx).
 */
// Adlar (17.11.2026): "Hasta Ayarları" / "Başvuru Ayarları".
const BASLIK = { hasta: 'Hasta Ayarları', basvuru: 'Başvuru Ayarları' } as const;

export function KayitKabulAyarlar({ bolum = 'basvuru' }: { bolum?: 'hasta' | 'basvuru' }) {
  const aktif = bolum;
  const ayar = useAyarlar({ taslakli: true });
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = ayar;

  return (
    <>
      <AyarSayfaBasligi baslik={BASLIK[bolum]} yol={`Kayıt Kabul › Ayarlar › ${BASLIK[bolum]}`} ayar={ayar} />

      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

      {yukleniyor && <div className="yukleniyor">Yükleniyor…</div>}

      {!yukleniyor && aktif === 'hasta' && (
        <>
          {/* KİMLİĞİ OKUT - MRZ (1255, mockup kimlik_mrz_okut.html ④): okutma yolu, süresi dolmuş belge, OCR eşiği.
              Açıklamalar "?" ikonunda (public.help). */}
          <div className="kagrup">
            <h6>{c('Kimlik okutma (MRZ)')}</h6>
            <div className="alan-izgara ayar-formu">
              <AyarAlani anahtar="kayit.kimlik_okutma" etiket={c('Kimlik okutma')} tip="secenek"
                         secenekler={[
                           { deger: '0', ad: c('Kapalı') },
                           { deger: '1', ad: c('Kamera') },
                           { deger: '2', ad: c('Tarayıcı / dosya') },
                           { deger: '3', ad: c('Kamera ve tarayıcı') },
                         ]}
                         ayarlar={ayarlar} onYaz={yaz} />
              <AyarAlani anahtar="kayit.suresi_dolmus_belge" etiket={c('Süresi dolmuş belge')} tip="secenek"
                         secenekler={[
                           { deger: '0', ad: c('Uyar (kayıt engellenmez)') },
                           { deger: '1', ad: c('Engelle') },
                         ]}
                         ayarlar={ayarlar} onYaz={yaz} />
              <AyarAlani anahtar="kayit.ocr_esik" etiket={c('OCR güven eşiği (%)')} ayarlar={ayarlar} onYaz={yaz} />
            </div>
            <div className="not" style={{ padding: '0 10px 10px' }}>
              {c('Hasta kartındaki ve başvuru hasta aramasındaki "Kimliği Okut" düğmesi kimlik kartının arka yüzündeki / pasaportun alt kenarındaki MRZ bölgesini okur. Görüntü sunucuya gitmez (OCR tarayıcıda); kontrol haneleri ve T.C. algoritması sunucuda denetlenir, okutma işlem loguna yazılır. MRZ okuyucu cihaz (klavye gibi metin verir) her ayarda çalışır.')}
            </div>
          </div>
          {/* NUMARALANDIRMA GRIDI BURADAN KALDIRILDI (kullanici): hasta
              belgelerinin butun numaralari 634'te TEK GRIDDE toplandi -
              Genel Ayarlar › Numaralama › Hasta Belgeleri. Ayni tabloyu iki
              ekrandan duzenlemek, hangisinin gecerli oldugu sorusunu
              doguruyordu. Aciklama burada KALIYOR: kural hastayi kaydeden
              memuru ilgilendiriyor, ayari nerede degistirecegini de soyler. */}
          <div className="not">
            Hasta dosya numarası <b>her zaman otomatik</b> verilir (396): hasta
            kartında yazılacak bir alan yoktur, bu yüzden numaralandırmadaki
            <b>{c('Numarayı kullanıcı elle yazsın')}</b> işareti hastada dikkate
            alınmaz. Numara, kayıt sırasında <b>{c('Ön Ek + Başlama No')}</b> düzenine
            göre sıradan verilir (örn. <b>H-</b> ve <b>00000100</b> →
            <b>H-00000100</b>). Göç / entegrasyon ile dışarıdan gelen numara
            varsa o korunur.
            {' '}Ön ekte <b>YYYY</b> yılın tamamını, <b>YY</b> son iki hanesini yazar
            (<b>YYYY-</b> + <b>000005</b> → <b>2026-000005</b>); yıl yer tutucusu
            varsa sayaç da yıl başında <b>1’den</b> başlar.
            {' '}Düzeni değiştirmek için: <b>Genel Ayarlar › Numaralama ›
            Hasta Belgeleri</b>.
          </div>
        </>
      )}

      {!yukleniyor && aktif === 'basvuru' && (
        <>
        {/* KVKK / ETK ONAYI (1353, kullanıcı 17.11.2026; mockup Ekranlar/Kayıt Kabul/kvkk_onay_gecerlilik.html A):
            yeni başvuruda hastanın geçerli son onayı KVKK / ETK'yı doldurur; geçerliliği bu iki ayar belirler. */}
        <div className="kagrup">
          <h6>{c('KVKK / ETK onayı')}</h6>
          <div className="alan-izgara ayar-formu">
            <AyarAlani anahtar="basvuru.kvkk_sube_bazli" etiket={c('KVKK onayı şube bazlı')} tip="secenek"
                       secenekler={[
                         { deger: '0', ad: c('Tüm şubelerde geçerli') },
                         { deger: '1', ad: c('Her şube için ayrı onay al') },
                       ]}
                       ayarlar={ayarlar} onYaz={yaz} />
            <AyarAlani anahtar="basvuru.kvkk_gecerlilik_gun" etiket={c('Onay geçerlilik süresi (gün, 0 = süresiz)')}
                       ayarlar={ayarlar} onYaz={yaz} />
          </div>
          <div className="not" style={{ padding: '0 10px 10px' }}>
            {c('Geçerli sayılan onay: SMS ile onay alındı ve Islak imzalı onay alındı. Hasta Reddetti ve Onaysız durumu sonraki başvuruya taşınmaz - hastaya her başvuruda yeniden sorulur. İptal edilmiş başvurudaki onay sayılmaz.')}
          </div>
        </div>
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

          {/* SGK KATILIM PAYI - TUTAR ve KODLAR YAN YANA (kullanici: "yanına da
              tahakkuk edecek SUT fiyat kodları editini koy… bu opsiyonu SGK
              Katılım Payı (TL)'nin sağ tarafına taşı"). Ikisi TEK KARARIN iki
              parcasi: ne kadar alinacagi ve hangi kalemde alinacagi - alt alta
              dizilince ilgisiz iki ayar gibi okunuyordu. Aciklamalar "?"
              ikonunda (db/593), alt paragrafta degil.

              Kodlar kutusu GENIS: virgullu kod listesi dar kutuda okunmuyor. */}
          <div className="alan-izgara ayar-formu katilim-payi-satiri">
            <AyarAlani anahtar="basvuru.sgk_katilim_payi"
                       etiket="SGK Katılım Payı (TL)"
                       ayarlar={ayarlar} onYaz={yaz} />
            <AyarAlani anahtar="basvuru.sgk_katilim_kodlari"
                       etiket="Katılım Payı Alınacak SUT Kodları"
                       tip="metin" genis
                       ayarlar={ayarlar} onYaz={yaz} />
          </div>

          {/* ISKONTO ONAY ESIGI (783/792/793, kullanici: "oranları nereden
              değiştireceğim"): kural vardi ama orani yalnizca SQL ile
              degistirilebiliyordu - ayar beyaz listede degildi.

              UC SAYI UC AYRI YERDE, karistirilmasin diye alttaki not ikisini
              de adresliyor: bu kutu KURUMUN esigi, rol tavani Yetkiler
              ekraninda. */}
          <div className="alan-izgara ayar-formu">
            <AyarAlani anahtar="basvuru.iskonto_onay_esik"
                       etiket="İskonto Onay Eşiği (%)"
                       ayarlar={ayarlar} onYaz={yaz} />
          </div>
          <div className="not">
            Bu oranın <b>üstündeki</b> iskonto, kişinin tavanı yetse bile
            <b> onaylı talepten</b> gelmek zorunda; <b>0</b> yazarsanız kural
            kapanır. Kişi başına <b>tavan</b> ayrı bir ayardır:
            <b>{c('Yönetim › Roller ve Yetkiler')}</b> → rolü seçin → <b>Başvuru ›
            İskonto</b> satırının <b>{c('Sınır')}</b> kutusu. Onay zincirinin hangi
            oranda hangi kademeye gideceği ise <b>Onay Akışları</b> ekranındaki
            <b>{c('Eşik (≥)')}</b> alanıdır.
          </div>
        </div>
        {/* PROTOKOL NO gridi de 634'te Hasta Belgeleri'ne tasindi. */}
        <div className="not">
          Protokol numarası kaydederken <b>{c('Ön Ek + Başlama No')}</b> düzenine göre
          verilir. Ön ekte <b>YYYY</b> / <b>YY</b> yazarsanız yıl otomatik geçer
          (<b>YYYY-</b> → <b>2026-000005</b>) ve sayaç her yıl 1’den başlar. <b>{c('Numarayı kullanıcı elle yazsın')}</b> işaretlenirse kayıt kabul
          memuru protokol numarasını başvuru kartında yazabilir; boş bırakılırsa
          numara yine sistemce verilir — başvuru numarasız kalmaz.
          {' '}Düzeni değiştirmek için: <b>Genel Ayarlar › Numaralama ›
          Hasta Belgeleri</b>.
        </div>
        </>
      )}
    </>
  );
}
