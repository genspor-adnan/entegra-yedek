import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { OturumSaglayici, useOturum } from './kimlik/OturumBaglami';
import { Giris } from './sayfalar/Giris';
import { Kabuk } from './sayfalar/Kabuk';
import { BelgeKarti } from './sayfalar/BelgeKarti';
import { KasaIslemKarti } from './sayfalar/KasaIslemKarti';
import { Liste, LISTELER } from './sayfalar/Liste';
import { StokAyarlar } from './sayfalar/StokAyarlar';

function Yollar() {
  const { kullanici, yukleniyor, yetki } = useOturum();

  if (yukleniyor) return <div className="tam-ekran-bilgi">Yukleniyor…</div>;
  if (!kullanici) return <Giris />;

  // Yetkisi olan ilk liste acilis ekrani olur.
  const ilk = LISTELER.find(l => yetki(l.yetkiKodu));

  return (
    <Routes>
      <Route element={<Kabuk />}>
        {/* Kart modal oldugu icin liste ile AYNI bilesende acilir: /cari ve /cari/4911
            ayni ekrani cizer, ikincisinde modal ustte durur. Rota=kaynak DEGILDIR
            zorunlu olarak - ayni kaynak ('cari') Musteri/Tedarikci gibi birden fazla
            ekranda farkli `rota` ile kullanilabilir, o yuzden path `rota ?? kaynak`dan
            uretilir. */}
        {LISTELER.filter(l => yetki(l.yetkiKodu) && !l.ozelSayfa).flatMap(l => {
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

        {/* Ayar ekranlari liste degil (ozelSayfa) - rotalari burada. */}
        {yetki('stok') && <Route path="/stok-ayarlar" element={<StokAyarlar />} />}

        <Route path="*" element={<Navigate to={ilk ? `/${ilk.rota ?? ilk.kaynak}` : '/cari'} replace />} />
      </Route>
    </Routes>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <OturumSaglayici>
        <Yollar />
      </OturumSaglayici>
    </BrowserRouter>
  );
}
