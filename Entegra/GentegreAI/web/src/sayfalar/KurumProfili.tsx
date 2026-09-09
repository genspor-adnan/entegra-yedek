import { KurumTipiAyarlari } from '../bilesenler/KurumTipiAyarlari';

/**
 * KURUM PROFILI (Yonetim › Kurum Profili).
 *
 * FIRMA BILGILERI'NIN SEKMESIYDI, KENDI EKRANI OLDU (kullanici): firma
 * bilgileri sube KIMLIGINI (unvan, VKN, adres, e-Belge) anlatir; kurum
 * profili ise KURULUMU belirler - urun modu, kurum tipi, acik moduller,
 * kayit/ucretlendirme kurallari. Ikisi ayni ekranda durunca profil bir
 * "sube ayari" gibi gorunuyordu; menude ayri satir olmasi da onu daha
 * bulunur yapar.
 *
 * Icerik degismedi: bilesen aynen KurumTipiAyarlari.
 */
export function KurumProfili() {
  return (
    <>
      <div className="sayfabas" style={{ marginBottom: 10 }}>
        <div className="basrow">
          <h1>Kurum Profili</h1>
          <span className="yol">Yönetim › Kurum Profili</span>
        </div>
      </div>
      <KurumTipiAyarlari />
    </>
  );
}
