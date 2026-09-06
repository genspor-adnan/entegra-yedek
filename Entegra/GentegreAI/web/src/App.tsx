import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { modulAcikMi } from './sayfalar/listeTanimlari';
import { OturumSaglayici, useOturum } from './kimlik/OturumBaglami';
import { Giris } from './sayfalar/Giris';
import { Kabuk } from './sayfalar/Kabuk';
import { BelgeKarti } from './sayfalar/BelgeKarti';
import { KasaIslemKarti } from './sayfalar/KasaIslemKarti';
import { Liste, LISTELER } from './sayfalar/Liste';
import { StokAyarlar } from './sayfalar/StokAyarlar';
import { KasaAyarlar } from './sayfalar/KasaAyarlar';
import { IKAyarlar } from './sayfalar/IKAyarlar';
import { RandevuAyarlar } from './sayfalar/RandevuAyarlar';
import { KayitKabulAyarlar } from './sayfalar/KayitKabulAyarlar';
import { KatalogAyarlar } from './sayfalar/KatalogAyarlar';
import { DepartmanGorev } from './sayfalar/DepartmanGorev';
import { FirmaBilgileri } from './sayfalar/FirmaBilgileri';
import { MesajKatmani } from './bilesenler/MesajKatmani';
import { GenelAyarlar } from './sayfalar/GenelAyarlar';
import { Mesajlar } from './sayfalar/Mesajlar';
import { Kategoriler } from './sayfalar/Kategoriler';
import { YapayZeka } from './sayfalar/YapayZeka';
import { UtsSorgu } from './sayfalar/UtsSorgu';
import { RadyolojiPanosu } from './sayfalar/RadyolojiPanosu';
import { RadyolojiRapor } from './sayfalar/RadyolojiRapor';
import { RadyolojiRaporCikti } from './sayfalar/RadyolojiRaporCikti';
import { LabRaporCikti } from './sayfalar/LabRaporCikti';
import { SatisAyarlar, AlisAyarlar } from './sayfalar/BelgeAyarlar';
import { Panel } from './sayfalar/Panel';

function Yollar() {
  const { kullanici, yukleniyor, yetki } = useOturum();

  if (yukleniyor) return <div className="tam-ekran-bilgi">Yukleniyor…</div>;
  if (!kullanici) return <Giris />;

  // Acilis ekrani artik PANEL (bkz. asagidaki "*" rotasi); eskiden yetkisi olan
  //   ILK liste aciliyordu ve kullanici nerede oldugunu anlamiyordu.

  // Yetkisiz kullanici ana sayfaya dusmesin: ilk erisilebilir ekran.
  const ilkErisilebilir = LISTELER.find(l =>
    yetki(l.yetkiKodu) && !l.menuGizli
    && (!l.urunModu || l.urunModu === (kullanici?.urunModu ?? 1))
    && modulAcikMi(l, kullanici?.moduller));
  const ilkYol = yetki('panel')
    ? '/panel'
    : `/${ilkErisilebilir?.rota ?? ilkErisilebilir?.kaynak ?? 'panel'}`;

  return (
    <Routes>
      <Route element={<Kabuk />}>
        {/* Kart modal oldugu icin liste ile AYNI bilesende acilir: /cari ve /cari/4911
            ayni ekrani cizer, ikincisinde modal ustte durur. Rota=kaynak DEGILDIR
            zorunlu olarak - ayni kaynak ('cari') Musteri/Tedarikci gibi birden fazla
            ekranda farkli `rota` ile kullanilabilir, o yuzden path `rota ?? kaynak`dan
            uretilir. */}
        {LISTELER.filter(l => yetki(l.yetkiKodu) && !l.ozelSayfa
          // Urun modu suzmesi (215): moda ozel ekranlar (Kayit Kabul = GenoTIP)
          //   diger urunde rotasiyla birlikte yok olur.
          && (!l.urunModu || l.urunModu === (kullanici.urunModu ?? 1))
          // MODUL suzmesi (359): kapali modulun ROTASI da acilmaz - menude
          //   gizlemek yetmiyor, adres cubuguna yazilinca ekran yine acilirdi.
          && modulAcikMi(l, kullanici.moduller)).flatMap(l => {
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
        {yetki('personel') && <Route path="/ik-ayarlar" element={<IKAyarlar />} />}
        {yetki('randevu') && <Route path="/randevu-ayarlar" element={<RandevuAyarlar />} />}
        {/* Departman + gorev (255): tek ekranda iki grid. */}
        {yetki('personel') && <Route path="/departman" element={<DepartmanGorev />} />}
        {yetki('sube') && <Route path="/sube" element={<FirmaBilgileri />} />}
        {yetki('belge') && <Route path="/satis-ayarlar" element={<SatisAyarlar />} />}
        {yetki('belge') && <Route path="/alis-ayarlar" element={<AlisAyarlar />} />}
        {/* ÜTS urun sorgu (223): liste degil, canli sorgu formu. */}
        {yetki('uts') && <Route path="/uts-sorgu" element={<UtsSorgu />} />}
        {/* Radyoloji panosu (320): liste degil - sayac/doluluk/uyari ekrani. */}
        {yetki('radyoloji') && <Route path="/radyoloji-pano" element={<RadyolojiPanosu />} />}
        {/* Radyoloji raporu: generic kart degil - bolumler sablondan uretilir,
            onay iki asamali ve onaydan sonra rapor kilitlenir (283/284). */}
        {yetki('radyoloji') && <Route path="/radyoloji/rapor/:istemId" element={<RadyolojiRapor />} />}
        {/* Rapor CIKTISI (303): hastaya verilen belge - yazma ekranindan ayri
            sayfa, yazdirma tarayicinin kendi diyalogu. */}
        {yetki('radyoloji') && <Route path="/radyoloji/cikti/:id" element={<RadyolojiRaporCikti />} />}
        {/* Lab sonuc raporu (441): istem numarasiyla acilir - bir istemdeki
            sayisal sonuc, kultur ve genetik ayni kagida basilir. */}
        {yetki('lab') && <Route path="/lab/rapor/:id" element={<LabRaporCikti />} />}

        {/* Bilinmeyen yol: Ana Sayfa yetkisi varsa panele, yoksa kullanicinin
            girebildigi ILK ekrana (yetkisi hic yoksa oldugu yerde kalir). */}
        <Route path="*" element={<Navigate to={ilkYol} replace />} />
      </Route>
    </Routes>
  );
}

export default function App() {
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
