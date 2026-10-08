import { useCallback, useEffect, useRef, useState } from 'react';
import { useOturum } from '@web/kimlik/OturumBaglami';
import { KurumTipiAyarlari } from '@web/bilesenler/KurumTipiAyarlari';
import { hataMetni } from '@web/api/sozlesme';
import { Ust } from './Ust';
import type { Baglanti } from './Giris';

/**
 * Bağlı sunucunun kurum profili. Bağlantı ekranından gelen kullanıcı/parola
 * ile **bir kez** giriş yapar, sonra web ürünündeki ekranın kendisini çizer -
 * bu araç ayrı bir profil ekranı taşımaz.
 *
 * "Kaydet ve Çık" GERÇEKTEN KAYDEDER: `KurumTipiAyarlari` ana kaydetme
 * işlevini `kaydetBagla` ile veriyor, şerit onu çağırıp sonra çıkıyor. Daha
 * önce bu düğme yalnız oturumu kapatıyordu; adı kaydettiğini söylerken
 * kaydetmemesi, teknisyene işini yapmış izlenimi veren bir yalandı.
 */
export function Profil({ baglanti, onKop, onGirisHatasi }: {
  baglanti: Baglanti;
  onKop(): void;
  /** Giriş tutmazsa bağlantı ekranına dön: adres ya da parola yanlış olabilir. */
  onGirisHatasi(mesaj: string): void;
}) {
  const { kullanici, yukleniyor, oturumHatasi, girisYap, cikisYap } = useOturum();
  const [bekle, setBekle] = useState(true);
  const [kaydediyor, setKaydediyor] = useState(false);
  const denendi = useRef(false);

  // Ana kaydetme işlevi ekrandan gelir; şerit düğmesi onu çağırır.
  const anaKaydet = useRef<(() => Promise<void>) | null>(null);
  const kaydetBagla = useCallback(
    (fn: (() => Promise<void>) | null) => { anaKaydet.current = fn }, []);

  // TEK DENEME (`denendi`): giriş tutmazsa döngüye girmesin - yanlış parolayla
  //   her render'da yeniden denemek hesabı kilitlerdi.
  useEffect(() => {
    if (denendi.current || kullanici) { setBekle(false); return }
    denendi.current = true;
    (async () => {
      try { await girisYap(baglanti.kod, baglanti.parola) }
      catch (h) { onGirisHatasi(hataMetni(h)) }
      finally { setBekle(false) }
    })();
  }, [baglanti.kod, baglanti.parola, girisYap, kullanici, onGirisHatasi]);

  const cik = useCallback(async (kaydet: boolean) => {
    if (kaydet && anaKaydet.current) {
      setKaydediyor(true);
      try { await anaKaydet.current() }
      // KAYIT TUTMAZSA ÇIKMAYIZ: ekran hatayı kendi gösteriyor, teknisyen
      //   düzeltip yeniden denesin - sessizce çıkmak değişikliği kaybettirirdi.
      catch { setKaydediyor(false); return }
      setKaydediyor(false);
    }
    try { await cikisYap() } catch { /* bağlantı koptuysa yerel temizlik yeter */ }
    onKop();
  }, [cikisYap, onKop]);

  const ust = (
    <Ust adres={baglanti.adres} kullanici={kullanici?.ad || kullanici?.kod}
         kaydediyor={kaydediyor}
         onKaydetCik={kullanici ? () => void cik(true) : undefined}
         onCik={() => void cik(false)} />
  );

  if (bekle || yukleniyor)
    return <div className="gp-kok">{ust}<div className="gp-govde sonuk">Bağlanıyor…</div></div>;

  if (oturumHatasi)
    return (
      <div className="gp-kok">{ust}
        <div className="gp-govde"><div className="gp-hata">{oturumHatasi}</div></div>
      </div>
    );

  if (!kullanici)
    return (
      <div className="gp-kok">{ust}
        <div className="gp-govde sonuk">Oturum açılamadı; sunucuyu değiştirip yeniden deneyin.</div>
      </div>
    );

  return (
    <div className="gp-kok">{ust}
      <div className="gp-govde"><KurumTipiAyarlari kaydetBagla={kaydetBagla} /></div>
    </div>
  );
}
