import type { DetayDurumu } from '../GenDetayTablo';

/**
 * GÖZ ÖLÇÜM MATRİSİ — mockup `Ekranlar/Goz/goz_detayli_muayene.html` `.odos`.
 *
 * <b>Satır = parametre, sütun = göz.</b> Göz muayenesinde her bulgu iki göz
 * için ayrı ölçülür ve <b>karşılaştırılarak</b> okunur: "sağ 0,3 sol 1,0" tek
 * başına bir bulgudur. Genel detay gridi (satır ekle / göz seç / tür seç)
 * aynı veriyi tutuyordu ama hekime her satırda "bu hangi göz, bu hangi tür"
 * sorusunu yeniden sorduruyordu; matris bu iki soruyu ızgaranın kendisine
 * taşıyor.
 *
 * <b>Veri modeli DEĞİŞMEDİ.</b> Hücreye yazılan değer yine
 * <c>goz_gorme</c> / <c>goz_refraksiyon</c> / … satırıdır; matris yalnız
 * (göz + ayırt edici alan) ikilisini satır/sütun konumundan türetir. Aynı
 * ziyarette aynı ölçümün tekrar edebilmesi (otoref → subjektif → sikloplejik)
 * bu yüzden korunur: her tekrar MATRİSİN AYRI BİR SATIRIDIR.
 *
 * Kaydetme kartın normal akışında: bileşen `detaylar` durumunu günceller,
 * GenForm onu detay satırı olarak gönderir. İkinci bir kaydetme yolu açmak,
 * aynı satırın iki farklı şekilde yazılması demekti.
 */

type Satir = Record<string, unknown>;

/** Bir matris satırı: etiket + hangi kolona yazdığı + ayırt edici alan. */
export interface MatrisSatiri {
  etiket: string;
  /** Detay satırındaki alan adı (API adı: "degerOndalik", "gib"…). */
  alan: string;
  /**
   * AYIRT EDİCİ: bu satırın hangi kayda düştüğü. `{ tur: 4 }` → BCVA satırı.
   * Boşsa gözün TEK kaydı kullanılır (fundus, motilite gibi göz başına tek
   * satır tutan ölçümler).
   */
  ayirt?: Record<string, number | string>;
  /** Yanında küçük gri gösterilen ikinci alan ("20/25", "µm"). */
  yanAlan?: string;
  birim?: string;
  ipucu?: string;
  /** Sabit seçenekli alan (DR evresi gibi): kod → ad. */
  kodlar?: Record<string, string>;
  genislik?: number;
}

export interface GozMatrisTanimi {
  /** Detay adı - `detaylar` sözlüğündeki anahtar. */
  detay: string;
  /** Izgaranın üstündeki başlık (mockup `.ic`): "Görme keskinliği". */
  baslik?: string;
  /** Başlığın yanındaki soluk açıklama: birim, eşel, mesafe. */
  aciklama?: string;
  /**
   * AYNI SEKMEDE ÇİZİLECEK İKİNCİ MATRİS (mockup "Görme & Refraksiyon" tek
   * sekme): göz hekimi görme keskinliğini refraksiyonla BİRLİKTE okur -
   * "0,3 görüyor" ile "−2,50 miyop" aynı cümlenin iki yarısı. Sekmeye
   * bölmek, hekimi her karşılaştırmada sekme değiştirmeye zorlardı.
   */
  ekMatris?: string;
  satirlar: MatrisSatiri[];
  /** Satır oluşturulurken eklenecek sabit alanlar (kaynak, zaman…). */
  varsayilan?: Record<string, unknown>;
  not?: string;
}

const GOZLER = [
  { kod: 1, ad: 'OD · Sağ', sinif: 'od' },
  { kod: 2, ad: 'OS · Sol', sinif: 'os' },
] as const;

/** Satırın hangi kayda düştüğünü bulur; yoksa null. */
function kayitBul(satirlar: Satir[], goz: number, ayirt?: Record<string, number | string>) {
  return satirlar.find(s => {
    if (Number(s.goz) !== goz) return false;
    if (!ayirt) return true;
    return Object.entries(ayirt).every(([k, v]) => String(s[k] ?? '') === String(v));
  }) ?? null;
}

export function GozOlcumMatrisi({ tanim, durum, onDegis, salt }: {
  tanim: GozMatrisTanimi;
  durum: DetayDurumu;
  onDegis(yeni: DetayDurumu): void;
  salt: boolean;
}) {
  const yaz = (satir: MatrisSatiri, goz: number, alan: string, deger: string) => {
    const guncel = durum.guncel.map(s => ({ ...s }));
    const mevcut = kayitBul(guncel, goz, satir.ayirt);
    if (mevcut) {
      mevcut[alan] = deger;
    } else {
      // BOŞ HÜCREYE YAZINCA SATIR DOĞAR: hekimden önce "satır ekle" deyip
      //   sonra göz ve tür seçmesini istemek, matrisin bütün kazancını
      //   geri verirdi.
      guncel.push({
        goz, ...(satir.ayirt ?? {}), ...(tanim.varsayilan ?? {}), [alan]: deger,
      });
    }
    onDegis({ ...durum, guncel });
  };

  return (
    <>
      {/* MATRİS BAŞLIĞI (mockup `.ic`): ölçümün NE OLDUĞU ve hangi birimle
          okunduğu ızgaranın üstünde yazar - "0,8" tek başına ondalık mı
          logMAR mı belli değil. Tanımda vardı ama çizilmiyordu. */}
      {tanim.baslik && (
        <div className="odos-baslik">
          <b>{tanim.baslik}</b>
          {tanim.aciklama && <span className="sonuk"> · {tanim.aciklama}</span>}
        </div>
      )}
      <div className="odos">
        <div className="h">Parametre</div>
        {GOZLER.map(g => <div className={`h ${g.sinif}`} key={g.kod}>{g.ad}</div>)}

        {/* ANAHTAR AYIRT EDİCİYİ DE İÇERİR: "Cyl / Aks" satırı refraksiyonda
            hem otoref (tur 1) hem subjektif (tur 2) için var; etiket+alan
            anahtarı ikisini AYNI düğüm sanıyor ve React satırları sekmeler
            arasında taşıyordu (tonometri sekmesinde "Cyl / Aks" görünüyordu). */}
        {tanim.satirlar.map(satir => (
          <MatrisSatirOgesi key={satir.etiket + '|' + satir.alan + '|'
                                 + JSON.stringify(satir.ayirt ?? {})}
                            satir={satir} durum={durum} salt={salt} yaz={yaz} />
        ))}
      </div>
      {tanim.not && <div className="not">{tanim.not}</div>}
    </>
  );
}

function MatrisSatirOgesi({ satir, durum, salt, yaz }: {
  satir: MatrisSatiri;
  durum: DetayDurumu;
  salt: boolean;
  yaz(satir: MatrisSatiri, goz: number, alan: string, deger: string): void;
}) {
  return (
    <>
      <div className="l" title={satir.ipucu}>{satir.etiket}</div>
      {GOZLER.map(g => {
        const kayit = kayitBul(durum.guncel, g.kod, satir.ayirt);
        const deger = String(kayit?.[satir.alan] ?? '');
        const yan = satir.yanAlan ? String(kayit?.[satir.yanAlan] ?? '') : '';
        return (
          <div className="v" key={g.kod}>
            {satir.kodlar ? (
              <select value={deger} disabled={salt}
                      onChange={e => yaz(satir, g.kod, satir.alan, e.target.value)}>
                <option value=""></option>
                {Object.entries(satir.kodlar).map(([k, ad]) => (
                  <option key={k} value={k}>{ad}</option>
                ))}
              </select>
            ) : (
              <input value={deger} disabled={salt}
                     style={satir.genislik ? { width: satir.genislik, flex: 'none' } : undefined}
                     onChange={e => yaz(satir, g.kod, satir.alan, e.target.value)} />
            )}
            {satir.yanAlan && (
              <input className="k" value={yan} disabled={salt}
                     placeholder={satir.birim ?? ''}
                     onChange={e => yaz(satir, g.kod, satir.yanAlan as string, e.target.value)} />
            )}
            {!satir.yanAlan && satir.birim && <span className="sonuk">{satir.birim}</span>}
          </div>
        );
      })}
    </>
  );
}
