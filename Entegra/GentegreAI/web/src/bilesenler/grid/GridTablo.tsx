import { Fragment } from 'react';
import { c } from '../../dil/ceviri';
import { bicimle } from '../bicim';
import { durumRozeti, ikonHucre, rozetHucre, yuzdeRozeti } from '../gridHucre';
import { agacAdi } from './agacDizim';
import type { KolonMeta, ListeSatiri, ListeYaniti } from '../../api/sozlesme';

/**
 * GRID TABLOSU - baslik satiri (siralama + kolon filtresi), veri satirlari,
 * grup ara toplamlari ve alt toplam seridi.
 *
 * Yalniz CIZIM: veri cekme, sayfalama ve secim mantigi GenGrid'de kalir; burasi
 * gelen satirlari mockup duzenine gore basar.
 */
export function GridTablo(p: GridTabloProps) {
  const {
    bosEk,
    kolonlar, satirlar, yukleniyor, gruplar, grupKolonu, gorunenToplamlar, satirBoyu,
    toplamSeridiVar, sayfa, sonSayfa, secili, sayfaIdleri, secimiUygula,
    satirSecimiDegistir, hepsiSecili, hepsiRef, satirTiklandi, satirTiklaninca,
    satirSinifi, setSeciliSatir, setSagTusKonumu, siraIsareti, siralamaDegistir,
    filtreAcik, filtreSatiriDegisti, gridMenuKonum, setGridMenuKonum, aksiyonEkrani,
    agacAlani, agacDegistir,
  } = p;
  return (
<table className={`grid boy-${satirBoyu ?? 'normal'}`}>
  <colgroup>
    <col style={{ width: 34 }} />
    {kolonlar.map(k => <col key={k.ad} style={k.genislik ? { width: k.genislik } : undefined} />)}
  </colgroup>
  <thead>
    <tr>
      <th className="cbk">
        <input
          ref={hepsiRef}
          type="checkbox"
          className="grid-cb"
          checked={hepsiSecili}
          onChange={() => secimiUygula(hepsiSecili ? new Set() : new Set(sayfaIdleri()))}
          title="Bu sayfadaki tumunu sec"
        />
        <button
          type="button"
          className={`grid-noktalar${gridMenuKonum ? ' on' : ''}`}
          title="Grid menusu"
          onClick={e => {
            e.stopPropagation();
            const r = e.currentTarget.getBoundingClientRect();
            setGridMenuKonum(gridMenuKonum ? null : { x: r.left, y: r.bottom + 4 });
          }}
        >
          ⋮
        </button>
      </th>
      {kolonlar.map(k => (
        <th
          key={k.ad}
          className={`hiza-${k.hizalama} ${k.siralanabilir ? 'siralanir' : ''}`}
          onClick={() => siralamaDegistir(k)}
        >
          {c(k.baslik)}{siraIsareti(k.ad)}
        </th>
      ))}
    </tr>
    {filtreAcik && (
      <tr className="flt">
        <th className="cbk" />
        {kolonlar.map(k => (
          <th key={k.ad}>
            {(k.tip === 'metin' || k.tip === 'kod') && k.filtrelenebilir && (
              <input
                placeholder="icerir…"
                onChange={e => filtreSatiriDegisti(k.ad, e.target.value)}
              />
            )}
          </th>
        ))}
      </tr>
    )}
  </thead>
  <tbody>
    {satirlar.map((satir, i) => {
      const id = String(satir.id ?? i);
      // ---- GRUPLU LISTE (ekstre: para birimi basina) ----------
      //   Grup basligi obegin ilk satirindan ONCE, ara toplam SON
      //   satirindan SONRA. Obek sayfa sonunda BOLUNDUYSE ara toplam
      //   yazilmaz - yarim toplam gostermek yaniltir; obek bitince
      //   (sonraki sayfada) yazilir.
      const grupDeger = grupKolonu ? String(satir[grupKolonu] ?? '') : null;
      const oncekiGrup = i > 0 && grupKolonu
        ? String(satirlar[i - 1][grupKolonu] ?? '') : null;
      const sonrakiGrup = i + 1 < satirlar.length && grupKolonu
        ? String(satirlar[i + 1][grupKolonu] ?? '') : null;
      const grupBasliyor = grupDeger !== null && (i === 0 || oncekiGrup !== grupDeger);
      const grupBitiyor = grupDeger !== null &&
        (sonrakiGrup !== null ? sonrakiGrup !== grupDeger : sayfa >= sonSayfa);
      const ozet = grupDeger !== null
        ? gruplar?.find(g => g.anahtar === grupDeger) : undefined;

      return (
        <Fragment key={`gr-${id}`}>
        {grupBasliyor && (
          <tr className="grup-bas">
            <td className="cbk" />
            <td colSpan={kolonlar.length}>
              <b>{grupDeger || '—'}</b>
              {ozet && <span className="sonuk"> · {ozet.adet} hareket</span>}
              {oncekiGrup !== null && oncekiGrup !== grupDeger && ''}
            </td>
          </tr>
        )}
        <tr
          key={id}
          className={satirSinifi(satir)}
          onMouseDown={e => { if (e.shiftKey) e.preventDefault() }}
          onClick={e => satirTiklandi(e, id, i)}
          onDoubleClick={() => satirTiklaninca(satir)}
          onContextMenu={e => {
            if (!aksiyonEkrani) return;
            e.preventDefault();
            setSeciliSatir(satir);
            setSagTusKonumu({ x: e.clientX, y: e.clientY });
          }}
        >
          <td className="cbk">
            <input
              type="checkbox"
              className="grid-cb"
              checked={secili.has(id)}
              onClick={e => e.stopPropagation()}
              onChange={() => satirSecimiDegistir(id, i)}
            />
          </td>
          {kolonlar.map((k, ki) => {
            // AGAC SUTUNU: ilk kolon girintiyi ve +/- dugmesini tasir.
            //   Dugme ayri bir sutun DEGIL - kolon duzeni her listede ayni
            //   kalsin, agac yalniz bu hucrenin icinde yasasin.
            const agacHucresi = !!agacAlani && ki === 0;
            const derinlik = Number(satir.__derinlik ?? 0);
            return (
            <td key={k.ad} className={`hiza-${k.hizalama}`}
              style={k.genislik ? {
                maxWidth: k.genislik, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap',
              } : undefined}
              title={k.genislik ? String(satir[k.ad] ?? '') : undefined}
            >
              {agacHucresi ? (
                <span className="agac-hucre"
                      style={{ paddingLeft: derinlik * 16 }}>
                  {satir.__cocukVar ? (
                    <button type="button" className="agac-dugme"
                            title={satir.__acik ? 'Kapat' : 'Aç'}
                            onClick={e => { e.stopPropagation(); agacDegistir?.(id) }}>
                      {satir.__acik ? '−' : '+'}
                    </button>
                  ) : <span className="agac-bosluk" />}
                  {agacAdi(satir[k.ad])}
                </span>
              ) : (
                ikonHucre(satir[k.ad], k) ?? yuzdeRozeti(satir[k.ad], k)
                  ?? rozetHucre(satir[k.ad], k)
                  ?? durumRozeti(satir[k.ad], k) ?? bicimle(satir[k.ad], k)
              )}
            </td>
            );
          })}
        </tr>
        {grupBitiyor && ozet && (
          <tr className="grup-toplam">
            <td className="cbk" />
            {kolonlar.map((k, ki) => {
              const t = ozet.toplamlar?.[k.ad];
              return (
                <td key={k.ad} className={`hiza-${k.hizalama}`}>
                  {t !== undefined && t !== null ? bicimle(t, k)
                    : ki === 0 ? `${grupDeger} toplamı` : ''}
                </td>
              );
            })}
          </tr>
        )}
        </Fragment>
      );
    })}
    {!yukleniyor && satirlar.length === 0 && (
      <tr><td colSpan={kolonlar.length + 1} className="bos">
        Kayıt yok
        {/* BOS LISTE SEBEBINI SOYLESIN (kullanici: "başvuru kayıtları
            listelenmedi"): basvuru listesi varsayilan olarak BUGUNU gosterir;
            o gun kayit yoksa ekran "liste bozuk" gibi duruyordu. Ekran sahibi
            buraya sebebi ve tek tikla cikis yolunu koyar. */}
        {bosEk}
      </td></tr>
    )}
  </tbody>
  {toplamSeridiVar && (
    <tfoot>
      <tr>
        <td className="cbk" />
        {kolonlar.map((k, i) => {
          const t = gorunenToplamlar.find(([ad]) => ad === k.ad);
          return (
            <td key={k.ad} className={`hiza-${k.hizalama}`}>
              {t ? bicimle(t[1], k)
                 : (i === 0 ? (grupKolonu ? c('GENEL TOPLAM') : c('Toplam')) : '')}
            </td>
          );
        })}
      </tr>
    </tfoot>
  )}
</table>
  );
}

export interface GridTabloProps {
  /** Bos listede "Kayıt yok"un altina eklenecek aciklama/dugme. */
  bosEk?: React.ReactNode;
  kolonlar: KolonMeta[];
  satirlar: ListeSatiri[];
  yukleniyor: boolean;
  /** Sunucudan gelen grup ozetleri (grupli listelerde ara toplam satirlari). */
  gruplar: ListeYaniti['gruplar'];
  grupKolonu: string | null;
  /** Satir yuksekligi tercihi (uc nokta menusu) - tabloya sinif olarak gecer. */
  satirBoyu?: 'sik' | 'normal' | 'genis';
  /** Alt toplam seridi: gorunen toplam degerleri ve seridin cizilip cizilmeyecegi. */
  /** [kolon adi, deger] ciftleri - alt toplam seridi. */
  gorunenToplamlar: [string, unknown][];
  toplamSeridiVar: boolean;
  sayfa: number;
  sonSayfa: number;
  /** Satir secimi (coklu isaretleme). */
  secili: Set<string>;
  sayfaIdleri(): string[];
  secimiUygula(yeni: Set<string>): void;
  satirSecimiDegistir(id: string, index: number): void;
  hepsiSecili: boolean;
  hepsiRef: React.RefObject<HTMLInputElement | null>;
  /** Satir etkilesimleri. */
  satirTiklandi(e: React.MouseEvent, id: string, index: number): void;
  satirTiklaninca(satir: ListeSatiri): void;
  satirSinifi(satir: ListeSatiri): string;
  setSeciliSatir(satir: ListeSatiri | null): void;
  setSagTusKonumu(k: { x: number; y: number } | null): void;
  /** Kolon basligi: siralama ve filtre satiri. */
  siraIsareti(ad: string): string;
  siralamaDegistir(kolon: KolonMeta): void;
  filtreAcik: boolean;
  filtreSatiriDegisti(ad: string, deger: string): void;
  /** Grid (uc nokta) menusu konumu - baslik satirindaki dugme acar. */
  gridMenuKonum: { x: number; y: number } | null;
  setGridMenuKonum(k: { x: number; y: number } | null): void;
  /** Aksiyon ekrani tanimliysa sag tus menusu acilir. */
  aksiyonEkrani?: string;
  /**
   * AGAC KIPI: doluysa ilk kolon girintili cizilir ve cocugu olan satirda
   * +/- dugmesi cikar. Deger, hiyerarsiyi tasiyan ALAN ADIDIR (bolumde
   * "ustbirimId") - tablo onu okumaz, yalniz kipin acik oldugunu bilir.
   */
  agacAlani?: string;
  agacDegistir?(id: string): void;
}
