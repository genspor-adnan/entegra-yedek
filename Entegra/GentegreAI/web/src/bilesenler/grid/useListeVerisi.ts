import { useCallback, useEffect, useRef, useState } from 'react';
import { c as cev } from '../../dil/ceviri';
import { api } from '../../api/istemci';
import { type KolonMeta, type Kosul, type ListeSatiri, type ListeYaniti,
         type Siralama, hataMetni } from '../../api/sozlesme';
import { bicimle, bugunIso } from '../bicim';
import { csvMetni, CSV_TIPI } from '../csv';
import { dosyaIndir, dosyaAdiTemiz } from '../indir';
import { aramaKosulu, tarihKosulu, filtreBirlestir } from '../gridSorgu';

/** Ust seritteki durum cipi (Aktif / Pasif / Tümü...). */
interface Cip { ad: string; filtre?: Kosul }

export interface ListeVerisiGirdisi {
  kaynak: string;
  /** Ekran basligi - CSV dosya adinda kullanilir. */
  baslik?: string;
  kolonlar: KolonMeta[];
  sabitFiltre?: Kosul;
  /** Toplami istenen kolonlar (sunucu hesaplar). */
  toplam?: string[];
  sayfaBoyu: number;
  cipler?: Cip[];
  cipIndeks: number;
  kodSuzgeci?: { alan: string };
  kodSuzgecDeger: string;
  tarihAlani?: string;
  tarihBas: string;
  tarihBit: string;
  varsayilanGrup?: string;
  /** Kart kaydedilince disaridan artirilan sayac - grid yeniden yuklenir. */
  yenile?: number;
  /** Yeni kayit EKLENINCE "Son Aranan" gorunumune gec. */
  odaklaSonEklenen?: number;
  /** Filtre satiri kosulu - durumu bilesende yasadigi icin disaridan gelir. */
  filtreSatiriFiltresi(): Kosul | undefined;
}

/**
 * LISTE VERISI: sunucudan satirlari cekme, sayfalama, siralama, arama ve
 * disa aktarma.
 *
 * `GenGrid` govdesinin yarisi bu isti: on uc durum, `yukle`, CSV disa aktarma
 * ve uc tazeleme etkisi. Kosul kurma SAF fonksiyonlarda (gridSorgu) - listeleme
 * ve disa aktarma AYNI mantigi kullansin diye tek yerde.
 */
export function useListeVerisi(g: ListeVerisiGirdisi) {
  const { kaynak, baslik, kolonlar, sabitFiltre, toplam, sayfaBoyu, cipler,
          cipIndeks, kodSuzgeci, kodSuzgecDeger, tarihAlani, tarihBas, tarihBit,
          varsayilanGrup, yenile, odaklaSonEklenen, filtreSatiriFiltresi } = g;

  const [satirlar, setSatirlar] = useState<ListeSatiri[]>([]);
  const [toplamKayit, setToplamKayit] = useState(0);
  const [toplamlar, setToplamlar] = useState<Record<string, unknown> | undefined>();
  /** Gruplu liste (ekstre): para birimi basina ozet - sunucudan, TUM kume icin. */
  const [gruplar, setGruplar] = useState<ListeYaniti['gruplar']>();
  /** Satirlarin hangi kolona gore obeklendigi (sunucudan; yoksa gruplama yok). */
  const [grupKolonu, setGrupKolonu] = useState<string | null>(null);
  const [sayfa, setSayfa] = useState(1);
  // GRUPLANAN KOLON AYNI ZAMANDA ILK SIRALAMA (492): siralanmazsa ayni grubun
  //   satirlari listeye dagilir ve baslik defalarca cizilir - bolume gore
  //   grupladiktan sonra "Biyokimya" basligi dort kez gorunuyordu.
  const [sirala, setSirala] = useState<Siralama[]>(
    varsayilanGrup ? [{ alan: varsayilanGrup, yon: 'asc' as const }] : []);
  const [arama, setArama] = useState('');
  // "Tum Liste / Son Aranan / Sik Aranan" (eski KULLANICI_ARAMA) - sunucuya
  //   `gorunum` olarak gider, kart acilis/ekleme sikligina gore filtreler+siralar.
  const [aramaGorunumu, setAramaGorunumu] = useState<'tum' | 'son' | 'sik'>('tum');
  const [yukleniyor, setYukleniyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [sureMs, setSureMs] = useState(0);

  const aramaFiltresi = useCallback(
    () => aramaKosulu(arama, kolonlar), [arama, kolonlar]);

  /** Listeleme ve disa aktarmanin ORTAK kosulu - ikisi ayrisamaz. */
  const filtreKur = useCallback(() => filtreBirlestir([
    sabitFiltre, cipler?.[cipIndeks]?.filtre,
    tarihKosulu(tarihAlani, tarihBas, tarihBit),
    kodSuzgeci && kodSuzgecDeger !== ''
      ? { alan: kodSuzgeci.alan, op: 'esit' as const, deger: Number(kodSuzgecDeger) }
      : undefined,
    aramaFiltresi(), filtreSatiriFiltresi(),
  ]), [sabitFiltre, cipler, cipIndeks, tarihAlani, tarihBas, tarihBit,
       kodSuzgeci, kodSuzgecDeger, aramaFiltresi, filtreSatiriFiltresi]);

  const yukle = useCallback(async () => {
    if (kolonlar.length === 0) return;
    setYukleniyor(true);
    setHata(null);
    try {
      const filtre = filtreKur();
      const gorunum = aramaGorunumu === 'tum' ? undefined : aramaGorunumu;
      const yanit = await api.liste(kaynak,
        { sayfa, boyut: sayfaBoyu, sirala, filtre, toplam, gorunum });
      setSatirlar(yanit.satirlar);
      setToplamKayit(yanit.toplamKayit);
      setToplamlar(yanit.toplamlar);
      setGruplar(yanit.gruplar);
      setGrupKolonu(yanit.grupKolonu ?? null);
      setSureMs(yanit.sureMs);
    } catch (h) {
      setHata(hataMetni(h, true));
      setSatirlar([]);
    } finally {
      setYukleniyor(false);
    }
  }, [kaynak, sayfa, sayfaBoyu, sirala, toplam, kolonlar.length, aramaGorunumu, filtreKur]);

  useEffect(() => { void yukle() }, [yukle]);

  // "yenile"/"odaklaSonEklenen" Liste.tsx'te YASIYOR (kaynak degisince
  //   sifirlanmiyor) - GenGrid kaynak degisince "key" ile yeniden kurulunca bu
  //   prop'lar eski sayimla gelir. "Onceki deger" ref'iyle karsilastirip GERCEK
  //   degisimde tetikliyoruz - ilk mount'ta ref zaten ayni degerle baslar,
  //   calismaz. Basit bir "ilk calisti mi" bool bayragi StrictMode'da KIRILIR
  //   (efektler dev'de cift calisir, ikinci calismada bayrak zaten false olur
  //   ve yanlislikla tetiklenir) - deger karsilastirmasi tekrar calismaya karsi
  //   dogal olarak baglisiktir (idempotent).
  const yenileOnceki = useRef(yenile);
  useEffect(() => {
    if (yenileOnceki.current === yenile) return;
    yenileOnceki.current = yenile;
    if (yenile !== undefined) void yukle();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [yenile]);

  const odaklaOnceki = useRef(odaklaSonEklenen);
  useEffect(() => {
    if (odaklaOnceki.current === odaklaSonEklenen) return;
    odaklaOnceki.current = odaklaSonEklenen;
    if (odaklaSonEklenen === undefined) return;
    setSayfa(1);
    setAramaGorunumu('son');
  }, [odaklaSonEklenen]);

  // Arama yazarken her tusa istek atilmaz (Delphi tarafindaki debounce deseni).
  const aramaZamanlayici = useRef<number | undefined>(undefined);
  const aramaDegisti = (deger: string) => {
    window.clearTimeout(aramaZamanlayici.current);
    aramaZamanlayici.current = window.setTimeout(() => { setSayfa(1); setArama(deger) }, 350);
  };

  const csvIndir = useCallback(async () => {
    setYukleniyor(true);
    try {
      // Listeleme ile AYNI kosullar (gridSorgu): disa aktarilan ne gorunuyorsa odur.
      const filtre = filtreKur();
      const gorunum = aramaGorunumu === 'tum' ? undefined : aramaGorunumu;
      const tumu: ListeSatiri[] = [];
      for (let sf = 1; sf <= 20; sf++) {
        const y = await api.liste(kaynak, { sayfa: sf, boyut: 500, sirala, filtre, gorunum });
        tumu.push(...y.satirlar);
        if (tumu.length >= y.toplamKayit || y.satirlar.length === 0) break;
      }

      const metin = csvMetni(
        kolonlar.map(k => cev(k.baslik)),
        tumu.map(r => kolonlar.map(k => bicimle(r[k.ad], k))));
      dosyaIndir(metin, `${dosyaAdiTemiz(baslik ?? kaynak)}-${bugunIso()}.csv`, CSV_TIPI);
    } catch (h) {
      setHata(hataMetni(h));
    } finally { setYukleniyor(false) }
  }, [kaynak, baslik, kolonlar, sirala, aramaGorunumu, filtreKur]);

  const siralamaDegistir = (kolon: KolonMeta) => {
    if (!kolon.siralanabilir) return;
    setSirala(onceki => {
      const mevcut = onceki.find(s => s.alan === kolon.ad);
      if (!mevcut) return [{ alan: kolon.ad, yon: 'asc' }];
      if (mevcut.yon === 'asc') return [{ alan: kolon.ad, yon: 'desc' }];
      return [];
    });
    setSayfa(1);
  };

  const siraIsareti = (ad: string) => {
    const s = sirala.find(x => x.alan === ad);
    return s ? (s.yon === 'asc' ? ' ↑' : ' ↓') : '';
  };

  return { satirlar, toplamKayit, toplamlar, gruplar, grupKolonu,
           sayfa, setSayfa, sirala, setSirala, siralamaDegistir, siraIsareti,
           arama, setArama, aramaDegisti, aramaGorunumu, setAramaGorunumu,
           yukleniyor, setYukleniyor, hata, setHata, sureMs,
           yukle, csvIndir,
           sonSayfa: Math.max(1, Math.ceil(toplamKayit / sayfaBoyu)) };
}
