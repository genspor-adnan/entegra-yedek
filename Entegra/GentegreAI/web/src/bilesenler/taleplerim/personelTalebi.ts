/**
 * PERSONEL LİSTESİNDEN YENİ TALEP (kullanıcı: "personel listesinde yeni butonu
 * sağına Yeni Talep butonu ekle.. seçili personel için, alta doğru liste combo
 * açılsın.. ona göre ekran gelsin").
 *
 * Seçili personel ve dönüş yolu kartlara router state ile gider: kart personeli
 * dolu açar, Kapat personel listesine döner. Kayıttan sonra kart kendi
 * adresine geçerken dönüş yolunu taşır (`devamDurumu`).
 */
export interface PersonelTalepDurumu {
  personel?: { id: number; ad: string };
  geri?: string;
  /** Kartın ARKASINDA kalacak liste (kaynak). Yoksa kartın kendi listesi. */
  arka?: string;
}

/** Talep türü → kart yolu ve yetki. Sıra = menü sırası. */
export const PERSONEL_TALEP_TURLERI = [
  { kod: 'personel.talep.izin', ad: '🌴 İzin talebi', yol: '/personel-izin', yetki: 'ik.izin' },
  { kod: 'personel.talep.avans', ad: '💸 Avans talebi', yol: '/personel-avans', yetki: 'ik.avans' },
  { kod: 'personel.talep.masraf', ad: '🧾 Masraf beyanı', yol: '/personel-masraf', yetki: 'ik.masraf' },
  { kod: 'personel.talep.belge', ad: '📄 Belge talebi', yol: '/personel-belge-talep', yetki: 'ik.belge_talep' },
] as const;

/** Menü seçenekleri, yalnız kullanıcının ekleme yetkisi olan türler. */
//   Seçili satırda kalan izin varsa izin seçeneğinin yanında yazar (963 mockup).
export const personelTalepSecenekleri = (yetki: (kod: string, islem?: 'ekle') => boolean,
                                         satir?: Record<string, unknown> | null) =>
  PERSONEL_TALEP_TURLERI.filter(t => yetki(t.yetki, 'ekle')).map(t => ({
    kod: t.kod,
    ad: t.kod === 'personel.talep.izin' && satir?.kalanIzin != null
      ? `${t.ad} · kalan ${String(satir.kalanIzin).replace('.', ',')} gün` : t.ad,
  }));

export function personelTalepDurumu(state: unknown): PersonelTalepDurumu {
  const s = state as PersonelTalepDurumu | null;
  return { personel: s?.personel?.id ? s.personel : undefined, geri: typeof s?.geri === 'string' ? s.geri : undefined,
           arka: typeof s?.arka === 'string' ? s.arka : undefined };
}

/** Kayıttan sonra kartın kendi adresine geçişte taşınacak state (dönüş + arka liste). */
export const devamDurumu = (d: PersonelTalepDurumu) => (d.geri ? { state: { geri: d.geri, arka: d.arka } } : undefined);

/**
 * MENÜDE SEÇİLİ GÖRÜNECEK YOL: personel listesinden açılan talep kartında
 * adres kartınki (/personel-izin/yeni) ama kullanıcı personel listesindedir -
 * menü dönüş yolunu (geri) seçili gösterir.
 */
export const menuYolu = (pathname: string, state: unknown) =>
  personelTalepDurumu(state).geri?.split('?')[0] ?? pathname;

/** Yol menü maddesine ait mi: tam eşit ya da alt yol ("/personel-izin" "/personel" değildir). */
export const yolEslesir = (yol: string, menu: string) => yol === menu || yol.startsWith(menu.endsWith('/') ? menu : menu + '/');
