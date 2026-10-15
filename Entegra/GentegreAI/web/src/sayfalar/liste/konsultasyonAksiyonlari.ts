import { api } from '../../api/istemci';
import type { AksiyonBaglami } from './aksiyonOrtak';
import { guvenli, mesaj } from '../../bilesenler/mesaj';
import type { ListeSatiri } from '../../api/sozlesme';
import { KONS_ISLEM_OLAYI } from '../konsultasyon/KonsultasyonPanelleri';

/**
 * KONSÜLTASYON AKSİYONLARI (1107). "✋ Yanıtla" isteği hekime alır ve yanıt muayenesini
 * kendi sekmesinde açar (mockup "üstlen" yerine - kullanıcı). Yönlendir / Reddet gerekçeli
 * pencere ister: pencere listenin üst panelinde (KonsultasyonUstPanel), aksiyon olayla açar.
 */
const KONS_AKSIYONLARI = new Set(['konsultasyon.yanitla', 'konsultasyon.yonlendir', 'konsultasyon.reddet', 'konsultasyon.gordum']);

export async function konsultasyonAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: AksiyonBaglami,
): Promise<boolean> {
  // YALNIZ KENDİ AKSİYONLARI: standart konsultasyon.yeni / .duzenle / .sil genel işleyicide kalır
  //   (kullanıcı 15.10.2026: "yeni ekleyemedim - Önce bir konsültasyon seçin" - yeni de yakalanıyordu).
  if (!KONS_AKSIYONLARI.has(kod)) return false;
  const id = Number(satir?.id ?? 0);
  if (!id) { mesaj('Önce bir konsültasyon seçin.'); return true }
  switch (kod) {
    case 'konsultasyon.yanitla':
      await guvenli(async () => {
        const y = await api.konsultasyonYanitla(id);
        b.tazele();
        b.git(`/muayene/${y.yanitMuayeneId}`);
      });
      return true;
    case 'konsultasyon.yonlendir':
    case 'konsultasyon.reddet':
      window.dispatchEvent(new CustomEvent(KONS_ISLEM_OLAYI,
        { detail: { id, islem: kod === 'konsultasyon.yonlendir' ? 'yonlendir' : 'reddet' } }));
      return true;
    case 'konsultasyon.gordum':
      await guvenli(async () => { mesaj((await api.konsultasyonGordum(id)).mesaj); b.tazele() });
      return true;
  }
  return false;
}
