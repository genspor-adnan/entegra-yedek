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
import { bankoOturumUclari } from './uclar/bankoOturum';
import { demirbasZimmetUclari } from './uclar/demirbasZimmet';
import { hastaIcmalUclari } from './uclar/hastaIcmal';
import { kurumIcmalUclari } from './uclar/kurumIcmal';
import { vezneIcmalUclari } from './uclar/vezneIcmal';
import { medulaMutabakatUclari } from './uclar/medulaMutabakat';
import { aktarimProfilUclari, aktarimUclari } from './uclar/aktarim';
import { alacakYaslandirmaUclari } from './uclar/alacakYaslandirma';
import { hastaBorcUclari } from './uclar/hastaBorc';
import { hekimPerformansUclari } from './uclar/hekimPerformans';
import { iskontoIcmalUclari } from './uclar/iskontoIcmal';
import { maliyetIcmalUclari } from './uclar/maliyetIcmal';
import { sevkEdenUclari } from './uclar/sevkEden';
import { labIcmalUclari } from './uclar/labIcmal';
import { goruntulemeIcmalUclari } from './uclar/goruntulemeIcmal';
import { disaAktarUclari } from './uclar/disaAktar';
import { yatanIcmalUclari } from './uclar/yatanIcmal';
import { kasaGunSonuUclari } from './uclar/kasaGunSonu';
import { cagriIcmalUclari } from './uclar/cagriIcmal';
import { sterilIcmalUclari } from './uclar/sterilIcmal';
import { ameliyathaneIcmalUclari } from './uclar/ameliyathaneIcmal';
import { disIcmalUclari } from './uclar/disIcmal';
import { eczaneIcmalUclari } from './uclar/eczaneIcmal';
import { ftrIcmalUclari } from './uclar/ftrIcmal';
import { isgIcmalUclari } from './uclar/isgIcmal';
import { kysPanoUclari } from './uclar/kysPano';
import { kysAyarUclari } from './uclar/kysAyar';
import { kysEgitimUclari } from './uclar/kysEgitim';
import { kysPolitikaUclari } from './uclar/kysPolitika';
import { kaliteIcmalUclari } from './uclar/kaliteIcmal';
import { randevuIcmalUclari } from './uclar/randevuIcmal';
import { efaturaUclari } from './uclar/efatura';
import { efaturaIcmalUclari } from './uclar/efaturaIcmal';
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
import { demoUclari } from './uclar/demo';
import { radyolojiTanimUclari } from './uclar/radyolojiTanim';
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
  ...demoUclari,
  ...radyolojiTanimUclari,
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
  ...bankoOturumUclari,
  ...demirbasZimmetUclari,
  ...hastaIcmalUclari,
  ...kurumIcmalUclari,
  ...vezneIcmalUclari,
  ...medulaMutabakatUclari,
  ...aktarimUclari,
  ...aktarimProfilUclari,
  ...alacakYaslandirmaUclari,
  ...hastaBorcUclari,
  ...hekimPerformansUclari,
  ...iskontoIcmalUclari,
  ...maliyetIcmalUclari,
  ...sevkEdenUclari,
  ...labIcmalUclari,
  ...goruntulemeIcmalUclari,
  ...disaAktarUclari,
  ...yatanIcmalUclari,
  ...kasaGunSonuUclari,
  ...cagriIcmalUclari,
  ...sterilIcmalUclari,
  ...ameliyathaneIcmalUclari,
  ...disIcmalUclari,
  ...eczaneIcmalUclari,
  ...ftrIcmalUclari,
  ...isgIcmalUclari,
  ...kysPanoUclari,
  ...kysAyarUclari,
  ...kysEgitimUclari,
  ...kysPolitikaUclari,
  ...kaliteIcmalUclari,
  ...randevuIcmalUclari,
  ...efaturaUclari,
  ...efaturaIcmalUclari,
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
