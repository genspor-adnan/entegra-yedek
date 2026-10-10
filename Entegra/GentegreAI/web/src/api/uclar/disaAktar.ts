import type { ExcelBlok } from '../../bilesenler/cikti/ciktiDonustur';
import { gonderDosya } from '../cekirdek';

/** Çıktı menüsü "Gönder › Excel" ucu (DisaAktarUclari). */
export const disaAktarUclari = {
  /** A4 belgesinin blokları (antet, başlık, bilgi, tablo, özet, not) → biçimli .xlsx. */
  disaAktarExcel: (govde: { dosyaAdi: string; sayfaAdi: string; bloklar: ExcelBlok[] }) =>
    gonderDosya('/api/disa-aktar/excel', govde),
};
