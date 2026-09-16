import { type ListeGirdisi, type ListeTanimi } from './listeTanimlari.Ortak';

// Tip ve sabitler ORTAK modulde (dongusel import kirildi); buradan
// yeniden disa aciliyorlar - cagiran dosyalar degismesin.
export { DURUM_CIPLERI } from './listeTanimlari.Ortak';
export type { ListeTanimi, ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * LISTE EKRANLARININ TANIM TABLOSU.
 *
 * Menu, rotalar ve grid AYNI tablodan uretilir - yeni bir liste eklemek icin
 * tek yer yeter. Liste.tsx bu tanimlari tuketen bilesendir; veri buradadir
 * (dosya 1028 satira ulasinca ikisi ayrildi).
 */
/**
 * Kasa listesindeki "＋ Tahsilat" / "－ Ödeme" dugmelerinin ARAC menusu.
 * Kodlar kasa_islem_turu.kod ile birebir: tahsilat 21/22/25, odeme 31/32/35.
 *
 * CEK / SENET (23/24/33/34) SIMDILIK YOK: bu turlerin sablonu 'ceksenet'
 * bacagi istiyor ve o bacak cek/senet KAYDINA baglaniyor (vade, seri,
 * kesideci) - kayit ekrani Kasa planinin F5 fazinda gelecek. Menude durup
 * kaydedilemeyen (422) bir secenek gostermek yerine F5'te eklenecek.
 */
/**
 * "⇢ Dönüştür" alt menusu (kullanici): hedefi LISTEDE secmek, karti actiktan
 * sonra combo'dan secmekten hizli. Secim karta KILITLI gider - kullanici zaten
 * kararini vermistir, kartta ikinci kez sormak hata kapisi acar.
 *
 * Kod bicimi "belge.donustur.<hedef tur>"; hedef turler BelgeDonusumModali'ndaki
 * HEDEFLER ile ayni (satis siparisi 19 -> 14/15/16/13).
 */
import { KLINIK_LISTELERI } from './listeTanimlari.Klinik';
import { LAB_LISTELERI } from './listeTanimlari.Laboratuvar';
import { RADYOLOJI_LISTELERI } from './listeTanimlari.Radyoloji';
import { GOZ_LISTELERI } from './listeTanimlari.Goz';
import { YATAN_LISTELERI } from './listeTanimlari.Yatan';
import { DIS_LISTELERI } from './listeTanimlari.Dis';
import { FTR_LISTELERI } from './listeTanimlari.Ftr';
import { MEDULA_LISTELERI } from './listeTanimlari.Medula';
import { KLINIK_KALITE_LISTELERI } from './listeTanimlari.KlinikKalite';
import { AMELIYATHANE_LISTELERI } from './listeTanimlari.Ameliyathane';
import { ACIL_LISTELERI } from './listeTanimlari.Acil';
import { ENABIZ_LISTELERI } from './listeTanimlari.Enabiz';
import { CARI_LISTELERI } from './listeTanimlari.Cari';
import { TICARI_LISTELERI } from './listeTanimlari.Ticari';
import { STOK_LISTELERI } from './listeTanimlari.Stok';
import { ECZANE_LISTELERI } from './listeTanimlari.Eczane';
import { BIYOMEDIKAL_LISTELERI } from './listeTanimlari.Biyomedikal';
import { SATINALMA_LISTELERI } from './listeTanimlari.Satinalma';
import { DOKUM_LISTELERI } from './listeTanimlari.Dokumler';
import { YONETIM_LISTELERI } from './listeTanimlari.Yonetim';

export const DONUSUM_MENUSU: Record<string, { kod: string; ad: string }[]> = {
  'belge.donustur': [
    { kod: 'belge.donustur.14', ad: '🚚 İrsaliye' },
    { kod: 'belge.donustur.15', ad: '🧾 Fatura' },
    { kod: 'belge.donustur.16', ad: '🧮 Fiş' },
    { kod: 'belge.donustur.13', ad: '📑 Tahakkuk' },
  ],
};

export const KASA_ARAC_MENUSU: Record<string, { kod: string; ad: string }[]> = {
  'kasa.tahsilat.yeni': [
    { kod: 'kasa.yeni.21', ad: '💵 Nakit' },
    { kod: 'kasa.yeni.22', ad: '🏦 Banka' },
    { kod: 'kasa.yeni.25', ad: '💳 POS' },
    // Cek/senet ayri turlerdir (23/24) ve portfoyde ayri izlenir; belge
    //   kartinin Tahsilat sekmesinde de ayni iki dugme var.
    { kod: 'kasa.yeni.23', ad: '🧾 Çek' },
    { kod: 'kasa.yeni.24', ad: '📜 Senet' },
  ],
  'kasa.odeme.yeni': [
    { kod: 'kasa.yeni.31', ad: '💵 Nakit' },
    { kod: 'kasa.yeni.32', ad: '🏦 Banka' },
    { kod: 'kasa.yeni.35', ad: '💳 POS / Kredi Kartı' },
    { kod: 'kasa.yeni.33', ad: '🧾 Çek' },
    { kod: 'kasa.yeni.34', ad: '📜 Senet' },
  ],
};



/** Menu + rota kaynagi. Yetki sunucudan gelir; burada yalnizca ekran tanimi var.
    menuGrup verilirse Kabuk.tsx'te ayni gruptaki ogeler "Cari" gibi acilir-kapanir bir
    ana menu altinda TOPLANIR. */

export const LISTELER: ListeGirdisi[] = [
  ...KLINIK_LISTELERI,
  ...LAB_LISTELERI,
  ...RADYOLOJI_LISTELERI,
  ...GOZ_LISTELERI,
  ...YATAN_LISTELERI,
  ...DIS_LISTELERI,
  ...FTR_LISTELERI,
  ...MEDULA_LISTELERI,
  ...KLINIK_KALITE_LISTELERI,
  ...AMELIYATHANE_LISTELERI,
  ...ACIL_LISTELERI,
  ...ENABIZ_LISTELERI,
  ...CARI_LISTELERI,
  ...TICARI_LISTELERI,
  ...STOK_LISTELERI,
  ...ECZANE_LISTELERI,
  ...BIYOMEDIKAL_LISTELERI,
  ...SATINALMA_LISTELERI,
  ...YONETIM_LISTELERI,
  // Grup basina "📊 Dökümler" baglantisi (plan kural 2): her grubun sonunda
  //   ayni oge - kullanici "bu isin dokumu nerede" diye aramasin.
  ...DOKUM_LISTELERI,
] as (ListeTanimi & { menuAd: string; ic: string; yetkiKodu: string; menuGrup?: string })[];


/**
 * MENU GRUBU -> MODUL (359). Listeye ayri ayri `modul` yazmak yerine grubun
 * varsayilani kullanilir; istisna olan liste kendi `modul` alanini verir.
 *
 * Burada OLMAYAN grup (Yonetim, Ana Sayfa...) hicbir kuruluma kapatilamaz:
 * ayar ve kullanici ekranlari her zaman erisilebilir kalmali - yoksa kapatilan
 * modul geri acilamazdi.
 */
export const MENU_GRUP_MODUL: Record<string, string> = {
  'Kayıt Kabul':   'kayit_kabul',
  'Randevu':       'randevu',
  'Radyoloji':     'radyoloji',
  // GOZ (691): kendi modulu - goz klinigi olmayan kurumda menu grubu hic
  //   cizilmesin. Muayene moduluyle birlestirilseydi, muayene acikken goz
  //   ekranlari da acilirdi.
  'Göz':           'goz',
  // YATAN HASTA (695): kendi modulu - yatan hasta kabul etmeyen kurumda
  //   (poliklinik, goruntuleme merkezi) menu grubu hic cizilmesin.
  'Yatan Hasta':   'yatan_hasta',
  // DIS (706): kendi modulu - dis klinigi olmayan kurumda grup cizilmez.
  'Diş':           'dis',
  // FTR (719): fizik tedavi modulu - ftr kapali kurumda grup cizilmez.
  'FTR':           'ftr',
  // AMELIYATHANE (715) / ACIL (716): kendi modulleri - ameliyathanesi ya da
  //   acili olmayan kurumda menu grubu hic cizilmesin. Bagli olmasalardi
  //   hicbir kuruluma kapatilamazlardi ve poliklinige olmayan bir yetenek
  //   vaat edilirdi.
  'Ameliyathane':  'ameliyathane',
  'Acil':          'acil',
  'Prim':          'prim',
  'Stok & Hizmet': 'stok',
  // ECZANE (722) / SATINALMA (724): kendi modulleri - hastane eczanesi ya da
  //   satinalma birimi olmayan kurumda menu grubu hic cizilmesin. Biyomedikal
  //   (723) BURADA YOK: ekranlari Demirbas grubunda ve `urunModu: 2` ile
  //   suzuluyor - ERP demirbas ekrani hicbir kurulumda kapatilamamali.
  'Eczane':        'eczane',
  'Satınalma':     'satinalma',
  // Kasa + Banka = FINANS (menu yeniden duzeni): iki grup tek modulun
  //   (kasa) altindaydi zaten, birlesince esleme de tek satira dustu.
  'Finans':        'kasa',
  'Muhasebe':      'muhasebe',
  'Satış':         'erp_satis',
  'Alış':          'erp_satis',
  // 'İletişim & AI' grubu kalkti: Mesajlar ve AI ust cubukta (arac, is akisi
  //   degil). Mesaj modulu kapaliysa ust cubuk dugmesi cizilmez.
  'Üretim':        'uretim',
  // e-Nabiz ekranlari MUAYENE modulune yazilmisti (kopyala-yapistir):
  //   kurum profilinden "e-Nabız" kapatilinca menude kalmaya devam
  //   ediyordu (kullanici). Grup varsayilani da eklendi - bu gruba
  //   ileride eklenen liste `modul` yazmayi unutsa bile dogru module
  //   baglanir.
  'e-Nabız':       'enabiz',
  'Laboratuvar':   'lab',
  'Muayene':       'muayene',
  // Dokuman ekranlari Yonetim > Dokuman alt grubuna tasindi; modul suzmesi
  //   artik LISTENIN KENDI `modul` alanindan gelir (grup Yonetim, ve Yonetim
  //   hicbir kuruluma kapatilamaz - kapatilan modul geri acilamazdi).
};

/**
 * Liste bu kurulumda gorunur mu (359). `acikModuller` giris/`/ben` yanitindan
 * gelir; bos dizi = bilgi yok demektir ve HICBIR SEY suzulmez (eski kurulumda
 * profil satiri olmayabilir - ekranin kaybolmasindansa gorunmesi yeglenir).
 */
export function modulAcikMi(l: ListeTanimi & { menuGrup?: string },
                            acikModuller?: readonly string[]) {
  if (!acikModuller || acikModuller.length === 0) return true;
  const kod = l.modul ?? (l.menuGrup ? MENU_GRUP_MODUL[l.menuGrup] : undefined);
  return !kod || acikModuller.includes(kod);
}
