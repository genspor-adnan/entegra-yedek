import { useEffect, useState } from 'react';
import { AyarAlani } from '../bilesenler/AyarAlani';
import { api } from '../api/istemci';
import { type AyarSatiri, type ListeSatiri } from '../api/sozlesme';

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
  /** Hangi subenin hangi entegratorle/ortamla gonderdigi - salt gorunum (171).
      Duzenleme sube kartinda; burada ozet olmasa kullanici ayar ekranina gelip
      "e-Belge nerede kuruluyor" sorusuna cevap bulamazdi. */
  const [mukellefOzet, setMukellefOzet] = useState<ListeSatiri[]>([]);
  useEffect(() => {
    api.liste('sube', { boyut: 100, sirala: [{ alan: 'varsayilan', yon: 'desc' }] })
       .then(y => setMukellefOzet(y.satirlar)).catch(() => {});
  }, []);
  /**
   * ANA SALTER (kullanici): `ebelge.aktif` kapaliyken hicbir belge GIB'e
   * gitmez - alt sekmelerdeki adresler, seriler ve tur bayraklari yazilabilir
   * ama HIC BIRI islemez. Kullanici saatlerce ayar doldurup "neden
   * gonderilmiyor" diye aramasin diye durum ustte yazili.
   */
  const anaSalter = ayarlar.find(a => a.anahtar === 'ebelge.aktif')?.deger === '1';
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
            </div>
          </div>

          {/* MUKELLEF BILGILERI SUBEDE (171): entegrator hesabi mukellefe aittir,
              ayri VKN'li sube ayri kullanici/sifre ile baglanir. Burada firma
              geneli tek hesap tutulsaydi cok mukellefli kurulum imkansizdi.
              Ana salter burada kaliyor: e-Belge'yi tumden acip kapatir. */}
          <div className="kagrup">
            <h6>Mükellef Hesabı</h6>
            <div className="not">
              Entegratör, kullanıcı/şifre, test ortamı ve mükellefiyet bilgileri
              artık <b>şube kaydında</b> tutuluyor:
              <b> Yönetim › Firma Bilgileri</b> → şubeyi açın →
              <b> e-Belge</b> sekmesi. Böylece ayrı VKN’li şube kendi entegratör
              hesabıyla, merkezin kimliğini kullanan şube merkezin hesabıyla gönderir.
            </div>
            {mukellefOzet.length > 0 && (
              <table className="grid" style={{ marginTop: 8 }}>
                <thead>
                  <tr><th>Şube</th><th>Ünvan</th><th>VKN</th><th>Entegratör</th>
                      <th style={{ textAlign: 'center' }}>Ortam</th></tr>
                </thead>
                <tbody>
                  {mukellefOzet.map(m => (
                    <tr key={String(m.id)}>
                      <td>{String(m.ad ?? '')}</td>
                      <td>{String(m.unvan ?? '')}</td>
                      <td>{String(m.vkno ?? '')}</td>
                      <td>{String(m.entegratorAdi ?? '—')}</td>
                      <td style={{ textAlign: 'center' }}>
                        <span className={`rozet ${Number(m.testOrtami) === 1 ? 'uyari' : 'ok'}`}>
                          {Number(m.testOrtami) === 1 ? 'TEST' : 'Üretim'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </>
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
        <b>Seri Kuralları</b> ve <b>XSLT Şablonları</b> artık
        <b> Yönetim › Firma Bilgileri › e-Belge</b> sekmesinde — ikisi de
        mükellefin gönderim kurulumunun parçası. <b>Alan Eşleştirme</b> tablosu
        henüz taşınmadı.
      </div>
    </>
  );
}
