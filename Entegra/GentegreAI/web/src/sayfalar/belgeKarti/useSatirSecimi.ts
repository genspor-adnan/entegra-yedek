import { useEffect, useRef, useState } from 'react';
import type { SatirDurumu } from '../belgeSatir';
import { mesaj, onay } from '../../bilesenler/mesaj';

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

  /**
   * SEÇİM SATIRIN KİMLİĞİNE BAĞLI (web incelemesi 18.11.2026): seçim yalnız `anahtar` tutuyordu; kayıt / tazeleme
   * sonrası sunucu yanıtından kurulan satırlar yeniden numaralanıyor (yanittanSatirlar: anahtar = sıra) - seçim başka
   * satırları gösteriyor, "Seçili Sil" yanlış ücret satırını siliyordu. Seçilen her anahtarın o anki satır kimliği
   * (sunucu satırId'si + kalem) saklanır; satırlar değişince kimliği tutmayan anahtar seçimden düşer.
   */
  const kimlik = (x: SatirDurumu) => `${x.satirId ?? ''}|${x.stokId ?? ''}|${x.hizmetId ?? ''}`;
  const seciminKimligi = useRef(new Map<number, string>());
  useEffect(() => {
    const m = new Map(satirlar.map(x => [x.anahtar, kimlik(x)]));
    seciminKimligi.current.forEach((k, a) => { if (m.get(a) !== k) seciminKimligi.current.delete(a) });
    setSeciliSatirlar(onceki => {
      const kalan = new Set([...onceki].filter(a => seciminKimligi.current.has(a)));
      return kalan.size === onceki.size ? onceki : kalan;
    });
    if (sonTiklanan.current !== null && sonTiklanan.current >= satirlar.length) sonTiklanan.current = null;
  }, [satirlar]);
  const kimlikKaydet = (anahtarlar: number[]) => {
    for (const a of anahtarlar) {
      const x = satirlar.find(y => y.anahtar === a);
      if (x) seciminKimligi.current.set(a, kimlik(x));
    }
  };

  const secimDegis = (anahtar: number) => {
    kimlikKaydet([anahtar]);
    setSeciliSatirlar(k => {
      const y = new Set(k);
      if (y.has(anahtar)) y.delete(anahtar); else y.add(anahtar);
      return y;
    });
  };

  const satirTikla = (sira: number, e: { shiftKey: boolean; ctrlKey: boolean; metaKey: boolean }) => {
    const anahtarlar = satirlar.map(x => x.anahtar);
    if (e.shiftKey && sonTiklanan.current !== null) {
      const [bas, son] = [sonTiklanan.current, sira].sort((a, b) => a - b);
      kimlikKaydet(anahtarlar.slice(bas, son + 1));
      setSeciliSatirlar(k => new Set([...k, ...anahtarlar.slice(bas, son + 1)]));
      return;
    }
    sonTiklanan.current = sira;
    if (e.ctrlKey || e.metaKey) { secimDegis(anahtarlar[sira]); return }
    kimlikKaydet([anahtarlar[sira]]);
    setSeciliSatirlar(new Set([anahtarlar[sira]]));
  };

  /** Seçili satırları siler - grid salt görünüm olduğu için satır içi silme yok. */
  const seciliSil = async () => {
    if (seciliSatirlar.size === 0) return;
    // ONAYLI (KİLİTLİ) SATIR SİLİNMEZ (681): düğme zaten kapalı ama silme
    //   başka yollardan da çağrılabiliyor (kısayol, toplu seçim) - sunucu
    //   reddedince kart kaydedilemez duruma düşerdi.
    if (satirlar.some(x => x.iskontoKilit && seciliSatirlar.has(x.anahtar))) {
      void mesaj('İskontosu onaylanmış satır silinemez - önce iskonto onayını kaldırın.');
      return;
    }
    // BELGEYE DONUSMUS SATIR SILINMEZ (kullanici 11.10.2026): fiş / fatura /
    //   tahakkuk ona bagli. Sunucu da reddeder.
    if (satirlar.some(x => x.donustu && seciliSatirlar.has(x.anahtar))) {
      void mesaj('Belgeye dönüşmüş ücret satırı silinemez - önce oluşan belgeyi (Belgeye Dönüşüm) silin.');
      return;
    }
    // ONAY (kullanıcı 07.11.2026 "bütün sil butonları silmeden önce uyarı vermeli").
    const n = seciliSatirlar.size;
    if (!await onay(n === 1 ? 'Seçili satır silinecek. Onaylıyor musunuz?' : `Seçili ${n} satır silinecek. Onaylıyor musunuz?`, true)) return;
    // PAKET satırı silinince İÇERİĞİ de gider - yoksa sahipsiz içerik
    //   satırları belgede kalırdı.
    setSatirlar(s => s.filter(x =>
      !seciliSatirlar.has(x.anahtar)
      && !(x.paketAnahtar !== undefined && seciliSatirlar.has(x.paketAnahtar))));
    setSeciliSatirlar(new Set());
    setKalemDegisti(true);
  };

  /** Dışarıdan seçim (grid "tümünü seç" vb.): seçilen anahtarların kimliği de kaydedilir. */
  const secimiAyarla = (d: Set<number> | ((k: Set<number>) => Set<number>)) =>
    setSeciliSatirlar(k => {
      const yeni = typeof d === 'function' ? d(k) : d;
      kimlikKaydet([...yeni]);
      return yeni;
    });

  return { seciliSatirlar, setSeciliSatirlar: secimiAyarla, sonTiklanan, satirTikla, secimDegis, seciliSil };
}
