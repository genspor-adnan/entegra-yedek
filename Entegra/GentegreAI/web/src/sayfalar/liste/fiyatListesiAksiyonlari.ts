import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { dosyaIndirUrl } from '../../bilesenler/indir';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * FIYAT LISTESI AKSIYONLARI (205-207).
 *
 * `Liste.tsx` icindeki dev `aksiyon()` fonksiyonundan konu bazli ayrildi
 * (ÜTS ve kasa ile ayni desen). Donus: aksiyon burada ele alindiysa true.
 */
export interface FiyatListesiBaglam {
  tazele(): void;
  git(yol: string): void;
  /** Excel ile iceri alma modali (207): sablon indir + yukle + hata tablosu. */
  setIceriAl(v: { listeId: number; ad: string }): void;
}

export async function fiyatListesiAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: FiyatListesiBaglam,
): Promise<boolean> {
  switch (kod) {
    // KOPYALA (540): var olan tarifeden yeni tarife - fiyatlar tasinir,
    //   sonra topluca zamlanir. Kopya BAGIMSIZDIR: kaynak sonradan degisse
    //   etkilenmez (turetilmis liste zinciri 539'da sokuldu).
    case 'fiyat-listesi.kopyala': {
      if (!satir) return true;
      const ad = String(satir.ad ?? satir.id);
      if (!await onay(`"${ad}" listesi satırlarıyla kopyalanacak.

`
                    + `Yeni listenin adı: "Kopya ${ad}".`)) return true;
      await guvenli(async () => {
        const y = await api.fiyatListesiKopyala(Number(satir.id));
        mesaj(y.mesaj);
        b.tazele();
      });
      return true;
    }

    case 'fiyat-listesi.satirlar':
      if (satir) b.git(`/fiyat-listesi-satir?listeId=${satir.id}`);
      return true;

    // EXCEL AKISI (207): modal sablon indirme + yukleme + hata tablosunu tasir.
    case 'fiyat-listesi.iceri-al':
      if (satir) b.setIceriAl({ listeId: Number(satir.id), ad: String(satir.ad ?? satir.id) });
      return true;

    case 'fiyat-listesi.sablon':
      if (!satir) return true;
      await guvenli(async () =>
        dosyaIndirUrl(await api.fiyatListesiSablon(Number(satir.id), true),
                      `${String(satir.ad ?? satir.id)}.xlsx`, true));
      return true;

    default:
      return false;
  }
}
