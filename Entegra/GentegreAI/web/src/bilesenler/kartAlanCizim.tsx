import { TelefonGirdi } from './TelefonGirdi';
import { telefonAlaniMi, epostaGecerliMi } from './alanBicim';
import type { KartAlanMeta, KartMetaYaniti, DovizMetasi } from '../api/sozlesme';

/** Kart alanlarinda tutulan deger tipleri. */
export type Deger = string | number | boolean | null;

// "epostaWeb"/"aliasEposta" DAHIL DEGIL - role gore URL/GIB-URN-alias de tutabiliyor
// (taraf.eposta_web/alias_eposta yorumlari), sadece duz "eposta" alani her zaman e-posta.
export const EPOSTA_ALANLARI = new Set(['eposta']);

/**
 * Alan cizimi - GenForm'un icinden cikarildi.
 *
 * Uc islev (girdi / etiketli alan / alan listesi) ayni baglami paylasiyor:
 * deger sozlugu, salt-okunurluk, doviz ucgeni, alan hatalari. Fabrika bu baglami
 * bir kez alir, GenForm da eskisi gibi `renderAlan(a)` diye cagirir - JSX
 * degismedi, yalnizca 160 satir kart govdesinden ayrildi.
 */
export interface AlanCizimBaglami {
  kaynak: string;
  salt: boolean;
  meta: KartMetaYaniti | null;
  deger: Record<string, Deger>;
  setDeger: React.Dispatch<React.SetStateAction<Record<string, Deger>>>;
  alanDegistir(ad: string, deger: Deger): void;
  alanHatalari: Record<string, string>;
  setAlanHatalari: React.Dispatch<React.SetStateAction<Record<string, string>>>;
  /** Kart doviz ucgeni (varsa): yerel karsilik alani salt okunur cizilir. */
  doviz: DovizMetasi | null | undefined;
  yerelTutar: number;
  kurNotu: string | null;
  /** Kisi karti "Cariye Bagla": secilen tarafin adi (lookup bilmiyor). */
  bagliTarafAdi: string | null;
  setBagliTarafAdi: React.Dispatch<React.SetStateAction<string | null>>;
}

export function alanCizici(b: AlanCizimBaglami) {
  const { kaynak, salt, meta, deger, setDeger, alanDegistir,
          alanHatalari, setAlanHatalari, doviz, yerelTutar, kurNotu,
          bagliTarafAdi, setBagliTarafAdi } = b;

    /** Sekme icinde mockup'taki gibi alt-bolumler (or. Genel -> Tanım/Sınıflandırma). */
    const altGruplaVar = (alanlar: KartAlanMeta[]) => {
      const harita = new Map<string, KartAlanMeta[]>();
      alanlar.forEach(a => {
        const g = a.altGrup ?? '';
        harita.set(g, [...(harita.get(g) ?? []), a]);
      });
      return [...harita.entries()];
    };

    const renderGirdi = (a: KartAlanMeta) => (
      a.tip === 'mantik' ? (
        <input
          key={a.ad}
          type="checkbox"
          checked={Boolean(deger[a.ad])}
          disabled={salt || !a.yazilabilir}
          onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.checked }))}
        />
      ) : kaynak === 'kisi' && a.ad === 'bagId' ? (
        // "Cariye Bağla" butonu + TarafArama modaliyla degistiriliyor - burada duz salt-okunur
        // gorunum (kullanici: "bagli cari readonly edit olsun"). Yazilabilir hala TRUE (kaydet
        // payload'una girsin), sadece render FARKLI - select degil, disabled text input.
        <div key={a.ad} className="tel-girdi">
          <input
            readOnly
            disabled
            value={bagliTarafAdi ?? (a.kodlar && a.kodlar[String(deger[a.ad] ?? '')]) ?? ''}
            placeholder="Bağlanmadı"
          />
          {!salt && deger[a.ad] && (
            <button type="button" className="mini" title="Boşalt"
              onClick={() => { setDeger(d => ({ ...d, [a.ad]: '' })); setBagliTarafAdi(null) }}>
              ×
            </button>
          )}
        </div>
      ) : doviz && a.ad === doviz.yerelAlani ? (
        // Yerel karsilik: HESAPLANIR, yazilamaz (sunucu da ayni carpimi yapar).
        <input
          key={a.ad}
          readOnly
          disabled
          value={yerelTutar.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
                 + ' ' + doviz.yerelPara}
        />
      ) : a.kodlar ? (() => {
        // BAGLI liste (Şube -> Banka): yalniz secili ust'un altindakiler.
        const ustDegeri = a.bagliAlan ? String(deger[a.bagliAlan] ?? '') : '';
        const secenekler = Object.entries(a.kodlar).filter(
          ([k]) => !a.bagliAlan || (a.kodUst?.[k] ?? '') === ustDegeri);
        const ustBos = Boolean(a.bagliAlan) && ustDegeri === '';
        return (
          <select
            key={a.ad}
            value={String(deger[a.ad] ?? '')}
            disabled={salt || !a.yazilabilir || ustBos}
            onChange={e => alanDegistir(a.ad, e.target.value)}
          >
            {/* Bos secenek yalniz ZORUNLU OLMAYAN alanlarda: zorunlu bir kod alaninda
                (ör. Depo > Durum) "—" secilebilir gorunmesi yaniltici. */}
            {!a.zorunlu && (
              <option value="">
                {/* Bagli listede bos secenek NEDEN bos oldugunu soylesin: kullanici
                    "sube gelmedi" diye ariyordu - once banka secilmesi ya da o
                    bankaya hic sube girilmemis olmasi bilgisi ekranda yok. */}
                {ustBos ? `— önce ${meta?.alanlar.find(x => x.ad === a.bagliAlan)?.baslik ?? 'üst'} seçin`
                  : a.bagliAlan && secenekler.length === 0 ? '— tanımlı kayıt yok'
                  : '—'}
              </option>
            )}
            {secenekler.map(([k, v]) => <option key={k} value={k}>{v}</option>)}
          </select>
        );
      })() : telefonAlaniMi(a.ad) ? (
        <TelefonGirdi
          key={a.ad}
          value={String(deger[a.ad] ?? '')}
          disabled={salt || !a.yazilabilir}
          onChange={v => setDeger(d => ({ ...d, [a.ad]: v }))}
        />
      ) : (
        <input
          key={a.ad}
          // Tarih alani TAKVIM kutusu olur; deger ham ISO gelir ("2026-08-24T00:00:00")
          //   ve type=date bunu GOSTEREMEZ - 10 karaktere kirpilir. Eskiden duz metin
          //   kutusuydu ve kullanici ISO damgasini goruyordu.
          type={a.tip === 'tarih' ? 'date' : EPOSTA_ALANLARI.has(a.ad) ? 'email' : 'text'}
          value={a.tip === 'tarih' ? String(deger[a.ad] ?? '').slice(0, 10)
                                   : String(deger[a.ad] ?? '')}
          maxLength={a.enFazlaUzunluk ?? undefined}
          disabled={salt || !a.yazilabilir}
          onChange={e => setDeger(d => ({ ...d, [a.ad]: e.target.value }))}
          onBlur={e => {
            if (EPOSTA_ALANLARI.has(a.ad)) {
              const gecerli = epostaGecerliMi(e.target.value);
              setAlanHatalari(h => {
                if (gecerli) { const { [a.ad]: _cikar, ...kalan } = h; return kalan }
                return { ...h, [a.ad]: 'Gecerli bir e-posta adresi girin.' };
              });
            }
          }}
        />
      )
    );

    const renderAlan = (a: KartAlanMeta) => (
      <label key={a.ad} className={`alan tip-${a.tip}`}>
        <span className="etiket">
          {a.baslik}{a.zorunlu && <b className="zorunlu"> *</b>}
        </span>
        {renderGirdi(a)}
        {/* Kur kutusunun altinda kurun NEREDEN geldigi (tarih kuru / bulunamadi) -
            otomatik gelen bir sayiyi kullanicinin sorgusuz kabul etmesi beklenmez. */}
        {doviz && a.ad === doviz.kurAlani && kurNotu && (
          <span className="alan-notu">{kurNotu}</span>
        )}
        {alanHatalari[a.ad] && <span className="alan-hata">{alanHatalari[a.ad]}</span>}
      </label>
    );

    /**
     * Mockup'taki ".ikili" (or. Raf Ömrü: sayi + birim combo TEK etiket altinda yan yana).
     * `eslesAlan` ile baska bir alani gosteren alan, o alani kendi satirina EKLER; hedef alan
     * ayri satir olarak TEKRAR RENDER EDILMEZ.
     */
    const renderAlanListesi = (alanlar: KartAlanMeta[]) => {
      const eslesenler = new Set(alanlar.map(a => a.eslesAlan).filter(Boolean));
      return alanlar
        .filter(a => !eslesenler.has(a.ad))
        .map(a => {
          const hedef = a.eslesAlan ? alanlar.find(x => x.ad === a.eslesAlan) : undefined;
          if (!hedef) return renderAlan(a);
          // IKI CHECK yan yana: her kutu KENDI adini tasir. Tek etiket altinda
          //   iki kutu ciziliyordu ve hangisinin hangi ad oldugu belirsizdi
          //   (kullanici: "Paket check te Paket label yok").
          if (a.tip === 'mantik' && hedef.tip === 'mantik')
            return (
              <div key={a.ad} className="alan ikili-mantik">
                <label className="alan tip-mantik">
                  {renderGirdi(a)}<span className="etiket">{a.baslik}</span>
                </label>
                <label className="alan tip-mantik">
                  {renderGirdi(hedef)}<span className="etiket">{hedef.baslik}</span>
                </label>
              </div>
            );
          return (
            <label key={a.ad} className={`alan tip-${a.tip}`}>
              <span className="etiket">
                {a.baslik}{a.zorunlu && <b className="zorunlu"> *</b>}
              </span>
              <div className="ikili">{renderGirdi(a)}{renderGirdi(hedef)}</div>
              {(alanHatalari[a.ad] || alanHatalari[hedef.ad]) && (
                <span className="alan-hata">{alanHatalari[a.ad] || alanHatalari[hedef.ad]}</span>
              )}
            </label>
          );
        });
    };

  return { altGruplaVar, renderGirdi, renderAlan, renderAlanListesi };
}
