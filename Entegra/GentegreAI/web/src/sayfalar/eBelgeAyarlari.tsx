import { AyarAlani } from '../bilesenler/AyarAlani';
import type { AyarSatiri } from '../api/sozlesme';

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
 */
export function EBelgeAyarlari({ ayarlar, yaz }: {
  ayarlar: AyarSatiri[];
  yaz(anahtar: string, deger: string): void | Promise<void>;
}) {
  const alan = (anahtar: string, etiket: string,
                ek?: Partial<Parameters<typeof AyarAlani>[0]>) => (
    <AyarAlani anahtar={anahtar} etiket={etiket} ayarlar={ayarlar} onYaz={yaz} {...ek} />
  );

  return (
    <>
      <div className="kagrup">
        <h6>Entegratör Bağlantısı</h6>
        <div className="alan-izgara tek-sutun ayar-formu">
          {alan('ebelge.aktif', 'e-Belge kullanımda', { tip: 'mantik' })}
          {alan('ebelge.entegrator', 'Entegratör', { tip: 'metin', genis: true })}
          {alan('ebelge.vkn', 'Vergi / kimlik no', { tip: 'metin' })}
          {alan('ebelge.kullanici', 'Kullanıcı', { tip: 'metin' })}
          {alan('ebelge.sifre', 'Şifre', { tip: 'parola' })}
        </div>
        <div className="not">
          Şifre sunucuda <b>düz metin</b> saklanır; yalnızca ekranda gizlenir.
          Bu hesabın e-Belge dışında bir yetkisi olmamalı.
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
          Canlıya geçerken bu kutuyu kapatmayı unutmayın.
        </div>
      </div>

      <div className="kagrup">
        <h6>e-Fatura</h6>
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

      <div className="kagrup">
        <h6>e-Arşiv</h6>
        <div className="alan-izgara tek-sutun ayar-formu">
          {alan('earsiv.aktif', 'e-Arşiv aktif', { tip: 'mantik' })}
          {alan('earsiv.uretim_url', 'Üretim (giden) adresi', { tip: 'metin', genis: true })}
          {alan('earsiv.gelen_url', 'Üretim (gelen) adresi', { tip: 'metin', genis: true })}
          {alan('earsiv.test_url', 'Test (giden) adresi', { tip: 'metin', genis: true })}
          {alan('earsiv.sabit_notlar', 'Sabit notlar', { tip: 'uzunMetin' })}
        </div>
      </div>

      <div className="kagrup">
        <h6>e-İrsaliye</h6>
        <div className="alan-izgara tek-sutun ayar-formu">
          {alan('eirsaliye.aktif', 'e-İrsaliye aktif', { tip: 'mantik' })}
          {alan('eirsaliye.gelen_al', 'Gelen irsaliyeleri al', { tip: 'mantik' })}
          {alan('eirsaliye.gib_alias', 'GİB portal adresi (alias)', { tip: 'metin', genis: true })}
          {alan('eirsaliye.uretim_url', 'Üretim servis adresi', { tip: 'metin', genis: true })}
          {alan('eirsaliye.test_url', 'Test servis adresi', { tip: 'metin', genis: true })}
          {alan('eirsaliye.sabit_notlar', 'Sabit notlar', { tip: 'uzunMetin' })}
        </div>
      </div>

      <div className="kagrup">
        <h6>e-Serbest Meslek Makbuzu</h6>
        <div className="alan-izgara tek-sutun ayar-formu">
          {alan('esmm.aktif', 'e-SMM aktif', { tip: 'mantik' })}
          {alan('esmm.uretim_url', 'Üretim servis adresi', { tip: 'metin', genis: true })}
          {alan('esmm.test_url', 'Test servis adresi', { tip: 'metin', genis: true })}
          {alan('esmm.sabit_notlar', 'Sabit notlar', { tip: 'uzunMetin' })}
        </div>
      </div>

      <div className="not">
        <b>Henüz taşınmadı:</b> XSLT şablon seçimleri (belge şablonu deposu
        gerekiyor), “Seri Kuralları” ve “Alan Eşleştirme” tabloları — bunlar
        tek değerli ayar değil, satırlı tanımlar; kendi ekranlarıyla gelecek.
      </div>
    </>
  );
}
