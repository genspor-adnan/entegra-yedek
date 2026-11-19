import { api } from '../../api/istemci';

/**
 * RANDEVU PANOSU (kullanıcı 19.11.2026: "Durum değiş sağına Pano İşlem buton ekle.. Altına Kes/Kopyala/Yapıştır ekle..
 * randevu plan modunda ise bir yerden kesilip başka yere yapıştırılsın,, veya kopyalanıp 2.bir 3.bir yere
 * yapıştırılabilir").
 *
 *  * KES: seçili randevu panoya; yapıştırınca AYNI randevu yeni saate (ve hedef sütunun doktoruna / cihazına) taşınır,
 *    pano boşalır. Randevu numarası, SMS geçmişi, log tek kayıtta kalır.
 *  * KOPYALA: yapıştırma her seferinde aynı hastaya YENİ randevu açar (hizmet, gönderen, kurum, açıklama, SMS
 *    tercihleri kopyalanır); pano dolu kalır - 2., 3. yere de yapıştırılabilir.
 *
 * Hedef: takvimde boş hücre tıklaması ya da işaretli aralığın başı. Sütun doktor ise doktor + bölümü, cihaz ise cihazı
 * değişir; düz gün sütununda kaynak (doktor / cihaz) olduğu gibi kalır. Çakışma / mesai / kapatma kuralları
 * veritabanı tetiğinde - hata mesajı olduğu gibi gösterilir.
 */
export interface RandevuPano {
  mod: 'kes' | 'kopyala';
  id: number;
  hasta: string;
  /** Kaynağın saati (bilgi: "09:00 Ali Yılmaz kesildi"). */
  saat: string;
}

export interface YapistirHedefi {
  /** Şube saati "yyyy-MM-ddTHH:mm". */
  baslangic: string;
  hekimId?: number;
  bolum?: number;
  cihazId?: number;
}

/** Kopyada taşınan alanlar (kart alan adları). Durum, belge bağı, erteleme izi, SMS gönderim damgası taşınmaz. */
const KOPYA_ALANLARI = ['hastaId', 'sureDk', 'tip', 'kaynak', 'bolum', 'hekimId', 'cihazId', 'hizmetId',
                        'gonderenId', 'kendiIstegi', 'kurumId', 'aciklama', 'smsGonder', 'smsHatirlatma'] as const;

/** Hedef sütunun kaynağı: doktor sütunu doktor + bölüm, cihaz sütunu cihaz; ikisi de yoksa değişmez. */
function kaynakAlanlari(h: YapistirHedefi): Record<string, unknown> {
  const k: Record<string, unknown> = {};
  if (h.hekimId) { k.hekimId = h.hekimId; if (h.bolum) k.bolum = h.bolum }
  if (h.cihazId) k.cihazId = h.cihazId;
  return k;
}

/** Yapıştırır; dönüş: yeni / taşınan randevunun id'si. */
export async function randevuYapistir(pano: RandevuPano, h: YapistirHedefi): Promise<number> {
  const mevcut = await api.kartOku('randevu', pano.id);
  if (pano.mod === 'kes') {
    await api.kartGuncelle('randevu', pano.id, {
      surum: mevcut.kart.surum,
      kart: { baslangic: h.baslangic, ...kaynakAlanlari(h) },
    });
    return pano.id;
  }
  const kart: Record<string, unknown> = { durum: 1, baslangic: h.baslangic };
  for (const a of KOPYA_ALANLARI) {
    const v = (mevcut.kart as Record<string, unknown>)[a];
    if (v !== undefined && v !== null && v !== '') kart[a] = v;
  }
  Object.assign(kart, kaynakAlanlari(h));
  const y = await api.kartEkle('randevu', { kart });
  return Number((y.kart as Record<string, unknown>).id ?? 0);
}
