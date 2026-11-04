import { useMemo } from 'react';
import type { UretimSeviyesi } from '../../api/uclar/uretimFisi';
import { useUretimSeviyesi } from '../../bilesenler/useUretimSeviyesi';
import type { ListeTanimi } from '../listeTanimlari.Ortak';

/**
 * ÜRETİM LİSTELERİ SEVİYEYE GÖRE (1254, mockup uretim_emri_listesi_v2.html / uretim_fisi_listesi.html). Kullanıcı
 * 04.11.2026: "üretim emri ve üretim fişi listelerini bu mockuplara uygun yap".
 *
 * Kayıt yapısı ve sunucu kataloğu TEK; seviye yalnız görüneni değiştirir: hangi kolonlar, hangi cipler, hangi araç
 * düğmeleri. Sunucu bütün kolonları varsayılan görünür döner, burada seviyeye göre gizlenir (kolon seçicide de
 * görünmez). Gizlenen aksiyon YETKİ kuralı değildir - o seviyede anlamsız adımdır (basit / standartta e-imzalı
 * "Serbest Bırak"); yapılabilen ama koşulu tutmayan adım gizlenmez, sunucu sebebini söyler.
 */
export type ListeCipleri = NonNullable<ListeTanimi['cipler']>;

export interface ListeUyarlamasi {
  gizliKolonlar: string[];
  cipler: ListeCipleri;
  gizliAksiyonlar: string[];
}

/** Liste aksiyonundan üst paneldeki pencereye (ImzaPenceresi) geçiş olayları - KONS_ISLEM_OLAYI deseni. */
export const UE_ISLEM_OLAYI = 'gentegre-uretim-emir-islem';
export const UF_ISLEM_OLAYI = 'gentegre-uretim-fis-islem';
export interface UretimIslemOlayi { id: number; islem: 'serbest' | 'ters'; satir?: Record<string, unknown> }

const URETIM_LISTELERI = ['uretim-emri', 'uretim-fisi'];

const EMIR_CIPLERI = (denetimli: boolean): ListeCipleri => [
  { ad: 'Açık',       filtre: { alan: 'durum',   op: 'arasinda', deger: [1, 5] } },
  { ad: 'Taslak',     filtre: { alan: 'durum',   op: 'esit', deger: 1 } },
  { ad: 'Onaylı',     filtre: { alan: 'durum',   op: 'esit', deger: 2 } },
  ...(denetimli ? [{ ad: 'Serbest', filtre: { alan: 'durum', op: 'esit', deger: 3 } as const }] : []),
  { ad: 'Üretimde',   filtre: { alan: 'durum',   op: 'arasinda', deger: [4, 5] } },
  { ad: 'Tamamlandı', filtre: { alan: 'durum',   op: 'arasinda', deger: [6, 7] } },
  { ad: 'Geciken',    filtre: { alan: 'gecikti', op: 'esit', deger: 1 } },
  { ad: 'Tümü' },
];

const EMRE_BAGLI = { ad: 'Emre bağlı', filtre: { alan: 'emirId', op: 'buyuk', deger: 0 } } as const;
const TERS_KAYIT = { ad: 'Ters kayıt', filtre: { alan: 'durum', op: 'esit', deger: 0 } } as const;

const FIS_CIPLERI: Record<UretimSeviyesi, ListeCipleri> = {
  basit: [
    { ad: 'Tümü' },
    { ad: 'Taslak',  filtre: { alan: 'durum', op: 'esit', deger: 1 } },
    { ad: 'İşlenen', filtre: { alan: 'durum', op: 'arasinda', deger: [2, 3] } },
    TERS_KAYIT,
  ],
  standart: [
    { ad: 'Tümü' },
    { ad: 'Taslak',  filtre: { alan: 'durum', op: 'esit', deger: 1 } },
    { ad: 'İşlenen', filtre: { alan: 'durum', op: 'arasinda', deger: [2, 3] } },
    TERS_KAYIT, EMRE_BAGLI,
  ],
  denetimli: [
    { ad: 'Tümü' },
    { ad: 'Taslak',         filtre: { alan: 'durum', op: 'esit', deger: 1 } },
    { ad: 'Kalite bekleyen', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
    { ad: 'Serbest',        filtre: { alan: 'durum', op: 'esit', deger: 3 } },
    { ad: 'Reddedilen',     filtre: { alan: 'durum', op: 'esit', deger: 4 } },
    TERS_KAYIT, EMRE_BAGLI,
  ],
};

/** Emir listesinin standart cipleri - liste tanımının varsayılanı (seviye yüklenene kadar bu çizilir). */
export const EMIR_VARSAYILAN_CIPLER = EMIR_CIPLERI(false);
export const FIS_VARSAYILAN_CIPLER = FIS_CIPLERI.standart;

export function uretimListeUyarlamasi(kaynak: string, seviye: UretimSeviyesi): ListeUyarlamasi | null {
  if (kaynak === 'uretim-emri') {
    // Basit seviyede /uretim-emri rotası iş listesini çizer (UretimEmirleriBasit); generic liste yalnız kart adresinden
    //   açılırsa görünür - o da sade kalsın.
    if (seviye === 'basit') return {
      gizliKolonlar: ['turAdi', 'agacAd', 'kaynakBelgeNo', 'planBas', 'kaliteOnayli', 'karantinaAdet', 'onKontrol', 'gercekToplam'],
      cipler: EMIR_CIPLERI(false),
      gizliAksiyonlar: ['uretim.rezerve', 'uretim.eksik', 'uretim.onayla', 'uretim.serbest-birak', 'uretim.baslat', 'uretim.sarf',
                        'uretim.mamul-giris', 'uretim.fire', 'uretim.agactan-yenile', 'uretim.maliyet-kapat', 'uretim.kapat'],
    };
    if (seviye === 'standart') return {
      gizliKolonlar: ['kaliteOnayli', 'karantinaAdet', 'onKontrol'],
      cipler: EMIR_CIPLERI(false),
      gizliAksiyonlar: ['uretim.serbest-birak'],
    };
    return { gizliKolonlar: [], cipler: EMIR_CIPLERI(true), gizliAksiyonlar: [] };
  }
  if (kaynak === 'uretim-fisi') {
    if (seviye === 'basit') return {
      gizliKolonlar: ['planMiktar', 'girisDepo', 'sorumlu', 'emirNo', 'partiNo', 'kalite'],
      cipler: FIS_CIPLERI.basit,
      gizliAksiyonlar: ['uretim-fisi.gerceklestir', 'uretim-fisi.serbest', 'uretim-fisi.ters-kayit', 'uretim-fisi.emir-ac'],
    };
    if (seviye === 'standart') return {
      gizliKolonlar: ['partiNo', 'kalite'],
      cipler: FIS_CIPLERI.standart,
      gizliAksiyonlar: ['uretim-fisi.serbest', 'uretim-fisi.ters-kayit'],
    };
    // Denetimli: Sil yerine gerekçeli Ters Kayıt (taslağı da o siler).
    return { gizliKolonlar: [], cipler: FIS_CIPLERI.denetimli, gizliAksiyonlar: ['uretim-fisi.sil'] };
  }
  return null;
}

/**
 * Liste.tsx kancası: üretim dışı listede istek atmaz ve null döner; üretim listesinde seviye yüklenene kadar da null
 * (liste tanımındaki standart cipler çizilir, cip indeksi 0 iki kümede de aynı anlamda).
 */
export function useUretimListeUyarlamasi(kaynak: string): ListeUyarlamasi | null {
  const etkin = URETIM_LISTELERI.includes(kaynak);
  const sv = useUretimSeviyesi(etkin);
  return useMemo(() => (etkin && sv.yuklendi ? uretimListeUyarlamasi(kaynak, sv.seviye) : null), [etkin, kaynak, sv.yuklendi, sv.seviye]);
}

/** Üst panel kutusu → cip: adıyla bulur (seviyeye göre cip kümesi değişir, sabit indeks yalan söylerdi). */
export function cipIndeksi(cipler: ListeCipleri, ad: string): number | null {
  const i = cipler.findIndex(x => x.ad === ad);
  return i < 0 ? null : i;
}
