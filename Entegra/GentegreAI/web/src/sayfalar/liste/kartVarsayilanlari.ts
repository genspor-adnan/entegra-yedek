import type { ListeTanimi } from '../listeTanimlari';

/**
 * YENİ KARTIN ÖN DOLGUSU — URL parametrelerinden kart varsayılanları (refaktör 22.10.2026).
 *
 * `ListeKarti.tsx` içinde 80 satırlık bir üçlü zincirdi; kural bilgisi (hangi ekrandan hangi parametre
 * gelir) bileşenin ortasındaydı ve test edilemiyordu. Saf fonksiyon: girdi liste tanımı + kart id +
 * URL sorgusu, çıktı GenForm'un `yeniKayitVarsayilanlari`'sı. İlk tutan kural kazanır (zincirin sırası
 * korundu); hiçbiri tutmazsa liste tanımının kendi varsayılanları.
 */

/** Önce hasta sorulup kartı o hastayla açılan kaynaklar (ListeKarti'nin hasta araması da bunu kullanır). */
export const HASTA_ILE_YENI = new Set(['konsultasyon', 'sevk']);
/** Odontogram / pano gibi başka ekrandan hasta ön dolu açılan hasta kayıtları. */
export const HASTA_KAYIT_KAYNAKLARI = new Set(['hasta-alerji', 'hasta-kronik', 'hasta-ilac', 'hasta-gecmis',
  'ftr-degerlendirme', 'ftr-program', 'ftr-olcek', 'isg-calisan']);
/** Göz muayenesinin kısayollarından açılan kartlar (hasta + muayene bağı). */
export const GOZ_KISAYOL_KAYNAKLARI = new Set(['goz-gozluk-recete', 'goz-goruntuleme', 'goz-islem']);

type Varsayilanlar = Record<string, boolean | number | string>;

export function yeniKartVarsayilanlari(tanim: ListeTanimi, kartId: number | 'yeni' | null,
                                      sorgu: URLSearchParams): Varsayilanlar | undefined {
  const t = tanim.yeniKayitVarsayilanlari;
  const g = (ad: string) => sorgu.get(ad);
  const sayi = (ad: string) => Number(g(ad));
  /** Parametre varsa alanına yazar (sayı ya da metin). */
  const varsa = (alan: string, param = alan, tur: 'sayi' | 'metin' = 'sayi') =>
    g(param) ? { [alan]: tur === 'sayi' ? sayi(param) : g(param)! } : {};
  const k = tanim.kaynak;

  // CTRL+K "TC / telefon + yeni hasta / personel" (22.10.2026): kayıtlı değilse yeni kart numara dolu.
  if ((k === 'hasta' || k === 'personel') && kartId === 'yeni' && (g('vkno') || g('cepTel')))
    return { ...t, ...varsa('vkno', 'vkno', 'metin'), ...varsa('cepTel', 'cepTel', 'metin') };
  // CTRL+K "VKN + müşteri / tedarikçi" (25.10.2026): entegratör bilgi veremezse yeni cari kartı VKN dolu açılır
  //   (rol bayrağı listenin kendi varsayılanından: Müşteri Listesi müşteri, Tedarikçi Listesi tedarikçi).
  if (k === 'cari' && kartId === 'yeni' && g('vkno'))
    return { ...t, ...varsa('vkno', 'vkno', 'metin') };
  // Önce sorulan hasta (ListeKarti'nin hasta araması) kartın hastasıdır.
  if (HASTA_ILE_YENI.has(k) && kartId === 'yeni' && g('tarafId'))
    return { ...t, tarafId: sayi('tarafId') };
  // Muayenedeki ＋'dan: hangi alanın altından açıldıysa o alan seçili gelir.
  if (k === 'metin-makro' && kartId === 'yeni' && g('alan') !== null)
    return { ...t, alan: g('alan')!, durum: 1 };
  // Takvimden gelen saat / süre (251); saat seçilmeden "Yeni" de süzgeçteki bölüm / doktoru taşır.
  //   KONTROL RANDEVUSU (göz süreci v2): muayene Tamamla'dan hasta ön dolu.
  if (k === 'randevu' && (g('baslangic') || g('hekim') || g('bolum') || g('hastaId')))
    return { ...t, ...varsa('baslangic', 'baslangic', 'metin'), ...varsa('sureDk', 'sure'), ...varsa('hekimId', 'hekim'),
             ...varsa('bolum'), ...varsa('cihazId', 'cihaz'), ...varsa('hastaId') };
  // GÖZ MUAYENESİ KISAYOLLARI (691): reçete / görüntüleme / işlem kartı muayeneden açıldıysa hasta ve
  //   muayene bağı ön dolu - hekim aynı bilgiyi ikinci kez seçmesin, bağ da unutulmasın.
  if (GOZ_KISAYOL_KAYNAKLARI.has(k) && g('hastaId'))
    return { ...t, hastaId: sayi('hastaId'), ...varsa('muayeneId') };
  // DİŞ LAB İŞ EMRİ (708): seans kartından hasta, hekim, plan satırı ve diş ön dolu.
  if (k === 'dis-lab-isemri' && g('hastaId'))
    return { ...t, hastaId: sayi('hastaId'), ...varsa('hekimId'), ...varsa('planSatirId'),
             ...varsa('disNolar', 'disNolar', 'metin') };
  // İSG (741): olay / ziyaret firma ve çalışan ön dolu (çalışan kartı, pano).
  if (k.startsWith('isg-') && (g('firmaId') || g('calisanId')))
    return { ...t, ...varsa('firmaId'), ...varsa('calisanId') };
  // KURUMSAL KALİTE (1050): olay / risk / denetim bulgusundan açılan DÖF kaynağı dolu.
  if (k === 'kys-dof' && g('kaynakTur'))
    return { ...t, kaynakTur: sayi('kaynakTur'), ...varsa('kaynakId'), ...varsa('kaynakNo', 'kaynakNo', 'metin'),
             ...varsa('departmanId', 'birimId'), ...varsa('tanim', 'tanim', 'metin') };
  // KURUMSAL KALİTE (1057): "Yeniden değerlendir" tedarikçi dolu.
  if (k === 'kys-tedarikci' && g('tarafId'))
    return { ...t, tarafId: sayi('tarafId'), ...varsa('neAliniyor', 'neAliniyor', 'metin') };
  // ÇALIŞMA PLANI (711): plandan açılan istisna / şablon kartı hekim ön dolu.
  if (k.startsWith('calisma-') && g('hekimId'))
    return { ...t, hekimId: sayi('hekimId') };
  // HASTA KAYITLARI (alerji / kronik / ilaç / geçmiş, FTR): hasta ön dolu; kaydet / kapat `geri` ile döner.
  if (HASTA_KAYIT_KAYNAKLARI.has(k) && g('hastaId'))
    return { ...t, hastaId: sayi('hastaId'), ...varsa('programId') };
  // DİŞ ÖDEME PLANI: plan ve toplam ön dolu (odontogramdaki düğme).
  if (k === 'dis-odeme-plani' && g('planId'))
    return { ...t, planId: sayi('planId'), ...varsa('toplam') };
  return t;
}
