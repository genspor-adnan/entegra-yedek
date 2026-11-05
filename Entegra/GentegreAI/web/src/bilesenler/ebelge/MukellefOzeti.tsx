import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { type ListeSatiri } from '../../api/sozlesme';
import { c } from '../../dil/ceviri';

/**
 * ŞUBELERİN e-BELGE DURUMU (Fatura Ayarları › Genel altı).
 *
 * Satış Belgeleri › e-Belge sekmesindeki özet grid buraya taşındı (kullanıcı 05.11.2026: "Satış Belgeleri menüde
 * e-belge sekmesindeki gridi buradaki genel sekmesine taşı"). Hangi şube hangi entegratörle / ortamla gönderiyor,
 * ana şalter (e-Fatura Mükellefi, 179) açık mı - salt görünüm; düzenleme üstteki kartta (aktif şube) ya da üst
 * çubuktan şube değiştirerek. Hiçbir şubede mükellefiyet yoksa uyarı: belge GİB'e gitmez.
 */
export function MukellefOzeti({ tazele = 0 }: { tazele?: number }) {
  const [subeler, setSubeler] = useState<ListeSatiri[]>([]);
  useEffect(() => {
    api.liste('sube', { boyut: 100, sirala: [{ alan: 'varsayilan', yon: 'desc' }] })
       .then(y => setSubeler(y.satirlar)).catch(() => {});
  }, [tazele]);
  const anaSalter = subeler.some(m => Number(m.efaturaMukellef) === 1);
  return (
    <div className="kagrup" style={{ marginTop: 10 }}>
      <h6>{c('Şubelerin e-Belge Durumu')}</h6>
      {subeler.length > 0 && !anaSalter && (
        <div className="bilgi-kutusu">
          <b>e-Belge kapalı.</b> {c('Hiçbir şubede')} <b>{c('e-Fatura Mükellefi')}</b> işaretli değil; belge GİB'e
          gönderilmez, fatura / irsaliye numarası her zaman <b>Belge No</b> şablonundan verilir.
        </div>
      )}
      <div className="not">
        Entegratör hesabı (kullanıcı / şifre, test ortamı) <b>Yönetim › Ayarlar › Genel › Entegrasyon</b>'da şube +
        ortam başına; mükellefiyet, gönderici etiketi ve seri yukarıdaki kartta. Ayrı VKN'li şube kendi hesabıyla,
        merkezin kimliğini kullanan şube merkezin hesabıyla gönderir.
      </div>
      {subeler.length > 0 && (
        <table className="grid" style={{ marginTop: 8 }}>
          <thead>
            <tr><th>Şube</th><th>Ünvan</th><th>{c('VKN')}</th><th>{c('Entegratör')}</th>
                <th style={{ textAlign: 'center' }}>e-Fatura Mük.</th>
                <th style={{ textAlign: 'center' }}>Ortam</th></tr>
          </thead>
          <tbody>
            {subeler.map(m => (
              <tr key={String(m.id)}>
                <td>{String(m.ad ?? '')}</td>
                <td>{String(m.unvan ?? '')}</td>
                <td>{String(m.vkno ?? '')}</td>
                <td>{String(m.entegratorAdi ?? '—')}</td>
                {/* ANA ŞALTER (179): işaretli değilse o şubeden e-Belge çıkmaz. */}
                <td style={{ textAlign: 'center' }}>
                  <span className={`rozet ${Number(m.efaturaMukellef) === 1 ? 'ok' : 'gri'}`}>
                    {Number(m.efaturaMukellef) === 1 ? 'Açık' : 'Kapalı'}
                  </span>
                </td>
                <td style={{ textAlign: 'center' }}>
                  <span className={`rozet ${Number(m.testOrtami) === 1 ? 'uyari' : 'ok'}`}>
                    {Number(m.testOrtami) === 1 ? 'TEST' : 'Üretim'}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
