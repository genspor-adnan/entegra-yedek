import { Fragment, useCallback, useEffect, useState } from 'react';
import { api } from '../api/istemci';
import { ApiHatasi, type StokDurumYaniti, type StokLotSatiri } from '../api/sozlesme';
import { say4 } from './bicim';


/** "2027-06-30T00:00:00" -> "30.06.2027"; bos ise tire. */
const gun = (t?: string | null) => (t ? t.slice(0, 10).split('-').reverse().join('.') : '—');

/**
 * Depo satirinin altindaki lot dokumu (master-detail). Eskiden karttaki ayri
 * "Seri / Lot" sekmesiydi: orada lotlar DEPOSUZ, tek liste halindeydi ve
 * "hangi depoda hangi lottan ne kadar var" sorusunu cevaplamiyordu.
 */
function lotTablosu(satirlar: StokLotSatiri[]) {
  return (
    <table className="lot-tablo">
      <thead>
        <tr>
          <th>Lot No</th>
          <th>Seri No</th>
          <th>Ürt. Tarihi</th>
          <th>SKT</th>
          <th className="hiza-sag">Kalan</th>
        </tr>
      </thead>
      <tbody>
        {satirlar.map(l => (
          <tr key={`${l.seriLotId}-${l.depoId ?? 0}`}>
            <td><code>{l.lotNo || '—'}</code></td>
            <td>{l.seriNo || '—'}</td>
            <td>{gun(l.uretimTarihi)}</td>
            <td>{gun(l.sonKullanmaTarihi)}</td>
            <td className="hiza-sag">{say4.format(Number(l.kalan))}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

/** Bos hucre "0" degil TIRE gosterir - "tanimlanmamis" ile "sifir" ayri seylerdir. */
const limitMetni = (d: number | null | undefined) =>
  d === null || d === undefined ? '' : say4.format(Number(d));

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
  /** Stokun lot dagilimi (115) - depo satirinin altinda master-detail acilir. */
  const [lotlar, setLotlar] = useState<StokLotSatiri[]>([]);
  /** Lot detayi ACIK depolar. Kullanici oka basinca acilir - her depo icin ayri. */
  const [acikDepolar, setAcikDepolar] = useState<Set<number>>(new Set());

  const yukle = useCallback(async () => {
    try {
      setVeri(await api.stokDurum(stokId));
      setHata(null);
    } catch (h) {
      setHata(h instanceof ApiHatasi ? h.message : String(h));
    } finally { setYukleniyor(false) }
  }, [stokId]);

  useEffect(() => { void yukle() }, [yukle]);

  // Lot dagilimi ayri istek: izlemsiz stokta bos doner, ekrani bekletmez.
  useEffect(() => {
    let iptal = false;
    void api.stokLotlari(stokId)
      .then(l => { if (!iptal) setLotlar(l) })
      .catch(() => { if (!iptal) setLotlar([]) });
    return () => { iptal = true };
  }, [stokId]);

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
          <div className="v">{say4.format(Number(o?.toplam ?? 0))}{birim}</div>
          <div className="s">{o?.depoSayisi ?? 0} depoda</div>
        </div>
        <div className="kpi">
          <div className="k">Rezerve</div>
          <div className="v uyari">{say4.format(Number(o?.rezerve ?? 0))}{birim}</div>
          <div className="s">açık siparişler</div>
        </div>
        <div className="kpi">
          <div className="k">Kullanılabilir</div>
          <div className="v olumlu">{say4.format(Number(o?.kullanilabilir ?? 0))}{birim}</div>
          <div className="s">satışa hazır</div>
        </div>
        <div className="kpi">
          <div className="k">Yoldaki (Sipariş)</div>
          <div className="v">{say4.format(Number(o?.yolda ?? 0))}{birim}</div>
          <div className="s">açık alış siparişleri</div>
        </div>
      </div>

      {/* Cerceve YOK (kullanici karari): KPI seridinin altinda dogrudan tablo -
          tek tablo icin baslikli kutu fazladan bir kat gorsel gurultuydu. */}
      <div className="depo-stok">
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
            {(veri?.satirlar ?? []).map(s => {
              // O deponun lotlari. Deposu BILINMEYEN (gocmus) lotlar asagida
              //   ayri bir satirda toplanir - hicbir depoya yazamayiz.
              const depoLotlari = lotlar.filter(l => l.depoId === s.depoId);
              const acik = acikDepolar.has(s.depoId);
              return (
              <Fragment key={s.depoId}>
              <tr>
                <td>
                  {depoLotlari.length > 0 && (
                    <button type="button" className="lot-ok"
                            title={acik ? 'Lotları gizle' : 'Lotları göster'}
                            onClick={() => setAcikDepolar(k => {
                              const y = new Set(k);
                              if (y.has(s.depoId)) y.delete(s.depoId); else y.add(s.depoId);
                              return y;
                            })}>
                      {acik ? '▾' : '▸'}
                    </button>
                  )}
                  {s.depoAdi}
                  {depoLotlari.length > 0 && (
                    <span className="sonuk"> · {depoLotlari.length} lot</span>
                  )}
                </td>
                <td className="hiza-sag"><b>{say4.format(Number(s.miktar))}</b></td>
                <td className="hiza-sag">{Number(s.rezerve) ? say4.format(Number(s.rezerve)) : ''}</td>
                <td className="hiza-sag">{say4.format(Number(s.kullanilabilir))}</td>
                <td className="hiza-sag">{Number(s.yolda) ? say4.format(Number(s.yolda)) : ''}</td>
                {limitHucre(s.depoId, 'min', s.minStok)}
                {limitHucre(s.depoId, 'max', s.maxStok)}
                <td className="hiza-orta">
                  <span className={`rozet ${s.durum === 'yeterli' ? 'ok'
                                          : s.durum === 'kritik' ? 'uyari' : 'hata'}`}>
                    {s.durum === 'yeterli' ? 'Yeterli' : s.durum === 'kritik' ? 'Kritik ↓' : 'Yok'}
                  </span>
                </td>
              </tr>
              {acik && depoLotlari.length > 0 && (
                <tr className="lot-detay">
                  <td colSpan={8}>{lotTablosu(depoLotlari)}</td>
                </tr>
              )}
              </Fragment>
            )})}
            {(veri?.satirlar ?? []).length === 0 && (
              <tr><td colSpan={8} className="bos">Bu stokun hiçbir depoda hareketi yok.</td></tr>
            )}
            {/* Deposu bilinmeyen lotlar: gocmus hareketlerin kaynak verisinde
                depo yok (115). Gizlemek yerine ayri satirda gosterilir - mal
                stokta, yeri belirsiz. */}
            {lotlar.some(l => l.depoId === null || l.depoId === undefined) && (
              <>
                <tr>
                  <td colSpan={8} className="sonuk">
                    <button type="button" className="lot-ok"
                            onClick={() => setAcikDepolar(k => {
                              const y = new Set(k);
                              if (y.has(0)) y.delete(0); else y.add(0);
                              return y;
                            })}>
                      {acikDepolar.has(0) ? '▾' : '▸'}
                    </button>
                    Deposu belirsiz (göçmüş hareketler)
                    <span className="sonuk"> · {lotlar.filter(l => !l.depoId).length} lot</span>
                  </td>
                </tr>
                {acikDepolar.has(0) && (
                  <tr className="lot-detay">
                    <td colSpan={8}>{lotTablosu(lotlar.filter(l => !l.depoId))}</td>
                  </tr>
                )}
              </>
            )}
          </tbody>
        </table>
        <div className="not">
          Depo satırındaki ok, o depodaki <b>lot/seri dağılımını</b> açar (izlemli
          stoklarda). Lotlar belge kaydıyla oluşur; burada düzenlenmez.
          Miktarlar <b>salt-okunur</b>: belge kaydında güncellenir. Min/Max seviye depo
          bazlı tanımlanır; boş bırakılırsa stok kartındaki Minimum Stok geçerlidir.
          <b> Kullanılabilir</b> = Miktar − Rezerve; kritik uyarısı bu değere bakar.
        </div>
      </div>
    </>
  );
}
