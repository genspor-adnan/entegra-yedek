import { Fragment } from 'react';
import type React from 'react';
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
  /** Yalnizca bu alanlar, VERILEN SIRAYLA cizilir (or. anamnez panelindeki
      vital izgarasi: tansiyon, nabiz, SpO2, ates...). Verilmezse katalogtaki
      butun alanlar cizilir. */
  alanSirasi?: string[];
  /** Karsilikli dislanan onay kutulari: anahtar alan ISARETLENINCE listedeki
      alanlar kaldirilir (or. ÜTS canli/test secimi radyo gibi davranir). */
  dislar?: Record<string, string[]>;
  /** Kutularin USTUNDE, tek basina cizilecek alanlar (or. ÜTS "Baz Alınacak
      Şube" - iki cercevenin ikisini de yonettigi icin birinin icinde durmasin). */
  ustAlanlar?: string[];
  /**
   * JENERIK ARAMA (305): aramaKaynagi tanimli alan combo yerine "secili ad + …"
   * kutusu olur; tiklayinca cagiran arama modalini acar. Combo, binlerce
   * kayitli listelerde (cari) kullanilmaz hale geliyor.
   */
  aramaAc?(alan: string, kaynak: string, uygula?: (deger: string) => void): void;
  /** Secili kaydin ADI - id'den cozulen gosterim metni. */
  secilenAdlar?: Record<string, string>;

  /**
   * Kutunun ICINE, detay alanlarindan ONCE cizilecek KART alanlari (309).
   * Dis hekimde kurum bagi taraf.bag_id'de - detay tablosunda olmadigi icin
   * TekKayit onu kendisi cizemez, ama gorsel olarak ayni kutuda durmali.
   */
  ekAlanlar?: React.ReactNode;
  /** ekAlanlar KACINCI alandan once cizilsin (0 = en uste). Dis hekimde 1:
      kullanici kurumu bransin ALTINDA istiyor. */
  ekAlanlarSira?: number;
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
export function TekKayit({ meta, durum, saltOkunur, onDegis, baslik, not, gruplar,
                           alanSirasi, dislar, ustAlanlar, aramaAc, secilenAdlar,
                           ekAlanlar, ekAlanlarSira }: Props) {
  const satir: Satir = durum.guncel[0] ?? {};

  const degis = (ad: string, deger: unknown) => {
    const yeniSatir = { ...satir, [ad]: deger };
    // Karsilikli dislama: kutu ISARETLENIRKEN karsitlari kalkar (kaldirirken
    //   dokunulmaz - ikisi de bos kalabilir).
    if (deger === true && dislar?.[ad])
      for (const karsit of dislar[ad]) yeniSatir[karsit] = false;
    const guncel = durum.guncel.length ? [yeniSatir, ...durum.guncel.slice(1)] : [yeniSatir];
    onDegis({ ...durum, guncel });
  };

  /**
   * Arama modalini acar ve secimi KENDI satirimiza yazdirir. Uygula'yi
   * gondermezsek cagiran (GenForm) secimi kartin alanina yazar - burada
   * gorunur ama kaydedilmez.
   */
  const ara = (a: KartAlanMeta) =>
    aramaAc?.(a.ad, a.aramaKaynagi!, deger => degis(a.ad, deger));

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
    // ARAMA ALANI: deger id'dir; ekranda secili kaydin adi gorunur.
    if (a.aramaKaynagi && aramaAc)
      return (
        <span className="ikili">
          <input readOnly value={String(deger ?? '') === '' ? ''
                                 : (secilenAdlar?.[a.ad]
                                    ?? a.kodlar?.[String(deger ?? '')] ?? '')}
                 placeholder="Seçiniz…"
                 disabled={saltOkunur || !a.yazilabilir}
                 onClick={() => !saltOkunur && a.yazilabilir && ara(a)} />
          <button type="button" className="d mini" title="Ara"
                  disabled={saltOkunur || !a.yazilabilir}
                  onClick={() => ara(a)}>…</button>
          {String(deger ?? '') !== '' && (
            <button type="button" className="d mini" title="Seçimi kaldır"
                    disabled={saltOkunur || !a.yazilabilir}
                    onClick={() => degis(a.ad, '')}>✕</button>
          )}
        </span>
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

  const tumAlanlar = meta.alanlar.filter(a => a.ad !== 'id' && !a.gizli);
  // ESLESEN ALAN (mockup ".ikili"): "Tansiyon" tek etiket altinda sistolik +
  //   diyastolik, "Boy / Kilo" tek etiket altinda iki kutu. Eslesen alan
  //   kendi satirini ALMAZ.
  const eslesenAdlar = new Set(tumAlanlar.map(a => a.eslesAlan).filter(Boolean));

  const alanCiz = (a: KartAlanMeta) => {
    const hedef = a.eslesAlan ? tumAlanlar.find(x => x.ad === a.eslesAlan) : undefined;
    return (
      <label key={a.ad} className={`alan tip-${a.tip}${hedef ? ' ikili' : ''}`}>
        <span className="etiket">{a.baslik}</span>
        {girdi(a)}
        {hedef && girdi(hedef)}
      </label>
    );
  };

  const alanlar = (alanSirasi?.length
    ? alanSirasi.map(ad => tumAlanlar.find(a => a.ad === ad))
        .filter((a): a is KartAlanMeta => !!a)
    : tumAlanlar
  ).filter(a => !eslesenAdlar.has(a.ad));

  if (gruplar?.length) {
    const bul = new Map(alanlar.map(a => [a.ad, a]));
    return (
      <>
        {/* Ust alanlar: kutularin uzerinde tek basina (or. baz sube secimi). */}
        {ustAlanlar && ustAlanlar.length > 0 && (
          <div className="alan-izgara dort-sutun" style={{ marginBottom: 8 }}>
            {ustAlanlar.map(ad => bul.get(ad)).filter((a): a is KartAlanMeta => !!a)
              .map(a => (
                <label key={a.ad} className={`alan tip-${a.tip}`}>
                  {/* Etiket TEK SATIR (kullanici): dar etiket kolonu
                      "Baz Alınacak Şube"yi ikiye kiriyordu. */}
                  <span className="etiket" style={{ whiteSpace: 'nowrap' }}>
                    {a.baslik}
                  </span>
                  {girdi(a)}
                </label>
              ))}
          </div>
        )}
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
      </>
    );
  }

  // Kart alanlari (ekAlanlar) detay alanlarinin ARASINA girer - ayri bir blok
  //   olarak ustte/altta durmasi kutuyu ikiye bolmus gibi gorunuyordu.
  const cizimler = alanlar.map(alanCiz);
  if (ekAlanlar)
    cizimler.splice(Math.min(ekAlanlarSira ?? 0, cizimler.length), 0,
                    <Fragment key="_ek">{ekAlanlar}</Fragment>);

  return (
    <div className="kasira">
      <div className="kagrup">
        <h6>{baslik ?? meta.baslik}</h6>
        <div className="alan-izgara tek-sutun">
          {cizimler}
        </div>
        {not && <div className="not">{not}</div>}
      </div>
    </div>
  );
}
