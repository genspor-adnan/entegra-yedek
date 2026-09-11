import { mesaj } from '../../bilesenler/mesaj';
import { UtsAlmaModali } from '../../bilesenler/uts/UtsAlmaModali';
import { UtsKullanimModali } from '../../bilesenler/uts/UtsBildirimModallari';
import { UtsGenelBildirimModali } from '../../bilesenler/uts/UtsGenelBildirimModali';
import { UtsBelgeSonucModali } from '../../bilesenler/uts/UtsBelgeSonucModali';
import { UtsHazirlaSonucModali } from '../../bilesenler/uts/UtsHazirlaSonucModali';
import type { UtsModalDurumu } from './useUtsModallari';

/**
 * ÜTS MODALLARI - durum `useUtsModallari` kancasinda; burasi yalniz cizim.
 * Sonuc mesajini SUNUCU uretir (hangi urun, kac adet), istemci yalniz gosterir.
 */
export function UtsModallari(
  { m, tazele }: { m: UtsModalDurumu; tazele: () => void },
) {
  return (
    <>
      {m.belgeSonuc && (
        <UtsBelgeSonucModali sonuc={m.belgeSonuc} onKapat={() => m.setBelgeSonuc(null)} />
      )}
      {m.hazirla && (
        <UtsHazirlaSonucModali sonuc={m.hazirla} onKapat={() => m.setHazirla(null)} />
      )}
      {m.genel && (
        <UtsGenelBildirimModali
          tur={m.genel}
          onKapat={() => m.setGenel(null)}
          onTamam={y => { m.setGenel(null); mesaj(y); tazele() }}
        />
      )}
      {m.kullanim && (
        <UtsKullanimModali
          onKapat={() => m.setKullanim(false)}
          onTamam={y => { m.setKullanim(false); mesaj(y); tazele() }}
        />
      )}
      {m.alma && (
        <UtsAlmaModali
          envanterId={m.alma.envanterId}
          urunNo={m.alma.urunNo}
          kurumUnvan={m.alma.kurumUnvan}
          askiAdet={m.alma.askiAdet}
          seriNo={m.alma.seriNo}
          onKapat={() => m.setAlma(null)}
          onTamam={y => { m.setAlma(null); mesaj(y); tazele() }}
        />
      )}
    </>
  );
}
