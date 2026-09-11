import { useEffect, useState } from 'react';

/**
 * KAYDEDILMEMIS DEGISIKLIK IZI (kullanici: "başvuruya herhangi bir ekleme veya
 * değişim yaptığımda kaydetmeden kapat dersem uyarsın").
 *
 * Kartin ANLAMLI durumu tek bir metne (imza) cevrilir; kart acilirken ve her
 * BASARILI kayitta bu metin "temiz" kabul edilir. Kapatirken metin farkliysa
 * degisiklik var demektir. Alan alan bayrak tutmak yerine imza kullanildi:
 * yeni alan eklendiginde burasi kendiliginden kapsar.
 *
 * Imza URETIMI saf fonksiyonda (belgeImza.ts) ve TESTLI: sahte fark uretirse
 * kullanici hicbir sey degistirmeden uyari alirdi.
 */
export function useKartKirliligi(imza: string, acilisAnahtari: unknown) {
  const [temiz, setTemiz] = useState<string | null>(null);
  const [tazeleSayaci, setTazeleSayaci] = useState(0);
  /**
   * ACILIS YARISI (kullanici korumasi): kart acilirken bazi alanlar EFEKTLE
   * doluyor - gelis sekli, odeyen kurum varsayilani, fiyat listesi, depo. Bir
   * kismi API cagrisiyla geldigi icin imza hemen alinirsa kart, kullanici hic
   * dokunmadan "kirli" gorunur. Bu yuzden acilistan sonra kisa bir sure imza
   * SUREKLI tazelenir; pencere bitince kullanici degisiklikleri sayilir.
   */
  const [acilisPenceresi, setAcilisPenceresi] = useState(true);

  useEffect(() => {
    setAcilisPenceresi(true);
    const z = window.setTimeout(() => setAcilisPenceresi(false), 1500);
    return () => window.clearTimeout(z);
  }, [acilisAnahtari]);

  useEffect(() => { if (acilisPenceresi) setTemiz(imza) }, [acilisPenceresi, imza]);

  // Her BASARILI kayittan sonra da "temiz" durum yeniden alinir. Sayac
  //   kullanilir cunku kaydi yapan kod daha ESKI imzayi goruyor - bir render
  //   sonra en guncel imza yazilir.
  useEffect(() => { setTemiz(imza) },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [tazeleSayaci]);

  // ACILIS PENCERESI kirli SAYILMAZ: imza tazelemesi effect'lerin bir adim
  //   gerisinde kaldigi icin acilisin ilk render'larinda kart kisa sure
  //   "kirli" gorunuyordu - o anda Kapat'a basan kullanici hicbir sey
  //   degistirmedigi halde uyari aliyordu.
  const kirli = !acilisPenceresi && temiz !== null && temiz !== imza;

  return { kirli, tazele: () => setTazeleSayaci(n => n + 1) };
}
