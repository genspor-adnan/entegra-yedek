import { useEffect, useState } from 'react';
import { api } from '../api/istemci';

/**
 * MUAYENE UYARI BANDI (461, yeri kullanıcı isteğiyle değişti) — mockup
 * `muayene_karti.html` `.statusbar` içeriği; artık kartın altında değil
 * BAĞLAM ŞERİDİNİN (hasta / alerji / ilaç / bugün) ALTINDA bir bant.
 *
 * <b>Neden yukarıda:</b> "ana tanı girilmedi", "panik sonuç", "alerji kaydı
 * var" gibi uyarılar hekimin yazmaya başlamadan önce göreceği yerde
 * durmalı; kartın en altında oldukları sürece Tamamla'ya basılana kadar
 * fark edilmiyordu.
 *
 * <b>İş kuralı burada DEĞİL:</b> şerit sunucudan gelen sayıları yazar;
 * "tamamlanabilir mi" kararını Tamamla ucu verir (ve gerekirse reddeder).
 */

type Satir = Record<string, unknown>;

const sayi = (v: unknown) => Number(v ?? 0);

/** "12 dk" · "1 sa 05 dk" - süre boşsa null. */
function sure(baslangic: unknown, bitis: unknown): string | null {
  const b = baslangic ? new Date(String(baslangic)).getTime() : NaN;
  if (!Number.isFinite(b)) return null;
  const s = bitis ? new Date(String(bitis)).getTime() : Date.now();
  const dk = Math.max(0, Math.round((s - b) / 60000));
  if (dk < 60) return `${dk} dk`;
  return `${Math.floor(dk / 60)} sa ${String(dk % 60).padStart(2, '0')} dk`;
}

export function MuayeneDurumSeridi({ muayeneId }: { muayeneId: number }) {
  const [satir, setSatir] = useState<Satir | null>(null);

  useEffect(() => {
    if (!(muayeneId > 0)) return;
    let iptal = false;
    void (async () => {
      try {
        const y = await api.liste('muayene', {
          sayfa: 1, boyut: 1,
          filtre: { alan: 'id', op: 'esit', deger: muayeneId },
        });
        if (!iptal) setSatir((y.satirlar?.[0] ?? null) as Satir | null);
      } catch { /* serit zorunlu degil */ }
    })();
    return () => { iptal = true };
  }, [muayeneId]);

  if (!satir) return null;

  const tani = sayi(satir.taniSayisi);
  const anaTani = String(satir.anaTani ?? '').trim();
  const bekleyen = sayi(satir.bekleyenIstem);
  const gecen = sure(satir.baslangic, satir.tamamlanma);
  const tamamlandi = sayi(satir.durum) === 2;
  // `uyari` SUNUCUDA hesaplanir (panik sonuc / alerji / tanisiz / sonuc geldi)
  //   ve listede de ayni kolon gosterilir - iki yerde iki kural olmasin.
  const uyari = String(satir.uyari ?? '').trim();

  return (
    <div className="muayene-uyari muayene-durum">
      {uyari && (
        <span className={`rozet ${uyari.startsWith('PANİK') ? 'hata' : 'uyari'}`}>
          {uyari}
        </span>
      )}
      {/* ANA TANI ZORUNLU: e-Nabız 103 paketi ve provizyon onu bekler. */}
      <span className={anaTani ? 'rozet olumlu' : 'rozet uyari'}>
        {anaTani ? `Ana tanı: ${anaTani}` : 'Ana tanı girilmedi'}
      </span>
      {tani > 1 && <span className="sonuk">{tani} tanı</span>}
      {bekleyen > 0 && <span className="rozet uyari">{bekleyen} sonuç bekliyor</span>}
      {/* Sure de ROZET (kullanici): banttaki diger olculer rozet, sure duz
          metin kaldigi icin bandin ortasinda kayboluyordu. */}
      {gecen && (
        <span className="rozet gri">{tamamlandi ? 'süre' : 'açık'} {gecen}</span>
      )}
      <span className="sonuk">
        {tamamlandi
          ? 'Tamamlandı → başvuru tahakkuka düştü'
          : 'Tamamla → başvuru tahakkuk · e-Nabız paketi'}
      </span>
    </div>
  );
}
