import { BrowserRouter, Navigate, Route, Routes } from 'react-router-dom';
import { OturumSaglayici, useOturum } from './kimlik/OturumBaglami';
import { Giris } from './sayfalar/Giris';
import { Kabuk } from './sayfalar/Kabuk';
import { BelgeKarti } from './sayfalar/BelgeKarti';
import { Liste, LISTELER } from './sayfalar/Liste';

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
            ayni ekrani cizer, ikincisinde modal ustte durur. */}
        {LISTELER.filter(l => yetki(l.yetkiKodu)).flatMap(l => [
          <Route key={l.kaynak} path={`/${l.kaynak}`} element={<Liste tanim={l} />} />,
          ...(l.kartYolu ? [
            <Route key={`${l.kaynak}-kart`} path={`/${l.kaynak}/:id`} element={<Liste tanim={l} />} />,
          ] : []),
        ])}

        <Route path="/belge/yeni" element={<BelgeKarti />} />

        <Route path="*" element={<Navigate to={ilk ? `/${ilk.kaynak}` : '/cari'} replace />} />
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
