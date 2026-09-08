import { GenDetayTablo, bosDetay, type DetayDurumu } from '../GenDetayTablo';
import { c } from '../../dil/ceviri';
import { DokumanGalerisi } from '../DokumanGalerisi';
import { IlgiliKisiler } from '../IlgiliKisiler';
import { TekAdres } from '../TekAdres';
import { TekKayit } from '../TekKayit';
import { PersonelKimlikOzet } from '../PersonelKimlikOzet';
import { KartResimKutusu } from '../KartResimKutusu';
import { RolKullanicilari } from '../RolKullanicilari';
import { TEK_SUTUN_KARTLAR } from '../kartSekmeleri';
import { VARSAYILAN_ULKE } from '../yerlerHook';
import type { KartAlanMeta, KartMetaYaniti } from '../../api/sozlesme';
import type { Deger } from '../kartAlanCizim';

/**
 * KART "GRUP" SEKMESI - katalogdaki alan gruplarinin (Genel, İletişim, Notlar...)
 * mockup duzenine gore cizimi.
 *
 * Kaynaga ozel yerlesimlerin tamami burada: cari/aday iletisim kutusuna gomulu
 * adres, kisi kartinin ust satiri, personel/hasta kimlik ozeti ve gomulu
 * gridler, ilgili kisiler. GenForm bu 350 satirdan arindirilinca geriye veri
 * akisi (yukleme, kaydetme, sekme secimi) kaldi.
 */
/**
 * NOTLAR KUTUSU TAM GENISLIK (484, kullanici: "kurum karti notlar saga dogru
 * genislesin"). Sol sutunda İletişim'in altinda yarim genislikte durunca not
 * alani iki-uc kelimede satir kiriyordu - serbest metin en genis kutuyu
 * hak eder. Cari'de zaten boyleydi; kurum da ayni yerlesimi kullanir.
 */
const NOTLAR_TAM_GENISLIK = new Set(['cari', 'kurum']);

export function KartGrupSekmesi(p: KartGrupSekmesiProps) {
  const {
    aktif, kaynak, id, yeniMi, meta, salt, personelGibiKart, deger, setDeger,
    detaylar, setDetaylar, alanHatalari, gizliSekmeler, resimYerTutucu, gruplar, altGruplaVar, renderAlanListesi,
    aramaAc, secilenAdlar,
  } = p;
const gruplanmis = altGruplaVar(aktif.alanlar);
const adli = gruplanmis.filter(([b]) => b);
// musteri/tedarikci toolbar'da (kaydet/sil yaninda) checkbox olarak zaten var,
// ad/soyad kart'ta hic gosterilmiyor - burada tekrarlanmasin (cari'ya ozel). "kisi"
// check'i de KALDIRILDI (kullanici) - artik ayri "Kişi Kartı" + "İlgili Kişiler"
// akisi var, cari uzerinde dogrudan kisi bayragi degistirmek gereksiz/kafa karistirici.
const gizli = kaynak === 'cari' ? new Set(['ad', 'soyad', 'musteri', 'tedarikci', 'kisi'])
  : kaynak === 'kisi' ? new Set(['kisi'])
  // Personel: "unvan" ad+soyad'dan Kaydet'te turetiliyor, ayrica gosterilmez/
  //   duzenlenmez (kullanici: "ad soyad kullan"); "personel" bayragi Kisi'nin
  //   "kisi" bayragiyla ayni sebeple gizli. "vkno"/"gorev" de gizli - normal
  //   adsiz akistan CIKARILIP PersonelKimlikOzet.tsx'e props olarak geciyor
  //   (ik_karti.html: TCKN "Kimlik Bilgileri" kutusunda, Görev "Özet" kutusunda).
  //   "randevuVerilebilir" de gizli: baslik seridinde degil, İş Bilgileri
  //   kutusunda cizilir (252, kullanici) - PersonelKimlikOzet'e prop olarak gider.
  : kaynak === 'personel'
    ? new Set(['personel', 'unvan', 'vkno', 'gorevId', 'subeId', 'randevuVerilebilir'])
  // "randevuVerilebilir" HASTADA ANLAMSIZ (kullanici): randevu VEREN taraf
  //   personeldir, hasta randevu alir - kutu yanlislikla isaretlenirse hasta
  //   hekim listelerine dusebilirdi.
  //   "subeId" / "eklemeTarihi" de HASTADA gizli (kullanici): ikisi de
  //   salt-okunur sistem bilgisi, kayit kabul memurunun ilgilenmedigi iki
  //   satiri kartin en altinda tutuyorlardi. Kaydedilen degerler DEGISMIYOR -
  //   yalnizca cizilmiyorlar; sube kayit sirasinda oturumdan geliyor.
  : kaynak === 'hasta'
    ? new Set(['hasta', 'grup', 'unvan', 'gorevId', 'randevuVerilebilir',
               'subeId', 'eklemeTarihi'])
  // Sube: baz sube combosu Depolar dalinda ELLE cizilir (tek satir etiket).
  : kaynak === 'sube' ? new Set(['depoBazSubeId'])
  : new Set<string>();
const adsiz = (gruplanmis.find(([b]) => !b)?.[1] ?? []).filter(a => !gizli.has(a.ad));
// Cari'ya ozel: Iletisim + Notlar ayni (sol) sutunda ust-alt, Tanımlama sagda.
const iletisim = adli.find(([b]) => b === 'İletişim');
const notlar = adli.find(([b]) => b === 'Notlar');
const digerAdli = adli.filter(([b]) => b !== 'İletişim' && b !== 'Notlar');
const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
const acilDetay = meta.detaylar.find(d => d.ad === 'acilKisiler');
const iletisimAlanAdlari = new Set(['telefon', 'cepTel', 'eposta', 'epostaWeb']);
const personelIletisimSekmesi = personelGibiKart
  && (iletisim !== undefined || aktif.alanlar.some(a => iletisimAlanAdlari.has(a.ad)));
if (personelIletisimSekmesi) {
  const iletisimAlanlari = iletisim?.[1] ?? aktif.alanlar.filter(a => !gizli.has(a.ad));
  return (
    <div className={'personel-iletisim-yerlesim'
                    + (kaynak === 'dis-hekim' ? ' esit-ikili' : '')}>
      <div className="kasira">
        <div className="kagrup">
          <h6>İletişim</h6>
          <div className="alan-izgara tek-sutun">{renderAlanListesi(iletisimAlanlari)}</div>
        </div>
        {/* DIS HEKIMDE (305, kullanici) iletisimin yanindaki kutu ADRES DEGIL
            HEKIM BILGISI: brans/kurum/tescil kartin asil bilgisidir, adres
            ikincil. Adres ALTTA GRID olarak - bir hekimin muayenehanesi ve
            calistigi hastane(ler) ayri satirlardir, tek adres yetmez. */}
        {kaynak === 'dis-hekim' ? (() => {
          const hekimDetay = meta.detaylar.find(d => d.ad === 'hekim');
          return hekimDetay ? (
            /* Sarmalayici sinif: TekKayit kendi .kasira/.kagrup yapisini
               uretiyor, dis seciciyle icindeki alanlara ulasilamiyordu. */
            <div className="hekim-bilgi-kutu">
            <TekKayit
              meta={hekimDetay}
              durum={detaylar[hekimDetay.ad] ?? bosDetay()}
              saltOkunur={salt || hekimDetay.saltOkunur}
              onDegis={yeni => setDetaylar(t => ({ ...t, [hekimDetay.ad]: yeni }))}
              baslik="Hekim Bilgisi"
              aramaAc={aramaAc}
              secilenAdlar={secilenAdlar}
              /* KURUM kartin kendi alani (taraf.bag_id, 309) - detayda degil,
                 ama kutunun icinde durmali: sekme olarak gizlenen "Hekim
                 Bilgisi" grubunun alanlari buraya cizilir. */
              ekAlanlar={renderAlanListesi(
                gruplar.find(([ad]) => ad === 'Hekim Bilgisi')?.[1] ?? [])}
              ekAlanlarSira={1}
            />
            </div>
          ) : null;
        })() : adresDetay && (
          <TekAdres
            meta={adresDetay}
            durum={detaylar[adresDetay.ad] ?? bosDetay()}
            saltOkunur={salt || adresDetay.saltOkunur}
            onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
            baslik="Ev Adresi"
            turGizli
            sabitTur="1"
          />
        )}
      </div>

      {/* Adres GRIDI (dis hekim): muayenehane / hastane satirlari. */}
      {kaynak === 'dis-hekim' && adresDetay && (
        // 'kasira' DEGIL: ust satirdaki iki kutu icin grid kurdugumuzdan ayni
        //   sinif adres gridini de yarim sutuna sikistiriyordu.
        <div className="hekim-adres-blok">
          <GenDetayTablo
            meta={adresDetay}
            durum={detaylar[adresDetay.ad] ?? bosDetay()}
            saltOkunur={salt || adresDetay.saltOkunur}
            hatalar={alanHatalari}
            onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
          />
        </div>
      )}
      {acilDetay && (
        <GenDetayTablo
          meta={acilDetay}
          durum={detaylar[acilDetay.ad] ?? bosDetay()}
          saltOkunur={salt || acilDetay.saltOkunur}
          hatalar={alanHatalari}
          onDegis={yeni => setDetaylar(t => ({ ...t, [acilDetay.ad]: yeni }))}
        />
      )}
    </div>
  );
}
const adliBlok = (
  <>
    {/* Mockup: Tanım/Sınıflandırma · Vergi & Ana Birim ... AYNI SATIRDA yan yana (.row > .col > .grp).
        Personel'de bu sarmalayici, AltGrup'lu (adli) alan olmasa BILE acik kalmali -
        PersonelKimlikOzet/TekAdres gibi ozel bilesenler AltGrup'a bagli DEGIL, asagida
        bu blogun icinde render ediliyor (bug: "genel sekmesinde sadece 2 alan var" -
        adli.length===0 oldugu icin butun kasira hic acilmiyordu). */}
    {(adli.length > 0 || personelGibiKart) && (
      <div className="kasira">
        {iletisim && (
          <div className="kasutun">
            <div className="kagrup">
              <h6>{iletisim[0]}</h6>
              <div className="alan-izgara tek-sutun">{renderAlanListesi(iletisim[1])}</div>
              {/* ADRES ayri kutu DEGIL (Aday karti): iletisim bilgisinin
                  devami - adres, altinda İl ve saginda İlçe. Ayri bir
                  "Adres" kutusu iki kisa alan icin fazladan bir kat
                  gorsel gurultuydu. */}
              {kaynak === 'cari' && gizliSekmeler?.includes('Adres / Fatura Bilgisi') && (() => {
                const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
                if (!adresDetay) return null;
                return (
                  <TekAdres
                    meta={adresDetay}
                    durum={detaylar[adresDetay.ad] ?? bosDetay()}
                    saltOkunur={salt || adresDetay.saltOkunur}
                    onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                    grupYok
                    baslikGizli
                    ilIlceAyniSatir
                    turGizli
                    sabitTur="1"
                    // Ulke sorulmaz (kullanici): aday yurt ici, varsayilan
                    //   yeterli. Musteri kartinda alan DURUYOR - ihracat
                    //   carisinde ulke gerekir.
                    ulkeGizli
                  />
                );
              })()}
            </div>
            {notlar && !NOTLAR_TAM_GENISLIK.has(kaynak) && (
              <div className="kagrup">
                <h6>{notlar[0]}</h6>
                <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
              </div>
            )}
          </div>
        )}
        {/* MALİ SEKMESİ (192): sube "merkezin mali ayarlarini kullan" derse
            kendi alanlari ETKISIZDIR - girilen deger fn_sube_mali tarafindan
            zaten merkezinkiyle degistirilir. Alanlari cizip kullanicinin bos
            yere doldurmasina izin vermek yerine sebebi yazilir. */}
        {/* Merkezin kendisi miras alamaz - kendi ayarini duzenlemeli. */}
        {kaynak === 'sube' && aktif.baslik === 'Mali'
         && deger.merkezMaliKullan && deger.ustSubeId ? (
          <div className="kagrup">
            <h6>Mali Ayarlar</h6>
            <div className="not" style={{ padding: 10 }}>
              Bu şube <b>merkezin mali ayarlarını</b> kullanıyor: dönem, muhasebe
              entegrasyonu, amortisman ve vergi/yuvarlama ayarları merkezden okunur.
              Şubeye özel ayar girmek için yukarıdaki kutunun işaretini kaldırın.
              <div style={{ marginTop: 6, opacity: .75 }}>
                Defter türü, KDV / geçici vergi dönemi, para birimi, ondalık ve
                yuvarlama adımı <b>her zaman merkezden</b> gelir — iki şube farklı
                yuvarlamayla çalışırsa mizan tutmaz.
              </div>
            </div>
          </div>
        ) : null}
        {digerAdli
          .filter(([altBaslik]) => !(kaynak === 'sube' && aktif.baslik === 'Mali'
                                     && deger.merkezMaliKullan && deger.ustSubeId
                                     && altBaslik !== 'Ayar Kaynağı'))
          .map(([altBaslik, alanlar]) => {
          // Cari'ye ozel: Tanımlama kutusunda dort cift AYNI SATIRDA yan yana,
          // sirayla (kullanici): Kategori/İlk Temas, Sektör/Alt Sektör, Sınıf/Bölge,
          // Temsilci/Özel Kod.
          const ciftler = kaynak === 'cari' && altBaslik === 'Tanımlama'
            ? [['kategori', 'ilkTemas'], ['sektor', 'altSektor'], ['sinif', 'bolge'], ['temsilci', 'ozelKod']]
            : [];
          const ciftliAlanlar = ciftler.map(cift =>
            cift.map(ad => alanlar.find(a => a.ad === ad)).filter(a => a !== undefined));
          const digerAlanlar = alanlar.filter(a => !ciftliAlanlar.flat().includes(a));
          const hastaVergiNoAlan = kaynak === 'hasta' && aktif.baslik === 'Adres / Fatura Bilgisi' && altBaslik === 'Fatura / Vergi Kimligi'
            ? meta.alanlar.find(a => a.ad === 'vkno')
            : undefined;
          // KURUM TURU seridin bir hucresi (484): Tanımlama kutusuna DEGIL
          //   kimlik seridine cizilir - kullanici temsilci ile yer degistirdi.
          return (
            <div className="kagrup" key={altBaslik}>
              <h6>{c(altBaslik)}</h6>
              <div className="alan-izgara tek-sutun">
                {ciftliAlanlar.map((cift, i) => cift.length > 0 && (
                  <div className="adres-satir" key={i}>{renderAlanListesi(cift)}</div>
                ))}
                {renderAlanListesi(digerAlanlar)}
                {hastaVergiNoAlan && (
                  <label className="alan tip-metin">
                    <span className="etiket">Vergi No{hastaVergiNoAlan.zorunlu && <b className="zorunlu"> *</b>}</span>
                    <input
                      value={String(deger.vkno ?? '')}
                      maxLength={hastaVergiNoAlan.enFazlaUzunluk ?? undefined}
                      disabled={salt}
                      onChange={e => setDeger(d => ({ ...d, vkno: e.target.value }))}
                    />
                    {alanHatalari.vkno && <span className="alan-hata">{alanHatalari.vkno}</span>}
                  </label>
                )}
              </div>
            </div>
          );
        })}
        {/* Kisi'ye ozel: kisi_karti.html'deki "Adres" kutusu - GRID DEGIL, TEK adres
            (kullanici: "grid olmasin tek adres"). Iletisim kutusuyla AYNI satirda
            (kasira icinde) - genislik esitlensin diye (kullanici: "iletisim kutusu
            kadar olsun"). Ayni taraf_adres tablosu, sadece tek satir gosterilir. */}
        {kaynak === 'kisi' && aktif.baslik === 'Genel' && (() => {
          const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
          if (!adresDetay) return null;
          return (
            <>
              <TekAdres
                meta={adresDetay}
                durum={detaylar[adresDetay.ad] ?? bosDetay()}
                saltOkunur={salt || adresDetay.saltOkunur}
                onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
              />
              <KartResimKutusu
                kartAdi="kisi"
                kaynakId={yeniMi ? undefined : (id as number)}
                saltOkunur={salt}
              />
            </>
          );
        })()}
        {/* Personel'e ozel: ik_karti.html mockup'ta Genel sekmesinde "Kimlik
            Bilgileri" (TCKN + Ozluk'ten dogum/cinsiyet/vb) + "Özet" (Pozisyon +
            İşe Giriş) kutulari - iki farkli veri kaynagini (taraf + personel_ozluk)
            BIRLESTIRDIGI icin ozel bilesen (PersonelKimlikOzet.tsx). */}
        {personelGibiKart && aktif.baslik === 'Genel' && (() => {
          const ozlukDetay = meta.detaylar.find(d => d.ad === 'ozluk');
          const egitimDetay = meta.detaylar.find(d => d.ad === 'egitimler');
          const vknoAlan = meta.alanlar.find(a => a.ad === 'vkno');
          const gorevAlan = meta.alanlar.find(a => a.ad === 'gorevId');
          if (!ozlukDetay || !vknoAlan || !gorevAlan) return null;
          const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
          // ILETISIM SUTUNU %20 GENIS (kullanici: "telefon, eposta, adres %20
          //   büyüsün"). Uc sutunun ikisi SABIT genislikte, iletisim ise tek
          //   ESNEK sutun - artan yer zaten hep ona gidiyor, tek buyutme yolu
          //   sabitlerden yer almak: kimlik 420->380, fotograf 210->180
          //   (toplam 70px; ~1000px kartta iletisim 350->420 = %20).
          const hastaIletisimAlanlari = kaynak === 'hasta'
            ? (gruplar.find(([ad]) => ad === 'İletişim')?.[1] ?? [])
            : [];
          return (
            <PersonelKimlikOzet
              subeAlan={meta.alanlar.find(a => a.ad === 'subeId')}
              sube={String(deger.subeId ?? '')}
              onSubeDegis={v => setDeger(d => ({ ...d, subeId: v }))}
              kartAdi={kaynak}
              vknoAlan={vknoAlan}
              vkno={String(deger.vkno ?? '')}
              onVknoDegis={v => setDeger(d => ({ ...d, vkno: v }))}
              gorevAlan={gorevAlan}
              gorev={String(deger.gorevId ?? '')}
              onGorevDegis={v => setDeger(d => ({ ...d, gorevId: v }))}
              ozlukMeta={ozlukDetay}
              ozlukDurum={detaylar[ozlukDetay.ad] ?? bosDetay()}
              saltOkunur={salt}
              onOzlukDegis={yeni => setDetaylar(t => ({ ...t, [ozlukDetay.ad]: yeni }))}
              kaynakId={yeniMi ? undefined : (id as number)}
              isBilgiEk={(() => {
                // RANDEVU VERILEBILIR (252): hekim mi - is bilgisi oldugu icin
                //   İş Bilgileri kutusunda (kullanici), kimlik seridinde degil.
                const a = meta.alanlar.find(x => x.ad === 'randevuVerilebilir');
                if (!a || kaynak !== 'personel') return undefined;
                // Etiket kutunun SAGINDA, tek satir (kullanici) - diger
                //   alanlardaki "etiket solda, deger sagda" duzeni burada
                //   etiketi iki satira sarip kutuyu tek basina birakiyordu.
                return (
                  <label className="alan onay-satiri">
                    <input type="checkbox" disabled={salt}
                           checked={Number(deger.randevuVerilebilir ?? 0) === 1}
                           onChange={e => setDeger(d => ({
                             ...d, randevuVerilebilir: e.target.checked ? 1 : 0,
                           }))} />
                    <span>{a.baslik}</span>
                  </label>
                );
              })()}
              ozetGizli={kaynak === 'hasta'}
              vknoGizli={kaynak === 'hasta'}
              kimlikSutunGenisligi={kaynak === 'hasta' ? '380px' : undefined}
              fotoSolEkOnce={kaynak === 'hasta'}
              fotoSolEk={hastaIletisimAlanlari.length > 0 && (
                <div className="kasutun" style={{ flex: '1 1 330px' }}>
                  <div className="kagrup">
                    <h6>İletişim</h6>
                    {/* HASTADA ALANLAR YAN YANA (kullanici: "telefondakinde
                        daha fazla yükseklik var, çerçeve boyları aynı değil"):
                        tek sutunda iki alan alt alta dizilince kutu yanindaki
                        Kimlik Bilgileri'nden uzun kaliyordu. */}
                    <div className="alan-izgara">{renderAlanListesi(hastaIletisimAlanlari)}</div>
                  {kaynak === 'hasta' && adresDetay && (
                    <TekAdres
                      meta={adresDetay}
                      durum={detaylar[adresDetay.ad] ?? bosDetay()}
                      saltOkunur={salt || adresDetay.saltOkunur}
                      onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
                      baslik="Ev Adresi"
                      turGizli
                      sabitTur="1"
                      grupYok
                      ilIlceAyniSatir
                      baslikGizli
                      uyruk={String((detaylar[ozlukDetay.ad]?.guncel[0] ?? {}).uyruk
                                    ?? VARSAYILAN_ULKE)}
                      onUyrukDegis={v => setDetaylar(t => {
                        const d = t[ozlukDetay.ad] ?? bosDetay();
                        const ilk = { ...(d.guncel[0] ?? {}), uyruk: v };
                        return { ...t, [ozlukDetay.ad]: { ...d, guncel: [ilk, ...d.guncel.slice(1)] } };
                      })}
                    />
                  )}
                  </div>
                </div>
              )}
              egitimler={kaynak !== 'hasta' && egitimDetay && (
                <GenDetayTablo
                  meta={egitimDetay}
                  durum={detaylar[egitimDetay.ad] ?? bosDetay()}
                  saltOkunur={salt || egitimDetay.saltOkunur}
                  hatalar={alanHatalari}
                  onDegis={yeni => setDetaylar(t => ({ ...t, [egitimDetay.ad]: yeni }))}
                />
              )}
            />
          );
        })()}
        {!iletisim && notlar && !NOTLAR_TAM_GENISLIK.has(kaynak) && (
          <div className="kagrup" key="Notlar">
            <h6>{notlar[0]}</h6>
            <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
          </div>
        )}
        {(resimYerTutucu || kaynak === 'cari') && aktif.baslik === 'Genel' && (
          <KartResimKutusu
            kartAdi={kaynak}
            kaynakId={yeniMi ? undefined : (id as number)}
            saltOkunur={salt}
          />
        )}
      </div>
    )}
    {/* YAKINLAR (kullanici: ayri sekme OLMASIN) - Iletisim / Kimlik /
        Fotograf satirinin ALTINDA ama .kasira SATIRININ DISINDA.

        .kasira BIR FLEX SATIRIDIR ve SARMAZ: bu kutu oranin icindeyken
        digerlerinin YANINA dorduncu sutun olarak diziliyor, genislik
        kalmayinca kartin gorunur alanindan tasiyordu - grid DOM'da vardi ama
        ekranda yoktu (kullanici uc kez "görünmüyor" dedi; DOM sirasina bakan
        test bunu GOREMEZ, cunku sira dogruydu). Satirin disinda oldugu icin
        artik kendi tam-genislikte satirinda. */}
      {kaynak === 'hasta' && aktif.baslik === 'Genel' && acilDetay && (
      // GenDetayTablo KENDI `.kagrup` kutusunu ve basligini cizer - ustune
      //   ikinci bir kutu koymak IC ICE IKI CERCEVE demekti (kullanici: "dış
      //   çerçeve duruyor" - benim kaldirdigim DIS kutuydu, ekranda gorunen
      //   gridin KENDI kutusu). Sarmalayici kaldirildi; baslik meta uzerinden.
      <GenDetayTablo
        key="Yakinlar"
        kutuSinif="yakinlar-kutusu"
        meta={{ ...acilDetay, baslik: 'Yakınlar / Acil Durumda Aranacak' }}
        durum={detaylar[acilDetay.ad] ?? bosDetay()}
        saltOkunur={salt || acilDetay.saltOkunur}
        hatalar={alanHatalari}
        onDegis={yeni => setDetaylar(t => ({ ...t, [acilDetay.ad]: yeni }))}
      />
      )}
  </>
);
// SubeId/EklemeTarihi (salt-okunur meta alanlar) EN ALTTA (kullanici: kisi kartinda
//   sonra cari kartinda da "şube id ve ekleme tarihi en alta gelsin") - Kisi'de Bagli
//   Cari/Rol/Durum'dan AYRI (o idstrip'in hemen altinda kaliyor); Cari'de zaten baska
//   adsiz alan kalmadi (kisi/ad/soyad/musteri/tedarikci gizli), direkt en alta duser.
const enAltAd = new Set(['subeId', 'eklemeTarihi']);
const adsizUst = adsiz.filter(a => !enAltAd.has(a.ad));
const adsizAlt = adsiz.filter(a => enAltAd.has(a.ad));
{/* Kisi'ye ozel: Rol/Durum saga yanasik, aradaki bosluk Bagli Cari editi buyuyerek
    doldurur (kullanici: "rol ve durum saga yanasik, aradaki bosluk bagli cari editi
    doldursun"). Alan sirasi katalogda Bagli Cari, Rol, Durum. */}
const adsizBlok = adsizUst.length > 0 && (
  // RANDEVU (mockup randevu_karti.html): iki sutun, etiketler alanlarin
  //   USTUNDE, Açıklama tam satir - kart mockup'la ayni duzende gorunsun.
  <div className={`alan-izgara${kaynak === 'kisi' ? ' kisi-ust-satir' : ''}` +
                  (kaynak === 'randevu' ? ' randevu-alanlar' : '') +
                  (TEK_SUTUN_KARTLAR.has(kaynak) ? ' tek-sutun ayar-formu' : '')}>
    {renderAlanListesi(adsizUst)}
  </div>
);
const adsizAltBlok = adsizAlt.length > 0 && <div className="alan-izgara">{renderAlanListesi(adsizAlt)}</div>;
/* ADAY HASTA (266): cinsiyet / dogum tarihi / kurum ayri sekme degil, Genel'in
   altinda tek ekranda - kayit kabul masasinda tek nefeste doldurulsun. */
const adayOzluk = kaynak === 'hasta-aday'
  ? meta.detaylar.find(d => d.ad === 'ozluk')
  : undefined;
/* KAMPANYA (268): indirim satirlari Genel sekmesinin altinda tam genislikte. */
const kampanyaSatirlari = kaynak === 'kampanya'
  ? meta.detaylar.find(d => d.ad === 'satirlar')
  : undefined;
// Cerceve/baslik YOK (kullanici): kartin tek isi bu satirlar - "İndirim
//   Satırları" basligi ve kutusu ekrani daraltiyordu.
const kampanyaSatirBlok = kampanyaSatirlari && (
  <div key="kampanya-satir" className="kampanya-satirlar">
    <GenDetayTablo
      meta={kampanyaSatirlari}
      durum={detaylar[kampanyaSatirlari.ad] ?? bosDetay()}
      saltOkunur={salt}
      hatalar={alanHatalari}
      onDegis={yeni => setDetaylar(t => ({ ...t, [kampanyaSatirlari.ad]: yeni }))}
    />
  </div>
);

const adayAdres = kaynak === 'hasta-aday'
  ? meta.detaylar.find(d => d.ad === 'adresler')
  : undefined;
const adayAdresBlok = adayAdres && (
  <TekKayit
    key="aday-adres"
    meta={adayAdres}
    durum={detaylar[adayAdres.ad] ?? bosDetay()}
    saltOkunur={salt}
    onDegis={yeni => setDetaylar(t => ({ ...t, [adayAdres.ad]: yeni }))}
  />
);
const adayOzlukBlok = adayOzluk && (
  <TekKayit
    key="aday-ozluk"
    meta={adayOzluk}
    durum={detaylar[adayOzluk.ad] ?? bosDetay()}
    saltOkunur={salt}
    onDegis={yeni => setDetaylar(t => ({ ...t, [adayOzluk.ad]: yeni }))}
  />
);
/* LOGO & KAŞE (193): gorseller USTTE, ayar kutulari altta (kullanici).
   Gorseller kolon degil dokuman; galeri yukleme/silme/onizlemeyi yapiyor.
   Merkezin gorselleri kullaniliyorsa yukleme yerine sebep yazilir. */
const logoKase = kaynak === 'sube' && aktif.baslik === 'Logo & Kaşe' ? (() => {
  const merkezMi = !deger.ustSubeId;
  if (yeniMi) {
    return (
      <div className="kagrup">
        <h6>Logo / Kaşe / İmza</h6>
        <div className="not" style={{ padding: 10 }}>
          Şube kaydedildikten sonra buradan logo, kaşe ve imza yüklenebilir.
        </div>
      </div>
    );
  }
  if (deger.merkezGorselKullan && !merkezMi) {
    return (
      <div className="kagrup">
        <h6>Logo / Kaşe / İmza</h6>
        <div className="not" style={{ padding: 10 }}>
          Bu şube <b>merkezin logo, kaşe ve imzasını</b> kullanıyor; belgelerde
          merkezin görselleri basılır. Şubeye özel görsel yüklemek için
          aşağıdaki kutunun işaretini kaldırın.
        </div>
      </div>
    );
  }
  return (
    <div className="kagrup">
      <h6>Logo / Kaşe / İmza</h6>
      <div style={{ padding: 10 }}>
        <div className="not" style={{ marginBottom: 8 }}>
          Yüklerken <b>türünü</b> seçin: <b>Logo</b> · <b>Kaşe</b> · <b>İmza</b> ·
          <b> Antet</b>. Belgede her türün <b>varsayılan</b> işaretlisi kullanılır.
          Önerilen logo: PNG, saydam zemin, en az 480×160 px.
        </div>
        <DokumanGalerisi kartAdi="sube" kaynakId={id as number} saltOkunur={salt} />
      </div>
    </div>
  );
})() : null;
return (
  <>
    {/* Kisi'ye ozel: Bagli Cari/Rol/Durum (adsiz) idstrip'in HEMEN ALTINDA, 2. sirada
        (kullanici: "onun altinda 2.sirada Bagli Cari/Rol/Durum olsun") - Iletisim/Adres
        kutularindan ONCE. Diger kaynaklar (Cari) eski sirada: kutular sonra adsiz. */}
    {kaynak === 'kisi' ? (
      <>
        {adsizBlok}
        {adliBlok}
      </>
    ) : logoKase ? (
      /* Logo & Kaşe: GALERI USTTE, ayar kutulari altinda (kullanici). */
      <>
        {logoKase}
        {adliBlok}
        {adsizBlok}
      </>
    ) : (
      <>
        {adliBlok}
        {adsizBlok}
      </>
    )}
    {/* Cari'ye ozel: mockup'ta Genel'in altinda "İlgili Kişiler" tablosu (ayri
        uclar - /api/kart/cari/{id}/kisiler, kartin diger alanlari gibi Kaydet'i
        beklemez). Yeni kayitta henuz id yok, kart once kaydedilmeli. */}
    {/* Fatura sekmesi gizli ekranlarda (Aday) ADRES ve KISILER YAN YANA
        (kullanici: "kişiler adres bölümünün sağına gelsin"); diger
        ekranlarda adres kendi sekmesinde, kisiler tek basina. */}
    {/* Adres artik İletişim kutusunun icinde (yukarida) - burada yalniz
        kisi gridi, tam genislikte. */}
    {/* Sube kartinda depolar, "Merkez deposunu da kullan" kutusuyla AYNI
        sekmede (kullanici): kutu "hangi depolari gorurum" sorusunun cevabi,
        listenin hemen ustunde durmasi gerekiyor. Yeni subede henuz id yok -
        once kaydedilmeli. */}
    {/* Rol kartinda kullanicilar Genel sekmesinde, alanlarin altinda
        (kullanici: "kullanicilari genel sekmesine al, kullanici sekmesini
        kaldir"). Yeni rolde henuz id yok - once kaydedilmeli. */}
    {kaynak === 'rol' && !yeniMi && aktif.baslik === 'Genel' && (
      /* Sube listesi ROLDE DEGIL (kullanici: "rolden kaldir tekrar") -
         personel kartinda, fotografin altinda. */
      <RolKullanicilari rolId={id as number} saltOkunur={salt} />
    )}

    {/* DIS HEKIM (305) - iki sekme generic akisin disinda:
        - "Hekim Bilgisi" 1:1 uzanti: satir ekle/sil'li grid degil TEK KAYIT
          formu (kullanici: "mockup gibi label ve edit olsun"). Ikinci satir
          zaten yazilamaz, grid yanlis bir vaat.
        - "Gönderim Geçmişi" BASKA BIR EKRANIN kayitlari (radyoloji istemleri):
          kart detayi degil, liste ekranlarindaki GenGrid - salt okunur. */}
    {kaynak === 'sube' && aktif.baslik === 'Depolar' && (() => {
      const depoDetay = meta.detaylar.find(d => d.ad === 'depolar');
      if (!depoDetay) return null;
      // Baz sube combosu ELLE (kullanici: etiket tek satir) - alan katalogda
      //   Gizli, generic akis cizmiyor.
      const bazAlan = meta.alanlar.find(a => a.ad === 'depoBazSubeId');
      const bazCombo = bazAlan ? (
        <div className="alan-izgara dort-sutun tek-satir-etiket"
             style={{ marginBottom: 8 }}>
          {renderAlanListesi([bazAlan])}
        </div>
      ) : null;
      // Merkez deposu kullaniliyorsa subenin KENDI depo listesi yok (174):
      //   grid cizilseydi "burada da depo tanimlayabilirim" izlenimi verirdi.
      if (Number(deger.depoBazSubeId) > 0) {
        return (
          <>
          {bazCombo}
          <div className="kagrup">
            <h6>Depolar</h6>
            <div className="not" style={{ padding: 10 }}>
              Bu şube <b>baz alınan şubenin depolarını</b> kullanıyor; kendi
              deposu tutulmaz. Kendi depolarını tanımlamak için yukarıdaki
              comboyu <b>Kendisi</b> yapın.
            </div>
          </div>
          </>
        );
      }
      if (yeniMi) {
        return (
          <>
          {bazCombo}
          <div className="kagrup">
            <h6>Depolar</h6>
            <div className="not" style={{ padding: 10 }}>
              Şube kaydedildikten sonra buradan depo eklenebilir.
            </div>
          </div>
          </>
        );
      }
      return (
        <>
        {bazCombo}
        {/* ~6 satirlik yukseklik, fazlasi dikey scroll (kullanici) - cok
            depolu subede sekme uzayip kartin altini itiyordu. */}
        <div style={{ maxHeight: 268, overflowY: 'auto' }}>
          <GenDetayTablo
            meta={depoDetay}
            durum={detaylar[depoDetay.ad] ?? bosDetay()}
            saltOkunur={salt || depoDetay.saltOkunur}
            hatalar={alanHatalari}
            onDegis={yeni => setDetaylar(t => ({ ...t, [depoDetay.ad]: yeni }))}
            ikonlu
            modalDuzenle
          />
        </div>
        </>
      );
    })()}
    {kaynak === 'cari' && aktif.baslik === 'Genel' && !yeniMi
      && gizliSekmeler?.includes('Adres / Fatura Bilgisi') && (
      <IlgiliKisiler tarafId={id as number} saltOkunur={salt} />
    )}
    {kaynak === 'cari' && aktif.baslik === 'Genel' && !yeniMi
      && !gizliSekmeler?.includes('Adres / Fatura Bilgisi') && (
      <IlgiliKisiler tarafId={id as number} saltOkunur={salt} />
    )}
    {/* YENI kartta kisi eklenemez (henuz taraf id'si yok) ama kutu
        GORUNUR: eskiden hic cizilmedigi icin kullanici "kisi gridi yok"
        saniyordu. Kaydedince ayni yerde gercek grid acilir. */}
    {kaynak === 'cari' && aktif.baslik === 'Genel' && yeniMi && (
      <div className="kasira">
        <div className="kagrup">
          <h6>İlgili Kişiler</h6>
          <div className="not" style={{ padding: 10 }}>
            Kişiler kart kaydedildikten sonra eklenir.
          </div>
        </div>
      </div>
    )}

    {/* ADRES: Fatura Bilgileri sekmesi bu ekranda GIZLIYSE (Aday karti)
        adres oradan gorunmez - Genel sekmesine, Notlar'in USTUNE tek
        adres olarak konur. Ayni taraf_adres tablosu, tek satir. */}
    {/* Kullanici: "notlar ilgili kişiler altına gelsin" - Cari'de Notlar kutusu
        artik İletişim'in yaninda degil, İlgili Kişiler tablosunun altinda. */}
    {NOTLAR_TAM_GENISLIK.has(kaynak) && aktif.baslik === 'Genel' && notlar && (
      <div className="kasira">
        <div className="kagrup" key="Notlar">
          <h6>{notlar[0]}</h6>
          <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
        </div>
      </div>
    )}
    {/* Cari'ye ozel: Adresler mockup'ta ayri sekme degil, Fatura Bilgileri'nin icine
        gomulu GRID (birden fazla adres - fatura/sevkiyat/vb). */}
    {(kaynak === 'cari' || kaynak === 'hasta') && aktif.baslik === 'Adres / Fatura Bilgisi' && (() => {
      const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
      if (!adresDetay) return null;
      return (
        <GenDetayTablo
          meta={adresDetay}
          durum={detaylar[adresDetay.ad] ?? bosDetay()}
          saltOkunur={salt || adresDetay.saltOkunur}
          hatalar={alanHatalari}
          onDegis={yeni => setDetaylar(t => ({ ...t, [adresDetay.ad]: yeni }))}
        />
      );
    })()}
    {/* SubeId/EklemeTarihi GERCEKTEN EN ALTTA - Kisi/Ilgili Kisiler/Adresler
        kutularindan da SONRA (kullanici iki kez duzeltti: onceki yer "ortada"
        kaliyordu, İlgili Kişiler grid'inden ONCE geliyordu). */}
    {adsizAltBlok}
    {adayOzlukBlok}
    {adayAdresBlok}
    {kampanyaSatirBlok}
  </>
);
}

export interface KartGrupSekmesiProps {
  /** Aktif GRUP sekmesi: baslik + o gruba dusen alanlar. */
  aktif: { baslik: string; alanlar: KartAlanMeta[] };
  kaynak: string;
  id: number | 'yeni';
  yeniMi: boolean;
  meta: KartMetaYaniti;
  salt: boolean;
  personelGibiKart: boolean;
  deger: Record<string, Deger>;
  setDeger: React.Dispatch<React.SetStateAction<Record<string, Deger>>>;
  detaylar: Record<string, DetayDurumu>;
  setDetaylar: React.Dispatch<React.SetStateAction<Record<string, DetayDurumu>>>;
  alanHatalari: Record<string, string>;
  /** Ekrana ozel gizlenen sekmeler - aday kartinda adres kutusunun yerini belirler. */
  gizliSekmeler?: string[];
  /** Resim kutusu yerine yer tutucu (yeni kayitta id yok). */
  resimYerTutucu?: boolean;
  /** Alan gruplari (Kimlik dahil) - kimlik seridi disinda kalanlar cizilir. */
  gruplar: [string, KartAlanMeta[]][];
  /** Alan cizim yardimcilari (kartAlanCizim fabrikasindan). */
  altGruplaVar(alanlar: KartAlanMeta[]): [string, KartAlanMeta[]][];
  renderAlanListesi(alanlar: KartAlanMeta[]): React.ReactNode;
  /** Jenerik arama modalini acar (305): 1:1 uzanti formundaki kurum secimi. */
  aramaAc?(alan: string, kaynak: string, uygula?: (deger: string) => void): void;
  secilenAdlar?: Record<string, string>;
}
