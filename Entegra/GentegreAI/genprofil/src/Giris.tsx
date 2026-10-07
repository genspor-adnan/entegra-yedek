import { useState } from 'react';
import { adresDeposu } from './vekil';

/**
 * Bağlantı ekranı: sunucu adresi + kullanıcı/parola.
 *
 * Parola BURADA DOĞRULANMAZ, yalnız bir sonraki adıma taşınır: doğrulama
 * oturum sağlayıcısının işi (tek giriş yolu olsun). Adres son kullanılan
 * değerle gelir - aynı sunucuya tekrar bağlanmak çoğu zaman olan iş.
 */
export function Giris({ onBagla }: { onBagla(adres: string): void }) {
  const [adres, setAdres] = useState(adresDeposu.oku());

  return (
    <div className="gp-kok">
      <form className="gp-giris" onSubmit={e => { e.preventDefault(); if (adres.trim()) onBagla(adres) }}>
        <h1>GenProfil</h1>
        <div className="sonuk">Kurum profili bakım aracı</div>
        <label className="gp-alan">
          <span>Sunucu adresi</span>
          <input value={adres} onChange={e => setAdres(e.target.value)} autoFocus
                 placeholder="http://46.36.201.170/genotipai/lab" />
        </label>
        <div className="sonuk" style={{ fontSize: 11, marginBottom: 12 }}>
          Kurulumun kök adresi. Sonundaki <code>/api</code> gerekmez.
        </div>
        <button type="submit" className="d birincil" disabled={!adres.trim()}>Bağlan</button>
      </form>
    </div>
  );
}
