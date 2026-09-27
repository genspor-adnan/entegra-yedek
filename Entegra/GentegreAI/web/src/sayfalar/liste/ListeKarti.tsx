import { GenForm } from '../../bilesenler/GenForm';
import { Modal } from '../../bilesenler/Modal';
import { LabMikroOzet, labMikroOzetiVar } from '../../bilesenler/LabMikroOzet';
import { LabCalismaTakvimi, type CalismaDuzeni }
  from '../../bilesenler/lab/LabCalismaTakvimi';
import { MuayeneBaglamSeridi } from '../../bilesenler/MuayeneBaglamSeridi';
import { MuayeneDurumSeridi } from '../../bilesenler/MuayeneDurumSeridi';
import { MuayeneSonucOzeti } from '../../bilesenler/MuayeneSonucOzeti';
import { MuayeneIstemSonuc } from '../../bilesenler/MuayeneIstemSonuc';
import {
  useMuayeneSekmeVerisi, MuayeneReceteSekmesi, MuayeneKonsultasyonSekmesi,
  MuayeneUcretSekmesi, MuayeneGecmisSekmesi,
} from '../../bilesenler/MuayeneSekmeleri';
import { DokumanGalerisi } from '../../bilesenler/DokumanGalerisi';
import { AsiUygulaModali } from '../../bilesenler/AsiUygulaModali';
import { CocukIzlemModali } from '../../bilesenler/CocukIzlemModali';
import { GebeIzlemModali } from '../../bilesenler/GebeIzlemModali';
import { EnabizButonu } from '../../bilesenler/EnabizButonu';
import { useOturum } from '../../kimlik/OturumBaglami';
import { EnabizMesajModali } from '../../bilesenler/EnabizMesajModali';
import { LabIstemSepetiModal } from '../../bilesenler/lab/LabIstemSepetiModal';
import { MuayeneRaporModal } from '../../bilesenler/MuayeneRaporModal';
import { useState } from 'react';
import type { ListeSatiri } from '../../api/sozlesme';
import type { ListeTanimi } from '../listeTanimlari';
import type { KartOzellestirme } from './kartOzellestirme';

/** Muayene durum kodlari (kart metasindaki SabitKodlar ile ayni) - baslik
    rozeti icin. Kod->ad cevrimi tek satirlik, ek istek gerektirmesin. */
const MUAYENE_DURUM: Record<string, string> = {
  '1': 'Açık', '2': 'Sonuç Bekliyor', '3': 'Tamamlandı',
  '4': 'Ek Not Eklendi', '0': 'İptal',
};

export interface ListeKartiOzellikleri {
  tanim: ListeTanimi;
  /** null iken kart kapali; 'yeni' yeni kayit. */
  kartId: number | 'yeni' | null;
  kartOzel: KartOzellestirme;
  sekmeVerisi: ReturnType<typeof useMuayeneSekmeVerisi>;
  /** Karttaki eylem dugmeleri listedekiyle AYNI isleyiciye gider. */
  aksiyon(kod: string, satir?: ListeSatiri | null): void | Promise<void>;
  muayeneBilgiAcik: boolean;
  setMuayeneBilgiAcik(acik: boolean): void;
  setIcdAramaAcik(acik: boolean): void;
  kartTazele: number;
  setKartTazele(f: (t: number) => number): void;
  sorgu: URLSearchParams;
  git(yol: string, secenek?: { replace?: boolean }): void;
  setYenile(f: (t: number) => number): void;
  /** Hasta kartındaki "＋ Yeni Başvuru": kart kapanır, başvuru açılır (782). */
  onBasvuruAc?(tarafId: number, unvan: string): void;
  setOdaklaSonEklenen(f: (t: number) => number): void;
}

/**
 * KART (modal GenForm) - liste ekraninin kart yuzu.
 *
 * `Liste` govdesinde duran ~280 satirlik GenForm cagrisi buraya alindi:
 * muayene kartinin sekme sarmalayicilari, baglam seridi, ek sekmeleri ve
 * eylem dugmeleri ile lab tetkik kartinin calisma takvimi burada yasiyor.
 * Davranis degismedi - yalniz yeri degisti.
 */
/**
 * Goz muayene kartindaki kisayollarin actigi kartlar (691). Bu uc
 * kaynak URL'den `hastaId` / `muayeneId` on dolgusu kabul eder.
 */
const HASTA_KAYIT_KAYNAKLARI = new Set(['hasta-alerji', 'hasta-kronik', 'hasta-ilac', 'hasta-gecmis', 'ftr-degerlendirme', 'ftr-program', 'ftr-olcek', 'isg-calisan']);
const GOZ_KISAYOL_KAYNAKLARI = new Set([
  'goz-gozluk-recete', 'goz-goruntuleme', 'goz-islem',
]);

export function ListeKarti({
  tanim, kartId, kartOzel, sekmeVerisi, aksiyon,
  muayeneBilgiAcik, setMuayeneBilgiAcik, setIcdAramaAcik,
  kartTazele, setKartTazele, sorgu, git, setYenile, setOdaklaSonEklenen,
  onBasvuruAc,
}: ListeKartiOzellikleri) {
  // KANCALAR ERKEN CIKISTAN ONCE: `kartId === null` dalinda da ayni sirada
  //   calismalari gerekir (React kanca kurali).
  const [enabizMesaj, setEnabizMesaj] = useState<
    { hastaId: number; hastaAdi: string; belgeId: number | null } | null>(null);
  // AŞI PENCERESİ (898): hasta kartından açılır.
  const [asiHasta, setAsiHasta] = useState<{ id: number; ad: string } | null>(null);
  const [izlemHasta, setIzlemHasta] = useState<{ id: number; ad: string } | null>(null);
  const [gebeHasta, setGebeHasta] = useState<{ id: number; ad: string } | null>(null);
  // HEKİM LAB İSTEM SEPETİ (kullanici): muayeneId set olunca sepet modalı açılır.
  const [labIstem, setLabIstem] = useState<number | null>(null);
  // RAPOR EKLE MODALI (kullanici: "eklerken direkt modal ön bilgilerle açılsın").
  const [raporModal, setRaporModal] = useState<{ muayeneId: number; tur: number } | null>(null);
  const { aksiyonVar } = useOturum();

  if (kartId === null || !tanim.kartYolu || tanim.ozelKart) return null;

  return (
    <>
      {gebeHasta && (
        <GebeIzlemModali hastaId={gebeHasta.id} hastaAdi={gebeHasta.ad}
                         onKapat={() => setGebeHasta(null)} />
      )}
      {izlemHasta && (
        <CocukIzlemModali hastaId={izlemHasta.id} cocukAdi={izlemHasta.ad}
                          onKapat={() => setIzlemHasta(null)} />
      )}
      {asiHasta && (
        <AsiUygulaModali hastaId={asiHasta.id} hastaAdi={asiHasta.ad}
                         onKapat={() => setAsiHasta(null)} />
      )}
      {enabizMesaj && (
        <EnabizMesajModali hastaId={enabizMesaj.hastaId} hastaAdi={enabizMesaj.hastaAdi}
                           belgeId={enabizMesaj.belgeId} onKapat={() => setEnabizMesaj(null)} />
      )}
      {labIstem !== null && (
        <LabIstemSepetiModal muayeneId={labIstem}
          onKapat={() => setLabIstem(null)}
          onBitti={() => setKartTazele(t => t + 1)} />
      )}
      {raporModal && (
        <MuayeneRaporModal muayeneId={raporModal.muayeneId} ilkTur={raporModal.tur}
          onKapat={() => setRaporModal(null)}
          onKaydedildi={() => setKartTazele(t => t + 1)} />
      )}
      <GenForm
        kaynak={tanim.kaynak}
        id={kartId}
        // MUAYENE > ISTEM & SONUCLAR (443): katalogdan gelen bag gridi
        //   "su istem acildi" der; hekimin ihtiyaci SONUCUN KENDISI.
        //   Sarmalayici o sekmenin ALTINA sonuc panelini koyar - gridi
        //   kaldirmadan, cunku "gorduм" isareti ve aciliyet orada duruyor.
        // ÇALIŞMA TAKVİMİ (487): tetkik kartinin "Çalışma Zamanları"
        //   sekmesinde, alanlarin ALTINDA haftalik tablo ve uc ozet kutusu.
        //   Alanlar girdi, takvim SONUC - ikisi ayni sekmede olmali ki
        //   kullanici "bu ayarla sonuc ne zaman cikar" sorusunu kaydetmeden
        //   gorebilsin. Hesap sunucuda.
        sekmeSarmalayici={tanim.kaynak === 'lab-tetkik'
          ? (baslik, icerik, deger) => (
              baslik.includes('Çalışma Zamanları')
                ? <>{icerik}<LabCalismaTakvimi deger={deger as CalismaDuzeni} /></>
                : icerik)
          : tanim.kaynak === 'muayene' && kartId !== 'yeni'
          ? (baslik, icerik, _deger, izgaraCiz) => (
              baslik.includes('Anamnez')
                // MOCKUP IKI PANEL (461): solda sikayet/hikaye/ozgecmis,
                //   sagda SON vital olcumu. Hekim sikayeti yazarken
                //   tansiyonu ayni ekranda gormeli - vital ayri sekmede
                //   kalirsa bakilmadan yazilir.
                ? (
                  <div className="muayene-ikili">
                    <div className="mi-sol">{icerik}</div>
                    <div className="mi-sag">
                      {/* VITAL IZGARASI DUZENLENEBILIR (kullanici): okunur
                          panel yerine muayenenin SON olcumu - hekim sikayeti
                          yazarken tansiyonu ayni ekranda girer. Sira mockup:
                          tansiyon/nabiz/SpO2 · ates/solunum/agri ·
                          boy-kilo/BKI/bel. */}
                      {izgaraCiz?.('vitaller')}
                      {/* Mockup'ta vitalin ALTINDA "Bugunku sonuclar": hekim
                          anamnezi yazarken bugun ne ciktigini yaninda ister. */}
                      <MuayeneSonucOzeti muayeneId={Number(kartId)} />
                    </div>
                  </div>
                )
                : baslik === 'Rapor' ? (
                  // MOCKUP RAPOR ARAC CUBUGU: rapor ekleme grid basliginda,
                  //   imza SUNUCU ucunda (eksik rapor reddedilir).
                  <>
                    <div className="muayene-arac">
                      <button type="button" className="d"
                              onClick={() => setRaporModal({ muayeneId: Number(kartId), tur: 1 })}>
                        ＋ Rapor
                      </button>
                      <button type="button" className="d"
                              onClick={() => setRaporModal({ muayeneId: Number(kartId), tur: 1 })}>
                        📋 Rapor şablonu ▾
                      </button>
                      <button type="button" className="d sil"
                              onClick={() => void aksiyon('muayene.raporSil',
                                                          { id: Number(kartId) })}>
                        🗑 Rapor Sil
                      </button>
                      <button type="button" className="d bir"
                              onClick={() => void aksiyon('muayene.raporImza',
                                                          { id: Number(kartId) })}>
                        ✍ e-İmzala
                      </button>
                    </div>
                    {icerik}
                    <div className="not ic">
                      Türler: istirahat · sağlık durumu · ilaç kullanım (SUT) ·
                      iş göremezlik. Bitiş tarihi başlangıç + süreden hesaplanır;
                      imzalanan rapor değiştirilemez.
                    </div>
                  </>
                )
                : baslik.startsWith('Sevk') ? (
                  // Sevk alanlarinin ALTINDA bu muayeneden istenen
                  //   konsultasyonlar (mockup "Sevk / Konsultasyon").
                  <MuayeneKonsultasyonSekmesi veri={sekmeVerisi.veri}
                                              hata={sekmeVerisi.hata}
                                              icerik={icerik} />
                )
                : (
                  <>
                    {/* FIZIK MUAYENE ARAC CUBUGU (mockup): sablon uygula ve
                        "tumu normal" - ikisi de SUNUCU ucuna gider, satirlari
                        istemci degistirmez. */}
                    {baslik.startsWith('Tanı') && (
                      <div className="muayene-arac">
                        {/* Tek mavi dugme (kullanici): ICD kodu/adi SORULUR,
                            katalog aramasi ve ekleme sunucuda. */}
                        <button type="button" className="d bir"
                                onClick={() => setIcdAramaAcik(true)}>
                          ＋ ICD-10 Ekle
                        </button>
                        {/* Kaldir/duzenle GRID BASLIGINDA (ikonlu kip):
                            secili satira uygulanir. */}
                        {/* Sık / son / önceki listeleri ARAMA PENCERESINDE
                            (kullanıcı): tek yerde, aramayla aynı akışta. */}
                      </div>
                    )}
                    {baslik === 'Fizik Muayene' && (
                      <div className="muayene-arac">
                        <button type="button" className="d"
                                onClick={() => void aksiyon('muayene.sablon',
                                                            { id: Number(kartId) })}>
                          📋 Şablon Uygula
                        </button>
                        <button type="button" className="d"
                                onClick={() => void aksiyon('muayene.normal',
                                                            { id: Number(kartId) })}>
                          ☑ Tümü normal işaretle
                        </button>
                      </div>
                    )}
                    {/* ISTEM & SONUCLAR (mockup): BAG GRIDI CIZILMEZ - hedef
                        tablo/id teknik alanlar, hekime bir sey soylemiyor;
                        "gordum" isareti panelde dugme. Sekme mockup'taki
                        gibi arac cubugu + tek istem tablosu + ayrintilar. */}
                    {baslik.includes('Sonuç') ? (
                      <>
                        <div className="muayene-arac">
                          <button type="button" className="d"
                                  onClick={() => setLabIstem(Number(kartId))}>
                            ＋ Laboratuvar
                          </button>
                          <button type="button" className="d"
                                  onClick={() => void aksiyon('muayene.istemGoruntuleme',
                                                              { id: Number(kartId) })}>
                            ＋ Görüntüleme
                          </button>
                        </div>
                        <MuayeneIstemSonuc muayeneId={Number(kartId)} />
                      </>
                    ) : icerik}
                  </>
                )
            )
          : undefined}
        // MUAYENE BAGLAM SERIDI (461, mockup muayene_karti.html): hasta,
        //   alerji/kronik, aktif ilac ve bugunun notu her sekmenin ustunde
        //   durur - hekim ilac yazarken alerjiyi ayri sekmede aramamali.
        // DURUM BASLIKTA ROZET (kullanici): alan izgarasinda kutu tutmak
        //   yerine kartin ustunde - hasta/protokol/tarih bilgisi zaten
        //   baglam seridinde, izgara yalnizca YAZILAN alanlara kaliyor.
        baslikEk={tanim.kaynak === 'muayene'
          ? (d) => {
              const kod = String(d.durum ?? '');
              const ad = MUAYENE_DURUM[kod] ?? '';
              if (!ad) return null;
              const sinif = kod === '3' ? 'olumlu' : kod === '0' ? 'gri'
                          : kod === '2' ? 'uyari' : 'mavi';
              return <span className={`rozet ${sinif}`}>{ad}</span>;
            }
          // LAB ISTEM NUMARASI BASLIKTA (kullanici: "kaydedince otomatik
          //   olsun, duzenle diye girince baslikta gorsun"). Numara artik
          //   yazilamiyor - tetikle uretiliyor (641) - ve kimlik seridindeki
          //   yerini Kaynak aldi. Yazilamayan bir numaraya alan izgarasinda
          //   kutu tutmak yerine basligda rozet: yeni kayitta hic cikmaz,
          //   kaydedilince gorunur.
          : tanim.kaynak === 'lab-istem'
          ? (d) => {
              const no = String(d.istemNo ?? '');
              return no ? <span className="rozet mavi">{no}</span> : null;
            }
          : undefined}
        // UYARI BANDI BAGLAM SERIDININ ALTINDA (kullanici): "ana tani
        //   girilmedi", "panik sonuc", "alerji kaydi var" hekim yazmaya
        //   baslamadan gorulmeli - kartin en altinda fark edilmiyordu.
        ustBaglam={tanim.kaynak === 'muayene' && kartId !== 'yeni'
          ? () => (
            <>
              <MuayeneBaglamSeridi muayeneId={Number(kartId)}
                                   onBugun={() => setMuayeneBilgiAcik(true)} />
              <MuayeneDurumSeridi muayeneId={Number(kartId)} />
            </>
          )
          : undefined}
        // PENCEREDEKI ALAN SIRASI (kullanici): once hekimin sectikleri
        //   (bolum, hekim, tur, isteyen muayene), EN ALTTA sistemin yazdigi
        //   baslama/bitis damgalari. `seritAlanlari` hem listeyi hem SIRAYI
        //   belirler; katalogdaki tanim sirasi degismedi.
        // FIZIK MUAYENE TEK SEKME (mockup muayene_karti.html): "Bulgular"
        //   detayi ayri sekme degil, "Muayene" sekmesinde sablon alanlarinin
        //   ALTINDA - hekim sablonu secip ayni ekranda dolduruyor.
        //   Mockup tablosu UC KOLON (kullanici): Sistem (etiket) · Normal
        //   (kutu) · Bulgu (metin). Sistem satirin kimligidir - satirlar
        //   sablondan acilir, secim kutusu yanlis bir vaat olurdu; deger/taraf
        //   ise mockup'ta yok.
        tazeleAnahtari={kartTazele}
        detaySecenekleri={kartOzel.detaySecenekleri}
        sekmeSirasi={kartOzel.sekmeSirasi}
        // MOCKUP EK SEKMELERI (muayene_karti.html): e-Recete · Sevk /
        //   Konsultasyon · Islem & Ucret · Gecmis · Dosyalar. Icerik gercek
        //   kayitlardan gelir (tek uc: /api/muayene/{id}/sekme-verisi);
        //   yazma islemleri kendi ekranlarinda kalir.
        // MIKRO KATALOG KARTLARININ "Tanım" SEKMESI (mockup
        //   Ekranlar/Lab/besiyeri_karti.html · organizma_karti.html ·
        //   antibiyotik_karti.html): uc mockup'ta da ILK sekme okunur bir
        //   ozettir. Icerik kartin KENDI degerlerinden gelir - ikinci istek
        //   yok, kural yok.
        ekSekmeler={labMikroOzetiVar(tanim.kaynak)
            && kartId !== 'yeni' && kartId !== null
          ? [{ anahtar: 'ozel:tanim', baslik: 'Tanım',
               ciz: baglam => <LabMikroOzet kaynak={tanim.kaynak} baglam={baglam} /> }]
          : tanim.kaynak === 'muayene' && kartId !== 'yeni' && kartId !== null
          ? [
              { anahtar: 'ozel:recete', baslik: 'e-Reçete',
                ciz: () => (
                  <MuayeneReceteSekmesi
                    veri={sekmeVerisi.veri} hata={sekmeVerisi.hata}
                    muayeneId={Number(kartId)}
                    // Recetenin tanisi muayenenin ANA + ek tanilaridir; ayri
                    //   sorulacak bir sey degil (mockup da okunur gosteriyor).
                    tanilar={sekmeVerisi.veri?.tanilar ?? ''}
                    tazele={() => setKartTazele(t => t + 1)} />
                ) },
              { anahtar: 'ozel:ucret', baslik: 'İşlem & Ücret',
                ciz: () => <MuayeneUcretSekmesi veri={sekmeVerisi.veri}
                                                hata={sekmeVerisi.hata} /> },
              { anahtar: 'ozel:gecmis', baslik: 'Geçmiş',
                ciz: () => (
                  <MuayeneGecmisSekmesi veri={sekmeVerisi.veri} hata={sekmeVerisi.hata}
                                        muayeneId={Number(kartId)}
                                        tazele={() => setKartTazele(t => t + 1)} />
                ) },
              { anahtar: 'ozel:dosyalar', baslik: 'Dosyalar',
                ciz: () => <DokumanGalerisi kartAdi="muayene"
                                            kaynakId={Number(kartId)}
                                            saltOkunur={false} /> },
            ]
          : undefined}
        // VITAL BULGULAR SEKMESI YOK (kullanici): olcum anamnez sekmesinin
        //   sag panelinde duzenleniyor - ayni veriyi iki sekmede gostermek
        //   hangisinin gecerli oldugunu belirsiz birakiyordu.
        gizliDetaylar={kartOzel.gizliDetaylar}
        detayGrupta={kartOzel.detayGrupta}
        detayIzgara={kartOzel.detayIzgara}
        seritAlanlari={kartOzel.seritAlanlari}
        // KIMLIK SERIDI MODALA TASINDI (kullanici): serit kart govdesinde
        //   cizilmez; "Bugun" kutusuna basilinca ayni GenForm alanlariyla
        //   (yani ayni deger/dogrulama/kaydetme yoluyla) pencerede acilir.
        seritSarmalayici={tanim.kaynak === 'muayene' && kartId !== 'yeni'
          ? (serit) => (muayeneBilgiAcik ? (
              <Modal baslik="Muayene bilgileri" dar enUst
                     onKapat={() => setMuayeneBilgiAcik(false)}
                     alt={<button type="button" className="d"
                                  onClick={() => setMuayeneBilgiAcik(false)}>Kapat</button>}>
                <div className="muayene-bilgi">{serit}</div>
              </Modal>
            ) : null)
          : undefined}

        // KART ARAC CUBUGU: muayene (461) ve goz muayenesi (691) kendi
        //   eylemlerini burada gosterir. DUGMELER LISTE AKSIYON KODLARINI
        //   cagirir - kural ve yetki tek yerde kalir; ayni kod hem sag tus
        //   menusunden hem karttan gecer.
        // e-NABIZ DÜĞMESİ HASTA KARTINDA DA (KTS H8): denetim "yer"i ayrıca
        //   soruyor - düğme yalnız muayenede olursa, hastayı kartından açan
        //   hekim aynı işlemi bulamıyor. Hasta kartında mesaj/erişim ikisi
        //   de aynı bileşenle, aynı yerde.
        ekAraclar={kartId !== 'yeni' && tanim.kaynak === 'hasta'
          ? (d) => {
              const hid = Number(kartId);
              return (
                <>
                  {/* AŞI UYGULAMA (898, KTS H10): doz numarasını sunucu
                      hesaplıyor, ekran yalnız aşıyı ve lotu soruyor. */}
                  {/* GEBE İZLEMİ (900, KTS H10): önce dosya, sonra izlem;
                      hafta sunucudan gelir. */}
                  {aksiyonVar('gebe.izlem') && (
                    <button type="button" className="d"
                            onClick={() => setGebeHasta({
                              id: hid, ad: String(d.unvan ?? d.ad ?? '') })}>
                      🤰 Gebe İzlemi
                    </button>
                  )}
                  {/* ÇOCUK İZLEMİ (899, KTS H10): izlem sırasını sunucu
                      söylüyor, persentil ölçümle birlikte görünüyor. */}
                  {aksiyonVar('cocuk.izlem') && (
                    <button type="button" className="d"
                            onClick={() => setIzlemHasta({
                              id: hid, ad: String(d.unvan ?? d.ad ?? '') })}>
                      👶 Çocuk İzlemi
                    </button>
                  )}
                  {aksiyonVar('asi') && (
                    <button type="button" className="d"
                            onClick={() => setAsiHasta({
                              id: hid, ad: String(d.unvan ?? d.ad ?? '') })}>
                      💉 Aşı Uygula
                    </button>
                  )}
                  <EnabizButonu tur="erisim" hastaId={hid} />
                  <EnabizButonu tur="mesaj" hastaId={hid}
                                onMesaj={() => setEnabizMesaj({
                                  hastaId: hid,
                                  hastaAdi: String(d.unvan ?? d.ad ?? ''),
                                  belgeId: null })} />
                </>
              );
            }
          : kartId !== 'yeni'
                   && (tanim.kaynak === 'muayene' || tanim.kaynak === 'goz-muayene')
          ? (d) => {
              const satir = {
                id: Number(kartId),
                hastaId: Number(d.hastaId ?? d.tarafId ?? 0),
                hastaAdi: String(d.tarafAdi ?? d.hastaAdi ?? ''),
                // Kisayolla acilacak kayitlar bu muayeneye baglanir.
                muayeneId: Number(d.muayeneId ?? 0),
              };
              const dugme = (kod: string, ad: string, sinif = 'd') => (
                <button key={kod} type="button" className={sinif}
                        onClick={() => void aksiyon(kod, satir)}>{ad}</button>
              );
              return tanim.kaynak === 'muayene' ? (
                <>
                  {dugme('muayene.al', '▶ Muayeneye Al')}
                  {dugme('muayene.istem', '🧪 İstem Aç')}
                  {dugme('muayene.sablon', '📋 Şablon Uygula')}
                  {/* e-NABIZ MESAJI (877, KTS H7): hekim ekranından hastanın
                      e-Nabız profiline düz metin bilgilendirme. Aksiyon
                      kataloğuna girmiyor - liste satırında değil, KART
                      bağlamında anlamlı (hangi hasta, hangi başvuru). */}
                  {/* e-NABIZ DÜĞMELERİ (KTS H8): görünüm, konum ve ipucu
                      TEK BİLEŞENDE (`EnabizButonu`) - denetim "standarda
                      uygun mu" diye sorduğunda cevap iki ekranda aynı
                      olmalı. Erişim akışı (878) ve mesaj penceresi (877)
                      değişmedi, yalnız düğme ortaklaştı. */}
                  <EnabizButonu key="enabiz.erisim" tur="erisim"
                                hastaId={satir.hastaId} muayeneId={satir.muayeneId || null} />
                  <EnabizButonu key="enabiz.mesaj" tur="mesaj" hastaId={satir.hastaId}
                                belgeId={Number(d.belgeId ?? 0) || null}
                                onMesaj={() => setEnabizMesaj({
                                  hastaId: satir.hastaId, hastaAdi: satir.hastaAdi,
                                  belgeId: Number(d.belgeId ?? 0) || null })} />
                  {dugme('muayene.tamamla', '✓ Tamamla')}
                </>
              ) : (
                // GOZ MUAYENESI (mockup goz_detayli_muayene.html araç çubuğu):
                //   hekim ölçümü bitirince buradan çıkış yapıyor.
                <>
                  {dugme('goz.muayene-tamamla', '✔ Tamamla', 'd onay')}
                  {dugme('goz.gozluk-recete', '👓 Gözlük Reçetesi')}
                  {dugme('goz.goruntuleme-iste', '📷 Görüntüleme İste')}
                  {dugme('goz.islem-planla', '💉 İşlem Planla')}
                  {dugme('goz.onceki-kopyala', '📋 Önceki Muayeneden Kopyala')}
                  {dugme('goz.sema', '🖼 Göz Şeması')}
                  {dugme('goz.dikte', '🎙 Dikte')}
                </>
              );
            }
          : undefined}
        baslik={tanim.kartBaslik ?? tanim.baslik.replace(/ler$|lar$/, '')}
        yerTutucuSekmeler={tanim.yerTutucuSekmeler}
        gizliAlanlar={tanim.gizliKartAlanlari}
        gizliSekmeler={tanim.gizliKartSekmeleri}
        zorunluAlanlar={tanim.zorunluKartAlanlari}
        resimYerTutucu={tanim.resimYerTutucu}
        // Takvimden gelen saat/sure (251): URL parametreleri kart varsayilani
        //   olur - kart acilinca alanlar dolu gelir.
        yeniKayitVarsayilanlari={tanim.kaynak === 'randevu' && sorgu.get('baslangic')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              baslangic: sorgu.get('baslangic')!,
              ...(sorgu.get('sure') ? { sureDk: Number(sorgu.get('sure')) } : {}),
              ...(sorgu.get('hekim') ? { hekimId: Number(sorgu.get('hekim')) } : {}),
              ...(sorgu.get('bolum') ? { bolum: Number(sorgu.get('bolum')) } : {}),
              ...(sorgu.get('cihaz') ? { cihazId: Number(sorgu.get('cihaz')) } : {}),
            }
          // GOZ MUAYENESI KISAYOLLARI (691): recete / goruntuleme / islem
          //   karti muayeneden acildiysa hasta ve muayene bagi ON DOLGU
          //   gelir - hekim ayni bilgiyi ikinci kez secmesin, bag da
          //   unutulmasin. Parametre yoksa kart normal bos acilir.
          : GOZ_KISAYOL_KAYNAKLARI.has(tanim.kaynak) && sorgu.get('hastaId')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              hastaId: Number(sorgu.get('hastaId')),
              ...(sorgu.get('muayeneId')
                  ? { muayeneId: Number(sorgu.get('muayeneId')) } : {}),
            }
          // DIS LAB IS EMRI (708, kullanici: "seansta lab is emri basilinca o
          //   hasta adina acilsin"): seans kartindan hasta, hekim, plan satiri
          //   ve dis on dolgu gelir; kaydet/kapat `geri` ile seansa doner.
          : tanim.kaynak === 'dis-lab-isemri' && sorgu.get('hastaId')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              hastaId: Number(sorgu.get('hastaId')),
              ...(sorgu.get('hekimId') ? { hekimId: Number(sorgu.get('hekimId')) } : {}),
              ...(sorgu.get('planSatirId') ? { planSatirId: Number(sorgu.get('planSatirId')) } : {}),
              ...(sorgu.get('disNolar') ? { disNolar: sorgu.get('disNolar')! } : {}),
            }
          // DIS ODEME PLANI (kullanici: odontogramdaki dugme yoksa yeni plan acsin):
          //   plan ve toplam on dolu; kaydet/kapat `geri` ile odontograma doner.
          // HASTA KAYITLARI (alerji / kronik / ilac / gecmis): odontogram ya da baska
          //   ekrandan hasta on dolu acilir; kaydet/kapat `geri` ile doner.
          // CALISMA PLANI (711): plandan acilan istisna/sablon karti hekim on dolu.
          // ISG (741): olay / ziyaret firma ve calisan on dolu (calisan karti, pano).
          : tanim.kaynak.startsWith('isg-') && (sorgu.get('firmaId') || sorgu.get('calisanId'))
          ? { ...tanim.yeniKayitVarsayilanlari, ...(sorgu.get('firmaId') ? { firmaId: Number(sorgu.get('firmaId')) } : {}), ...(sorgu.get('calisanId') ? { calisanId: Number(sorgu.get('calisanId')) } : {}) }
          : tanim.kaynak.startsWith('calisma-') && sorgu.get('hekimId')
          ? { ...tanim.yeniKayitVarsayilanlari, hekimId: Number(sorgu.get('hekimId')) }
          : HASTA_KAYIT_KAYNAKLARI.has(tanim.kaynak) && sorgu.get('hastaId')
          ? { ...tanim.yeniKayitVarsayilanlari, hastaId: Number(sorgu.get('hastaId')), ...(sorgu.get('programId') ? { programId: Number(sorgu.get('programId')) } : {}) }
          : tanim.kaynak === 'dis-odeme-plani' && sorgu.get('planId')
          ? {
              ...tanim.yeniKayitVarsayilanlari,
              planId: Number(sorgu.get('planId')),
              ...(sorgu.get('toplam') ? { toplam: Number(sorgu.get('toplam')) } : {}),
            }
          : tanim.yeniKayitVarsayilanlari}
        // `geri`: kart baska bir ekrandan (seans) acildiysa kaydet/kapat oraya
        //   doner - liste ekranina dusurmek hekimi seansi yeniden aramaya zorlardi.
        yeniSecilenAdlar={sorgu.get('hastaAd') ? { hastaId: sorgu.get('hastaAd')! } : undefined}
        onBasvuruAc={onBasvuruAc}
        onKapat={() => git(sorgu.get('geri') ?? tanim.kartYolu!)}
        // Hasta: kimlik no kayıtlıysa yeni kart yerine MEVCUT kart açılır (geri yolu korunur).
        onMevcutKayit={mevcutId => { setYenile(t => t + 1); git(`${tanim.kartYolu}/${mevcutId}${sorgu.get('geri') ? `?geri=${encodeURIComponent(sorgu.get('geri')!)}` : ''}`, { replace: true }) }}
        onKaydedildi={yeniId => {
          setYenile(t => t + 1);
          // `geri` varsa (seanstan lab is emri) yeni kartta kalmaz, onKapat
          //   geldigi ekrana doner; kart yoluna ara gecis gereksiz gecmis birakirdi.
          // FTR programi (719): yeni kayit ozel karta (uygulama ekle / planla) gecer.
          // ISG (741): yeni calisan kaydedince ozel karta (muayene ac / form gonder).
          if (kartId === 'yeni' && tanim.kaynak === 'isg-calisan') { git(`/isg-calisan/${yeniId}?geri=${encodeURIComponent(sorgu.get('geri') ?? '/isg-calisan')}`, { replace: true }); return }
          if (kartId === 'yeni' && tanim.kaynak === 'ftr-program') { git(`/ftr-program/${yeniId}?geri=${encodeURIComponent(sorgu.get('geri') ?? '/ftr-program')}`, { replace: true }); return }
          if (kartId === 'yeni' && !sorgu.get('geri')) {
            setOdaklaSonEklenen(t => t + 1);
            git(`${tanim.kartYolu}/${yeniId}`, { replace: true });
          }
        }}
      />
    </>
  );
}
