import { BrowserRouter, Navigate, Route, Routes, useLocation } from 'react-router-dom';
import { modulAcikMi } from './sayfalar/listeTanimlari';
import { modUyar } from './api/sozlesme';
import { OturumSaglayici, useOturum } from './kimlik/OturumBaglami';
import { Giris } from './sayfalar/Giris';
import { Kabuk } from './sayfalar/Kabuk';
import { PortalKabuk } from './sayfalar/portal/PortalKabuk';
import { PortalDavet } from './sayfalar/portal/PortalDavet';
import { BelgeKarti } from './sayfalar/BelgeKarti';
import { KasaIslemKarti } from './sayfalar/KasaIslemKarti';
import { Liste, LISTELER } from './sayfalar/Liste';
import { StokAyarlar } from './sayfalar/StokAyarlar';
import { KasaAyarlar } from './sayfalar/KasaAyarlar';
import { IceriAlma } from './sayfalar/IceriAlma';
import { RandevuAyarlar } from './sayfalar/RandevuAyarlar';
import { CalismaPlani } from './sayfalar/CalismaPlani';
import { AmeliyatCizelge } from './sayfalar/AmeliyatCizelge';
import { KayitKabulAyarlar } from './sayfalar/KayitKabulAyarlar';
import { KatalogAyarlar } from './sayfalar/KatalogAyarlar';
import { DepartmanGorev } from './sayfalar/DepartmanGorev';
import { FirmaBilgileri } from './sayfalar/FirmaBilgileri';
import { KurumProfili } from './sayfalar/KurumProfili';
import { MesajKatmani } from './bilesenler/MesajKatmani';
import { GenelAyarlar } from './sayfalar/GenelAyarlar';
import { Mesajlar } from './sayfalar/Mesajlar';
import { Kategoriler } from './sayfalar/Kategoriler';
import { YapayZeka } from './sayfalar/YapayZeka';
import { UtsSorgu } from './sayfalar/UtsSorgu';
import { RadyolojiPanosu } from './sayfalar/RadyolojiPanosu';
import { TeleradyolojiPanosu } from './sayfalar/TeleradyolojiPanosu';
import { TeleradFatura } from './sayfalar/TeleradFatura';
import { EnabizPanosu } from './sayfalar/EnabizPanosu';
import { Hakedisim } from './sayfalar/Hakedisim';
import { RadyolojiRapor } from './sayfalar/RadyolojiRapor';
import { RadyolojiIstemKarti } from './sayfalar/RadyolojiIstemKarti';
import { MuayeneSablonlari } from './sayfalar/MuayeneSablonlari';
import { RadyolojiRaporCikti } from './sayfalar/RadyolojiRaporCikti';
import { LabRaporCikti } from './sayfalar/LabRaporCikti';
import { GozSemaCikti } from './sayfalar/GozSemaCikti';
import { BelgeYazisi } from './sayfalar/BelgeYazisi';
import { ServisCizelge } from './sayfalar/ServisCizelge';
import { ArizaBildir } from './sayfalar/ariza/ArizaBildir';
import { ZiyaretMobil } from './sayfalar/servis/ZiyaretMobil';
import { DisHastaKarti } from './sayfalar/dis/DisHastaKarti';
import { DisGunlukAkis } from './sayfalar/dis/DisGunlukAkis';
import { DisLabEtiket } from './sayfalar/dis/DisLabEtiket';
import { BzbhPanosu } from './sayfalar/BzbhPanosu';
import { EnabizGunSonu } from './sayfalar/EnabizGunSonu';
import { LabArsiv } from './sayfalar/LabArsiv';
import { DisSeansKarti } from './sayfalar/dis/DisSeansKarti';
import { DisPlanKarti } from './sayfalar/dis/DisPlanKarti';
import { FtrProgramKarti } from './sayfalar/ftr/FtrProgramKarti';
import { FtrSeansKarti } from './sayfalar/ftr/FtrSeansKarti';
import { FtrPano } from './sayfalar/ftr/FtrPano';
import { FormAcik } from './sayfalar/form/FormAcik';
import { FormDoldur } from './sayfalar/form/FormDoldur';
import { HastaFormlari } from './sayfalar/form/HastaFormlari';
import { FormKutuphane } from './sayfalar/form/FormKutuphane';
import { FormSablonEditor } from './sayfalar/form/FormSablonEditor';
import { IsgPano } from './sayfalar/isg/IsgPano';
import { IsgCalisanKarti } from './sayfalar/isg/IsgCalisanKarti';
import { IsgTakvim } from './sayfalar/isg/IsgTakvim';
import { CagriOperator } from './sayfalar/cagri/CagriOperator';
import { CagriKarti } from './sayfalar/cagri/CagriKarti';
import { CagriGiden } from './sayfalar/cagri/CagriGiden';
import { CagriSupervizor } from './sayfalar/cagri/CagriSupervizor';
import { CagriSantral } from './sayfalar/cagri/CagriSantral';
import { SterilPano } from './sayfalar/steril/SterilPano';
import { SterilDonguKarti } from './sayfalar/steril/SterilDonguKarti';
import { SterilIzlenebilirlik } from './sayfalar/steril/SterilIzlenebilirlik';
import { SterilAyarlar } from './sayfalar/steril/SterilAyarlar';
import { MedulaHastaKabul } from './sayfalar/medula/MedulaHastaKabul';
import { MedulaHizmetKayit } from './sayfalar/medula/MedulaHizmetKayit';
import { MedulaFaturaDonem } from './sayfalar/medula/MedulaFaturaDonem';
import { MedulaKuyruk } from './sayfalar/medula/MedulaKuyruk';
import { LabKkGrafik } from './sayfalar/LabKkGrafik';
import { LabEtiket } from './sayfalar/LabEtiket';
import { SatisAyarlar, AlisAyarlar } from './sayfalar/BelgeAyarlar';
import { Panel } from './sayfalar/Panel';
import { ParolaZorunlu } from './sayfalar/ParolaZorunlu';
import { IskontoOnaylari } from './sayfalar/IskontoOnaylari';
import { calismaOku } from './bilesenler/calismaTercihi';
import { Dokumler } from './sayfalar/Dokumler';
import { useOtomatikTamamlamaKapali } from './bilesenler/otomatikTamamlama';
import { c } from './dil/ceviri';

function Yollar() {
  const { kullanici, yukleniyor, yetki } = useOturum();
  const konum = useLocation();

  // ACIK FORM SAYFASI (740): /f/{kod} - hastanin telefonunda, OTURUMSUZ. Giris
  //   ekranindan ONCE: kimlik kaniti bağlantı + TCKN son 4, JWT degil.
  if (konum.pathname.startsWith('/f/')) return <Routes><Route path="/f/:kod" element={<FormAcik />} /></Routes>;

  // PORTAL DAVETI (822): /davet/{jeton} - hastanin telefonunda, OTURUMSUZ.
  //   Giris ekranindan ONCE: kisi henuz kullanici degil, hesabini burada acar.
  if (konum.pathname.startsWith('/davet/'))
    return <Routes><Route path="/davet/:jeton" element={<PortalDavet />} /></Routes>;

  if (yukleniyor) return <div className="tam-ekran-bilgi">{c('Yukleniyor…')}</div>;
  if (!kullanici) return <Giris />;
  // ZORUNLU PAROLA DEGISIMI (667): varsayilan parolayla (kart id) giren kisi
  //   once kendi parolasini belirler - bayrak dusene kadar HICBIR rota
  //   cizilmez, yoksa "sonra degistiririm" diyen kullanici o parolayla kalirdi.
  if (kullanici.parolaDegismeli) return <ParolaZorunlu />;

  // Acilis ekrani artik PANEL (bkz. asagidaki "*" rotasi); eskiden yetkisi olan
  //   ILK liste aciliyordu ve kullanici nerede oldugunu anlamiyordu.

  // Yetkisiz kullanici ana sayfaya dusmesin: ilk erisilebilir ekran.
  const ilkErisilebilir = LISTELER.find(l =>
    yetki(l.yetkiKodu) && !l.menuGizli
    && (!l.urunModu || modUyar(l.urunModu, kullanici?.urunModu))
    && modulAcikMi(l, kullanici?.moduller));
  const varsayilanYol = yetki('panel')
    ? '/panel'
    : `/${ilkErisilebilir?.rota ?? ilkErisilebilir?.kaynak ?? 'panel'}`;
  // ACILIS EKRANI (kullanici ayarlari > calisma tercihleri): kisi kendi
  //   secmisse ve o ekrana yetkisi varsa oraya; yoksa varsayilan yol.
  const acilis = calismaOku().acilisEkran;
  const acilisUygun = acilis === 'panel' ? yetki('panel')
    : LISTELER.some(l => (l.rota ?? l.kaynak) === acilis && yetki(l.yetkiKodu)
        && (!l.urunModu || modUyar(l.urunModu, kullanici?.urunModu))
        && modulAcikMi(l, kullanici?.moduller));
  const ilkYol = acilis && acilisUygun ? `/${acilis}` : varsayilanYol;

  // PORTAL KABUGU V2 (796/818): dis hekim / dis kurum / hasta AYRI kabuk
  //   gorur - telefon icin cekmece menu, acilir bolumler, sade ust serit.
  //   Rotalar AYNI: portal kullanicisi zaten yalnizca yetkili oldugu
  //   ekranlari goruyor ve her liste kendi kapsam kuraliyla suzuluyor (794).
  const portalMi = (kullanici.portalTuru ?? 0) > 0;

  return (
    <Routes>
      <Route element={portalMi ? <PortalKabuk /> : <Kabuk />}>
        {/* Kart modal oldugu icin liste ile AYNI bilesende acilir: /cari ve /cari/4911
            ayni ekrani cizer, ikincisinde modal ustte durur. Rota=kaynak DEGILDIR
            zorunlu olarak - ayni kaynak ('cari') Musteri/Tedarikci gibi birden fazla
            ekranda farkli `rota` ile kullanilabilir, o yuzden path `rota ?? kaynak`dan
            uretilir. */}
        {LISTELER.filter(l => yetki(l.yetkiKodu) && !l.ozelSayfa
          // Urun modu suzmesi (215): moda ozel ekranlar (Kayit Kabul = GenoTIP)
          //   diger urunde rotasiyla birlikte yok olur.
          && (!l.urunModu || modUyar(l.urunModu, kullanici.urunModu))
          // MODUL suzmesi (359): kapali modulun ROTASI da acilmaz - menude
          //   gizlemek yetmiyor, adres cubuguna yazilinca ekran yine acilirdi.
          && modulAcikMi(l, kullanici.moduller)
          // MENU BAGLANTISI (menuYol): kendi ekrani yok, var olan bir ekrana
          //   suzgecle gider - ayni rotayi ikinci kez kaydetmek React Router'da
          //   sessizce ilkini kazandirirdi.
          && !l.menuYol).flatMap(l => {
          const rota = l.rota ?? l.kaynak;
          return [
            <Route key={rota} path={`/${rota}`} element={<Liste tanim={l} />} />,
            ...(l.kartYolu && !l.ozelKart ? [
              <Route key={`${rota}-kart`} path={`/${rota}/:id`} element={<Liste tanim={l} />} />,
            ] : []),
          ];
        })}

        <Route path="/belge/yeni" element={<BelgeKarti />} />

        {/* Kasa islem karti BESPOKE (GenForm degil): tur sablonu, bacaklar ve fis
            paneli generic karta sigmaz. LISTELER dongusu 'kasa-islem' icin kart
            uretmez (ozelKart), bu iki rota onun yerine gecer. */}
        <Route path="/kasa-islem/yeni" element={<KasaIslemKarti />} />
        <Route path="/kasa-islem/:id" element={<KasaIslemKarti />} />

        {/* ANA SAYFA: panel. Giris sonrasi buraya gelinir - eskiden ilk listeye
            (Hasta) dusuyordu, kullanici nerede oldugunu anlamiyordu.
            YETKIYE BAGLI (241): menude gizlemek yetmiyordu, rota acik kalinca
            giris sonrasi yine ana sayfa aciliyordu (kullanici). */}
        {yetki('panel') && <Route path="/panel" element={<Panel />} />}

        {/* İletişim & AI (341): menude Ana Sayfa'nin hemen altinda, her iki
            urun modunda. Ekranlar simdilik kapsam sayfasi. */}
        {yetki('mesaj') && <Route path="/mesajlar" element={<Mesajlar />} />}
        {yetki('ai') && <Route path="/yapay-zeka" element={<YapayZeka />} />}

        {/* Ayar ekranlari liste degil (ozelSayfa) - rotalari burada. */}
        {yetki('ayar') && <Route path="/genel-ayarlar" element={<GenelAyarlar />} />}
        {yetki('ayar') && <Route path="/kayit-kabul-ayarlar" element={<KayitKabulAyarlar />} />}
        {yetki('katalog') && <Route path="/katalog-ayarlar" element={<KatalogAyarlar />} />}
        {yetki('stok') && <Route path="/stok-ayarlar" element={<StokAyarlar />} />}
        {/* Kategoriler iki bolmeli ozel ekran (345) - duz liste degil. */}
        {yetki('stok') && <Route path="/kategori" element={<Kategoriler />} />}
        {yetki('kasa_islem') && <Route path="/kasa-ayarlar" element={<KasaAyarlar />} />}
        {/* Excel'den iceri alma sihirbazi (548) - liste degil, dort adimli ekran. */}
        {yetki('ayar') && <Route path="/iceri-alma" element={<IceriAlma />} />}
        {yetki('randevu') && <Route path="/randevu-ayarlar" element={<RandevuAyarlar />} />}
        {/* Calisma plani (711): sablon + istisnadan turetilen haftalik plan. */}
        {yetki('randevu.plan') && <Route path="/calisma-plani" element={<CalismaPlani />} />}
        {/* Ameliyathane masa cizelgesi (719): generic liste satir cizer, blok
            cizmez - "hangi masa ne zaman bos" sorusu kendi sayfasini ister. */}
        {yetki('ameliyathane.plan') && <Route path="/ameliyat-cizelge" element={<AmeliyatCizelge />} />}
        {/* Departman + gorev (255): tek ekranda iki grid. */}
        {yetki('personel') && <Route path="/departman" element={<DepartmanGorev />} />}
        {yetki('sube') && <Route path="/sube" element={<FirmaBilgileri />} />}
        {/* Kurum profili (489): Firma Bilgileri'nin sekmesiydi, kendi ekrani. */}
        {yetki('sube') && <Route path="/kurum-profili" element={<KurumProfili />} />}
        {yetki('belge') && <Route path="/satis-ayarlar" element={<SatisAyarlar />} />}
        {yetki('belge') && <Route path="/alis-ayarlar" element={<AlisAyarlar />} />}
        {/* ÜTS urun sorgu (223): liste degil, canli sorgu formu. */}
        {yetki('uts') && <Route path="/uts-sorgu" element={<UtsSorgu />} />}
        {/* Radyoloji panosu (320): liste degil - sayac/doluluk/uyari ekrani. */}
        {yetki('radyoloji') && <Route path="/radyoloji-pano" element={<RadyolojiPanosu />} />}
        {yetki('teleradyoloji') && <Route path="/telerad-pano" element={<TeleradyolojiPanosu />} />}
        {yetki('teleradyoloji.kurum') && <Route path="/telerad-fatura" element={<TeleradFatura />} />}
        {yetki('entegrasyon') && <Route path="/enabiz-pano" element={<EnabizPanosu />} />}
        {/* HAKEDISLERIM: hekimin KENDI prim dokumu - liste degil, ozet +
            gruplu dokum. Yetki `prim.kendi`; butun kisileri goren ekran
            Prim modulunde ve `prim` yetkisinde. */}
        {yetki('prim.kendi') && <Route path="/hakedisim" element={<Hakedisim />} />}
        {/* PRIM SATIRLARI: ayni self-scoped hakedisim endpoint/sayfasi, menude
            Hakedislerim'in ustunde ayri giris (kullanici). */}
        {yetki('prim.kendi') && <Route path="/prim-satirlari" element={<Hakedisim />} />}

        {/* ISKONTO ONAY EKRANI (666): zilin buyugu - kuyruk, karar, limit,
            analiz. 'belge' gor yetkisi yeter; KARAR yetkisi ayri (aksiyon
            basvuru.iskonto) ve ekran icinde olculur. */}
        {yetki('iskonto_onay') && <Route path="/iskonto-onay" element={<IskontoOnaylari />} />}
        {/* DOKUMLER & ISTATISTIK (686): kosullu, kaydedilen, tekrar calistirilan
            dokum tasarimcisi + baski onizleme. SQL istemcide yok. */}
        {yetki('dokum') && <Route path="/dokumler" element={<Dokumler />} />}
        {/* Radyoloji raporu: generic kart degil - bolumler sablondan uretilir,
            onay iki asamali ve onaydan sonra rapor kilitlenir (283/284). */}
        {yetki('radyoloji') && <Route path="/radyoloji/rapor/:istemId" element={<RadyolojiRapor />} />}
        {yetki('radyoloji-istem') && <Route path="/radyoloji/:id" element={<RadyolojiIstemKarti />} />}
        {/* Rapor CIKTISI (303): hastaya verilen belge - yazma ekranindan ayri
            sayfa, yazdirma tarayicinin kendi diyalogu. */}
        {yetki('radyoloji') && <Route path="/radyoloji/cikti/:id" element={<RadyolojiRaporCikti />} />}
        {/* Lab sonuc raporu (441): istem numarasiyla acilir - bir istemdeki
            sayisal sonuc, kultur ve genetik ayni kagida basilir. */}
        {yetki('lab') && <Route path="/lab/rapor/:id" element={<LabRaporCikti />} />}
        {/* Goz semasi CIKTISI (705): cizim ekranindan ayri sayfa - kagida
            palet ve arac degil, antet + kimlik + sema + isaret dokumu gider. */}
        {yetki('goz.muayene') && (
          <Route path="/goz/sema-cikti/:id" element={<GozSemaCikti />} />
        )}
        {/* Belge talebi YAZISI (768): liste ekraninda cizilemez - kagida
            antet + metin + imza gider, arac cubugu gitmez. */}
        {yetki('ik.belge_talep') && (
          <Route path="/belge-talep/yazi/:id" element={<BelgeYazisi />} />
        )}
        {/* Teknisyen cizelgesi (775): generic liste satir cizer, BLOK cizmez -
            "kimde bos kapasite var" sorusu zaman ekseninde gorulur. */}
        {yetki('servis') && (
          <Route path="/servis-cizelge" element={<ServisCizelge />} />
        )}
        {yetki('ariza.talep') && (
          <Route path="/ariza-bildir" element={<ArizaBildir />} />
        )}
        {yetki('muayene') && (
          <Route path="/muayene-sablon" element={<MuayeneSablonlari />} />
        )}
        {/* DIS (706): hasta karti (odontogram + plan) ve gunluk akis ozel
            sayfalardir - generic liste/kart odontogrami cizemez. */}
        {/* Dis hasta karti MODALDIR (kullanici): arkada Dis Hastalari listesi,
            ustte odontogram + plan penceresi - generic kartlarla ayni his. */}
        {yetki('dis.hasta') && (
          <Route path="/dis-hasta/:hastaId" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'dis-hasta')!} />
            <DisHastaKarti />
          </>} />
        )}
        {yetki('dis') && <Route path="/dis-akis" element={<DisGunlukAkis />} />}
        {/* Protez is emri barkot etiketi (874, KTS D1): yazdirma sayfasi -
            arac cubugu ve menu basilmaz, sayfada yalniz etiket kalir. */}
        {yetki('dis.lab') && <Route path="/dis-lab/etiket" element={<DisLabEtiket />} />}
        {/* BZBH bildirim panosu (882, KTS H5): enfeksiyon kontrol biriminin
            gunluk ekrani - bekleyen ve geciken vaka bildirimleri. */}
        {yetki('bzbh') && <Route path="/bzbh" element={<BzbhPanosu />} />}
        {/* Gun sonu ve gonderim orani (884, KTS H13). */}
        {yetki('enabiz.gun_sonu') && <Route path="/enabiz-gun-sonu" element={<EnabizGunSonu />} />}
        {/* NUMUNE ARŞİVİ (890, KTS L13): ızgara üzerinden yerleştirme/çıkarma. */}
        {yetki('lab.arsiv') && <Route path="/lab-arsiv" element={<LabArsiv />} />}
        {/* Seans karti (708): yapilan islemler listesi - generic detay tablosu
            "plan satirindan ekle" ve "bu seansta tamamlandi" kuralini tasiyamiyordu. */}
        {yetki('dis.seans') && (
          <Route path="/dis-seans/:id" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'dis-seans')!} />
            <DisSeansKarti />
          </>} />
        )}
        {/* FTR (719): unite panosu ozel sayfa; program ve seans kartlari modal.
            Program karti "yeni-kart" ve ":id/duzenle" yollari generic GenForm'a
            gider (ozel modal yalniz goruntuler/planlar). */}
        {yetki('ftr.seans') && <Route path="/ftr-pano" element={<FtrPano />} />}
        {yetki('ftr.program') && (
          <Route path="/ftr-program/:id" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'ftr-program')!} />
            <FtrProgramKarti />
          </>} />
        )}
        {yetki('ftr.seans') && (
          <Route path="/ftr-seans/:id" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'ftr-seans')!} />
            <FtrSeansKarti />
          </>} />
        )}
        {/* Tedavi plani karti (710): mockup dis_tedavi_plani_karti - seans programi,
            proforma/onay, odeme plani, lab, varyant ve gunluk tek kartta. */}
        {yetki('dis.plan') && (
          <Route path="/dis-plan/:id" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'dis-plan')!} />
            <DisPlanKarti />
          </>} />
        )}
        {/* FORM MOTORU (740): doldurma ve hasta formlari modal (arkada ilgili liste),
            kutuphane ve editor tam sayfa. */}
        {yetki('form.istek') && (
          <Route path="/form-doldur/:id" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'form-istek')!} />
            <FormDoldur />
          </>} />
        )}
        {yetki('form.istek') && (
          <Route path="/hasta-formlar/:hastaId" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'form-istek')!} />
            <HastaFormlari />
          </>} />
        )}
        {yetki('form.kutuphane') && <Route path="/form-kutuphane" element={<FormKutuphane />} />}
        {/* ISG (741): firma panosu ve periyodik takvim tam sayfa; calisan karti modal. */}
        {yetki('isg.pano') && <Route path="/isg-pano" element={<IsgPano />} />}
        {yetki('isg.takvim') && <Route path="/isg-takvim" element={<IsgTakvim />} />}
        {yetki('isg.calisan') && (
          <Route path="/isg-calisan/:id" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'isg-calisan' && l.rota === 'isg-calisan')!} />
            <IsgCalisanKarti />
          </>} />
        )}
        {/* ÇAĞRI MERKEZİ (839): operatör / giden / süpervizör / santral tam sayfa; çağrı kartı liste üstünde modal. */}
        {yetki('cagri.pano') && <Route path="/cagri-pano" element={<CagriOperator />} />}
        {yetki('cagri.giden') && <Route path="/cagri-giden" element={<CagriGiden />} />}
        {yetki('cagri.supervizor') && <Route path="/cagri-supervizor" element={<CagriSupervizor />} />}
        {yetki('cagri.ayar') && <Route path="/cagri-santral" element={<CagriSantral />} />}
        {yetki('cagri.kayit') && (
          <Route path="/cagri/:id" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'cagri' && l.rota === 'cagri')!} />
            <CagriKarti />
          </>} />
        )}
        {/* STERİLİZASYON (868): pano / izlenebilirlik / ayar tam sayfa; döngü kartı liste üstünde modal. */}
        {yetki('steril.pano') && <Route path="/steril-pano" element={<SterilPano />} />}
        {yetki('steril.izleme') && <Route path="/steril-izleme" element={<SterilIzlenebilirlik />} />}
        {yetki('steril.ayar') && <Route path="/steril-ayar" element={<SterilAyarlar />} />}
        {yetki('steril.dongu') && (
          <Route path="/steril-dongu/:id" element={<>
            <Liste tanim={LISTELER.find(l => l.kaynak === 'steril-dongu' && l.rota === 'steril-dongu')!} />
            <SterilDonguKarti />
          </>} />
        )}
        {yetki('form.sablon') && <Route path="/form-editor/:id" element={<FormSablonEditor />} />}
        {/* MEDULA (707): hasta kabul, hizmet kaydi, fatura & donem, kuyruk & ayarlar ozel sayfalar. */}
        {yetki('medula.provizyon') && <Route path="/medula-kabul" element={<MedulaHastaKabul />} />}
        {yetki('medula.provizyon') && <Route path="/medula-kabul/:belgeId" element={<MedulaHastaKabul />} />}
        {yetki('medula.hizmet') && <Route path="/medula-hizmet/:belgeId" element={<MedulaHizmetKayit />} />}
        {yetki('medula.fatura') && <Route path="/medula-fatura-donem" element={<MedulaFaturaDonem />} />}
        {yetki('medula') && <Route path="/medula-kuyruk-ayar" element={<MedulaKuyruk />} />}
        {/* Levey-Jennings (442): tetkik/lot/seviye sorgu parametresiyle. */}
        {yetki('lab.kk') && <Route path="/lab/kk/grafik" element={<LabKkGrafik />} />}
        {/* Tup barkod etiketi (444): ?istem= tum tupler, ?numune= tek tup. */}
        {yetki('lab.numune') && <Route path="/lab/etiket" element={<LabEtiket />} />}

        {/* Bilinmeyen yol: Ana Sayfa yetkisi varsa panele, yoksa kullanicinin
            girebildigi ILK ekrana (yetkisi hic yoksa oldugu yerde kalir). */}
        <Route path="*" element={<Navigate to={ilkYol} replace />} />
      </Route>

      {/* ZİYARET KARTI KABUĞUN DIŞINDA (776) — teknisyenin telefonu.
          Yan menü telefon genişliğinde açık kalıyor ve kartı 114 px'lik bir
          şeride sıkıştırıyordu; sahada tek elle doldurulacak ekranın tam
          genişliğe ihtiyacı var. Açık form sayfası (`/f/:kod`) da aynı
          sebeple kabuk dışında.

          YOL AYRI KÖKTEN: liste `/servis-ziyaret/:id` rotasını da kaydediyor,
          alt yol olsaydı "mobil" onun `:id`'si olarak eşleşip listeyi
          açardı - React Router'da önce kaydedilen kazanır. */}
      {yetki('servis') && (
        <Route path="/ziyaret-karti/:id" element={<ZiyaretMobil />} />
      )}
    </Routes>
  );
}

export default function App() {
  // TARAYICI OTOMATIK TAMAMLAMASI KAPALI (780, kullanici): 500'den fazla
  //   input'a tek tek yazmak bugunkuleri kapatir, yarin eklenecegi kapatmaz.
  //   Kural tek yerde ve sonradan cizilen alanlari da kapsiyor.
  useOtomatikTamamlamaKapali();

  // basename: uygulama alt yolda yayinda olabilir (sunucuda /ai) - rotalar o
  //   onekle calisir. import.meta.env.BASE_URL vite'in `base` degeri, yerelde "/".
  return (
    <BrowserRouter basename={import.meta.env.BASE_URL}>
      <OturumSaglayici>
        <Yollar />
        {/* Tek mesaj/onay penceresi ("Gentegre AI Mesajı") - tarayici
            alert/confirm kutulari yerine (bkz. bilesenler/mesaj.ts).
            Yollar'dan SONRA cizilir ve perdesi enUst'tur: kart modali acikken
            sorulan onay arkada kaybolmasin. */}
        <MesajKatmani />
      </OturumSaglayici>
    </BrowserRouter>
  );
}
