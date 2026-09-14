import { Fragment, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { tarihSaat } from '../../bicim';
import {
  BAYRAK_OK, BOLUM, ISTEM_DURUM, KALITE, NUMUNE, NUMUNE_DURUM, SATIR_DURUM,
  bayrakSinifi, referansMetni, tup,
} from '../../labKodlari';
import { dizi, metin, kodEki, TupRozeti, tatMetni } from './ortak';

/** Panelde cizilen sunucu kaydi - alanlar kaynaga gore degisir. */
type Kayit = Record<string, unknown>;
type Satir = Record<string, unknown>;

export function IstemDetayi({ veri, secili, kaynak, kisim }: {
  veri: Kayit; secili: Satir | null; kaynak: string;
  kisim: 'tam' | 'ana' | 'yan';
}) {
  const git = useNavigate();
  const satirlar = dizi(veri.satirlar);
  /**
   * PANELLER VARSAYILAN KAPALI (kullanici: "panel varsa + ile acilir kapanir
   * yap, default kapali olsun").
   *
   * Hemogram 23, tam idrar 21 satir uretiyor. Ikisi birden istenen bir
   * istemde tablo 44 satir aciliyor ve panel DISI tetkikler (CRP, TSH…)
   * gorunmez oluyordu - oysa bankonun once onlari gormesi gerekiyor.
   * Panel TEK SATIRA katlanir; acmak isteyen "+" ile acar.
   *
   * Durum PANEL KIMLIGIYLE tutulur, satir sirasiyla degil: baska bir istem
   * secilince ayni panel acik kalsin - kullanici her satirda yeniden
   * acmasin.
   */
  const [acikPaneller, setAcikPaneller] = useState<Set<number>>(new Set());
  const panelAc = (id: number) => setAcikPaneller(o => {
    const y = new Set(o);
    if (y.has(id)) y.delete(id); else y.add(id);
    return y;
  });

  /**
   * SATIRLARI PANELE GORE DIZ - sunucunun sirasi KORUNUR.
   *
   * Panelleri basa toplamak, istemin girildigi sirayi bozardi; grup satirin
   * ILK gorundugu yerde acilir, oteki satirlari oraya toplanir.
   */
  type Grup = { panelId: number; ad: string; satirlar: Satir[] };
  const gruplar: Grup[] = [];
  const grupDizini = new Map<number, number>();
  for (const s of satirlar) {
    const pid = Number(s.panelId ?? 0);
    if (pid === 0) { gruplar.push({ panelId: 0, ad: '', satirlar: [s] }); continue }
    const yer = grupDizini.get(pid);
    if (yer === undefined) {
      grupDizini.set(pid, gruplar.length);
      gruplar.push({ panelId: pid, ad: metin(s.panelAd), satirlar: [s] });
    } else gruplar[yer].satirlar.push(s);
  }
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
  const saklamaYeri = ilkDolu('saklamaYeri');
  const sicaklik = numuneler.map(n => n.saklamaSicaklik).find(v => v !== null && v !== undefined);
  const saklama = saklamaYeri
    + (sicaklik !== undefined && sicaklik !== null ? ` · ${Number(sicaklik)} °C` : '');
  // Serum indeksi tupte olculur; istemde tek deger gosterilir - en KOTU olan,
  //   cunku sonucu o belirler.
  const enBuyuk = (a: string) =>
    numuneler.reduce((en, n) => Math.max(en, Number(n[a] ?? 0)), 0);
  const hemoliz = enBuyuk('hemoliz'), lipemi = enBuyuk('lipemi'), ikter = enBuyuk('ikter');
  const indeksVar = hemoliz > 0 || lipemi > 0 || ikter > 0;
  const tatlar = dizi(veri.tatlar);
  const oncekiler = dizi(veri.oncekiler);

  const tupBolumleri = (barkod: string) => {
    const ad = satirlar.filter(s => metin(s.barkod) === barkod)
                       .map(s => BOLUM[Number(s.bolum ?? 0)] ?? '')
                       .filter(Boolean);
    return [...new Set(ad)].join(' · ');
  };

  /**
   * TEK SATIRIN CIZIMI - panel icinde de disinda da AYNI.
   *
   * Gruplama eklenince satir cizimi iki yerde tekrar edecekti (panel
   * icerigi ve panelsiz tetkik); ayni hucre kurallarinin iki kopyasi
   * zamanla ayrisirdi.
   */
  const satirCiz = (s: Satir) => {
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
                          {/* GIRISIN KAYNAGI (kullanici: "sonucu elle
                              degistirdigim / girdigim bilgisi nerede"):
                              cihazdan mi elle mi, kim girdi, kacinci
                              duzeltme. Duzeltme nedeni ipucunda. */}
                          <td className="orta not"
                              title={[metin(s.giren), metin(s.duzeltmeNeden)]
                                     .filter(Boolean).join(' · ')}>
                            {metin(s.girisTuru) === 'Elle'
                              ? <span title={`Elle girildi${metin(s.giren)
                                              ? ` · ${metin(s.giren)}` : ''}`}>
                                  ✍ {metin(s.giren)}
                                </span>
                              : metin(s.girisTuru) === 'Cihaz'
                                ? <>🖧 {metin(s.cihaz) || 'Cihaz'}</>
                                : '—'}
                            {Number(s.tekrarNo ?? 0) > 0 && (
                              <span className="rozet uyari" style={{ marginLeft: 4 }}
                                    title="Düzeltilmiş sonuç">
                                {Number(s.tekrarNo)}. düzeltme
                              </span>
                            )}
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
  };
  const sol = (
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
                      <th className="orta">Giriş</th>
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
                {/* PANEL BASLIGI SATIRIN YERINDE: once butun basliklar,
                    sonra butun satirlar diye cizmek istemin sirasini
                    bozardi - grup kendi yerinde acilir. */}
                {gruplar.map(g => (
                  <Fragment key={g.panelId === 0
                    ? `t${String(g.satirlar[0]?.satirId)}` : `p${g.panelId}`}>
                    {g.panelId !== 0 && (
                      <tr className="panel-basligi">
                        <td colSpan={10}>
                          <button type="button" className="d mini"
                                  onClick={() => panelAc(g.panelId)}
                                  title={acikPaneller.has(g.panelId)
                                         ? 'Paneli kapat' : 'Paneli aç'}>
                            {acikPaneller.has(g.panelId) ? '−' : '+'}
                          </button>{' '}
                          <b>{g.ad || 'Panel'}</b>
                          <span className="not"> · {g.satirlar.length} parametre</span>
                          {/* KAC TANESI BITTI: panel KAPALIYKEN de ilerleme
                              gorunsun - acmadan "hepsi cikti mi" sorusunun
                              cevabi. */}
                          {g.satirlar.some(x => Number(x.durum ?? 1) >= 5) && (
                            <span className="not">
                              {' · '}
                              {g.satirlar.filter(x => Number(x.durum ?? 1) >= 5).length}
                              {' sonuçlandı'}
                            </span>
                          )}
                        </td>
                      </tr>
                    )}
                    {(g.panelId === 0 || acikPaneller.has(g.panelId))
                      && g.satirlar.map(s => satirCiz(s))}
                  </Fragment>
                ))}
                {satirlar.length === 0 && (
                  <tr><td colSpan={10} className="not">Bu istemde tetkik yok.</td></tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
  );

  const sag = (
      <div>
        <div className="kagrup">
          <h6>
            Hasta / İstem
            {metin(veri.protokol) &&
              <span className="sp">Protokol {metin(veri.protokol)}</span>}
          </h6>
          {/* HASTA ŞERİDİ (mockup lab_hasta_istem_karti.html): ad · yaş/
              cinsiyet · maskeli kimlik, altında dosya/protokol/kan grubu.
              Banko tüpü hastayla eşlerken ada güvenemez - aynı isimli iki
              hasta aynı gün gelir. */}
          <div className="lab-hasta">
            <div className="ad">
              {metin(veri.hasta) || '—'}
              {(metin(veri.yas) || metin(veri.cinsiyet)) && (
                <span className="rozet gri">
                  {`${metin(veri.yas)} ${metin(veri.cinsiyet)}`.trim()}
                </span>
              )}
              {metin(veri.kimlik) && <span className="rozet mavi">{metin(veri.kimlik)}</span>}
            </div>
            <div className="alt">
              {metin(veri.dosyaNo) && <span>Dosya <b>{metin(veri.dosyaNo)}</b></span>}
              {metin(veri.protokol) && <span>Protokol <b>{metin(veri.protokol)}</b></span>}
              {metin(veri.kanGrubu) && <span>Kan grubu <b>{metin(veri.kanGrubu)}</b></span>}
            </div>
          </div>
          {/* UYARI BANDI: numune alımını ya da sonucun yorumunu değiştiren
              her şey (alerji, kronik tanı). Hasta kartından gelir; bankonun
              ayrı ekran açması beklenemez. */}
          {(metin(veri.alerjiler) || metin(veri.kronik)) && (
            <div className="lab-uyari">
              {metin(veri.alerjiler) && (
                <span className={veri.agirAlerji ? 'rozet hata' : 'rozet uyari'}>
                  ⚠ {metin(veri.alerjiler)}
                </span>
              )}
              {metin(veri.kronik) && <span className="rozet uyari">{metin(veri.kronik)}</span>}
            </div>
          )}
          <div className="lab-alanlar">
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
            {/* KAYNAK: istem nereden açıldı. Dış istemde gönderen kurum -
                numunenin nereden geldiği kabul kararını değiştirir. */}
            <div className="fld" style={{ gridColumn: '1 / -1' }}>
              <label>Kaynak</label>
              <div className="deger">
                {metin(veri.kaynakAd) || '—'}
                {metin(veri.disKurum) && <span className="not">· {metin(veri.disKurum)}</span>}
              </div>
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
              <label>Saklama</label>
              <div className="deger">
                {saklama || <span className="not">—</span>}
              </div>
            </div>
            {/* SERUM İNDEKSİ: sonucun güvenilirlik ölçüsü. Eşiği aşan değer
                kırmızı - hemolizli tüpten çıkan potasyum numunenin sonucudur,
                laboratuvarın değil. */}
            <div className="fld" style={{ gridColumn: '1 / -1' }}>
              <label>Serum indeksi</label>
              <div className="deger">
                {indeksVar ? (
                  <span className="lab-sir">
                    {([['H', hemoliz], ['L', lipemi], ['İ', ikter]] as const).map(([h, d]) => (
                      <span key={h} className={d >= 3 ? 'kotu' : undefined}>{h} {d}</span>
                    ))}
                  </span>
                ) : <span className="not">ölçülmedi</span>}
              </div>
            </div>
          </div>
        </div>

        {/* SÜRE (TAT): söz verilen süre, bölüm bölüm. Yüzde ve kalan dakika
            SUNUCUDAN gelir - ekran aynı sayıyı ikinci kez türetmez. Saat
            kabulde başlar; kabul edilmemiş istemde çubuk boştur. */}
        {tatlar.length > 0 && (
          <div className="kagrup">
            <h6>
              Süre (TAT)
              <span className="sp">
                {veri.hedefBitis ? `hedef bitiş ${tarihSaat(veri.hedefBitis)}`
                                 : 'kabulde başlar'}
              </span>
            </h6>
            <div className="ic">
              {tatlar.map(t => {
                const kalan = t.kalanDk === null || t.kalanDk === undefined
                  ? null : Number(t.kalanDk);
                const yuzde = Number(t.yuzde ?? 0);
                const sinif = kalan === null ? 'lab-bar'
                            : kalan < 0 ? 'lab-bar kritik'
                            : yuzde >= 75 ? 'lab-bar uyari' : 'lab-bar';
                return (
                  <div className="lab-tat" key={String(t.bolum)}>
                    <span className="ad">{BOLUM[Number(t.bolum ?? 0)] ?? '—'}</span>
                    <span className={sinif}><i style={{ width: `${yuzde}%` }} /></span>
                    <span className={kalan === null ? 'rozet gri'
                                   : kalan < 0 ? 'rozet hata'
                                   : yuzde >= 75 ? 'rozet uyari' : 'rozet olumlu'}>
                      {kalan === null ? `${Number(t.hedefDk ?? 0)} dk hedef`
                       : kalan < 0 ? `${-kalan} dk geçti` : `${kalan} dk kaldı`}
                    </span>
                    <span className="not">{Number(t.biten ?? 0)}/{Number(t.toplam ?? 0)}</span>
                  </div>
                );
              })}
            </div>
          </div>
        )}

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

        {/* SON LABORATUVAR: aynı hastanın önceki ONAYLI sonuçları - delta
            kontrolünün dayanağı. "Yükselmiş mi" sorusu için ayrı ekran
            açtırmak, kararı geciktirirdi. */}
        {oncekiler.length > 0 && (
          <div className="kagrup">
            <h6>Son laboratuvar<span className="sp">aynı hasta</span></h6>
            <div className="ic sonuk lab-onceki">
              {oncekiler.map((o, i) => {
                const bayrak = metin(o.bayrak);
                return (
                  <span key={i}>
                    <b>{metin(o.ad)}</b> {metin(o.deger)} {metin(o.birim)}
                    {bayrak && bayrak !== 'N' && (
                      <span className={bayrakSinifi(bayrak)}>
                        {bayrak} {BAYRAK_OK[bayrak] ?? ''}
                      </span>
                    )}
                    <span className="not">{o.zaman ? tarihSaat(o.zaman) : ''}</span>
                  </span>
                );
              })}
            </div>
          </div>
        )}

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
  );

  if (kisim === 'ana') return sol;
  if (kisim === 'yan') return sag;
  return <div className="lab-ana-yan">{sol}{sag}</div>;
}

/* ---------------------------------------------------------------- kültür --
   Mockup lab_mikrobiyoloji.html .ikiPanel: solda antibiyogram, sağda okuma
   kaydı ve rapor önizleme.                                              */
/** `lab_kultur_ureme.id_yontem`. */
