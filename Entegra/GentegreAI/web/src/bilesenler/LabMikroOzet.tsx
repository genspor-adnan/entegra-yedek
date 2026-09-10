import type { EkSekmeBaglami } from './GenForm';

/**
 * MIKROBIYOLOJI KATALOG KARTLARININ "Tanım" SEKMESI.
 *
 * Uc mockup'ta da (Ekranlar/Lab/besiyeri_karti.html · organizma_karti.html ·
 * antibiyotik_karti.html) kartin ILK sekmesi bir GRID DEGIL, kartin kendi
 * alanlarindan kurulmus okunur bir OZET: "bu besiyeri kac saatte okunur",
 * "bu organizma hangi esikle anlamli", "bu ajan hangi basamakta raporlanir".
 * Uygulamada bu sekme hic yoktu; kart acilinca dogrudan bos bir detay gridi
 * geliyor, kartin ne soyledigi ancak alanlar tek tek okunarak anlasiliyordu.
 *
 * BURADA IS KURALI YOK. Gosterilen her sayi kartin KENDI alanindan ya da
 * detay satirlarinin ADEDINDEN geliyor; yanlarindaki cumleler mockup'un
 * aciklama metinleri - karar veren degil, yazilani okutan satirlar.
 *
 * Bicim mockup ailesinin ortak dili: `.kagrup` + `h6` baslik (mockup'ta
 * `.blok` + `h4`), icinde `.detay-tablo`. Yeni bir gorunum uretilmedi.
 */
/** Ozet, kartin kendi baglamiyla cizilir - ikinci bir istek atmaz. */
export type OzetBaglami = EkSekmeBaglami;

/** Kod alaninin OKUNUR karsiligi ("1" -> "Katı (agar)"); yoksa ham deger. */
function kodAdi(baglam: OzetBaglami, alan: string): string {
  const ham = baglam.deger[alan];
  if (ham === null || ham === undefined || ham === '') return '';
  const meta = baglam.meta?.alanlar.find(a => a.ad === alan);
  return meta?.kodlar?.[String(ham)] ?? String(ham);
}

function metin(baglam: OzetBaglami, alan: string): string {
  const ham = baglam.deger[alan];
  return ham === null || ham === undefined ? '' : String(ham);
}

function sayi(baglam: OzetBaglami, alan: string): number | null {
  const ham = Number(baglam.deger[alan]);
  return Number.isFinite(ham) ? ham : null;
}

/**
 * Dolu deger KALIN, bos deger `null` doner. Yer tutucuyu burasi BASMAZ:
 * satirin aciklamasi varsa "— — açıklama" gibi cift tire cikiyordu; bos
 * hucrenin "—"sini satiri cizen yer, aciklamanin olup olmadigini bilerek koyar.
 */
function ya(deger: string) {
  return deger.trim() === '' ? null : <b>{deger}</b>;
}

interface SatirTanimi {
  etiket: string;
  deger: React.ReactNode;
  /** Degerin sagindaki aciklama - mockup'taki `.sonuk` kuyrugu. */
  not?: string;
}

function OzetBlok({ baslik, sag, satirlar }:
                  { baslik: string; sag?: string; satirlar: SatirTanimi[] }) {
  return (
    <div className="kagrup lab-tanim-blok">
      <h6>{baslik}{sag && <span className="sonuk sag-ek">{sag}</span>}</h6>
      <table className="detay-tablo">
        <tbody>
          {satirlar.map(s => (
            <tr key={s.etiket}>
              <td className="lab-tanim-etiket">{s.etiket}</td>
              <td>
                {s.deger ?? (s.not ? null : <span className="sonuk">—</span>)}
                {s.not && (
                  <span className="sonuk">{s.deger ? ' — ' : ''}{s.not}</span>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}

/** Besiyeri: mockup'un "🔎 Okuma kuralı" bloku. */
function BesiyeriOzeti(b: OzetBaglami) {
  const ilk = sayi(b, 'ilkOkumaSaat');
  const son = sayi(b, 'sonOkumaSaat');
  const carpan = sayi(b, 'sayimCarpani');
  const hacim = sayi(b, 'ekimHacmiUl');
  const sicaklik = sayi(b, 'sicaklik');
  return (
    <div className="lab-tanim-satir">
      <OzetBlok baslik="🔎 Okuma kuralı" sag="kültür ekranına yansır" satirlar={[
        { etiket: 'İlk okuma',
          deger: ya(ilk ? `${ilk}. saat` : ''),
          not: 'üreme yoksa kültür kapanmaz, inkübasyona döner' },
        { etiket: 'Son okuma',
          deger: ya(son ? `${son}. saat` : ''),
          not: 'üreme yoksa "üreme olmadı" raporlanabilir' },
        { etiket: 'Sayım çarpanı',
          deger: ya(carpan ? `×${carpan}` : ''),
          not: hacim ? `${hacim} µL özeyle sayılan koloni CFU/mL'ye çevrilir`
                     : 'ekim hacmi girilmeden koloni sayımı raporlanamaz' },
        { etiket: 'Atmosfer',
          deger: ya(kodAdi(b, 'atmosfer')),
          not: sicaklik ? `${sicaklik} °C inkübasyon` : undefined },
      ]} />
      <OzetBlok baslik="ℹ️ Özet" sag="kart kuralı" satirlar={[
        { etiket: 'Tür', deger: ya(kodAdi(b, 'tur')) },
        { etiket: 'Numune tipi',
          deger: <b>{b.detaySayisi('numuneler')}</b>,
          not: 'kültür açılırken varsayılan set buradan gelir' },
        { etiket: 'Stok kartı',
          deger: ya(kodAdi(b, 'stokId')),
          not: 'bağlıysa lot/miat ve kalan adet stoktan okunur' },
        { etiket: 'KK suşu', deger: ya(metin(b, 'kkSusu')),
          not: kodAdi(b, 'kkPeriyot') || undefined },
      ]} />
    </div>
  );
}

/** Organizma: mockup'un "ℹ️ Özet" bloku (raporu belirleyen kurallar). */
function OrganizmaOzeti(b: OzetBaglami) {
  const esik = sayi(b, 'uremeEsigi');
  const birim = metin(b, 'esikBirimi');
  const skrs = metin(b, 'skrsKod');
  const snomed = metin(b, 'snomed');
  const bildirim = Number(b.deger.bildirimiZorunlu ?? 0) === 1;
  const durumSatiri = Number(b.deger.sonucSatiri ?? 0) === 1;
  return (
    <div className="lab-tanim-satir">
      <OzetBlok baslik="🦠 Raporlama kuralı" sag="kart kuralı" satirlar={[
        { etiket: 'Doğal direnç',
          deger: <b>{b.detaySayisi('direnc')}</b>,
          not: 'antibiyogramda bu ajanlar hiç sorulmaz' },
        { etiket: 'Panel',
          deger: <b>{b.detaySayisi('panel')}</b>,
          not: b.detaySayisi('panel') > 0
               ? 'panel tanımlıysa yalnız o panel çalışılır'
               : 'panel yok - antibiyotiğin genel basamağı geçerli' },
        { etiket: 'Üreme eşiği',
          deger: ya(esik ? `${esik.toLocaleString('tr-TR')} ${birim}`.trim() : ''),
          not: 'eşiğin altındaki üreme "anlamlı değil" raporlanır' },
        { etiket: 'Durum satırı',
          deger: <span className={`rozet ${durumSatiri ? 'mor' : 'gri'}`}>
                   {durumSatiri ? 'Evet' : 'Hayır'}
                 </span>,
          not: durumSatiri ? '"üreme yok" / "normal flora" gibi bir sonuç satırı'
                           : 'gerçek bir izolat' },
      ]} />
      <OzetBlok baslik="🏷 Kodlar & bildirim" sag="bildirim eşlemesi" satirlar={[
        { etiket: 'Gram / morfoloji',
          deger: ya([kodAdi(b, 'gram'), kodAdi(b, 'morfoloji')]
                      .filter(Boolean).join(' · ')) },
        { etiket: 'SKRS kodu', deger: ya(skrs), not: 'e-Nabız bildirimi' },
        { etiket: 'SNOMED CT', deger: ya(snomed), not: 'uluslararası kayıt' },
        { etiket: 'Bildirimi zorunlu',
          deger: <span className={`rozet ${bildirim ? 'uyari' : 'gri'}`}>
                   {bildirim ? 'Evet' : 'Hayır'}
                 </span>,
          not: bildirim ? 'Grup A/B listesinde' : 'Grup A/B listesinde değil' },
      ]} />
    </div>
  );
}

/** Antibiyotik: mockup'un "⚙️ Raporlama kuralları" + "ℹ️ Özet" bloklari. */
function AntibiyotikOzeti(b: OzetBaglami) {
  const yetersiz = Number(b.deger.tekBasinaYetersiz ?? 0) === 1;
  const uriner = Number(b.deger.yalnizUriner ?? 0) === 1;
  const basamak = kodAdi(b, 'basamak');
  return (
    <div className="lab-tanim-satir">
      <OzetBlok baslik="⚙️ Raporlama kuralları" sag="kart kuralı" satirlar={[
        { etiket: 'Basamak', deger: ya(basamak),
          not: 'alt basamakta duyarlı seçenek yoksa raporlanır' },
        { etiket: 'Tek başına yeterli değil',
          deger: <span className={`rozet ${yetersiz ? 'uyari' : 'gri'}`}>
                   {yetersiz ? 'Evet' : 'Hayır'}
                 </span>,
          not: yetersiz ? 'kombinasyon ajanı; üst basamağı KAPATMAZ'
                        : 'duyarlı çıkarsa üst basamağı kapatır' },
        { etiket: 'Yalnız üriner',
          deger: <span className={`rozet ${uriner ? 'mor' : 'gri'}`}>
                   {uriner ? 'Evet' : 'Hayır'}
                 </span>,
          not: uriner ? 'kan/derin doku izolatında raporlanmaz'
                      : 'her örnek tipinde anlamlı' },
        { etiket: 'Uygulama', deger: ya(kodAdi(b, 'uygulama')) },
      ]} />
      <OzetBlok baslik="ℹ️ Özet" sag="nerede kullanılıyor" satirlar={[
        { etiket: 'Grup', deger: ya(metin(b, 'grup')) },
        { etiket: 'Panel',
          deger: <b>{b.detaySayisi('paneller')}</b>,
          not: 'organizma panelinde' },
        { etiket: 'Doğal direnç',
          deger: <b>{b.detaySayisi('direnc')}</b>,
          not: 'organizmada raporlanmaz' },
        { etiket: 'ATC', deger: ya(metin(b, 'atc')), not: 'WHO ATC kodu' },
      ]} />
    </div>
  );
}

const OZETLER: Record<string, (b: OzetBaglami) => React.ReactNode> = {
  'lab-besiyeri': BesiyeriOzeti,
  'lab-organizma': OrganizmaOzeti,
  'lab-antibiyotik': AntibiyotikOzeti,
};

/** Kartın "Tanım" sekmesi; tanımsız kaynakta hiç çizilmez. */
export function LabMikroOzet({ kaynak, baglam }:
                             { kaynak: string; baglam: OzetBaglami }) {
  const ciz = OZETLER[kaynak];
  return ciz ? <>{ciz(baglam)}</> : null;
}

/** Bu kaynağın "Tanım" özeti var mı (ekran sekmeyi ona göre açar). */
export function labMikroOzetiVar(kaynak: string) {
  return kaynak in OZETLER;
}
