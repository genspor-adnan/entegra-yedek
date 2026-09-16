import { useState } from 'react';
import { AyarSekmeSeridi } from '../bilesenler/AyarSekmeSeridi';
import { api } from '../api/istemci';
import { type ListeSatiri } from '../api/sozlesme';
import { AyarAlani, useAyarlar } from '../bilesenler/AyarAlani';
import { NumaralamaSekmesi } from '../bilesenler/NumaralamaSekmesi';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import { guvenli, mesaj, onay } from '../bilesenler/mesaj';
import { useOturum } from '../kimlik/OturumBaglami';

const SEKMELER = [
  // Guvenlik 2. sirada, Entegrasyon onun SAGINDA (kullanici).
  { anahtar: 'genel',       baslik: 'Genel' },
  { anahtar: 'guvenlik',    baslik: 'Güvenlik' },
  { anahtar: 'entegrasyon', baslik: 'Entegrasyon' },
  { anahtar: 'numaralama',  baslik: 'Belge No' },
] as const;

type Sekme = typeof SEKMELER[number]['anahtar'];

/**
 * Genel Ayarlar (Yönetim › Ayarlar › Genel) — firma geneli DAVRANIS ayarlari.
 *
 * Ayarlar `public.referans` tablosunda ve sunucuda BEYAZ LISTE ile korunuyor
 * (AyarDeposu). Alan cizimi/kayit AyarAlani'nda ortak: etiket ustte, "?" ikonu
 * saginda, kayit aninda.
 *
 * ENTEGRASYON sekmesi (336) — dis servis hesaplari (SKRS/Saglik.NET, e-Nabiz,
 * MEDULA, UTS, e-Belge, SMS) tek yerde. Her satir bir (entegrasyon · sube ·
 * ortam) ucludur; subesi bos kayit kurum genelidir. Sifreler listede
 * GOSTERILMEZ - yalniz "dolu mu" isareti. Once Kayit Kabul ayarlarindaydi,
 * kullanici istegiyle buraya Guvenlik'in SAGINA tasindi (entegrasyon yalniz
 * kayit kabule ait degil).
 */
export function GenelAyarlar() {
  const [aktif, setAktif] = useState<Sekme>('genel');
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();
  const { yetki } = useOturum();

  // Entegrasyon hesaplari ayri yetkiye bagli - sekme de o yetkiyle cikar.
  const entegrasyonGorur = yetki('entegrasyon');
  const sekmeler = SEKMELER.filter(s => s.anahtar !== 'entegrasyon' || entegrasyonGorur);

  const [kart, setKart] = useState<number | 'yeni' | null>(null);
  const [yenile, setYenile] = useState(0);

  async function entegrasyonAksiyon(kod: string, satir: ListeSatiri | null) {
    switch (kod) {
      case 'entegrasyon.yeni':    setKart('yeni'); return;
      case 'entegrasyon.duzenle': if (satir) setKart(Number(satir.id)); return;
      case 'entegrasyon.sil':
        if (!satir) return;
        if (!await onay(`"${String(satir.kodAdi ?? satir.kod ?? '')}" hesabı silinecek. `
                        + 'Onaylıyor musunuz?')) return;
        await guvenli(async () => {
          await api.kartSil('entegrasyon-hesap', Number(satir.id));
          setYenile(t => t + 1);
        });
        return;
      // BAGLANTI SINAMA: kimlik dogru mu, adres ayakta mi - kayit degismez.
      case 'entegrasyon.sina':
        if (!satir) return;
        await guvenli(async () => {
          const y = await api.entegrasyonSina(Number(satir.id));
          mesaj(y.mesaj);
          setYenile(t => t + 1);
        });
        return;
      // SKRS listelerini servisten cekip YEREL kod listelerini tazeler.
      case 'entegrasyon.skrs-senkron':
        if (!satir) return;
        if (String(satir.kod ?? '') !== 'SKRS') {
          mesaj('Bu işlem yalnız SKRS hesabında çalışır.');
          return;
        }
        if (!await onay('SKRS kod listeleri servisten çekilip yerel listeler '
                        + 'güncellenecek. Devam edilsin mi?')) return;
        await guvenli(async () => {
          const y = await api.skrsListeSenkron(Number(satir.id));
          mesaj(y.mesaj);
          setYenile(t => t + 1);
        });
        return;
      // SKRS klinik kodlarini BOLUM KODUNA yazar (455). Dolu kod korunur:
      //   kurum kendi kodlamasini yapmis olabilir.
      case 'entegrasyon.skrs-klinik':
        if (!satir) return;
        if (String(satir.kod ?? '') !== 'SKRS') {
          mesaj('Bu işlem yalnız SKRS hesabında çalışır.');
          return;
        }
        if (!await onay('Kodu BOŞ olan bölümlere SKRS klinik kodu yazılacak '
                        + '(dolu kodlara dokunulmaz). Devam edilsin mi?')) return;
        await guvenli(async () => {
          const y = await api.skrsKlinikEsle(Number(satir.id));
          mesaj(y.eslesmeyen.length > 0
            ? `${y.mesaj} Eşleşmeyen: `
              + y.eslesmeyen.slice(0, 8).map(b => b.ad).join(', ')
            : y.mesaj);
          setYenile(t => t + 1);
        });
        return;
    }
  }

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

      <AyarSekmeSeridi sekmeler={sekmeler} aktif={aktif} onSec={a => setAktif(a as typeof aktif)} />

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}
        {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}

        {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : aktif === 'genel' ? (
          <>
            <div className="kagrup">
              <h6>Genel</h6>
              {/* Urun modu | Yerel para | Doviz YAN YANA, ARALIKLI (kullanici);
                  combolar Belge Girisi editiyle ayni olcude (160px - tema
                  .ayar-formu select kurali). Para/doviz combolari genel.doviz
                  kod listesinden; ETIKETE tiklaninca jenerik modalda yonetilir. */}
              <div className="alan-izgara ayar-formu ayar-yanyana">
                {/* Urun modu (215): menu/marka/mesaj basliklari buna gore.
                    Degisiklik acik oturumlara SONRAKI giris/yenilemede iner. */}
                {alan('genel.urun_modu', 'Ürün modu', {
                  tip: 'secenek',
                  secenekler: [
                    { deger: '1', ad: 'Gentegre AI (ERP)' },
                    { deger: '2', ad: 'GenoTIP AI (HBYS)' },
                  ],
                })}
                {alan('genel.varsayilan_doviz', 'Döviz', { listeKod: 'genel.doviz' })}
                {/* YEREL PARA BIRIMI ve SAAT FARKI BURADAN KALDIRILDI (666/667).
                    Ikisi de artik SUBENIN ayari: Yönetim > Firma Bilgileri >
                    Adres > Yerel Ayarlar. Kurum geneline koymak, yurt disinda
                    subesi olan kurumda "hangisini yazayim" ikilemi yaratiyordu.
                    Saat farki ayrica ARTIK GEREKSIZ: zaman damgalari timestamptz
                    (667), gosterim subenin saat diliminde yapiliyor - elle
                    girilen bir kayma yaz saatinde yilda iki kez yanlis olurdu. */}
                <div className="kanot">
                  Yerel para birimi ve saat dilimi <b>şube ayarıdır</b>:
                  Yönetim › Firma Bilgileri › Yerel Ayarlar.
                </div>
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

            {/* SATINALMA (724/729/732). Bu ayarlar OLMADAN akış uçları kendi
                varsayılanlarına düşer ve kritik stok işi hiç çalışmaz - kapının
                nerede olduğu görünsün diye buraya konuldu.

                ONAY EŞİKLERİ BOŞ BIRAKILABİLİR: boşsa uç kendi varsayılanını
                kullanır (0 / 50.000 / 250.000) ve o varsayılanın gerekçesi
                kuralın yanında durur (db/729). */}
            <div className="kagrup">
              <h6>Satınalma</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('satinalma.esik_satinalma',
                      'Satınalma birimi onayı için alt tutar (boş = her talepte)')}
                {alan('satinalma.esik_mali',
                      'Mali işler onayı için alt tutar (boş = 50.000)')}
                {alan('satinalma.esik_ust',
                      'Üst yönetim onayı için alt tutar (boş = 250.000)')}
                {alan('satinalma.sozlu_onay_saat',
                      'Sözlü onayın yazılı tamamlanma süresi, saat (boş = 24)')}
                {alan('satinalma.eslestirme_tolerans_kurus',
                      'Fatura eşleştirmesinde yok sayılacak fark, kuruş (boş = 100)')}
              </div>
            </div>

            {/* KRİTİK STOK VARSAYILAN KAPALI: kurumun istemediği halde
                kendiliğinden satınalma talebi açmak, para harcanan bir süreci
                habersiz başlatmak olurdu. Açılınca saatlik iş çalışır ve depo
                başına TEK taslak talep açar (onaya insan gönderir). */}
            <div className="kagrup">
              <h6>Kritik Stok → Satınalma Talebi</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('satinalma.kritik_stok_aktif',
                      'Asgari stoğun altına düşen kalemler için otomatik talep açılsın',
                      { tip: 'mantik' })}
                {alan('satinalma.kritik_hedef_kat',
                      'Azami stok tanımsızsa hedef = asgari × bu kat (boş = 2)')}
                {alan('satinalma.kritik_departman',
                      'Otomatik talebin açılacağı birim no (boş = birimsiz taslak)')}
                {alan('satinalma.kritik_isteyen',
                      'Otomatik talepte "isteyen" personel no (boş = yazılmaz)')}
              </div>
            </div>

            {/* DEPOLAR (729): eczanenin ve teknik servisin kendi deposu vardır;
                genel depodan düşmek iki birimin sayımını da bozar. Boşsa uç
                kurumun varsayılan deposuna düşer. */}
            <div className="kagrup">
              <h6>Depolar</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('eczane.depo',
                      'Eczane giriş/çıkış fişlerinin deposu (boş = varsayılan depo)')}
                {alan('demirbas.parca_depo',
                      'Teknik servis parça çıkışının deposu (boş = varsayılan depo)')}
              </div>
            </div>
          </>
        ) : aktif === 'numaralama' ? (
          // Belge / tahsilat / odeme numaralandirmasi (152) - dort grid.
          <NumaralamaSekmesi />
        ) : aktif === 'entegrasyon' ? (
          <>
            {/* Mockup: Ekranlar/Ayarlar/entegrasyon_hesaplari.html - arama +
                cipler serit halinde, kolon sirasi mockup'la ayni.
                ARAC CUBUGU SAGA yanasik (kullanici): `aracCubuguSol`
                verilmez, gridin ust sag kosesinde durur. */}
            <GenGrid
              key="entegrasyon"
              kaynak="entegrasyon-hesap"
              gomulu
              aramaGorunumGizli
              aramaGizli
              aracCubuguSeritte
              gorunumSecimGizli
              aksiyonEkrani="entegrasyon-liste"
              cipler={[
                { ad: 'Tümü' },
                { ad: 'Aktif', filtre: { alan: 'aktif',  op: 'esit', deger: 1 } },
                { ad: 'Test',  filtre: { alan: 'testMi', op: 'esit', deger: 1 } },
                { ad: 'Canlı', filtre: { alan: 'testMi', op: 'esit', deger: 0 } },
              ]}
              kolonSirasi={['kodAdi', 'ad', 'sube', 'bazSube', 'ortam', 'kullaniciAdi',
                            'sifreVar', 'uygulamaKodu', 'entegratorAdi', 'aktif',
                            'sonKullanim', 'sonSonuc']}
              gizliKolonlar={['kod', 'testMi']}
              yenile={yenile}
              onSatirAc={satir => setKart(Number(satir.id))}
              onAksiyon={(kod, satir) => { void entegrasyonAksiyon(kod, satir) }}
            />
            <div className="not">
              Şifre değeri listede gösterilmez — yalnız “dolu mu” işareti; gerçek
              değer kartı açan yetkili kullanıcıya gider. <b>Şube boş = Tümü</b>
              (kurum geneli hesap). <b>Baz Şube</b> dolu ise o şubenin işlemleri
              baz alınan şubenin hesabıyla gider. Hesap çözümü: şubenin kendi
              satırı → baz şube → kurum geneli → (yalnız ÜTS) varsayılan şube.
            </div>
            {kart !== null && (
              <GenForm
                kaynak="entegrasyon-hesap"
                id={kart}
                baslik="Entegrasyon Hesabı"
                // Yeni kayitta combo BOS acilmasin (kullanici): baz sube
                //   varsayilani "Kendisi" (0); ortam TEST, kayit aktif -
                //   sunucudaki YeniKayitVarsayilanlari ile ayni degerler.
                yeniKayitVarsayilanlari={{ bazSubeId: 0, testMi: true, aktif: true }}
                onKapat={() => setKart(null)}
                onKaydedildi={() => { setKart(null); setYenile(t => t + 1) }}
                // Mockup'taki kart altı kutuları (uyarı + çözüm zinciri):
                //   test/canlı ayrımı ve hangi satırın kullanılacağı kartın
                //   kendisinde yazılı olsun - kullanıcı belgeye çıkmadan görsün.
                sekmeSarmalayici={(baslik, icerik) => baslik !== 'Genel' ? icerik : (
                  <>
                    {icerik}
                    <div className="uyari-kutusu" style={{ margin: '10px 12px' }}>
                      <b>Test ve canlı AYRI SATIRDIR.</b> Kurum canlıya geçerken test
                      hesabını silmez — test satırının “Aktif” kutusunu kaldırır, canlı
                      satırınkini işaretler. Aynı entegrasyon + şube + ortam üçlüsünden
                      ikinci satır açılamaz.
                    </div>
                    <div className="not" style={{ margin: '0 12px 12px' }}>
                      <b>Hesap çözümü:</b> şubenin kendi satırı → baz alınan şubenin
                      satırı → kurum geneli satır (şube boş) → varsayılan şube
                      (yalnız ÜTS). e-Fatura'da varsayılan şubeye düşülmez: “merkezin
                      kimliğiyle gönder” kararı şube kartında verilir.
                    </div>
                  </>
                )}
              />
            )}
          </>
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
