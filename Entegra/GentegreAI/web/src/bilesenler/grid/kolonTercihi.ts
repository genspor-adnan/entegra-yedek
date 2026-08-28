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

function sakla(kaynak: string, adlar: string[]) {
  try { localStorage.setItem(anahtar(kaynak), JSON.stringify(adlar)) }
  catch { /* gizli sekme: tercih saklanmaz, ekran calisir */ }
}

function oku(kaynak: string): string[] | null {
  try {
    const ham = localStorage.getItem(anahtar(kaynak));
    return ham ? JSON.parse(ham) as string[] : null;
  } catch { return null }
}

export function useKolonTercihi({ kaynak, gizliKolonlar, kolonSirasi, setHata }: {
  kaynak: string;
  gizliKolonlar?: string[];
  kolonSirasi?: string[];
  setHata(mesaj: string): void;
}) {
  /** Gosterilen kolonlar - kullanicinin sirasiyla. */
  const [kolonlar, setKolonlar] = useState<KolonMeta[]>([]);
  /** Katalogdaki tum kolonlar (menude gizliler de listelenir). */
  const [tumKolonlar, setTumKolonlar] = useState<KolonMeta[]>([]);

  useEffect(() => {
    let iptal = false;
    api.kolonlar(kaynak)
      .then(y => {
        if (iptal) return;
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
          const secilenler = secim
            .map(ad => bul.get(ad))
            .filter((k): k is KolonMeta => !!k && !gizli.has(k.ad));
          // `kolonSirasi` verilen ekranda o kolonlar HER ZAMAN en solda ve o
          //   sirada: tercih ayni kaynagi paylasan baska listede kaydedilmis
          //   olabilir (belge tercihi fatura ekranindan) - teklifin Temsilci /
          //   Durumu / Belge No uclusu yoksa hic gorunmez, sirasi da kayardi.
          //   Kalan kolonlar kullanicinin kendi sirasinda arkadan gelir.
          const bastakiler = (kolonSirasi ?? [])
            .map(ad => bul.get(ad))
            .filter((k): k is KolonMeta => !!k && !gizli.has(k.ad));
          const kalanlar = secilenler.filter(k => !zorunlu.has(k.ad));
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
    sakla(kaynak, yeni.map(k => k.ad));
  };

  /** Kolon gorunurlugu: yeni kolon SONA eklenir, kullanicinin sirasi korunur. */
  const kolonDegistir = (kolon: KolonMeta) => {
    const varMi = kolonlar.some(k => k.ad === kolon.ad);
    const yeni = varMi ? kolonlar.filter(k => k.ad !== kolon.ad) : [...kolonlar, kolon];
    if (yeni.length === 0) return;                 // en az bir kolon kalsin
    setKolonlar(yeni);
    sakla(kaynak, yeni.map(k => k.ad));
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
