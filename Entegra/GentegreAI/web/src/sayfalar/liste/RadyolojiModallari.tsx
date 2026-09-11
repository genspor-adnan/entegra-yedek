import { api } from '../../api/istemci';
import { guvenli } from '../../bilesenler/mesaj';
import { TarafArama } from '../../bilesenler/TarafArama';
import { IstemModali } from '../../bilesenler/radyoloji/IstemModali';
import { TeslimModali } from '../../bilesenler/radyoloji/TeslimModali';
import { RandevuModali } from '../../bilesenler/radyoloji/RandevuModali';
import { KritikBildirimModali } from '../../bilesenler/radyoloji/KritikBildirimModali';
import { KonsultasyonCevapModali }
  from '../../bilesenler/radyoloji/KonsultasyonCevapModali';
import { CihazKapatmaModali } from '../../bilesenler/radyoloji/CihazKapatmaModali';
import { SarfOnayModali } from '../../bilesenler/radyoloji/SarfOnayModali';
import type { RadyolojiModalDurumu } from './useRadyolojiModallari';

/**
 * RADYOLOJI EKRAN MODALLARI - hepsi `Liste` govdesinde yan yana duruyordu.
 * Durum `useRadyolojiModallari` kancasinda; burasi yalniz cizim ve kapanis.
 */
export function RadyolojiModallari(
  { m, tazele }: { m: RadyolojiModalDurumu; tazele: () => void },
) {
  return (
    <>
      {/* RADYOLOJI ISTEM (304): once hasta, sonra tetkikler. Listeden acilan
          istem DIS istemdir - ic istem basvuru kartindan acilir. */}
      <TarafArama
        acik={m.hastaArama}
        kaynaklar={['hasta']}
        yerTutucu="Hastayı isim/tel ile ara…"
        onKapat={() => m.setHastaArama(false)}
        onSec={sec => {
          m.setHastaArama(false);
          m.setIstem({ hastaId: sec.id, hastaAdi: sec.unvan, disIstem: true });
        }}
      />
      {m.istem && (
        <IstemModali
          acik
          hastaId={m.istem.hastaId}
          hastaAdi={m.istem.hastaAdi}
          disIstem={m.istem.disIstem}
          randevuId={m.istem.randevuId ?? null}
          onSeciliHizmetId={m.istem.hizmetId ?? null}
          onKapat={() => m.setIstem(null)}
          onTamam={(_a, sonuc) => {
            // RANDEVUDAN KABUL (317): acilan basvuru randevuya baglanir, randevu
            //   "Geldi"ye cekilir - takvim, basvuru ve istem ayni olayi gosterir.
            const rid = m.istem?.randevuId;
            if (rid && sonuc?.belgeId) {
              void guvenli(async () => {
                const mevcut = await api.kartOku('randevu', rid);
                await api.kartGuncelle('randevu', rid, {
                  surum: mevcut.kart.surum,
                  kart: { belgeId: sonuc.belgeId, durum: 2 },
                });
              });
            }
            tazele();
          }}
        />
      )}
      {m.sarf && (
        <SarfOnayModali
          istemId={m.sarf.istemId}
          accessionNo={m.sarf.accessionNo}
          tetkikAdi={m.sarf.tetkikAdi}
          onKapat={() => m.setSarf(null)}
          onTamam={tazele}
        />
      )}

      {m.kapatma && (
        <CihazKapatmaModali
          cihazId={m.kapatma.cihazId}
          cihazAdi={m.kapatma.cihazAdi}
          baslangic={m.kapatma.baslangic}
          bitis={m.kapatma.bitis}
          onKapat={() => m.setKapatma(null)}
          onTamam={tazele}
        />
      )}

      {m.kritik && (
        <KritikBildirimModali
          istemId={m.kritik.istemId}
          accessionNo={m.kritik.accessionNo}
          hasta={m.kritik.hasta}
          tetkik={m.kritik.tetkik}
          bulgu={m.kritik.bulgu}
          bildirilenAd={m.kritik.bildirilenAd}
          onKapat={() => m.setKritik(null)}
          onTamam={tazele}
        />
      )}

      {m.konsultasyon && (
        <KonsultasyonCevapModali
          istemId={m.konsultasyon.istemId}
          konsultasyonId={m.konsultasyon.konsultasyonId}
          accessionNo={m.konsultasyon.accessionNo}
          hasta={m.konsultasyon.hasta}
          tetkik={m.konsultasyon.tetkik}
          soru={m.konsultasyon.soru}
          mevcutGorus={m.konsultasyon.gorus}
          onKapat={() => m.setKonsultasyon(null)}
          onTamam={tazele}
        />
      )}

      {m.randevu && (
        <RandevuModali
          istemId={m.randevu.istemId}
          accessionNo={m.randevu.accessionNo}
          tetkikAdi={m.randevu.tetkikAdi}
          modalite={m.randevu.modalite}
          sureDk={m.randevu.sureDk}
          onKapat={() => m.setRandevu(null)}
          onTamam={tazele}
        />
      )}

      {m.teslim && (
        <TeslimModali
          istemId={m.teslim.istemId}
          accessionNo={m.teslim.accessionNo}
          cdIstendi={m.teslim.cdIstendi}
          onKapat={() => m.setTeslim(null)}
          onTamam={tazele}
        />
      )}
    </>
  );
}
