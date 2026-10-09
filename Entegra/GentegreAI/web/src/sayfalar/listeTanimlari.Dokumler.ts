import type { ListeTanimi } from './listeTanimlari.Ortak';

/**
 * GRUP BAŞINA "📊 DÖKÜMLER" (plan: dokuman/11_MENU_DUZENI_PLANI.md kural 2 ve 4).
 *
 * Her ana grubun sonunda aynı iki öğe durur: **Dökümler** ve **Ayarlar**.
 * Kullanıcı hangi gruptaysa "bu işin dökümü nerede" diye aramaz - yer hep aynı.
 *
 * Bunlar EKRAN DEĞİL, BAĞLANTIDIR (`menuYol`): hepsi tek `/dokumler` ekranına
 * gider, yalnız `?grup=` süzgeci değişir. Her grup için ayrı bir rota açmak
 * aynı ekranı on kez kaydetmek olurdu.
 *
 * Yönetim › Dökümler ise TASARIMCIDIR (süzgeçsiz, hepsi): plan kural 4 -
 * grup içi 📊 çalıştırma, Yönetim'deki tasarım.
 *
 * YETKİ: GRUBUN KENDİ KODU `dokum.<grup>` (1003, kullanıcı: "menü koduyla
 * yetki matrisi kodları aynı olmalı"). Eskiden tek `dokum` kodu 28 grubun
 * Dökümler'ini birlikte açıyordu - matristeki bir kutu menüde 28 yeri
 * değiştiriyordu. Döküm yetkisi olmayanda satır hiç çizilmez; dökümün
 * KAYNAK yetkisi ayrıca sunucuda uygulanır (döküm görmek veri görmek değildir).
 * Kod listesi sunucuda Gentegre.Cekirdek/Yetki/EkranKodlari ile aynı.
 */
const DOKUM_KOD_EKI: Record<string, string> = {
  'Yönetim': 'yonetim', 'Randevu': 'randevu', 'Kayıt Kabul': 'kayit_kabul',
  'Muayene': 'muayene', 'Laboratuvar': 'laboratuvar', 'Radyoloji': 'radyoloji',
  'Göz': 'goz', 'Yatan Hasta': 'yatan_hasta', 'Diş': 'dis', 'FTR': 'ftr',
  'İşyeri Hekimliği': 'isyeri_hekimligi', 'Çağrı Merkezi': 'cagri_merkezi',
  'Medula': 'medula', 'Ameliyathane': 'ameliyathane', 'Acil': 'acil',
  'Kurumlar & Sigorta': 'kurumlar_sigorta', 'Cari & CRM': 'cari_crm',
  'Satış': 'satis', 'Alış': 'alis', 'Stok & Hizmet': 'stok_hizmet',
  'Eczane': 'eczane', 'Satınalma': 'satinalma', 'Üretim': 'uretim',
  'Finans': 'finans', 'Muhasebe': 'muhasebe', 'İK': 'ik', 'Doküman': 'dokuman',
  'Teknik Servis': 'teknik_servis',
};

/** Grubun Dökümler yetki kodu; grupsuz (tasarımcı) = Yönetim'inki. */
export function dokumKodu(grup?: string | null): string {
  return `dokum.${DOKUM_KOD_EKI[grup || 'Yönetim'] ?? 'yonetim'}`;
}

/** Bütün Dökümler kodları - rota kapısı bunlardan biri yeterli. */
export const DOKUM_KODLARI = Object.values(DOKUM_KOD_EKI).map(e => `dokum.${e}`);

function dokumOgesi(grup: string, sira = 80): ListeTanimi & {
  menuAd: string; ic: string; yetkiKodu: string; menuGrup?: string;
} {
  return {
    kaynak: 'dokumler',
    rota: 'dokumler',
    ozelSayfa: true,
    baslik: 'Dökümler',
    yol: `${grup} › Dökümler`,
    menuYol: `/dokumler?grup=${encodeURIComponent(grup)}`,
    menuGrup: grup,
    menuSira: sira,
    menuAd: 'Dökümler',
    ic: '📊',
    yetkiKodu: dokumKodu(grup),
  } as ListeTanimi & { menuAd: string; ic: string; yetkiKodu: string; menuGrup?: string };
}

/**
 * Hangi gruplarda Dökümler var: kayıtlı dökümü OLABİLECEK gruplar. e-Nabız
 * (kuyruk ekranı) ve Yönetim (tasarımcının kendisi zaten orada) dışarıda -
 * boş açılan bir "Dökümler" öğesi, kullanıcıya yanlış söz vermektir.
 */
export const DOKUM_LISTELERI = [
  dokumOgesi('Randevu'),
  dokumOgesi('Kayıt Kabul'),
  dokumOgesi('Muayene'),
  dokumOgesi('Laboratuvar'),
  dokumOgesi('Radyoloji'),
  // Göz (691): "hangi hekim kaç fako yaptı", "DR tarama oranı", "gözlük
  //   reçetesi sayısı" - hepsi döküm sorusu.
  dokumOgesi('Göz'),
  // Yatan hasta (695): doluluk oranı, ortalama yatış süresi, yatak devir hızı,
  //   çıkış şekli dağılımı - kurumun en çok sorulan yönetim sayıları.
  dokumOgesi('Yatan Hasta'),
  // Diş (706): plan kabul oranı, hekim başına yapılan işlem, lab gecikme
  //   oranı, borçlu hastalar - klinik panosunun soruları.
  dokumOgesi('Diş'),
  // FTR (719): program tamamlanma, devamsizlik, olcek iyilesme (MCID), unite doluluk.
  dokumOgesi('FTR'),
  // ISG (741): periyodik uyum, kanaat dagilimi, kaza sikligi, ISG-KATIP sure.
  dokumOgesi('İşyeri Hekimliği'),
  // Çağrı Merkezi (839): cevaplama / SLA / kaçan, agent performansı, konu dağılımı, kampanya sonucu.
  dokumOgesi('Çağrı Merkezi'),
  // Medula (707): kabul / red oranı, fatura-kesinti, hata kodu dağılımı.
  dokumOgesi('Medula'),
  // Ameliyathane (715): masa kullanımı, plan-gerçek sapması, iptal nedeni,
  //   cerrahi süre, komplikasyon oranı.
  dokumOgesi('Ameliyathane'),
  // Acil (716): kapı-hekim süresi, triyaj dağılımı, 4 saati aşan hasta,
  //   yeniden başvuru, çağrı yanıt süresi.
  dokumOgesi('Acil'),
  dokumOgesi('Kurumlar & Sigorta'),
  dokumOgesi('Cari & CRM'),
  dokumOgesi('Satış'),
  dokumOgesi('Alış'),
  dokumOgesi('Stok & Hizmet'),
  // Eczane (722): miad/imha tutarı, önlenen ilaç hatası, kontrollü ilaç
  //   uyum oranı, hazırlama süresi.
  dokumOgesi('Eczane'),
  // Satınalma (724): talep-sipariş süresi, gecikme ve ceza, bütçe kullanımı,
  //   tedarikçi skoru, en düşük alınmayan teklifler.
  dokumOgesi('Satınalma'),
  dokumOgesi('Üretim'),
  dokumOgesi('Finans'),
  dokumOgesi('Muhasebe'),
  dokumOgesi('İK'),
  // Dokuman kendi ana grubu (kullanici): dokum orada da var - "hangi klasorde
  //   kac dosya, suresi dolan, onayda bekleyen" bir dokum sorusudur.
  dokumOgesi('Doküman'),
  dokumOgesi('Teknik Servis'),
];
