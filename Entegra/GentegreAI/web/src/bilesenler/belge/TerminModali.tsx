import { useState } from 'react';
import { api } from '../../api/istemci';
import { ApiHatasi, type BelgeYaniti } from '../../api/sozlesme';
import { Modal } from '../Modal';
import type { SatirDurumu } from '../../sayfalar/belgeSatir';

/**
 * TERMIN GUNCELLEME (140) - siparis satirlarinin teslim tarihi.
 *
 * Tedarikci gecikince ya da musteri erteleyince siparisi iptal edip yeniden
 * kesmek yerine TARIH guncellenir: numara, fiyatlar ve donusum zinciri kalir.
 * Termin tutar/stok/cari etkilemedigi icin KESIN belgede de degistirilebilir -
 * kayitli belge duzenleme kilidine (135) takilmaz.
 *
 * "Hepsine uygula" once girilir, tek tek duzeltilecek satirlar sonra: siparisin
 * tamami iki hafta oteleniyor, birkac kalem farkli tarihte kaliyor - en sik
 * durum bu.
 */
export function TerminModali({ belgeId, satirlar, onKapat, onTamam }: {
  belgeId: number;
  satirlar: SatirDurumu[];
  onKapat(): void;
  onTamam(yeni: BelgeYaniti): void;
}) {
  // Yalniz KAYITLI satirlar guncellenebilir (satirId sunucudan gelir).
  const kayitli = satirlar.filter(s => s.satirId);
  const [tarihler, setTarihler] = useState<Record<number, string>>(
    () => Object.fromEntries(kayitli.map(s => [s.satirId!, s.teslimTarihi ?? ''])));
  const [toplu, setToplu] = useState('');
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);

  const hepsineUygula = (deger: string) => {
    setToplu(deger);
    if (deger) setTarihler(Object.fromEntries(kayitli.map(s => [s.satirId!, deger])));
  };

  async function kaydet() {
    setHata(null);
    setCalisiyor(true);
    try {
      const yeni = await api.belgeTermin(belgeId, kayitli.map(s => ({
        satirId: s.satirId!,
        // Bos tarih = termin KALDIRILDI; sunucu null bekliyor.
        teslimTarihi: tarihler[s.satirId!] || null,
      })));
      onTamam(yeni);
      onKapat();
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally { setCalisiyor(false) }
  }

  return (
    <Modal
      baslik="Termin Güncelle"
      onKapat={onKapat}
      alt={
        <>
          <button className="d ana" disabled={calisiyor || kayitli.length === 0}
                  onClick={() => void kaydet()}>
            {calisiyor ? 'Kaydediliyor…' : '📅 Terminleri Kaydet'}
          </button>
          <span className="ayrac" />
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="kagrup">
          <div className="alan-izgara" style={{ margin: 10 }}>
            <label className="alan">
              <span className="etiket">Hepsine Uygula</span>
              <input type="date" value={toplu}
                     onChange={e => hepsineUygula(e.target.value)} />
            </label>
            <span className="alan-notu">
              Tarih girince tüm satırlara yazılır; sonra tek tek değiştirebilirsiniz.
              Boş bırakılan satırın termini kaldırılır.
            </span>
          </div>

          <table className="detay-tablo">
            <thead>
              <tr>
                <th style={{ width: 110 }}>Kod</th>
                <th>Stok / Hizmet</th>
                <th className="hiza-sag" style={{ width: 80 }}>Miktar</th>
                <th className="hiza-orta" style={{ width: 96 }}>Mevcut</th>
                <th className="hiza-orta" style={{ width: 150 }}>Yeni Teslim Tarihi</th>
              </tr>
            </thead>
            <tbody>
              {kayitli.map(s => (
                <tr key={s.satirId}>
                  <td><code>{s.stokKodu || '—'}</code></td>
                  <td>{s.stokAdi || s.aciklama}</td>
                  <td className="hiza-sag">
                    {(Number(s.adet.replace(',', '.')) || 0).toLocaleString('tr-TR')}
                  </td>
                  <td className="hiza-orta sonuk">
                    {s.teslimTarihi ? s.teslimTarihi.split('-').reverse().join('.') : '—'}
                  </td>
                  <td className="hiza-orta">
                    <input type="date" value={tarihler[s.satirId!] ?? ''}
                           onChange={e => setTarihler(t => ({ ...t, [s.satirId!]: e.target.value }))} />
                  </td>
                </tr>
              ))}
              {kayitli.length === 0 && (
                <tr><td colSpan={5} className="bos">
                  Termin verilecek kayıtlı satır yok — önce siparişi kaydedin.
                </td></tr>
              )}
            </tbody>
          </table>
        </div>
      </>
    </Modal>
  );
}
