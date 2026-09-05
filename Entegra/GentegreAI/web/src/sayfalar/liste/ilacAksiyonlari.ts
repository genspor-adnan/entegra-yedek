import { api } from '../../api/istemci';
import { guvenli, mesaj, metinSor } from '../../bilesenler/mesaj';
import { tutarOku } from '../../bilesenler/bicim';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * ILAC KATALOGU AKSIYONLARI (406/407).
 *
 * Tek is: FIYAT GIRME. Katalogun kendisi TITCK ruhsat listesinden ve SKRS
 * e-Recete listesinden doluyor, SGK Ek-4/A da iskonto oranlarini getiriyor -
 * ama HICBIRI PERAKENDE FIYAT VERMIYOR. Fiyatin resmi kaynagi TITCK Detayli
 * Ilac Fiyat Listesi ve o liste kurumsal portal hesabi istiyor; kapi acilana
 * kadar ilac fiyatsiz kalir, fiyatsiz ilac da belgeye 0 ile duser.
 *
 * Girilen fiyat tarihceye KAYNAK 9 (elle) ile yazilir: resmi liste geldiginde
 * uzerine yazilmaz, hangi tarihte hangi fiyatin gecerli oldugu izlenebilir.
 * Ilaca bagli stok karti varsa satis fiyati da guncellenir - belge satiri
 * fiyati stok fiyat listesinden okunur, ilac tablosundan degil.
 */
export interface IlacBaglam {
  tazele(): void;
}

export async function ilacAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: IlacBaglam,
): Promise<boolean> {
  if (kod !== 'ilac.fiyat') return false;

  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir ilaç seçin.'); return true }

  const ad = String(satir?.ad ?? '');
  const mevcut = Number(satir?.fiyat ?? 0);
  const girilen = await metinSor(
    `${ad}\n\nKDV dahil perakende satış fiyatı:`,
    mevcut > 0 ? String(mevcut).replace('.', ',') : '', 'Fiyat (₺)');
  if (girilen === null) return true;

  // Serbest metin: "1.234,50" da "1234.50" da kabul edilir (tutarOku).
  const fiyat = tutarOku(girilen);
  if (!(fiyat > 0)) { mesaj('Tutar sıfırdan büyük olmalı.'); return true }

  await guvenli(async () => {
    const y = await api.ilacFiyatGir(id, fiyat);
    mesaj(y.stokId
      ? `Fiyat kaydedildi (${y.yururluk}). Stok kartının satış fiyatı da güncellendi.`
      : `Fiyat kaydedildi (${y.yururluk}).`);
    b.tazele();
  });
  return true;
}
