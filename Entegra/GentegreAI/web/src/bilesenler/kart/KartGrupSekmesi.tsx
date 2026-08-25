import { GenDetayTablo, bosDetay, type DetayDurumu } from '../GenDetayTablo';
import { IlgiliKisiler } from '../IlgiliKisiler';
import { TekAdres } from '../TekAdres';
import { PersonelKimlikOzet } from '../PersonelKimlikOzet';
import { KartResimKutusu } from '../KartResimKutusu';
import { TEK_SUTUN_KARTLAR } from '../kartSekmeleri';
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
export function KartGrupSekmesi(p: KartGrupSekmesiProps) {
  const {
    aktif, kaynak, id, yeniMi, meta, salt, personelGibiKart, deger, setDeger,
    detaylar, setDetaylar, alanHatalari, gizliSekmeler, resimYerTutucu, gruplar, altGruplaVar, renderAlanListesi,
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
  : kaynak === 'personel' ? new Set(['personel', 'unvan', 'vkno', 'gorev'])
  : kaynak === 'hasta' ? new Set(['hasta', 'grup', 'unvan', 'gorev'])
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
    <div className="personel-iletisim-yerlesim">
      <div className="kasira">
        <div className="kagrup">
          <h6>İletişim</h6>
          <div className="alan-izgara tek-sutun">{renderAlanListesi(iletisimAlanlari)}</div>
        </div>
        {adresDetay && (
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
              {kaynak === 'cari' && gizliSekmeler?.includes('Fatura Bilgileri') && (() => {
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
            {notlar && kaynak !== 'cari' && (
              <div className="kagrup">
                <h6>{notlar[0]}</h6>
                <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
              </div>
            )}
          </div>
        )}
        {digerAdli.map(([altBaslik, alanlar]) => {
          // Cari'ye ozel: Tanımlama kutusunda dort cift AYNI SATIRDA yan yana,
          // sirayla (kullanici): Kategori/İlk Temas, Sektör/Alt Sektör, Sınıf/Bölge,
          // Temsilci/Özel Kod.
          const ciftler = kaynak === 'cari' && altBaslik === 'Tanımlama'
            ? [['kategori', 'ilkTemas'], ['sektor', 'altSektor'], ['sinif', 'bolge'], ['temsilci', 'ozelKod']]
            : [];
          const ciftliAlanlar = ciftler.map(cift =>
            cift.map(ad => alanlar.find(a => a.ad === ad)).filter(a => a !== undefined));
          const digerAlanlar = alanlar.filter(a => !ciftliAlanlar.flat().includes(a));
          const hastaVergiNoAlan = kaynak === 'hasta' && aktif.baslik === 'Fatura Bilgileri' && altBaslik === 'Fatura / Vergi Kimligi'
            ? meta.alanlar.find(a => a.ad === 'vkno')
            : undefined;
          return (
            <div className="kagrup" key={altBaslik}>
              <h6>{altBaslik}</h6>
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
          const gorevAlan = meta.alanlar.find(a => a.ad === 'gorev');
          if (!ozlukDetay || !vknoAlan || !gorevAlan) return null;
          const adresDetay = meta.detaylar.find(d => d.ad === 'adresler');
          const hastaIletisimAlanlari = kaynak === 'hasta'
            ? (gruplar.find(([ad]) => ad === 'İletişim')?.[1] ?? [])
            : [];
          return (
            <PersonelKimlikOzet
              kartAdi={kaynak}
              vknoAlan={vknoAlan}
              vkno={String(deger.vkno ?? '')}
              onVknoDegis={v => setDeger(d => ({ ...d, vkno: v }))}
              gorevAlan={gorevAlan}
              gorev={String(deger.gorev ?? '')}
              onGorevDegis={v => setDeger(d => ({ ...d, gorev: v }))}
              ozlukMeta={ozlukDetay}
              ozlukDurum={detaylar[ozlukDetay.ad] ?? bosDetay()}
              saltOkunur={salt}
              onOzlukDegis={yeni => setDetaylar(t => ({ ...t, [ozlukDetay.ad]: yeni }))}
              kaynakId={yeniMi ? undefined : (id as number)}
              ozetGizli={kaynak === 'hasta'}
              vknoGizli={kaynak === 'hasta'}
              kimlikSutunGenisligi={kaynak === 'hasta' ? '420px' : undefined}
              fotoSolEkOnce={kaynak === 'hasta'}
              fotoSolEk={hastaIletisimAlanlari.length > 0 && (
                <div className="kasutun" style={{ flex: '1 1 260px' }}>
                  <div className="kagrup">
                    <h6>İletişim</h6>
                    <div className="alan-izgara tek-sutun">{renderAlanListesi(hastaIletisimAlanlari)}</div>
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
        {!iletisim && notlar && kaynak !== 'cari' && (
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
  <div className={`alan-izgara${kaynak === 'kisi' ? ' kisi-ust-satir' : ''}` +
                  (TEK_SUTUN_KARTLAR.has(kaynak) ? ' tek-sutun ayar-formu' : '')}>
    {renderAlanListesi(adsizUst)}
  </div>
);
const adsizAltBlok = adsizAlt.length > 0 && <div className="alan-izgara">{renderAlanListesi(adsizAlt)}</div>;
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
    {kaynak === 'cari' && aktif.baslik === 'Genel' && !yeniMi
      && gizliSekmeler?.includes('Fatura Bilgileri') && (
      <IlgiliKisiler tarafId={id as number} saltOkunur={salt} />
    )}
    {kaynak === 'cari' && aktif.baslik === 'Genel' && !yeniMi
      && !gizliSekmeler?.includes('Fatura Bilgileri') && (
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
    {kaynak === 'cari' && aktif.baslik === 'Genel' && notlar && (
      <div className="kasira">
        <div className="kagrup" key="Notlar">
          <h6>{notlar[0]}</h6>
          <div className="alan-izgara tek-sutun">{renderAlanListesi(notlar[1])}</div>
        </div>
      </div>
    )}
    {/* Cari'ye ozel: Adresler mockup'ta ayri sekme degil, Fatura Bilgileri'nin icine
        gomulu GRID (birden fazla adres - fatura/sevkiyat/vb). */}
    {(kaynak === 'cari' || kaynak === 'hasta') && aktif.baslik === 'Fatura Bilgileri' && (() => {
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
}
