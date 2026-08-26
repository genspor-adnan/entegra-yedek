import { useEffect, useRef, useState } from 'react';
import { AyarAlani } from '../bilesenler/AyarAlani';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import { Modal } from '../bilesenler/Modal';
import { api } from '../api/istemci';
import { hataMetni, type AyarSatiri, type EntegratorSecenegi, type ListeSatiri } from '../api/sozlesme';

/**
 * e-BELGE AYARLARI (Yönetim › Ayarlar › Satış Belgeleri › e-Belge).
 *
 * Delphi'deki "Opsiyonlar › Fatura › E-Belge" sekmesinin karsiligi
 * (UOpsiyonFatura). Orada opsiyonlar GENINI'de negatif kodlarla duruyordu
 * (-24030, -24031...); burada `public.referans` anahtarlariyla:
 *
 *     ebelge.*     entegrator baglantisi (tum e-belge turleri icin ORTAK)
 *     efatura.*    e-Fatura
 *     earsiv.*     e-Arsiv
 *     eirsaliye.*  e-Irsaliye
 *     esmm.*       e-Serbest Meslek Makbuzu
 *
 * ALIS tarafinda YOK: gelen belgeyi GIB'e biz gondermeyiz. "Gelen ... al"
 * kutulari burada, cunku ayni entegrator baglantisini kullanirlar.
 *
 * TASINMAYANLAR (ayri altyapi ister, bu ekranin disinda):
 *   - XSLT sablon secimleri (Delphi'de DOKUMLER tablosundan gelen combo) -
 *     GentegreAI'de belge sablonu deposu henuz yok,
 *   - "Seri Kurallari" ve "Alan Eslestirme" gridleri - satirli tanimlar,
 *     ayar degil; kendi kartlarini isterler.
 *
 * Bolumler ALT SEKME (kullanici): alti bolum alt alta ~30 alan ediyordu, ekran
 * surekli kaydiriliyordu. Her belge turu kendi sekmesinde durur; entegrator
 * bilgisi ve test ortami ayri, cunku ikisi TUM turler icin ortaktir.
 */
const BOLUMLER = [
  // Test ortami AYRI SEKME DEGIL (kullanici): Mükellef bilgisinin yanindaki
  //   kutuda duruyor - ikisi birlikte "hangi kimlikle, hangi ortama" sorusunu
  //   cevapliyor, ayri sekmelerde bakmak gerekiyordu.
  { anahtar: 'baglanti',  baslik: 'Entegratör' },
  // Seri bilgileri belge turlerinin SOLUNDA (kullanici): once "hangi seriyle
  //   kesilecek", sonra tur bazli servis ayarlari.
  { anahtar: 'seri',      baslik: 'Seri Bilgileri' },
  { anahtar: 'xslt',      baslik: 'XSLT' },
  { anahtar: 'efatura',   baslik: 'e-Fatura' },
  { anahtar: 'earsiv',    baslik: 'e-Arşiv' },
  { anahtar: 'eirsaliye', baslik: 'e-İrsaliye' },
  { anahtar: 'esmm',      baslik: 'e-SMM' },
] as const;

export function EBelgeAyarlari({ ayarlar, yaz }: {
  ayarlar: AyarSatiri[];
  yaz(anahtar: string, deger: string): void | Promise<void>;
}) {
  const alan = (anahtar: string, etiket: string,
                ek?: Partial<Parameters<typeof AyarAlani>[0]>) => (
    <AyarAlani anahtar={anahtar} etiket={etiket} ayarlar={ayarlar} onYaz={yaz} {...ek} />
  );

  const [bolum, setBolum] = useState<string>('baglanti');
  /** Entegrator listesi KATALOGDAN gelir (167) - ekrana gomulu liste tutulmaz. */
  const [entegratorler, setEntegratorler] = useState<EntegratorSecenegi[]>([]);
  useEffect(() => {
    api.entegratorler().then(y => setEntegratorler(y.entegratorler)).catch(() => {});
  }, []);
  const seciliEntegrator = entegratorler.find(
    e => e.kod === ayarlar.find(a => a.anahtar === 'ebelge.entegrator')?.deger);
  /**
   * ANA SALTER (kullanici): `ebelge.aktif` kapaliyken hicbir belge GIB'e
   * gitmez - alt sekmelerdeki adresler, seriler ve tur bayraklari yazilabilir
   * ama HIC BIRI islemez. Kullanici saatlerce ayar doldurup "neden
   * gonderilmiyor" diye aramasin diye durum ustte yazili.
   */
  const anaSalter = ayarlar.find(a => a.anahtar === 'ebelge.aktif')?.deger === '1';
  /** Acik seri kurali karti ("yeni" = ekleme). */
  const [seriKart, setSeriKart] = useState<number | 'yeni' | null>(null);
  const [seriYenile, setSeriYenile] = useState(0);
  /** Gridde secili kural - Duzenle/Sil bunu kullanir. */
  const [seciliSeri, setSeciliSeri] = useState<ListeSatiri | null>(null);
  const [seriHata, setSeriHata] = useState<string | null>(null);
  /** XSLT sablonlari - seri kurallariyla ayni desen. */
  /** XSLT: sablonlar `dokuman` deposunda (160) - ayri tablo yok. */
  const [xsltYenile, setXsltYenile] = useState(0);
  const [seciliXslt, setSeciliXslt] = useState<ListeSatiri | null>(null);
  /**
   * EKLEME FORMU (kullanici): "+ ya basinca klasorden dokuman secsin, adini ad
   * olarak kullansin ve ekleme formunu acsin; bilgileri orada girip kaydet
   * deyince bir satir olarak eklesin."
   *
   * Tur/yon secicileri baslikta DEGIL formda: yukleme oradan yapiliyor,
   * baslikta durmalari "hangi secim neyi etkiliyor" belirsizligi yaratiyordu.
   */
  const [xsltForm, setXsltForm] = useState<
    { dosya?: File; id?: number; eskiTur?: number;
      ad: string; tur: number; yon: number; varsayilan: boolean } | null>(null);
  const dosyaGirdisi = useRef<HTMLInputElement | null>(null);

  const xsltSil = async () => {
    if (!seciliXslt) return;
    if (!window.confirm(`"${seciliXslt.ad ?? ''}" şablonu silinecek. Onaylıyor musunuz?`)) return;
    setSeriHata(null);
    try {
      await api.dokumanSil('ebelge-xslt', Number(seciliXslt.turKodu ?? 0), Number(seciliXslt.id));
      setSeciliXslt(null);
      setXsltYenile(t => t + 1);
    } catch (h) { setSeriHata(hataMetni(h)) }
  };

  /** Klasorden dosya secildi: formu DOSYA ADIYLA doldurup ac - kayit sonra. */
  const xsltDosyaSecildi = (dosya: File | undefined) => {
    if (!dosya) return;
    setSeriHata(null);
    setXsltForm({ dosya, ad: dosya.name, tur: 1, yon: 2, varsayilan: false });
  };

  /** Secili satiri formda ac - dosya degismez, yalniz bilgileri duzenlenir. */
  const xsltDuzenle = () => {
    if (!seciliXslt) return;
    const tur = Number(seciliXslt.turKodu ?? 0);
    setSeriHata(null);
    setXsltForm({
      id: Number(seciliXslt.id), eskiTur: tur,
      ad: String(seciliXslt.ad ?? ''),
      tur: tur || 1,
      yon: String(seciliXslt.yon) === 'Gelen' ? 1 : 2,
      varsayilan: Boolean(seciliXslt.varsayilan),
    });
  };

  /** Yeni sablonu ekler ya da acik satiri gunceller. */
  const xsltKaydet = async () => {
    if (!xsltForm) return;
    setSeriHata(null);
    try {
      if (xsltForm.id) {
        await api.dokumanDuzenle('ebelge-xslt', xsltForm.eskiTur ?? xsltForm.tur, xsltForm.id,
          xsltForm.ad.trim(), '',
          { kaynakId: xsltForm.tur, yon: xsltForm.yon, varsayilan: xsltForm.varsayilan });
      } else if (xsltForm.dosya) {
        // Ad degistirildiyse dosyayi o adla gonder - satirin adi dosya adindan gelir.
        const dosya = xsltForm.ad.trim() && xsltForm.ad !== xsltForm.dosya.name
          ? new File([xsltForm.dosya], xsltForm.ad.trim(), { type: xsltForm.dosya.type })
          : xsltForm.dosya;
        await api.dokumanYukle('ebelge-xslt', xsltForm.tur, dosya, xsltForm.varsayilan, xsltForm.yon);
      }
      setXsltForm(null);
      setSeciliXslt(null);
      setXsltYenile(t => t + 1);
    } catch (h) { setSeriHata(hataMetni(h)) }
  };

  /**
   * Secili sablonu diske kaydet. Icerik yetkili istekle cekilir (blob URL);
   * dosya adi sablonun adidir, uzantisi yoksa .xslt eklenir.
   */
  const xsltIndir = async () => {
    if (!seciliXslt) return;
    setSeriHata(null);
    try {
      const url = await api.dokumanIcerikUrl(Number(seciliXslt.id));
      const ad = String(seciliXslt.ad ?? 'sablon');
      const bag = document.createElement('a');
      bag.href = url;
      bag.download = /\.(xsl|xslt|xml)$/i.test(ad) ? ad : `${ad}.xslt`;
      document.body.appendChild(bag);
      bag.click();
      bag.remove();
      // Blob URL'i birak - yoksa sekme kapanana kadar bellekte kalir.
      setTimeout(() => URL.revokeObjectURL(url), 10_000);
    } catch (h) { setSeriHata(hataMetni(h)) }
  };

  const seriSil = async () => {
    if (!seciliSeri) return;
    const ad = `${seciliSeri.seri ?? ''}`.trim();
    if (!window.confirm(`"${ad}" seri kuralı silinecek. Onaylıyor musunuz?`)) return;
    setSeriHata(null);
    try {
      await api.kartSil('ebelge-seri', Number(seciliSeri.id));
      setSeciliSeri(null);
      setSeriYenile(t => t + 1);
    } catch (h) { setSeriHata(hataMetni(h)) }
  };

  return (
    <>
      {/* Ikinci seviye sekme cubugu - ana sekmelerden (Genel / e-Belge) daha
          kucuk cizilir ki hangisinin ust seviye oldugu karismasin. */}
      <div className="katab alt">
        {BOLUMLER.map(b => (
          <div key={b.anahtar}
               className={`kat${b.anahtar === bolum ? ' on' : ''}`}
               onClick={() => setBolum(b.anahtar)}>
            {b.baslik}
          </div>
        ))}
      </div>

      {!anaSalter && (
        <div className="bilgi-kutusu" style={{ marginTop: 8 }}>
          <b>e-Belge kapalı.</b> Aşağıdaki ayarlar kaydedilir ama hiçbir belge
          GİB'e gönderilmez ve fatura/irsaliye numarası her zaman
          <b> Belge No</b> şablonundan verilir. Açmak için <b>Entegratör</b>
          sekmesindeki “e-Belge kullanımda” kutusunu işaretleyin.
        </div>
      )}

      {bolum === 'baglanti' && (
        <>
          <div className="kagrup">
            <div className="alan-izgara tek-sutun ayar-formu">
              {alan('ebelge.aktif', 'e-Belge kullanımda', { tip: 'mantik' })}
              {alan('ebelge.entegrator', 'Entegratör', {
                tip: 'secenek',
                secenekler: entegratorler.map(e => ({ deger: e.kod, ad: e.ad })),
              })}
            </div>
            {/* Secili entegratorun gonderim ureteci yoksa bunu KAYIT ANINDA soyle:
                yoksa kullanici tum ayarlari doldurup gonderimde ogrenir. */}
            {seciliEntegrator && !seciliEntegrator.gonderilebilir && (
              <div className="hata-kutusu">
                {seciliEntegrator.ad} için gönderim gövdesi üreteci henüz yazılmadı.
                Ayarlar ve seriler kaydedilir, belge hazırlanır; gönderim adımı
                bu entegratör için çalışmaz.
              </div>
            )}
          </div>

          {/* Mükellef ve Test Ortamı YAN YANA, esit hizada (kullanici):
              "hangi kimlikle" ve "hangi ortama" birlikte okunur. */}
          <div className="kasira">
            <div className="kagrup">
              <h6>Mükellef</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {alan('ebelge.vkn', 'Vergi / kimlik no', { tip: 'metin' })}
                {alan('ebelge.kullanici', 'Kullanıcı', { tip: 'metin' })}
                {alan('ebelge.sifre', 'Şifre', { tip: 'parola' })}
              </div>
              <div className="not">
                Şifre sunucuda <b>düz metin</b> saklanır; yalnızca ekranda gizlenir.
              </div>
            </div>

            <div className="kagrup">
              <h6>Test Ortamı</h6>
              <div className="alan-izgara tek-sutun ayar-formu">
                {/* Test aciksa belgeler GIB'e degil entegratorun test servisine gider. */}
                {alan('ebelge.test_aktif', 'Test ortamı aktif', { tip: 'mantik' })}
                {alan('ebelge.test_kullanici', 'Test kullanıcı', { tip: 'metin' })}
                {alan('ebelge.test_sifre', 'Test şifre', { tip: 'parola' })}
              </div>
              <div className="not">
                Test açıkken kesilen belgeler <b>resmî değildir</b> — GİB'e ulaşmaz.
              </div>
            </div>
          </div>
        </>
      )}

      {bolum === 'seri' && (
        <div className="kagrup">
          {/* Delphi'deki "Seri Bilgileri" gridi (UOpsiyonFatura > TabSeri).
              Belgenin IC numarasi degil, GIB'e giden SERI kodu. */}
          {/* Ikonlar basligin HEMEN saginda (kullanici) - saga yaslanmis
              halde baslikla arasindaki bosluk ikisini ayri iki ogeye
              cevirmisti. */}
          <div className="numaralama-bas bitisik">
            <h6>Seri Kuralları</h6>
            {/* Ekle / Duzenle / Sil - baslik seridinin saginda, yalniz IKON
                (kullanici). Duzenle ve Sil satir secimi ister; secim yokken
                pasif ve sebebi title'da. */}
            <span className="baslik-eylem">
              <button className="d bir ikon-dugme" title="Yeni seri kuralı"
                      onClick={() => setSeriKart('yeni')}>＋</button>
              <button className="d ikon-dugme" disabled={!seciliSeri}
                      title={seciliSeri ? 'Seçili kuralı düzenle' : 'Önce satır seçin'}
                      onClick={() => seciliSeri && setSeriKart(Number(seciliSeri.id))}>✎</button>
              <button className="d teh ikon-dugme" disabled={!seciliSeri}
                      title={seciliSeri ? 'Seçili kuralı sil' : 'Önce satır seçin'}
                      onClick={() => { void seriSil() }}>🗑</button>
            </span>
          </div>
          {seriHata && <div className="hata-kutusu">{seriHata}</div>}
          <GenGrid
            key={`ebelge-seri-${seriYenile}`}
            kaynak="ebelge-seri"
            gomulu
            seritGizli
            boyut={25}
            onSatirAc={satir => setSeriKart(Number(satir.id))}
            onSecimDegisti={setSeciliSeri}
          />
          <div className="not">
            Belge gönderilirken bu kurallardan <b>uyanı</b> seçilir: önce
            kullanıcıya özel, sonra senaryoya özel, sonra genel kural; eşitlikte
            <b> Sıra</b> küçük olan kazanır. Senaryo ve Kullanıcı boş bırakılırsa
            kural her senaryoda / her kullanıcıda geçerlidir.
          </div>
        </div>
      )}

      {seriKart !== null && (
        <GenForm
          kaynak="ebelge-seri"
          id={seriKart}
          baslik="e-Belge Seri Kuralı"
          onKapat={() => setSeriKart(null)}
          onKaydedildi={() => { setSeriKart(null); setSeriYenile(t => t + 1) }}
        />
      )}

      {bolum === 'xslt' && (
        <div className="kagrup">
          {/* Sablonlar merkezi `dokuman` deposunda (160): ad, boyut, hash,
              varsayilan ve yukleme/indirme altyapisi orada hazir. */}
          <div className="numaralama-bas bitisik">
            <h6>XSLT Şablonları</h6>
            <span className="baslik-eylem">
              {/* Dosya secici gizli: "＋" ona basar, secilen DOSYANIN ADI
                  forma ad olarak dolar. */}
              <input ref={dosyaGirdisi} type="file" accept=".xsl,.xslt,.xml" hidden
                     onChange={e => {
                       xsltDosyaSecildi(e.target.files?.[0]);
                       e.target.value = '';        // ayni dosya tekrar secilebilsin
                     }} />
              <button className="d bir ikon-dugme" title="Klasörden şablon seç"
                      onClick={() => dosyaGirdisi.current?.click()}>＋</button>
              <button className="d ikon-dugme" disabled={!seciliXslt}
                      title={seciliXslt ? 'Seçili şablonun bilgilerini düzenle' : 'Önce satır seçin'}
                      onClick={xsltDuzenle}>✎</button>
              <button className="d teh ikon-dugme" disabled={!seciliXslt}
                      title={seciliXslt ? 'Seçili şablonu sil' : 'Önce satır seçin'}
                      onClick={() => { void xsltSil() }}>🗑</button>
              <button className="d ikon-dugme" disabled={!seciliXslt}
                      title={seciliXslt ? 'Seçili şablonu dosyaya kaydet' : 'Önce satır seçin'}
                      onClick={() => { void xsltIndir() }}>💾</button>
            </span>
          </div>
          <GenGrid
            key={`ebelge-xslt-${xsltYenile}`}
            kaynak="ebelge-xslt"
            gomulu
            seritGizli
            boyut={25}
            onSecimDegisti={setSeciliXslt}
            onSatirAc={satir => {
              setSeciliXslt(satir);
              const tur = Number(satir.turKodu ?? 0);
              setXsltForm({
                id: Number(satir.id), eskiTur: tur,
                ad: String(satir.ad ?? ''), tur: tur || 1,
                yon: String(satir.yon) === 'Gelen' ? 1 : 2,
                varsayilan: Boolean(satir.varsayilan),
              });
            }}
          />
          <div className="not">
            Belge GİB'e XML olarak gider; insanın gördüğü görüntü bu şablon
            uygulanarak üretilir ve gönderimde XML'in <b>içine gömülür</b>.
            <b> ＋</b> ile klasörden seçtiğiniz dosyanın adı şablon adı olur;
            <b> 💾</b> seçili şablonu diske kaydeder. Her belge türü ve yön için
            <b> bir</b> şablon varsayılan olabilir.
          </div>
        </div>
      )}

      {xsltForm && (
        <Modal
          baslik={xsltForm.id ? "XSLT Şablonu" : "XSLT Şablonu Ekle"}
          dar
          onKapat={() => setXsltForm(null)}
          alt={<>
            <button className="d kapat-dugmesi" onClick={() => setXsltForm(null)}>Vazgeç</button>
            <button className="d bir" disabled={!xsltForm.ad.trim()}
                    onClick={() => { void xsltKaydet() }}>Kaydet</button>
          </>}
        >
          <div className="kagrup">
            <div className="alan-izgara tek-sutun ayar-formu">
              <label className="alan">
                <span className="etiket zorunlu-isaret">Şablon Adı</span>
                <span className="ikili">
                  <input className="genis-deger" value={xsltForm.ad}
                         onChange={e => setXsltForm({ ...xsltForm, ad: e.target.value })} />
                </span>
              </label>
              <label className="alan">
                <span className="etiket">e-Belge Türü</span>
                <span className="ikili">
                  <select value={xsltForm.tur}
                          onChange={e => setXsltForm({ ...xsltForm, tur: Number(e.target.value) })}>
                    <option value={1}>e-Fatura</option>
                    <option value={2}>e-Arşiv</option>
                    <option value={7}>e-İrsaliye</option>
                    <option value={8}>e-SMM</option>
                  </select>
                </span>
              </label>
              <label className="alan">
                <span className="etiket">Yön</span>
                <span className="ikili">
                  <select value={xsltForm.yon}
                          onChange={e => setXsltForm({ ...xsltForm, yon: Number(e.target.value) })}>
                    <option value={2}>Giden</option>
                    <option value={1}>Gelen</option>
                  </select>
                </span>
              </label>
              <label className="alan ayar-onay">
                <input type="checkbox" checked={xsltForm.varsayilan}
                       onChange={e => setXsltForm({ ...xsltForm, varsayilan: e.target.checked })} />
                <span className="etiket">Bu tür ve yön için varsayılan olsun</span>
              </label>
            </div>
          </div>
        </Modal>
      )}

      {bolum === 'efatura' && (
        <div className="kagrup">
          <div className="alan-izgara tek-sutun ayar-formu">
            {alan('efatura.gelen_al', 'Gelen faturaları al', { tip: 'mantik' })}
            {alan('efatura.senaryo', 'Varsayılan senaryo', {
              tip: 'secenek',
              secenekler: [
                { deger: '1', ad: 'Temel' },
                { deger: '2', ad: 'Ticari' },
                { deger: '8', ad: 'İlaç / Tıbbi Cihaz' },
              ],
            })}
            {alan('efatura.ihracat_gonder', 'İhracat faturaları da gönderilsin', { tip: 'mantik' })}
            {alan('efatura.uretim_url', 'Üretim servis adresi', { tip: 'metin', genis: true })}
            {alan('efatura.test_url', 'Test servis adresi', { tip: 'metin', genis: true })}
            {alan('efatura.sabit_notlar', 'Sabit notlar', { tip: 'uzunMetin' })}
          </div>
        </div>
      )}

      {bolum === 'earsiv' && (
        <div className="kagrup">
          <div className="alan-izgara tek-sutun ayar-formu">
            {alan('earsiv.aktif', 'e-Arşiv aktif', { tip: 'mantik' })}
            {alan('earsiv.uretim_url', 'Üretim (giden) adresi', { tip: 'metin', genis: true })}
            {alan('earsiv.gelen_url', 'Üretim (gelen) adresi', { tip: 'metin', genis: true })}
            {alan('earsiv.test_url', 'Test (giden) adresi', { tip: 'metin', genis: true })}
            {alan('earsiv.sabit_notlar', 'Sabit notlar', { tip: 'uzunMetin' })}
          </div>
        </div>
      )}

      {bolum === 'eirsaliye' && (
        <div className="kagrup">
          <div className="alan-izgara tek-sutun ayar-formu">
            {alan('eirsaliye.aktif', 'e-İrsaliye aktif', { tip: 'mantik' })}
            {alan('eirsaliye.gelen_al', 'Gelen irsaliyeleri al', { tip: 'mantik' })}
            {alan('eirsaliye.gib_alias', 'GİB portal adresi (alias)', { tip: 'metin', genis: true })}
            {alan('eirsaliye.uretim_url', 'Üretim servis adresi', { tip: 'metin', genis: true })}
            {alan('eirsaliye.test_url', 'Test servis adresi', { tip: 'metin', genis: true })}
            {alan('eirsaliye.sabit_notlar', 'Sabit notlar', { tip: 'uzunMetin' })}
          </div>
        </div>
      )}

      {bolum === 'esmm' && (
        <div className="kagrup">
          <div className="alan-izgara tek-sutun ayar-formu">
            {alan('esmm.aktif', 'e-SMM aktif', { tip: 'mantik' })}
            {alan('esmm.uretim_url', 'Üretim servis adresi', { tip: 'metin', genis: true })}
            {alan('esmm.test_url', 'Test servis adresi', { tip: 'metin', genis: true })}
            {alan('esmm.sabit_notlar', 'Sabit notlar', { tip: 'uzunMetin' })}
          </div>
        </div>
      )}

      <div className="not">
        <b>Henüz taşınmadı:</b> XSLT şablon seçimleri (belge şablonu deposu
        gerekiyor), “Seri Kuralları” ve “Alan Eşleştirme” tabloları — bunlar
        tek değerli ayar değil, satırlı tanımlar; kendi ekranlarıyla gelecek.
      </div>
    </>
  );
}
