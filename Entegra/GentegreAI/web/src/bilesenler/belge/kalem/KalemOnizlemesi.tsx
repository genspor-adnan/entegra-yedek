import { para } from '../../bicim';
import type { KalemDurumu } from '../../../sayfalar/belgeKarti/kalemDurumu';
import type { SatirDurumu } from '../../../sayfalar/belgeSatir';

/**
 * KALEM ÖNİZLEMESİ — girilen alanlardan HESAPLANAN sonuçlar.
 *
 * Mockup'ta ayrı bir `.grp` kutusu: girilen alanlarla hesaplananlar arasında
 * görsel bir sınır olmalı - düz liste içinde salt görünüm kutular
 * girilebilir sanılıyordu.
 *
 * ============ HİÇBİR ŞEY YAZMAZ ======================================
 * Bileşenin tek yazdığı yer lot kutusuna tıklama (`onIzlemAc`); gerisi
 * okunur. Bu yüzden kalem penceresinden çıkarılması bedava: hesabı
 * `kalemDurumu` yapıyor, burası yalnız biçimliyor.
 */
export function KalemOnizlemesi({ d, transferMi, yerelPara, izlemler,
                                  onIzlemAc }: {
  d: Pick<KalemDurumu, 'iskontoluMu' | 'sgkKilitli' | 'onizlemeBirim'
                     | 'gosterimTabani' | 'oranSayi' | 'tutarIskontosu'
                     | 'onizlemeTutar' | 'izlemGerekli'>;
  /** Depo transferi: para yok - önizleme hiç çizilmez. */
  transferMi: boolean;
  yerelPara: string;
  izlemler: SatirDurumu['izlemler'];
  onIzlemAc: () => void;
}) {
  return (
    <>
      {!transferMi && <div className="alan-ayrac">Önizleme</div>}

      {/* İSKONTO SONRASI BİRİM (602): yalnız iskonto VARSA çizilir - iskontosuz
          satırda üst kutudaki sayının aynısı olurdu. */}
      {!transferMi && d.iskontoluMu && (
      <label className="alan">
        {/* "(önizleme, KDV dahil)" eki KALKTI (kullanıcı): kutu zaten salt
            görünüm ve başvuruda KDV her zaman dahil - her satırda tekrarlanan
            parantez etiketi uzatıyordu. */}
        <span className="etiket">
          İskontolu {d.sgkKilitli ? 'Hasta Katkısı' : 'Birim Fiyat'}</span>
        <input className="hiza-sag onizleme"
               value={para.format(d.onizlemeBirim)} readOnly />
        {/* NE UYGULANDIĞI YAZAR (661): kutudaki sayı sonuçtur, hangi oranın ve
            hangi tutarın düşüldüğü görünmüyordu - "100 TL yazdım, doğru mu
            indi" sorusu ancak hesap makinesiyle cevaplanıyordu. */}
        <span className="ipucu">
          {para.format(d.gosterimTabani)} − %{d.oranSayi}
          {d.tutarIskontosu > 0.004
            && <> ({para.format(d.tutarIskontosu)} {yerelPara})</>}
          {' = '}<b>{para.format(d.onizlemeBirim)} {yerelPara}</b>
        </span>
      </label>
      )}

      {!transferMi && (
      <label className="alan">
        <span className="etiket">Tutar</span>
        <input className="hiza-sag onizleme"
               value={para.format(d.onizlemeTutar)} readOnly />
      </label>
      )}

      {/* İzlemli stokta girilmiş lotların özeti - kalem penceresine
          dönüldüğünde dağıtımın yapıldığı görünsün. */}
      {d.izlemGerekli && izlemler.length > 0 && (
        <label className="alan">
          <span className="etiket">Lot / Seri</span>
          <input className="onizleme" readOnly
                 value={izlemler.map(z => `${z.lotNo || z.seriNo} (${z.miktar})`)
                   .join(', ')}
                 onClick={onIzlemAc}
                 title="Değiştirmek için tıklayın" />
        </label>
      )}
    </>
  );
}
