import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import type { ApiHatasi, KolonMeta } from '../../api/sozlesme';

/**
 * GRID KOLON TERCIHI - hangi kolon gorunur ve hangi sirada.
 *
 * Uc kaynak var, oncelik sirasiyla:
 *   1) KULLANICI secimi (uc nokta > Kolonlar / ↑ ↓) - tarayicida kaynak basina,
 *   2) EKRAN istegi (`kolonSirasi` prop'u) - "temsilci solda olsun",
 *   3) KATALOG varsayilani (`kolon.varsayilan`).
 *
 * Kullanici secimi varsa ekran sirasi UYGULANMAZ: kullanici kolonlari eliyle
 * tasidiktan sonra ekranin sirasi geri gelirse tasima yok sayilmis olur.
 */
const anahtar = (kaynak: string) => `grid.kolon.${kaynak}`;

/**
 * Saklanan tercih: kullanicinin GORDUGU kolonlar + tercih kaydedildigi andaki
 * KATALOG VARSAYILANLARI.
 *
 * Ikincisi olmadan katalogda sonradan eklenen bir kolon EKRANA HIC GELMIYORDU:
 * saklanan liste her seyi belirledigi icin, yeni kolon (ör. fiyat listesinde
 * "Tarife", 518'de geldi) tercihi olan kullanicida sonsuza dek gizli kaliyordu.
 * Varsayilan kumeyi de saklayinca "kullanici bunu ELIYLE gizledi" ile "bu kolon
 * o zaman daha YOKTU" birbirinden ayrilabiliyor.
 */
interface KolonTercihi { adlar: string[]; varsayilanlar: string[] }

function sakla(kaynak: string, adlar: string[], varsayilanlar: string[]) {
  try {
    localStorage.setItem(anahtar(kaynak),
      JSON.stringify({ adlar, varsayilanlar } satisfies KolonTercihi));
  } catch { /* gizli sekme: tercih saklanmaz, ekran calisir */ }
}

function oku(kaynak: string): KolonTercihi | null {
  try {
    const ham = localStorage.getItem(anahtar(kaynak));
    if (!ham) return null;
    const c = JSON.parse(ham) as string[] | KolonTercihi;
    // ESKI BICIM (duz dizi): varsayilan kumesi bilinmiyor. O tercihte adi
    //   gecmeyen her varsayilan kolon "sonradan eklenmis" sayilir - bir
    //   kereligine geri gelir, kullanici yine gizlerse yeni bicimde saklanir.
    return Array.isArray(c) ? { adlar: c, varsayilanlar: c } : c;
  } catch { return null }
}

export function useKolonTercihi({ kaynak, gizliKolonlar, kolonSirasi,
                                 kolonBasliklari, setHata }: {
  kaynak: string;
  gizliKolonlar?: string[];
  kolonSirasi?: string[];
  /**
   * EKRANA OZEL kolon basligi (kullanici: basvuruda "Belge No" degil
   * "Protokol No"). Ayni kaynagi 13 liste paylasiyor - katalogdaki basligi
   * degistirmek hepsini birden degistirirdi. Yalniz GORUNEN metin degisir;
   * kolon anahtari, kolon tercihi ve filtreler ayni kalir.
   */
  kolonBasliklari?: Record<string, string>;
  setHata(mesaj: string): void;
}) {
  /** Gosterilen kolonlar - kullanicinin sirasiyla. */
  const [kolonlar, setKolonlar] = useState<KolonMeta[]>([]);
  /** Katalogdaki tum kolonlar (menude gizliler de listelenir). */
  const [tumKolonlar, setTumKolonlar] = useState<KolonMeta[]>([]);

  useEffect(() => {
    let iptal = false;
    api.kolonlar(kaynak)
      .then(ham => {
        if (iptal) return;
        // Ekran basliklari kolonlar dagitilmadan ONCE uygulanir: grid, kolon
        //   menusu ve disa aktarim ayni metni gorsun.
        const y = kolonBasliklari
          ? { ...ham, kolonlar: ham.kolonlar.map(k =>
              kolonBasliklari[k.ad] ? { ...k, baslik: kolonBasliklari[k.ad] } : k) }
          : ham;
        const gizli = new Set(gizliKolonlar ?? []);
        // kolonSirasi'nda ADI GECEN kolon, katalogda varsayilan olmasa bile
        //   gosterilir: ekran "temsilci solda olsun" diyorsa once GORUNMELI.
        const zorunlu = new Set(kolonSirasi ?? []);
        const gorunen = y.kolonlar.filter(k =>
          (k.varsayilan || zorunlu.has(k.ad)) && !gizli.has(k.ad));
        setTumKolonlar(y.kolonlar.filter(k => !gizli.has(k.ad)));

        const secim = oku(kaynak);
        if (secim) {
          // SIRAYI SECIM BELIRLER: `filter` katalog sirasini korur ve kullanicinin
          //   ↑/↓ ile yaptigi tasima sayfa yenilenince kaybolurdu - saklanan
          //   dizinin sirasiyla eslestiriyoruz.
          const bul = new Map(y.kolonlar.map(k => [k.ad, k]));
          const secilenler = secim.adlar
            .map(ad => bul.get(ad))
            .filter((k): k is KolonMeta => !!k && !gizli.has(k.ad));
          // TERCIHTEN SONRA EKLENEN VARSAYILAN KOLONLAR: kullanicinin
          //   gizledikleri gizli kalir, yenisi sona eklenir.
          const eskiVarsayilan = new Set(secim.varsayilanlar);
          const yeniler = y.kolonlar.filter(k =>
            k.varsayilan && !gizli.has(k.ad)
            && !eskiVarsayilan.has(k.ad) && !secim.adlar.includes(k.ad));
          // `kolonSirasi` verilen ekranda o kolonlar HER ZAMAN en solda ve o
          //   sirada: tercih ayni kaynagi paylasan baska listede kaydedilmis
          //   olabilir (belge tercihi fatura ekranindan) - teklifin Temsilci /
          //   Durumu / Belge No uclusu yoksa hic gorunmez, sirasi da kayardi.
          //   Kalan kolonlar kullanicinin kendi sirasinda arkadan gelir.
          const bastakiler = (kolonSirasi ?? [])
            .map(ad => bul.get(ad))
            .filter((k): k is KolonMeta => !!k && !gizli.has(k.ad));
          const kalanlar = [...secilenler, ...yeniler].filter(k => !zorunlu.has(k.ad));
          // Secim tumuyle gecersizse (kolonlar yeniden adlandirilmis) varsayilana don.
          setKolonlar(secilenler.length ? [...bastakiler, ...kalanlar] : gorunen);
          return;
        }
        // Ekran sirasi: listede adi gecen kolonlar SOLDA ve verilen sirada.
        const sira = (ad: string) => {
          const i = kolonSirasi?.indexOf(ad) ?? -1;
          return i < 0 ? 900 : i;
        };
        setKolonlar(kolonSirasi?.length
          ? [...gorunen].sort((a, b) => sira(a.ad) - sira(b.ad))
          : gorunen);
      })
      .catch((h: ApiHatasi) => { if (!iptal) setHata(h.message) });
    return () => { iptal = true };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [kaynak]);

  /** Katalogun BUGUNKU varsayilan kolonlari - tercihle birlikte saklanir. */
  const varsayilanAdlar = () => tumKolonlar.filter(k => k.varsayilan).map(k => k.ad);

  /**
   * KOLON YERINI DEGISTIR (uc nokta > ↑ ↓). Gorunur kolonlar arasinda tasir;
   * sunucudaki katalog sirasi bozulmaz - bu yalniz KULLANICININ ekranidir.
   */
  const kolonTasi = (ad: string, yon: -1 | 1) => {
    const i = kolonlar.findIndex(k => k.ad === ad);
    const j = i + yon;
    if (i < 0 || j < 0 || j >= kolonlar.length) return;
    const yeni = [...kolonlar];
    [yeni[i], yeni[j]] = [yeni[j], yeni[i]];
    setKolonlar(yeni);
    sakla(kaynak, yeni.map(k => k.ad), varsayilanAdlar());
  };

  /** Kolon gorunurlugu: yeni kolon SONA eklenir, kullanicinin sirasi korunur. */
  const kolonDegistir = (kolon: KolonMeta) => {
    const varMi = kolonlar.some(k => k.ad === kolon.ad);
    const yeni = varMi ? kolonlar.filter(k => k.ad !== kolon.ad) : [...kolonlar, kolon];
    if (yeni.length === 0) return;                 // en az bir kolon kalsin
    setKolonlar(yeni);
    sakla(kaynak, yeni.map(k => k.ad), varsayilanAdlar());
  };

  const kolonlariSifirla = () => {
    try { localStorage.removeItem(anahtar(kaynak)) } catch { /* yoksay */ }
    const gizli = new Set(gizliKolonlar ?? []);
    const zorunlu = new Set(kolonSirasi ?? []);
    setKolonlar(tumKolonlar.filter(k =>
      (k.varsayilan || zorunlu.has(k.ad)) && !gizli.has(k.ad)));
  };

  return { kolonlar, tumKolonlar, kolonTasi, kolonDegistir, kolonlariSifirla };
}
