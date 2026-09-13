import { basvuruAsamalari, type AsamaGirdisi } from '../../sayfalar/belgeKarti/basvuruAsamalari';

/**
 * BASVURU TAMAMLANMA SERIDI (370, kullanici) - radyoloji istem kartindaki
 * akis seridinin (310) kayit kabul karsiligi.
 *
 * "Bu basvuruda daha ne eksik" sorusu kartin sekmeleri gezilerek
 * cevaplaniyordu: ucret var mi, tahsilat tam mi, fis kesildi mi... Serit
 * hepsini tek satirda gosterir - yapilmayan asama GRI, yapilan KENDI RENGIYLE
 * dolar, %100 olunca basvuru tamamlanmistir.
 *
 * Renkler asamanin kimligidir (kullanici), seritteki yerinin degil: Başvuru
 * kirmizi · Provizyon turuncu · Ücretlendirme sari · Tahsilat mavi ·
 * Faturalama yesil. Sira Başvuru · Ücretlendirme · Provizyon · Tahsilat ·
 * Belge Kesimi; provizyon yalniz kurum odeyen basvuruda cizilir - hesap
 * `basvuruAsamalari`da (saf, testli).
 */
export function BasvuruAsamaSeridi(g: AsamaGirdisi) {
  const { asamalar, yuzde, tamamlandi } = basvuruAsamalari(g);

  return (
    <div className={'basvuru-asama' + (tamamlandi ? ' bitti' : '')}>
      <div className="asama-seridi">
        {asamalar.map(a => (
          <div key={a.kod}
               className={'asama ' + a.renk + (a.tamam ? ' ok' : '')}
               /* Eksik asamanin SEBEBI ipucunda: "Açık borç 250,00 ₺" gibi -
                  memur hangi sekmeye gidecegini serit uzerinden anlasin. */
               title={a.tamam ? `${a.ad}: tamamlandı` : `${a.ad}: ${a.ipucu}`}>
            <span className="ad">{a.ad}</span>
          </div>
        ))}
      </div>
      <div className="asama-yuzde" title={tamamlandi
        ? 'Başvuru tamamlandı.'
        : asamalar.filter(a => !a.tamam).map(a => a.ipucu).join(' ')}>
        <span className="cubuk"><i style={{ width: `${yuzde}%` }} /></span>
        <b>%{yuzde}</b>
      </div>
    </div>
  );
}
