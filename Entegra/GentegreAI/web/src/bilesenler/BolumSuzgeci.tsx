import { useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { guvenli } from './mesaj';

/**
 * BÖLÜM SÜZGECİ (kullanıcı: "personel listesinde aktif/pasif/durum sağına
 * filtreleme için Bölüm ağaç combo ve Rol combo getir").
 *
 * `KategoriSuzgeci` ile aynı desen: combo AĞACI girintiyle gösterir ve seçilen
 * dal ALT BİRİMLERİYLE BİRLİKTE süzer - "Görüntüleme" seçen kullanıcı MR/BT
 * alt birimlerindeki personeli de görmek ister, yalnız doğrudan köke bağlı
 * olanları değil.
 *
 * Süzgeç `icinde` koşuluyla gider: dalın tüm alt id'leri tek sorguda.
 *
 * Departman listesi `personel` yetkisiyle okunur (KaynakKatalogu.Departman),
 * yani personel listesini görebilen bu combo'yu da doldurabilir.
 */
type Bolum = { id: number; ad: string; ustId: number | null };

/** Sunucu alt birimin adını "— " ile ön ekliyor (agac listede tek bakışta
    görünsün diye). Burada girintiyi derinlikten üretiyoruz; ön ek kalırsa
    çift girinti olur. */
const adTemizle = (ad: string) => ad.replace(/^—\s*/, '');

export function BolumSuzgeci({ deger, onDegis, izinliIdler }: {
  deger: number | null;
  onDegis(id: number | null, altlarDahil: number[]): void;
  /**
   * Verilirse combo YALNIZ bu bolumleri (ve onlara giden ust dallari) gosterir
   * - basvuru listesinde "o tarih araliginda YER ALAN" bolumler (kullanici).
   * Ust dallar agac yapisi bozulmasin diye kalir; secilince zaten alt agaciyla
   * birlikte suzer, yani onlar da anlamli secim.
   */
  izinliIdler?: number[];
}) {
  const [kayitlar, setKayitlar] = useState<Bolum[]>([]);

  useEffect(() => {
    void guvenli(async () => {
      const y = await api.liste('departman', { sayfa: 1, boyut: 1000 });
      setKayitlar((y.satirlar ?? []).map(s => ({
        id: Number(s.id),
        ad: adTemizle(String(s.ad ?? '')),
        ustId: s.ustbirimId === null || s.ustbirimId === undefined
             ? null : Number(s.ustbirimId),
      })));
    });
  }, []);

  /** Ağaç sırası: kök -> altları, girinti derinlikle. */
  const secenekler = useMemo(() => {
    // İzin listesi varsa: izinli düğümler + onların TÜM ÜST dalları kalır.
    //   Üst dal atılırsa alttaki bölüm ağaçta asılı kalır ve hiç çizilmez.
    let gorunur = kayitlar;
    if (izinliIdler) {
      const izin = new Set(izinliIdler);
      const ustler = new Map(kayitlar.map(k => [k.id, k.ustId]));
      izinliIdler.forEach(id => {
        let u = ustler.get(id) ?? null;
        while (u !== null && !izin.has(u)) { izin.add(u); u = ustler.get(u) ?? null }
      });
      gorunur = kayitlar.filter(k => izin.has(k.id));
    }
    const cocuk = new Map<number, Bolum[]>();
    gorunur.forEach(b => {
      const ust = b.ustId ?? 0;
      cocuk.set(ust, [...(cocuk.get(ust) ?? []), b]);
    });
    cocuk.forEach(liste => liste.sort((a, b) => a.ad.localeCompare(b.ad, 'tr')));

    const sonuc: { id: number; etiket: string }[] = [];
    const gez = (ustId: number, derinlik: number) => {
      (cocuk.get(ustId) ?? []).forEach(b => {
        sonuc.push({
          id: b.id,
          etiket: `${'  '.repeat(derinlik)}${derinlik > 0 ? '└ ' : ''}${b.ad}`,
        });
        gez(b.id, derinlik + 1);
      });
    };
    gez(0, 0);
    return sonuc;
  }, [kayitlar, izinliIdler]);

  /** Seçilen dalın kendisi + tüm altları. */
  const altAgac = (id: number): number[] => {
    const sonuc = [id];
    const kuyruk = [id];
    while (kuyruk.length) {
      const ust = kuyruk.shift()!;
      kayitlar.filter(b => b.ustId === ust).forEach(b => { sonuc.push(b.id); kuyruk.push(b.id) });
    }
    return sonuc;
  };

  return (
    <select className="kat-suzgec" value={deger === null ? '' : String(deger)}
            title="Bölüme göre süz (alt birimler dâhil)"
            onChange={e => {
              const v = e.target.value;
              if (v === '') { onDegis(null, []); return }
              const id = Number(v);
              onDegis(id, altAgac(id));
            }}>
      <option value="">Tüm Bölümler</option>
      {secenekler.map(s => <option key={s.id} value={s.id}>{s.etiket}</option>)}
    </select>
  );
}
