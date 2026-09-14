import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { api, oturum } from '../api/istemci';
import type { BenYaniti, KaynakYetkisi, KullaniciOzeti } from '../api/sozlesme';
import { subeAyariniKur } from '../bilesenler/subeAyari';

interface OturumDurumu {
  kullanici: KullaniciOzeti | null;
  aksiyonlar: string[];
  kaynaklar: KaynakYetkisi[];
  yukleniyor: boolean;
  girisYap(kod: string, parola: string, subeId?: number): Promise<void>;
  cikisYap(): Promise<void>;
  subeDegistir(subeId: number): Promise<void>;
  dilDegistir(dil: number): Promise<void>;
  /**
   * Oturumu SUNUCUDAN tazeler (359/364): kurum profili degisince acik modul
   * kumesi de degisir - menu ve rotalar yeniden cizilsin diye kart ekrani
   * kaydettikten sonra bunu cagirir.
   */
  tazele(): Promise<void>;
  /** Kaynak yetkisi: yetki('cari','ekle'). Sunucu da ayrica dogrular - bu yalniz arayuz icin. */
  yetki(kaynak: string, islem?: 'gor' | 'ekle' | 'degistir' | 'sil'): boolean;
  aksiyonVar(kod: string): boolean;
  /**
   * Aksiyonun SAYISAL SINIRI (661): 'basvuru.iskonto' -> iskonto tavani.
   * Yetki yoksa ya da sinir tanimli degilse 0 - "sinirsiz" DEGIL, "yapamaz".
   */
  aksiyonDegeri(kod: string): number;
}

const Baglam = createContext<OturumDurumu | null>(null);

export function OturumSaglayici({ children }: { children: ReactNode }) {
  const [ben, setBen] = useState<BenYaniti | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);

  const benYukle = useCallback(async () => {
    if (!oturum.access) { setBen(null); setYukleniyor(false); return }
    try { setBen(await api.ben()) } catch { oturum.temizle(); setBen(null) }
    finally { setYukleniyor(false) }
  }, []);

  useEffect(() => { void benYukle() }, [benYukle]);

  /* AKTIF SUBENIN YEREL AYARLARI (666): ulke / telefon kodu / saat dilimi /
     para birimi. Bicimlendirici ve dogrulama React agacinin DISINDA saf
     fonksiyon olarak calisiyor - deger modul degiskenine yazilir, oradan
     okunur. Sube degisince (ya da /ben tazelenince) guncellenir. */
  useEffect(() => {
    const k = ben?.kullanici;
    subeAyariniKur(k?.subeler.find(s => s.id === k?.subeId) ?? k?.subeler[0]);
  }, [ben]);

  const deger = useMemo<OturumDurumu>(() => ({
    kullanici: ben?.kullanici ?? null,
    aksiyonlar: ben?.aksiyonlar ?? [],
    kaynaklar: ben?.kaynaklar ?? [],
    yukleniyor,

    async girisYap(kod, parola, subeId) {
      const yanit = await api.giris(kod, parola, subeId);
      oturum.yaz(yanit);
      setBen(await api.ben());
    },

    async cikisYap() { await api.cikis(); setBen(null) },

    async subeDegistir(subeId) {
      const yanit = await api.subeSec(subeId);
      oturum.yaz(yanit);
      oturum.subeYaz(subeId);
      setBen(await api.ben());
    },

    async dilDegistir(dil) {
      await api.dilDegistir(dil);
      setBen(await api.ben());
    },

    async tazele() { setBen(await api.ben()) },

    yetki(kaynak, islem = 'gor') {
      const k = ben?.kaynaklar.find(x => x.kod === kaynak);
      return k ? k[islem] : false;
    },

    aksiyonVar(kod) { return ben?.aksiyonlar.includes(kod) ?? false },

    aksiyonDegeri(kod) { return ben?.aksiyonDegerleri?.[kod] ?? 0 },
  }), [ben, yukleniyor]);

  return <Baglam.Provider value={deger}>{children}</Baglam.Provider>;
}

export function useOturum() {
  const b = useContext(Baglam);
  if (!b) throw new Error('useOturum, OturumSaglayici icinde kullanilmali.');
  return b;
}
