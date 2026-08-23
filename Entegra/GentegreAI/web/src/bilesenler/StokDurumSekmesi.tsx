import { useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type StokDurumYaniti } from '../api/sozlesme';

const say = new Intl.NumberFormat('tr-TR', { maximumFractionDigits: 4 });

/** Bos hucre "0" degil TIRE gosterir - "tanimlanmamis" ile "sifir" ayri seylerdir. */
const limitMetni = (d: number | null | undefined) =>
  d === null || d === undefined ? '' : say.format(Number(d));

const sayiCoz = (m: string): number | null => {
  const t = m.trim();
  if (t === '') return null;
  const s = Number(t.replace(/\./g, '').replace(',', '.'));
  return Number.isFinite(s) ? s : null;
};

/**
 * Stok kartı "Stok Durumu" sekmesi — Ekranlar/stok_karti.html.
 *
 * MIKTARLAR SALT OKUNUR: stok_durum belge kaydında güncellenir (mockup'ın notu:
 * "Miktarlar salt-okunur, STOKDURUM tetiklerle güncellenir"). Buradan yazılabilen
 * tek şey depo bazlı Min/Max seviyedir (099) - hücreye girilip Enter/blur ile
 * kaydedilir, sunucu yanıtı bütün satırları ve KPI'ları tazeler.
 *
 * Rezerve = açık SATIŞ siparişi kalanı, Yoldaki = açık ALIŞ siparişi kalanı;
 * ikisi de F8'in kalan_miktar sayacından türer, ayrı rezervasyon tablosu yok.
 */
export function StokDurumSekmesi({ stokId, duzenlenebilir }: {
  stokId: number;
  duzenlenebilir: boolean;
}) {
  const [veri, setVeri] = useState<StokDurumYaniti | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);
  const [hata, setHata] = useState<string | null>(null);
  /** Hucre duzenleme: "<depoId>:min" | "<depoId>:max" -> girilen metin. */
  const [taslak, setTaslak] = useState<Record<string, string>>({});

  const yukle = useCallback(async () => {
    try {
      setVeri(await api.stokDurum(stokId));
      setHata(null);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally { setYukleniyor(false) }
  }, [stokId]);

  useEffect(() => { void yukle() }, [yukle]);

  async function limitYaz(depoId: number, hangi: 'min' | 'max', metin: string) {
    const satir = veri?.satirlar.find(s => s.depoId === depoId);
    if (!satir) return;
    const yeni = sayiCoz(metin);
    const eski = hangi === 'min' ? satir.minStok : satir.maxStok;
    setTaslak(t => { const y = { ...t }; delete y[`${depoId}:${hangi}`]; return y });
    if ((eski ?? null) === yeni) return;                       // degismediyse istek yok

    try {
      setVeri(await api.stokDurumLimit(stokId, depoId,
        hangi === 'min' ? yeni : satir.minStok ?? null,
        hangi === 'max' ? yeni : satir.maxStok ?? null));
      setHata(null);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
      void yukle();
    }
  }

  if (yukleniyor) return <div className="yukleniyor">Yükleniyor…</div>;

  const birim = veri?.birim ? ` ${veri.birim}` : '';
  const o = veri?.ozet;

  const limitHucre = (depoId: number, hangi: 'min' | 'max', deger: number | null) => {
    const anahtar = `${depoId}:${hangi}`;
    if (!duzenlenebilir) return <td className="hiza-sag">{limitMetni(deger)}</td>;
    return (
      <td className="hiza-sag">
        <input className="hiza-sag hucre-girdi"
               value={taslak[anahtar] ?? limitMetni(deger)}
               placeholder="—"
               onChange={e => setTaslak(t => ({ ...t, [anahtar]: e.target.value }))}
               onBlur={e => void limitYaz(depoId, hangi, e.target.value)}
               onKeyDown={e => { if (e.key === 'Enter') (e.target as HTMLInputElement).blur() }} />
      </td>
    );
  };

  return (
    <>
      {hata && <div className="hata-kutusu">{hata}</div>}

      <div className="kpi-serit">
        <div className="kpi">
          <div className="k">Toplam Stok</div>
          <div className="v">{say.format(Number(o?.toplam ?? 0))}{birim}</div>
          <div className="s">{o?.depoSayisi ?? 0} depoda</div>
        </div>
        <div className="kpi">
          <div className="k">Rezerve</div>
          <div className="v uyari">{say.format(Number(o?.rezerve ?? 0))}{birim}</div>
          <div className="s">açık siparişler</div>
        </div>
        <div className="kpi">
          <div className="k">Kullanılabilir</div>
          <div className="v olumlu">{say.format(Number(o?.kullanilabilir ?? 0))}{birim}</div>
          <div className="s">satışa hazır</div>
        </div>
        <div className="kpi">
          <div className="k">Yoldaki (Sipariş)</div>
          <div className="v">{say.format(Number(o?.yolda ?? 0))}{birim}</div>
          <div className="s">açık alış siparişleri</div>
        </div>
      </div>

      <div className="kagrup">
        <h6>Depo Bazlı Stok</h6>
        <table className="detay-tablo">
          <thead>
            <tr>
              <th>Depo</th>
              <th className="hiza-sag" style={{ width: 90 }}>Miktar</th>
              <th className="hiza-sag" style={{ width: 90 }}>Rezerve</th>
              <th className="hiza-sag" style={{ width: 100 }}>Kullanılab.</th>
              <th className="hiza-sag" style={{ width: 90 }}>Yolda</th>
              <th className="hiza-sag" style={{ width: 80 }}>Min</th>
              <th className="hiza-sag" style={{ width: 80 }}>Max</th>
              <th className="hiza-orta" style={{ width: 90 }}>Durum</th>
            </tr>
          </thead>
          <tbody>
            {(veri?.satirlar ?? []).map(s => (
              <tr key={s.depoId}>
                <td>{s.depoAdi}</td>
                <td className="hiza-sag"><b>{say.format(Number(s.miktar))}</b></td>
                <td className="hiza-sag">{Number(s.rezerve) ? say.format(Number(s.rezerve)) : ''}</td>
                <td className="hiza-sag">{say.format(Number(s.kullanilabilir))}</td>
                <td className="hiza-sag">{Number(s.yolda) ? say.format(Number(s.yolda)) : ''}</td>
                {limitHucre(s.depoId, 'min', s.minStok)}
                {limitHucre(s.depoId, 'max', s.maxStok)}
                <td className="hiza-orta">
                  <span className={`rozet ${s.durum === 'yeterli' ? 'ok'
                                          : s.durum === 'kritik' ? 'uyari' : 'hata'}`}>
                    {s.durum === 'yeterli' ? 'Yeterli' : s.durum === 'kritik' ? 'Kritik ↓' : 'Yok'}
                  </span>
                </td>
              </tr>
            ))}
            {(veri?.satirlar ?? []).length === 0 && (
              <tr><td colSpan={8} className="bos">Bu stokun hiçbir depoda hareketi yok.</td></tr>
            )}
          </tbody>
        </table>
        <div className="not">
          Miktarlar <b>salt-okunur</b>: belge kaydında güncellenir. Min/Max seviye depo
          bazlı tanımlanır; boş bırakılırsa stok kartındaki Minimum Stok geçerlidir.
          <b> Kullanılabilir</b> = Miktar − Rezerve; kritik uyarısı bu değere bakar.
        </div>
      </div>
    </>
  );
}
