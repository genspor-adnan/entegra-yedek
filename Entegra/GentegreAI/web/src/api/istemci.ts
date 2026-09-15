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
import { yapayZekaUclari } from './uclar/yapayZeka';
import { mesajUclari } from './uclar/mesaj';
import { ayarUclari } from './uclar/ayar';
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
  ...yapayZekaUclari,
  ...mesajUclari,
  ...ayarUclari,
  ...kasaUclari,
  ...iskontoUclari,
  ...iceriAlmaUclari,
  ...dokumUclari,
};
