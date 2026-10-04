/**
 * API YUZU: tum uc sarmalayicilari tek `api` nesnesinde birlesir.
 *
 * Cagri yerleri degismedi (`api.listeAc(...)`); govde konu bazli
 * dosyalara (api/uclar) ayrildi - dosya 2000 satira dayanmisti.
 */
import { kimlikUclari } from './uclar/kimlik';
import { listeUclari } from './uclar/liste';
import { labUclari } from './uclar/lab';
import { sigortaUclari } from './uclar/sigorta';
import { uretimUclari } from './uclar/uretim';
import { kartUclari } from './uclar/kart';
import { belgeUclari } from './uclar/belge';
import { stokUclari } from './uclar/stok';
import { icmalUclari } from './uclar/icmal';
import { radyolojiUclari } from './uclar/radyoloji';
import { gozUclari } from './uclar/goz';
import { yatanUclari } from './uclar/yatan';
import { disUclari } from './uclar/dis';
import { ftrUclari } from './uclar/ftr';
import { formUclari } from './uclar/form';
import { isgUclari } from './uclar/isg';
import { cagriUclari } from './uclar/cagri';
import { sterilUclari } from './uclar/steril';
import { hastaUclari } from './uclar/hasta';
import { medulaUclari } from './uclar/medula';
import { yapayZekaUclari } from './uclar/yapayZeka';
import { mesajUclari } from './uclar/mesaj';
import { ayarUclari } from './uclar/ayar';
import { klinikKaliteUclari } from './uclar/klinikKalite';
import { enabizUclari } from './uclar/enabiz';
import { bzbhUclari } from './uclar/bzbh';
import { asiUclari } from './uclar/asi';
import { cocukIzlemUclari } from './uclar/cocukIzlem';
import { gebelikUclari } from './uclar/gebelik';
import { ameliyathaneUclari } from './uclar/ameliyathane';
import { acilUclari } from './uclar/acil';
import { akisTedarikUclari } from './uclar/akisTedarik';
import { onayUclari } from './uclar/onay';
import { izinUclari } from './uclar/izin';
import { duyuruUclari } from './uclar/duyuru';
import { servisUclari } from './uclar/servis';
import { arizaUclari } from './uclar/ariza';
import { basvuruIstemUclari } from './uclar/basvuruIstem';
import { kasaUclari } from './uclar/kasa';
import { iskontoUclari } from './uclar/iskonto';
import { iceriAlmaUclari } from './uclar/iceriAlma';
import { dokumUclari } from './uclar/dokum';

export { oturum } from './cekirdek';
export type {
  KullaniciSubeSatiri, KartRolBilgisi, RolKullanicisi,
  UtsMesaji, UtsSorguYaniti, UtsBildirimYaniti, UtsBelgeBildirimSatiri,
  UtsBelgeBildirimYaniti, UtsHazirlaAtlanan, UtsHazirlaYaniti,
} from './tipler';

export const api = {
  ...kimlikUclari,
  ...klinikKaliteUclari,
  ...enabizUclari,
  ...bzbhUclari,
  // ASI MODULU (898, KTS H10): uygulama kaydi + USS 207.
  ...asiUclari,
  // BEBEK/COCUK IZLEM (899, KTS H10): izlem + persentil + USS 209.
  ...cocukIzlemUclari,
  // GEBELIK DOSYASI + GEBE IZLEM (900, KTS H10): USS 221.
  ...gebelikUclari,
  ...ameliyathaneUclari,
  ...acilUclari,
  ...akisTedarikUclari,
  ...onayUclari,
  ...izinUclari,
  ...duyuruUclari,
  ...servisUclari,
  ...arizaUclari,
  ...basvuruIstemUclari,
  ...listeUclari,
  ...labUclari,
  ...sigortaUclari,
  ...uretimUclari,
  ...kartUclari,
  ...belgeUclari,
  ...stokUclari,
  ...icmalUclari,
  ...radyolojiUclari,
  ...gozUclari,
  ...yatanUclari,
  ...disUclari,
  ...ftrUclari,
  ...formUclari,
  ...isgUclari,
  ...cagriUclari,
  ...sterilUclari,
  ...hastaUclari,
  ...medulaUclari,
  ...yapayZekaUclari,
  ...mesajUclari,
  ...ayarUclari,
  ...kasaUclari,
  ...iskontoUclari,
  ...iceriAlmaUclari,
  ...dokumUclari,
};
