import { useEffect, useMemo, useState } from 'react';
import { altAgac as altAgacHesapla } from './kategoriAgaci';
import { api } from '../api/istemci';
import { guvenli } from './mesaj';

/**
 * KATEGORİ SÜZGECİ (kullanıcı: "hizmet listesinde Aktif/Pasif/Tümü'nün sağına
 * kategori combo ağacı gelsin, seçime göre filtre olsun").
 *
 * Combo AĞACI girintiyle gösterir (kök > alt > alt); seçilen dal ALT AĞACIYLA
 * BİRLİKTE süzer - "Radyoloji" seçen kullanıcı yalnız doğrudan köke bağlı
 * hizmetleri değil, MR/BT/US altındakileri de görmek ister.
 *
 * Süzgeç `icinde` koşuluyla gider: dalın tüm alt id'leri tek sorguda.
 */
type Kategori = { id: number; ad: string; ustId: number | null; tur: number;
                  /** 0 = kurum profilinde kapatildi (527) - agacta gorunmez. */
                  aktif: number };

/** Ağaç başlıkları - iki tür birden istendiğinde optgroup etiketi olur. */
const TUR_ADI: Record<number, string> = { 1: 'Stok', 2: 'Hizmet' };

export function KategoriSuzgeci({ tur, deger, onDegis, sinirla, baslik }: {
  /** 1 stok · 2 hizmet (346) - hangi ağaç gösterilecek. Dizi = iki ağaç birden. */
  tur: number | readonly number[];
  deger: number | null;
  onDegis(id: number | null, altlarDahil: number[]): void;
  /**
   * YALNIZ BU KATEGORİLER (ve üstleri) listelensin. Fiyat listesi kartında
   * (kullanıcı) satırlarda hiç geçmeyen dallar, seçilince boş grid veren
   * yüzlerce seçenek üretiyordu.
   */
  sinirla?: ReadonlySet<number>;
  /** Boş seçeneğin metni; varsayılan "Tüm Kategoriler". */
  baslik?: string;
}) {
  const [kayitlar, setKayitlar] = useState<Kategori[]>([]);
  const turler = useMemo(() => (Array.isArray(tur) ? [...tur] : [tur as number]), [tur]);
  // Dizi her cizimde yeni referans: efekt ICERIGE bagli olmali.
  const turAnahtari = turler.join(',');

  useEffect(() => {
    void guvenli(async () => {
      const y = await api.liste('kategori', { sayfa: 1, boyut: 1000 });
      setKayitlar((y.satirlar ?? []).map(s => ({
        id: Number(s.id), ad: String(s.ad ?? ''),
        ustId: s.ustId === null || s.ustId === undefined ? null : Number(s.ustId),
        tur: Number(s.tur ?? 1),
        aktif: Number(s.aktif ?? 1),
      }))
        // PASIF KATEGORI AGACA GIRMEZ (531, kullanici: "profilden
        //   kaldirdigim kategoriler hem kategori agaclarina gelmesin hem de
        //   listelere aratinca"). Kurum profilinde kapatilan kategori (527)
        //   o kurumun YAPMADIGI istir; secenek olarak sunmak, secilince bos
        //   sonuc veren bir suzgec uretir.
        .filter(k => k.aktif === 1)
        .filter(k => turler.includes(k.tur)));
    });
  }, [turAnahtari]);

  /** Ağaç sırası: kök -> altları, girinti derinlikle; tür başına bir grup. */
  const gruplar = useMemo(() => {
    // SINIRLA: istenen dallar + ÜSTLERİ - üst olmadan girinti kopar.
    let gorunur = kayitlar;
    if (sinirla) {
      const ustler = new Map(kayitlar.map(k => [k.id, k.ustId]));
      const tut = new Set<number>();
      sinirla.forEach(id => {
        let g: number | null | undefined = id;
        while (g != null && !tut.has(g)) { tut.add(g); g = ustler.get(g) ?? null }
      });
      gorunur = kayitlar.filter(k => tut.has(k.id));
    }

    const cocuk = new Map<number, Kategori[]>();
    gorunur.forEach(k => {
      const ust = k.ustId ?? 0;
      cocuk.set(ust, [...(cocuk.get(ust) ?? []), k]);
    });
    cocuk.forEach(liste => liste.sort((a, b) => a.ad.localeCompare(b.ad, 'tr')));

    const gez = (ustId: number, derinlik: number,
                 sonuc: { id: number; etiket: string }[]) => {
      (cocuk.get(ustId) ?? []).forEach(k => {
        sonuc.push({ id: k.id, etiket: `${'  '.repeat(derinlik)}${derinlik > 0 ? '└ ' : ''}${k.ad}` });
        gez(k.id, derinlik + 1, sonuc);
      });
    };
    return turler.map(t => {
      const sonuc: { id: number; etiket: string }[] = [];
      // Kok = ust'u olmayan ya da ustu (tur suzmesi yuzunden) listede olmayan dal.
      const idler = new Set(gorunur.map(k => k.id));
      gorunur.filter(k => k.tur === t && (k.ustId == null || !idler.has(k.ustId)))
        .sort((a, b) => a.ad.localeCompare(b.ad, 'tr'))
        .forEach(k => {
          sonuc.push({ id: k.id, etiket: k.ad });
          gez(k.id, 1, sonuc);
        });
      return { tur: t, ad: TUR_ADI[t] ?? '', secenekler: sonuc };
    }).filter(g => g.secenekler.length > 0);
  }, [kayitlar, sinirla, turAnahtari]);


  return (
    <select className="kat-suzgec" value={deger === null ? '' : String(deger)}
            title="Kategoriye göre süz (alt kategoriler dâhil)"
            onChange={e => {
              const v = e.target.value;
              if (v === '') { onDegis(null, []); return }
              const id = Number(v);
              onDegis(id, altAgacHesapla(id, kayitlar));
            }}>
      <option value="">{baslik ?? 'Tüm Kategoriler'}</option>
      {/* Tek ağaçta grup başlığı gürültü; iki ağaç birden çizilirken
          "Stok" / "Hizmet" ayrımı şart. */}
      {gruplar.length === 1
        ? gruplar[0].secenekler.map(s => <option key={s.id} value={s.id}>{s.etiket}</option>)
        : gruplar.map(g => (
            <optgroup key={g.tur} label={g.ad}>
              {g.secenekler.map(s => <option key={s.id} value={s.id}>{s.etiket}</option>)}
            </optgroup>
          ))}
    </select>
  );
}
