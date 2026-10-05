import { useCallback, useEffect, useRef, useState } from 'react';
import { api } from '../../api/istemci';
import type { Kosul } from '../../api/sozlesme';
import type { GozUniteOzeti } from '../../api/uclar/goz';
import { c } from '../../dil/ceviri';
import { GOZ_ISTASYON, GOZ_PANO_ESIK } from '../../bilesenler/goz/gozPanoSabitleri';

/**
 * GÖZ ÜNİTE PANOSU v2 (976, mockup `Ekranlar/Goz/goz_unite_panosu.html`).
 *
 * Panonun mockup'ta olup ekranda eksik kalan üç parçası burada:
 *
 *   * <b>TAZELEME.</b> Mockup başlığında "30 sn'de bir yenilenir" yazıyor ve
 *     tasarım notu sebebini söylüyor: "panoya bakan kişi verinin ne kadar taze
 *     olduğunu bilmeden sıraya güvenemez". Elle tazelenen pano, duvara asılı
 *     bir ekranda sessizce eskiyor - kimse "bu sayı 40 dakikalık" demiyor.
 *   * <b>SÜZGEÇLER.</b> Mockup şeridinde hekim ve ünite seçimi var; istasyon
 *     çipleri kanbanın sütunlarıyla aynı şeyi söylediği için sol panele taşındı.
 *   * <b>SAYILAR TEK İSTEKTEN.</b> Şerit, alt tablolar ve sol panel aynı
 *     yanıtı (<c>/api/goz/unite-ozet</c>) paylaşıyor; üç ayrı istek aynı ekranda
 *     üç farklı "4 kişi" üretmenin en kısa yoluydu.
 */

// Tip ANNOTE EDİLİYOR: sabitler `as const` olduğu için literal tip (30)
//   çıkarılıyor ve sayaç durumu yalnız 30 değerini kabul ediyordu.
const PANO_TAZELEME_SN: number = GOZ_PANO_ESIK.tazelemeSn;

// --------------------------------------------------------------- süzgeç --
/**
 * Sol panel süzgeci: istasyon · hekim · oda/cihaz. Çipler (bekleyen,
 * dilatasyonda, geciken, acil) liste tanımında duruyor - onlar sabit koşul,
 * bunlar veriye göre değişen listeler.
 */
export function useGozPanoSuzgeci(aktif: boolean) {
  const [istasyon, setIstasyon] = useState<number | null>(null);
  const [hekim, setHekim] = useState<number | null>(null);
  const [kaynak, setKaynak] = useState<number | null>(null);

  const filtre = (temel: Kosul | undefined): Kosul | undefined => {
    if (!aktif) return temel;
    const l: Kosul[] = temel ? [temel] : [];
    if (istasyon !== null) l.push({ alan: 'istasyon', op: 'esit', deger: istasyon });
    if (hekim !== null) l.push({ alan: 'hekimId', op: 'esit', deger: hekim });
    if (kaynak !== null) l.push({ alan: 'kaynakId', op: 'esit', deger: kaynak });
    return l.length === 0 ? undefined : l.length === 1 ? l[0] : { op: 'and', kosullar: l };
  };
  return { istasyon, setIstasyon, hekim, setHekim, kaynak, setKaynak, filtre };
}
export type GozPanoSuzgeci = ReturnType<typeof useGozPanoSuzgeci>;

// ------------------------------------------------------------ veri + tazeleme --
/**
 * Pano verisi ve otomatik tazeleme.
 *
 * <b>Sekme görünmezken tazelenmez</b> (`document.hidden`): arkada duran on
 * sekme, kullanıcı hiç bakmadığı hâlde dakikada iki istek atardı.
 *
 * <b>Duraklatma var</b> çünkü pano sürükle-bırakla çalışıyor: kart taşınırken
 * gelen tazeleme listeyi yeniden kurup sürüklemeyi düşürüyor. Duraklatınca
 * şeritte kaçıncı dakikadan beri durduğu yazıyor - "pano donmuş mu" sorusu
 * ekranda cevaplanmalı.
 */
export function useGozPanoOzeti(aktif: boolean, yenile: number, onTazele: () => void) {
  const [veri, setVeri] = useState<GozUniteOzeti | null>(null);
  const [sonYenileme, setSonYenileme] = useState<Date | null>(null);
  const [otomatik, setOtomatik] = useState(true);
  const [kalan, setKalan] = useState(PANO_TAZELEME_SN);
  // Tazeleme isteğini her tikte yeniden kurmamak için: sayaç her saniye
  //   değişiyor, effect bağımlılığı olsaydı interval saniyede bir kurulurdu.
  const tazeleRef = useRef(onTazele);
  tazeleRef.current = onTazele;

  const yukle = useCallback(async () => {
    if (!aktif) return;
    // Şerit zorunlu değil: hatası kanbanı ve listeyi düşürmemeli.
    try {
      setVeri(await api.gozUniteOzeti());
      setSonYenileme(new Date());
    } catch { /* sessiz */ }
  }, [aktif]);

  useEffect(() => { void yukle() }, [yukle, yenile]);

  useEffect(() => {
    if (!aktif || !otomatik) return;
    setKalan(PANO_TAZELEME_SN);
    const t = window.setInterval(() => {
      setKalan(k => {
        if (k > 1) return k - 1;
        // Görünmeyen sekmede sayaç başa döner ama istek atılmaz.
        if (!document.hidden) tazeleRef.current();
        return PANO_TAZELEME_SN;
      });
    }, 1000);
    return () => window.clearInterval(t);
  }, [aktif, otomatik]);

  return { veri, sonYenileme, otomatik, setOtomatik, kalan, yukle };
}
export type GozPanoDurumu = ReturnType<typeof useGozPanoOzeti>;

const saatYaz = (t: Date) =>
  `${String(t.getHours()).padStart(2, '0')}:${String(t.getMinutes()).padStart(2, '0')}:${String(t.getSeconds()).padStart(2, '0')}`;

/** Başlık şeridi: verinin yaşı + sayaç + duraklat. */
export function GozPanoTazeleSeridi({ d, onYenile }: { d: GozPanoDurumu; onYenile: () => void }) {
  return (
    <div className="gp-tazele">
      <span className="gp-nokta" aria-hidden />
      <b>{c('Ünite panosu')}</b>
      <span className="sonuk">
        {d.sonYenileme
          ? `${c('son yenileme')} ${saatYaz(d.sonYenileme)}`
          : c('yükleniyor') + '…'}
      </span>
      <span className="sonuk">·</span>
      <span className="sonuk">
        {d.otomatik
          ? `${c('yeni veri')} ${d.kalan} ${c('sn')}`
          : c('otomatik yenileme duraklatıldı')}
      </span>
      <span className="gp-bosluk" />
      <button type="button" className="d" onClick={onYenile}>⟳ {c('Yenile')}</button>
      <button type="button" className={`d${d.otomatik ? '' : ' bir'}`}
              onClick={() => d.setOtomatik(!d.otomatik)}
              title={c('Kart taşırken duraklatın: tazeleme sürüklemeyi düşürür.')}>
        {d.otomatik ? `⏸ ${c('Duraklat')}` : `▶ ${c('Sürdür')}`}
      </button>
    </div>
  );
}

// ------------------------------------------------------------------ sol panel --
export function GozPanoSolPanel({ veri, s }: { veri: GozUniteOzeti | null; s: GozPanoSuzgeci }) {
  const istasyonlar = veri?.istasyonlar ?? [];
  const hekimler = veri?.panelHekimler ?? [];
  const kaynaklar = veri?.panelKaynaklar ?? [];
  const toplam = istasyonlar.reduce((a, b) => a + b.sayi, 0);
  const vardiya = (id: number) => veri?.vardiyalar?.find(v => v.id === id)?.vardiya ?? '';

  return (
    <div className="rt-agac">
      <h6>{c('İstasyon')}</h6>
      <button type="button" className={`rt-dal${s.istasyon === null ? ' on' : ''}`}
              onClick={() => s.setIstasyon(null)}><span>{c('Tümü')}</span><i>{toplam}</i></button>
      {istasyonlar.map(i => (
        <button key={i.istasyon} type="button" className={`rt-dal${s.istasyon === i.istasyon ? ' on' : ''}`}
                onClick={() => s.setIstasyon(s.istasyon === i.istasyon ? null : i.istasyon)}>
          <span>{c(GOZ_ISTASYON[i.istasyon] ?? String(i.istasyon))}</span><i>{i.sayi}</i></button>
      ))}

      {hekimler.length > 0 && <h6 style={{ marginTop: 12 }}>{c('Hekim')}</h6>}
      {hekimler.map(h => (
        <button key={h.id} type="button" className={`rt-dal${s.hekim === h.id ? ' on' : ''}`}
                onClick={() => s.setHekim(s.hekim === h.id ? null : h.id)}>
          {/* VARDİYA ADIN ALTINDA: mockup şeridindeki "Vardiya 08:00-16:00";
              planı olmayan hekimde satır hiç çizilmez (uydurma saat yazmaz). */}
          <span>{h.ad}{vardiya(h.id) ? <em className="gp-vardiya"> {vardiya(h.id)}</em> : null}</span>
          <i>{h.sayi}</i></button>
      ))}

      {kaynaklar.length > 0 && <h6 style={{ marginTop: 12 }}>{c('Oda / cihaz')}</h6>}
      {kaynaklar.map(k => (
        <button key={`${k.kaynakId ?? 'x'}-${k.ad}`} type="button"
                className={`rt-dal${k.kaynakId !== null && s.kaynak === k.kaynakId ? ' on' : ''}`}
                // TANIMSIZ ODA SÜZÜLEMEZ: metin eşleşmesiyle filtre kurmak,
                //   "OCT-1 / OCT1" ikiliğini süzgeçte geri getirirdi. Tanım
                //   yapılınca satır süzülebilir hâle geliyor.
                disabled={k.kaynakId === null}
                title={k.kaynakId === null
                  ? c('Tanımsız oda - Göz › Oda / Cihaz Tanımı ekranından tanımlayın.')
                  : undefined}
                onClick={() => k.kaynakId !== null && s.setKaynak(s.kaynak === k.kaynakId ? null : k.kaynakId)}>
          <span>{k.ad}</span><i>{k.sayi}</i></button>
      ))}
    </div>
  );
}
