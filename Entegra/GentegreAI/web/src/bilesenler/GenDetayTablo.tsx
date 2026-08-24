import type { DetayFarki, KartDetayMeta } from '../api/sozlesme';
import { useYerler, VARSAYILAN_ULKE } from './yerlerHook';
import { TelefonGirdi } from './TelefonGirdi';
import { telefonAlaniMi, telefonGecerliMi } from './alanBicim';

export type Satir = Record<string, unknown> & { id?: number };

/**
 * Detay tablosunun duzenleme durumu. Sunucuya TAM LISTE degil FARK gonderilir
 * (§3.2), bu yuzden ilk hal ile guncel hal birlikte tutulur.
 */
export interface DetayDurumu {
  ilk: Satir[];        // karttan geldigi hali
  guncel: Satir[];     // ekranda duzenlenmis hali
  silinen: number[];   // kaldirilan mevcut satirlarin id'leri
}

export const bosDetay = (satirlar: Satir[] = []): DetayDurumu => ({
  ilk: satirlar.map(s => ({ ...s })),
  guncel: satirlar.map(s => ({ ...s })),
  silinen: [],
});

/** Ekrandaki durumdan sunucunun bekledigi fark listesini uretir. */
export function detayFarki(durum: DetayDurumu): DetayFarki {
  // YENI satirda BOS birakilan alan HIC GONDERILMEZ (GenForm'daki kuralin
  //   detay karsiligi): bos metin NOT NULL + varsayilanli kolonlarda
  //   "birim bos birakilamaz" gibi hatalara yol aciyordu. Gonderilmeyince
  //   veritabani varsayilani devreye girer.
  const eklenen = durum.guncel
    .filter(s => s.id === undefined || s.id === null)
    .map(s => Object.fromEntries(
      Object.entries(s).filter(([, v]) => v !== '' && v !== null && v !== undefined)) as Satir);

  const degisen = durum.guncel
    .filter(s => s.id !== undefined && s.id !== null)
    .map(s => {
      const eski = durum.ilk.find(i => i.id === s.id);
      if (!eski) return null;
      // Yalniz gercekten degisen alanlar gonderilir
      const fark: Satir = { id: s.id };
      let degisti = false;
      Object.keys(s).forEach(alan => {
        if (alan === 'id') return;
        if (String(s[alan] ?? '') !== String(eski[alan] ?? '')) { fark[alan] = s[alan]; degisti = true }
      });
      return degisti ? fark : null;
    })
    .filter(Boolean) as Satir[];

  return {
    eklenen: eklenen.length ? eklenen : undefined,
    degisen: degisen.length ? degisen : undefined,
    silinen: durum.silinen.length ? durum.silinen : undefined,
  };
}

interface Props {
  meta: KartDetayMeta;
  durum: DetayDurumu;
  saltOkunur: boolean;
  hatalar: Record<string, string>;
  onDegis(yeni: DetayDurumu): void;
}

// Adresler grid'ine ozel kolon genislikleri (kullanici: "Adres geniş, İl/İlçe aynı
// genişlik, Ülke ... dar, PK çok dar"). Diger detay tablolari (stok_izleme vb.) bundan
// etkilenmez - sadece meta.ad==='adresler' iken colgroup basılır.
const ADRES_GENISLIK: Record<string, string> = {
  tur: '12%', adres: '30%', il: '13%', ilce: '13%', ulke: '10%',
  postaKodu: '7%', varsayilan: '7%', aktif: '7%',
};

const DIPLOMA_ADLARI = [
  'İlkokul',
  'Ortaokul',
  'Lise',
  'Ön Lisans (Yüksek Okul)',
  'Lisans',
  'Yüksek Lisans (Master)',
  'Doktora',
];

const EGITIM_GECERLILIK = ['Süresiz', 'Süreli'];

const tarihYilTemizle = (deger: string) => deger.replace(/[^0-9./-]/g, '').slice(0, 10);

export function GenDetayTablo({ meta, durum, saltOkunur, hatalar, onDegis }: Props) {
  const alanlar = meta.alanlar.filter(a => a.ad !== 'id');
  const yerler = useYerler(meta.ad === 'adresler');
  const adresGrid = meta.ad === 'adresler';
  const acilKisiGrid = meta.ad === 'acilKisiler';
  const ilAdIdHarita = new Map((yerler?.iller ?? []).map(i => [i.ad, i.id]));

  const hucreDegis = (satirIndeks: number, alan: string, deger: unknown) => {
    const guncel = durum.guncel.map((s, i) => {
      if (meta.ad === 'acilKisiler' && alan === 'varsayilan' && (deger === true || Number(deger) === 1)) {
        return { ...s, varsayilan: i === satirIndeks ? 1 : 0 };
      }
      return i === satirIndeks ? { ...s, [alan]: deger } : s;
    });
    onDegis({ ...durum, guncel });
  };

  // Adresler'de acik (Adres Tipi secilmemis) satir varken yeni satir eklenemez (kullanici:
  // "adres te fatura tipi seçilmeden yeni satır açılmasın" - Adres Tipi kastediliyor).
  const acikAdresSatiriVar = adresGrid && durum.guncel.some(s => !s.tur);
  const satirEklenebilir = !saltOkunur && !acikAdresSatiriVar;

  const satirEkle = () => {
    if (acikAdresSatiriVar) return;
    const yeni: Satir = {};
    // "aktif" alani yeni satirda ACIK baslar: kullanici bir kayit eklerken onu
    //   pasif olsun diye eklemez. Kapali baslayinca (banka subesi ornegi) satir
    //   kaydediliyor ama secim listelerinde HIC gorunmuyordu.
    alanlar.forEach(a => {
      yeni[a.ad] = a.tip === 'mantik' ? (a.ad === 'aktif' ? 1 : 0) : '';
    });
    if (meta.ad === 'adresler') {
      yeni.ulke = VARSAYILAN_ULKE;
      // Ilk satir (henuz hic adres yok) - Adres Tipi varsayilan "Fatura" (kullanici:
      // "cari kart adres eklemede ilk satır ise adres tipi Fatura olsun"). Bu grid SADECE
      // Cari'de kullaniliyor (Kisi'nin adresi TekAdres.tsx, ayri bilesen) - 1="Fatura"
      // guvenli (AdresTurKodlari).
      if (durum.guncel.length === 0) yeni.tur = '1';
    }
    if (meta.ad === 'egitimler') {
      yeni.tur = '1'; // Diploma
      yeni.gecerlilik = 'Süresiz';
    }
    if (meta.ad === 'acilKisiler' && durum.guncel.length === 0) {
      yeni.varsayilan = 1;
    }
    onDegis({ ...durum, guncel: [...durum.guncel, yeni] });
  };

  const satirSil = (satirIndeks: number) => {
    const satir = durum.guncel[satirIndeks];
    const guncel = durum.guncel.filter((_, i) => i !== satirIndeks);
    const silinen = satir.id != null ? [...durum.silinen, satir.id] : durum.silinen;
    onDegis({ ...durum, guncel, silinen });
  };

  return (
    <div className="kagrup">
      <h6>
        {meta.baslik}
        {!saltOkunur && (
          <button type="button" className="d bir" disabled={!satirEklenebilir} onClick={satirEkle}>
            {acilKisiGrid ? '＋ Kişi Ekle' : '+ Satir'}
          </button>
        )}
      </h6>

      <table className={`detay-tablo${adresGrid ? ' adres-tablo' : ''}`} style={adresGrid ? { tableLayout: 'fixed' } : undefined}>
        {adresGrid && (
          <colgroup>
            {alanlar.map(a => <col key={a.ad} style={{ width: ADRES_GENISLIK[a.ad] }} />)}
            {!saltOkunur && <col style={{ width: '6%' }} />}
          </colgroup>
        )}
        <thead>
          <tr>
            {alanlar.map(a => <th key={a.ad}>{a.baslik}{a.zorunlu && ' *'}</th>)}
            {!saltOkunur && <th />}
          </tr>
        </thead>
        <tbody>
          {durum.guncel.map((satir, i) => (
            <tr key={satir.id ?? `yeni-${i}`}>
              {alanlar.map(a => (
                <td key={a.ad}>
                  {/* TELEFON her yerde ayni (genel kural): gride de ulke kodlu,
                      gruplu kutu gelir; gecersiz numara kirmizi cerceve alir. */}
                  {telefonAlaniMi(a.ad) ? (
                    <span className={telefonGecerliMi(String(satir[a.ad] ?? '')) ? '' : 'tel-gecersiz'}>
                      <TelefonGirdi
                        value={String(satir[a.ad] ?? '')}
                        disabled={saltOkunur || !a.yazilabilir}
                        onChange={(v: string) => hucreDegis(i, a.ad, v)}
                      />
                    </span>
                  ) : a.tip === 'mantik' ? (
                    acilKisiGrid && a.ad === 'varsayilan' ? (
                      <button
                        type="button"
                        className="d"
                        title="Varsayılan"
                        disabled={saltOkunur || !a.yazilabilir}
                        onClick={() => hucreDegis(i, a.ad, Number(satir[a.ad]) === 1 || satir[a.ad] === true ? 0 : 1)}
                        style={{ minWidth: 24, height: 22, padding: 0 }}
                      >
                        {Number(satir[a.ad]) === 1 || satir[a.ad] === true ? '★' : ''}
                      </button>
                    ) : (
                      <input
                        type="checkbox"
                        checked={Number(satir[a.ad]) === 1 || satir[a.ad] === true}
                        disabled={saltOkunur || !a.yazilabilir}
                        onChange={e => hucreDegis(i, a.ad, e.target.checked)}
                      />
                    )
                  ) : meta.ad === 'adresler' && a.ad === 'il' && yerler ? (
                    <select
                      value={String(satir.il ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => {
                        const guncel = durum.guncel.map((s, ix) =>
                          ix === i ? { ...s, il: e.target.value, ilce: '' } : s);
                        onDegis({ ...durum, guncel });
                      }}
                    >
                      <option value="">—</option>
                      {yerler.iller.map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
                    </select>
                  ) : meta.ad === 'adresler' && a.ad === 'ulke' && yerler ? (
                    <select
                      value={String(satir.ulke ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {yerler.ulkeler.map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
                    </select>
                  ) : meta.ad === 'adresler' && a.ad === 'ilce' && yerler ? (
                    <select
                      value={String(satir.ilce ?? '')}
                      disabled={saltOkunur || !a.yazilabilir || !satir.il}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {yerler.ilceler
                        .filter(y => y.ilId === ilAdIdHarita.get(String(satir.il ?? '')))
                        .map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
                    </select>
                  ) : meta.ad === 'egitimler' && a.ad === 'ad' && String(satir.tur ?? '') === '1' ? (
                    <select
                      value={String(satir.ad ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {DIPLOMA_ADLARI.map(ad => <option key={ad} value={ad}>{ad}</option>)}
                    </select>
                  ) : meta.ad === 'egitimler' && a.ad === 'tarih' ? (
                    <input
                      value={String(satir.tarih ?? '')}
                      maxLength={10}
                      inputMode="numeric"
                      placeholder="YYYY veya GG.AA.YYYY"
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, tarihYilTemizle(e.target.value))}
                    />
                  ) : meta.ad === 'egitimler' && a.ad === 'gecerlilik' ? (
                    <select
                      value={String(satir.gecerlilik ?? 'Süresiz')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      {EGITIM_GECERLILIK.map(ad => <option key={ad} value={ad}>{ad}</option>)}
                    </select>
                  ) : a.kodlar ? (
                    <select
                      value={String(satir[a.ad] ?? '')}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    >
                      <option value="">—</option>
                      {Object.entries(a.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                    </select>
                  ) : (
                    <input
                      value={String(satir[a.ad] ?? '')}
                      maxLength={a.enFazlaUzunluk ?? undefined}
                      disabled={saltOkunur || !a.yazilabilir}
                      onChange={e => hucreDegis(i, a.ad, e.target.value)}
                    />
                  )}
                  {hatalar[`${meta.ad}.${a.ad}`] && (
                    <span className="alan-hata">{hatalar[`${meta.ad}.${a.ad}`]}</span>
                  )}
                </td>
              ))}
              {!saltOkunur && (
                <td className="hiza-orta">
                  <button type="button" className="d teh" onClick={() => satirSil(i)}>×</button>
                </td>
              )}
            </tr>
          ))}
          {durum.guncel.length === 0 && (
            <tr><td colSpan={alanlar.length + 1} className="bos">Satir yok</td></tr>
          )}
        </tbody>
      </table>
    </div>
  );
}
