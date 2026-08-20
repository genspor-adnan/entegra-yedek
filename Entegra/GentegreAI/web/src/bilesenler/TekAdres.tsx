import type { DetayDurumu } from './GenDetayTablo';
import type { KartDetayMeta } from '../api/sozlesme';
import { useYerler, VARSAYILAN_ULKE } from './yerlerHook';

interface Props {
  meta: KartDetayMeta;
  durum: DetayDurumu;
  saltOkunur: boolean;
  onDegis(yeni: DetayDurumu): void;
}

/**
 * kisi_karti.html mockup'taki "Adres" kutusu — GRID DEGIL, TEK adres (kullanici acikca
 * "grid olmasin tek adres" dedi). Ayni taraf_adres tablosuna baglanir (Cari'nin Adresler
 * grid'iyle AYNI DetayDurumu/detayFarki mekanizmasi), sadece UI'da tek satir gosterilir:
 * durum.guncel[0] okunur/yazilir, +Satir / satir sil YOK.
 */
export function TekAdres({ meta, durum, saltOkunur, onDegis }: Props) {
  const yerler = useYerler(true);
  const ilAdIdHarita = new Map((yerler?.iller ?? []).map(i => [i.ad, i.id]));
  const satir = durum.guncel[0] ?? {};

  const degis = (degisiklik: Record<string, unknown>) => {
    const yeniSatir = { ...satir, ...degisiklik };
    const guncel = durum.guncel.length ? [yeniSatir, ...durum.guncel.slice(1)] : [yeniSatir];
    onDegis({ ...durum, guncel });
  };

  const turAlan = meta.alanlar.find(a => a.ad === 'tur');

  return (
    <div className="kagrup">
      <h6>Adres</h6>
      <div className="alan-izgara tek-sutun">
        {/* Adres Tipi combosu Il ile AYNI genislikte olsun diye Il/Ilce ile ayni iki-kolonlu
            satir duzeninde (kullanici) - ikinci kolon bos birakiliyor. */}
        <div className="adres-satir">
          <label className="alan tip-kod">
            <span className="etiket">Adres Tipi</span>
            <select value={String(satir.tur ?? '')} disabled={saltOkunur}
              onChange={e => degis({ tur: e.target.value })}>
              <option value="">—</option>
              {turAlan?.kodlar && Object.entries(turAlan.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
            </select>
          </label>
          <div className="alan" aria-hidden="true" />
        </div>
        <label className="alan tip-metin">
          <span className="etiket">Adres</span>
          <input value={String(satir.adres ?? '')} disabled={saltOkunur}
            onChange={e => degis({ adres: e.target.value })} />
        </label>
        <div className="adres-satir">
          <label className="alan tip-kod">
            <span className="etiket">İl</span>
            <select value={String(satir.il ?? '')} disabled={saltOkunur}
              onChange={e => degis({ il: e.target.value, ilce: '' })}>
              <option value="">—</option>
              {(yerler?.iller ?? []).map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
            </select>
          </label>
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
        </div>
        <div className="adres-satir">
          <label className="alan tip-metin">
            <span className="etiket">Posta Kodu</span>
            <input value={String(satir.postaKodu ?? '')} disabled={saltOkunur}
              onChange={e => degis({ postaKodu: e.target.value })} />
          </label>
          <label className="alan tip-kod">
            <span className="etiket">Ülke</span>
            <select value={String(satir.ulke ?? VARSAYILAN_ULKE)} disabled={saltOkunur}
              onChange={e => degis({ ulke: e.target.value })}>
              {(yerler?.ulkeler ?? []).map(y => <option key={y.id} value={y.ad}>{y.ad}</option>)}
            </select>
          </label>
        </div>
      </div>
    </div>
  );
}
