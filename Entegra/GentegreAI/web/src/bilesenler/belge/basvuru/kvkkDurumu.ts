/**
 * KVKK ONAY DURUMU (1353, mockup Ekranlar/Kayıt Kabul/kvkk_onay_gecerlilik.html). Sunucu (GET /api/basvuru/kvkk-durum)
 * hastanın bu başvuru dışındaki son KVKK kaydını ayarlara (şube bazlı / X gün) göre yorumlar; burada yalnız METİN
 * ve RENK üretilir - başvuru sekmesi, hasta şeridi ve KVKK Onay menüsü aynı cümleyi göstersin.
 */
export interface KvkkDurumu {
  durum: 'gecerli' | 'suresi_doldu' | 'reddetti' | 'baska_sube' | 'yok';
  kvkkOnay?: number; etkOnay?: number;
  tarih?: string; belgeNo?: string; sube?: string; kod?: string;
  bitis?: string | null; gun?: number;
}

const gun = (iso?: string | null) => iso ? iso.slice(0, 10).split('-').reverse().join('.') : '';
const onayTuru = (k?: number) => k === 4 ? 'SMS ile onay' : k === 3 ? 'ıslak imzalı onay' : k === 1 ? 'hasta reddetti' : k === 2 ? 'onaysız' : '';

/** Başvuru sekmesindeki bilgi satırı: sınıf (g / s / b / k) + metin. Durum yoksa null. */
export function kvkkBilgiSatiri(d: KvkkDurumu | null): { sinif: 'g' | 's' | 'b' | 'k'; metin: string } | null {
  if (!d) return null;
  switch (d.durum) {
    case 'gecerli':
      return { sinif: 'g', metin: `↻ Önceki onay geçerli: ${gun(d.tarih)} · Başvuru ${d.belgeNo} · ${d.sube} · ${onayTuru(d.kvkkOnay)}`
        + (d.kod ? ` (kod ${d.kod})` : '') + (d.bitis ? ` · ${gun(d.bitis)}'e kadar geçerli` : ' · süresiz') + '.' };
    case 'suresi_doldu':
      return { sinif: 's', metin: `⚠ KVKK onayının süresi doldu: son onay ${gun(d.tarih)} (Başvuru ${d.belgeNo}, ${onayTuru(d.kvkkOnay)}) - ${d.gun} gün geçti. Yeniden onay alın: KVKK Onay › SMS Gönder ya da Islak İmzalı Onay Alındı.` };
    case 'reddetti':
      return { sinif: 'k', metin: `🚫 Hasta son başvurusunda (${gun(d.tarih)}, ${d.belgeNo}) ${d.kvkkOnay === 1 ? 'onayı reddetti' : 'onaysız kaldı'}. Bu başvuruda yeniden sorun.` };
    case 'baska_sube':
      return { sinif: 'b', metin: `ℹ Hastanın ${d.sube} şubesinde ${gun(d.tarih)} tarihli onayı var; bu şube için ayrı onay gerekiyor (Kayıt Kabul Ayarları › KVKK onayı şube bazlı).` };
    default:
      return { sinif: 's', metin: '⚠ Hastanın KVKK onayı yok - KVKK Onay › SMS Gönder ya da Islak İmzalı Onay Alındı.' };
  }
}

/**
 * Hasta şeridi / menü başlığı için KISA durum. Önce bu başvurunun kendi seçimi (kvkkOnay) - kayıt kabul az önce
 * değiştirdiyse o geçerli; seçilmemişse önceki kayıtların durumu.
 */
export function kvkkKisa(mevcut: number | null | undefined, d: KvkkDurumu | null): { isaret: '✓' | '✗' | '?' | '⚠'; metin: string; sinif: string } {
  if (mevcut === 3 || mevcut === 4) {
    const bitis = d?.durum === 'gecerli' && d.bitis ? ` · ${gun(d.bitis)}'e kadar` : '';
    return { isaret: '✓', metin: `${mevcut === 4 ? 'SMS ile onay' : 'Islak imzalı onay'}${bitis}`, sinif: 'olumlu' };
  }
  if (mevcut === 1) return { isaret: '✗', metin: 'Hasta reddetti', sinif: 'teh' };
  if (mevcut === 2) return { isaret: '✗', metin: 'Onaysız', sinif: 'teh' };
  if (d?.durum === 'suresi_doldu') return { isaret: '⚠', metin: 'Süresi doldu - yeniden onay alın', sinif: 'uyari' };
  if (d?.durum === 'baska_sube') return { isaret: '⚠', metin: 'Bu şube için onay gerekli', sinif: 'uyari' };
  if (d?.durum === 'reddetti') return { isaret: '⚠', metin: 'Son başvuruda reddetti - yeniden sorun', sinif: 'uyari' };
  return { isaret: '?', metin: 'Onay gerekli', sinif: 'uyari' };
}
