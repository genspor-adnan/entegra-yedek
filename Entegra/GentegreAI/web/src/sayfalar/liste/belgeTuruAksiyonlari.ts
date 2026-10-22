import { api } from '../../api/istemci';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';

/**
 * İK › BELGE TÜRLERİ LİSTE AKSİYONLARI (mockup personel_belge_turu.html (1)):
 * Kopyala (kapsamıyla) · Pasife al / Aktif et · Sırayı düzenle (pencere Liste'de).
 * Kullanımdaki tür silinmez - pasife alınır (pasif tür kapsam hesabına girmez).
 */
export interface BelgeTuruBaglam {
  tazele(): void;
  kartAc(id: number): void;
  siraAc(): void;
}

export async function belgeTuruAksiyonu(kod: string, satir: ListeSatiri | null | undefined,
                                        b: BelgeTuruBaglam): Promise<boolean> {
  switch (kod) {
    case 'personel-belge-turu.kopyala': {
      if (!satir) return true;
      const ad = String(satir.ad ?? satir.id);
      if (!await onay(`"${ad}" kapsamıyla birlikte kopyalanacak. Yeni türün adı: "Kopya ${ad}".`)) return true;
      await guvenli(async () => {
        const y = await api.belgeTuruKopyala(Number(satir.id));
        b.tazele();
        b.kartAc(y.id);
      });
      return true;
    }
    case 'personel-belge-turu.durum': {
      if (!satir) return true;
      const aktif = Number(satir.aktif) === 1;
      const ad = String(satir.ad ?? satir.id);
      if (!await onay(aktif
        ? `"${ad}" pasife alınsın mı?\nPasif tür kimseye zorunlu sayılmaz; girilmiş belgeler korunur.`
        : `"${ad}" yeniden aktif edilsin mi?`)) return true;
      await guvenli(async () => {
        const y = await api.belgeTuruDurum(Number(satir.id));
        mesaj(y.aktif ? `"${ad}" aktif edildi.` : `"${ad}" pasife alındı.`);
        b.tazele();
      });
      return true;
    }
    case 'personel-belge-turu.sira':
      b.siraAc();
      return true;
    default:
      return false;
  }
}
