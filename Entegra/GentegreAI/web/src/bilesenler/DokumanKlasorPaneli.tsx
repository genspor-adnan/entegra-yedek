import { useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';

/**
 * DOKÜMAN KLASÖR PANELİ (419) — liste ekranının sol tarafı.
 *
 * İKİ TÜR KLASÖR yan yana durur ve ayrımı görünür olmalı:
 *
 *   * KURUMSAL klasörler kullanıcının açtığı ağaçtır (Kalite, Sözleşmeler…).
 *   * KAYNAK klasörleri SANALDIR: doküman zaten `kaynak + kaynak_id` ile bir
 *     karta bağlı (taraf, stok, hasta…), o bağdan türetilir. Her yeni personel
 *     için klasör kaydı açmak gerekmesin diye böyle - ve bu yüzden kaynak
 *     klasörü silinemez, yeniden adlandırılamaz.
 *
 * Seçim listeye SABİT FİLTRE olarak geçer; grid kendi arama/sıralamasını
 * bunun üstüne uygular.
 */
export interface KlasorSecimi {
  tur: 'tum' | 'klasor' | 'kaynak';
  id?: number;
  kod?: string;
  ad: string;
}

interface KlasorSatiri { tur: string; id: number; ad: string; yol: string;
                         ustId: number; sayi: number }
interface KaynakSatiri { tur: string; kod: string; sayi: number }

/** Kaynak kodunun okunur adı - kod listesi değil, ekranda görünen etiket. */
const KAYNAK_ADI: Record<string, string> = {
  taraf: 'Cari / Kişi', stok: 'Stok / Ürün', hasta: 'Hasta',
  personel: 'Personel (İK)', 'radyoloji-istem': 'Radyoloji İstem',
  'ebelge-xslt': 'e-Belge Şablonları', demirbas: 'Demirbaş', klasor: 'Kurumsal',
};

export function DokumanKlasorPaneli({ secim, onSecim, yenile }: {
  secim: KlasorSecimi;
  onSecim(s: KlasorSecimi): void;
  /** Liste yenilenince sayaçlar da tazelensin. */
  yenile?: number;
}) {
  const [klasorler, setKlasorler] = useState<KlasorSatiri[]>([]);
  const [kaynaklar, setKaynaklar] = useState<KaynakSatiri[]>([]);
  const [toplam, setToplam] = useState(0);
  const [hata, setHata] = useState<string | null>(null);

  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.dokumanKlasorleri();
        if (iptal) return;
        setKlasorler(y.kurumsal ?? []);
        setKaynaklar(y.kaynaklar ?? []);
        setToplam(y.toplam ?? 0);
        setHata(null);
      } catch (h) { if (!iptal) setHata(hataMetni(h)) }
    })();
    return () => { iptal = true };
  }, [yenile]);

  const secili = (s: KlasorSecimi) =>
    s.tur === secim.tur && s.id === secim.id && s.kod === secim.kod;

  const satir = (s: KlasorSecimi, ic: string, sayi: number, girinti = 0) => (
    <button
      key={`${s.tur}-${s.id ?? s.kod ?? 'tum'}`}
      className={`klasor-satir${secili(s) ? ' secili' : ''}`}
      onClick={() => onSecim(s)}
      title={s.ad}
      style={{ paddingLeft: 8 + girinti * 12 }}
    >
      <span className="klasor-ic">{ic}</span>
      <span className="klasor-ad">{s.ad}</span>
      <span className="klasor-sayi">{sayi}</span>
    </button>
  );

  return (
    <aside className="dokuman-klasor">
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="klasor-baslik">Klasörler</div>
      {satir({ tur: 'tum', ad: 'Tümü' }, '📁', toplam)}

      {klasorler.length > 0 && (
        <>
          <div className="klasor-baslik">Kurumsal</div>
          {klasorler.map(k => satir(
            { tur: 'klasor', id: k.id, ad: k.ad }, '📁', k.sayi,
            // Yol derinligi girintiyi verir: ayri bir agac yapisi kurmadan
            //   ust-alt iliskisi gorunur olsun.
            Math.max(0, (k.yol.match(/\//g) ?? []).length)))}
        </>
      )}

      {kaynaklar.length > 0 && (
        <>
          <div className="klasor-baslik">Kaynak</div>
          {kaynaklar.map(k => satir(
            { tur: 'kaynak', kod: k.kod, ad: KAYNAK_ADI[k.kod] ?? k.kod },
            '🔗', k.sayi))}
        </>
      )}

      <div className="klasor-not">
        Kaynak klasörleri otomatiktir (kaynak = cari / stok / hasta …);
        kurumsal klasörleri kullanıcı açar.
      </div>
    </aside>
  );
}
