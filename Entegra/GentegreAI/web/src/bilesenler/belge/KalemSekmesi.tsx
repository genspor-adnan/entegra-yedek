import { Fragment } from 'react';
import { para } from '../bicim';
import { iskonatoMetni, satirTutari, tarihSaat, type SatirDurumu } from '../../sayfalar/belgeSatir';
import { DOVIZ_KODLARI } from '../../sayfalar/belgeSabitleri';
import type { BelgeYaniti } from '../../api/sozlesme';

/**
 * KALEMLER SEKMESI - satir gridi (izlemli kalemlerde lot master-detail) ve
 * dip toplam panosu.
 *
 * Grid SALT GORUNUM: ekleme/duzenleme kalem penceresinden yapilir, buradaki
 * dugmeler yalnizca onu acar. Tutarlar ONIZLEME; kayitli belgede sunucunun
 * dondurdugu dip toplam gosterilir.
 */
export function KalemSekmesi(p: KalemSekmesiProps) {
  const {
    satirlar, seciliSatirlar, setSeciliSatirlar, acikLotlar, setAcikLotlar,
    kilitli, bilgi, onizleme, sonuc, transferBaslikEksigi,
    depoBelgesi, stokFisiMi, talepMi,
    setStokArama, setKalem, seciliSil, satirTikla, sonTiklanan, secimDegis, doviz,
  } = p;

  const sayi = (m: unknown) => Number(String(m ?? '').replace(',', '.')) || 0;
  const yerelPara = doviz?.yerelPara ?? 'TL';

  /**
   * DOVIZ KOLONLARI (kullanici kurali):
   *   1) Tum satirlar yerel parada VE rapor dovizi yerel ise kolonlar GIZLI.
   *   2) Rapor dovizi secilince gorunur - yerel tutar KURA BOLUNEREK gosterilir.
   *   3) Bir satir kendi dovizinde girildiyse (100 USD) o satirda kendi
   *      degerleri; yerel karsiligi zaten "Birim Fiyat (TL)" kolonunda.
   */
  const raporKur = sayi(doviz?.kur);
  const raporDovizli = !!doviz && doviz.raporDovizi !== yerelPara && raporKur > 0;
  //   Kolonlar YALNIZ rapor dovizi secilince cikar (kullanici): hic doviz
  //   girilmemisse her sey yerel paradadir, fazladan kolon gosterilmez.
  //   Dovizli fiyatli bir kalem eklenince rapor dovizi ZATEN otomatik o doviz
  //   olur (BelgeKarti.kalemKaydet), yani kolonlar kendiliginden gelir.
  const dovizKolon = raporDovizli;
  const dovizAdi = raporDovizli ? doviz!.raporDovizi : '';

  /** Bir satirin doviz karsiligi: kendi dovizi varsa o, yoksa rapor kuruyla. */
  const satirDoviz = (r: SatirDurumu, yerelTutar: number, yerelFiyat: number) => {
    if (r.fiyatDovizi && r.fiyatDovizi !== yerelPara) {
      const birim = sayi(r.dovizFiyat);
      return { cins: r.fiyatDovizi, birim,
               tutar: satirTutari(sayi(r.adet), birim, r.iskonto, r.iskonto2) };
    }
    if (raporDovizli)
      return { cins: doviz!.raporDovizi, birim: yerelFiyat / raporKur, tutar: yerelTutar / raporKur };
    return null;
  };

  /** Hicbir satirda aciklama yoksa kolon HIC cizilmez (kullanici) - bos bir
   *  sutun gridi daraltiyordu. */
  const aciklamaVar = satirlar.some(x => String(x.aciklama ?? '').trim() !== '');

  /** Dip toplam / TOPLAM satiri icin yerel -> rapor dovizi. */
  const dovizeCevir = (yerel: number) => (raporDovizli ? yerel / raporKur : yerel);
  return (
    <>
<div className="kagrup">
  <h6>
    Kalemler
    {/* Ekle / Duzenle / Sil - YALNIZ IKON (yer kazanmak icin), ne
        yaptiklari title'da. Dugmeler kesin belgede de GORUNUR, yalnizca
        pasif: kaybolunca kullanici "nereye gitti" diye ariyordu. */}
    <button type="button" className="d bir ikon"
            disabled={kilitli || transferBaslikEksigi !== null}
            title={kilitli ? 'Kesin belgeye satır eklenemez (İptal edip yeniden kesin).'
                  : transferBaslikEksigi
                  ? `Önce başlıkta ${transferBaslikEksigi} seçin.`
                  : 'Satır ekle'}
            onClick={() => setStokArama(true)}>
      ＋
    </button>
    <button type="button" className="d ikon"
            disabled={kilitli || seciliSatirlar.size !== 1}
            title={kilitli ? 'Kesin belge satırı düzenlenemez.'
                  : seciliSatirlar.size === 0 ? 'Önce bir satır seçin'
                  : seciliSatirlar.size > 1 ? 'Tek satır seçin' : 'Seçili satırı düzenle'}
            onClick={() => {
              const anahtar = [...seciliSatirlar][0];
              const satir = satirlar.find(x => x.anahtar === anahtar);
              if (satir) setKalem(satir);
            }}>
      ✎
    </button>
    <button type="button" className="d teh ikon"
            disabled={kilitli || seciliSatirlar.size === 0}
            title={kilitli ? 'Kesin belgeden satır silinemez.'
                  : seciliSatirlar.size === 0 ? 'Önce satır seçin'
                  : `Seçili ${seciliSatirlar.size} satırı sil`}
            onClick={seciliSil}>
      🗑
    </button>
  </h6>

  {/* Grid SALT GORUNUM (mockup deseni): hucre ici input yok, satir secimi
      onay kutusuyla, ekleme/duzenleme ayri kalem penceresinde. Boylece
      satirlar okunakli kalir ve yanlislikla ustune yazilmaz. */}
  <table className="detay-tablo secilebilir">
    <thead>
      <tr>
        <th style={{ width: 30 }} className="hiza-orta">
          <input type="checkbox"
                 checked={satirlar.length > 0 && seciliSatirlar.size === satirlar.length}
                 onChange={e => setSeciliSatirlar(
                   e.target.checked ? new Set(satirlar.map(x => x.anahtar)) : new Set())} />
        </th>
        <th style={{ width: 34 }} className="hiza-orta">Tip</th>
        <th style={{ width: 110 }}>Kod</th>
        <th>Stok / Hizmet</th>
        {aciklamaVar && <th style={{ width: 200 }}>Açıklama</th>}
        {/* Miktar / iskonto / KDV DAR (kullanici): ikisi de en fazla birkac
            hane; genis birakinca stok adi sikisiyordu. */}
        <th className="hiza-sag" style={{ width: 60 }}>Miktar</th>
        {bilgi.kalem === 'tam' && <th className="hiza-sag" style={{ width: 56 }}>İskonto %</th>}
        {bilgi.kalem === 'tam' && <th className="hiza-sag" style={{ width: 46 }}>KDV %</th>}
        {/* Transferde FIYAT YOK: mal satilmiyor, depo degistiriyor. */}
        {bilgi.kalem !== 'miktar' && (
          <th className="hiza-sag" style={{ width: 110 }}>Birim Fiyat ({yerelPara})</th>
        )}
        {bilgi.kalem !== 'miktar' && (
          <th className="hiza-sag" style={{ width: 120 }}>Tutar ({yerelPara})</th>
        )}
        {/* Doviz kolonlari: satir kendi dovizinde girildiyse ya da rapor dovizi
            secildiyse cizilir; hepsi yerel ve rapor yoksa GIZLI. */}
        {bilgi.kalem !== 'miktar' && dovizKolon && (
          <th className="hiza-sag" style={{ width: 120 }}>
            Döviz Birim{dovizAdi ? ` (${dovizAdi})` : ''}
          </th>
        )}
        {bilgi.kalem !== 'miktar' && dovizKolon && (
          <th className="hiza-sag" style={{ width: 120 }}>
            Döviz Tutar{dovizAdi ? ` (${dovizAdi})` : ''}
          </th>
        )}
      </tr>
    </thead>
    <tbody>
      {satirlar.map((r, sira) => {
        const adet = Number(r.adet.replace(',', '.')) || 0;
        const fiyat = Number(r.birimFiyat.replace(',', '.')) || 0;
        const tutar = satirTutari(adet, fiyat, r.iskonto, r.iskonto2);
        const secili = seciliSatirlar.has(r.anahtar);
        // Izlemli kalemin lotlari ALTINDA acilir (master-detail):
        //   hangi lottan kac adet oldugu kalemi acmadan gorunsun.
        const lotlar = r.izlemler ?? [];
        // IZLEM (lot/seri) satirlari VARSAYILAN KAPALI (kullanici): kalem
        //   listesi kisa kalsin, isteyen okla acsin.
        const acik = lotlar.length > 0 && acikLotlar.has(r.anahtar);
        const kolonSayisi = (bilgi.kalem === 'miktar' ? 6 : bilgi.kalem === 'sade' ? 8 : 10)
                          - (aciklamaVar ? 0 : 1)
                          + (dovizKolon && bilgi.kalem !== 'miktar' ? 2 : 0);
        return (
          <Fragment key={r.anahtar}>
          <tr className={secili ? 'secili' : ''}
              onClick={e => satirTikla(sira, e)}
              onDoubleClick={() => !kilitli && setKalem(r)}>
            <td className="hiza-orta">
              {/* Onay kutusu TEK satiri ekler/cikarir - satir tiklamasi
                  (duz tik = yalniz o satir) tetiklenmesin. */}
              <input type="checkbox" checked={secili}
                     onClick={e => e.stopPropagation()}
                     onChange={() => { sonTiklanan.current = sira; secimDegis(r.anahtar) }} />
            </td>
            {/* Tip IKON: metin kolonu yer kapliyordu, anlami title'da. */}
            <td className="hiza-orta" title={r.satirTur === 2 ? 'Hizmet' : 'Stok'}>
              {r.satirTur === 2 ? '🛠️' : '📦'}
            </td>
            <td><code>{r.stokKodu}</code></td>
            <td>
              {/* Lotlu kalemde ac/kapa oku - detay satirlari onun altinda. */}
              {lotlar.length > 0 && (
                <button type="button" className="lot-ok"
                        title={acik ? 'Lotları gizle' : 'Lotları göster'}
                        onClick={e => {
                          e.stopPropagation();
                          setAcikLotlar(k => {
                            const y = new Set(k);
                            if (y.has(r.anahtar)) y.delete(r.anahtar); else y.add(r.anahtar);
                            return y;
                          });
                        }}>
                  {acik ? '▾' : '▸'}
                </button>
              )}
              {r.stokAdi || <span className="sonuk">(stok seçilmedi)</span>}
            </td>
            {aciklamaVar && <td className="sonuk">{r.aciklama}</td>}
            <td className="hiza-sag">{adet.toLocaleString('tr-TR')}</td>
            {/* Iki iskonto varsa ikisi de gorunsun: "%10 + %5". */}
            {bilgi.kalem === 'tam' && <td className="hiza-sag">{iskonatoMetni(r)}</td>}
            {bilgi.kalem === 'tam' && <td className="hiza-sag">%{r.kdv}</td>}
            {bilgi.kalem !== 'miktar' && <td className="hiza-sag">{para.format(fiyat)}</td>}
            {bilgi.kalem !== 'miktar' && <td className="hiza-sag"><b>{para.format(tutar)}</b></td>}
            {bilgi.kalem !== 'miktar' && dovizKolon && (() => {
              const d = satirDoviz(r, tutar, fiyat);
              return (
                <>
                  <td className="hiza-sag sonuk">{d ? para.format(d.birim) : '—'}</td>
                  <td className="hiza-sag sonuk">{d ? para.format(d.tutar) : '—'}</td>
                </>
              );
            })()}
          </tr>
          {/* DETAY: kalemin lot dagilimi. Kalem satirinin bir parcasi -
              ayri kolon basligi yok, kendi mini basligiyla gelir. */}
          {acik && lotlar.length > 0 && (
            <tr className="lot-detay">
              <td />
              <td colSpan={kolonSayisi - 1}>
                <table className="lot-tablo">
                  <thead>
                    <tr>
                      <th>Lot No</th>
                      <th>Seri No</th>
                      <th>Ürt. Tarihi</th>
                      <th>SKT</th>
                      <th className="hiza-sag">Miktar</th>
                    </tr>
                  </thead>
                  <tbody>
                    {lotlar.map((z, li) => (
                      <tr key={z.seriLotId ?? li}>
                        <td><code>{z.lotNo || '—'}</code></td>
                        <td>{z.seriNo || '—'}</td>
                        <td>{z.uretimTarihi ? z.uretimTarihi.split('-').reverse().join('.') : '—'}</td>
                        <td>{z.sonKullanmaTarihi ? z.sonKullanmaTarihi.split('-').reverse().join('.') : '—'}</td>
                        <td className="hiza-sag">
                          {(Number(String(z.miktar).replace(',', '.')) || 0).toLocaleString('tr-TR')}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </td>
            </tr>
          )}
          </Fragment>
        );
      })}
      {satirlar.length === 0 && (
        <tr><td colSpan={(bilgi.kalem === 'miktar' ? 6 : bilgi.kalem === 'sade' ? 8 : 10)
                       + (bilgi.kalem !== 'miktar' ? 1 : 0)
                          + (dovizKolon && bilgi.kalem !== 'miktar' ? 2 : 0)} className="bos">
          {transferBaslikEksigi
            ? `Kalem eklemek için önce başlıkta ${transferBaslikEksigi} seçin.`
            : 'Kalem yok — “＋” ile ekleyin.'}
        </td></tr>
      )}
    </tbody>
    <tfoot>
      <tr className="genel">
        <td colSpan={aciklamaVar ? 5 : 4} className="hiza-sag">TOPLAM</td>
        <td className="hiza-sag">
          {satirlar.reduce((t, r) => t + (Number(r.adet.replace(',', '.')) || 0), 0)
                   .toLocaleString('tr-TR')}
        </td>
        {bilgi.kalem !== 'miktar' && <td colSpan={bilgi.kalem === 'sade' ? 1 : 3} />}
        {bilgi.kalem !== 'miktar' && <td className="hiza-sag">{para.format(onizleme.matrah)}</td>}
        {bilgi.kalem !== 'miktar' && dovizKolon && <td />}
        {bilgi.kalem !== 'miktar' && dovizKolon && (
          <td className="hiza-sag">
            {para.format(satirlar.reduce((t, r) => {
              const f = sayi(r.birimFiyat);
              const d = satirDoviz(r, satirTutari(sayi(r.adet), f, r.iskonto, r.iskonto2), f);
              return t + (d?.tutar ?? 0);
            }, 0))}
          </td>
        )}
      </tr>
    </tfoot>
  </table>
  {!kilitli && satirlar.length > 0 && (
    <div className="not">
      Satırı düzenlemek için çift tıklayın.
      {(depoBelgesi || stokFisiMi) && ` Kalem eklendiği için başlık (${stokFisiMi ? 'tip, depo' : talepMi ? 'depolar, talep eden' : 'depolar, teslim eden/alan'}, tarih) kilitlendi — değiştirmek için kalemleri silin.`}
    </div>
  )}
</div>

{/* Doviz kutusu SOLDA, dip toplam SAGDA - ayni hizada (kullanici). */}
{bilgi.kalem !== 'miktar' && (
<div className="grid-alt-serit">
{doviz && (
  /* RAPOR / EKSTRE DOVIZI (134) - gridin ALTINDA SOLDA (kullanici).
     Rapor dovizi yerel para disindaysa yaninda KUR editi cikar ve dip toplam
     ikinci bir kolonda yerel karsiligiyla gosterilir. Ekstre dovizi cari
     hesaba hangi dovizde islenecegidir: rapor dovizi ya da yerel para. */
  <div className="kagrup belge-doviz">
    <div className="alan-izgara tek-sutun">
      <label className="alan">
        <span className="etiket">Rapor Dövizi</span>
        <div className="ikili">
          <select value={doviz.raporDovizi} disabled={kilitli}
                  onChange={e => doviz.setRaporDovizi(e.target.value)}>
            {DOVIZ_KODLARI.map(k => <option key={k} value={k}>{k}</option>)}
          </select>
          {doviz.raporDovizi !== doviz.yerelPara && (
            <input className="kur hiza-sag" value={doviz.kur} disabled={kilitli}
                   title={`1 ${doviz.raporDovizi} = ? ${doviz.yerelPara}`}
                   onChange={e => doviz.setKur(e.target.value)} />
          )}
        </div>
      </label>
      <label className="alan">
        {/* "Ekstre Dövizi" = cari hesaba hangi dovizde islenecegi. SIPARISTE
            cari hareketi YOK (henuz mal/fatura cikmadi), o yuzden orada alan
            "Sipariş Dövizi" adiyla cikar (kullanici) - siparis onaylanip
            irsaliye/faturaya donunce ekstre dovizi olarak tasinir. */}
        <span className="etiket">{bilgi.siparis ? 'Sipariş Dövizi' : 'Ekstre Dövizi'}</span>
        <select value={doviz.ekstreDovizi} disabled={kilitli}
                onChange={e => doviz.setEkstreDovizi(e.target.value)}>
          {/* Rapor dovizi + yerel para (ayni ise tek secenek). */}
          {[...new Set([doviz.raporDovizi, doviz.yerelPara])]
            .map(k => <option key={k} value={k}>{k}</option>)}
        </select>
      </label>
    </div>
    {doviz.raporDovizi !== doviz.yerelPara && (
      <div className="not">
        Tutarlar {doviz.yerelPara} girilir; {doviz.raporDovizi} karşılığı kura
        bölünerek gösterilir.
        {/* Siparis cari hesabi ETKILEMEZ - "cari hesaba islenir" cumlesi orada
            yaniltici olurdu. */}
        {!bilgi.siparis && <> Cari hesaba <b>{doviz.ekstreDovizi}</b> işlenir.</>}
      </div>
    )}
  </div>
)}

{(
<div className="kagrup dip-toplam">
  {/* BASLIK YOK (kullanici): cerceve ve kolon basliklari zaten neyin ne
      oldugunu soyluyor; "Dip Toplam" satiri yer kapliyordu. */}
  {sonuc ? (
    <table className="dip-tablo">
      {raporDovizli && (
        <thead>
          {/* Dip toplamda SOLDA yerel, SAGDA doviz (kullanici). */}
          <tr><th /><th className="hiza-sag">{yerelPara}</th>
              <th className="hiza-sag">{doviz!.raporDovizi}</th></tr>
        </thead>
      )}
      <tbody>
        {sonuc.dipToplam.map((d, i) => (
          <tr key={i} className={d.tur === 20 ? 'genel' : ''}>
            <td>{d.aciklama}</td>
            <td className="hiza-sag">{para.format(d.deger)}</td>
            {/* Dovizli belgede IKINCI kolon: kur ile yerel karsilik (kullanici). */}
            {raporDovizli && (
              <td className="hiza-sag sonuk">{para.format(dovizeCevir(d.deger))}</td>
            )}
          </tr>
        ))}
      </tbody>
    </table>
  ) : (
    <table className="dip-tablo">
      {raporDovizli && (
        <thead>
          {/* Dip toplamda SOLDA yerel, SAGDA doviz (kullanici). */}
          <tr><th /><th className="hiza-sag">{yerelPara}</th>
              <th className="hiza-sag">{doviz!.raporDovizi}</th></tr>
        </thead>
      )}
      <tbody>
        <tr>
          <td>Ara Toplam</td><td className="hiza-sag">{para.format(onizleme.matrah)}</td>
          {raporDovizli && <td className="hiza-sag sonuk">{para.format(dovizeCevir(onizleme.matrah))}</td>}
        </tr>
        <tr>
          <td>KDV</td><td className="hiza-sag">{para.format(onizleme.kdv)}</td>
          {raporDovizli && <td className="hiza-sag sonuk">{para.format(dovizeCevir(onizleme.kdv))}</td>}
        </tr>
        <tr className="genel">
          <td>Genel Toplam</td><td className="hiza-sag">{para.format(onizleme.genel)}</td>
          {raporDovizli && <td className="hiza-sag sonuk">{para.format(dovizeCevir(onizleme.genel))}</td>}
        </tr>
      </tbody>
    </table>
  )}
  {/* "Kesin tutar sunucuda hesaplanir" notu kaldirildi (kullanici): kayittan
      sonra zaten sunucunun dondurdugu tutar gosteriliyor. */}
</div>
)}
</div>
)}
    </>
  );
}

export interface KalemSekmesiProps {
  satirlar: SatirDurumu[];
  seciliSatirlar: Set<number>;
  setSeciliSatirlar(v: Set<number>): void;
  /** Lot detayi ACIK olan kalemler (varsayilan KAPALI). */
  acikLotlar: Set<number>;
  setAcikLotlar(v: Set<number> | ((o: Set<number>) => Set<number>)): void;
  kilitli: boolean;
  /** belgeTuru.ts davranis tablosu: kalem bicimi (tam | sade | miktar) vb. */
  bilgi: { kalem: 'tam' | 'sade' | 'miktar'; alis: boolean; siparis: boolean };
  onizleme: { matrah: number; kdv: number; genel: number };
  sonuc: BelgeYaniti | null;
  /** Transferde eksik baslik alani (varsa kalem eklenemez). */
  transferBaslikEksigi: string | null;
  depoBelgesi: boolean;
  stokFisiMi: boolean;
  talepMi: boolean;
  setStokArama(v: boolean): void;
  setKalem(v: SatirDurumu | null): void;
  seciliSil(): void;
  /** Satir tiklama (Shift ile aralik secimi kartta yonetiliyor). */
  satirTikla(sira: number, e: React.MouseEvent): void;
  /** Son tiklanan satirin SIRASI - Shift araligi bunun uzerinden hesaplanir. */
  sonTiklanan: React.MutableRefObject<number | null>;
  secimDegis(anahtar: number): void;
  /** Rapor / ekstre dovizi kutusu (134). Verilmezse kutu cizilmez. */
  doviz?: {
    raporDovizi: string;
    setRaporDovizi(v: string): void;
    ekstreDovizi: string;
    setEkstreDovizi(v: string): void;
    kur: string;
    setKur(v: string): void;
    yerelPara: string;
  };
}

/**
 * TAHSILAT SEKMESI - belgeye bagli kasa islemleri ve kalan bakiye.
 * Kayit YOK: tahsilat kasa ekranindan girilir, burasi ozet gosterir.
 */
export function TahsilatSekmesi({ sonuc, tahsilatlar, kayitliId, alisMi, tahsilatAc }: {
  sonuc: BelgeYaniti | null;
  tahsilatlar: Record<string, unknown>[];
  kayitliId: number;
  /** Alis belgesinde "Tahsilat" degil "Ödeme" yazar. */
  alisMi: boolean;
  /** Kasa islem kartini acar (tur: tahsilat 21 / odeme 31); belge kayitli
      degilse ONCE kaydeder. */
  tahsilatAc(tur: number): Promise<void>;
}) {
const genel = Number(sonuc?.belge.genelToplam ?? 0);
const tahsil = tahsilatlar.reduce((t, k) => t + (Number(k.yerelTutar ?? k.tutar ?? 0) || 0), 0);
const kalan = Math.round((genel - tahsil) * 100) / 100;
return (
  <div className="kagrup">
    {/* Tahsilat araclari: Nakit 21 / Banka 22 / POS 25 - hepsi ayni
        modali (kasa karti) cari + tutar onyuklu acar. Cek/Senet kasa
        planinin F5 fazinda (cek_senet tablosu) baglanacak. */}
    <div className="katoolbar" style={{ margin: 10 }}>
      {/* Tahsilat ARACI adiyla: yanindaki POS / Cek-Senet ile ayni
          dizide - bu dugme NAKIT tahsilat (tur 21) acar. */}
      {/* Alista ODEME turleri (31/32/35), satista tahsilat (21/22/25). */}
      {/* Kayitli olma sarti YOK: kaydedilmemis belgede kart once KAYDEDER,
          sonra tahsilati acar (tahsilatAc). */}
      <button className="d bir"
              title={kayitliId ? `Nakit ${alisMi ? 'ödeme' : 'tahsilat'} işlemi aç`
                               : `Belge kaydedilip nakit ${alisMi ? 'ödeme' : 'tahsilat'} açılır`}
              onClick={() => void tahsilatAc(alisMi ? 31 : 21)}>
        💵 Nakit
      </button>
      <button className="d bir"
              title={kayitliId ? `Banka (havale/EFT) ${alisMi ? 'ödeme' : 'tahsilat'} işlemi aç`
                               : 'Belge kaydedilip banka işlemi açılır'}
              onClick={() => void tahsilatAc(alisMi ? 32 : 22)}>
        🏦 Banka
      </button>
      <button className="d bir"
              title={kayitliId ? `Kredi kartı / POS ${alisMi ? 'ödeme' : 'tahsilat'} işlemi aç`
                               : 'Belge kaydedilip POS işlemi açılır'}
              onClick={() => void tahsilatAc(alisMi ? 35 : 25)}>
        💳 POS
      </button>
      <button className="d" disabled title="Çek/senet girişi F5'te bağlanacak">🧾 Çek/Senet Al</button>
    </div>
    <table className="detay-tablo">
      <thead>
        <tr>
          <th style={{ width: 140 }}>Tarih / Saat</th>
          <th style={{ width: 120 }}>Makbuz No</th>
          <th style={{ width: 180 }}>Tür</th>
          <th>Kasa / Banka</th>
          <th className="hiza-sag" style={{ width: 130 }}>Tutar</th>
        </tr>
      </thead>
      <tbody>
        {tahsilatlar.map((k, i) => (
          <tr key={i}>
            {/* Tarih + saat: ayni gun birden fazla tahsilat olunca
                sira ancak saatle anlasiliyordu. */}
            <td>{tarihSaat(k.islemTarihi)}</td>
            <td>{String(k.islemNo ?? '')}</td>
            <td>{String(k.turAdi ?? '')}</td>
            <td>{String(k.hesapAdi ?? '') || <span className="sonuk">—</span>}</td>
            <td className="hiza-sag">{para.format(Number(k.yerelTutar ?? k.tutar ?? 0))}</td>
          </tr>
        ))}
        {tahsilatlar.length === 0 && (
          <tr><td colSpan={5} className="bos">
            {kayitliId > 0
              ? `Bu belgeye bağlı ${alisMi ? 'ödeme' : 'tahsilat'} yok.`
              : 'Önce belgeyi kaydedin.'}
          </td></tr>
        )}
      </tbody>
      <tfoot>
        <tr className="genel">
          <td colSpan={4} className="hiza-sag">
            {alisMi ? 'Ödenen / Kalan' : 'Tahsil Edilen / Kalan'}
          </td>
          <td className="hiza-sag">
            {para.format(tahsil)} /{' '}
            <b style={{ color: kalan > 0 ? 'var(--hata)' : 'var(--ok)' }}>
              {para.format(kalan)}
            </b>
          </td>
        </tr>
      </tfoot>
    </table>

  </div>
);
}
