import { useCallback, useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from './bicim';
import {
  BAYRAK_OK, BOLUM, ISTEM_DURUM, KALITE, NUMUNE, NUMUNE_DURUM, SATIR_DURUM,
  ZIGOSITE, bayrakSinifi, referansMetni, sayi, sirSinifi, tup,
} from './labKodlari';

/**
 * LABORATUVAR GRİD ALTI DETAY PANELİ (446).
 *
 * Mockup'ların hepsinde (Ekranlar/Lab/*.html) aynı düzen var: üstte çalışma
 * tablosu, <b>altında seçili kaydın ayrıntısı</b> - numune kabulde tetkik/tüp
 * planı, mikrobiyolojide antibiyogram ve okuma kaydı, genetikte varyantlar.
 *
 * <b>Neden gridin altında, kartta değil:</b> teknisyen elinde tüple bankoda
 * duruyor; hangi tetkiklerin hangi tüpe gittiğini görmek için kart açıp
 * kapatmak zorunda kalırsa listeyi kaybeder. Mockup bu yüzden ikisini aynı
 * ekranda gösteriyor.
 *
 * <b>Panel salt okunurdur.</b> İşlemler (kabul, ret, okuma, antibiyogram…)
 * araç çubuğu aksiyonlarıyla yapılır ve kuralları sunucuda işler; burada
 * hiçbir iş kuralı yoktur - yalnız sunucudan gelen kayıt çizilir.
 */

type Satir = Record<string, unknown>;
type Kayit = Record<string, unknown>;

/** Panelin desteklediği listeler ve detayın okunacağı anahtar. */
const KAYNAKLAR: Record<string, 'istem' | 'kultur' | 'genetik' | 'dis'> = {
  'lab-istem': 'istem',
  'lab-numune': 'istem',
  'lab-sonuc': 'istem',
  'lab-kultur': 'kultur',
  'lab-genetik-vaka': 'genetik',
  'lab-dis-gonderim': 'dis',
};

export function labDetayVarMi(kaynak: string): boolean {
  return kaynak in KAYNAKLAR;
}

const dizi = (v: unknown): Satir[] => (Array.isArray(v) ? v as Satir[] : []);
const metin = (v: unknown): string => String(v ?? '').trim();

/**
 * Tetkik adının yanına kodu YALNIZ ayırt ediyorsa yazar: "ALT (SGPT) ALT"
 * gibi tekrar, dar bir kolonda yer yiyor ve okumayı zorlaştırıyordu.
 */
function kodEki(ad: unknown, kod: unknown): string {
  const a = metin(ad).toLocaleUpperCase('tr'), k = metin(kod).toLocaleUpperCase('tr');
  return k !== '' && !a.includes(k) ? metin(kod) : '';
}

/** Tüp rengi rozet olarak: renk bilgidir, teknisyen rafta rengi arar. */
function TupRozeti({ tip }: { tip: unknown }) {
  const t = tup(tip);
  return (
    <span className="rozet gri"
          style={{ background: t.renk, color: t.yazi ?? '#1f2d3a', border: 'none' }}>
      {t.kisa}
    </span>
  );
}

/**
 * Hedef süre dakika olarak tutulur; mockup saat yazıyor ("2 s", "48 s").
 * 60'ın altını dakika bırakmak bilinçli: 30 dakikalık acil tetkiği "0,5 s"
 * diye göstermek okunmaz olurdu.
 */
function tatMetni(dk: unknown): string {
  const d = Number(dk ?? 0);
  if (!d) return '—';
  return d < 60 ? `${d} dk` : `${Math.round(d / 6) / 10} s`.replace('.', ',');
}

/** Boş panel de bir bilgidir: "satır seç" demek, boş kutu bırakmaktan iyidir. */
function Bos({ ne }: { ne: string }) {
  return <div className="kagrup"><div className="bos">{ne}</div></div>;
}

export function LabDetayPaneli({ kaynak, satir }: {
  kaynak: string;
  satir: Satir | null;
}) {
  const tur = KAYNAKLAR[kaynak];
  // İstem tabanlı listelerde detay İSTEMİN kendisidir: numune ve sonuç
  //   satırları da aynı istemin parçası (barkod tek başına yetmez - bir
  //   istemde birden çok tüp olur).
  const id = tur === 'istem'
    ? Number(satir?.istemId ?? (kaynak === 'lab-istem' ? satir?.id : 0) ?? 0)
    : Number(satir?.id ?? 0);

  const [veri, setVeri] = useState<Kayit | null>(null);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(false);

  const yukle = useCallback(async () => {
    if (!tur || !id) { setVeri(null); return }
    setYukleniyor(true); setHata('');
    try {
      const y = tur === 'istem' ? await api.labIstemOku(id)
              : tur === 'kultur' ? await api.labKulturOku(id)
              : tur === 'genetik' ? await api.genetikVakaOku(id)
              : await api.disLabOku(id) as unknown as Kayit;
      setVeri(y as Kayit);
    } catch (h) { setHata(hataMetni(h)); setVeri(null) }
    finally { setYukleniyor(false) }
  }, [tur, id]);

  useEffect(() => { void yukle() }, [yukle]);

  if (!tur) return null;
  if (!id) return <div className="lab-detay"><Bos ne="Ayrıntı için listeden bir satır seçin." /></div>;

  return (
    <div className="lab-detay">
      {hata && <div className="hata-kutusu">{hata}</div>}
      {!veri && yukleniyor && <Bos ne="Yükleniyor…" />}
      {veri && tur === 'istem' && <IstemDetayi veri={veri} secili={satir} kaynak={kaynak} />}
      {veri && tur === 'kultur' && <KulturDetayi veri={veri} />}
      {veri && tur === 'genetik' && <GenetikDetayi veri={veri} />}
      {veri && tur === 'dis' && <DisDetayi veri={veri} />}
    </div>
  );
}

/* ------------------------------------------------------------------ istem --
   Mockup lab_istem_numune_kabul.html: solda "LAB-…/… · Tetkikler" tablosu
   (tüp planı otomatik), sağda hasta/klinik bilgisi ve etiketler.        */
function IstemDetayi({ veri, secili, kaynak }: {
  veri: Kayit; secili: Satir | null; kaynak: string;
}) {
  const git = useNavigate();
  const satirlar = dizi(veri.satirlar);
  const numuneler = dizi(veri.numuneler);
  // Numune kabul ekranında seçili TÜPÜN satırları öne alınır: banko o tüple
  //   çalışıyor, listedeki diğer tüpler bağlam olarak kalır.
  const seciliBarkod = kaynak === 'lab-numune' ? metin(secili?.barkod) : '';
  // AYNI TABLO IKI SORUYA BIRDEN CEVAP VEREMEZ: numune kabulde soru "hangi
  //   tup, ne zaman alindi, ne zaman biter" (mockup
  //   lab_istem_numune_kabul.html), sonuc ekraninda "deger, referans,
  //   bayrak". Dokuz kolonu yan yana koymak ikisini de okunmaz yapardi.
  const sonucGorunumu = kaynak === 'lab-sonuc';
  const acil = Number(veri.oncelik ?? 1) === 3;
  // Etiket kartinda tupun hangi bolumlere gittigi yazar (mockup:
  //   "Hemogram+HbA1c"): teknisyen tupu dogru banka gonderir.
  // ALAN / ALIM / KALITE tup duzeyinde tutulur ama pratikte bir istemin
  //   tupleri AYNI kisi tarafindan, AYNI anda alinir; sag panel istemin
  //   ozetini gosterir. Farkli deger varsa ilk dolu olan yazilir - ayrinti
  //   soldaki satir tablosunda zaten tup tup duruyor.
  const ilkDolu = (a: string) => metin(numuneler.find(n => metin(n[a]) !== '')?.[a]);
  const alimZamani = numuneler.map(n => n.alim).find(Boolean) ?? null;
  // Numune ALINMADAN alan/yer/kalite YAZILMAZ: tabloda duran varsayilanlari
  //   ("Kan alma", "Uygun") gostermek, alinmamis tupu alinmis gibi okuturdu.
  const alan = alimZamani ? ilkDolu('alan') : '';
  const alimYeri = alimZamani ? ilkDolu('alimYeri') : '';
  const kaliteli = numuneler.find(n => (n.kabul || n.ret) && Number(n.kalite ?? 0) > 0);
  const kalite = Number(kaliteli?.kalite ?? 0);

  const tupBolumleri = (barkod: string) => {
    const ad = satirlar.filter(s => metin(s.barkod) === barkod)
                       .map(s => BOLUM[Number(s.bolum ?? 0)] ?? '')
                       .filter(Boolean);
    return [...new Set(ad)].join(' · ');
  };

  return (
    <div className="lab-ana-yan">
      <div>
        <div className="kagrup">
          <h6>
            {metin(veri.istemNo)} · Tetkikler
            <span className="rozet gri">
              {ISTEM_DURUM[Number(veri.durum ?? 1)] ?? ''}
            </span>
            {acil && <span className="rozet hata">ACİL</span>}
            <span className="sp">tüp/numune planı tetkik kataloğundan</span>
          </h6>
          <div className="detay-kaydir">
            <table className="detay-tablo">
              <thead>
                <tr>
                  <th>Bölüm</th><th>Tetkik</th>
                  {sonucGorunumu ? (
                    <>
                      <th>Tüp / Barkod</th>
                      <th className="sag">Sonuç</th><th>Birim</th><th>Referans</th>
                      <th className="orta">Bayrak</th><th className="orta">Ölçüm</th>
                    </>
                  ) : (
                    <>
                      <th>Numune</th><th>Tüp</th><th className="orta">Barkod</th>
                      <th className="orta">Alındı</th><th className="orta">Kabul</th>
                      <th className="orta">Hedef TAT</th><th className="orta">Cihaz</th>
                    </>
                  )}
                  <th className="orta">Durum</th>
                </tr>
              </thead>
              <tbody>
                {satirlar.map(s => {
                  const barkod = metin(s.barkod);
                  const n = numuneler.find(x => metin(x.barkod) === barkod);
                  const t = tup(n?.tupTipi);
                  const bayrak = metin(s.bayrak);
                  const panik = Number(s.panik ?? 0) === 1 || Boolean(s.panik);
                  return (
                    <tr key={String(s.satirId)}
                        className={panik ? 'panik'
                          : (seciliBarkod && barkod === seciliBarkod ? 'secili' : '')}>
                      <td>{BOLUM[Number(s.bolum ?? 0)] ?? ''}</td>
                      <td>
                        <b>{metin(s.ad)}</b>
                        {kodEki(s.ad, s.kod) &&
                          <span className="not"> {kodEki(s.ad, s.kod)}</span>}
                      </td>
                      {sonucGorunumu ? (
                        <>
                          <td>
                            {barkod ? (
                              <>
                                <span className="rozet gri"
                                      style={{ background: t.renk, color: t.yazi ?? '#1f2d3a',
                                               border: 'none' }}>
                                  {t.kisa}
                                </span>{' '}
                                <span className="not">{barkod}</span>
                              </>
                            ) : <span className="not">tüp planlanmadı</span>}
                          </td>
                          <td className="sag">
                            {metin(s.deger) ? <b>{metin(s.deger)}</b>
                                            : <span className="not">bekliyor</span>}
                          </td>
                          <td>{metin(s.birim)}</td>
                          <td>
                            {referansMetni(s.referansAlt, s.referansUst, s.referansMetin) || '—'}
                          </td>
                          <td className="orta">
                            {bayrak && bayrak !== 'N'
                              ? <span className={bayrakSinifi(bayrak)}>
                                  {bayrak} {BAYRAK_OK[bayrak] ?? ''}
                                </span>
                              : '—'}
                            {Number(s.deltaUyari ?? 0) === 1 && (
                              <span className="not" title="Önceki sonuçtan belirgin sapma"> Δ</span>
                            )}
                          </td>
                          <td className="orta not">
                            {s.olcumZamani ? tarihSaat(s.olcumZamani) : '—'}
                          </td>
                        </>
                      ) : (
                        <>
                          <td>{NUMUNE[Number(s.numuneTipi ?? 9)] ?? '—'}</td>
                          <td><TupRozeti tip={s.tupTipi} /></td>
                          {/* Barkod YOKSA tüp planı henüz çıkmamıştır - satır
                              "Barkod Üret" beklediğini kendisi söylemeli. */}
                          <td className="orta not">
                            {barkod || 'tüp planlanmadı'}
                          </td>
                          <td className="orta not">{s.alim ? tarihSaat(s.alim) : '—'}</td>
                          <td className="orta not">{s.kabul ? tarihSaat(s.kabul) : '—'}</td>
                          <td className="orta">{tatMetni(s.hedefTat)}</td>
                          <td className="orta not">{metin(s.cihaz) || '—'}</td>
                        </>
                      )}
                      <td className="orta">
                        <span className="rozet gri">
                          {SATIR_DURUM[Number(s.durum ?? 1)] ?? ''}
                        </span>
                      </td>
                    </tr>
                  );
                })}
                {satirlar.length === 0 && (
                  <tr><td colSpan={10} className="not">Bu istemde tetkik yok.</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div>
        <div className="kagrup">
          <h6>
            Hasta / İstem
            {metin(veri.protokol) &&
              <span className="sp">Protokol {metin(veri.protokol)}</span>}
          </h6>
          <div className="lab-alanlar">
            {/* HASTA SATIRI mockup'taki gibi tek satır: ad · yaş/cinsiyet ·
                maskeli kimlik. Banko tüpü hastayla eşlerken ada güvenemez -
                aynı isimli iki hasta aynı gün gelir. */}
            <div className="fld" style={{ gridColumn: '1 / -1' }}>
              <label>Hasta</label>
              <div className="deger buyuk">
                {metin(veri.hasta) || '—'}
                {metin(veri.yas) || metin(veri.cinsiyet)
                  ? ` · ${metin(veri.yas)} ${metin(veri.cinsiyet)}`.trimEnd() : ''}
                {metin(veri.kimlik) ? ` · ${metin(veri.kimlik)}` : ''}
              </div>
            </div>
            <div className="fld" style={{ gridColumn: '1 / -1' }}>
              <label>Klinik bilgi / tanı</label>
              <div className="deger">
                {metin(veri.klinik) || '—'}
                {metin(veri.tani) ? ` · ${metin(veri.tani)}` : ''}
              </div>
            </div>
            {/* AÇLIK / HAZIRLIK tetkik kataloğundan (lab_tetkik.hazirlik_notu):
                koşul sağlanmadıysa sonuç yorumlanamaz, bankonun kan almadan
                ÖNCE görmesi gerekir. */}
            <div className="fld" style={{ gridColumn: '1 / -1' }}>
              <label>Açlık / hazırlık</label>
              <div className="deger">
                {metin(veri.hazirlik) || <span className="not">özel hazırlık gerekmiyor</span>}
              </div>
            </div>
            <div className="fld">
              <label>İsteyen</label>
              <div className="deger">{metin(veri.hekim) || '—'}</div>
            </div>
            <div className="fld">
              <label>İstem zamanı</label>
              <div className="deger">{veri.tarih ? tarihSaat(veri.tarih) : '—'}</div>
            </div>
            {/* ALAN + YER birlikte (mockup "Hemşire N. Koç · Kan alma 2"):
                numunenin nerede alındığı kalite tartışmasının ilk sorusu. */}
            <div className="fld">
              <label>Numune alan</label>
              <div className="deger">
                {alan || <span className="not">—</span>}
                {alimYeri && <span className="not">· {alimYeri}</span>}
              </div>
            </div>
            <div className="fld">
              <label>Alım zamanı</label>
              <div className="deger">{alimZamani ? tarihSaat(alimZamani) : '—'}</div>
            </div>
            {/* KALİTE sonucun güvenilirlik kaydıdır: hemolizli tüpten çıkan
                potasyum, laboratuvarın değil numunenin sonucudur. */}
            <div className="fld">
              <label>Numune kalitesi</label>
              <div className="deger">
                {kalite ? (kalite === 1
                            ? <span className="rozet olumlu">Uygun</span>
                            : <span className="rozet uyari">{KALITE[kalite] ?? ''}</span>)
                        : <span className="not">—</span>}
              </div>
            </div>
            <div className="fld">
              <label>Hedef bitiş (TAT)</label>
              <div className="deger">
                {veri.hedefBitis ? tarihSaat(veri.hedefBitis) : '—'}
              </div>
            </div>
          </div>
        </div>

        {/* ETİKETLER (mockup sağ panel): basılacak tüp etiketinin ekrandaki
            karşılığı - barkod, tüp rengi, hasta ve tüpün gideceği bölümler.
            Tüplerin alım/kabul saati SOL tabloda satır satır durur; burada
            tekrar etmek aynı bilgiyi iki yerden okutmak olurdu. */}

        {/* ETİKETLER: mockup'taki tüp kutucukları. Tüp rengi metinden önce
            gelir - teknisyen rafta rengi arar. */}
        <div className="kagrup">
          <h6>
            Etiketler
            <span className="sp">{numuneler.length} numune</span>
            {/* Mockup'ta bu kutunun altında "Etiketleri Bas" duruyor: tüp
                planı burada görünüyor, etiket de buradan basılmalı. */}
            <button className="d"
                    onClick={() => git(`/lab/etiket?istem=${Number(veri.id ?? 0)}`)}>
              🏷 Etiketleri Bas
            </button>
          </h6>
          <div className="lab-etiketler">
            {numuneler.map(n => {
              const barkod = metin(n.barkod);
              const bolumler = tupBolumleri(barkod);
              return (
                <div className={'lab-etiket'
                       + (seciliBarkod && barkod === seciliBarkod ? ' secili' : '')
                       + (n.ret ? ' ret' : '')}
                     key={String(n.id)}>
                  <b>
                    {barkod} <TupRozeti tip={n.tupTipi} />
                  </b>
                  <span className="not">
                    {metin(veri.hasta)}
                    {metin(veri.yas) ? ` ${metin(veri.yas)}${metin(veri.cinsiyet)}` : ''}
                    {' · '}{NUMUNE[Number(n.numuneTipi ?? 9)] ?? ''}
                    {bolumler ? ` · ${bolumler}` : ''}
                  </span>
                  <span>
                    {n.ret
                      ? <span className="rozet hata">Ret</span>
                      : <span className="rozet gri">
                          {NUMUNE_DURUM[Number(n.durum ?? 1)] ?? ''}
                        </span>}
                  </span>
                </div>
              );
            })}
            {numuneler.length === 0 && (
              <div className="bos">
                Tüp planlanmadı - araç çubuğundan “🏷 Barkod Üret”.
              </div>
            )}
          </div>
          {/* RET NEDENİ görünür kalmalı: numune neden reddedildi sorusunun
              cevabı, yeniden alım kararının kendisidir. */}
          {numuneler.filter(n => n.ret).map(n => (
            <div className="ic sonuk" key={`r${n.id}`}>
              <b>{metin(n.barkod)} reddedildi:</b> {metin(n.retAciklama) || 'gerekçe yok'}
            </div>
          ))}
        </div>

        {/* KURALLAR (mockup sağ alt): bankonun ezberlemesi gereken beş kural.
            Ekranda durması, yeni gelen teknisyenin sorması gereken soruları
            azaltır - kural değişirse tek yerde değişir. */}
        <div className="kagrup">
          <h6>Kurallar</h6>
          <div className="ic sonuk">
            Aynı numune tipi/tüp tek barkodda birleşir. Acil istemde etiket
            kırmızı, cihazda STAT önceliklidir. <b>TAT kabul anında başlar.</b>{' '}
            Ret'te isteyen hekime bildirim gider ve tetkikler “tekrar numune”
            durumuna düşer. Dış istemde numune kurye ile gelir (sıcaklık kaydı).
          </div>
        </div>
      </div>
    </div>
  );
}

/* ---------------------------------------------------------------- kültür --
   Mockup lab_mikrobiyoloji.html .ikiPanel: solda antibiyogram, sağda okuma
   kaydı ve rapor önizleme.                                              */
/** `lab_kultur_ureme.id_yontem`. */
const ID_YONTEM: Record<number, string> = {
  1: 'MALDI-TOF', 2: 'VITEK', 3: 'Manuel', 4: 'Moleküler', 9: 'Diğer',
};

/** Enfeksiyon kontrolüne bildirilen direnç işaretleri (436). */
const DIRENC: { alan: string; ad: string }[] = [
  { alan: 'mrsa', ad: 'MRSA' }, { alan: 'vre', ad: 'VRE' },
  { alan: 'esbl', ad: 'ESBL' }, { alan: 'karbapenemaz', ad: 'Karbapenemaz' },
  { alan: 'ampc', ad: 'AmpC' },
];

function KulturDetayi({ veri }: { veri: Kayit }) {
  const k = (veri.kultur ?? {}) as Kayit;
  const besiyeriler = dizi(veri.besiyeriler);
  const okumalar = dizi(veri.okumalar);
  const izolatlar = dizi(veri.izolatlar);
  const antibiyogram = dizi(veri.antibiyogram);

  return (
    <div className="lab-ikili">
      <div className="kagrup">
        <h6>
          💊 Antibiyogram
          <span className="sp">
            {metin(antibiyogram[0]?.standart) || 'EUCAST'}
            {metin(antibiyogram[0]?.standartSurum)
              ? ` ${metin(antibiyogram[0]?.standartSurum)}` : ''} · MIC
          </span>
        </h6>
        <div className="detay-kaydir">
          <table className="detay-tablo">
            <thead>
              <tr>
                <th>Antibiyotik</th><th className="sag">MIC (µg/mL)</th>
                <th className="orta">Zon</th><th className="orta">Yorum</th>
                <th className="orta">Kaynak</th><th className="orta">Raporlanır</th>
              </tr>
            </thead>
            <tbody>
              {antibiyogram.map(a => (
                <tr key={String(a.id)}>
                  <td>
                    {metin(a.ad)}
                    {kodEki(a.ad, a.kod) &&
                      <span className="not"> {kodEki(a.ad, a.kod)}</span>}
                  </td>
                  <td className="sag">
                    {metin(a.micIsaret)}{a.mic === null || a.mic === undefined
                      ? (metin(a.micIsaret) ? '' : '—') : ` ${sayi(a.mic, 3)}`}
                  </td>
                  <td className="orta">{a.zonMm ? `${String(a.zonMm)} mm` : '—'}</td>
                  <td className="orta">
                    <span className={sirSinifi(a.yorum)}>{metin(a.yorum) || '—'}</span>
                  </td>
                  <td className="orta not">
                    {Number(a.kaynak ?? 1) === 2 ? 'disk (manuel)'
                      : Number(a.kaynak ?? 1) === 3 ? 'uzman' : 'cihaz'}
                  </td>
                  {/* KADEMELİ BİLDİRİM: raporda görünmeyen ajan burada da
                      işaretli - "niye yazmıyor" sorusu ekranda cevaplanır. */}
                  <td className="orta">
                    {a.bildir ? <span className="rozet olumlu">Evet</span>
                              : <span className="rozet gri">Kademeli</span>}
                  </td>
                </tr>
              ))}
              {antibiyogram.length === 0 && (
                <tr><td colSpan={6} className="not">Antibiyogram girilmedi.</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {metin(k.uzmanYorum) && <div className="ic sonuk">{metin(k.uzmanYorum)}</div>}
      </div>

      <div>
        <div className="kagrup">
          <h6>
            🧫 Okumalar
            <span className="sp">
              {besiyeriler.map(b => metin(b.ad)).join(' · ') || 'besiyeri yok'}
            </span>
          </h6>
          <table className="detay-tablo">
            <thead>
              <tr>
                <th className="orta">Saat</th><th className="orta">Zaman</th>
                <th className="orta">Üreme</th><th>Bulgu</th><th>Sonraki adım</th>
              </tr>
            </thead>
            <tbody>
              {okumalar.map(o => (
                <tr key={String(o.id)}>
                  <td className="orta">{String(o.saat ?? '')} s</td>
                  <td className="orta not">
                    {o.zaman ? tarihSaat(o.zaman) : '—'}
                  </td>
                  <td className="orta">
                    {o.uremeVar ? <span className="rozet uyari">var</span>
                                : <span className="rozet gri">yok</span>}
                  </td>
                  <td>{metin(o.bulgu) || '—'}</td>
                  <td className="not">{metin(o.sonrakiAdim) || '—'}</td>
                </tr>
              ))}
              {okumalar.length === 0 && (
                <tr><td colSpan={5} className="not">Okuma kaydı yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>

        <div className="kagrup">
          <h6>🔬 İzolatlar</h6>
          <table className="detay-tablo">
            <thead>
              <tr>
                <th className="orta">No</th><th>Organizma</th>
                <th className="sag">Koloni</th><th className="orta">Yöntem</th>
              </tr>
            </thead>
            <tbody>
              {izolatlar.map(i => (
                <tr key={String(i.id)}>
                  <td className="orta">{String(i.izolatNo ?? '')}</td>
                  <td>
                    <b><i>{metin(i.organizma)}</i></b>
                    {kodEki(i.organizma, i.organizmaKod) &&
                      <span className="not"> {kodEki(i.organizma, i.organizmaKod)}</span>}
                    {/* DİRENÇ İŞARETLERİ enfeksiyon kontrolünün konusudur:
                        MRSA/VRE/ESBL/karbapenemaz gizlenirse bildirim
                        yapılmaz. */}
                    {DIRENC.filter(d => Number(i[d.alan] ?? 0) === 1).map(d => (
                      <span className="rozet hata" key={d.alan}
                            style={{ marginLeft: 4 }}>{d.ad}</span>
                    ))}
                  </td>
                  <td className="sag">
                    {i.koloniSayisi ? `${sayi(i.koloniSayisi, 0)} ${metin(i.koloniBirim)}`
                                    : '—'}
                    {i.anlamli === false && <span className="not"> · anlamsız</span>}
                  </td>
                  <td className="orta not">
                    {ID_YONTEM[Number(i.idYontem ?? 0)] ?? '—'}
                    {i.idGuven ? ` ${sayi(i.idGuven, 1)}` : ''}
                  </td>
                </tr>
              ))}
              {izolatlar.length === 0 && (
                <tr><td colSpan={4} className="not">Üreme yok / izolat kaydedilmedi.</td></tr>
              )}
            </tbody>
          </table>
        </div>

        {metin(k.onRapor) && (
          <div className="kagrup">
            <h6>📄 Ön rapor</h6>
            <div className="ic">{metin(k.onRapor)}</div>
          </div>
        )}
      </div>
    </div>
  );
}

/* --------------------------------------------------------------- genetik --
   Mockup lab_genetik.html: varyant tablosu + vaka/kalite bilgisi.        */
/** `lab_varyant.kalitim` / `lab_gen.kalitim` (439). */
const KALITIM: Record<number, string> = {
  1: 'OD', 2: 'OR', 3: 'X’e bağlı', 4: 'Mitokondriyal', 5: 'Somatik',
};

function GenetikDetayi({ veri }: { veri: Kayit }) {
  const v = (veri.vaka ?? {}) as Kayit;
  const varyantlar = dizi(veri.varyantlar);

  const sinif = (k: unknown) => {
    const n = Number(k ?? 0);
    if (n === 5 || n === 4) return 'rozet hata';        // patojenik / olası
    if (n === 3) return 'rozet uyari';                  // VUS
    return 'rozet olumlu';                              // benign / olası benign
  };
  const SINIF: Record<number, string> = {
    1: 'Benign', 2: 'Olası benign', 3: 'VUS', 4: 'Olası patojenik', 5: 'Patojenik',
  };

  return (
    <>
      {/* VARYANT TABLOSU TAM GENİŞLİK (mockup lab_genetik.html): on bir
          kolonu yarım sütuna sıkıştırınca sınıf ve rapor işareti kırpılıyor -
          oysa raporlanacak varyantı seçmek bu ekranın işi. */}
      <div className="kagrup">
        <h6>
          🧬 Varyantlar
          <span className="sp">ACMG/AMP 2015 · sınıf sunucuda türetilir</span>
        </h6>
        <div className="detay-kaydir">
          <table className="detay-tablo">
            <thead>
              <tr>
                <th>Gen</th><th>Transkript · HGVS c.</th><th>HGVS p.</th>
                <th className="orta">Zigosite</th><th className="orta">Kalıtım</th>
                <th className="sag">Derinlik / VAF</th><th className="sag">gnomAD AF</th>
                <th>ClinVar</th><th>ACMG kriterleri</th>
                <th className="orta">Sınıf</th><th className="orta">Doğrulama</th>
                <th className="orta">Rapor</th>
              </tr>
            </thead>
            <tbody>
              {varyantlar.map(x => (
                <tr key={String(x.id)}>
                  <td><b>{metin(x.genSembol)}</b></td>
                  <td>
                    {metin(x.transkript) ? `${metin(x.transkript)}:` : ''}
                    {metin(x.hgvsC) || '—'}
                  </td>
                  <td>{metin(x.hgvsP) || '—'}</td>
                  <td className="orta">{ZIGOSITE[Number(x.zigosite ?? 0)] ?? '—'}</td>
                  <td className="orta">{KALITIM[Number(x.kalitim ?? 0)] ?? '—'}</td>
                  {/* VAF ORAN olarak saklanır (0,49 = %49): başına yüzde
                      işareti koymak değeri yüz kat küçük gösteriyordu. */}
                  <td className="sag">
                    {x.derinlik ? `${sayi(x.derinlik, 0)}×` : '—'}
                    {x.vaf ? ` · ${sayi(x.vaf, 2)}` : ''}
                  </td>
                  <td className="sag">{x.gnomadAf ? sayi(x.gnomadAf, 5) : '—'}</td>
                  <td>{metin(x.clinVar) || '—'}</td>
                  {/* ACMG KANIT KODLARI sınıfın gerekçesidir: sınıf tek
                      başına "neden patojenik" sorusunu cevaplamaz. */}
                  <td className="not">
                    {Array.isArray(x.acmg) && (x.acmg as string[]).length > 0
                      ? (x.acmg as string[]).join(' · ') : '—'}
                  </td>
                  <td className="orta">
                    <span className={sinif(x.sinif)}>
                      {SINIF[Number(x.sinif ?? 0)] ?? '—'}
                    </span>
                    {x.sinifElle ? <span className="not" title="Uzman değiştirdi"> ✎</span>
                                 : null}
                  </td>
                  <td className="orta not">
                    {Number(x.dogrulama ?? 0) === 2 ? `Sanger · ${metin(x.dogrulamaYontem)}`
                      : Number(x.dogrulama ?? 0) === 1 ? 'bekliyor' : '—'}
                  </td>
                  <td className="orta">
                    {x.raporla ? <span className="rozet olumlu">Evet</span>
                               : <span className="rozet gri">Hayır</span>}
                  </td>
                </tr>
              ))}
              {varyantlar.length === 0 && (
                <tr><td colSpan={12} className="not">Varyant kaydedilmedi.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      <div className="lab-ikili">
      <div className="kagrup">
        <h6>Vaka</h6>
        <div className="lab-alanlar">
          <div className="fld">
            <label>Vaka no</label>
            <div className="deger buyuk">{metin(v.vakaNo) || '—'}</div>
          </div>
          <div className="fld">
            <label>Test / panel</label>
            <div className="deger">{metin(v.panel) || metin(v.tetkikAd) || '—'}</div>
          </div>
          {/* ONAM: KVKK md. 6 - onamsız rapor yok. Ekranda da en üstte. */}
          <div className="fld">
            <label>Onam</label>
            <div className="deger">
              {v.onamTarihi
                ? <span className="rozet olumlu">
                    alındı · {tarihSaat(v.onamTarihi)}
                    {metin(v.onamSurum) ? ` · ${metin(v.onamSurum)}` : ''}
                  </span>
                : <span className="rozet hata">alınmadı</span>}
            </div>
          </div>
          <div className="fld">
            <label>Tesadüfi bulgu</label>
            <div className="deger">
              {Number(v.tesadufiBulgu ?? 0) === 1 ? 'bildirilsin' : 'bildirilmesin'}
            </div>
          </div>
          <div className="fld">
            <label>DNA (ng/µL · A260/280)</label>
            <div className="deger">
              {sayi(v.dnaKonsantrasyon, 1)} · {sayi(v.dnaSaflik, 2)}
            </div>
          </div>
          <div className="fld">
            <label>Run</label>
            <div className="deger">{metin(v.run) || '—'}</div>
          </div>
        </div>
        {metin(v.uzmanYorum) && <div className="ic sonuk">{metin(v.uzmanYorum)}</div>}
      </div>

      {/* RUN / KALİTE (mockup "Run / kalite · RUN-0931"): varyantın hangi
          koşullarda çağrıldığı sonucun kendisi kadar bağlayıcıdır - düşük
          kapsama, kontaminasyon ya da cinsiyet uyumsuzluğu varyantı
          şüpheli yapar. */}
      <div className="kagrup">
        <h6>Run / kalite <span className="sp">{metin(v.run) || 'run atanmadı'}</span></h6>
        <div className="lab-alanlar">
          <div className="fld">
            <label>Kapsama / ort. derinlik</label>
            <div className="deger">
              {v.kapsamaYuzde ? `%${sayi(v.kapsamaYuzde, 1)}` : '—'}
              {v.ortDerinlik ? ` · ${sayi(v.ortDerinlik, 0)}×` : ''}
            </div>
          </div>
          <div className="fld">
            <label>Kontaminasyon</label>
            <div className="deger">
              {v.kontaminasyon ? `%${sayi(v.kontaminasyon, 2)}` : '—'}
            </div>
          </div>
          <div className="fld">
            <label>Cinsiyet doğrulama</label>
            <div className="deger">
              {Number(v.cinsiyetDogrulama ?? 0) === 1
                ? <span className="rozet olumlu">uyumlu</span>
                : Number(v.cinsiyetDogrulama ?? 0) === 2
                  ? <span className="rozet hata">uyumsuz</span>
                  : '—'}
            </div>
          </div>
          <div className="fld">
            <label>Pipeline / referans</label>
            <div className="deger">
              {[metin(v.pipeline), metin(v.referansGenom)].filter(Boolean).join(' · ') || '—'}
            </div>
          </div>
        </div>
        {metin(v.oneriler) && (
          <div className="ic"><b>Öneriler:</b> {metin(v.oneriler)}</div>
        )}
        {metin(v.sinirliliklar) && (
          <div className="ic sonuk"><b>Sınırlılıklar:</b> {metin(v.sinirliliklar)}</div>
        )}
      </div>
      </div>
    </>
  );
}

/* ------------------------------------------------------------- dış lab ----
   Gönderim bir süreçtir: kurye, soğuk zincir ve satır durumları burada.  */
function DisDetayi({ veri }: { veri: Kayit }) {
  const g = (veri.gonderim ?? {}) as Kayit;
  const satirlar = dizi(veri.satirlar);
  const TASIMA: Record<number, string> = {
    1: 'Oda sıcaklığı', 2: 'Soğuk (2-8 °C)', 3: 'Dondurulmuş (-20 °C)',
    4: 'Kuru buz (-70 °C)',
  };
  const SDURUM: Record<number, string> = {
    1: 'Gönderildi', 2: 'Sonuç geldi', 3: 'Dış lab reddetti', 4: 'Numune kayboldu',
  };

  return (
    <div className="lab-ana-yan">
      <div className="kagrup">
        <h6>
          {metin(g.gonderimNo)} · Gönderilen tetkikler
          <span className="sp">{satirlar.length} tetkik</span>
        </h6>
        <div className="detay-kaydir">
          <table className="detay-tablo">
            <thead>
              <tr>
                <th>Hasta</th><th>Tetkik</th><th className="orta">Barkod</th>
                <th className="sag">Sonuç</th><th className="orta">Sonuç zamanı</th>
                <th className="orta">Durum</th>
              </tr>
            </thead>
            <tbody>
              {satirlar.map(s => (
                <tr key={String(s.id)}
                    className={Number(s.durum ?? 1) >= 3 ? 'panik' : ''}>
                  <td>{metin(s.hasta)}</td>
                  <td>
                    <b>{metin(s.ad)}</b>
                    {kodEki(s.ad, s.kod) &&
                      <span className="not"> {kodEki(s.ad, s.kod)}</span>}
                  </td>
                  <td className="orta not">{metin(s.barkod) || '—'}</td>
                  <td className="sag">{metin(s.deger) || <span className="not">bekliyor</span>}</td>
                  <td className="orta not">
                    {s.sonucZamani ? tarihSaat(s.sonucZamani) : '—'}
                  </td>
                  <td className="orta">
                    <span className={Number(s.durum ?? 1) >= 3 ? 'rozet hata'
                                   : Number(s.durum) === 2 ? 'rozet olumlu' : 'rozet gri'}>
                      {SDURUM[Number(s.durum ?? 1)] ?? ''}
                    </span>
                  </td>
                </tr>
              ))}
              {satirlar.length === 0 && (
                <tr><td colSpan={6} className="not">Gönderim satırı yok.</td></tr>
              )}
            </tbody>
          </table>
        </div>
        {satirlar.filter(s => metin(s.retNeden)).map(s => (
          <div className="ic sonuk" key={`r${s.id}`}>
            <b>{metin(s.kod)} reddedildi:</b> {metin(s.retNeden)}
          </div>
        ))}
      </div>

      <div className="kagrup">
        <h6>Kurye / soğuk zincir</h6>
        <div className="lab-alanlar">
          <div className="fld" style={{ gridColumn: '1 / -1' }}>
            <label>Dış laboratuvar</label>
            <div className="deger buyuk">{metin(g.disLab) || '—'}</div>
          </div>
          <div className="fld">
            <label>Kurye</label>
            <div className="deger">
              {[metin(g.kuryeFirma), metin(g.kuryeAd)].filter(Boolean).join(' · ') || '—'}
            </div>
          </div>
          <div className="fld">
            <label>Telefon</label>
            <div className="deger">{metin(g.kuryeTel) || '—'}</div>
          </div>
          {/* SOĞUK ZİNCİR: -20 °C isteyen numune oda sıcaklığında gittiyse
              sonuç geçersizdir; kayıt sonradan sorulur. */}
          <div className="fld">
            <label>Taşıma koşulu</label>
            <div className="deger">{TASIMA[Number(g.tasimaKosulu ?? 2)] ?? '—'}</div>
          </div>
          <div className="fld">
            <label>Sıcaklık / kap</label>
            <div className="deger">
              {g.sicaklik ? `${sayi(g.sicaklik, 1)} °C` : '—'} · {String(g.kapSayisi ?? 1)} kap
            </div>
          </div>
          <div className="fld">
            <label>Gönderim</label>
            <div className="deger">
              {g.gonderimZamani ? tarihSaat(g.gonderimZamani) : '—'}
            </div>
          </div>
          <div className="fld">
            <label>Teslim</label>
            <div className="deger">
              {g.teslimZamani ? tarihSaat(g.teslimZamani) : '—'}
              {metin(g.teslimAlan) ? ` · ${metin(g.teslimAlan)}` : ''}
            </div>
          </div>
          <div className="fld">
            <label>Dış kabul no</label>
            <div className="deger">{metin(g.disKabulNo) || '—'}</div>
          </div>
          <div className="fld">
            <label>Alış faturası</label>
            <div className="deger">{metin(g.faturaNo) || 'eşleştirilmedi'}</div>
          </div>
        </div>
      </div>
    </div>
  );
}
