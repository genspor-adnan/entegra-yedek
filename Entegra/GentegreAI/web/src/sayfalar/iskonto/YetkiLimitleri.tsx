import type { IskontoLimiti } from '../../api/sozlesme';
import { ISTISNALAR } from './ortak';

/**
 * YETKİ LİMİTLERİ — "bu talep neden bana düştü" sorusunun cevabı.
 *
 * Tavan rol yetkisindeki SAYISAL DEĞERDİR (Yetkiler › Başvuru › İskonto);
 * talep isteyenin tavanını aşmıyorsa onaya hiç düşmez. Altındaki tablo
 * yetkiden BAĞIMSIZ kuralları yazar - tavanı %100 olan kişi de SGK katkı
 * payını indiremez.
 */
export function YetkiLimitleri({ limitler, rolId }: {
  limitler: IskontoLimiti[];
  /** Oturumdaki kullanıcının rolü - kendi satırı işaretlenir. */
  rolId?: number;
}) {
  return (
    <>
      <div className="kagrup">
        <h6>İskonto Yetki Matrisi
          <span className="sonuk">
            rol tavanı · limit içi doğrudan uygulanır, üstü kuyruğa düşer
          </span></h6>
        <table className="detay-tablo">
          <thead>
            <tr>
              <th>Rol</th>
              <th className="hiza-sag" style={{ width: 120 }}>Oran tavanı</th>
              <th className="hiza-sag" style={{ width: 120 }}>Kişi</th>
              <th>Not</th>
            </tr>
          </thead>
          <tbody>
            {limitler.map(l => (
              <tr key={l.rolId} className={l.rolId === rolId ? 'secili' : undefined}>
                <td>
                  {l.rolAd}
                  {l.rolId === rolId && (
                    <span className="rozet mavi" style={{ marginLeft: 6 }}>siz</span>
                  )}
                </td>
                <td className="hiza-sag"><b>%{l.tavan}</b></td>
                <td className="hiza-sag">{l.kullaniciSayisi}</td>
                <td className="sonuk">
                  {l.tavan >= 100 ? 'Sınırsız — her talebi karşılar'
                    : `%${l.tavan} üstü talep bu role düşmez`}
                </td>
              </tr>
            ))}
            {limitler.length === 0 && (
              <tr><td colSpan={4} className="bos">
                Tanımlı iskonto tavanı yok — yetki ekranından
                “Başvuru › İskonto” değeri verilmeli.
              </td></tr>
            )}
          </tbody>
        </table>
        <div className="pano-not">
          Tavan <b>rol yetkisindeki sayısal değerdir</b> (Yetkiler ekranı ›
          Başvuru › İskonto). Talep, isteyenin tavanını aşmıyorsa onaya hiç
          düşmez — her indirimi onaya göndermek gerçek istisnayı gürültüde
          kaybederdi.
        </div>
      </div>

      <div className="kagrup">
        <h6>Kural İstisnaları <span className="sonuk">yetkiden bağımsız</span></h6>
        <table className="detay-tablo">
          <thead>
            <tr><th style={{ width: 220 }}>Kural</th>
                <th style={{ width: 190 }}>Etki</th><th>Neden</th></tr>
          </thead>
          <tbody>
            {ISTISNALAR.map(k => (
              <tr key={k.kural}>
                <td>{k.kural}</td>
                <td><span className={`rozet ${k.sinif}`}>{k.etki}</span></td>
                <td className="sonuk">{k.neden}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
