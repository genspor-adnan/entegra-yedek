import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { api, oturum } from '../api/istemci';
import type { BenYaniti, KaynakYetkisi, KullaniciOzeti } from '../api/sozlesme';

interface OturumDurumu {
  kullanici: KullaniciOzeti | null;
  aksiyonlar: string[];
  kaynaklar: KaynakYetkisi[];
  yukleniyor: boolean;
  girisYap(kod: string, parola: string, subeId?: number): Promise<void>;
  cikisYap(): Promise<void>;
  subeDegistir(subeId: number): Promise<void>;
  dilDegistir(dil: number): Promise<void>;
  /** Kaynak yetkisi: yetki('cari','ekle'). Sunucu da ayrica dogrular - bu yalniz arayuz icin. */
  yetki(kaynak: string, islem?: 'gor' | 'ekle' | 'degistir' | 'sil'): boolean;
  aksiyonVar(kod: string): boolean;
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

    yetki(kaynak, islem = 'gor') {
      const k = ben?.kaynaklar.find(x => x.kod === kaynak);
      return k ? k[islem] : false;
    },

    aksiyonVar(kod) { return ben?.aksiyonlar.includes(kod) ?? false },
  }), [ben, yukleniyor]);

  return <Baglam.Provider value={deger}>{children}</Baglam.Provider>;
}

export function useOturum() {
  const b = useContext(Baglam);
  if (!b) throw new Error('useOturum, OturumSaglayici icinde kullanilmali.');
  return b;
}
