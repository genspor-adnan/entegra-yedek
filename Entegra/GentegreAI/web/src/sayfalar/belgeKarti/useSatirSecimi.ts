import { useRef, useState } from 'react';
import type { SatirDurumu } from '../belgeSatir';
import { mesaj } from '../../bilesenler/mesaj';

/**
 * KALEM GRİDİNDE SATIR SEÇİMİ VE SİLME.
 *
 * Seçim davranışı liste gridleriyle AYNI olmalı: düz tık = yalnız o satır,
 * Ctrl/Cmd = ekle-çıkar, Shift = aralık. Kullanıcı ekrandan ekrana aynı eli
 * kullanıyor; kartta başka türlü davranan bir grid "bozuk" diye okunur.
 */
export function useSatirSecimi(satirlar: SatirDurumu[],
                               setSatirlar: (f: (s: SatirDurumu[]) => SatirDurumu[]) => void,
                               setKalemDegisti: (v: boolean) => void) {
  const [seciliSatirlar, setSeciliSatirlar] = useState<Set<number>>(new Set());
  /** Shift ile aralık seçimi için son tıklanan satırın sırası. */
  const sonTiklanan = useRef<number | null>(null);

  const secimDegis = (anahtar: number) =>
    setSeciliSatirlar(k => {
      const y = new Set(k);
      if (y.has(anahtar)) y.delete(anahtar); else y.add(anahtar);
      return y;
    });

  const satirTikla = (sira: number, e: { shiftKey: boolean; ctrlKey: boolean; metaKey: boolean }) => {
    const anahtarlar = satirlar.map(x => x.anahtar);
    if (e.shiftKey && sonTiklanan.current !== null) {
      const [bas, son] = [sonTiklanan.current, sira].sort((a, b) => a - b);
      setSeciliSatirlar(k => new Set([...k, ...anahtarlar.slice(bas, son + 1)]));
      return;
    }
    sonTiklanan.current = sira;
    if (e.ctrlKey || e.metaKey) { secimDegis(anahtarlar[sira]); return }
    setSeciliSatirlar(new Set([anahtarlar[sira]]));
  };

  /** Seçili satırları siler - grid salt görünüm olduğu için satır içi silme yok. */
  const seciliSil = () => {
    if (seciliSatirlar.size === 0) return;
    // ONAYLI (KİLİTLİ) SATIR SİLİNMEZ (681): düğme zaten kapalı ama silme
    //   başka yollardan da çağrılabiliyor (kısayol, toplu seçim) - sunucu
    //   reddedince kart kaydedilemez duruma düşerdi.
    if (satirlar.some(x => x.iskontoKilit && seciliSatirlar.has(x.anahtar))) {
      void mesaj('İskontosu onaylanmış satır silinemez - önce iskonto onayını kaldırın.');
      return;
    }
    // PAKET satırı silinince İÇERİĞİ de gider - yoksa sahipsiz içerik
    //   satırları belgede kalırdı.
    setSatirlar(s => s.filter(x =>
      !seciliSatirlar.has(x.anahtar)
      && !(x.paketAnahtar !== undefined && seciliSatirlar.has(x.paketAnahtar))));
    setSeciliSatirlar(new Set());
    setKalemDegisti(true);
  };

  return { seciliSatirlar, setSeciliSatirlar, sonTiklanan, satirTikla, secimDegis, seciliSil };
}
