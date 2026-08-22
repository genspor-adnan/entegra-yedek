import type { FisOzeti } from '../../api/sozlesme';

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const FIS_TURU: Record<number, string> = {
  1: 'Mahsup', 2: 'Tahsil', 3: 'Tediye', 4: 'Açılış', 5: 'Kapanış',
};
const FIS_DURUM: Record<number, string> = {
  1: 'Kayıtlı', 2: 'Ters fişle iptal', 3: 'Ters fiş',
};

/**
 * Kesinlestirmede uretilen muhasebe fisi. Salt gorunum: fis satirlari SUNUCUDA
 * bacaklardan uretilir (fn_kasa_islem_fisle), burada yeniden hesaplanmaz.
 */
export function FisOnizleme({ fis }: { fis: FisOzeti }) {
  const dengeli = Math.round(fis.toplamBorc * 100) === Math.round(fis.toplamAlacak * 100);

  return (
    <div className="kagrup">
      <h6>
        Muhasebe Fişi
        <span className="rozet">{FIS_TURU[fis.tur] ?? fis.tur}</span>
        {fis.fisNo && <span className="rozet bir">{fis.fisNo}</span>}
        {fis.durum !== 1 && <span className="rozet uyari">{FIS_DURUM[fis.durum] ?? fis.durum}</span>}
        <span className={dengeli ? 'rozet olumlu' : 'rozet uyari'}>
          {dengeli ? '⚖ dengeli' : '⚠ dengesiz'}
        </span>
      </h6>

      <table className="detay-tablo">
        <thead>
          <tr>
            <th style={{ width: 90 }}>Hesap</th>
            <th>Hesap Adı</th>
            <th className="hiza-sag" style={{ width: 130 }}>Borç</th>
            <th className="hiza-sag" style={{ width: 130 }}>Alacak</th>
            <th style={{ width: 120 }}>Döviz</th>
          </tr>
        </thead>
        <tbody>
          {fis.satirlar.map(s => (
            <tr key={s.sira}>
              <td><code>{s.hesapKodu}</code></td>
              <td>{s.hesapAdi}</td>
              <td className="hiza-sag">{s.borc ? para.format(s.borc) : ''}</td>
              <td className="hiza-sag">{s.alacak ? para.format(s.alacak) : ''}</td>
              <td>
                {s.dovizCinsi !== 'TL' && (
                  <span className="onizleme">
                    {para.format(s.dovizBorc || s.dovizAlacak)} {s.dovizCinsi}
                  </span>
                )}
              </td>
            </tr>
          ))}
        </tbody>
        <tfoot>
          <tr className="genel">
            <td colSpan={2}>Toplam</td>
            <td className="hiza-sag">{para.format(fis.toplamBorc)}</td>
            <td className="hiza-sag">{para.format(fis.toplamAlacak)}</td>
            <td />
          </tr>
        </tfoot>
      </table>
    </div>
  );
}
