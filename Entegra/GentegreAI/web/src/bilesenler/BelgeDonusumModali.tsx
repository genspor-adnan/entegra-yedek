import { useEffect, useMemo, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type AcikSatir, type BelgeYaniti } from '../api/sozlesme';
import { Modal } from './GenForm';

const say = new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 4 });
const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

/** Kaynak turden hangi hedeflere donusulebilir (belge turu kod uzayi, 073 katalogu). */
const HEDEFLER: Record<number, { kod: number; ad: string }[]> = {
  // Alis siparisi -> alis irsaliyesi / alis faturasi
  9:  [{ kod: 10, ad: 'Alış İrsaliyesi' }, { kod: 11, ad: 'Alış Faturası' }],
  // Satis siparisi -> satis irsaliyesi / satis faturasi
  19: [{ kod: 14, ad: 'Satış İrsaliyesi' }, { kod: 15, ad: 'Satış Faturası' }],
  // Irsaliyeler -> fatura
  10: [{ kod: 11, ad: 'Alış Faturası' }],
  14: [{ kod: 15, ad: 'Satış Faturası' }],
  // Konsinye -> fatura
  109: [{ kod: 11, ad: 'Alış Faturası' }],
  119: [{ kod: 15, ad: 'Satış Faturası' }],
};

interface Props {
  belgeId: number;
  belgeTur: number;
  onKapat(): void;
  /** Donusum bittiginde cagrilir - cagiran yalnizca grid'i tazeler. */
  onTamam(yeni: BelgeYaniti): void;
}

/**
 * Sipariş → irsaliye → fatura dönüşümü.
 *
 * KISMI donusum esastir: kullanici her satirdan ne kadarini aktaracagini secer,
 * kalan kaynak belgede durur. Miktar kontrolu SUNUCUDA yapilir (kaynak satirlar
 * kilitlenerek) - buradaki sinir yalnizca kullaniciyi erken uyarmak icindir.
 */
export function BelgeDonusumModali({ belgeId, belgeTur, onKapat, onTamam }: Props) {
  const [satirlar, setSatirlar] = useState<AcikSatir[]>([]);
  const [miktarlar, setMiktarlar] = useState<Record<number, string>>({});
  const [secili, setSecili] = useState<Record<number, boolean>>({});
  const [hedefTur, setHedefTur] = useState<number>(HEDEFLER[belgeTur]?.[0]?.kod ?? 0);
  const [tarih, setTarih] = useState(new Date().toISOString().slice(0, 10));
  const [taslak, setTaslak] = useState(false);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [sonuc, setSonuc] = useState<BelgeYaniti | null>(null);

  useEffect(() => {
    void (async () => {
      try {
        const s = await api.belgeAcikSatirlar(belgeId);
        setSatirlar(s);
        setSecili(Object.fromEntries(s.map(x => [x.satirId, true])));
        setMiktarlar(Object.fromEntries(s.map(x => [x.satirId, String(x.kalanMiktar)])));
      } catch (h) {
        setHata(h instanceof ApiHatasi ? h.message : String(h));
      } finally { setYukleniyor(false) }
    })();
  }, [belgeId]);

  const hedefler = HEDEFLER[belgeTur] ?? [];
  const sayi = (m: string) => Number(m.replace(/\./g, '').replace(',', '.')) || 0;

  const toplam = useMemo(() =>
    satirlar.reduce((t, s) => secili[s.satirId]
      ? t + sayi(miktarlar[s.satirId] ?? '0') * Number(s.birimFiyat ?? 0) : t, 0),
    [satirlar, secili, miktarlar]);

  const seciliSayi = satirlar.filter(s => secili[s.satirId] && sayi(miktarlar[s.satirId] ?? '0') > 0).length;

  async function donustur() {
    setHata(null);
    const gonderilecek = satirlar
      .filter(s => secili[s.satirId] && sayi(miktarlar[s.satirId] ?? '0') > 0)
      .map(s => ({ satirId: s.satirId, miktar: sayi(miktarlar[s.satirId]) }));

    if (gonderilecek.length === 0) { setHata('En az bir satır seçilmeli.'); return }
    if (!hedefTur) { setHata('Hedef belge türü seçilmeli.'); return }

    const asan = gonderilecek.find(g => {
      const s = satirlar.find(x => x.satirId === g.satirId)!;
      return g.miktar > Number(s.kalanMiktar);
    });
    if (asan) { setHata('Bir satırda girilen miktar kalanı aşıyor.'); return }

    setCalisiyor(true);
    try {
      const yeni = await api.belgeDonustur(belgeId, hedefTur, gonderilecek, tarih, taslak);
      setSonuc(yeni);
      // Kalan satirlari tazele: ayni siparisten ikinci bir belge kesilebilir.
      setSatirlar(await api.belgeAcikSatirlar(belgeId));
      onTamam(yeni);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally { setCalisiyor(false) }
  }

  return (
    <Modal
      baslik="Belge Dönüştür"
      onKapat={onKapat}
      alt={
        <>
          <button className="d" onClick={onKapat}>Kapat</button>
          <button className="d bir" disabled={calisiyor || satirlar.length === 0}
                  onClick={() => void donustur()}>
            {calisiyor ? 'Dönüştürülüyor…' : sonuc ? '⇢ Kalanı Dönüştür' : '⇢ Dönüştür'}
          </button>
        </>
      }
    >
      {hata && <div className="hata-kutusu">{hata}</div>}

      {sonuc && (
        <div className="bilgi-kutusu">
          <b>{hedefler.find(h => h.kod === hedefTur)?.ad ?? 'Belge'} oluşturuldu.</b>{' '}
          No: <b>{String(sonuc.belge.belgeNo || '(taslak — numara verilmedi)')}</b> ·
          Genel toplam: <b>{para.format(Number(sonuc.belge.genelToplam))}</b>
          {sonuc.uyarilar && sonuc.uyarilar.length > 0 && (
            <ul className="uyari-liste">{sonuc.uyarilar.map((u, i) => <li key={i}>{u}</li>)}</ul>
          )}
        </div>
      )}

      {hedefler.length === 0 ? (
        <div className="bilgi-kutusu">Bu belge türü için tanımlı bir dönüşüm hedefi yok.</div>
      ) : (
        <>
          <div className="kagrup">
            <h6>Hedef</h6>
            <div className="alan-izgara">
              <label className="alan">
                <span className="etiket">Hedef Belge</span>
                <select value={hedefTur} onChange={e => setHedefTur(Number(e.target.value))}>
                  {hedefler.map(h => <option key={h.kod} value={h.kod}>{h.ad}</option>)}
                </select>
              </label>
              <label className="alan">
                <span className="etiket">Belge Tarihi</span>
                <input type="date" value={tarih} onChange={e => setTarih(e.target.value)} />
              </label>
              <label className="alan">
                <span className="etiket">&nbsp;</span>
                <span className="satir-ici">
                  <input type="checkbox" checked={taslak}
                         onChange={e => setTaslak(e.target.checked)} />
                  Taslak (numara tüketmez)
                </span>
              </label>
            </div>
          </div>

          <div className="kagrup">
            <h6>Dönüştürülecek Satırlar</h6>
            {yukleniyor ? <div className="yukleniyor">Yükleniyor…</div> : (
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th style={{ width: 34 }} />
                    <th>Stok / Açıklama</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Miktar</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Dönüşen</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Kalan</th>
                    <th className="hiza-sag" style={{ width: 120 }}>Bu Belgeye</th>
                    <th className="hiza-sag" style={{ width: 110 }}>Birim Fiyat</th>
                  </tr>
                </thead>
                <tbody>
                  {satirlar.map(s => (
                    <tr key={s.satirId}>
                      <td className="hiza-orta">
                        <input
                          type="checkbox"
                          checked={!!secili[s.satirId]}
                          onChange={e => setSecili(x => ({ ...x, [s.satirId]: e.target.checked }))}
                        />
                      </td>
                      <td>
                        {s.stokKodu ? <><code>{s.stokKodu}</code> {s.stokAdi}</> : s.aciklama}
                      </td>
                      <td className="hiza-sag">{say.format(Number(s.miktar))}</td>
                      <td className="hiza-sag">{say.format(Number(s.kapatilanMiktar))}</td>
                      <td className="hiza-sag"><b>{say.format(Number(s.kalanMiktar))}</b></td>
                      <td>
                        <input
                          className="hiza-sag"
                          value={miktarlar[s.satirId] ?? ''}
                          disabled={!secili[s.satirId]}
                          onChange={e => setMiktarlar(x => ({ ...x, [s.satirId]: e.target.value }))}
                        />
                      </td>
                      <td className="hiza-sag">{para.format(Number(s.birimFiyat ?? 0))}</td>
                    </tr>
                  ))}
                  {satirlar.length === 0 && (
                    <tr><td colSpan={7} className="bos">Dönüştürülecek açık satır yok.</td></tr>
                  )}
                </tbody>
                <tfoot>
                  <tr className="genel">
                    <td colSpan={5}>{seciliSayi} satır seçili</td>
                    <td className="hiza-sag" colSpan={2}>
                      {para.format(toplam)} (KDV hariç, önizleme)
                    </td>
                  </tr>
                </tfoot>
              </table>
            )}
          </div>

          <div className="not">
            Kalan miktar kaynağında durur; aynı siparişten birden fazla irsaliye/fatura
            kesilebilir. Miktar kontrolü sunucuda, kaynak satırlar kilitlenerek yapılır.
          </div>
        </>
      )}
    </Modal>
  );
}
