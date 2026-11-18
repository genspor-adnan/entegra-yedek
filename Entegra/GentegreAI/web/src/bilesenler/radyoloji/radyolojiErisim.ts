/**
 * RADYOLOJİ ERİŞİM ▾ MENÜSÜ (kullanıcı 18.11.2026: "Teslim Et butonu sağında Erişim butonu.. alta 4 menü: Hasta Kartını
 * Aç / Başvuruyu Aç / İstemi Aç / Raporu Aç, ikonlar da olsun"; aynı menü TeleRadyoloji Gönderimi kartında da).
 *
 * Tek tanım: liste araç çubuğunun alt seçenekleri (`radyoloji.erisim` ▾) ve Teletip kartının açılır düğmesi buradan.
 * Her hedef KENDİ ekranının yetkisiyle açılır (hasta kartı, başvuru, istem, rapor ekranı sunucuda ayrı kapıdan geçer).
 */
export const ERISIM_KODU = 'radyoloji.erisim';

export const ERISIM_MENUSU: { kod: string; ad: string }[] = [
  { kod: 'radyoloji.erisim.hasta',   ad: '👤 Hasta Kartını Aç' },
  { kod: 'radyoloji.erisim.basvuru', ad: '🧾 Başvuruyu Aç' },
  { kod: 'radyoloji.erisim.istem',   ad: '☢️ İstemi Aç' },
  { kod: 'radyoloji.erisim.rapor',   ad: '📄 Raporu Aç' },
];

export interface ErisimKimligi { istemId: number; hastaId?: number | null; basvuruId?: number | null }

/** Alt menü kodunun açacağı yol; açılamıyorsa kullanıcıya gösterilecek neden. Menü kodu değilse null. */
export function erisimYolu(kod: string, k: ErisimKimligi): { yol: string } | { hata: string } | null {
  switch (kod) {
    case 'radyoloji.erisim.hasta':
      return k.hastaId ? { yol: `/hasta/${k.hastaId}` } : { hata: 'İstemin hastası bulunamadı.' };
    case 'radyoloji.erisim.basvuru':
      return k.basvuruId ? { yol: `/basvuru/${k.basvuruId}` } : { hata: 'Bu istem bir başvuruya bağlı değil.' };
    case 'radyoloji.erisim.istem':
      return k.istemId ? { yol: `/radyoloji/${k.istemId}` } : { hata: 'İstem bulunamadı.' };
    case 'radyoloji.erisim.rapor':
      return k.istemId ? { yol: `/radyoloji/rapor/${k.istemId}` } : { hata: 'İstem bulunamadı.' };
    default:
      return null;
  }
}
