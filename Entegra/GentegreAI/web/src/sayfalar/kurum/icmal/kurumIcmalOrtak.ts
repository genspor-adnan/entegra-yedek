import type { KurumIcmalKaydi, KurumIcmali } from '../../../api/uclar/kurumIcmal';

/** Kurum icmalinin saf yardımcıları - ekran çizmez, test edilir. */

export type Rozet = { ad: string; renk: string };

/** Provizyon durumu (kod listesi provizyon.durum); -1 = kurum provizyon istemez. */
export function provizyonRozeti(d: number): Rozet | null {
  switch (d) {
    case 0: return { ad: 'Alınmadı', renk: 'sari' };
    case 1: return { ad: 'Onaylı', renk: 'ok' };
    case 2: return { ad: 'Red', renk: 'kir' };
    case 3: return { ad: 'Kısmi onay', renk: 'sari' };
    case 4: return { ad: 'İptal', renk: 'pas' };
    default: return null;
  }
}

/** Kurumun dönem icmal durumu (kurum_icmal.durum; 0 = icmal yok). */
export function icmalRozeti(d: number): Rozet {
  if (d === 2) return { ad: 'Faturalandı', renk: 'ok' };
  if (d === 1) return { ad: 'Kesinleşti', renk: 'sari' };
  return { ad: 'Açık', renk: 'pas' };
}

/**
 * İCMAL KAYDI DURUMU (İcmaller sekmesi): sunucunun durum kodu + vade / kısmi
 * tahsil ayrıntısı - "faturalandı" tek başına parası gelmiş mi söylemiyor.
 */
export function kayitRozeti(k: Pick<KurumIcmalKaydi, 'durumKod' | 'vadesiGecti' | 'tahsil' | 'vade'>): Rozet {
  if (k.durumKod === 'hazirlaniyor') return { ad: 'Hazırlanıyor · fatura bekliyor', renk: 'sari' };
  if (k.durumKod === 'tahsil') return { ad: 'Tahsil edildi', renk: 'ok' };
  if (k.vadesiGecti) return { ad: 'Faturalandı · vadesi geçti', renk: 'kir' };
  if (k.tahsil > 0.005) return { ad: 'Faturalandı · kısmi tahsil', renk: 'sari' };
  if (k.vade) {
    const d = new Date(k.vade);
    return { ad: `Faturalandı · vade ${String(d.getDate()).padStart(2, '0')}.${String(d.getMonth() + 1).padStart(2, '0')}`, renk: 'mavi' };
  }
  return { ad: 'Faturalandı', renk: 'mavi' };
}

export type Adim = { ad: string; durum: 'bitti' | 'simdi' | 'bekliyor' };

/**
 * DÖNEM ADIMLARI (yalnız tek kurum): Açık → Kesinleşti (icmal oluşturuldu)
 * → Faturalandı → Tahsil edildi. Açık kurum payı kaldıysa dönem hâlâ açıktır -
 * icmal sonradan girilen başvuruları kapsamaz.
 */
export function donemAdimlari(v: Pick<KurumIcmali, 'icmaller' | 'ozet'>): Adim[] {
  const icmal = v.icmaller;
  const kesin = icmal.length > 0 && v.ozet.acikKurumPayi <= 0.005;
  const faturali = icmal.length > 0 && icmal.every(i => i.durum === 2);
  const fatura = icmal.reduce((t, i) => t + i.faturaTutari, 0);
  const tahsil = icmal.reduce((t, i) => t + i.tahsil, 0);
  const odendi = faturali && fatura > 0 && tahsil >= fatura - 0.005;
  const bitti = [true, kesin, faturali, odendi];
  const ilkEksik = bitti.indexOf(false);
  return ['Açık', 'Kesinleşti', 'Faturalandı', 'Tahsil edildi'].map((ad, i) => ({
    ad,
    durum: ilkEksik === -1 || i < ilkEksik - 1 ? 'bitti' : i === ilkEksik - 1 ? 'simdi' : 'bekliyor',
  }));
}

/** Varsayılan dönem: geçen ay (kurum faturası ay kapanınca kesilir). */
export function gecenAy(bugun = new Date()): { bas: string; bit: string } {
  const bas = new Date(bugun.getFullYear(), bugun.getMonth() - 1, 1);
  const bit = new Date(bugun.getFullYear(), bugun.getMonth(), 0);
  return { bas: yerelGun(bas), bit: yerelGun(bit) };
}

/** Yerel gün (toISOString UTC'ye çevirip bir gün kaydırır). */
export const yerelGun = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

/**
 * LİSTE SEÇİMİ (kullanıcı 10.10.2026: "seçimde diğer seçimler kalksın.. ctrl
 * veya shift ile birden fazla seçilir"): düz tıklama yalnız o satırı seçer;
 * Ctrl (Mac'te Cmd) ekler / çıkarır; Shift son tıklanandan bu satıra kadar
 * aralığı seçer (Ctrl+Shift aralığı mevcut seçime ekler).
 */
export function secimUygula(secili: number[], id: number, sira: number[], sonId: number | null,
                            tus: { ctrl: boolean; shift: boolean }): number[] {
  if (tus.shift && sonId != null && sira.includes(sonId)) {
    const a = sira.indexOf(sonId), b = sira.indexOf(id);
    const aralik = sira.slice(Math.min(a, b), Math.max(a, b) + 1);
    return tus.ctrl ? [...new Set([...secili, ...aralik])] : aralik;
  }
  if (tus.ctrl) return secili.includes(id) ? secili.filter(x => x !== id) : [...secili, id];
  return [id];
}
