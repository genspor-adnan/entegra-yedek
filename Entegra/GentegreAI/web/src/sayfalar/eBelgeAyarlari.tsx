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
 * ARTIK YALNIZ ANA SALTER: entegrator hesabi, seri kurallari, XSLT ve tur
 * ayarlarinin tamami sube kartinin e-Belge sekmesine tasindi (kullanici) -
 * e-Belge kurulumu tek yerde toplandi. Burada kalan `ebelge.aktif` firma
 * genelidir: kapaliyken hicbir belge GIB'e gitmez.
 */
export function EBelgeAyarlari({ ayarlar, yaz }: {
  ayarlar: AyarSatiri[];
  yaz(anahtar: string, deger: string): void | Promise<void>;
}) {
  const alan = (anahtar: string, etiket: string,
                ek?: Partial<Parameters<typeof AyarAlani>[0]>) => (
    <AyarAlani anahtar={anahtar} etiket={etiket} ayarlar={ayarlar} onYaz={yaz} {...ek} />
  );

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
   * gitmez - sube kartindaki hesaplar, seriler ve tur bayraklari yazilabilir
   * ama HIC BIRI islemez. Kullanici saatlerce ayar doldurup "neden
   * gonderilmiyor" diye aramasin diye durum ustte yazili.
   */
  const anaSalter = ayarlar.find(a => a.anahtar === 'ebelge.aktif')?.deger === '1';
  return (
    <>
      {!anaSalter && (
        <div className="bilgi-kutusu" style={{ marginTop: 8 }}>
          <b>e-Belge kapalı.</b> Aşağıdaki ayarlar kaydedilir ama hiçbir belge
          GİB'e gönderilmez ve fatura/irsaliye numarası her zaman
          <b> Belge No</b> şablonundan verilir. Açmak için aşağıdaki
          “e-Belge kullanımda” kutusunu işaretleyin.
        </div>
      )}

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

      <div className="not">
        Entegratör hesabı, seri kuralları, XSLT şablonları ve tür ayarları
        (e-Fatura · e-Arşiv · e-İrsaliye · e-SMM) artık
        <b> Yönetim › Firma Bilgileri</b> → şubeyi açın →
        <b> e-Belge</b> sekmesinde. Burada yalnızca <b>ana şalter</b> kaldı:
        kapalıyken hiçbir belge GİB'e gitmez.
        <b> Alan Eşleştirme</b> tablosu henüz taşınmadı.
      </div>
    </>
  );
}
