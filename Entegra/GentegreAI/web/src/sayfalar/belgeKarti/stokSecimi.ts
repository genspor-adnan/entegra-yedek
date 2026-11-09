import { api } from '../../api/istemci';
import type { SatirDurumu } from '../belgeSatir';
import { dovizKuruUygula, kampanyaFiyatiUygula, sonAnahtar, stokSecimindenKalem } from '../belgeKalem';
import { hamSayi } from '../../bilesenler/bicim';
import type { BasvuruBilgi } from '../../bilesenler/belge/BasvuruSekmesi';

/**
 * ARAMA PENCERESINDEN SECILEN STOK/HIZMETI KALEME CEVIRIR.
 *
 * FIYAT LISTESI ONCELIKLI (205/207): belgenin listesi varsa fiyat ORADAN
 * gelir; kartin kendi fiyati yalniz listede kalem yoksa kalir.
 *
 * SOZLESMELI BASVURUDA LISTE OLMASA DA SORULUR (483): uc yalniz fiyati degil
 * ROTAYI da doner - TSS'de kalemin bir de SGK (SUT) bedeli var ve sozlesmenin
 * tarife listesi bos olsa bile o bedel sorulmali.
 *
 * `BelgeKarti` govdesinden ayrildi: fiyat cozumleme kurali kartin durumundan
 * bagimsiz ve tek basina okunabilir.
 */
export async function stokSeciminiCoz(
  sec: Record<string, unknown>,
  baglam: {
    satirlar: SatirDurumu[];
    yerelPara: string;
    tarafId: number | null;
    odeyenKurumId: number | null;
    fiyatListesiId: number | null;
    kampanyaId: number | null;
    basvuruBilgi: BasvuruBilgi;
    /** Belge tarihi (kur günü) ve yönü (alışta alış kuru) - dövizli liste fiyatının yerel karşılığı için. */
    belgeTarihi?: string;
    alisMi?: boolean;
  },
): Promise<SatirDurumu> {
  const { satirlar, yerelPara, tarafId, odeyenKurumId,
          fiyatListesiId, kampanyaId, basvuruBilgi, belgeTarihi, alisMi } = baglam;

  // Secim "Son / Sik Aranan" sayacina islensin - listede oldugu gibi.
  void api.aramaIsaretle(sec.tip === 'hizmet' ? 'hizmet' : 'stok', Number(sec.id));
  let yeni = stokSecimindenKalem(sec, sonAnahtar(satirlar) + 1, yerelPara);

  if (fiyatListesiId || kampanyaId || basvuruBilgi.sozlesmeId) {
    try {
      // Fiyat LISTE + KAMPANYA (274): baz listeden, indirim kampanyadan.
      //   Kampanya yoksa uc liste fiyatini doner.
      const f = await api.fiyatKalem(
        sec.tip === 'hizmet' ? { hizmetId: Number(sec.id) } : { stokId: Number(sec.id) },
        { tarafId, kurumId: odeyenKurumId, listeId: fiyatListesiId,
          // SOZLESME (483): rota ve SUT listesi ondan cikar - TSS'de kalemin
          //   bir de SGK bedeli vardir ve pencere onu sorar.
          sozlesmeId: basvuruBilgi.sozlesmeId ?? null,
          sgkKullan: basvuruBilgi.sgkKullan ?? null });
      yeni = kampanyaFiyatiUygula(yeni, f);
    } catch { /* liste fiyati alinamazsa kart fiyati kalir */ }
  }
  // DÖVİZLİ FİYAT -> KUR BURADA (kullanıcı 09.11.2026): yerel karşılık pencere açılmadan da doğru olsun (hızlı
  //   ekleme). Kur alınamazsa satır dövizli kalır; kalem penceresi açılınca yeniden dener, kullanıcı elle girer.
  if (yeni.fiyatDovizi && yeni.fiyatDovizi !== yerelPara && hamSayi(yeni.dovizFiyat) > 0) {
    try {
      const gun = (belgeTarihi || new Date().toISOString()).slice(0, 10);
      const k = await api.dovizKur(yeni.fiyatDovizi, gun, alisMi ? 2 : 1);
      yeni = dovizKuruUygula(yeni, k.kur);
    } catch { /* kur yoksa pencere / kullanıcı */ }
  }
  return yeni;
}
