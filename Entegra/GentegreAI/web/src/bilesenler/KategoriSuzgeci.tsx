import { useEffect, useMemo, useState } from 'react';
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
type Kategori = { id: number; ad: string; ustId: number | null; tur: number };

export function KategoriSuzgeci({ tur, deger, onDegis }: {
  /** 1 stok · 2 hizmet (346) - hangi ağaç gösterilecek. */
  tur: number;
  deger: number | null;
  onDegis(id: number | null, altlarDahil: number[]): void;
}) {
  const [kayitlar, setKayitlar] = useState<Kategori[]>([]);

  useEffect(() => {
    void guvenli(async () => {
      const y = await api.liste('kategori', { sayfa: 1, boyut: 1000 });
      setKayitlar((y.satirlar ?? []).map(s => ({
        id: Number(s.id), ad: String(s.ad ?? ''),
        ustId: s.ustId === null || s.ustId === undefined ? null : Number(s.ustId),
        tur: Number(s.tur ?? 1),
      })).filter(k => k.tur === tur));
    });
  }, [tur]);

  /** Ağaç sırası: kök -> altları, girinti derinlikle. */
  const secenekler = useMemo(() => {
    const cocuk = new Map<number, Kategori[]>();
    kayitlar.forEach(k => {
      const ust = k.ustId ?? 0;
      cocuk.set(ust, [...(cocuk.get(ust) ?? []), k]);
    });
    cocuk.forEach(liste => liste.sort((a, b) => a.ad.localeCompare(b.ad, 'tr')));

    const sonuc: { id: number; etiket: string }[] = [];
    const gez = (ustId: number, derinlik: number) => {
      (cocuk.get(ustId) ?? []).forEach(k => {
        sonuc.push({ id: k.id, etiket: `${'  '.repeat(derinlik)}${derinlik > 0 ? '└ ' : ''}${k.ad}` });
        gez(k.id, derinlik + 1);
      });
    };
    gez(0, 0);
    return sonuc;
  }, [kayitlar]);

  /** Seçilen dalın kendisi + tüm altları. */
  const altAgac = (id: number): number[] => {
    const sonuc = [id];
    const kuyruk = [id];
    while (kuyruk.length) {
      const ust = kuyruk.shift()!;
      kayitlar.filter(k => k.ustId === ust).forEach(k => { sonuc.push(k.id); kuyruk.push(k.id) });
    }
    return sonuc;
  };

  return (
    <select className="kat-suzgec" value={deger === null ? '' : String(deger)}
            title="Kategoriye göre süz (alt kategoriler dâhil)"
            onChange={e => {
              const v = e.target.value;
              if (v === '') { onDegis(null, []); return }
              const id = Number(v);
              onDegis(id, altAgac(id));
            }}>
      <option value="">Tüm kategoriler</option>
      {secenekler.map(s => <option key={s.id} value={s.id}>{s.etiket}</option>)}
    </select>
  );
}
