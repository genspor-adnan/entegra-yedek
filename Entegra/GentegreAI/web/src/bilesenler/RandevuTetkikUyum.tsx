import { useEffect, useRef, useState } from 'react';
import { api } from '../api/istemci';

/**
 * RANDEVU KARTINDA TETKİK-CİHAZ UYUMU (317).
 *
 * Hasta çoğunlukla kuruma gelmeden randevu alır: yanlış cihaza yazılan randevu
 * ancak hasta geldiğinde fark edilir, o da hastanın boşuna gelmesi demektir.
 * Bu yüzden kart, tetkik seçilir seçilmez iki şey yapar:
 *   1) süreyi çekim protokolünden (314) doldurur - kart varsayılanı 15 dk her
 *      tetkik için yanlış (MR 30, röntgen 10),
 *   2) tetkikin modalitesi seçili cihazla uyuşmuyorsa uyarır.
 * Engelleme veritabanı tetiğindedir (317) - burası yalnız erken uyarı.
 */

interface Cihaz { id: number; ad: string; modalite: number }

export function RandevuTetkikUyum({ hizmetId, cihazId, sureDk, onSure }: {
  hizmetId: number | null;
  cihazId: number | null;
  sureDk: number;
  /** Protokol süresi geldiğinde kartın Süre alanını doldurur. */
  onSure(dk: number): void;
}) {
  const [bilgi, setBilgi] = useState<
    { modalite: number; modaliteAdi: string; protokolSure: number;
      hazirlikMetni: string } | null>(null);
  const [cihazlar, setCihazlar] = useState<Cihaz[]>([]);

  useEffect(() => {
    let birak = false;
    void (async () => {
      try {
        const y = await api.liste('radyoloji-cihaz', { sayfa: 1, boyut: 50 });
        if (!birak) setCihazlar(y.satirlar.map(r => ({
          id: Number(r.id), ad: String(r.ad ?? ''), modalite: Number(r.modalite ?? 0),
        })));
      } catch { /* radyoloji kurulu degil ya da yetki yok - uyari cizilmez */ }
    })();
    return () => { birak = true };
  }, []);

  /**
   * Kart AÇILIRKEN gelen tetkik süreyi EZMEZ: kullanıcı 45 dk yazdıysa kayıt
   * her açılışta 30'a dönerdi. Yalnız alan gerçekten değiştiğinde uygulanır.
   */
  const ilkHizmet = useRef<number | null>(null);

  useEffect(() => {
    let birak = false;
    if (!hizmetId) {
      setBilgi(null);
      // Tetkiksiz acilan YENI kart da "ilk deger" sayilir (0): yoksa kullanici
      //   ilk tetkigi sectiginde bu kart acilisi sanilip sure doldurulmazdi.
      if (ilkHizmet.current === null) ilkHizmet.current = 0;
      return;
    }
    void (async () => {
      try {
        const y = await api.radyolojiTetkikBilgi(hizmetId);
        if (birak) return;
        setBilgi(y ? {
          modalite: Number(y.modalite ?? 0),
          modaliteAdi: String(y.modaliteAdi ?? ''),
          protokolSure: Number(y.protokolSure ?? 0),
          hazirlikMetni: String(y.hazirlikMetni ?? ''),
        } : null);

        const ilkDeger = ilkHizmet.current;
        ilkHizmet.current = hizmetId;
        if (ilkDeger === null) return;                 // kart açılışı - dokunma
        if (y && Number(y.protokolSure) > 0 && Number(y.protokolSure) !== sureDk)
          onSure(Number(y.protokolSure));
      } catch { /* uc okunamazsa kart normal calisir */ }
    })();
    return () => { birak = true };
    // sureDk/onSure bilerek DISARIDA: sure her degistiginde yeniden sorgu
    //   atmak ve kullanicinin yazdigi degeri geri ezmek istemiyoruz.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [hizmetId]);

  if (!bilgi) return null;

  const cihaz = cihazId ? cihazlar.find(c => c.id === cihazId) : undefined;
  const uyumsuz = !!cihaz && cihaz.modalite > 0 && bilgi.modalite > 0
                  && cihaz.modalite !== bilgi.modalite;

  return (
    <div className={uyumsuz ? 'hata-kutusu' : 'bilgi-kutusu'} style={{ marginTop: 8 }}>
      {uyumsuz ? (
        <>
          <b>Tetkik ile cihaz uyuşmuyor.</b> Tetkik <b>{bilgi.modaliteAdi}</b>,
          seçili cihaz <b>{cihaz?.ad}</b>. Kayıt bu haliyle reddedilir - cihazı
          değiştirin.
        </>
      ) : (
        <>
          {bilgi.modaliteAdi && <>Tetkik modalitesi: <b>{bilgi.modaliteAdi}</b>. </>}
          {bilgi.protokolSure > 0
            && <>Çekim protokolü süresi <b>{bilgi.protokolSure} dk</b>. </>}
          {bilgi.hazirlikMetni && <>Hazırlık: {bilgi.hazirlikMetni}</>}
        </>
      )}
    </div>
  );
}
