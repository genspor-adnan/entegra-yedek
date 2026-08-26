import { AyarAlani, useAyarlar } from '../AyarAlani';

/**
 * e-BELGE TUR AYARLARI (e-Fatura / e-Arşiv / e-İrsaliye / e-SMM).
 *
 * Ayarlar ekranindan sube kartinin e-Belge sekmesine tasindi (kullanici).
 *
 * DIKKAT - BUNLAR FIRMA GENELI: degerler `public.referans`ta durur, subeye gore
 * degismez. Kartin icinde gorunmelerinin sebebi "e-Belge kurulumunun tamami tek
 * yerde" olsun istenmesi; bir subede degistirilen deger TUM subeler icin gecerli
 * olur ve ekranda bu yaziyor.
 */
const TURLER = {
  efatura: {
    baslik: 'e-Fatura',
    alanlar: [
      { anahtar: 'efatura.gelen_al', etiket: 'Gelen faturaları al', tip: 'mantik' as const },
      { anahtar: 'efatura.senaryo', etiket: 'Varsayılan senaryo', tip: 'secenek' as const,
        secenekler: [
          { deger: '1', ad: 'Temel' },
          { deger: '2', ad: 'Ticari' },
          { deger: '8', ad: 'İlaç / Tıbbi Cihaz' },
        ] },
      { anahtar: 'efatura.ihracat_gonder', etiket: 'İhracat faturaları da gönderilsin', tip: 'mantik' as const },
      { anahtar: 'efatura.uretim_url', etiket: 'Üretim servis adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'efatura.test_url', etiket: 'Test servis adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'efatura.sabit_notlar', etiket: 'Sabit notlar', tip: 'uzunMetin' as const },
    ],
  },
  earsiv: {
    baslik: 'e-Arşiv Fatura',
    alanlar: [
      { anahtar: 'earsiv.aktif', etiket: 'e-Arşiv aktif', tip: 'mantik' as const },
      { anahtar: 'earsiv.uretim_url', etiket: 'Üretim (giden) adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'earsiv.gelen_url', etiket: 'Üretim (gelen) adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'earsiv.test_url', etiket: 'Test (giden) adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'earsiv.sabit_notlar', etiket: 'Sabit notlar', tip: 'uzunMetin' as const },
    ],
  },
  eirsaliye: {
    baslik: 'e-İrsaliye',
    alanlar: [
      { anahtar: 'eirsaliye.aktif', etiket: 'e-İrsaliye aktif', tip: 'mantik' as const },
      { anahtar: 'eirsaliye.gelen_al', etiket: 'Gelen irsaliyeleri al', tip: 'mantik' as const },
      { anahtar: 'eirsaliye.gib_alias', etiket: 'GİB portal adresi (alias)', tip: 'metin' as const, genis: true },
      { anahtar: 'eirsaliye.uretim_url', etiket: 'Üretim servis adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'eirsaliye.test_url', etiket: 'Test servis adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'eirsaliye.sabit_notlar', etiket: 'Sabit notlar', tip: 'uzunMetin' as const },
    ],
  },
  esmm: {
    baslik: 'e-SMM',
    alanlar: [
      { anahtar: 'esmm.aktif', etiket: 'e-SMM aktif', tip: 'mantik' as const },
      { anahtar: 'esmm.uretim_url', etiket: 'Üretim servis adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'esmm.test_url', etiket: 'Test servis adresi', tip: 'metin' as const, genis: true },
      { anahtar: 'esmm.sabit_notlar', etiket: 'Sabit notlar', tip: 'uzunMetin' as const },
    ],
  },
} as const;

export type EBelgeTuru = keyof typeof TURLER;

export function TurAyarlari({ tur }: { tur: EBelgeTuru }) {
  const { ayarlar, yukleniyor, hata, bilgi, yaz } = useAyarlar();
  const t = TURLER[tur];

  if (yukleniyor) return <div className="yukleniyor">Yükleniyor…</div>;

  return (
    <div className="kagrup">
      <h6>{t.baslik}</h6>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {bilgi && <div className="bilgi-kutusu">{bilgi}</div>}
      <div className="alan-izgara tek-sutun ayar-formu">
        {t.alanlar.map(a => (
          <AyarAlani key={a.anahtar}
                     anahtar={a.anahtar} etiket={a.etiket} tip={a.tip}
                     secenekler={'secenekler' in a ? a.secenekler.map(o => ({ deger: o.deger, ad: o.ad })) : undefined}
                     genis={'genis' in a ? a.genis : undefined}
                     ayarlar={ayarlar} onYaz={yaz} />
        ))}
      </div>
      {/* Sube kartinin icinde ama FIRMA GENELI - yanlis beklenti olusmasin. */}
      <div className="not">
        Bu ayarlar <b>tüm şubeler</b> için ortaktır; şubeye göre değişen bilgiler
        (entegratör hesabı, test ortamı, mükellefiyet) <b>Genel</b> sekmesindedir.
      </div>
    </div>
  );
}
