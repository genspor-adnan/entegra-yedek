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
export async function konsultasyonAksiyonu(
  kod: string,
  satir: ListeSatiri | null | undefined,
  b: AksiyonBaglami,
): Promise<boolean> {
  if (!kod.startsWith('konsultasyon.')) return false;
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
