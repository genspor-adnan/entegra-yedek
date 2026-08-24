import type { DetayDurumu, Satir } from './GenDetayTablo';
import type { KartDetayMeta } from '../api/sozlesme';
import { useYerler, VARSAYILAN_ULKE } from './yerlerHook';

interface Props {
  meta: KartDetayMeta;
  durum: DetayDurumu;
  saltOkunur: boolean;
  onDegis(yeni: DetayDurumu): void;
  /** Personel'de mockup basligi "Ev Adresi"; kisi kartinda varsayilan "Adres". */
  baslik?: string;
  /** Personel Ev Adresi'nde tip gorunmez ama arka planda sabit yazilir. */
  turGizli?: boolean;
  sabitTur?: string;
  grupYok?: boolean;
  /** Ulke satirini hic cizme (ör. Aday karti - yurt ici varsayilani yeterli). */
  ulkeGizli?: boolean;
  ilIlceAyniSatir?: boolean;
  baslikGizli?: boolean;
}

/**
 * Kisi/personel kartinda tek adres formu. Ayni taraf_adres detayini kullanir,
 * sadece UI'da tek satir gosterir; ekle/sil butonu yoktur.
 */
export function TekAdres({
  meta,
  durum,
  saltOkunur,
  onDegis,
  baslik = 'Adres',
  turGizli = false,
  sabitTur,
  grupYok = false,
  ulkeGizli = false,
  ilIlceAyniSatir = false,
  baslikGizli = false,
}: Props) {
  const yerler = useYerler(true);
  const ilAdIdHarita = new Map((yerler?.iller ?? []).map(i => [i.ad, i.id]));
  const satir: Satir = {
    ulke: VARSAYILAN_ULKE,
    ...(durum.guncel[0] ?? {}),
    ...(sabitTur ? { tur: sabitTur } : {}),
  };

  const degis = (degisiklik: Record<string, unknown>) => {
    const yeniSatir = { ...satir, ...degisiklik, ...(sabitTur ? { tur: sabitTur } : {}) };
    const guncel = durum.guncel.length ? [yeniSatir, ...durum.guncel.slice(1)] : [yeniSatir];
    onDegis({ ...durum, guncel });
  };

  const turAlan = meta.alanlar.find(a => a.ad === 'tur');
  const ilSecimi = (
    <label className="alan tip-kod">
      <span className="etiket">İl</span>
      <select value={String(satir.il ?? '')} disabled={saltOkunur}
        onChange={e => degis({ il: e.target.value, ilce: '' })}>
        <option value="">—</option>
        {(yerler?.iller ?? []).map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
      </select>
    </label>
  );
  const ilceSecimi = (
    <label className="alan tip-kod">
      <span className="etiket">İlçe</span>
      <select value={String(satir.ilce ?? '')} disabled={saltOkunur || !satir.il}
        onChange={e => degis({ ilce: e.target.value })}>
        <option value="">—</option>
        {(yerler?.ilceler ?? [])
          .filter(y => y.ilId === ilAdIdHarita.get(String(satir.il ?? '')))
          .map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
      </select>
    </label>
  );

  const icerik = (
    <div className="alan-izgara tek-sutun">
      {grupYok && !baslikGizli && <div className="adres-alt-baslik">{baslik}</div>}
        {!turGizli && (
          <div className="adres-satir">
            <label className="alan tip-kod">
              <span className="etiket">Adres Tipi</span>
              <select value={String(satir.tur ?? '')} disabled={saltOkunur}
                onChange={e => degis({ tur: e.target.value })}>
                <option value="">—</option>
                {turAlan?.kodlar && Object.entries(turAlan.kodlar).map(([k, v]) => (
                  <option key={k} value={k}>{v}</option>
                ))}
              </select>
            </label>
            <div className="alan" aria-hidden="true" />
          </div>
        )}

        <label className="alan tip-metin">
          <span className="etiket">Adres</span>
          <input value={String(satir.adres ?? '')} disabled={saltOkunur}
            onChange={e => degis({ adres: e.target.value })} />
        </label>

        {turGizli && !ilIlceAyniSatir ? (
          <>
            {ilSecimi}
            {ilceSecimi}
          </>
        ) : (
          <div className="adres-satir">
            {ilSecimi}
            {ilceSecimi}
          </div>
        )}

        {/* POSTA KODU sorulmaz (kullanici): kolon duruyor, gocmus degerler
            korunuyor - yalniz formda yer kaplamiyordu. */}
        {!ulkeGizli && (
        <div className="adres-satir">
          <label className="alan tip-kod">
            <span className="etiket">Ülke</span>
            <select value={String(satir.ulke ?? VARSAYILAN_ULKE)} disabled={saltOkunur}
              onChange={e => degis({ ulke: e.target.value })}>
              {(yerler?.ulkeler ?? []).map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
            </select>
          </label>
        </div>
        )}
      </div>
  );

  if (grupYok) return icerik;

  return (
    <div className="kagrup">
      {!baslikGizli && <h6>{baslik}</h6>}
      {icerik}
    </div>
  );
}
