import { TelefonGirdi } from './TelefonGirdi';
import { telefonAlaniMi } from './alanBicim';
import type { DetayDurumu, Satir } from './GenDetayTablo';
import type { KartAlanMeta, KartDetayMeta } from '../api/sozlesme';

interface Props {
  meta: KartDetayMeta;
  durum: DetayDurumu;
  saltOkunur: boolean;
  onDegis(yeni: DetayDurumu): void;
  /** Kutu basligi; verilmezse detayin kendi basligi. */
  baslik?: string;
  /** Kutunun altinda aciklama satiri. */
  not?: React.ReactNode;
  /** Verilirse alanlar TEK kutu yerine YAN YANA kutulara bolunur (or. sube
      ÜTS: solda canli hesap, sagda test hesabi). Listede olmayan alan
      cizilmez; not SON kutunun altina gider. */
  gruplar?: { baslik: string; alanlar: string[] }[];
}

/**
 * 1:1 UZANTI SEKMESI — grid degil TEK KAYIT formu.
 *
 * Bir stokun bir ÜTS kaydi, bir personelin bir ozluk kaydi vardir; bunlari
 * "satir ekle / sil"li bir tabloda gostermek yanlis bir vaat (ikinci satir
 * eklenemez). Alanlar KATALOGTAN gelir - burada alan listesi yoktur, sunucu
 * neyi gonderiyorsa o cizilir (TekOzluk'un aksine: o personele ozel elle
 * yazilmis bir formdur).
 *
 * Kayit satiri yoksa BOS bir satir uzerinde calisilir; kullanici bir alani
 * doldurup Kaydet derse detay farkinda "eklenen" olarak gider.
 */
export function TekKayit({ meta, durum, saltOkunur, onDegis, baslik, not, gruplar }: Props) {
  const satir: Satir = durum.guncel[0] ?? {};

  const degis = (ad: string, deger: unknown) => {
    const yeniSatir = { ...satir, [ad]: deger };
    const guncel = durum.guncel.length ? [yeniSatir, ...durum.guncel.slice(1)] : [yeniSatir];
    onDegis({ ...durum, guncel });
  };

  const girdi = (a: KartAlanMeta) => {
    const deger = satir[a.ad];
    // Telefon her yerde ayni kutu: ulke kodu + gruplu numara (genel kural).
    if (telefonAlaniMi(a.ad))
      return (
        <TelefonGirdi
          value={String(deger ?? '')}
          disabled={saltOkunur || !a.yazilabilir}
          onChange={v => degis(a.ad, v)}
        />
      );
    if (a.tip === 'mantik')
      return (
        <input type="checkbox" checked={Number(deger) === 1 || deger === true}
               disabled={saltOkunur || !a.yazilabilir}
               onChange={e => degis(a.ad, e.target.checked)} />
      );
    if (a.kodlar)
      return (
        <select value={String(deger ?? '')} disabled={saltOkunur || !a.yazilabilir}
                onChange={e => degis(a.ad, e.target.value)}>
          <option value="">—</option>
          {Object.entries(a.kodlar).map(([k, v]) => <option key={k} value={k}>{v}</option>)}
        </select>
      );
    return (
      <input
        type={a.tip === 'tarih' ? 'date' : 'text'}
        value={a.tip === 'tarih' ? String(deger ?? '').slice(0, 10) : String(deger ?? '')}
        maxLength={a.enFazlaUzunluk ?? undefined}
        disabled={saltOkunur || !a.yazilabilir}
        onChange={e => degis(a.ad, e.target.value)} />
    );
  };

  const alanCiz = (a: KartAlanMeta) => (
    <label key={a.ad} className={`alan tip-${a.tip}`}>
      <span className="etiket">{a.baslik}</span>
      {girdi(a)}
    </label>
  );
  const alanlar = meta.alanlar.filter(a => a.ad !== 'id' && !a.gizli);

  if (gruplar?.length) {
    const bul = new Map(alanlar.map(a => [a.ad, a]));
    return (
      <div className="kasira">
        {gruplar.map((g, i) => (
          <div key={g.baslik} className="kagrup">
            <h6>{g.baslik}</h6>
            <div className="alan-izgara tek-sutun">
              {g.alanlar.map(ad => bul.get(ad)).filter((a): a is KartAlanMeta => !!a)
                .map(alanCiz)}
            </div>
            {not && i === gruplar.length - 1 && <div className="not">{not}</div>}
          </div>
        ))}
      </div>
    );
  }

  return (
    <div className="kasira">
      <div className="kagrup">
        <h6>{baslik ?? meta.baslik}</h6>
        <div className="alan-izgara tek-sutun">
          {alanlar.map(alanCiz)}
        </div>
        {not && <div className="not">{not}</div>}
      </div>
    </div>
  );
}
