import { useEffect, useRef, useState } from 'react';
import { AvansMahsup } from '../AvansMahsup';
import { para, tarihSaat, paraYaz } from '../bicim';
import type { BelgeYaniti } from '../../api/sozlesme';

/**
 * TAHSILAT SEKMESI - belgeye bagli kasa islemleri ve kalan bakiye.
 * Kayit YOK: tahsilat kasa ekranindan girilir, burasi ozet gosterir.
 */
export function TahsilatSekmesi({ sonuc, tahsilatlar, kayitliId, alisMi, tahsilatAc,
                                  secili, setSecili, tahsilatAcKart, tahsilatSil,
                                  onYenile, kurumTahakkukAc, kurumKalan, kurumBelgeleri,
                                  basvuruMu,
                                  hizliNakit, hesapSecAc, acikBorc,
                                  iadeAc, yerelPara = 'TL' }: {
  /** Basvuru kartinda arac cubugu SADE: "＋" (tam ekran) cizilmez. */
  basvuruMu?: boolean;
  sonuc: BelgeYaniti | null;
  tahsilatlar: Record<string, unknown>[];
  kayitliId: number;
  /** Avans mahsubu satirlari degistirdiginde belgeyi tazelemek icin (322). */
  onYenile?(): void;
  /** Alis belgesinde "Tahsilat" degil "Ödeme" yazar. */
  alisMi: boolean;
  /** Kasa islem kartini acar (tur: tahsilat 21 / odeme 31); belge kayitli
      degilse ONCE kaydeder. */
  tahsilatAc(tur: number): Promise<void>;
  /** Listede SECILI kasa islemleri (satir onay kutulari, coklu secim). */
  secili: number[];
  setSecili(v: number[]): void;
  /** MEVCUT kasa islemini duzeltmek icin karti acar (cift tik da bunu cagirir). */
  tahsilatAcKart(id: number): void;
  /** Secili kasa islemlerini siler - silinemeyende sunucunun sebebi gosterilir (354). */
  tahsilatSil(idler: number[]): Promise<void>;
  /**
   * HIZLI TAHSILAT (kullanici): kasa karti ACILMADAN gride satir ekler.
   * Nakitte varsayilan kasa, banka/POS'ta modal aramadan secilen hesap.
   */
  hizliNakit?(): void;
  /** Banka/POS hesabi secim penceresi; `iade` true ise satir EKSI yazilir. */
  hesapSecAc?(tur: 'B' | 'P', iade?: boolean): void;
  /**
   * IADE / IPTAL: secilen araca gore iade satiri ekler (tutar penceresinde
   * neden combosu da sorulur). Verilmezse dugme cizilmez.
   */
  iadeAc?(arac: 'nakit' | 'pos' | 'banka' | 'cek' | 'senet'): void;
  /** Yerel para kodu - "dövizli tahsilat var mı" bunun disindakilerle olculur. */
  yerelPara?: string;
  /** Gridde tutar hucresine tiklaninca cagrilir (satir ici duzenleme). */
  /** Belgenin ACIK BORCU - yeni tahsilat satiri bu tutarla acilir. */
  acikBorc?: number;
  /**
   * KURUM TAHAKKUKU (331): basvuruda kurum payini kuruma kesilen belgeye
   * (Satış Tahakkuku) dönüştürür. TAHSILAT DEGILDIR - hastadan para alinmaz,
   * kasa hareketi olusmaz; alacak kurum carisine yazilir ve prim de dogmaz
   * (prim yalniz tahsilattan uretilir). Verilmezse dugme cizilmez.
   */
  kurumTahakkukAc?(): void;
  /** Henuz belgelesmemis kurum payi - dugme yalniz bu > 0 iken etkin. */
  kurumKalan?: number;
  /**
   * KURUM TAHAKKUKLARI (kullanici: "kaydettiğim zaman eğer yoksa kurum
   * tahakkuk ilk satıra gelecek (yani 800), altına da 200 nakit gelecek").
   *
   * Tahakkuk bir KASA ISLEMI DEGIL, kuruma kesilen belgedir - listeye SALT
   * OKUNUR satir olarak, tahsilatlarin USTUNE gelir: memur "800'ü kuruma
   * yazdım, 200'ü hastadan aldım" tablosunu tek yerde gorur. Secilemez ve
   * silinemez; duzeltmesi Belgeye Dönüşüm sekmesindedir.
   */
  kurumBelgeleri?: { id: number; belgeNo: string; tarih: string;
                     turAdi: string; cari: string; tutar: number;
                     /** Hastaya mi kesildi (ikon 👤) yoksa kuruma mi (🏛️). */
                     hastaMi?: boolean }[];
}) {
/* SECIM: faturalama gridiyle AYNI desen - duz tik tek satir secer, Ctrl/Cmd
   ekler-cikarir, Shift aralik secer; basliktaki kutu tumunu secer. */
const idler = tahsilatlar.map(k => Number(k.id ?? 0)).filter(Boolean);
const hepsi = idler.length > 0 && secili.length === idler.length;
const cevir = (id: number) =>
  setSecili(secili.includes(id) ? secili.filter(x => x !== id) : [...secili, id]);
const tekSecili = secili.length === 1 ? secili[0] : 0;
const capa = useRef<number | null>(null);   // son tiklanan satirin sirasi
/**
 * "⋯" MENUSU (banka / cek / senet): seyrek kullanilan tahsilat araclari.
 * Disari tiklaninca kapanir - acik menu ekranda unutulmasin (GenToolbar ile
 * ayni desen).
 */
const [aracMenu, setAracMenu] = useState(false);
/** IADE arac menusu - "⋯" ile ayni desen, ayri acilir. */
const [iadeMenu, setIadeMenu] = useState(false);
useEffect(() => {
  if (!aracMenu && !iadeMenu) return;
  const kapat = () => { setAracMenu(false); setIadeMenu(false) };
  window.addEventListener('click', kapat);
  return () => window.removeEventListener('click', kapat);
}, [aracMenu, iadeMenu]);
/* PARA USTU dugmesi yalniz dovizli tahsilat varken: yerel parada alinan tutar
   zaten net yazilir, "ustu" diye ayri bir satira gerek yok. */
const dovizliTahsilatVar = tahsilatlar.some(
  k => String(k.dovizCinsi ?? yerelPara) !== yerelPara);
const satirTikla = (e: React.MouseEvent, sira: number, id: number) => {
  if (!id) return;
  if (e.shiftKey && capa.current != null) {
    const [bas, son] = capa.current <= sira ? [capa.current, sira] : [sira, capa.current];
    setSecili(tahsilatlar.slice(bas, son + 1).map(k => Number(k.id ?? 0)).filter(Boolean));
    return;
  }
  capa.current = sira;
  if (e.ctrlKey || e.metaKey) { cevir(id); return }
  setSecili(secili.length === 1 && secili[0] === id ? [] : [id]);
};
/**
 * DIP TOPLAM HASTA PAYI UZERINDEN (kullanici: "nakit, POS, banka, çek, senet
 * her zaman hastadan alacağımız tahsilatlar içindir").
 *
 * "Kalan" belgenin genel toplamindan hesaplanınca paylasimli basvuruda kurumun
 * payi da hastadan beklenen para gibi gorunuyordu: 1.000 TL'lik iste hastadan
 * 200 alinacakken dipnot "Kalan 1.000" yaziyordu. `acikBorc` kart tarafinda
 * zaten HASTA PAYINI tasir (paylasimli degilse belgenin tamami).
 */
const genel = Number(sonuc?.belge.genelToplam ?? 0);
const tahsil = tahsilatlar.reduce((t, k) => t + (Number(k.yerelTutar ?? k.tutar ?? 0) || 0), 0);
const kalan = acikBorc != null
  ? Math.round(acikBorc * 100) / 100
  : Math.round((genel - tahsil) * 100) / 100;
return (
  <div className="kagrup">
    {/* AVANS MAHSUBU (322): hasta once para yatirip ucret satiri sonra
        girildiyse o tahsilat hicbir satira bagli degildir - prim de dogmaz.
        Serit yalniz dagitilmamis tahsilat VARSA cizilir. */}
    {kayitliId > 0 && Number(sonuc?.belge.tarafId ?? 0) > 0 && (
      <AvansMahsup belgeId={kayitliId}
                   tarafId={Number(sonuc?.belge.tarafId)}
                   onTamam={onYenile} />
    )}
    {/* Tahsilat araclari: Nakit 21 / Banka 22 / POS 25 - hepsi ayni
        modali (kasa karti) cari + tutar onyuklu acar. Cek/Senet kasa
        planinin F5 fazinda (cek_senet tablosu) baglanacak. */}
    <div className="katoolbar" style={{ margin: 10 }}>
      {/* Tahsilat ARACI adiyla: yanindaki POS / Cek-Senet ile ayni
          dizide - bu dugme NAKIT tahsilat (tur 21) acar. */}
      {/* Alista ODEME turleri (31/32/35), satista tahsilat (21/22/25). */}
      {/* Kayitli olma sarti YOK: kaydedilmemis belgede kart once KAYDEDER,
          sonra tahsilati acar (tahsilatAc). */}
      {/* HIZLI TAHSILAT (kullanici): kart ACILMAZ - satir dogrudan gride
          duser. Nakitte VARSAYILAN KASA, banka/POS'ta modal aramadan secilen
          hesap kullanilir; tutar acik borcun tamami gelir ve gridde
          tiklanarak degistirilir. */}
      {/* KAYITLI OLMA SARTI YOK (kullanici: "ücretleme yaptım tahsilat
          sekmede nakit/banka/pos basamıyorum"): dugmeler kaydedilmemis
          belgede pasifti ve "Önce belgeyi kaydedin" diyordu - kullaniciyi
          karti birakip yesil dugmeye gitmeye zorluyordu. Tahsilat kasaya
          belge kimligiyle baglandigi icin kayit gercekten sart, ama kart
          KENDISI kaydediyor (BelgeKarti.kayitSart) - tipki ucret eklemede
          oldugu gibi. */}
      <button className="d bir"
              title={`Varsayılan kasaya nakit ${alisMi ? 'ödeme' : 'tahsilat'} satırı ekler`
                + (acikBorc && acikBorc > 0 ? ` (${paraYaz(acikBorc)})` : '')
                + (kayitliId ? '' : ' — belge önce kaydedilir')}
              onClick={() => hizliNakit?.()}>
        💵 Nakit
      </button>
      <button className="d bir"
              title={'POS hesabı seç ve satır ekle'
                     + (kayitliId ? '' : ' — belge önce kaydedilir')}
              onClick={() => hesapSecAc?.('P')}>
        💳 POS
      </button>
      {/* SEYREK ARACLAR MENUDE (kullanici: "sağında ... şeklinde 3 nokta
          buton olsun basınca alta doğru menüde Banka/Çek/Senet"): kayit
          kabulde tahsilatin neredeyse tamami nakit ya da POS; banka havalesi
          ve cek/senet ayda birkac kez. Bes dugme yan yana durunca en cok
          kullanilan ikisi kalabaligin icinde kayboluyordu.
          Cek ve senet AYRI SECENEK: ikisi ayri kasa islem turu (23/24
          tahsilat, 33/34 odeme) ve portfoyde ayri izlenir. */}
      <span className="dugme-menu">
        <button className="d" title="Diğer tahsilat araçları"
                onClick={e => { e.stopPropagation(); setAracMenu(v => !v) }}>⋯</button>
        {aracMenu && (
          <div className="dugme-menu-liste">
            <button type="button" className="mi"
                    onClick={() => { setAracMenu(false); hesapSecAc?.('B') }}>
              🏦 Banka
            </button>
            <button type="button" className="mi"
                    onClick={() => { setAracMenu(false); void tahsilatAc(alisMi ? 33 : 23) }}>
              🧾 Çek
            </button>
            <button type="button" className="mi"
                    onClick={() => { setAracMenu(false); void tahsilatAc(alisMi ? 34 : 24) }}>
              📜 Senet
            </button>
          </div>
        )}
      </span>
      {/* IADE / IPTAL (kullanici: "3 nokta buton sağına ↩ İade / İptal
          butonu ekle, basınca alta doğru menü gelsin Nakit/Pos/Banka/Çek/
          Senet"). Arac menusu tahsilattaki ile AYNI: para hangi araçla
          alindiysa o araçla geri verilir - karttan alinip nakit iade etmek
          veznede olmayan parayi cikarir ve en bilinen suistimal yoludur.
          Secimden sonra tutar penceresi acilir; tutar EKSI islenir. */}
      {iadeAc && (
        <span className="dugme-menu">
          <button className="d" title="Seçilen araçla iade / iptal satırı ekler"
                  disabled={!kayitliId}
                  onClick={e => { e.stopPropagation(); setIadeMenu(v => !v) }}>
            ↩ İade / İptal
          </button>
          {iadeMenu && (
            <div className="dugme-menu-liste">
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); iadeAc('nakit') }}>💵 Nakit</button>
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); iadeAc('pos') }}>💳 POS</button>
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); iadeAc('banka') }}>🏦 Banka</button>
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); iadeAc('cek') }}>🧾 Çek</button>
              <button type="button" className="mi"
                      onClick={() => { setIadeMenu(false); iadeAc('senet') }}>📜 Senet</button>
            </div>
          )}
        </span>
      )}
      {/* KURUM TAHAKKUKU (331): tahsilat ARACI DEGIL - "tahsil edildi"
          saymaz; bu yuzden tahsilat araclarinin SONUNDA, Senet'in saginda
          durur (kullanici). Kurum payi
          kuruma kesilen Satış Tahakkuku belgesine doner; para kurumdan
          gelince normal tahsilat islenir ve prim O ZAMAN dogar. */}
      {kurumTahakkukAc && (
        <button className="d"
                disabled={!kayitliId || !(kurumKalan && kurumKalan > 0)}
                title={!kayitliId ? 'Önce belgeyi kaydedin'
                       : !(kurumKalan && kurumKalan > 0)
                       ? 'Belgelenmemiş kurum payı yok'
                       : 'Kurumdan alınacak payı belgeler: kuruma Satış Tahakkuku '
                         + 'kesilir. Para kurumdan gelince normal tahsilat işlenir.'}
                onClick={kurumTahakkukAc}>
          {/* "TAHSILAT" DEGIL "TAHAKKUK" (kullanici: "kurumun ödeyeceği ve
              kuruma yapacağım faturalama karşılığı olarak değil mi"): kurum
              payi iki asamalidir - once kuruma BELGE kesilir (alacak dogar),
              para geldiginde normal tahsilat islenir ve prim O ZAMAN dogar.
              Dugmeye "tahsilat" demek, para alinmis izlenimi verirdi. */}
          🏥 Kuruma Tahakkuk
        </button>
      )}
      <span className="ayrac" />
      {/* Secili satir uzerinde islem - kalem gridiyle ayni desen: yalniz ikon,
          secim yoksa pasif. Cift tik da duzeltmeyi acar. */}
      {/* "＋" BASVURUDA CIZILMEZ (kullanici): tam tahsilat ekranini acan
          ikinci bir yol, Nakit / POS / ⋯ araclari dururken yalniz karisiklik
          yaratiyordu - hangi dugmenin ne actigi belirsizlesiyordu. Kayit
          kabulde tahsilat araclardan biriyle baslar; ayrintili duzeltme
          mevcut satirin ✎ ikonundan. ERP belgelerinde (satis siparisi,
          fatura) tam ekran hala gerekli - orada duruyor. */}
      {!basvuruMu && (
        <button className="d" disabled={!kayitliId}
                title={kayitliId ? 'Tahsilat ekranını aç (tüm alanlarla)'
                                 : 'Önce belgeyi kaydedin'}
                onClick={() => void tahsilatAc(alisMi ? 31 : 21)}>＋</button>
      )}
      <button className="d" disabled={!tekSecili}
              title={!secili.length ? 'Önce satır seçin'
                     : secili.length > 1 ? 'Düzeltme için tek satır seçin'
                     : 'Seçili işlemi düzelt'}
              onClick={() => tekSecili && tahsilatAcKart(tekSecili)}>✎</button>
      <button className="d teh" disabled={!secili.length}
              title={secili.length ? 'Seçili işlemleri sil' : 'Önce satır seçin'}
              onClick={() => { void tahsilatSil(secili) }}>🗑</button>
      {secili.length > 1 && <span className="kapt">{secili.length} işlem seçili</span>}
    </div>
    <table className="detay-tablo">
      <thead>
        <tr>
          <th className="check">
            <input type="checkbox" checked={hepsi} disabled={!idler.length}
                   title="Tümünü seç"
                   onChange={() => setSecili(hepsi ? [] : idler)} />
          </th>
          <th style={{ width: 140 }}>Tarih / Saat</th>
          <th style={{ width: 120 }}>Makbuz No</th>
          <th style={{ width: 180 }}>Tür</th>
          <th>Kasa / Banka</th>
          {/* DOVIZ SUTUNU yalniz dovizli tahsilat varsa (kullanici: "döviz
              tahsilat olursa tutar soluna alınan döviz de gelsin"): "Tutar"
              kolonu YEREL KARSILIKTIR, hastanin verdigi 100 USD orada hic
              gorunmuyordu. Yerel parada bu sutun bos yer harcar - cizilmez. */}
          {dovizliTahsilatVar && (
            <th className="hiza-sag" style={{ width: 120 }}
                title="Alınan döviz tutarı ve para birimi">Alınan Döviz</th>
          )}
          <th className="hiza-sag" style={{ width: 130 }}
              title={`Yerel karşılık (${yerelPara})`}>Tutar</th>
        </tr>
      </thead>
      <tbody>
        {/* KURUM TAHAKKUKLARI EN USTTE (kullanici): tahsilattan once okunur -
            "kurumun payi belgelendi mi" sorusu listenin basinda cevaplanir. */}
        {(kurumBelgeleri ?? []).map(kb => (
          <tr key={`kb-${kb.id}`} className="kurum-belge" style={{ userSelect: 'none' }}>
            <td className="check">
              {/* IKON BELGENIN TARAFINA GORE (kullanici tahakkuku ikiye ayirdi):
                  hastaya kesilen 👤, kuruma kesilen 🏛️. Ikisi de TAHSILAT
                  DEGIL - alacagin belgelenmesidir. */}
              <span className="sonuk"
                    title={kb.hastaMi ? 'Hastaya kesilen belge - tahsilat değildir'
                                      : 'Kuruma kesilen belge - tahsilat değildir'}>
                {kb.hastaMi ? '👤' : '🏛️'}</span>
            </td>
            <td>{tarihSaat(kb.tarih)}</td>
            <td>{kb.belgeNo}</td>
            <td>{kb.turAdi}</td>
            <td>{kb.cari || <span className="sonuk">—</span>}</td>
            {dovizliTahsilatVar && <td className="hiza-sag sonuk">—</td>}
            <td className="hiza-sag">{para.format(kb.tutar)}</td>
          </tr>
        ))}
        {tahsilatlar.map((k, i) => {
          const kid = Number(k.id ?? 0);
          return (
          <tr key={i} className={kid && secili.includes(kid) ? 'secili' : ''}
              style={{ userSelect: 'none' }}
              onClick={e => satirTikla(e, i, kid)}
              onDoubleClick={() => kid && tahsilatAcKart(kid)}>
            <td className="check" onClick={e => e.stopPropagation()}>
              <input type="checkbox" checked={!!kid && secili.includes(kid)} disabled={!kid}
                     onChange={() => { if (kid) { capa.current = i; cevir(kid) } }} />
            </td>
            {/* Tarih + saat: ayni gun birden fazla tahsilat olunca
                sira ancak saatle anlasiliyordu. */}
            <td>{tarihSaat(k.islemTarihi)}</td>
            <td>{String(k.islemNo ?? '')}</td>
            <td>{String(k.turAdi ?? '')}</td>
            <td>{String(k.hesapAdi ?? '') || <span className="sonuk">—</span>}</td>
            {/* TUTAR ARTIK GRIDDE DUZENLENMIYOR (kullanici): tutar tahsilat
                aracina basildigi anda MODALDE soruluyor (acik borc onyuklu,
                Enter kaydediyor). Iki ayri duzenleme yolu -hucre ici ve
                modal- ayni alani farkli kurallarla yaziyordu; girilen satir
                yanlissa ✎ ile tahsilat ekrani acilir. */}
            {dovizliTahsilatVar && (() => {
              const dvz = String(k.dovizCinsi ?? yerelPara) || yerelPara;
              return (
                <td className="hiza-sag">
                  {dvz === yerelPara
                    ? <span className="sonuk">—</span>
                    : <>{para.format(Number(k.tutar ?? 0))}{' '}
                        <span className="sonuk">{dvz}</span></>}
                </td>
              );
            })()}
            <td className="hiza-sag">
              {para.format(Number(k.yerelTutar ?? k.tutar ?? 0))}
            </td>
          </tr>
          );
        })}
        {tahsilatlar.length === 0 && (kurumBelgeleri ?? []).length === 0 && (
          <tr><td colSpan={dovizliTahsilatVar ? 7 : 6} className="bos">
            {kayitliId > 0
              ? `Bu belgeye bağlı ${alisMi ? 'ödeme' : 'tahsilat'} yok.`
              : 'Önce belgeyi kaydedin.'}
          </td></tr>
        )}
      </tbody>
      <tfoot>
        <tr className="genel">
          <td colSpan={dovizliTahsilatVar ? 6 : 5} className="hiza-sag">
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

