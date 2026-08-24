import { useState } from 'react';
import { Modal } from './Modal';
import { StokAramaPenceresi } from './StokAramaPenceresi';
import type { DetayDurumu, Satir } from './GenDetayTablo';
import type { KartDetayMeta, ListeSatiri } from '../api/sozlesme';

/** Tutar bicimi - grid hucrelerinde iki hane. */
const para = new Intl.NumberFormat('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });


/**
 * PAKET ICERIGI SEKMESI (124/125) - jenerik detay gridinin YERINE.
 *
 * Icerik satiri elle YAZILMAZ: kullanici stok kodunu ezberden giremez, girse
 * de birim ile fiyati ayrica doldurmasi gerekirdi. Burada satir tek yoldan
 * gelir - belge kalemindeki AYNI stok arama penceresi - ve secilen stogun
 * birimi ile satis fiyati satira hazir yazilir. Grid bu yuzden salt gorunum;
 * duzenleme satira tiklayinca acilan kucuk pencerede yapilir (belge kalem
 * penceresi deseni).
 *
 * Baslik ve cerceve YOK (kullanici): sekmenin kendi adi zaten "Paket".
 */
export function PaketSekmesi({ meta, durum, saltOkunur, onDegis }: {
  meta: KartDetayMeta;
  durum: DetayDurumu;
  saltOkunur: boolean;
  onDegis(yeni: DetayDurumu): void;
}) {
  const [arama, setArama] = useState(false);
  /** Duzenlenen satir - yeni satirda id yok, dizin ile bulunur. */
  const [satirDuzen, setSatirDuzen] = useState<{ dizin: number; satir: Satir } | null>(null);

  const kodlar = (ad: string) => meta.alanlar.find(a => a.ad === ad)?.kodlar ?? {};
  const birimAdi = (deger: unknown) => kodlar('birim')[String(deger ?? '')] ?? '';
  const stokAdi = (s: Satir) =>
    String(s.ad ?? kodlar('icerikStokId')[String(s.icerikStokId ?? '')] ?? '');
  const stokKodu = (s: Satir) => {
    if (s.kod) return String(s.kod);
    // Yeni satirda kod yerelde tutulur; kayitli satirda lookup etiketi
    //   "KOD — Ad" bicimindedir.
    const etiket = kodlar('icerikStokId')[String(s.icerikStokId ?? '')] ?? '';
    return etiket.includes(' — ') ? etiket.split(' — ')[0] : '';
  };

  const yaz = (guncel: Satir[], silinen = durum.silinen) => onDegis({ ...durum, guncel, silinen });

  const stokSecildi = (r: ListeSatiri) => {
    setSatirDuzen({
      dizin: durum.guncel.length,
      satir: {
        icerikStokId: String(r.id ?? ''),
        kod: String(r.kod ?? ''),
        ad: String(r.ad ?? ''),
        birim: String(r.anaBirimKod ?? ''),
        adet: '1',
        birimFiyat: r.fiyat ? String(r.fiyat) : '',
        dovizCinsi: String(r.fiyatDovizi ?? '') || 'TL',
      },
    });
  };

  const satirKaydet = (satir: Satir) => {
    if (!satirDuzen) return;
    const guncel = [...durum.guncel];
    guncel[satirDuzen.dizin] = satir;
    yaz(guncel);
    setSatirDuzen(null);
  };

  const satirSil = (dizin: number) => {
    const satir = durum.guncel[dizin];
    const silinen = satir.id != null ? [...durum.silinen, Number(satir.id)] : durum.silinen;
    yaz(durum.guncel.filter((_, i) => i !== dizin), silinen);
  };

  return (
    <>
      {!saltOkunur && (
        <div className="detay-arac">
          <button className="d" onClick={() => setArama(true)}>＋ Stok Ekle</button>
          <span className="alan-notu">
            Satırlar stok kartından gelir; birim ve fiyat seçilen stoktan yazılır.
            Satıra tıklayarak adet/fiyat değiştirilir.
          </span>
        </div>
      )}

      <table className="detay-tablo secilebilir">
        <thead>
          <tr>
            <th style={{ width: 130 }}>Kod</th>
            <th>Ad</th>
            <th style={{ width: 90 }} className="hiza-orta">Birim</th>
            <th style={{ width: 90 }} className="hiza-sag">Adet</th>
            <th style={{ width: 110 }} className="hiza-sag">Birim Fiyat</th>
            <th style={{ width: 70 }} className="hiza-orta">Döviz</th>
            {!saltOkunur && <th style={{ width: 40 }} />}
          </tr>
        </thead>
        <tbody>
          {durum.guncel.map((s, i) => (
            <tr key={s.id != null ? `k${s.id}` : `y${i}`}
                onClick={() => !saltOkunur && setSatirDuzen({ dizin: i, satir: s })}>
              <td><code>{stokKodu(s)}</code></td>
              <td>{stokAdi(s)}</td>
              <td className="hiza-orta sonuk">{birimAdi(s.birim)}</td>
              <td className="hiza-sag">{Number(s.adet ?? 0).toLocaleString('tr-TR')}</td>
              <td className="hiza-sag">
                {Number(s.birimFiyat ?? 0) > 0
                  ? para.format(Number(s.birimFiyat))
                  : <span className="sonuk">—</span>}
              </td>
              <td className="hiza-orta sonuk">{String(s.dovizCinsi ?? '')}</td>
              {!saltOkunur && (
                <td className="hiza-orta">
                  <button className="d ufak" title="Satırı sil"
                          onClick={e => { e.stopPropagation(); satirSil(i) }}>✖</button>
                </td>
              )}
            </tr>
          ))}
          {durum.guncel.length === 0 && (
            <tr><td colSpan={saltOkunur ? 6 : 7} className="bos">
              Paket içeriği boş — “＋ Stok Ekle” ile ürün seçin.
            </td></tr>
          )}
        </tbody>
      </table>

      {arama && (
        <StokAramaPenceresi
          etkin={satirDuzen === null}
          yalnizStok
          onSec={stokSecildi}
          onKapat={() => setArama(false)}
        />
      )}

      {satirDuzen && (
        <PaketSatirPenceresi
          satir={satirDuzen.satir}
          birimler={kodlar('birim')}
          dovizler={kodlar('dovizCinsi')}
          onKaydet={satirKaydet}
          onKapat={() => setSatirDuzen(null)}
        />
      )}
    </>
  );
}

/** Adet / birim / fiyat penceresi - grid salt gorunum oldugu icin giris burada. */
function PaketSatirPenceresi({ satir, birimler, dovizler, onKaydet, onKapat }: {
  satir: Satir;
  birimler: Record<string, string>;
  dovizler: Record<string, string>;
  onKaydet(satir: Satir): void;
  onKapat(): void;
}) {
  const [taslak, setTaslak] = useState<Satir>(satir);
  const degis = (ad: string, deger: string) => setTaslak(t => ({ ...t, [ad]: deger }));
  const gecerli = Number(String(taslak.adet ?? '').replace(',', '.')) > 0;

  return (
    <Modal
      baslik={`Paket İçeriği — ${String(taslak.kod ?? '')} ${String(taslak.ad ?? '')}`.trim()}
      dar
      onKapat={onKapat}
      alt={
        <>
          <button className="d ana" disabled={!gecerli}
                  onClick={() => onKaydet(taslak)}>Tamam</button>
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>
        </>
      }
    >
      <div className="kasira">
        <div className="kagrup">
          <div className="alan-izgara tek-sutun">
            <label className="alan tip-kod">
              <span className="etiket">Birim</span>
              <select value={String(taslak.birim ?? '')} onChange={e => degis('birim', e.target.value)}>
                <option value="">—</option>
                {Object.entries(birimler).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
              </select>
            </label>
            <label className="alan tip-para">
              <span className="etiket">Adet<b className="zorunlu"> *</b></span>
              <input autoFocus value={String(taslak.adet ?? '')}
                     onChange={e => degis('adet', e.target.value)} />
            </label>
            <label className="alan tip-para">
              <span className="etiket">Birim Fiyat</span>
              <input value={String(taslak.birimFiyat ?? '')}
                     onChange={e => degis('birimFiyat', e.target.value)} />
            </label>
            <label className="alan tip-kod">
              <span className="etiket">Döviz</span>
              <select value={String(taslak.dovizCinsi ?? 'TL')}
                      onChange={e => degis('dovizCinsi', e.target.value)}>
                {Object.entries(dovizler).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
              </select>
            </label>
          </div>
          <div className="not">
            Fiyat boş bırakılırsa belgeye eklenirken stoğun kendi kart fiyatı kullanılır.
          </div>
        </div>
      </div>
    </Modal>
  );
}
