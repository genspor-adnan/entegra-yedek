import { useState } from 'react';
import { useOturum } from '@web/kimlik/OturumBaglami';
import { KurumTipiAyarlari } from '@web/bilesenler/KurumTipiAyarlari';
import { hataMetni } from '@web/api/sozlesme';

/**
 * Bağlı sunucunun kurum profili. Oturum yoksa kullanıcı/parola sorar, varsa
 * **web ürünündeki ekranın kendisini** çizer - bu araç ayrı bir profil ekranı
 * taşımaz.
 */
export function Profil({ adres, onKop }: { adres: string; onKop(): void }) {
  const { kullanici, yukleniyor, oturumHatasi, girisYap, cikisYap } = useOturum();
  const [kod, setKod] = useState('');
  const [parola, setParola] = useState('');
  const [hata, setHata] = useState('');
  const [bekle, setBekle] = useState(false);

  const gir = async (e: React.FormEvent) => {
    e.preventDefault();
    setHata(''); setBekle(true);
    try { await girisYap(kod, parola) } catch (h) { setHata(hataMetni(h)) }
    finally { setBekle(false) }
  };

  const cik = async () => {
    // Oturumu sunucuda da kapat, sonra adres ekranına dön.
    try { await cikisYap() } catch { /* bağlantı koptuysa yerel temizlik yeter */ }
    onKop();
  };

  const ust = (
    <div className="gp-ust">
      <span className="gp-marka">GenProfil</span>
      <span className="gp-sunucu">{adres}</span>
      <span className="gp-bosluk" />
      {kullanici && <span className="sonuk">{kullanici.ad || kullanici.kod}</span>}
      <button type="button" className="d" onClick={() => void cik()}>
        {kullanici ? 'Kaydet ve çık' : 'Sunucuyu değiştir'}
      </button>
    </div>
  );

  if (yukleniyor) return <div className="gp-kok">{ust}<div className="gp-govde sonuk">Bağlanıyor…</div></div>;

  if (oturumHatasi) return (
    <div className="gp-kok">{ust}
      <div className="gp-govde"><div className="gp-hata">{oturumHatasi}</div></div>
    </div>
  );

  if (!kullanici) return (
    <div className="gp-kok">{ust}
      <form className="gp-giris" onSubmit={gir}>
        <h1>Giriş</h1>
        <div className="sonuk">{adres}</div>
        {hata && <div className="gp-hata">{hata}</div>}
        <label className="gp-alan"><span>Kullanıcı</span>
          <input value={kod} onChange={e => setKod(e.target.value)} autoFocus /></label>
        <label className="gp-alan"><span>Parola</span>
          <input type="password" value={parola} onChange={e => setParola(e.target.value)} /></label>
        <button type="submit" className="d birincil" disabled={bekle || !kod || !parola}>
          {bekle ? 'Giriliyor…' : 'Giriş'}</button>
      </form>
    </div>
  );

  // KAYDETME EKRANIN KENDİSİNDE: profil ekranı kendi "Kaydet" düğmelerini
  //   taşıyor; buradaki "Kaydet ve çık" yalnız oturumu kapatır, kaydedilmemiş
  //   bir değişikliği göndermez - araç, ekranın kurallarını tekrar yazmıyor.
  return <div className="gp-kok">{ust}<div className="gp-govde"><KurumTipiAyarlari /></div></div>;
}
