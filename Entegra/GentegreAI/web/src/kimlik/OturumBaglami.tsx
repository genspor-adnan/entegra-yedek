import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { api, oturum } from '../api/istemci';
import { OTURUM_TAZELE_OLAYI } from '../api/cekirdek';
import { ApiHatasi, type BenYaniti, type KaynakYetkisi, type KullaniciOzeti } from '../api/sozlesme';
import { subeAyariniKur } from '../bilesenler/subeAyari';
import { sonKullaniciYaz } from './sonKullanici';

/** /ben bu surede donmezse gecici hata sayilir (sonsuz "Yukleniyor" yok). */
const BEN_ZAMAN_ASIMI_MS = 15000;

/**
 * /ben HATASININ SINIFI (denetim 28.09.2026 #11). Eskiden HER hata
 * `oturum.temizle()` idi: sunucu yeniden baslarken (502/503) ya da ag
 * koptugunda acik oturum silinir, kullanici giris ekranina duserdi.
 *  - `kesin`   : sunucu kimligi REDDETTI (401 ve refresh de gecersiz) - temizle.
 *  - `gecici`  : ag, zaman asimi, 5xx, yenilenemeyen 401 - token KORUNUR,
 *                "yeniden dene" gosterilir; korumali ekran ACILMAZ.
 *  - `sube`    : saklanan sube artik yetkili degil (403) - sube secimi
 *                silinip bir kez daha denenir; oturum kapanmaz.
 */
export function benHatasiSinifi(h: unknown, refreshVar: boolean): 'kesin' | 'gecici' | 'sube' {
  if (h instanceof ApiHatasi) {
    // 401: cekirdek once refresh'i denedi. Refresh SILINDIYSE sunucu
    //   reddetmistir (kesin); duruyorsa yenileme gecici hatadan dondu.
    if (h.durum === 401) return refreshVar ? 'gecici' : 'kesin';
    if (h.durum === 403 && h.hata.kod === 'YASAK') return 'sube';
    if (h.durum >= 500) return 'gecici';
    // 400/404/422: /ben icin beklenmez; oturumu silmek icin sebep degil.
    return 'gecici';
  }
  return 'gecici';   // fetch TypeError (ag), zaman asimi
}

interface OturumDurumu {
  kullanici: KullaniciOzeti | null;
  aksiyonlar: string[];
  kaynaklar: KaynakYetkisi[];
  yukleniyor: boolean;
  /**
   * Profil GECICI bir hatayla okunamadi (token'lar duruyor). Doluyken ne
   * giris ekrani ne korumali ekran cizilir - "yeniden dene" gosterilir.
   */
  oturumHatasi: string | null;
  /** /ben'i yeniden dener (kullanici dugmesi). */
  yenidenDene(): Promise<void>;
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
  const [oturumHatasi, setOturumHatasi] = useState<string | null>(null);

  const benYukle = useCallback(async () => {
    if (!oturum.access) { setBen(null); setOturumHatasi(null); setYukleniyor(false); return }
    // Sube hatasinda bir kez, saklanan sube OLMADAN tekrar denenir - dongu yok.
    for (let deneme = 0; deneme < 2; deneme++) {
      try {
        let zamanlayici: ReturnType<typeof setTimeout> | undefined;
        const zamanAsimi = new Promise<never>((_, red) => {
          zamanlayici = setTimeout(() => red(new Error('zaman asimi')), BEN_ZAMAN_ASIMI_MS);
        });
        try { setBen(await Promise.race([api.ben(), zamanAsimi])) }
        finally { clearTimeout(zamanlayici) }
        setOturumHatasi(null);
        break;
      } catch (h) {
        const sinif = benHatasiSinifi(h, !!oturum.refresh);
        if (sinif === 'sube' && deneme === 0 && oturum.subeId) {
          oturum.subeSil();
          continue;
        }
        if (sinif === 'kesin') { oturum.temizle(); setBen(null); setOturumHatasi(null) }
        else setOturumHatasi(h instanceof ApiHatasi ? h.message : 'Sunucuya ulaşılamadı.');
        break;
      }
    }
    setYukleniyor(false);
  }, []);

  useEffect(() => { void benYukle() }, [benYukle]);

  // Sunucu "hesap durumu degisti" dedi (PAROLA_DEGISMELI): profili tazele.
  useEffect(() => {
    const dinle = () => { void benYukle() };
    window.addEventListener(OTURUM_TAZELE_OLAYI, dinle);
    return () => window.removeEventListener(OTURUM_TAZELE_OLAYI, dinle);
  }, [benYukle]);

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
    oturumHatasi,

    async yenidenDene() { setYukleniyor(true); await benYukle() },

    async girisYap(kod, parola, subeId) {
      const yanit = await api.giris(kod, parola, subeId);
      oturum.yaz(yanit);
      // SON KULLANICI (kullanici 09.10.2026: "login de son girdigim user name
      //   default gelsin"): yalniz BASARILI giristen sonra - yanlis yazilan
      //   kod bir sonraki acilisa tasinmasin. Parola saklanmaz.
      sonKullaniciYaz(kod);
      setBen(await api.ben());
    },

    async cikisYap() { await api.cikis(); setBen(null); setOturumHatasi(null) },

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
  }), [ben, yukleniyor, oturumHatasi, benYukle]);

  return <Baglam.Provider value={deger}>{children}</Baglam.Provider>;
}

export function useOturum() {
  const b = useContext(Baglam);
  if (!b) throw new Error('useOturum, OturumSaglayici icinde kullanilmali.');
  return b;
}
