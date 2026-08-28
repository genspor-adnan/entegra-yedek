import { Modal } from '../Modal';
import type { UtsBelgeBildirimYaniti } from '../../api/istemci';

/**
 * ÜTS BELGE KÖPRÜSÜ SONUCU (226) - belgeden toplu bildirim satır satır
 * raporlanır: hangi seri/lot gitti, hangisi neden gitmedi. Bir satırın hatası
 * diğerlerini durdurmaz; kullanıcı eksiği görüp düzeltir (cari ÜTS no, stok
 * GTIN, askıdakiler senkronu...) ve tekrar çalıştırır - bildirilmişler atlanır.
 */
export function UtsBelgeSonucModali({ sonuc, onKapat }: {
  sonuc: UtsBelgeBildirimYaniti;
  onKapat(): void;
}) {
  return (
    <Modal baslik={`ÜTS Bildirimi — ${sonuc.belgeNo}`} onKapat={onKapat}
      alt={
        <button className="d kapat-dugmesi" style={{ marginLeft: 'auto' }}
                onClick={onKapat}>Kapat</button>
      }>
      <div style={{ padding: 10 }}>
        <div className="bilgi-kutusu">
          {sonuc.mesaj}
          {sonuc.hatali > 0 && <> — <b>{sonuc.hatali} satır bildirilemedi.</b></>}
        </div>
        <table className="detay-tablo" style={{ width: '100%' }}>
          <thead>
            <tr>
              <th>Stok</th><th>Seri</th><th>Lot</th>
              <th style={{ textAlign: 'right' }}>Adet</th>
              <th>İşlem</th><th>Sonuç</th>
            </tr>
          </thead>
          <tbody>
            {sonuc.sonuclar.map((s, i) => (
              <tr key={i}>
                <td>{s.stok}</td>
                <td>{s.seriNo}</td>
                <td>{s.lotNo}</td>
                <td style={{ textAlign: 'right' }}>{s.adet}</td>
                <td>{s.islem}</td>
                <td>
                  <span className={`rozet ${s.basarili ? 'ok' : 'hata'}`}>
                    {s.basarili ? '✓' : '✖'}
                  </span>{' '}{s.mesaj}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Modal>
  );
}
