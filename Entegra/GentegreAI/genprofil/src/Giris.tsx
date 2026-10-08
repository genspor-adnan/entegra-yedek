import { useState } from 'react';
import { adresDeposu } from './vekil';

export type Baglanti = { adres: string; kod: string; parola: string };

/**
 * BAĞLANTI EKRANI — sunucu adresi, kullanıcı ve parola **tek formda**
 * (kullanıcı: *"girişte user/pass/adres bilgilerini al"*).
 *
 * Önce adres sorup sonra kullanıcıyı ikinci ekranda istemek, teknisyene aynı
 * işi iki adımda yaptırıyordu; adres yanlış girildiğinde de hata ancak ikinci
 * ekranda görünüyordu. Üçü birlikte alınır, bağlanma tek hareket olur.
 *
 * Parola BURADA DOĞRULANMAZ, yalnız bir sonraki adıma taşınır: doğrulama
 * oturum sağlayıcısının işi - tek giriş yolu olsun.
 *
 * Adres son kullanılan değerle gelir; aynı sunucuya tekrar bağlanmak çoğu
 * zaman olan iş. Kullanıcı adı ve parola SAKLANMAZ.
 */
export function Giris({ onBagla, hata }: {
  onBagla(b: Baglanti): void;
  /** Önceki denemenin hatası: ekran burada kalır, bilgiler formda durur. */
  hata?: string;
}) {
  const [adres, setAdres] = useState(adresDeposu.oku());
  const [kod, setKod] = useState('');
  const [parola, setParola] = useState('');

  const gonder = (e: React.FormEvent) => {
    e.preventDefault();
    if (!adres.trim() || !kod || !parola) return;
    onBagla({ adres: adres.trim(), kod, parola });
  };

  return (
    <div className="gp-kok">
      <form className="gp-giris" onSubmit={gonder}>
        <h1>GenProfil</h1>
        <div className="sonuk">Kurum profili bakım aracı</div>
        {hata && <div className="gp-hata">{hata}</div>}
        <label className="gp-alan">
          <span>Sunucu adresi</span>
          <input value={adres} onChange={e => setAdres(e.target.value)} autoFocus
                 placeholder="http://46.36.201.170/genotipai/lab" />
        </label>
        <div className="sonuk gp-ipucu">
          Kurulumun kök adresi. Sonundaki <code>/api</code> gerekmez.
        </div>
        <label className="gp-alan">
          <span>Kullanıcı</span>
          <input value={kod} onChange={e => setKod(e.target.value)} autoComplete="username" />
        </label>
        <label className="gp-alan">
          <span>Parola</span>
          <input type="password" value={parola} onChange={e => setParola(e.target.value)}
                 autoComplete="current-password" />
        </label>
        <button type="submit" className="d birincil"
                disabled={!adres.trim() || !kod || !parola}>Bağlan</button>
      </form>
    </div>
  );
}
