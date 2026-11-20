import { useEffect, useState, type ReactNode } from 'react';
import { useParams } from 'react-router-dom';
import { acikRaporImzaliAdresi, acikRaporOku, type AcikRapor, type AcikRaporImza } from '../../api/uclar/raporGonderim';
import { gunNokta, tarihSaat } from '../../bilesenler/bicim';
import { basHarfler } from '../../bilesenler/basHarfler';
import { c } from '../../dil/ceviri';
import { RadyolojiRaporBelgesi, type RaporCiktiVerisi } from '../RadyolojiRaporCikti';
import { LabSonucRaporu } from './LabSonucRaporu';
import { raporBaglantisi } from '../../api/uclar/raporGonderim';

/**
 * AÇIK RAPOR SAYFASI `/r/{kod}` (1389; kullanıcı 20.11.2026; mockup
 * Ekranlar/Radyoloji/radyoloji_rapor_hasta_goruntuleme.html) — hastanın (kâğıttaki karekod / SMS bağlantısı) ya da
 * gönderen dış doktorun telefonunda / bilgisayarında açılan rapor. Oturum YOK, doğrulama adımı YOK (kullanıcı kararı).
 *
 *  * SOLDA e-imza paneli (imza geçerli mi, imzalayan hekim, imza zamanı, sertifika sahibi / veren kurum / geçerlilik /
 *    seri no, belge özeti, imzalı asıl belgeyi indir); telefonda tek satır + "Ayrıntı".
 *  * SAĞDA rapor - basılı çıktıyla AYNI bileşen (RadyolojiRaporBelgesi). Yazdır / PDF tarayıcının yazdırmasıyla.
 *  * Rapor GÖSTERİLMEYEN durumlar sunucudan gelir: başvurunun borcu var ("kurumla iletişime geçin" - tutar yazmaz),
 *    süresi dolmuş, rapor geri çekilmiş / güncelleniyor, imza geçersiz, bağlantı yok.
 */
export function RaporAcik() {
  const { kod = '' } = useParams();
  const [veri, setVeri] = useState<AcikRapor | null>(null);
  const [hata, setHata] = useState<string | null>(null);
  const [sekme, setSekme] = useState<'rapor' | 'belge'>('rapor');
  const [imzaAcik, setImzaAcik] = useState(false);

  useEffect(() => {
    document.title = c('Radyoloji Raporu');
    let iptal = false;
    acikRaporOku(kod).then(v => { if (!iptal) setVeri(v) }).catch(h => { if (!iptal) setHata(h instanceof Error ? h.message : String(h)) });
    return () => { iptal = true };
  }, [kod]);

  if (hata) return <Kabuk><Durum ikon="⚠" baslik={c('Rapor yüklenemedi')} metin={hata} /></Kabuk>;
  if (!veri) return <Kabuk><div className="ra-durum"><p>{c('Yükleniyor…')}</p></div></Kabuk>;

  const kurum = veri.kurum ?? {};
  const kurumAdi = String(kurum.unvan ?? '');
  const telefon = String(kurum.telefon ?? '');
  const ust = (alt: string, sag?: ReactNode) => (
    <div className="ra-ust">
      <div className="ra-logo">{basHarfler(kurumAdi, true) || '🏥'}</div>
      <div className="ra-kurum"><b>{kurumAdi || c('Radyoloji')}</b><span>{alt}</span></div>
      {sag && <div className="ra-ust-sag">{sag}</div>}
    </div>
  );
  const ozet = [veri.ozet?.tetkik, veri.ozet?.cekimTarihi ? gunNokta(veri.ozet.cekimTarihi) : ''].filter(Boolean).join(' · ');
  const ara = telefon ? <a className="d bir ra-ara" href={`tel:${telefon.replace(/[^\d+]/g, '')}`}>📞 {telefon}</a> : null;

  if (veri.durum !== 'ok') {
    const d = {
      yok: { ikon: '🔍', baslik: c('Bağlantı bulunamadı'), metin: c('Bu bağlantı geçerli değil. Adresi kontrol edin ya da kurumu arayın.') },
      // BORÇ: tutar yazmaz (bağlantıyı başkası açabilir) - yalnız iletişim.
      iletisim: { ikon: '☎', baslik: c('Raporunuz için kurumla iletişime geçin'),
                  metin: `${ozet ? ozet + ' ' : ''}${c('tarihli raporunuz şu an bu sayfadan görüntülenemiyor. Bilgi için lütfen bizi arayın.')}` },
      sure: { ikon: '⏳', baslik: c('Bağlantının süresi doldu'),
              metin: `${c('Bu bağlantı')} ${veri.sonGecerli ? gunNokta(veri.sonGecerli) : ''} ${c('tarihine kadar geçerliydi. Raporunuz için kurumu arayabilirsiniz.')}` },
      guncel: { ikon: '🔄', baslik: c('Rapor güncelleniyor'),
                metin: c('Bu rapor şu an yeniden düzenleniyor. Onaylandığında aynı bağlantıdan görüntüleyebilirsiniz.') },
      gecersiz: { ikon: '✖', baslik: c('Rapor doğrulanamadı'),
                  metin: c('Belgenin elektronik imzası doğrulanamadı. Lütfen kurumla iletişime geçin.') },
    }[veri.durum];
    return (
      <Kabuk>
        {ust(c('Radyoloji raporu'))}
        <Durum ikon={d.ikon} baslik={d.baslik} metin={d.metin} ek={ara} />
      </Kabuk>
    );
  }

  // LABORATUVAR (1394): Bakanlık Tetkik Sonuç Raporu düzeni; lab'da e-imza yok - solda onay bilgisi.
  if (veri.tur === 'lab' && veri.lab) {
    const lab = veri.lab;
    const hekim = veri.aliciTur === 2;
    const onayMetni = [lab.uzman?.ad, lab.baslik.onayZamani ? tarihSaat(lab.baslik.onayZamani) : ''].filter(Boolean).join(' · ');
    const panelSatir = (ad: string, deger: ReactNode) => <div className="ra-satir"><span>{ad}</span><b>{deger || '—'}</b></div>;
    return (
      <Kabuk>
        {ust(`${hekim ? c('Gönderen hekim') + ' · ' : ''}${c('Laboratuvar')} · ${c(lab.bolumAd)} · ${lab.baslik.protokolNo}`, <>
          <span className="ra-rozet ok">✔ {c('Onaylı')}</span>
          <button type="button" className="d" onClick={() => window.print()} title={c('Yazdırma penceresinde "PDF olarak kaydet" seçebilirsiniz.')}>
            🖨 {c('Yazdır / PDF')}</button>
        </>)}
        <button type="button" className="ra-m-imza" onClick={() => setImzaAcik(v => !v)} data-testid="rapor-acik-imza-ozet">
          <span className="ra-tik ra-tik-m">✔</span>
          <span><b>{c('Sonuçlar onaylı')}</b><span>{onayMetni}</span></span>
          <span className="ra-ok">{imzaAcik ? c('Kapat') + ' ‹' : c('Ayrıntı') + ' ›'}</span>
        </button>
        <div className="ra-govde">
          <div className={`ra-panel${imzaAcik ? ' acik' : ''}`} data-testid="rapor-acik-panel">
            <div className="ra-kutu gecerli">
              <div className="ra-buyuk"><span className="ra-tik">✔</span><div><b>{c('Sonuçlar onaylı')}</b>
                <span>{c(lab.bolumAd)} {c('bölümünün')} {lab.satirlar.length + lab.gizlenen} {c('testi uzman onayından geçti.')}</span></div></div>
            </div>
            <div className="ra-kutu"><h4>✍ {c('Onaylayan')}</h4>
              {panelSatir(c('Uzman'), lab.uzman?.ad)}
              {lab.uzman?.tescilNo && panelSatir(c('Diploma / Tescil'), lab.uzman.tescilNo)}
              {panelSatir(c('Onay zamanı'), lab.baslik.onayZamani ? tarihSaat(lab.baslik.onayZamani) : '')}
              {panelSatir(c('İsteyen hekim'), lab.baslik.isteyen)}
            </div>
            {veri.sonGecerli && <div className="ra-kutu"><h4>🔗 {c('Bağlantı')}</h4>{panelSatir(c('Geçerlilik'), `${gunNokta(veri.sonGecerli)} ${c("'a kadar")}`)}</div>}
            <div className="ra-kucuk">{c('Sonuçlar, isteyen hekiminizin değerlendirmesiyle birlikte anlam taşır. Referans aralıkları yaş ve cinsiyete göredir.')}</div>
          </div>
          <div className="ra-sag">
            <div className="ra-sekme"><button type="button" className="on">{c('Sonuçlar')}</button></div>
            <div className="ra-rapor"><LabSonucRaporu lab={lab} kurum={kurum} baglanti={raporBaglantisi(kod)} /></div>
          </div>
        </div>
      </Kabuk>
    );
  }

  const imza = veri.imza!;
  const r = veri.rapor ?? {};
  const cikti: RaporCiktiVerisi = {
    rapor: r as never, bolumler: (veri.bolumler ?? []) as never, alanlar: (veri.alanlar ?? []) as never,
    ekler: (veri.ekler ?? []) as never,
    // Logo doküman deposundan oturumla okunur - açık sayfada istenmez (yedek simge çizilir).
    kurum: { ...kurum, logoDokumanId: undefined } as never, tipografi: veri.tipografi,
  };
  const hekimSayfasi = veri.aliciTur === 2;

  return (
    <Kabuk>
      {ust(`${hekimSayfasi ? c('Gönderen hekim') + ' · ' : ''}${c('Rapor No')} ${String(r.raporNo ?? '—')}`, <>
        <span className={`ra-rozet ${imza.imzali ? 'ok' : 'sari'}`}>{imza.imzali ? `✔ ${c('e-İmzalı')}` : c('Onaylı')}</span>
        <button type="button" className="d" onClick={() => window.print()} title={c('Yazdırma penceresinde "PDF olarak kaydet" seçebilirsiniz.')}>
          🖨 {c('Yazdır / PDF')}</button>
      </>)}
      {/* Telefon: imza paneli tek satır; "Ayrıntı" tam paneli açar. */}
      <button type="button" className={`ra-m-imza${imza.imzali ? '' : ' sari'}`} onClick={() => setImzaAcik(v => !v)} data-testid="rapor-acik-imza-ozet">
        <span className={`ra-tik ra-tik-m${imza.imzali ? '' : ' sari'}`}>{imza.imzali ? '✔' : 'i'}</span>
        <span><b>{imza.imzali ? c('e-İmzalı · İmza geçerli') : c('Onaylı rapor (e-imzasız)')}</b>
          <span>{[imza.hekim, imza.zaman ? tarihSaat(imza.zaman) : r.onayTarihi ? tarihSaat(r.onayTarihi) : ''].filter(Boolean).join(' · ')}</span></span>
        <span className="ra-ok">{imzaAcik ? c('Kapat') + ' ‹' : c('Ayrıntı') + ' ›'}</span>
      </button>
      <div className="ra-govde">
        <div className={`ra-panel${imzaAcik ? ' acik' : ''}`} data-testid="rapor-acik-panel">
          <ImzaPaneli imza={imza} onayTarihi={r.onayTarihi} onaylayan={String(r.onaylayan ?? '')} sonGecerli={veri.sonGecerli} kod={kod} />
        </div>
        <div className="ra-sag">
          <div className="ra-sekme">
            <button type="button" className={sekme === 'rapor' ? 'on' : ''} onClick={() => setSekme('rapor')}>{c('Rapor')}</button>
            {imza.imzali && <button type="button" className={sekme === 'belge' ? 'on' : ''} onClick={() => setSekme('belge')}>{c('İmzalı Asıl Belge')}</button>}
          </div>
          {sekme === 'rapor'
            ? <div className="rapor-cikti ra-rapor" data-testid="rapor-acik-rapor"><RadyolojiRaporBelgesi veri={cikti} /></div>
            : (
              <div className="ra-belge">
                <h3>{c('İmzalı asıl belge')}</h3>
                <p>{c('Hukuken geçerli olan, hekimin nitelikli elektronik imzasıyla imzaladığı XML belgesidir. Sayfada gördüğünüz rapor bu belgenin içeriğidir.')}</p>
                <p>{c('Belgeyi indirip e-imza doğrulayan bir programla (örneğin kamu doğrulama servisleriyle) ayrıca doğrulayabilirsiniz.')}</p>
                <a className="d bir" href={acikRaporImzaliAdresi(kod)}>⬇ {c('İmzalı asıl belgeyi indir (.xml)')}</a>
              </div>
            )}
        </div>
      </div>
    </Kabuk>
  );
}

function Kabuk({ children }: { children: ReactNode }) {
  return <div className="ra-sayfa" data-testid="rapor-acik">{children}</div>;
}

function Durum({ ikon, baslik, metin, ek }: { ikon: string; baslik: string; metin: string; ek?: ReactNode }) {
  return (
    <div className="ra-durum" data-testid="rapor-acik-durum">
      <div className="ra-durum-ikon">{ikon}</div>
      <h2>{baslik}</h2>
      <p>{metin}</p>
      {ek}
    </div>
  );
}

function ImzaPaneli({ imza, onayTarihi, onaylayan, sonGecerli, kod }: {
  imza: AcikRaporImza; onayTarihi: unknown; onaylayan: string; sonGecerli?: string; kod: string;
}) {
  const satir = (ad: string, deger: ReactNode, mono = false) => (
    <div className="ra-satir"><span>{ad}</span><b className={mono ? 'mono' : undefined}>{deger || '—'}</b></div>
  );
  if (!imza.imzali) {
    return (
      <>
        <div className="ra-kutu">
          <div className="ra-buyuk"><span className="ra-tik sari">i</span><div><b className="sari">{c('Onaylı rapor')}</b>
            <span>{c('Bu rapor elektronik imzalı değildir; hekim onayıyla yayımlanmıştır.')}</span></div></div>
        </div>
        <div className="ra-kutu"><h4>{c('Onaylayan')}</h4>
          {satir(c('Hekim'), onaylayan || imza.hekim)}
          {satir(c('Onay zamanı'), onayTarihi ? tarihSaat(onayTarihi) : '')}
        </div>
        {sonGecerli && <div className="ra-kutu"><h4>{c('Bağlantı')}</h4>{satir(c('Geçerlilik'), `${gunNokta(sonGecerli)} ${c("'a kadar")}`)}</div>}
      </>
    );
  }
  return (
    <>
      <div className="ra-kutu gecerli">
        <div className="ra-buyuk"><span className="ra-tik">✔</span><div><b>{c('İmza geçerli')}</b>
          <span>{c('Belge imzalandıktan sonra değişmemiştir.')}</span></div></div>
      </div>
      <div className="ra-kutu"><h4>✍ {c('İmzalayan')}</h4>
        {satir(c('Hekim'), imza.hekim)}
        {imza.tescil && satir(c('Diploma / Tescil'), imza.tescil)}
        {satir(c('İmza zamanı'), imza.zaman ? tarihSaat(imza.zaman) : '')}
        {satir(c('İmza türü'), c('Elektronik imza (XAdES)'))}
      </div>
      <div className="ra-kutu"><h4>📜 {c('Sertifika')}</h4>
        {satir(c('Sahibi'), imza.sahip)}
        {satir(c('Veren kurum'), imza.veren)}
        {satir(c('Geçerlilik'), imza.gecerlilikBas && imza.gecerlilikBit ? `${gunNokta(imza.gecerlilikBas)} – ${gunNokta(imza.gecerlilikBit)}` : '')}
        {satir(c('Seri no'), imza.seriNo, true)}
      </div>
      <div className="ra-kutu"><h4>🧾 {c('Belge')}</h4>
        {imza.ozet && satir(c('Özet'), imza.ozet.length > 24 ? `${imza.ozet.slice(0, 10)}…${imza.ozet.slice(-8)}` : imza.ozet, true)}
        {sonGecerli && satir(c('Bağlantı'), `${gunNokta(sonGecerli)} ${c("'a kadar geçerli")}`)}
      </div>
      <a className="d ra-indir" href={acikRaporImzaliAdresi(kod)}>⬇ {c('İmzalı asıl belgeyi indir (.xml)')}</a>
      <div className="ra-kucuk">{c('İmzalı asıl belge hukuken geçerli olandır; e-imza doğrulayan programlarla ayrıca doğrulanabilir.')}</div>
    </>
  );
}

export default RaporAcik;
