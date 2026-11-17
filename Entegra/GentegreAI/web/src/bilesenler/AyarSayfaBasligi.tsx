import { useContext, type ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { EkranSekmesiBaglami } from './sekmeBaglami';
import { secimSor } from './mesaj';
import { c } from '../dil/ceviri';

/**
 * AYAR SAYFASI BAŞLIĞI (kullanıcı 17.11.2026: "ayarlar ekranlarında desen: sol üst köşeye (başlık label soluna)
 * 'Kaydet & Uygula', sağ üst köşeye de kapat butonu ekle.. otomatik kaydetmeyi kaldır, kaydet basınca kaydedilsin").
 * useAyarlar({ taslakli: true }) ile: değişiklik yoksa Kaydet pasif; kaydedilmemiş değişiklikte Kapat sorar.
 */
export function AyarSayfaBasligi({ baslik, yol, ayar, ek }: {
  baslik: string;
  yol?: string;
  ayar: { kaydet(): Promise<boolean>; degisti: boolean; kaydediyor: boolean; vazgec(): void };
  /** Başlığın sağında (Kapat'tan önce) ekrana özel öğe. */
  ek?: ReactNode;
}) {
  const ekranSekmesi = useContext(EkranSekmesiBaglami);
  const git = useNavigate();
  const cik = () => { if (ekranSekmesi) ekranSekmesi.kapat(); else git('/') };

  const kapat = async () => {
    if (ayar.degisti) {
      const s = await secimSor(c('Kaydedilmemiş ayar değişiklikleri var.'), [
        { kod: 'kaydet', ad: `💾 ${c('Kaydet ve Kapat')}`, sinif: 'bir' },
        { kod: 'at', ad: c('Kaydetmeden Kapat'), sinif: 'teh' },
        { kod: 'geri', ad: c('Geri Dön') },
      ], 'geri');
      if (s === 'geri') return;
      if (s === 'kaydet' && !await ayar.kaydet()) return;
      if (s === 'at') ayar.vazgec();
    }
    cik();
  };

  return (
    <div className="sayfabas ayar-sayfabas">
      <div className="basrow">
        <button type="button" className="d bir" disabled={!ayar.degisti || ayar.kaydediyor}
                data-testid="ayar-kaydet" onClick={() => void ayar.kaydet()}
                title={ayar.degisti ? c('Değişen ayarları kaydet ve uygula') : c('Değişiklik yok')}>
          💾 {ayar.kaydediyor ? c('Kaydediliyor…') : c('Kaydet & Uygula')}
        </button>
        <h1>{c(baslik)}</h1>
        {yol && <span className="yol">{c(yol)}</span>}
        {ayar.degisti && <span className="rozet uyari" data-testid="ayar-degisti">{c('kaydedilmemiş değişiklik')}</span>}
        <span className="ayar-sayfabas-sag">
          {ek}
          <button type="button" className="d kapat-dugmesi" data-testid="ayar-kapat" onClick={() => void kapat()}>✖ {c('Kapat')}</button>
        </span>
      </div>
    </div>
  );
}
