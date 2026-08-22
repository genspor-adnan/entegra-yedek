import type { KasaBacagi } from '../../api/sozlesme';

const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

const ROL_ADI: Record<string, string> = {
  ana: 'Hesap',
  karsi: 'Karşı Hesap',
  cari: 'Cari',
  karsi_cari: 'Karşı Cari',
  masraf: 'Gider Kalemi',
  kalem: 'Kalem',
};

/**
 * Uretilmis bacaklarin salt-gorunum listesi.
 *
 * Bacaklar ISTEMCIDE HESAPLANMAZ: kullanici basligi (tutar, hesap, cari, masraf)
 * doldurur, sunucu turun sablonundan bacaklari uretir. Burada gosterilen degerler
 * her zaman sunucudan gelen sonuctur - iki taraf ayni sayiyi gorur.
 */
export function BacakListesi({ bacaklar, dovizCinsi }: { bacaklar: KasaBacagi[]; dovizCinsi: string }) {
  if (bacaklar.length === 0)
    return <div className="not">Bacaklar kaydedince sunucu tarafından üretilir.</div>;

  const toplamBorc = bacaklar.reduce((t, b) => t + Number(b.yerelBorc || 0), 0);
  const toplamAlacak = bacaklar.reduce((t, b) => t + Number(b.yerelAlacak || 0), 0);
  const dengeli = Math.round(toplamBorc * 100) === Math.round(toplamAlacak * 100);
  const dovizli = dovizCinsi !== 'TL';

  const ad = (b: KasaBacagi) =>
    b.hesapAdi || b.tarafUnvan || b.masrafAdi || b.hizmetAdi || '(hesapsız)';

  return (
    <>
      <table className="detay-tablo">
        <thead>
          <tr>
            <th style={{ width: 110 }}>Rol</th>
            <th>Hesap / Cari / Kalem</th>
            {dovizli && <th className="hiza-sag" style={{ width: 120 }}>Borç ({dovizCinsi})</th>}
            {dovizli && <th className="hiza-sag" style={{ width: 120 }}>Alacak ({dovizCinsi})</th>}
            <th className="hiza-sag" style={{ width: 130 }}>Borç (TL)</th>
            <th className="hiza-sag" style={{ width: 130 }}>Alacak (TL)</th>
          </tr>
        </thead>
        <tbody>
          {bacaklar.map(b => (
            <tr key={b.id ?? b.sira}>
              <td>{ROL_ADI[b.rol ?? ''] ?? b.rol ?? '—'}</td>
              <td>{ad(b)}</td>
              {dovizli && <td className="hiza-sag">{b.borc ? para.format(b.borc) : ''}</td>}
              {dovizli && <td className="hiza-sag">{b.alacak ? para.format(b.alacak) : ''}</td>}
              <td className="hiza-sag">{b.yerelBorc ? para.format(b.yerelBorc) : ''}</td>
              <td className="hiza-sag">{b.yerelAlacak ? para.format(b.yerelAlacak) : ''}</td>
            </tr>
          ))}
        </tbody>
        <tfoot>
          <tr className="genel">
            <td colSpan={dovizli ? 4 : 2}>
              Toplam {dengeli
                ? <span className="rozet olumlu">⚖ dengeli</span>
                : <span className="rozet uyari">⚠ fark {para.format(toplamBorc - toplamAlacak)}</span>}
            </td>
            <td className="hiza-sag">{para.format(toplamBorc)}</td>
            <td className="hiza-sag">{para.format(toplamAlacak)}</td>
          </tr>
        </tfoot>
      </table>
    </>
  );
}
