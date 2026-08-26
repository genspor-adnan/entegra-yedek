import { useState } from 'react';
import { AyarAlani } from '../bilesenler/AyarAlani';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import { api } from '../api/istemci';
import { hataMetni, type AyarSatiri, type ListeSatiri } from '../api/sozlesme';

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
              {alan('ebelge.entegrator', 'Entegratör', { tip: 'metin', genis: true })}
            </div>
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
