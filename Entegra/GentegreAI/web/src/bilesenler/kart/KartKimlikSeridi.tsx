import type { ReactNode } from 'react';
import type { KartAlanMeta, KartMetaYaniti } from '../../api/sozlesme';
import type { Deger } from '../kartAlanCizim';
import { type DetayDurumu, bosDetay } from '../GenDetayTablo';
import { TekKayit } from '../TekKayit';
import type { useUnvanOneki } from './useUnvanOneki';

/** Dokuman seridinde TEK HUCREDE toplanan gecerlilik alanlari (mockup). */
const GECERLILIK_ALANLARI = ['gecerliBas', 'gecerliBit'];

/** Mikro katalog kartlari: serit tek satira sigsin diye dar yerlesim. */
const LAB_MIKRO_KARTLAR = new Set(['lab-besiyeri', 'lab-organizma', 'lab-antibiyotik']);

export interface KartKimlikSeridiOzellikleri {
  kaynak: string;
  deger: Record<string, Deger>;
  meta: KartMetaYaniti | null;
  salt: boolean;
  detaylar: Record<string, DetayDurumu>;
  setDetaylar(f: (t: Record<string, DetayDurumu>) => Record<string, DetayDurumu>): void;
  /** Seritte cizilecek alanlar (Kimlik grubu ya da `seritAlanlari` sirasi). */
  kimlikAlanlari: KartAlanMeta[];
  renderAlanListesi(alanlar: KartAlanMeta[]): ReactNode;
  /** Ekran seridi baska bir kabuga (or. modal) sarabilir. */
  seritSarmalayici?(serit: ReactNode, deger: Record<string, Deger>): ReactNode;
  personelGibiKart: boolean;
  dogumYasMetni: string;
  unvanOneki: ReturnType<typeof useUnvanOneki>;
}

/**
 * KIMLIK SERIDI (mockup `.kaid`): kartin ust seridi - sekme degistikce
 * yerinde kalir, kaydin kim/ne oldugunu soyler.
 *
 * `GenForm` govdesinden ayrildi (2300 satir): serit yalniz CIZIM yapar,
 * deger/dogrulama yolu degismedi - alanlar yine `renderAlanListesi` ile,
 * yani ayni girdi bilesenleri ve ayni `alanDegistir` ile ciziliyor.
 */
export function KartKimlikSeridi({
  kaynak, deger, meta, salt, detaylar, setDetaylar, kimlikAlanlari, renderAlanListesi,
  seritSarmalayici, personelGibiKart, dogumYasMetni, unvanOneki,
}: KartKimlikSeridiOzellikleri) {
        const kimlikSeridi = (
        <div className="kaid">
          {/* AVATAR (305, kullanici: "ad soyadin soluna avatar ekle"): ad ve
              soyadin bas harfleri. Kisi kartlarinda kimin karti oldugunu tek
              bakista gosterir - hasta seridindeki desenle ayni. */}
          {kaynak === 'dis-hekim' && (() => {
            const bas = [String(deger.ad ?? ''), String(deger.soyad ?? '')]
              .map(x => x.trim()[0] ?? '').join('').toLocaleUpperCase('tr');
            return <span className="kart-avatar">{bas || '—'}</span>;
          })()}
          {/* Kisi'ye ozel: Kisi Kodu dar, Unvan genis (kullanici: "kod edit yariya dussun,
              onu unvana ekle") - idstrip'in 4 sabit alani (Kod/Unvan/Departman/Gorev). */}
          {/* Personelde ROL kimlik seridinde, DEPARTMANIN SAGINDA (kullanici);
              serit 5 sutunlu akar. Diger kartlarda serit eskisi gibi. */}
          {/* YENI kayitta da gecerli: Görev ZORUNLU ama serit yalniz mevcut
              kartta cizilince alan hic gorunmuyordu ("Görev zorunlu" hatasi
              alinip duzeltilemiyordu). */}
          {/* ADAY HASTA (266): kimlik seridinde Durum yerine KURUM - durum arac
              cubugunda rozet. Kurum taraf_hasta detayinda oldugu icin serit
              alanlarindan degil, detay durumundan besleniyor. */}
          {kaynak === 'hasta-aday' ? (() => {
            const ozluk = meta?.detaylar.find(d => d.ad === 'ozluk');
            const kurumAlan = ozluk?.alanlar.find(a => a.ad === 'kurumId');
            const satir = detaylar[ozluk?.ad ?? '']?.guncel[0] ?? {};
            return (
              <div className="alan-izgara"
                   style={{ gridTemplateColumns: 'repeat(4, minmax(0, 1fr))' }}>
                {renderAlanListesi(kimlikAlanlari)}
                {kurumAlan && ozluk && (
                  <label className="alan tip-kod">
                    <span className="etiket">{kurumAlan.baslik}</span>
                    <select value={String(satir.kurumId ?? '')} disabled={salt}
                            onChange={e => setDetaylar(t => {
                              const d = t[ozluk.ad] ?? { ilk: [], guncel: [] };
                              const yeni = { ...(d.guncel[0] ?? {}), kurumId: e.target.value };
                              return { ...t, [ozluk.ad]: { ...d, guncel: [yeni, ...d.guncel.slice(1)] } };
                            })}>
                      <option value="">—</option>
                      {kurumAlan.kodlar && Object.entries(kurumAlan.kodlar)
                        .map(([k, v]) => <option key={k} value={k}>{v}</option>)}
                    </select>
                  </label>
                )}
              </div>
            );
          })() : kaynak === 'dis-hekim' ? (
            /* DIS HEKIM (305/306) serit duzeni: avatar · Ünvan · Ad · Soyad ·
               Kod · Bölüm · Temsilci · Durum. Temsilci BIZIM personelimiz (bu
               hekimle ilgilenen kisi), dis hekimin kendi kurumundan biri degil.
               BOLUM KODUN SAGINDA (577, kullanici): serit SABIT alan listesi -
               alani katalogda tanimlamak yetmiyordu, burada acikca cizilmeyen
               Kimlik alani hic gorunmuyor. Goruntuleme/lab merkezinde
               basvurunun bolumu bu alandan cozulur. */
            /* Ünvan ve Kod YARIM sutun (kullanici): kisa degerler - "Prof.Dr."
               ve "DR-0042" tam sutunda bos yer birakiyordu. Ad/Soyad, Bölüm ve
               Temsilci tam sutun kalir. */
            <div className="alan-izgara"
                 style={{ gridTemplateColumns: '0.5fr 1fr 1fr 0.5fr 1fr 1fr 0.5fr' }}>
              <label className="alan tip-kod">
                <span className="etiket">Ünvan</span>
                <select value={unvanOneki.onek} disabled={salt}
                        onChange={e => unvanOneki.setOnek(e.target.value)}>
                  <option value="">—</option>
                  {unvanOneki.secenekler.map(o => <option key={o} value={o}>{o}</option>)}
                </select>
              </label>
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'ad'))}
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'soyad'))}
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'kod'))}
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'departman'))}
              {renderAlanListesi((meta?.alanlar ?? []).filter(a => a.ad === 'temsilci'))}
              {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'durum'))}
            </div>
          ) : personelGibiKart ? (
            <div className="alan-izgara"
                 style={{ gridTemplateColumns: 'repeat(5, minmax(0, 1fr))' }}>
              {/* HASTADA "Dosya No" EDITI HIC YOK (kullanici): numara
                  OTOMATIK verilir - yeni kayitta da sorulmaz. Kayitli kartta
                  numara basliktan okunur; duzenlenecek bir alan degil,
                  seritte yer kapliyordu. */}
              {renderAlanListesi(kimlikAlanlari.filter(a =>
                ['kod', 'ad', 'soyad', 'departman'].includes(a.ad)
                && !(kaynak === 'hasta' && a.ad === 'kod')))}
              {/* GOREV seritte YALNIZ PERSONELDE (kullanici: "hasta kartında en
                  üstte görev kaldır"): hastanin gorevi yoktur - alan katalogda
                  zaten GIZLI, buraya ACIKCA cizildigi icin o gizlemeyi
                  atliyordu. Personelde serit'in 5. alani odur (rol ile yer
                  degistirdi; Rol combosu Kimlik Bilgileri kutusunda). */}
              {kaynak !== 'hasta' && renderAlanListesi(
                (meta?.alanlar ?? []).filter(a => a.ad === 'gorevId'))}
              {/* DURUM: personelde seritte YOK (baslikta rozet), HASTADA VAR ve
                  TC No'nun SAGINDA (kullanici) - hasta durumu dort degerli
                  (Aktif/Pasif/Aday/Vefat), rozet tek basina yetmiyor. */}
              {/* DURUM burada DEGIL, seridin EN SAGINDA (kullanici) - once
                  kimlik alanlari okunur, durum kartin ozeti olarak sona kalir. */}
              {renderAlanListesi(kimlikAlanlari.filter(a =>
                !['kod', 'ad', 'soyad', 'departman', 'durum'].includes(a.ad)))}
              {/* DOGUM TARIHI / YAS - TC No'nun saginda, SALT OKUNUR
                  (kullanici): uc bilgi tek hucrede "14.03.1979 ♂ E 47 y".
                  Kaynak ozluk detayi; duzenlemesi Kimlik Bilgileri kutusunda -
                  ayni alani iki yerde yazdirmak ikisini ayirmaya calismak
                  demekti. */}
              {kaynak === 'hasta' && (
                <label className="alan tip-metin">
                  <span className="etiket">Doğum Tarihi / Yaş</span>
                  <input readOnly tabIndex={-1} value={dogumYasMetni}
                         title="Doğum bilgileri Kimlik Bilgileri kutusundan girilir" />
                </label>
              )}
              {/* DURUM yalniz HASTADA seritte (dort degerli: Aktif/Pasif/Aday/
                  Vefat); personelde baslikta rozet. */}
              {kaynak === 'hasta'
                && renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'durum'))}
            </div>
          ) : kaynak === 'dokuman' ? (
            /* DOKUMAN SERIDI (mockup dokuman_karti.html): DORT SUTUN sabit -
               otomatik akista alanlar ekran genisligine gore 2-6 sutun
               arasinda ziplayip mockup duzenini bozuyordu.
               GECERLILIK TEK HUCREDE: mockupta "28.08.2026 — 01.09.2027 ·
               gozden gecirme 12 ay" tek satir; uc ayri kutu ucte bir satir
               kaplayip ilgisiz alanlari birbirinden ayiriyordu. */
            <div className="alan-izgara kaid-dokuman">
              {/* GECERLILIK HUCRESI KENDI YERINDE kalir (mockup 3. satirin
                  BASI): alanlari filtreleyip hucreyi sona eklemek, Gecerlilik'i
                  Aciklama'nin arkasina atiyordu. Once ondan ONCEKI alanlar,
                  sonra hucre, sonra kalanlar cizilir. */}
              {renderAlanListesi(kimlikAlanlari.slice(
                0, kimlikAlanlari.findIndex(a => GECERLILIK_ALANLARI.includes(a.ad))))}
              <label className="alan tip-metin gecerlilik-hucre">
                <span className="etiket">Geçerlilik</span>
                <span className="gecerlilik-kutu">
                  {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'gecerliBas'))}
                  <span className="ayrac">—</span>
                  {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'gecerliBit'))}
                </span>
              </label>
              {renderAlanListesi(kimlikAlanlari.slice(
                kimlikAlanlari.findIndex(a => GECERLILIK_ALANLARI.includes(a.ad)))
                .filter(a => !GECERLILIK_ALANLARI.includes(a.ad)))}
            </div>
          ) : kaynak === 'kurum' ? (() => {
            /* KURUM SERIDI (484, kullanici: "temsilci ile kurum turunu yer
               degistir"): Kod · Kurum Adi · KURUM TURU · Durum. Kurum turu
               kurumun en temel bilgisidir - hangi anlasma kurallarinin
               isleyecegini o belirler (Ozel / OSS / SGK); temsilci ise satis
               takibi alani, Tanımlama kutusuna indi.
               Deger `taraf_kurum.tur`da (1:1 uzanti), kartin kendi tablosunda
               degil - o yuzden renderAlanListesi ile cizilemez; TekKayit
               cercevesiz kipte seridin bir hucresi olur. */
            const rol = meta?.detaylar.find(d => d.ad === 'kurumRolu');
            return (
              <div className="alan-izgara">
                {renderAlanListesi(kimlikAlanlari.filter(a => a.ad !== 'durum'))}
                {rol && (
                  <TekKayit
                    meta={rol}
                    durum={detaylar[rol.ad] ?? bosDetay()}
                    saltOkunur={salt || rol.saltOkunur}
                    onDegis={y => setDetaylar(t => ({ ...t, [rol.ad]: y }))}
                    cerceveSiz
                  />
                )}
                {renderAlanListesi(kimlikAlanlari.filter(a => a.ad === 'durum'))}
              </div>
            );
          })() : (
            <div className={`alan-izgara${kaynak === 'kisi' ? ' kaid-kisi' : ''}`
                            + (kaynak === 'randevu' ? ' kaid-randevu' : '')
                            + (kaynak === 'prim-plani' ? ' kaid-prim' : '')
                            + (kaynak === 'kampanya' ? ' kaid-kampanya' : '')
                            // FIYAT LISTESI SERIDI BES SUTUN (532, kullanici:
                            //   "1. sira: ad, tarife, yon, kdv, durum" ·
                            //   "2. sira: baslama, bitis, aciklama,
                            //   varsayilan"). Otomatik akista kutular ekran
                            //   genisligine gore ziplayip bu ayrimi bozuyordu.
                            + (kaynak === 'fiyat-listesi' ? ' kaid-fiyat' : '')
                            // MIKROBIYOLOJI KATALOG KARTLARI DORT SUTUN
                            //   (Ekranlar/Lab/*_karti.html `.hdr`): mockup'ta
                            //   serit 4x2 duzenli bir izgara. Otomatik akista
                            //   sekiz alan 1080 px'de yedi sutuna yayilip
                            //   sekizinciyi tek basina ikinci satira
                            //   birakiyordu - ayni aileden gelmeyen bir kart
                            //   gibi duruyordu.
                            + (LAB_MIKRO_KARTLAR.has(kaynak) ? ' kaid-labmikro' : '')}>
              {renderAlanListesi(kimlikAlanlari)}
            </div>
          )}
        </div>
        );
        return seritSarmalayici ? seritSarmalayici(kimlikSeridi, deger) : kimlikSeridi;
}
