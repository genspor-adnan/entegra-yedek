import { useState } from 'react';
import { para, hamSayi } from '../../bicim';
import { type FiyatGirdisi, fiyattanOran, oranKirp as oranKirpCoz }
  from '../../../sayfalar/belgeKarti/kalemFiyat';
import { type KalemDurumu, type SagMod, sagKutuGorunumu }
  from '../../../sayfalar/belgeKarti/kalemDurumu';

/** İskonto combosunun hazır oranları: %5'ten %50'ye beşer beşer (kullanıcı). */
const ISKONTO_ORANLARI = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50];

/**
 * KALEM İSKONTOSU — combo (oran) + tek kutu (anlamı moda göre).
 *
 * ============ TEK İSKONTO, İKİ YAZILIŞI (661) ========================
 * Sol combo ORAN, sağ kutu TUTAR - ikisi de AYNI alanı (`iskonto`) yazar,
 * biri yüzdeyle biri lirayla. Hangisine dokunulduysa öteki onun karşılığını
 * gösterir; iki ayrı indirim değildir.
 *
 * İkinci iskonto slotu (`iskonto2`) bu pencerede KULLANILMIYOR: tutarı oraya
 * yazmak, ekranda görünmeyen ikinci bir indirim bırakıyordu. Kullanıcı burada
 * iskontoya dokunursa ikinci slot SIFIRLANIR.
 *
 * ============ NEDEN AYRI BİLEŞEN =====================================
 * Kutunun modu (`sagMod`) ve yazılmakta olan ham metni (`sagMetin`) yalnız
 * bu blokta anlamlı; kalem penceresinde dururken iki `useState` ve dört
 * işleyici, ilgisiz 800 satırın arasına dağılmıştı. Buraya taşınınca
 * pencerenin taşıdığı durum azaldı, blok tek başına okunur oldu.
 *
 * Ana bileşene geri giden tek şey ORANDIR (`onYaz`) - satırda saklanan da o.
 */
export function KalemIskontosu({ d, iskontoTutari, iskontoTavani, kdvDahil,
                                 yerelPara, tus, onYaz }: {
  /** Türetilmiş durum - hangi tabana, hangi adla iskonto yapıldığı orada. */
  d: Pick<KalemDurumu, 'oranSayi' | 'gosterimTabani' | 'hedefFiyat'
                     | 'tutarIskontosu' | 'tabanAdi' | 'iskontoTabani'
                     | 'sgkKilitli' | 'katkiVar'> & { fg: FiyatGirdisi };
  /** Satırdaki ham iskonto metni (`r.iskonto`). */
  iskontoTutari: string;
  /** Rolün `basvuru.iskonto` sınırı; 0 = iskonto yapamaz. */
  iskontoTavani: number;
  kdvDahil: boolean;
  yerelPara: string;
  tus: (e: React.KeyboardEvent) => void;
  /** Orana çevrilmiş sonuç - görünmeyen 2. slot çağıranda sıfırlanır. */
  onYaz: (oran: number | string) => void;
}) {
  const iskontoYapilir = iskontoTavani > 0;
  /**
   * SAĞ KUTUNUN ANLAMI COMBODAN GELİR (kullanıcı):
   *   hazır oran     -> SALT GÖRÜNÜM iskonto TUTARI (200 TL'nin %10'u = 20)
   *   "Özel İskonto" -> ORAN girilir (%)
   *   "Birim Fiyat"  -> hedef BİRİM FİYAT girilir; fark orana çevrilir
   *
   * Hazır oranda kutu READONLY: oran zaten combodan seçildi, aynı sayıyı iki
   * yerden değiştirilebilir bırakmak "hangisi kazanır" sorusu üretirdi.
   */
  const [sagMod, setSagMod] = useState<SagMod>(
    d.oranSayi > 0 && !ISKONTO_ORANLARI.includes(d.oranSayi) ? 'oran' : 'tutar');
  /**
   * YAZILMAKTA OLAN HAM METİN (kullanıcı: "combodan birim fiyat seçtim ama
   * giremedim").
   *
   * Kutu kontrollü ve değeri MODELDEN türetiliyordu: her tuşta sayıya çevrilip
   * `para.format` ile geri yazılıyordu. "1" yazınca kutu anında "1,00" oluyor,
   * imleç kayıyor ve ikinci rakam yazılamıyordu; virgül de yutuluyordu.
   *
   * Çözüm: odak KUTUDAYKEN kullanıcının yazdığı metin gösterilir (model yine
   * her tuşta güncellenir - önizleme canlı kalır), odak çıkınca biçimlenmiş
   * hâli görünür.
   */
  const [sagMetin, setSagMetin] = useState<string | null>(null);

  const sag = sagKutuGorunumu(d, sagMod, iskontoTutari, yerelPara);

  /** Oran tavanı aşmasın - her yoldan gelen değer buradan geçer. */
  const oranKirp = (oran: number) => oranKirpCoz(oran, iskontoTavani);

  /** Sağ kutuya yazıldı: moda göre orana çevrilir. */
  const sagYaz = (metin: string) => {
    const sayi = hamSayi(metin);
    if (sagMod === 'oran') {
      onYaz(metin === '' ? '' : oranKirp(sayi));
      return;
    }
    // Hazır oranda kutu salt görünüm - buraya hiç gelinmez.
    if (sagMod !== 'fiyat' || !(d.gosterimTabani > 0)) return;
    // HEDEF BİRİM FİYAT -> ORAN. Kullanıcı EKRANDAKİ (KDV dahil) fiyatı yazar;
    //   oran aynı tabana göre hesaplandığı için matrah/brüt farkı önemsiz.
    //   Girilen fiyat asıl fiyattan büyükse iskonto 0'dır (bu kutudan ZAM
    //   yapılamaz - fiyatı yükseltmek fiyat listesinin işidir); tavan geçerli.
    if (!(sayi > 0)) { onYaz(0); return }
    onYaz(oranKirp(fiyattanOran(d.fg, sayi)));
  };

  /** Combo seçimi: hazır oran, "Özel İskonto" ya da "Birim Fiyat" kutusu. */
  const oranSec = (v: string) => {
    // Mod değişince yazılmakta olan ham metin DÜŞER: eski modun sayısı
    //   (ör. %10) yeni modda (birim fiyat) başka şey demektir.
    setSagMetin(null);
    if (v === 'ozel')  { setSagMod('oran');  return }
    if (v === 'fiyat') { setSagMod('fiyat'); return }
    setSagMod('tutar');
    onYaz(v === '' ? 0 : v);
  };

  return (
    <label className="alan">
      {/* İSKONTO TABANI (586): Özel'de satırın tek fiyatı, TTB/SUT'ta hastanın
          katkı payı. Kurumun ödediği SUT/tarife bedeli indirimden ETKİLENMEZ -
          hastaneyle hasta arasındaki anlaşma SGK'nin ödemesini kısamaz.
          Hesap sunucuda. */}
      <span className="etiket">
        İskonto{d.katkiVar ? ' (katkı üzerinden)' : ''}</span>
      <span className="ikili">
        {/* SOL: ORAN COMBOSU. Tavanın ÜSTÜNDEKİ oranlar listeye HİÇ girmez:
            seçilemeyen seçenek göstermek, kullanıcıyı sunucudan red yemeye
            gönderirdi.

            Son iki seçenek sağ kutunun ANLAMINI değiştirir:
              hazır oran     -> sağda SALT GÖRÜNÜM tutar karşılığı
              "Özel İskonto" -> sağda serbest yüzde
              "Birim Fiyat"  -> sağda hedef birim fiyat / katkı */}
        <select className="birim" style={{ width: 138 }}
                value={sag.oranSecimi} disabled={!iskontoYapilir}
                title={iskontoYapilir
                  ? `İskonto oranı (en çok %${iskontoTavani})`
                  : 'İskonto yetkiniz yok (Yetkiler › Başvuru › '
                    + 'Başvuruda iskonto)'}
                onChange={e => oranSec(e.target.value)}>
          <option value="">%0</option>
          {ISKONTO_ORANLARI.filter(o => o <= iskontoTavani)
            .map(o => <option key={o} value={String(o)}>%{o}</option>)}
          <option value="ozel">Özel İskonto…</option>
          {/* "Birim Fiyat…" -> "Fiyat Gir…" (kullanıcı): combo bir EYLEM
              listesi - öteki seçenekler oran veriyor, bu seçenek kutuyu fiyat
              girişine çeviriyor. Alan adını tekrarlamak ne yapacağını
              söylemiyordu. */}
          <option value="fiyat">
            {d.sgkKilitli ? 'Katkı Gir…' : 'Fiyat Gir…'}
          </option>
        </select>
        {/* SAĞ: TEK KUTU, anlamı moda göre. Üçü de aynı alanı yazar - satırda
            saklanan tek şey YÜZDEDİR:
              tutar  -> tutar / taban
              oran   -> doğrudan
              fiyat  -> (1 - hedef / asıl) x 100
            Ayrı bir "tutar iskontosu" kolonu açmak, aynı tutarın iki formülle
            hesaplandığı ikinci bir yol demekti.

            ETİKET ÜST KUTUYU İZLER (kullanıcı: "üstte birim fiyatsa birim
            fiyat, katkı ise katkı yazar"): saf SGK'da iskonto birim fiyata
            değil HASTA KATKISINA işler (fn_dagilim_coz). */}
        <span className="birim-metin">{sag.baslik}</span>
        <input className="hiza-sag iskonto-deger" value={sagMetin ?? sag.deger}
               onKeyDown={tus} disabled={!iskontoYapilir}
               /* HAZIR ORANDA SALT GÖRÜNÜM: oran combodan seçildi, buradaki
                  sayı onun TUTAR karşılığı. */
               readOnly={sagMod === 'tutar'}
               placeholder={sagMod === 'oran' ? 'oran'
                          : sagMod === 'fiyat'
                          ? d.tabanAdi.toLocaleLowerCase('tr') : ''}
               title={sagMod === 'oran'
                 ? `Serbest iskonto oranı (en çok %${iskontoTavani})`
                 : sagMod === 'fiyat'
                 ? `İskonto sonrası ${d.tabanAdi.toLocaleLowerCase('tr')}`
                   + ` - asıl değere (${para.format(d.iskontoTabani)}) göre`
                   + ' oran hesaplanır'
                 : `Seçilen oranın tutar karşılığı (${para
                     .format(d.gosterimTabani)} × %${d.oranSayi})`
                   + (kdvDahil ? ' - KDV dahil' : '')}
               onFocus={e => { if (sagMod !== 'tutar') setSagMetin(e.target.value) }}
               onBlur={() => setSagMetin(null)}
               onChange={e => { setSagMetin(e.target.value); sagYaz(e.target.value) }} />
        <span className="birim-metin">{sag.etiket}</span>
      </span>
      {!iskontoYapilir && (
        <span className="ipucu">
          İskonto yetkiniz yok - Yetkiler › Başvuru › “Başvuruda iskonto”.
        </span>
      )}
    </label>
  );
}
