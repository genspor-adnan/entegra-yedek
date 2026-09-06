import { Fragment, useCallback, useEffect, useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni } from '../api/sozlesme';
import { tarihSaat } from '../bilesenler/bicim';
import { BOLUM, ZIGOSITE } from '../bilesenler/labKodlari';

/**
 * LABORATUVAR SONUÇ RAPORU (mockuplar: Ekranlar/Lab/lab_sonuc_formu_*.html).
 *
 * Hastaya VERİLEN belge; çalışma ekranlarından ayrı bir sayfa çünkü işi
 * başka: orada süreç yürütülür (kabul, okuma, izolat, varyant), burada
 * onaylanmış sonuç kurum anteti ve kimlik satırlarıyla basılabilir hale
 * gelir.
 *
 * <b>Tek sayfa, üç bölüm.</b> Bir istemde sayısal tetkik, kültür ve genetik
 * birlikte bulunabilir; hangisi doluysa o bölüm basılır. Üç ayrı çıktı
 * sayfası, aynı hastanın aynı istemini üç kâğıda bölerdi.
 *
 * <b>Yazdırma tarayıcınındır</b> ("PDF olarak kaydet" orada). Ayrı bir sunucu
 * PDF üreticisi YOK - aynı çıktının iki üretim yolu, birinin diğerinden
 * sapması demektir (radyoloji çıktısıyla aynı karar).
 */

type Satir = Record<string, unknown>;

const gun = (v: unknown): string => {
  const m = String(v ?? '').slice(0, 10);
  return /^\d{4}-\d{2}-\d{2}$/.test(m) ? m.split('-').reverse().join('.') : '';
};

const yas = (dogum: unknown): string => {
  const m = String(dogum ?? '').slice(0, 10);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(m)) return '';
  const d = new Date(m), b = new Date();
  let y = b.getFullYear() - d.getFullYear();
  const ay = b.getMonth() - d.getMonth();
  if (ay < 0 || (ay === 0 && b.getDate() < d.getDate())) y--;
  return String(y);
};

const CINSIYET: Record<number, string> = { 1: 'Erkek', 2: 'Kadın' };

/** Bayrak → rapor gösterimi. Boş bayrak "değerlendirilmedi" demektir. */
const BAYRAK: Record<string, string> = {
  LL: '↓↓ Panik düşük', HH: '↑↑ Panik yüksek', L: '↓ Düşük', H: '↑ Yüksek', N: 'Normal',
};

const KALITIM: Record<number, string> = {
  1: 'OD', 2: 'OR', 3: 'X’e bağlı', 4: 'Mitokondriyal',
};

const SINIF: Record<number, string> = {
  1: 'Benign (1)', 2: 'Olası benign (2)', 3: 'VUS (3)',
  4: 'Olası patojenik (4)', 5: 'Patojenik (5)',
};

const ID_YONTEM: Record<number, string> = {
  1: 'MALDI-TOF MS', 2: 'Otomatize sistem (VITEK)', 3: 'Manuel testler',
  4: 'Moleküler',
};

const GEN_YONTEM: Record<number, string> = {
  1: 'NGS panel (hedef zenginleştirme)', 2: 'Tüm ekzom dizileme (WES)',
  3: 'Tüm genom dizileme (WGS)', 4: 'PCR / RT-PCR', 5: 'Sanger dizileme',
  6: 'Karyotip', 7: 'MLPA', 8: 'Mikroarray',
};

/** "0 bakılmadı · 1 negatif · 2 pozitif" - üçü ayrı bilgi. */
const direncMetni = (izolat: Satir): string => {
  const bak = (alan: string, ad: string) => {
    const v = Number(izolat[alan] ?? 0);
    return v === 0 ? '' : `${ad}: ${v === 2 ? 'Pozitif' : 'Negatif'}`;
  };
  return [bak('esbl', 'ESBL'), bak('karbapenemaz', 'Karbapenemaz'),
          bak('mrsa', 'MRSA'), bak('vre', 'VRE'), bak('ampc', 'AmpC')]
    .filter(Boolean).join(' · ');
};

const sayiMetni = (v: unknown, basamak = 2): string => {
  if (v === null || v === undefined || v === '') return '';
  const s = Number(v);
  return Number.isFinite(s) ? s.toLocaleString('tr-TR',
    { maximumFractionDigits: basamak }) : String(v);
};

export function LabRaporCikti() {
  const { id } = useParams();
  const git = useNavigate();
  const [veri, setVeri] = useState<{
    istem: Satir; sonuclar: Satir[]; kulturler: Satir[]; izolatlar: Satir[];
    antibiyogram: Satir[]; vakalar: Satir[]; varyantlar: Satir[]; kurum: Satir | null;
  } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { setVeri(await api.labRaporCikti(Number(id)) as never) }
    catch (h) { setHata(hataMetni(h)) }
  }, [id]);

  useEffect(() => { void yukle() }, [yukle]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!veri) return <div className="yukleniyor">Yükleniyor…</div>;

  const i = veri.istem;
  const k = veri.kurum ?? {};
  const adresSatiri = [k.adres, [k.ilce, k.il].filter(Boolean).join(' / ')]
    .filter(x => String(x ?? '').trim() !== '').join(' · ');

  const sayisal = veri.sonuclar;
  const kulturVar = veri.kulturler.length > 0;
  const genetikVar = veri.vakalar.length > 0;
  // Rapor "nihai" ancak basılacak her parça onaylıysa: kültür/vaka onayı
  //   ayrı ayrı denetlenir, biri bile açıksa çıktı TASLAK damgası taşır.
  const tamam = (sayisal.length > 0 || kulturVar || genetikVar)
    && veri.kulturler.every(x => Number(x.durum ?? 0) === 7)
    && veri.vakalar.every(x => Number(x.durum ?? 0) === 7);

  const baslik = genetikVar ? 'GENETİK TEST RAPORU'
    : kulturVar ? 'KÜLTÜR VE ANTİBİYOGRAM SONUÇ RAPORU'
    : 'LABORATUVAR SONUÇ RAPORU';

  const panikVar = sayisal.some(s => Number(s.panik ?? 0) === 1);

  return (
    <div className="rapor-cikti">
      {/* Araç çubuğu YAZDIRILMAZ (@media print) - kâğıtta yalnız belge kalır. */}
      <div className="cikti-arac">
        <button className="d bir" onClick={() => window.print()}>🖨 Yazdır</button>
        <button className="d" onClick={() => window.print()}
                title="Yazdırma penceresinde “PDF olarak kaydet” seçin.">
          📄 PDF
        </button>
        <button className="d" disabled title="Hasta portalı henüz yok.">
          🔗 Hasta Portalı Bağlantısı
        </button>
        <span style={{ marginLeft: 'auto' }} />
        {!tamam && (
          <span className="rozet uyari" style={{ marginRight: 8 }}>
            Tüm sonuçlar onaylanmadı — bu çıktı TASLAKTIR
          </span>
        )}
        <button className="d" onClick={() => git(-1)}>✖ Kapat</button>
      </div>

      <div className="cikti-sayfa">
        {/* --- KURUM ANTETİ --- */}
        <div className="kbaslik">
          <div className="logo">🧪</div>
          <div>
            <h1>{String(k.unvan ?? '—')}</h1>
            <div className="alt">
              Tıbbi Laboratuvar{genetikVar ? ' · Tıbbi Genetik'
                : kulturVar ? ' · Tıbbi Mikrobiyoloji' : ''}
              {adresSatiri ? ` · ${adresSatiri}` : ''}<br />
              {[k.telefon ? `Tel: ${k.telefon}` : '',
                k.vkno ? `VKN ${k.vkno}` : ''].filter(Boolean).join(' · ')}
            </div>
          </div>
          <div className="sag">
            İstem No: <b>{String(i.istemNo ?? '—')}</b><br />
            Protokol: {String(i.protokolNo ?? '—')}<br />
            {genetikVar && veri.vakalar[0].vakaNo
              ? <>Vaka No: {String(veri.vakalar[0].vakaNo)}</>
              : <>Barkod: {String(sayisal[0]?.barkod ?? veri.kulturler[0]?.barkod ?? '—')}</>}
          </div>
        </div>

        <div className="rapadi">{baslik}{!tamam && ' — TASLAK'}</div>

        {/* --- KİMLİK --- */}
        <div className="kimlik">
          <div><span className="et">Hasta</span>
               <span className="dg">{String(i.hastaAdi ?? '—')}</span></div>
          <div><span className="et">Hasta No</span>
               <span className="dg">{String(i.hastaNo ?? '—')}</span></div>
          <div>
            <span className="et">Doğum T. / Yaş</span>
            <span className="dg">
              {[gun(i.dogumTarihi), yas(i.dogumTarihi), CINSIYET[Number(i.cinsiyet ?? 0)]]
                .filter(Boolean).join(' · ') || '—'}
            </span>
          </div>
          <div><span className="et">T.C. No</span>
               <span className="dg">{String(i.hastaTc ?? '—')}</span></div>
          <div><span className="et">İsteyen Hekim</span>
               <span className="dg">{String(i.isteyenHekim ?? '') || '—'}</span></div>
          <div><span className="et">Ödeyen</span>
               <span className="dg">{String(i.odeyenKurum ?? '') || 'Hasta kendi öder'}</span></div>
          <div><span className="et">Numune Alım</span>
               <span className="dg">{i.numuneAlim ? tarihSaat(i.numuneAlim) : '—'}</span></div>
          {/* TAT KABULDE BAŞLAR: raporda ikisi de görünür, gecikmenin
              laboratuvardan mı numune naklinden mi geldiği ayrılabilsin. */}
          <div><span className="et">Lab Kabul</span>
               <span className="dg">{i.numuneKabul ? tarihSaat(i.numuneKabul) : '—'}</span></div>
          <div><span className="et">İstem Tarihi</span>
               <span className="dg">{i.istemTarihi ? tarihSaat(i.istemTarihi) : '—'}</span></div>
          <div><span className="et">Rapor Tarihi</span>
               <span className="dg">{i.sonucTarihi ? tarihSaat(i.sonucTarihi) : '—'}</span></div>
        </div>

        {String(i.klinikBilgi ?? '').trim() !== '' && (
          <div className="rapor-bolum">
            <h3>Klinik Bilgi</h3>
            <p>
              {String(i.klinikBilgi)}
              {String(i.taniIcd ?? '').trim() !== '' && ` · Ön tanı: ${i.taniIcd}`}
            </p>
          </div>
        )}

        {/* ================================================ SAYISAL SONUÇLAR */}
        {sayisal.length > 0 && (
          <div className="rapor-bolum">
            <h3>Sonuçlar</h3>
            <table className="cikti-tablo">
              <thead>
                <tr>
                  <th>Tetkik</th><th>Sonuç</th><th>Birim</th>
                  <th>Referans</th><th>Değerlendirme</th><th>Yöntem</th>
                </tr>
              </thead>
              <tbody>
                {sayisal.map((s, n) => {
                  // BÖLÜM BAŞLIĞI: biyokimya/hematoloji/hormon aynı kâğıtta
                  //   art arda basılır; ayraç olmadan hangi değerin hangi
                  //   bölümden geldiği kaybolur.
                  const oncekiBolum = n > 0 ? Number(sayisal[n - 1].bolum ?? 0) : -1;
                  const bolumBasi = Number(s.bolum ?? 0) !== oncekiBolum;
                  const ref = String(s.referansMetin ?? '').trim() !== ''
                    ? String(s.referansMetin)
                    : (s.referansAlt !== null || s.referansUst !== null)
                      ? `${sayiMetni(s.referansAlt)} – ${sayiMetni(s.referansUst)}`
                      : '';
                  const bayrak = String(s.bayrak ?? '');
                  // Fragment'e KEY verilir: bölüm ayracı + sonuç satırı
                  //   tek öğe olarak döndüğü için anahtar dıştaki parçada
                  //   olmalı, yoksa React her yeniden çizimde listeyi
                  //   baştan kurar.
                  return (
                    <Fragment key={n}>
                    {bolumBasi && (
                      <tr>
                        <td colSpan={6} className="bolum-ayrac">
                          {BOLUM[Number(s.bolum ?? 0)] ?? 'Diğer'}
                        </td>
                      </tr>
                    )}
                    <tr className={Number(s.panik ?? 0) === 1 ? 'panik' : ''}>
                      <td>
                        {String(s.ad ?? '')}
                        <span className="kod"> {String(s.kod ?? '')}</span>
                        {Number(s.tekrarNo ?? 0) > 0 && (
                          <span className="not"> · düzeltilmiş sonuç</span>
                        )}
                      </td>
                      <td className="sag"><b>{String(s.deger ?? '')}</b></td>
                      <td>{String(s.birim ?? '')}</td>
                      <td>{ref || '—'}</td>
                      <td className={bayrak === 'LL' || bayrak === 'HH' ? 'vurgu' : ''}>
                        {/* Bayrak yoksa "referans tanımlı değil" yazılır:
                            boş hücre "normal" gibi okunurdu. */}
                        {BAYRAK[bayrak] ?? (ref ? '—' : 'Referans tanımlı değil')}
                        {Number(s.deltaUyari ?? 0) === 1 && (
                          <div className="not">
                            Delta uyarısı · önceki {sayiMetni(s.deltaOnceki)}
                            {s.deltaYuzde ? ` (%${sayiMetni(s.deltaYuzde, 1)})` : ''}
                          </div>
                        )}
                        {String(s.indeksUyari ?? '').trim() !== '' && (
                          <div className="not">{String(s.indeksUyari)}</div>
                        )}
                      </td>
                      <td>{String(s.yontem ?? '') || String(s.cihazAdi ?? '') || '—'}</td>
                    </tr>
                    </Fragment>
                  );
                })}
              </tbody>
            </table>
            {/* NUMUNE KALİTESİ raporun zorunlu parçası (ISO 15189): "K
                yüksek" ile "hemoliz nedeniyle yüksek görünüyor" hekim için
                bambaşka iki bilgi. Etkilenen satırın uyarısı ayrıca yazılır. */}
            {sayisal.some(s => String(s.indeksUyari ?? '').trim() !== '') && (
              <p className="uyari-satir">
                Numune kalitesi uyarısı:{' '}
                {sayisal
                  .filter(s => String(s.indeksUyari ?? '').trim() !== '')
                  .map(s => `${String(s.kod ?? '')} — ${String(s.indeksUyari)}`)
                  .join(' · ')}
              </p>
            )}
            {(sayisal[0]?.hemolizIdx !== null && sayisal[0]?.hemolizIdx !== undefined)
              || (sayisal[0]?.lipemiIdx !== null && sayisal[0]?.lipemiIdx !== undefined)
              || (sayisal[0]?.ikterIdx !== null && sayisal[0]?.ikterIdx !== undefined)
              ? (
              <p className="not">
                Numune kalitesi (serum indeksleri):{' '}
                {[sayisal[0].hemolizIdx !== null && sayisal[0].hemolizIdx !== undefined
                    ? `hemoliz ${sayiMetni(sayisal[0].hemolizIdx, 0)}` : '',
                  sayisal[0].lipemiIdx !== null && sayisal[0].lipemiIdx !== undefined
                    ? `lipemi ${sayiMetni(sayisal[0].lipemiIdx, 0)}` : '',
                  sayisal[0].ikterIdx !== null && sayisal[0].ikterIdx !== undefined
                    ? `ikter ${sayiMetni(sayisal[0].ikterIdx, 0)}` : ''
                 ].filter(Boolean).join(' · ')}
              </p>
            ) : null}
            {panikVar && (
              <p className="uyari-satir">
                ↑↑ / ↓↓ ile işaretli değerler PANİK DEĞER sınırındadır ve isteyen
                hekime bildirilmiştir.
              </p>
            )}
          </div>
        )}

        {/* ====================================================== MİKROBİYOLOJİ */}
        {veri.kulturler.map(kul => {
          const kid = Number(kul.id);
          const izolat = veri.izolatlar.filter(u => Number(u.kulturId) === kid);
          return (
            <div className="rapor-bolum" key={`k${kid}`}>
              <h3>{String(kul.ad ?? 'Kültür')} — Sonuç</h3>
              <table className="cikti-tablo">
                <tbody>
                  <tr><td className="et">Numune / Ön işlem</td>
                      <td>{[String(kul.barkod ?? ''), String(kul.numuneKalite ?? '')]
                            .filter(Boolean).join(' · ') || '—'}</td></tr>
                  <tr><td className="et">Direkt bakı</td>
                      <td>{String(kul.gramSonuc ?? '') || String(kul.direktBaki ?? '') || '—'}</td></tr>
                  <tr><td className="et">Besiyeri / ekim</td>
                      <td>{[String(kul.besiyeri ?? ''),
                            kul.ekimZamani ? tarihSaat(kul.ekimZamani) : '']
                            .filter(Boolean).join(' · ') || '—'}</td></tr>
                  <tr><td className="et">Üreme</td>
                      <td><b>{String(kul.ozet ?? '')}</b></td></tr>
                </tbody>
              </table>

              {izolat.map(u => {
                const ab = veri.antibiyogram.filter(g => Number(g.uremeId) === Number(u.id));
                const direnc = direncMetni(u);
                const standart = ab.length > 0
                  ? [String(ab[0].standart ?? ''), String(ab[0].standartSurum ?? '')]
                      .filter(Boolean).join(' ')
                  : '';
                return (
                  <div key={`u${u.id}`} style={{ marginTop: 10 }}>
                    <div className="alt-baslik">
                      İzolat #{String(u.izolatNo)} · {String(u.organizma ?? '')}
                      {u.koloniSayisi
                        ? ` — ${sayiMetni(u.koloniSayisi, 0)} ${String(u.koloniBirim ?? '')}`
                        : ''}
                      {Number(u.bildirimiZorunlu ?? 0) === 1 && (
                        <span className="rozet uyari" style={{ marginLeft: 6 }}>
                          Bildirimi zorunlu etken
                        </span>
                      )}
                    </div>
                    <div className="not">
                      İdentifikasyon: {ID_YONTEM[Number(u.idYontem ?? 1)] ?? '—'}
                      {u.idGuven ? ` · güven %${sayiMetni(u.idGuven, 1)}` : ''}
                      {direnc ? ` · ${direnc}` : ''}
                      {String(u.direncNotu ?? '').trim() !== '' ? ` · ${u.direncNotu}` : ''}
                    </div>

                    {ab.length > 0 && (
                      <>
                        <table className="cikti-tablo" style={{ marginTop: 6 }}>
                          <thead>
                            <tr>
                              <th>Antibiyotik</th><th>MIC (µg/mL)</th>
                              <th>Zon (mm)</th><th>Yorum</th><th>Not</th>
                            </tr>
                          </thead>
                          <tbody>
                            {ab.map((g, n) => (
                              <tr key={n}>
                                <td>{String(g.antibiyotik ?? '')}</td>
                                <td className="sag">
                                  {g.mic !== null && g.mic !== undefined
                                    ? `${String(g.micIsaret ?? '')} ${sayiMetni(g.mic, 3)}`.trim()
                                    : '—'}
                                </td>
                                <td className="sag">{g.zonMm ? String(g.zonMm) : '—'}</td>
                                <td><b>{String(g.yorum ?? '')}</b></td>
                                <td>
                                  {String(g.aciklama ?? '')}
                                  {Number(g.yalnizUriner ?? 0) === 1
                                    && ' Yalnız alt üriner sistem enfeksiyonu için.'}
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                        <p className="not">
                          S = duyarlı (standart doz) · I = artırılmış maruziyette
                          duyarlı · R = dirençli
                          {standart ? ` · Yorum standardı: ${standart}` : ''}.
                          {/* KADEMELİ BİLDİRİM raporda da uygulanır: gizlenen
                              ajanı basmak, kuralı anlamsız kılardı. */}
                          {' '}Akılcı antibiyotik kullanımı gereği kademeli bildirim
                          uygulanmıştır; gerektiğinde ek ajanlar laboratuvardan
                          istenebilir.
                        </p>
                      </>
                    )}
                  </div>
                );
              })}

              {String(kul.onRapor ?? '').trim() !== '' && (
                <p className="not" style={{ marginTop: 8 }}>
                  Ön rapor{kul.onRaporZamani ? ` (${tarihSaat(kul.onRaporZamani)})` : ''}:
                  {' '}{String(kul.onRapor)}
                </p>
              )}
              {String(kul.uzmanYorum ?? '').trim() !== '' && (
                <p style={{ marginTop: 8 }}>
                  <b>Uzman yorumu:</b> {String(kul.uzmanYorum)}
                </p>
              )}
              {Number(kul.ekkBildirim ?? 0) === 1 && (
                <p className="uyari-satir">
                  Bu izolat enfeksiyon kontrol komitesine bildirilmiştir.
                </p>
              )}
            </div>
          );
        })}

        {/* ============================================================ GENETİK */}
        {veri.vakalar.map(v => {
          const vid = Number(v.id);
          const vars = veri.varyantlar.filter(x => Number(x.vakaId) === vid);
          return (
            <div className="rapor-bolum" key={`g${vid}`}>
              <h3>Genetik İnceleme — {String(v.panel ?? v.ad ?? '')}</h3>

              <table className="cikti-tablo">
                <tbody>
                  <tr><td className="et">Test / kapsam</td>
                      <td>{[String(v.panel ?? ''), GEN_YONTEM[Number(v.yontem ?? 1)],
                            String(v.referansGenom ?? '')].filter(Boolean).join(' · ')}</td></tr>
                  {/* ONAM RAPORDA GÖRÜNÜR: tesadüfi bulgu tercihi neyin
                      raporlanmadığını açıklar (KVKK md. 6). */}
                  <tr><td className="et">Onam</td>
                      <td>
                        {String(v.onamSurum ?? '') || 'Kayıtlı değil'}
                        {v.onamTarihi ? ` · ${gun(v.onamTarihi)}` : ''}
                        {Number(v.tesadufiBulgu ?? 0) === 2
                          ? ' · tesadüfi bulgu: istemiyor'
                          : Number(v.tesadufiBulgu ?? 0) === 1
                            ? ' · tesadüfi bulgu: istiyor' : ''}
                      </td></tr>
                  <tr><td className="et">Sonuç</td>
                      <td><b>{String(v.ozet ?? '')}</b></td></tr>
                </tbody>
              </table>

              {vars.length > 0 && (
                <>
                  <div className="alt-baslik" style={{ marginTop: 10 }}>
                    Raporlanan varyantlar (ACMG/AMP 2015 + ClinGen)
                  </div>
                  <table className="cikti-tablo">
                    <thead>
                      <tr>
                        <th>Gen</th><th>Transkript · HGVS c.</th><th>HGVS p.</th>
                        <th>Zigosite</th><th>Kalıtım</th><th>gnomAD AF</th>
                        <th>ClinVar</th><th>ACMG kanıtları</th><th>Sınıf</th>
                      </tr>
                    </thead>
                    <tbody>
                      {vars.map((x, n) => (
                        <tr key={n} className={Number(x.sinif ?? 0) >= 4 ? 'panik' : ''}>
                          <td><b>{String(x.genSembol ?? '')}</b></td>
                          <td>
                            {[String(x.transkript ?? ''), String(x.hgvsC ?? '')]
                              .filter(Boolean).join(':')}
                          </td>
                          <td>{String(x.hgvsP ?? '') || '—'}</td>
                          <td>{ZIGOSITE[Number(x.zigosite ?? 1)]}</td>
                          <td>{KALITIM[Number(x.kalitim ?? 0)] ?? '—'}</td>
                          <td className="sag">
                            {x.gnomadAf !== null && x.gnomadAf !== undefined
                              ? Number(x.gnomadAf).toExponential(1) : '—'}
                          </td>
                          <td>{String(x.clinvar ?? '') || '—'}</td>
                          <td>{(x.acmgKriterler as string[] | null)?.join(' · ') || '—'}</td>
                          <td><b>{SINIF[Number(x.sinif ?? 3)]}</b></td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                  <p className="not">
                    Sınıf tanımları: 5 patojenik · 4 olası patojenik · 3 klinik önemi
                    belirsiz (VUS) · 2 olası benign · 1 benign. Nomenklatür: HGVS.
                    {vars.some(x => Number(x.dogrulama ?? 0) === 2) && (
                      ' Patojenik varyant(lar) ikinci yöntemle doğrulanmıştır'
                      + (vars.find(x => Number(x.dogrulama ?? 0) === 2)?.dogrulamaYontem
                          ? ` (${vars.find(x => Number(x.dogrulama ?? 0) === 2)!
                                .dogrulamaYontem}).` : '.')
                    )}
                    {Number(v.tesadufiBulgu ?? 0) === 2 && (
                      ' Benign varyantlar ve tesadüfi (ikincil) bulgular hasta '
                      + 'tercihi doğrultusunda raporlanmamıştır.'
                    )}
                  </p>
                </>
              )}

              {String(v.uzmanYorum ?? '').trim() !== '' && (
                <p style={{ marginTop: 8 }}><b>Yorum:</b> {String(v.uzmanYorum)}</p>
              )}
              {String(v.oneriler ?? '').trim() !== '' && (
                <p style={{ marginTop: 6 }}><b>Öneriler:</b> {String(v.oneriler)}</p>
              )}

              {/* YÖNTEM ve KALİTE raporun zorunlu parçası: kapsanamayan
                  bölgede "varyant yok" demek, bakılamayanı temiz saymaktır. */}
              <div className="alt-baslik" style={{ marginTop: 10 }}>Yöntem ve kalite</div>
              <p className="not">
                DNA izolasyonu{v.izolasyonTarihi ? ` (${gun(v.izolasyonTarihi)})` : ''}
                {v.dnaKonsantrasyon
                  ? ` · ${sayiMetni(v.dnaKonsantrasyon)} ng/µL · A260/280 ${sayiMetni(v.dnaSaflik, 3)}`
                  : ''}
                {String(v.cihaz ?? '').trim() !== '' ? ` · ${v.cihaz}` : ''}
                {String(v.runKodu ?? '').trim() !== '' ? ` · ${v.runKodu}` : ''}
                {v.q30 ? ` · Q30 %${sayiMetni(v.q30, 1)}` : ''}
                {v.ortDerinlik ? ` · ortalama derinlik ${sayiMetni(v.ortDerinlik, 0)}×` : ''}
                {v.kapsamaYuzde
                  ? ` · hedefin %${sayiMetni(v.kapsamaYuzde, 1)}’i ≥20×` : ''}
                {v.kontaminasyon !== null && v.kontaminasyon !== undefined
                  ? ` · kontaminasyon %${sayiMetni(v.kontaminasyon, 1)}` : ''}
                {Number(v.cinsiyetDogrulama ?? 0) === 1 ? ' · cinsiyet doğrulama uyumlu'
                  : Number(v.cinsiyetDogrulama ?? 0) === 2 ? ' · cinsiyet doğrulama UYUMSUZ' : ''}
                {String(v.pipeline ?? '').trim() !== '' ? ` · ${v.pipeline}` : ''}
              </p>
              {String(v.sinirliliklar ?? '').trim() !== '' && (
                <p className="not"><b>Sınırlılıklar:</b> {String(v.sinirliliklar)}</p>
              )}
              {String(v.genListesi ?? '').trim() !== '' && (
                <p className="not"><b>Gen listesi:</b> {String(v.genListesi)}</p>
              )}
              {Number(v.veriSaklamaYil ?? 0) > 0 && (
                <p className="not">
                  Ham veri (FASTQ/BAM/VCF) hasta onamı doğrultusunda
                  {' '}{String(v.veriSaklamaYil)} yıl saklanır; istek üzerine VCF verilir.
                  Genetik veriler özel nitelikli kişisel veridir (KVKK md. 6);
                  paylaşım yalnız hasta onamıyla yapılır.
                </p>
              )}
            </div>
          );
        })}

        {/* --- İMZA --- */}
        <div className="imza">
          <div className="imzak">
            <div className="cizgi" />
            <b>
              {String(veri.vakalar[0]?.onaylayan
                   ?? veri.kulturler[0]?.onaylayan
                   ?? sayisal[0]?.onaylayan ?? '') || '—'}
            </b><br />
            {genetikVar ? 'Tıbbi Genetik Uzmanı'
              : kulturVar ? 'Tıbbi Mikrobiyoloji Uzmanı' : 'Laboratuvar Uzmanı'}
            {tamam && (
              <div className="eimza">
                ✓ Elektronik olarak onaylandı
                {veri.vakalar[0]?.onayZamani ? ` · ${tarihSaat(veri.vakalar[0].onayZamani)}`
                  : veri.kulturler[0]?.onayZamani ? ` · ${tarihSaat(veri.kulturler[0].onayZamani)}`
                  : sayisal[0]?.onayZamani ? ` · ${tarihSaat(sayisal[0].onayZamani)}` : ''}
              </div>
            )}
          </div>
        </div>

        <div className="dipnot">
          Bu rapor yalnızca yukarıda belirtilen numuneye aittir; klinik bulgular ve
          diğer tetkiklerle birlikte değerlendirilmelidir.
          {sayisal.length > 0 && ' Referans aralıkları laboratuvarın kullandığı '
            + 'yönteme özgüdür ve sonucun verildiği tarihteki hâliyle basılmıştır.'}
          {genetikVar && ' Genetik rapor, genetik danışmanlık eşliğinde '
            + 'değerlendirilmelidir; varyant sınıflaması bilimsel bilgi geliştikçe '
            + 'değişebilir.'}
        </div>
      </div>
    </div>
  );
}
