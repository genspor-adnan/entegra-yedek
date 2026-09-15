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
 * YETKİ: `dokum` kodu. Döküm yetkisi olmayanda satır hiç çizilmez; dökümün
 * KAYNAK yetkisi ayrıca sunucuda uygulanır (döküm görmek veri görmek değildir).
 */
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
    yetkiKodu: 'dokum',
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
  dokumOgesi('Kurumlar & Sigorta'),
  dokumOgesi('Cari & CRM'),
  dokumOgesi('Satış'),
  dokumOgesi('Alış'),
  dokumOgesi('Stok & Hizmet'),
  dokumOgesi('Üretim'),
  dokumOgesi('Finans'),
  dokumOgesi('Muhasebe'),
  dokumOgesi('İK & Prim'),
  // Dokuman kendi ana grubu (kullanici): dokum orada da var - "hangi klasorde
  //   kac dosya, suresi dolan, onayda bekleyen" bir dokum sorusudur.
  dokumOgesi('Doküman'),
];
