import { api } from '../../api/istemci';
import { mesaj } from '../../bilesenler/mesaj';
import { hataAyristir, type BelgeYaniti } from '../../api/sozlesme';
import { belgeDogrula, belgeGovdesi, doluSatirlar, type BelgeGirdisi } from '../belgeKaydet';
import { yanittanSatirlar, type SatirDurumu } from '../belgeSatir';

export interface BelgeKaydetmeBaglami {
  /** Kart durumunu tek nesneye toplar - alan derlemesi kartta kalir. */
  girdiKur(): BelgeGirdisi;
  satirlar: SatirDurumu[];
  setSatirlar(s: SatirDurumu[]): void;
  taslak: boolean;
  yerelPara: string;
  /** Kayitli belgenin id'si (0 = henuz yok). */
  etkinBelgeId: number | null;
  /** Kayitli belge yeniden YAZILABILIR mi (e-Belge gitmisse hayir). */
  duzenlenebilir: boolean;
  basvuruMu: boolean;
  sonuc: BelgeYaniti | null;
  setSonuc(y: BelgeYaniti): void;
  setHata(v: string | null): void;
  setAlanHatalari(v: Record<string, string>): void;
  setKaydediyor(v: boolean): void;
  /** Gridde KAYDEDILMEMIS satir degisikligi var mi (ekleme ya da SILME). */
  kalemDegisti: boolean;
  setKalemDegisti(v: boolean): void;
  /** Ilk basvuru kaydinda protokol alinir; kart acik kalir. */
  setAcilanId(id: number): void;
  imzayiTemizle(): void;
  onKaydedildi?(): void;
  kapat(zorla?: boolean): void;
}

/**
 * BELGE KAYDETME AKISI: dogrula -> yaz -> satir kimliklerini tazele -> kapat.
 *
 * `BelgeKarti` govdesinden ayrildi; alan derlemesi (`girdiKur`) ve dogrulama
 * kurallari (belgeKaydet.ts) yerlerinde kaldi - burada yalniz SIRA var. Sirada
 * gizli iki kural, ikisi de sahada yasanmis hatalardan:
 *
 *  - `sonuc` hata durumunda SIFIRLANMAZ: `duzenlenebilir` hesabi `!!sonuc`a
 *    bagli; dogrulama hatasinda null kalinca kart kilitleniyor ve kullanici
 *    hatayi duzeltemiyordu.
 *  - Kayittan sonra satir kimlikleri SUNUCUDAN tazelenir: `satirId` tasinmazsa
 *    ikinci kayitta ayni kalem YENI satir sayilip iki kez yaziliyor (900 + 900
 *    = 1.800) ve acik tutarlar iki kati gorunuyordu.
 */
export function belgeKaydetmeKur(b: BelgeKaydetmeBaglami) {
  return async function kes(kapatilsin = true, otomatik = false): Promise<number> {
    b.setHata(null);
    b.setAlanHatalari({});

    const girdi = b.girdiKur();
    const hatalar = belgeDogrula(girdi);
    if (hatalar) {
      if (hatalar.genel) b.setHata(hatalar.genel);
      else b.setAlanHatalari(hatalar);
      return 0;
    }

    const dolu = doluSatirlar(b.satirlar);
    // OTOMATIK KAYIT SATIR SILMEZ (kullanici: basvuru 114413 iki kez
    //   "satirAdedi: 0" ile guncellendi): kart bir sebeple kalemsiz kalirsa
    //   tahsilat/POS oncesi yapilan kayit sunucudaki ucretleri de siliyordu.
    //   Kullanici Kaydet'e basarsa istegi gecerlidir - yalniz kartin KENDI
    //   kaydi engellenir.
    //
    // AMA KULLANICI SILDIYSE GECERLIDIR (kullanici: "ücretlerde 2 muayene
    //   vardı onları sildim… ücrete gelip ＋'ya basınca 2 satır ve tahakkuk
    //   oluştu, hemen bir şey seçmeden"): gridi BOSALTAN kullanicinin
    //   kendisiydi (`kalemDegisti`), kayit atlaninca silme sunucuya hic
    //   gitmiyor ve ardindan gelen tazeleme satirlari geri getiriyordu -
    //   silinmis satirlar kendiliginden dirilmis gibi gorunuyordu.
    if (otomatik && dolu.length === 0 && !b.kalemDegisti
        && (b.sonuc?.satirlar?.length ?? 0) > 0)
      return b.etkinBelgeId ?? 0;

    b.setKaydediyor(true);
    try {
      const govde = belgeGovdesi(girdi, dolu, b.taslak);

      // DUZENLEME (135): kayitli belge PUT ile yeniden yazilir - numara korunur,
      //   eski stok/cari etkisi sunucuda geri alinip yenisi uygulanir.
      // IKINCI kayit UPDATE olmali: basvuru kartta acik kaldigi icin ayni
      //   dugmeye tekrar basiliyor - etkinBelgeId olmasa her basis yeni belge
      //   uretirdi.
      const yanit = b.duzenlenebilir && b.etkinBelgeId
        ? await api.belgeGuncelle(b.etkinBelgeId, govde)
        : await api.belgeEkle(govde);
      b.setSonuc(yanit);
      if (yanit.satirlar?.length)
        b.setSatirlar(yanittanSatirlar(yanit.satirlar, b.yerelPara));
      // Kayit sonrasi kart TEMIZ sayilir (kaydedilmemis degisiklik uyarisi).
      b.setKalemDegisti(false);
      b.imzayiTemizle();
      b.onKaydedildi?.();

      // GENEL KURAL (kullanici): Kaydet'e basilinca form KAPANIR. Belgeye
      //   sonradan yapilacak isler (e-Belge gonderimi, donusum) listeden belge
      //   yeniden acilarak surdurulur - kart acik birakmak "kaydettim mi?"
      //   belirsizligi yaratiyordu. Tek istisna "kaydet ve devam et".
      const yeniId = Number(yanit.belge.id ?? 0);
      // BASVURU akisi (300): ilk kayit KAPATMAZ - protokol verilir, kart acik
      //   kalir; ucretlendirme ve provizyon girildikten sonra ayni dugmeyle
      //   kaydedilip kapatilir.
      if (b.basvuruMu && !b.etkinBelgeId && yeniId) { b.setAcilanId(yeniId); return yeniId }
      if (kapatilsin) b.kapat(true);
      return yeniId;
    } catch (h) {
      const c = hataAyristir(h);
      b.setAlanHatalari(c.alanlar);
      b.setHata(c.mesaj);
      // KAYIT DUSTUYSE MESAJ DA CIKAR (kullanici: "değişiklik kaydet
      //   basıyorum ama kaydetmiyor"): sunucunun is kurali uyarisi
      //   ("Kurumun 3 sözleşmesi var - hangisinin geçerli olduğunu seçin")
      //   yalniz ilgili alanin altinda kirmizi yaziydi ve kullanici BASKA
      //   SEKMEDEYSE hic gormuyordu - dugme calismamis gibi duruyordu.
      if (c.mesaj) mesaj(c.mesaj);
    } finally {
      b.setKaydediyor(false);
    }
    return 0;
  };
}
