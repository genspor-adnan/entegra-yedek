import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { sonMenuEkle } from '../menuSonKullanilan';

/**
 * SOL MENUNUN KULLANICI TERCIHLERI: favoriler ve en son kullanilanlar.
 *
 * FAVORILER SUNUCUDA (kullanici tercihleri): makine degistiren kullanici
 * yildizlarini kaybetmesin. `localStorage` artik yalniz CEVRIMDISI KOPYA:
 * sunucuya ulasilamazsa menu yine dolu acilir, ilk yazmada sunucu tekrar
 * dogruyu ogrenir.
 *
 * EN SON KULLANILANLAR (kullanici: "Favori'den sonra 'En Son' ekle, son 10
 * secilmis menu listelensin") favorilerin aksine kendiliginden birikir: gunun
 * isi hep ayni birkac ekranda geciyor ama hangileri oldugu onceden bilinmiyor.
 * Yol EN BASA yazilir, ayni yol ikinci kez secilince yukari tasinir (kopya
 * birikmez), liste ONDA kirpilir.
 */
export function useMenuTercihleri(kullaniciId: number | undefined) {
  const favoriAnahtar = `favoriler.${kullaniciId ?? 0}`;
  const sonAnahtar = `sonMenuler.${kullaniciId ?? 0}`;

  const [favoriler, setFavoriler] = useState<string[]>([]);
  const [sonMenuler, setSonMenuler] = useState<string[]>([]);

  const yerelFavori = (anahtar: string): string[] => {
    try { return JSON.parse(localStorage.getItem(anahtar) ?? '[]') as string[] }
    catch { return [] }
  };

  useEffect(() => {
    if (!kullaniciId) return;
    let iptal = false;
    void (async () => {
      const yerel = yerelFavori(favoriAnahtar);
      let liste = yerel;
      try {
        const tercihler = await api.tercihler();
        const ham = tercihler.favoriler;
        if (ham === undefined) {
          // Sunucuda HIC kayit yok: tarayicidaki eski liste bir kez tasinir.
          //   (Bos liste "[]" olarak yazilmis olabilir - o zaman kullanici
          //   favorilerini bilerek bosaltmistir, geri getirilmez.)
          if (yerel.length > 0)
            await api.tercihYaz('favoriler', JSON.stringify(yerel)).catch(() => {});
        } else {
          liste = JSON.parse(ham) as string[];
          try { localStorage.setItem(favoriAnahtar, ham) } catch { /* dolu/kapali depo */ }
        }
      } catch { /* sunucuya ulasilamadi - yerel kopya ile devam */ }
      if (!iptal) setFavoriler(Array.isArray(liste) ? liste : []);
    })();
    return () => { iptal = true };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kullaniciId, favoriAnahtar]);

  const favoriToggle = (yol: string) => setFavoriler(t => {
    const y = t.includes(yol) ? t.filter(x => x !== yol) : [...t, yol];
    const metin = JSON.stringify(y);
    try { localStorage.setItem(favoriAnahtar, metin) } catch { /* dolu/kapali depo */ }
    // Yazma sessizce denenir: ag koparsa yildiz yine de degisir, yerel kopya
    //   dogru kalir; sonraki basarili yazmada sunucu ile esitlenir.
    void api.tercihYaz('favoriler', metin).catch(() => {});
    return y;
  });

  useEffect(() => {
    try { setSonMenuler(JSON.parse(localStorage.getItem(sonAnahtar) ?? '[]') as string[]) }
    catch { setSonMenuler([]) }
  }, [sonAnahtar]);

  const sonKaydet = (yol: string) => setSonMenuler(o => {
    const y = sonMenuEkle(o, yol) as string[];
    if (y === o) return o;                       // degismediyse yazma
    try { localStorage.setItem(sonAnahtar, JSON.stringify(y)) } catch { /* dolu/kapali depo */ }
    return y;
  });

  return { favoriler, favoriToggle, sonMenuler, sonKaydet };
}

/**
 * KULLANICI AYARLARI PENCERESI: sifre degistirme ve dil secimi.
 *
 * Sifre degisikligi oturumu kapatir (sunucu tum oturumlari iptal eder), bu
 * yuzden pencere once kapanir sonra cikis yapilir.
 */
export function useKullaniciAyari(opts: {
  mevcutDil: number;
  dilDegistir(dil: number): Promise<void>;
  cikisYap(): Promise<void> | void;
}) {
  const { mevcutDil, dilDegistir, cikisYap } = opts;

  const [acik, setAcik] = useState(false);
  const [eskiSifre, setEskiSifre] = useState('');
  const [sifre1, setSifre1] = useState('');
  const [sifre2, setSifre2] = useState('');
  const [seciliDil, setSeciliDil] = useState(0);
  const [mesaj, setMesaj] = useState('');
  const [kaydediliyor, setKaydediliyor] = useState(false);

  const kapat = () => {
    setAcik(false);
    setMesaj('');
    setEskiSifre('');
    setSifre1('');
    setSifre2('');
  };

  const tamam = async () => {
    setMesaj('');
    if (sifre1 || sifre2 || eskiSifre) {
      if (!eskiSifre) { setMesaj('Mevcut şifre gerekli.'); return }
      if (sifre1.length < 8) { setMesaj('Şifre en az 8 karakter olmalı.'); return }
      if (sifre1 !== sifre2) { setMesaj('Şifreler aynı değil.'); return }
    }

    setKaydediliyor(true);
    try {
      if (seciliDil !== mevcutDil) await dilDegistir(seciliDil);
      if (sifre1 || sifre2 || eskiSifre) {
        await api.parolaDegistir(eskiSifre, sifre1);
        kapat();
        await cikisYap();
        return;
      }
      kapat();
    } catch (e) {
      setMesaj(e instanceof Error ? e.message : 'Kullanıcı ayarları kaydedilemedi.');
    } finally {
      setKaydediliyor(false);
    }
  };

  // Pencere acilinca dil kutusu kullanicinin GUNCEL dili ile baslar.
  useEffect(() => { if (acik) setSeciliDil(mevcutDil) }, [acik, mevcutDil]);

  useEffect(() => {
    if (!acik) return;
    const esc = (e: KeyboardEvent) => { if (e.key === 'Escape') kapat() };
    window.addEventListener('keydown', esc);
    return () => window.removeEventListener('keydown', esc);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [acik]);

  return { acik, setAcik, eskiSifre, setEskiSifre, sifre1, setSifre1,
           sifre2, setSifre2, seciliDil, setSeciliDil,
           mesaj, kaydediliyor, kapat, tamam };
}
