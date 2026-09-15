import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * YATAK PANOSU — mockup `Ekranlar/Yatan/yatak_panosu.html`.
 *
 * <b>"Yer var mı?" sorusunun tek cevabı.</b> Liste değil PANO: yatak sayısı
 * kurumda sabittir ve gözle taranır; satır satır liste "şu odada iki boş var
 * mı" sorusunu cevaplamaz.
 *
 * <b>Kutu oda, satır yatak.</b> Yatak tek tek kutu olsaydı oda kuralları
 * (cinsiyet, izolasyon, oda türü) görünmez olurdu — oysa boş yatağın
 * <i>verilebilir</i> olup olmadığını oda belirler: kadın odasındaki boş yatak,
 * erkek hasta için boş değildir.
 *
 * Gridle AYNI kaynağı okur (`yatak` listesi): ikinci bir uç açmak, aynı ekranda
 * iki farklı doluluk oranı üretmenin en kısa yoluydu.
 */

interface PanoSatiri {
  id: number;
  yatak: string;
  oda: string;
  bina: string;
  kat: string;
  klinik: string;
  odaTurAdi: string;
  durum: number;
  durumAdi: string;
  durumNotu: string;
  hasta: string;
  yatisGun: number | null;
  bugunBosalacak: number;
  cinsiyetKurali: string;
  izolasyon: string;
  yatisId: number | null;
}

/**
 * Yatak durumu → nokta rengi (mockup `.nk` sınıfları), hepsi `y-` ÖNEKLİ.
 * Önek şart: `bos` adı tema.css'teki global `.bos` kuralına (boş liste mesajı,
 * padding 30px) çarpıyor ve 9 pikselik durum noktası 69 piksellik bir daireye
 * dönüşüyordu.
 */
const NOKTA: Record<number, string> = {
  1: 'y-bos', 2: 'y-dolu', 3: 'y-rezerve', 4: 'y-temizlik', 5: 'y-kapali',
};
/**
 * Satır durum sınıfı. ÖNEKLİ (`y-`) çünkü tema.css'te GLOBAL bir `.bos`
 * kuralı var (boş liste mesajı: padding 30px, ortalı) - önek olmadan yatak
 * satırı o kuralı yiyor ve pano dağılıyordu.
 */
const SATIR: Record<number, string> = {
  1: 'y-bos', 2: '', 3: '', 4: 'y-temizlik', 5: 'y-kapali',
};

export function YatakPanosu({ yenile }: { yenile?: number }) {
  const [satirlar, setSatirlar] = useState<PanoSatiri[] | null>(null);

  const yukle = useCallback(async () => {
    // Pano zorunlu değil: hatası liste akışını kesmemeli.
    try {
      const y = await api.liste('yatak', { sayfa: 1, boyut: 500 });
      setSatirlar(y.satirlar as unknown as PanoSatiri[]);
    } catch { /* sessiz */ }
  }, []);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  if (!satirlar) return null;

  // KAT → ODA kırılımı: mockuptaki düzen. Kat boşsa servis adı kullanılır -
  //   her kurum katla çalışmıyor, ama bir yerde gruplanmalı.
  const katlar = new Map<string, Map<string, PanoSatiri[]>>();
  for (const s of satirlar) {
    const kat = [s.bina, s.kat].filter(Boolean).join(' · ')
                || s.klinik || 'Tanımsız';
    if (!katlar.has(kat)) katlar.set(kat, new Map());
    const odalar = katlar.get(kat) as Map<string, PanoSatiri[]>;
    const oda = s.oda || '—';
    if (!odalar.has(oda)) odalar.set(oda, []);
    (odalar.get(oda) as PanoSatiri[]).push(s);
  }

  // KAPALI YATAK DOLULUK PAYDASINDAN DÜŞER: arızalı yatağı payda içinde
  //   bırakmak oranı olduğundan düşük gösterir ve "yer var" yanılgısı üretir.
  const acik = satirlar.filter(s => s.durum !== 5);
  const dolu = acik.filter(s => s.durum === 2).length;
  const oran = acik.length ? Math.round((dolu * 100) / acik.length) : 0;

  return (
    <div className="yatak-pano">
      <div className="yatak-pano-ozet">
        <span><b>{satirlar.length}</b> yatak</span>
        <span><b>{dolu}</b> dolu · <b>%{oran}</b> doluluk</span>
        <span><b>{satirlar.filter(s => s.durum === 1).length}</b> boş</span>
        <span><b>{satirlar.filter(s => s.durum === 4).length}</b> temizlikte</span>
        <span><b>{satirlar.filter(s => s.bugunBosalacak).length}</b> bugün boşalacak</span>
        <span className="sonuk">kapalı {satirlar.filter(s => s.durum === 5).length} — paydada değil</span>
      </div>

      {[...katlar.entries()].map(([kat, odalar]) => {
        const katYatak = [...odalar.values()].flat();
        const katDolu = katYatak.filter(s => s.durum === 2).length;
        return (
          <div className="kat" key={kat}>
            <div className="kat-bas">{kat}
              <span className="mini">{katYatak.length} yatak · {katDolu} dolu</span>
            </div>
            <div className="odalar">
              {[...odalar.entries()].map(([oda, yataklar]) => {
                const ilk = yataklar[0];
                return (
                  <div className={`oda${ilk.izolasyon ? ' izo' : ''}`} key={kat + oda}>
                    <div className="oda-bas">🚪 {oda}
                      <span className="mini">{ilk.odaTurAdi}</span>
                      <span className="sp">
                        {ilk.izolasyon && <span className="rozet hata">{ilk.izolasyon}</span>}
                        {ilk.cinsiyetKurali && (
                          <span className="rozet mavi">{ilk.cinsiyetKurali}</span>
                        )}
                      </span>
                    </div>
                    {yataklar.map(y => (
                      <div className={`yatak ${SATIR[y.durum] ?? ''}`
                                      + (y.bugunBosalacak ? ' y-cikacak' : '')} key={y.id}>
                        <span className={`nk ${NOKTA[y.durum] ?? ''}`} />
                        <span className="kod">{y.yatak}</span>
                        <span className="ad">
                          {y.hasta || y.durumAdi}
                          {y.durumNotu && <span className="sonuk"> · {y.durumNotu}</span>}
                        </span>
                        <span className="gun">
                          {/* "Bugün boşalacak" yatağı BOŞA ÇIKARMAZ, işaretler:
                              öğleden sonra boşalacak yatak sabah gelen hastaya
                              planlanabilir ama verilemez. */}
                          {y.bugunBosalacak
                            ? <span className="rozet sari">bugün çıkacak</span>
                            : y.yatisGun != null ? `${y.yatisGun}. gün` : ''}
                        </span>
                      </div>
                    ))}
                  </div>
                );
              })}
            </div>
          </div>
        );
      })}
    </div>
  );
}
