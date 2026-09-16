import { api } from '../../api/istemci';
import { hataMetni, type ListeSatiri } from '../../api/sozlesme';
import { guvenli, mesaj, metinSor, onay } from '../../bilesenler/mesaj';
import type { AmeliyatAdimi } from '../../api/uclar/ameliyathane';

/**
 * AMELİYATHANE LİSTE AKSİYONLARI (715/719 uçları).
 *
 * ALTI ZAMAN DAMGASI TEK YOLDAN GEÇER (`api.ameliyatAdim`): sıra kuralı,
 * time-out kapısı ve sayım uyarısı sunucuda. İstemci hangi adımın geçerli
 * olduğunu KENDİ karar vermiyor - iki yerde karar verilseydi, ekranın izin
 * verip sunucunun reddettiği (ya da tersi) durumlar çıkardı.
 *
 * SUNUCU REDDEDİNCE SORUYORUZ, SESSİZCE ZORLAMIYORUZ. İki red kullanıcıya
 * geri dönüyor:
 *   "zaten kaydedilmiş"  -> düzeltme mi? (`duzelt`)
 *   "time-out tamamlanmadı" -> gerekçe iste (`zorla` + gerekçe)
 * Zorlamayı baştan göndermek kuralı süse çevirirdi; hiç sormamak ise acil
 * vakada ekibi kayıt tutmamaya iterdi.
 */
export interface AmeliyathaneBaglam {
  tazele(): void;
  /** Talepten ameliyat doğuran modal. */
  planlaAc(v: {
    talepId: number; talepNo?: string; hastaAdi?: string; islem?: string;
    tahminiSure?: number; eksikler?: string;
  }): void;
  /** Güvenli cerrahi kontrol listesi modalı. */
  kontrolAc(v: { ameliyatId: number; ameliyatNo?: string }): void;
  /** Fatura & stok modalı (720) - iki iş, iki ayrı düğme. */
  faturaAc(v: { ameliyatId: number; ameliyatNo?: string }): void;
}

/** Aksiyon kodu -> akış adımı. Katalogdaki kodlar ile uçtaki adlar burada eşleşir. */
const ADIMLAR: Record<string, { adim: AmeliyatAdimi; ad: string }> = {
  'ameliyat.salona-al': { adim: 'salona-alma', ad: 'Salona alma' },
  'ameliyat.anestezi': { adim: 'anestezi', ad: 'Anestezi başlangıcı' },
  'ameliyat.kesi': { adim: 'kesi', ad: 'Kesi' },
  'ameliyat.kapanis': { adim: 'kapanis', ad: 'Kapanış başlangıcı' },
  'ameliyat.bitis': { adim: 'bitis', ad: 'Ameliyat bitişi' },
  'ameliyat.cikis': { adim: 'cikis', ad: 'Salondan çıkış' },
};

export async function ameliyathaneAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: AmeliyathaneBaglam,
): Promise<boolean> {
  const bizim = kod.startsWith('ameliyat.') || kod.startsWith('ameliyat-talep.')
             || kod.startsWith('ameliyat-salon.');
  if (!bizim) return false;
  // CRUD kodlari (yeni / duzenle / sil) genel makinede kalir.
  if (kod.endsWith('.yeni') || kod.endsWith('.duzenle') || kod.endsWith('.sil')) return false;

  // ------------------------------------------------------ talebi planla ----
  if (kod === 'ameliyat-talep.planla') {
    const talepId = Number(satir?.id ?? 0);
    if (!talepId) { mesaj('Önce bir talep seçin.'); return true }
    b.planlaAc({
      talepId,
      talepNo: satir?.talepNo ? String(satir.talepNo) : undefined,
      hastaAdi: satir?.hastaAd ? String(satir.hastaAd) : undefined,
      islem: satir?.islemAd ? String(satir.islemAd) : undefined,
      tahminiSure: Number(satir?.tahminiSure ?? 0),
      // Liste "eksikler" kolonunu zaten hesaplıyor; modal aynı metni gösterir
      //   ki kullanıcı redde takılmadan önce görsün.
      eksikler: satir?.eksikler ? String(satir.eksikler) : undefined,
    });
    return true;
  }

  // -------------------------------------------------- kontrol listesi ----
  if (kod === 'ameliyat.kontrol') {
    const id = Number(satir?.id ?? 0);
    if (!id) { mesaj('Önce bir ameliyat seçin.'); return true }
    b.kontrolAc({
      ameliyatId: id,
      ameliyatNo: satir?.ameliyatNo ? String(satir.ameliyatNo) : undefined,
    });
    return true;
  }

  // ------------------------------------------------------ fatura & stok ----
  // TEK DÜĞME, MODALDE İKİ İŞ: faturalama ve stok düşümü ayrı yetki ister ve
  //   ayrı deftere yazar; tek tıkla ikisini birden yapsaydık faturayı
  //   onaylayan kişi farkında olmadan depo sayımını da değiştirirdi.
  if (kod === 'ameliyat.fatura') {
    const id = Number(satir?.id ?? 0);
    if (!id) { mesaj('Önce bir ameliyat seçin.'); return true }
    b.faturaAc({
      ameliyatId: id,
      ameliyatNo: satir?.ameliyatNo ? String(satir.ameliyatNo) : undefined,
    });
    return true;
  }

  // -------------------------------------------------------- akış adımı ----
  const adimTanim = ADIMLAR[kod];
  if (adimTanim) {
    const id = Number(satir?.id ?? 0);
    if (!id) { mesaj('Önce bir ameliyat seçin.'); return true }
    await adimYaz(id, adimTanim.adim, adimTanim.ad, b);
    return true;
  }

  // ------------------------------------------------------------ iptal ----
  if (kod === 'ameliyat.iptal') {
    const id = Number(satir?.id ?? 0);
    if (!id) { mesaj('Önce bir ameliyat seçin.'); return true }
    // NEDEN ZORUNLU: iptal edilen vaka masa kullanımı raporuna girer; nedensiz
    //   iptal "neden yapılmadı" sorusunu yanıtsız bırakır.
    const neden = await metinSor('Ameliyat neden iptal ediliyor?', '', 'İptal nedeni');
    if (!neden || !neden.trim()) return true;
    if (!await onay('Ameliyat iptal edilsin mi? Kayıt silinmez, durumu "İptal" olur '
                  + 've talep bekleyen listesine geri döner.', true)) return true;
    await guvenli(async () => {
      const y = await api.ameliyatIptal(id, neden.trim());
      mesaj('Ameliyat iptal edildi.'
          + (y.talepGeriAlindi ? ' Talep bekleyen listesine döndü.' : ''));
      b.tazele();
    });
    return true;
  }

  // ------------------------------------------------------ notu imzala ----
  if (kod === 'ameliyat.not-imzala') {
    const id = Number(satir?.id ?? 0);
    if (!id) { mesaj('Önce bir ameliyat seçin.'); return true }
    // İMZA GERİ ALINAMAZ: tehlikeli onay, çünkü imzadan sonra not gövdesi
    //   veritabanı kuralıyla kilitlenir (719) - yalnız ek not yazılabilir.
    if (!await onay('Ameliyat notu imzalansın mı?\n\n'
                  + 'İmzadan sonra not DEĞİŞTİRİLEMEZ; sonradan gelen bilgi '
                  + 'yalnız "ek not" alanına yazılabilir.', true)) return true;
    await guvenli(async () => {
      await api.ameliyatNotImzala(id);
      mesaj('Ameliyat notu imzalandı.');
      b.tazele();
    });
    return true;
  }

  return false;
}

/**
 * Adımı yazar; sunucunun iki reddini kullanıcıya soruya çevirir.
 *
 * UYARILAR HATA DEĞİL: sayım uyuşmazlığı kaydı engellemez ama söylenmeden de
 * geçilmez - engellemek ekibi damgayı hiç yazmamaya iter (716 ilkesi).
 */
async function adimYaz(id: number, adim: AmeliyatAdimi, ad: string,
                       b: AmeliyathaneBaglam,
                       ek: { duzelt?: boolean; zorla?: boolean; gerekce?: string } = {}) {
  try {
    const y = await api.ameliyatAdim(id, adim, ek);
    const saat = new Date(y.zaman).toLocaleTimeString('tr-TR',
      { hour: '2-digit', minute: '2-digit' });
    mesaj(`${ad}: ${saat}`
        + (y.uyarilar?.length ? `\n\n⚠ ${y.uyarilar.join('\n⚠ ')}` : ''));
    b.tazele();
  } catch (h) {
    const m = hataMetni(h);

    if (m.includes('zaten kaydedilmiş') && !ek.duzelt) {
      if (await onay(`${ad} zaten kaydedilmiş.\n\n`
                   + 'Saati DÜZELTMEK istiyor musunuz? Düzeltme işlem '
                   + 'günlüğüne yazılır.', true))
        await adimYaz(id, adim, ad, b, { ...ek, duzelt: true });
      return;
    }

    if (m.includes('Time-out') && !ek.zorla) {
      if (!await onay(`${m}\n\n`
                    + 'Time-out tamamlanmadan kesi kaydedilmesi olağandışıdır. '
                    + 'Yine de devam edilsin mi?', true)) return;
      const gerekce = await metinSor('Time-out neden atlandı?', '', 'Gerekçe');
      if (!gerekce || !gerekce.trim()) return;
      await adimYaz(id, adim, ad, b, { ...ek, zorla: true, gerekce: gerekce.trim() });
      return;
    }

    mesaj(m);
  }
}
