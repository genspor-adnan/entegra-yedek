import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import {
  FARK_NEDENLERI,
  type OturumCek, type OturumIslem, type OturumOzeti, type PosEslesme, type TurOzeti,
  type UygunBanko, type VardiyaSecenek,
} from '../../api/uclar/bankoOturum';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { useOturum } from '../../kimlik/OturumBaglami';

/**
 * BANKO OTURUMU `/banko-oturum` (987) — mockup
 * Ekranlar/Kayıt Kabul/banko_oturum_akisi_v2.html.
 *
 * Altı adımın tamamı TEK sayfada, oturumun durumuna göre: açılış talebi →
 * (ops.) sorumlu onayı → devir sayımı → gün içi şerit → gün sonu sayımı →
 * teslim ve kapanış. Ayrı ekranlara bölmek, görevliyi "şimdi hangi ekranda
 * olmalıyım" sorusuyla baş başa bırakırdı; akış şeridi hangi adımda
 * olunduğunu söylüyor.
 *
 * DEVİR SUNUCUDAN GELİR ve yazılamaz (`fn_banko_devir`): önceki oturumun
 * kasada bıraktığı tutar. Görevli yalnız SAYIMI girer, farkı sunucu hesaplar.
 *
 * KUPÜR DÖKÜMÜ toplamı sayım alanını besler: "7.140 saydım" ile
 * "20x200 + 22x100 + …" denetimde aynı şey değil. Bankoda kupür dökümü
 * kapalıysa (banko ayarı) tutar elle girilir.
 */
const ADIMLAR = [
  'Oturum talebi', 'Sorumlu onayı', 'Devir sayımı',
  'Gün içi işlem', 'Gün sonu sayım', 'Teslim & kapanış',
];

/**
 * Oturum durumundan akış şeridindeki etkin adım (1 tabanlı). `gunSonu` formu
 * açıkken 5. adım gösterilir: durum hâlâ "açık" ama görevli artık sayımda.
 */
function etkinAdim(o: OturumOzeti | null, gunSonu = false): number {
  if (!o) return 1;
  if (o.durum === 1) return 2;
  if (o.durum === 2) return gunSonu ? 5 : 4;
  if (o.durum === 3) return 6;
  if (o.durum === 4) return 6;
  return 1;                                    // reddedildi: baştan
}

const para = (n: number) =>
  n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
const saat = (t: string | null) =>
  t ? new Date(t).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' }) : '—';
/** Gün içi tabloda yalnız saat - oturum zaten tek güne ait. */
const saatKisa = (t: string) =>
  new Date(t).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });

export function BankoOturumu({ gomulu, acilisBanko, oturumId, onKapat }: {
  /** Modal içinde çizilir: kendi sayfa kabuğunu ve başlığını kurmaz. */
  gomulu?: boolean;
  /** Bankolar listesinden seçilen banko (modal kullanımı). */
  acilisBanko?: number;
  /**
   * BELİRLİ BİR OTURUM (oturum geçmişinden "Düzenle"): verilmezse kullanıcının
   * kendi canlı oturumu açılır. Kapanmış oturum da açılabilir - akış salt
   * okuma durur, tutanak oradan basılır.
   */
  oturumId?: number;
  onKapat?: () => void;
} = {}) {
  const { yetki } = useOturum();
  const git = useNavigate();
  // Banko ya prop'tan (modal) ya adresten gelir: görevli bankosunu listede
  //   bulduysa burada yeniden aramasın.
  const [arama] = useSearchParams();
  const istenenBanko = acilisBanko || Number(arama.get('banko') ?? 0);
  const [oturum, setOturum] = useState<OturumOzeti | null>(null);
  const [bankolar, setBankolar] = useState<UygunBanko[]>([]);
  const [hata, setHata] = useState<string | null>(null);
  const [yukleniyor, setYukleniyor] = useState(true);

  // açılış formu
  const [bankoId, setBankoId] = useState(0);
  // VARDİYA SEÇENEKLİ (994): serbest metin yerine kod + saat. Saatler kurum
  //   ayarından geliyor; seçim değişince öneri saatler forma yazılır,
  //   kullanıcı yine elle düzeltebilir.
  const [vardiyalar, setVardiyalar] = useState<VardiyaSecenek[]>([]);
  const [vardiyaKod, setVardiyaKod] = useState(0);
  // SAAT ARALIĞI İKİ FORMATLI ALAN, YAN YANA ve DAR (kullanıcı 08.10.2026:
  //   "yine önceki gibi formatlı 2 edit olsun ama geniş olmasın"). Biçimi
  //   tarayıcı tutuyor (type=time); sunucuya "18:00-08:00" olarak birleşip
  //   gidiyor, ayrıştırma ve doğrulama orada - biçimi iki yerde kontrol
  //   etmek birinin gevşemesi demekti.
  const [vBas, setVBas] = useState('');
  const [vBit, setVBit] = useState('');
  const [acilisTutar, setAcilisTutar] = useState('');
  const [acilisNot, setAcilisNot] = useState('');

  // gün sonu formu
  const [gunSonu, setGunSonu] = useState(false);
  const [turler, setTurler] = useState<TurOzeti[]>([]);
  const [poslar, setPoslar] = useState<PosEslesme[]>([]);
  const [posGiris, setPosGiris] = useState<Record<number, string>>({});
  const [posAtanmamis, setPosAtanmamis] = useState<{ toplam: number; adet: number } | null>(null);
  const [cekler, setCekler] = useState<OturumCek[]>([]);
  const [islemler, setIslemler] = useState<OturumIslem[]>([]);
  const [kapanisTutar, setKapanisTutar] = useState('');
  const [farkNeden, setFarkNeden] = useState(0);
  const [farkAciklama, setFarkAciklama] = useState('');
  const [birakilan, setBirakilan] = useState('');

  const yukle = useCallback(async () => {
    try {
      // Belirli oturum istendiyse onu getir; yoksa kullanıcının canlı oturumu.
      const y = oturumId
        ? { oturum: (await api.bankoOturumGetir(oturumId)).oturum }
        : await api.bankoOturumAktif();
      setOturum(y.oturum);
      if (!y.oturum) {
        const y2 = await api.bankoOturumUygun();
        const b = y2.bankolar ?? [];
        setBankolar(b);
        setVardiyalar(y2.vardiyalar ?? []);
        setBankoId(p => {
          // Sıra: URL'den istenen > zaten seçili > listenin ilki.
          if (istenenBanko && b.some(x => x.id === istenenBanko)) return istenenBanko;
          return p && b.some(x => x.id === p) ? p : b[0]?.id ?? 0;
        });
      }
      setHata(null);
    } catch (h) { setHata(hataMetni(h)) } finally { setYukleniyor(false) }
  }, [istenenBanko, oturumId]);

  useEffect(() => { void yukle() }, [yukle]);

  // ODEME TURU DOKUMU oturum acikken anlamli: gun ici her tahsilat satirini
  //   tura gore toplar. Oturum yoksa cagrilmaz - bos tablo cizmek icin
  //   istek atmak gereksiz.
  useEffect(() => {
    if (!oturum) { setTurler([]); return }
    let iptal = false;
    (async () => {
      try {
        const d = await api.bankoOturumGetir(oturum.id);
        if (iptal) return;
        setTurler(d.turler ?? []);
        setPoslar(d.pos ?? []);
        setPosAtanmamis(d.posAtanmamis ?? null);
        setCekler(d.cekler ?? []);
        setIslemler(d.islemler ?? []);
        // Girilmis cihaz toplamlari forma yazilir: gun sonu yarim kalip
        //   tekrar acildiginda bastan girilmesin.
        setPosGiris(o => {
          const y = { ...o };
          for (const p of d.pos ?? [])
            if (p.cihazToplam != null && y[p.bankoPosId] === undefined)
              y[p.bankoPosId] = String(p.cihazToplam);
          return y;
        });
      } catch { /* dokum gosterilemezse akis durmaz */ }
    })();
    return () => { iptal = true };
  }, [oturum?.id, oturum?.durum, gunSonu]);
  // ONAY BEKLERKEN KENDİLİĞİNDEN TAZELENİR: görevli ekranı yenilemek için
  //   beklemesin - onay gelince gün içi şeride kendisi geçer.
  useEffect(() => {
    if (oturum?.durum !== 1 && oturum?.durum !== 3) return;
    const t = setInterval(() => void yukle(), 15000);
    return () => clearInterval(t);
  }, [oturum?.durum, yukle]);

  const secili = useMemo(() => bankolar.find(b => b.id === bankoId) ?? null, [bankolar, bankoId]);

  const acilisSayim = parseFloat(acilisTutar.replace(',', '.')) || 0;
  const acilisFark = secili ? acilisSayim - secili.devir : 0;

  const kapanisSayim = parseFloat(kapanisTutar.replace(',', '.')) || 0;
  const beklenen = oturum?.beklenenNakit ?? 0;
  const kapanisFark = kapanisSayim - beklenen;
  const birakilanSayi = parseFloat((birakilan || '').replace(',', '.')) || 0;

  const ac = () => guvenli(async () => {
    const y = await api.bankoOturumAc({
      bankoId, vardiyaKod,
      vardiyaAralik: vBas && vBit ? `${vBas}-${vBit}` : '',
      acilisSayim, not: acilisNot,
    });
    // Açılıştan sonra AYNI ekranda kalınır: onay bekliyorsa bekleme kutusu,
    //   açıldıysa gün içi şerit burada - görevli kaldığı yerden sürdürür.
    setOturum(y.oturum); if (y.mesaj) mesaj(y.mesaj);
  });

  const gunSonuGonder = () => guvenli(async () => {
    if (!oturum) return;
    const y = await api.bankoOturumGunSonu(oturum.id, {
      kapanisSayim,
      farkNeden: kapanisFark !== 0 ? farkNeden : undefined,
      farkAciklama: kapanisFark !== 0 ? farkAciklama : undefined,
      kasadaBirakilan: birakilanSayi,
    });
    setOturum(y.oturum); setGunSonu(false); if (y.mesaj) mesaj(y.mesaj);
  });

  const posKaydet = () => guvenli(async () => {
    if (!oturum) return;
    const satirlar = poslar
      .filter(p => (posGiris[p.bankoPosId] ?? '') !== '')
      .map(p => ({
        bankoPosId: p.bankoPosId,
        cihazToplam: parseFloat((posGiris[p.bankoPosId] ?? '0').replace(',', '.')) || 0,
      }));
    if (satirlar.length === 0) { mesaj('Cihaz toplamı girilmedi.'); return }
    const y = await api.bankoOturumPosEslestir(oturum.id, satirlar);
    setPoslar(o => o.map(p => {
      const g = y.pos.find(x => x.bankoPosId === p.bankoPosId);
      return g ? { ...p, ...g } : p;
    }));
    mesaj('POS gün sonu kaydedildi.');
  });

  const yenidenAc = () => guvenli(async () => {
    if (!oturum) return;
    if (!(await onay('Kapanmış oturum yeniden açılacak. Gerekçe loga yazılır.'))) return;
    const y = await api.bankoOturumYenidenAc(oturum.id, 'Yanlış kapatıldı');
    setOturum(y.oturum);
  });

  if (yukleniyor)
    return <div className={(gomulu ? 'bo-gomulu' : 'fm-sayfa') + ' sonuk'}>Yükleniyor…</div>;

  const adim = etkinAdim(oturum, gunSonu);
  return (
    <div className={gomulu ? 'bo-gomulu' : 'fm-sayfa bo-sayfa'}>
      <style>{bostil}</style>
      {/* Modal kabuğu başlığı kendi çiziyor; burada ikinci başlık olmaz. */}
      {!gomulu && (
        <div className="bo-baslik">
          <h2>🏦 Banko Oturumu</h2>
          {oturum && (
            <span className="bo-ust">
              {oturum.bankoKod} · {oturum.bankoAd} · {oturum.gorevli}
              {oturum.vardiya ? ` · ${oturum.vardiya}` : ''}
            </span>
          )}
        </div>
      )}

      <div className="bo-akis">
        {ADIMLAR.map((a, i) => (
          <div key={a} className={'bo-ad' + (i + 1 === adim ? ' simdi' : i + 1 < adim ? ' bitti' : '')}>
            <span className="no">{i + 1}</span>{a}
            {i === 1 && <span className="bo-rz mavi">ops.</span>}
          </div>
        ))}
      </div>

      {hata && <div className="hata-kutusu">{hata}</div>}

      {gomulu && acilisBanko === 0 && !oturumId && oturum && (
        <div className="bo-uyari">
          ⚠ <b>Yeni oturum açılamaz:</b> açık bir oturumunuz var (aşağıda). Bir
          görevli aynı anda tek oturum yürütür - bunu gün sonuyla kapatınca
          yenisini açabilirsiniz.
        </div>
      )}

      {/* ---------------------------------------------------- 1 · AÇILIŞ --- */}
      {!oturum && (
        istenenBanko > 0 && !bankolar.some(x => x.id === istenenBanko) ? (
          <div className="bo-bos">
            Seçtiğiniz bankoda oturum açılamıyor. Olası sebepler: bankoda zaten
            <b> canlı bir oturum var</b>, banko <b>pasif</b>, <b>danışma</b> türünde
            (kasası yok) ya da başka şubeye ait. Aşağıdan uygun bir banko
            seçebilirsiniz.
            {bankolar.length > 0 && (
              <div className="bo-not" style={{ padding: '8px 0 0' }}>
                Uygun bankolar: {bankolar.map(b => `${b.kod} ${b.ad}`).join(' · ')}
              </div>
            )}
          </div>
        ) : bankolar.length === 0 ? (
          <div className="bo-bos">
            Bu şubede oturum açılabilecek banko yok. Bankolar pasif olabilir, hepsinde
            açık oturum olabilir ya da yalnız danışma bankosu tanımlıdır (danışmada
            kasa yoktur, oturum beklenmez).
          </div>
        ) : (
          <div className="bo-kutu">
            <div className="bo-kb">Açılış talebi</div>
            <div className="bo-izgara">
              <label>Banko *
                <select value={bankoId} onChange={e => setBankoId(Number(e.target.value))}>
                  {bankolar.map(b => (
                    <option key={b.id} value={b.id}>
                      {b.kod} — {b.ad}{b.konum ? ` (${b.konum})` : ''}
                    </option>
                  ))}
                </select>
              </label>
              <label>Vardiya
                <select value={vardiyaKod} onChange={e => {
                  const k = Number(e.target.value);
                  setVardiyaKod(k);
                  // Seçime göre ÖNERİ aralık: kurum ayarından geliyor,
                  //   kullanıcı yine elle düzeltebilir.
                  const v = vardiyalar.find(x => x.kod === k);
                  setVBas(v?.bas ?? ''); setVBit(v?.bit ?? '');
                }}>
                  <option value={0}>— seçin —</option>
                  {vardiyalar.map(v => <option key={v.kod} value={v.kod}>{v.ad}</option>)}
                </select>
              </label>
              <label>Saat aralığı
                <span className="bo-saat">
                  <input type="time" value={vBas} onChange={e => setVBas(e.target.value)} />
                  <b>–</b>
                  <input type="time" value={vBit} onChange={e => setVBit(e.target.value)} />
                </span>
              </label>
              <label>Kasa hesabı
                <input readOnly value={secili?.hesap || '—'} />
              </label>
              <label>Sistem devri
                <input readOnly className="bo-buyuk" value={para(secili?.devir ?? 0) + ' ₺'} />
              </label>
            </div>
            <div className="bo-not">
              Sistem devri <b>önceki oturumun kapanış bakiyesidir</b> ve elle
              değiştirilemez. Sayım farklıysa fark kapanışta değil <b>açılışta</b>
              yazılır - sonraki görevli başkasının farkını devralmasın.
            </div>

            {/* KUPÜR DÖKÜMÜ KALDIRILDI (kullanıcı 08.10.2026: "oturum
                açma/kapatma da kupür kaldır, yerine devir olsun"): kasadaki
                parayı banknot banknot saymak günlük işi yavaşlatıyordu; tek
                devir tutarı giriliyor, fark yine sistem devrine göre
                hesaplanıyor. */}
            {/* ÜÇÜ AYNI SATIRDA (kullanıcı 08.10.2026): sayım, fark ve not
                birlikte okunuyor - sayımı girip farkı görmek ve gerekçeyi
                yazmak tek harekettir, araya satır sonu koymak gözü
                yukarı-aşağı gezdiriyordu. */}
            <div className="bo-izgara bo-sayim">
              <label>Kasada bulunan (devir sayımı)
                <input value={acilisTutar} onChange={e => setAcilisTutar(e.target.value)}
                       className="bo-buyuk" placeholder="0,00" inputMode="decimal" />
              </label>
              <label>Fark
                <input readOnly className={'bo-buyuk' + (acilisFark !== 0 ? ' bo-kir' : '')}
                       value={para(acilisFark) + ' ₺'} />
              </label>
              <label className="bo-not-alan">
                Not{acilisFark !== 0 ? ' (fark var - açıklayın)' : ''}
                <input value={acilisNot} onChange={e => setAcilisNot(e.target.value)} />
              </label>
            </div>

            <div className="bo-dugmeler">
              <button className="bo-ana" onClick={ac} disabled={!bankoId}>
                {secili?.acilisOnay ? '📨 Onaya Gönder' : '🔓 Oturumu Aç'}
              </button>
              <span className="bo-not">
                {secili?.acilisOnay
                  ? 'Bu bankoda açılış sorumlu onayı istiyor; onay gelene kadar tahsilat girilemez.'
                  : 'Bu bankoda açılış onayı kapalı - devri sayıp doğrudan açılır.'}
              </span>
            </div>
          </div>
        )
      )}

      {/* ------------------------------------- 2 · AÇILIŞ ONAYI BEKLENİYOR -- */}
      {oturum?.durum === 1 && (
        <div className="bo-kutu bo-bekle">
          <div className="bo-kb">⏳ Açılış onayı bekleniyor</div>
          <div className="bo-ic">
            Oturum <b>#{oturum.id}</b> sorumluya gönderildi ({saat(oturum.acilisTalepTs)}).
            Onay gelene kadar bu bankoda
            <b> tahsilat ve başvuru kaydı yapılamaz</b>; hasta kaydı ve randevu
            görüntüleme açık kalır - para hareketi olmayan işler beklemesin.
            <div className="bo-not">Devir {para(oturum.devirTutar)} · sayım{' '}
              {para(oturum.acilisSayim)} · fark{' '}
              <b className={oturum.acilisFark !== 0 ? 'bo-kir' : ''}>{para(oturum.acilisFark)}</b>
            </div>
          </div>
        </div>
      )}

      {oturum?.durum === 5 && (
        <div className="bo-kutu">
          <div className="bo-kb bo-kir">✖ Açılış reddedildi</div>
          <div className="bo-ic">{oturum.redNeden || '—'}
            <div className="bo-not">Yeni talep için sayfayı yenileyin.</div></div>
        </div>
      )}

      {/* ------------------------------------------------- 3 · GÜN İÇİ ----- */}
      {oturum && (oturum.durum === 2 || oturum.durum === 3 || oturum.durum === 4) && (
        <div className="bo-serit">
          <span>🔓 Oturum <b>#{oturum.id}</b></span>
          <div className="bo-k"><span>devir</span><b>{para(oturum.devirTutar)}</b></div>
          {oturum.acilisFark !== 0 && (
            <div className="bo-k"><span>açılış farkı</span><b>{para(oturum.acilisFark)}</b></div>
          )}
          <div className="bo-k"><span>nakit tahsilat</span><b>+{para(oturum.nakitTahsilat)}</b></div>
          <div className="bo-k"><span>nakit iade</span><b>−{para(oturum.nakitIade)}</b></div>
          <div className="bo-k vurgu"><span>kasada olması gereken</span><b>{para(oturum.beklenenNakit)}</b></div>
          <div className="bo-k"><span>POS</span><b>{para(oturum.posTutar)}</b></div>
          <div className="bo-k"><span>işlem</span><b>{oturum.islemAdet}</b></div>
          {oturum.durum === 2 && (
            <button className="bo-ana bo-sag" onClick={() => {
              setGunSonu(true);
              // Önerilen bırakma tutarı banko tanımından gelir; görevli değiştirebilir.
              // ÖNERİ SAYIMI AŞMAZ: hedef 1.000 ama kasada 400 varsa öneri 400.
              //   Aşan öneri her gün elle düzeltilmek zorunda kalırdı.
              setBirakilan(String(Math.min(oturum.bankoDevirHedef || 0,
                                           oturum.beklenenNakit || 0)));
            }}>🔒 Gün Sonu</button>
          )}
        </div>
      )}

      {/* KİMDEN NE ALINDI (kullanıcı 09.10.2026): gün içi tablosu mockup'taki
          gibi şeridin altında. Kapanmış oturumda da çizilir - oturum kartını
          listeden açan sorumlu aynı dökümü görür. Gün sonu formu açıkken
          gizli: orada tür dökümü ve sayım konuşuluyor. */}
      {oturum && (oturum.durum === 2 || oturum.durum === 3 || oturum.durum === 4) && !gunSonu && (
        <IslemTablosu islemler={islemler} oturum={oturum} />
      )}

      {oturum?.durum === 2 && !gunSonu && (
        <div className="bo-not bo-ic">
          POS ve havale kasada <b>para olarak durmaz</b>: gün sonu sayımı yalnız nakit
          üzerindendir, mutabakatı banka ekstresi yapar.
        </div>
      )}

      {/* ------------------------------------------------ 4 · GÜN SONU ----- */}
      {oturum?.durum === 2 && gunSonu && (
        <div className="bo-kutu">
          <div className="bo-kb">Gün sonu — kasa sayımı</div>
          <TurTablosu turler={turler} />
          <PosPaneli poslar={poslar} giris={posGiris} setGiris={setPosGiris}
                     kaydet={posKaydet} atanmamis={posAtanmamis} />
          <CekPaneli cekler={cekler} />

          <div className="bo-iki">
            <div>
              <div className="bo-kb2">Sistem — kasada olması gereken</div>
              <table className="bo-tablo">
                <tbody>
                  <tr><td>Devir (açılış)</td><td>{para(oturum.devirTutar)}</td></tr>
                  {oturum.acilisFark !== 0 && (
                    <tr><td>Açılış farkı</td><td>{para(oturum.acilisFark)}</td></tr>
                  )}
                  <tr><td>Nakit tahsilat</td><td>+{para(oturum.nakitTahsilat)}</td></tr>
                  <tr><td>Nakit iade</td><td>−{para(oturum.nakitIade)}</td></tr>
                  <tr className="top"><td>Olması gereken nakit</td><td>{para(beklenen)}</td></tr>
                  <tr className="sonuk"><td>POS (bilgi — kasada değil)</td><td>{para(oturum.posTutar)}</td></tr>
                  <tr className="sonuk"><td>Havale / EFT</td><td>{para(oturum.bankaTutar)}</td></tr>
                </tbody>
              </table>
            </div>
            <div>
              <div className="bo-kb2">Sayım</div>
              <label className="bo-tek">Sayılan nakit (kasadaki devir)
                <input value={kapanisTutar} onChange={e => setKapanisTutar(e.target.value)}
                       className="bo-buyuk" placeholder="0,00" inputMode="decimal" /></label>
              <div className="bo-izgara">
                <label>Sayılan<input readOnly className="bo-buyuk" value={para(kapanisSayim)} /></label>
                <label>Olması gereken<input readOnly className="bo-buyuk" value={para(beklenen)} /></label>
                <label>Fark
                  <input readOnly className={'bo-buyuk' + (kapanisFark !== 0 ? ' bo-kir' : '')}
                         value={para(kapanisFark)} /></label>
              </div>
            </div>
          </div>

          {kapanisFark !== 0 && (
            <div className="bo-uyari">
              ⚠ <b>Fark var: {para(Math.abs(kapanisFark))} ₺ {kapanisFark < 0 ? 'noksan' : 'fazla'}.</b>{' '}
              Teslim için <b>neden ve açıklama zorunlu</b> - fark ayrı fişle muhasebeleşir,
              kasa bakiyesi sayımla eşitlenir ve fark geçmişi bozulmaz.
            </div>
          )}
          {kapanisFark !== 0 && (
            <div className="bo-izgara">
              <label>Fark nedeni *
                <select value={farkNeden} onChange={e => setFarkNeden(Number(e.target.value))}>
                  <option value={0}>— seçin —</option>
                  {FARK_NEDENLERI.map(f => <option key={f.kod} value={f.kod}>{f.ad}</option>)}
                </select>
              </label>
              <label className="bo-genis">Açıklama *
                <input value={farkAciklama} onChange={e => setFarkAciklama(e.target.value)} />
              </label>
            </div>
          )}

          <div className="bo-izgara">
            <label>Kasada bırakılan (yarının devri)
              <input value={birakilan} onChange={e => setBirakilan(e.target.value)} className="bo-buyuk" />
            </label>
            <label>Teslim edilecek
              <input readOnly className="bo-buyuk"
                     value={para(Math.max(0, kapanisSayim - birakilanSayi))} />
            </label>
          </div>
          <div className="bo-not">
            Bırakılan tutar <b>sonraki oturumun devri</b> olur; kalanı için kasa çıkış
            fişi üretilir. Sayılan nakitten fazla bırakılamaz - olmayan parayı yarına
            devretmek ertesi gün hazır fark üretirdi.
            {birakilanSayi > kapanisSayim && (
              <b className="bo-kir"> Bırakılan ({para(birakilanSayi)}) sayılandan
                ({para(kapanisSayim)}) fazla; önce sayımı ya da bu tutarı düzeltin.</b>
            )}
          </div>

          <div className="bo-dugmeler">
            <button className="bo-ana" onClick={gunSonuGonder}
                    disabled={(kapanisFark !== 0 && (!farkNeden || !farkAciklama.trim()))
                              || birakilanSayi > kapanisSayim}>
              {oturum.gunSonuOnay ? '📨 Teslime Gönder (onaya)' : '🔒 Oturumu Kapat'}
            </button>
            <button onClick={() => setGunSonu(false)}>↻ Vazgeç</button>
            <span className="bo-not">
              {oturum.gunSonuOnay
                ? 'Sayım kaydedilir ve sorumlu onayına gider; onaya kadar tahsilat girilemez.'
                : 'Bu bankoda gün sonu onayı kapalı - sayım kaydedilince oturum kapanır.'}
            </span>
          </div>
        </div>
      )}

      {/* ----------------------------------- 5-6 · TESLİM VE KAPANIŞ ------- */}
      {oturum && (oturum.durum === 3 || oturum.durum === 4) && (
        <div className="bo-kutu">
          <div className="bo-kb">
            {oturum.durum === 3 ? '⏳ Teslim tutanağı — kapanış onayı bekliyor' : '✔ Oturum kapandı'}
            {oturum.tutanakNo && <span className="bo-rz mavi">{oturum.tutanakNo}</span>}
          </div>
          <div className="bo-izgara">
            <label>Teslim eden<input readOnly value={`${oturum.gorevli} · ${saat(oturum.kapanisTalepTs)}`} /></label>
            <label>Teslim edilen nakit<input readOnly className="bo-buyuk" value={para(oturum.teslimEdilen) + ' ₺'} /></label>
            <label>Kasada bırakılan<input readOnly className="bo-buyuk" value={para(oturum.kasadaBirakilan) + ' ₺'} /></label>
            <label>Fark
              <input readOnly className={'bo-buyuk' + (oturum.kapanisFark !== 0 ? ' bo-kir' : '')}
                     value={para(oturum.kapanisFark) + ' ₺'} /></label>
          </div>
          <div className="bo-iki">
            <div>
              <div className="bo-kb2">Oturum özeti</div>
              <div className="bo-ic">
                <div>Açılış · {saat(oturum.acilisTs)} {oturum.acilisOnayId ? <span className="bo-rz ok">onaylı</span> : null}</div>
                <div>Devir <b>{para(oturum.devirTutar)}</b> · işlem <b>{oturum.islemAdet}</b></div>
                <div>Nakit <b>{para(oturum.nakitTahsilat)}</b> · iade <b>−{para(oturum.nakitIade)}</b></div>
                <div>POS <b>{para(oturum.posTutar)}</b> · havale <b>{para(oturum.bankaTutar)}</b></div>
                <div>Sayım <b>{para(oturum.kapanisSayim)}</b> · beklenen <b>{para(oturum.kapanisBeklenen)}</b></div>
                {oturum.farkAciklama && <div className="bo-not">Fark: {oturum.farkAciklama}</div>}
              </div>
            </div>
            <div>
              <div className="bo-kb2">İmza / onay</div>
              <div className="bo-ic">
                <div><span className="bo-rz ok">✔</span> Teslim eden · {oturum.gorevli}</div>
                <div>
                  {oturum.kapanisOnayId
                    ? <><span className="bo-rz ok">✔</span> Teslim alan · onaylandı {saat(oturum.kapanisTs)}</>
                    : <><span className="bo-rz sari">⏳</span> Teslim alan · bekliyor</>}
                </div>
                <div className="bo-not">
                  {oturum.durum === 3
                    ? 'Onay gelince oturum kapanır; bankoda tahsilat girilemez, yeni gün yeni oturumla başlar.'
                    : 'Kapanan oturum düzeltilmez: hatalı tahsilat iade/düzeltme fişiyle çözülür.'}
                </div>
              </div>
            </div>
          </div>
          <div className="bo-dugmeler">
            <button onClick={() => { onKapat?.(); git(`/banko-tutanak/${oturum.id}`) }}>
              🖨 Teslim Tutanağı
            </button>
            {oturum.durum === 4 && yetki('banko_oturum.yeniden_ac') && (
              <>
                <button onClick={yenidenAc}>🔓 Yeniden Aç</button>
                <span className="bo-not">Ayrı yetki ister; gerekçe loga yazılır.</span>
              </>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

/**
 * ÇEK TESLİM LİSTESİ (991) — mockup: "Portföye alındı · çek teslim listesi".
 *
 * Çek kasada para değildir: fiziken çekmecede durur, nakit sayımına GİRMEZ ve
 * gün sonunda elden teslim edilir. Tutanakta seri no ve vadeyle dökümü olmalı -
 * "3 çek teslim edildi" tek başına kontrol edilemez.
 *
 * Liste `cek_senet` kayıtlarından türetilir (tahsilat fişine `giris_kasa_islem_id`
 * ile bağlı); ikinci bir çek listesi tutmak ikisinin ayrışması demekti.
 */
function CekPaneli({ cekler }: { cekler: OturumCek[] }) {
  if (cekler.length === 0) return null;
  const toplam = cekler.reduce((a, c) => a + c.tutar, 0);
  return (
    <>
      <div className="bo-kb2 bo-ic">Çek / senet teslim listesi</div>
      <table className="bo-tablo bo-cek">
        <thead>
          <tr><th>Tür</th><th>Seri no</th><th>Banka</th><th>Keşideci</th>
            <th>Vade</th><th>Tutar</th></tr>
        </thead>
        <tbody>
          {cekler.map(c => (
            <tr key={c.cekId}>
              <td>{c.tur === 2 ? 'Senet' : 'Çek'}</td>
              <td>{c.seriNo || '—'}</td>
              <td>{c.bankaAdi || '—'}</td>
              <td>{c.kesideci || c.tarafUnvan || '—'}</td>
              <td>
                {c.vade ? new Date(c.vade).toLocaleDateString('tr-TR') : '—'}
                {c.kalanGun != null && (
                  <span className={'bo-rz' + (c.kalanGun < 0 ? ' kir' : '')}>
                    {c.kalanGun < 0 ? `${-c.kalanGun} gün geçti` : `${c.kalanGun} gün`}
                  </span>
                )}
              </td>
              <td>{para(c.tutar)}</td>
            </tr>
          ))}
          <tr className="top">
            <td colSpan={5}>TOPLAM · {cekler.length} kıymetli evrak</td>
            <td>{para(toplam)}</td>
          </tr>
        </tbody>
      </table>
      <div className="bo-not">
        Bu evrak <b>nakit sayımına girmez</b>; fiziken teslim edilir ve portföyde
        izlenir. Vadesi geçmiş çek varsa tahsile verilmesi gecikmiş demektir.
      </div>
    </>
  );
}

/**
 * POS GÜN SONU EŞLEŞMESİ (990) — mockup: "POS gün sonu 120,00 ₺ fark".
 *
 * POS tahsilatı kasaya nakit girmez; mutabakatı CİHAZIN gün sonu raporuyla
 * yapılır. Görevli her terminal için cihazdan okuduğu toplamı girer, sistem
 * kendi toplamını karşısına koyar.
 *
 * FARK GÜN SONUNU ENGELLEMEZ: POS farkı banka ekstresiyle kapanır (komisyon,
 * taksit, gün kayması) - nakit sayım farkıyla aynı şey değil. Kayıt altına
 * alınır ve kapanış onayında sorumlunun önüne düşer.
 */
function PosPaneli({ poslar, giris, setGiris, kaydet, atanmamis }: {
  poslar: PosEslesme[];
  giris: Record<number, string>;
  setGiris: (f: (o: Record<number, string>) => Record<number, string>) => void;
  kaydet: () => void;
  atanmamis: { toplam: number; adet: number } | null;
}) {
  if (poslar.length === 0) return null;
  return (
    <>
      <div className="bo-kb2 bo-ic">POS gün sonu eşleşmesi</div>
      <table className="bo-tablo bo-pos">
        <thead>
          <tr><th>Terminal</th><th>Sistem</th><th>Cihaz gün sonu</th><th>Fark</th><th>Durum</th></tr>
        </thead>
        <tbody>
          {poslar.map(p => {
            const girilen = giris[p.bankoPosId] ?? '';
            const cihaz = parseFloat(girilen.replace(',', '.'));
            const fark = Number.isFinite(cihaz) ? cihaz - p.sistemToplam : null;
            return (
              <tr key={p.bankoPosId}>
                <td>{p.hesapAdi} · {p.terminalNo}
                  {p.posDurum !== 1 && <span className="bo-rz sari">cihaz arızalı</span>}</td>
                <td>{para(p.sistemToplam)}</td>
                <td><input value={girilen} inputMode="decimal" placeholder="0,00"
                           onChange={e => setGiris(o => ({ ...o, [p.bankoPosId]: e.target.value }))} /></td>
                <td className={fark ? 'bo-kir' : ''}>{fark == null ? '—' : para(fark)}</td>
                <td>
                  {p.eslesmeDurum === 1 ? <span className="bo-rz ok">eşleşti</span>
                   : p.eslesmeDurum === 2 ? <span className="bo-rz kir">fark</span>
                   : p.eslesmeDurum === 3 ? <span className="bo-rz sari">ulaşılamadı</span>
                   : <span className="bo-rz">girilmedi</span>}
                </td>
              </tr>
            );
          })}
          {atanmamis && atanmamis.adet > 0 && (
            <tr className="bo-atan">
              <td>Terminale bağlanmamış POS tahsilatı ({atanmamis.adet} işlem)</td>
              <td>{para(atanmamis.toplam)}</td>
              <td colSpan={3} className="bo-es">
                Para kayıtta; hangi terminalden geçtiği yazılmamış - cihaz
                toplamıyla karşılaştırırken bu tutarı da sayın.
              </td>
            </tr>
          )}
        </tbody>
      </table>
      <div className="bo-dugmeler">
        <button onClick={kaydet}>💳 POS Gün Sonunu Kaydet</button>
        <span className="bo-not">
          POS farkı gün sonunu engellemez; banka ekstresiyle kapanır (komisyon,
          taksit, gün kayması). Nakit sayım farkıyla aynı şey değildir.
        </span>
      </div>
    </>
  );
}

/**
 * GÜN İÇİ İŞLEMLER — mockup banko_oturum_akisi_v2.html adım 4: Saat /
 * Başvuru / Hasta / Klinik · hekim / Ödeyen / Tutar / Tahsil / Ödeme / Durum.
 *
 * Satır = oturuma damgalı bir kasa işlemi (997). Tutar başvurunun toplamı,
 * Tahsil bu satırın parası; başvuruya yapılan tahsilatın neti toplamın
 * altındaysa durum KISMİ. İptal edilen satır sönük çizilir ve toplama girmez.
 */
function IslemTablosu({ islemler, oturum }: { islemler: OturumIslem[]; oturum: OturumOzeti }) {
  if (islemler.length === 0)
    return (
      <div className="bo-bos">
        Bu oturumda henüz tahsilat yok. Başvurudan alınan her ödeme oturum
        numarasıyla buraya düşer.
      </div>
    );
  const gecerli = islemler.filter(x => !x.iptal);
  const net = gecerli.reduce((a, x) => a + (x.iade ? -x.tahsil : x.tahsil), 0);
  const son = islemler[0];
  return (
    <>
      <div className="bo-tkap">
        <table className="bo-tablo bo-islem">
          <thead>
            <tr>
              <th>Saat</th><th>Başvuru</th><th>Hasta</th><th>Klinik / hekim</th>
              <th>Ödeyen</th><th className="sag">Tutar</th><th className="sag">Tahsil</th>
              <th className="orta">Ödeme</th><th className="orta">Durum</th>
            </tr>
          </thead>
          <tbody>
            {islemler.map(x => {
              const odeme = odemeRozeti(x);
              const durum = durumRozeti(x);
              return (
                <tr key={x.id} className={x.iptal ? 'sonuk' : ''}
                    title={x.makbuzNo ? `Makbuz ${x.makbuzNo} · ${x.turAdi}` : x.turAdi}>
                  <td>{saatKisa(x.tarih)}</td>
                  <td>{x.basvuruNo || '—'}</td>
                  <td>{x.hasta || '—'}</td>
                  <td>{x.bolum || x.hekim ? `${x.bolum || '—'} · ${x.hekim || '—'}` : '—'}</td>
                  <td>{x.odeyen || '—'}</td>
                  <td className="para">{x.belgeId ? para(x.tutar) : '—'}</td>
                  <td className="para">{x.iade ? '−' : ''}{para(x.tahsil)}</td>
                  <td className="orta"><span className={'bo-rz ' + odeme.renk}>{odeme.ad}</span></td>
                  <td className="orta"><span className={'bo-rz ' + durum.renk}>{durum.ad}</span></td>
                </tr>
              );
            })}
            <tr className="top">
              <td colSpan={5}>Oturum toplamı ({gecerli.length} işlem)</td>
              <td className="para">—</td>
              <td className="para">{para(net)}</td>
              <td className="orta" colSpan={2}>
                nakit {para(oturum.nakitTahsilat)} · POS {para(oturum.posTutar)}
                {oturum.nakitIade ? ` · iade −${para(oturum.nakitIade)}` : ''}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      <div className="bo-durum-cubugu">
        <span>Kapalı oturuma yazma reddedilir: tahsilat satırı <b>oturum numarasını taşır</b></span>
        <span>Son işlem {saatKisa(son.tarih)} · {oturum.bankoAd || oturum.bankoKod}</span>
      </div>
    </>
  );
}

/** Ödeme rozeti: kasa türünün ana hesabından (K nakit, P POS, B havale). */
function odemeRozeti(x: OturumIslem): { ad: string; renk: string } {
  if (x.iade) return { ad: 'iade', renk: 'kir' };
  if (x.hesapTuru === 'K') return { ad: 'nakit', renk: 'sari' };
  if (x.hesapTuru === 'P') return { ad: 'POS', renk: 'mavi' };
  if (x.hesapTuru === 'B') return { ad: 'havale', renk: 'mavi' };
  if (x.turGrup === 'ceksenet') return { ad: 'çek/senet', renk: 'mavi' };
  return { ad: x.turAdi.toLocaleLowerCase('tr-TR'), renk: '' };
}

function durumRozeti(x: OturumIslem): { ad: string; renk: string } {
  if (x.iptal) return { ad: 'iptal', renk: '' };
  if (x.iade) return { ad: 'iade', renk: 'kir' };
  // Kuruş yuvarlaması kısmi saymasın.
  if (x.belgeId && x.belgeTahsil < x.tutar - 0.005) return { ad: 'kısmi', renk: 'sari' };
  return { ad: 'tahsil', renk: 'ok' };
}

/**
 * ÖDEME TÜRÜ DÖKÜMÜ (989) — mockup tablosu: Tür / Adet / Tahsilat / İade /
 * Net / Kasada durur? / Teslim-eşleşme.
 *
 * "Kasada durur mu" türün kendi özelliğinden gelir: nakit sayılır, POS ve
 * havale kasaya para olarak girmez, çek fiziken kasada ama SAYIMA GİRMEZ
 * (portföye alınır), kupon/indirimde nakit akışı yok. Gün sonunda kasiyer ile
 * sorumlu bu tabloya bakarak mutabık kalır.
 */
function TurTablosu({ turler }: { turler: TurOzeti[] }) {
  if (turler.length === 0)
    return (
      <div className="bo-not">
        Bu oturumda henüz tahsilat yok - ödeme türü dökümü boş.
      </div>
    );
  const t = (n: number) => turler.reduce((a, x) => a + (n === 1 ? x.tahsilat : n === 2 ? x.iade : x.net), 0);
  const adet = turler.reduce((a, x) => a + x.adet, 0);
  return (
    <>
      <div className="bo-kb2 bo-ic">Ödeme türü dökümü</div>
      <table className="bo-tablo bo-tur">
        <thead>
          <tr>
            <th>Tür</th><th>Adet</th><th>Tahsilat</th><th>İade</th><th>Net</th>
            <th>Kasada durur?</th><th>Teslim / eşleşme</th>
          </tr>
        </thead>
        <tbody>
          {turler.map(x => (
            <tr key={x.tur}>
              <td>{x.turAdi}</td>
              <td>{x.adet}</td>
              <td>{para(x.tahsilat)}</td>
              <td>{x.iade ? '−' + para(x.iade) : '—'}</td>
              <td>{para(x.net)}</td>
              <td className={'bo-kd' + (x.kasaDurumu === 1 ? ' var' : '')}>{KASA_DURUM[x.kasaDurumu] ?? ''}</td>
              <td className="bo-es">{ESLESME[x.kasaDurumu] ?? ''}</td>
            </tr>
          ))}
          <tr className="top">
            <td>TOPLAM</td><td>{adet}</td><td>{para(t(1))}</td>
            <td>{t(2) ? '−' + para(t(2)) : '—'}</td><td>{para(t(3))}</td>
            <td /><td />
          </tr>
        </tbody>
      </table>
    </>
  );
}

const KASA_DURUM: Record<number, string> = {
  1: 'Evet · sayılır',
  2: 'Hayır',
  3: 'Fiziken evet · sayıma girmez',
  4: 'Hayır',
};
const ESLESME: Record<number, string> = {
  1: 'Sayım bekliyor',
  2: 'Banka ekstresinde bekliyor',
  3: 'Portföye alındı · çek teslim listesi',
  4: 'nakit akışı yok',
};

const bostil = `
/* KIRPILMA (kullanici: "alt taraf kirpilmis goremiyorum"): .fm-sayfa
   display:flex / column. Flex cocuklarin varsayilan flex-shrink:1 degeri
   kutulari pencereye SIGDIRMAYA calisiyor, kutu kendi icerigini kirpiyor ve
   toplam tasma olusmadigi icin scroll da cikmiyordu - alt kisim erisilemez
   kaliyordu. Bu akis ekrani uzun formlardan olusuyor; blok akisa dondurup
   kaydirmayi sayfanin kendisine veriyoruz. */
.bo-gomulu { display:block }
.bo-gomulu .bo-akis { margin-bottom:10px }
.bo-sayfa { display: block; height: 100%; overflow-y: auto; padding: 14px 16px 24px; }
.bo-baslik { display:flex; align-items:baseline; gap:12px; flex-wrap:wrap; margin-bottom:10px; }
.bo-baslik h2 { margin:0; font-size:17px; }
.bo-ust { color: var(--ikincil-metin, #6b7a8b); font-size:12px; }
.bo-akis { display:flex; gap:6px; flex-wrap:wrap; margin-bottom:12px; }
.bo-ad { display:flex; align-items:center; gap:6px; border:1px solid var(--cizgi, #cdd6e0);
  border-radius:14px; padding:3px 11px; font-size:11.5px; background:var(--kart, #fff);
  color: var(--ikincil-metin, #6b7a8b); }
.bo-ad .no { width:16px; height:16px; border-radius:50%; background:#e7edf4; color:#4d5d6e;
  display:inline-flex; align-items:center; justify-content:center; font-size:10px; }
.bo-ad.simdi { border-color:#2f6db3; color:#1b4f87; font-weight:bold; background:#eef4fc; }
.bo-ad.simdi .no { background:#2f6db3; color:#fff; }
.bo-ad.bitti .no { background:#cfe6d6; color:#2e7d46; }
.bo-rz { display:inline-block; border-radius:9px; padding:0 7px; font-size:10.5px;
  border:1px solid var(--cizgi, #cdd6e0); }
.bo-rz.mavi { background:#eef4fc; color:#2f6db3; border-color:#cfe0f5; }
.bo-rz.ok { background:#e2f3e8; color:#2e7d46; border-color:#bfe3cb; }
.bo-rz.sari { background:#fdf6e3; color:#8a6218; border-color:#f2ddbf; }
.bo-kutu { border:1px solid var(--cizgi, #cdd6e0); border-radius:6px; background:var(--kart, #fff);
  margin-bottom:12px; }
.bo-kb { background:var(--baslik-arka, #f3f6fa); border-bottom:1px solid var(--cizgi, #cdd6e0);
  padding:7px 11px; font-weight:bold; font-size:12.5px; display:flex; gap:10px; align-items:center; }
.bo-kb2 { font-weight:bold; font-size:12px; margin:8px 0 4px; color:#2c4a6b; }
.bo-ic { padding:9px 11px; font-size:12px; line-height:1.7; }
.bo-izgara { display:grid; grid-template-columns:repeat(auto-fit, minmax(190px, 1fr)); gap:8px 12px;
  padding:9px 11px; }
.bo-izgara label, .bo-tek { display:flex; flex-direction:column; gap:3px; font-size:11px;
  color: var(--ikincil-metin, #6b7a8b); }
.bo-izgara .bo-genis { grid-column: span 2; }
.bo-izgara input, .bo-izgara select, .bo-tek input { border:1px solid var(--cizgi, #cdd6e0);
  border-radius:4px; padding:5px 7px; font-size:12.5px; background:var(--giris-arka, #fff);
  color: var(--metin, #1f2d3a); }
.bo-izgara input[readonly], .bo-tek input[readonly] { background:#f6f8fa; }
.bo-sayim { grid-template-columns: 180px 150px 1fr; }
.bo-not-alan input { width:100% }
@media (max-width: 720px) { .bo-sayim { grid-template-columns: 1fr } }
.bo-saat { display:flex; align-items:center; gap:6px }
.bo-saat input { width:92px; flex:none }
.bo-saat b { color: var(--ikincil-metin, #6b7a8b) }
.bo-buyuk { font-family: Consolas, monospace; font-weight:bold; text-align:right; }
.bo-kir { color:#b3261e; }
.bo-not { color: var(--ikincil-metin, #6b7a8b); font-size:11px; line-height:1.6; padding:0 11px 9px; }
.bo-dugmeler { display:flex; gap:8px; align-items:center; padding:9px 11px; flex-wrap:wrap;
  border-top:1px solid var(--cizgi-ince, #e3e9f0); }
.bo-dugmeler button { border:1px solid var(--cizgi, #cdd6e0); border-radius:4px; padding:6px 12px;
  font-size:12px; background:var(--kart, #fff); cursor:pointer; }
.bo-ana { border-color:#2f6db3 !important; background:linear-gradient(#4d8fd6,#2f6db3) !important;
  color:#fff !important; font-weight:bold; }
.bo-ana:disabled { opacity:.5; cursor:default; }
.bo-serit { display:flex; gap:10px; align-items:center; flex-wrap:wrap; padding:8px 11px;
  border:1px solid #cfe0f5; background:#eef4fc; border-radius:6px; margin-bottom:10px; font-size:12px; }
.bo-k { display:flex; flex-direction:column; border-left:1px solid #cfe0f5; padding-left:10px; }
.bo-k span { font-size:10.5px; color:#5c7ba3; }
.bo-k b { font-family: Consolas, monospace; }
.bo-k.vurgu b { color:#1b4f87; font-size:14px; }
.bo-sag { margin-left:auto; }
.bo-iki { display:grid; grid-template-columns:repeat(auto-fit, minmax(300px, 1fr)); gap:12px;
  padding:0 11px 9px; }
.bo-tablo { border-collapse:collapse; width:100%; font-size:12px; }
.bo-tablo td, .bo-tablo th { border-bottom:1px solid var(--cizgi-ince, #e3e9f0); padding:4px 7px; }
.bo-tablo td:last-child, .bo-tablo th:last-child { text-align:right; font-family:Consolas, monospace; }
.bo-tablo tr.top td { font-weight:bold; background:#f7f9fc; }
.bo-tablo tr.sonuk td { color: var(--ikincil-metin, #6b7a8b); }
.bo-tkap { overflow-x:auto; margin:8px 0 0; border:1px solid var(--cizgi-ince, #e3e9f0); border-radius:4px; }
.bo-islem th { text-align:left; background:#f7f9fc; white-space:nowrap; }
.bo-islem td { white-space:nowrap; }
.bo-islem td.para, .bo-islem th.sag { text-align:right; font-family:Consolas, monospace; }
.bo-islem td.orta, .bo-islem th.orta { text-align:center; font-family:inherit; }
.bo-islem tr.sonuk td:not(.orta) { text-decoration:line-through; }
.bo-durum-cubugu { display:flex; justify-content:space-between; gap:12px; flex-wrap:wrap;
  font-size:11px; color: var(--ikincil-metin, #6b7a8b); padding:5px 2px; }
.bo-cek { margin: 0 11px 0; width: calc(100% - 22px); }
.bo-cek td:last-child, .bo-cek th:last-child { text-align:right; font-family:Consolas,monospace; }
.bo-pos { margin: 0 11px 0; width: calc(100% - 22px); }
.bo-pos td:nth-child(2), .bo-pos td:nth-child(4) { text-align:right; font-family:Consolas,monospace; }
.bo-pos tr.bo-atan td { background:#fdf6e3; color:#7a5612; }
.bo-pos input { width:110px; border:1px solid var(--cizgi, #cdd6e0); border-radius:3px;
  padding:3px 6px; text-align:right; font-family:Consolas,monospace;
  background:var(--giris-arka, #fff); color: var(--metin, #1f2d3a); }
.bo-rz.kir { background:#fbe9e7; color:#b3261e; border-color:#f3c4bf; }
.bo-tur { margin: 0 11px 10px; width: calc(100% - 22px); }
.bo-tur td:nth-child(2) { text-align:center; font-family:Consolas,monospace; }
.bo-tur td:nth-child(3), .bo-tur td:nth-child(4), .bo-tur td:nth-child(5) {
  text-align:right; font-family:Consolas,monospace; }
.bo-tur td:last-child, .bo-tur th:last-child { text-align:left; font-family:inherit; }
.bo-kd { font-size:11px; color: var(--ikincil-metin, #6b7a8b); }
.bo-kd.var { color:#2e7d46; font-weight:bold; }
.bo-es { font-size:11px; color: var(--ikincil-metin, #6b7a8b); }
.bo-kupur input { width:70px; border:1px solid var(--cizgi, #cdd6e0); border-radius:3px;
  padding:3px 6px; text-align:right; font-family:Consolas, monospace;
  background:var(--giris-arka, #fff); color: var(--metin, #1f2d3a); }
.bo-uyari { display:flex; gap:8px; align-items:center; padding:7px 11px; background:#fbe9e7;
  border-top:1px solid #f3c4bf; border-bottom:1px solid #f3c4bf; color:#8c1d18; font-size:12px; }
.bo-bekle .bo-kb { background:#fdf6e3; border-color:#f2ddbf; color:#7a5612; }
.bo-bos { border:1px dashed var(--cizgi, #cdd6e0); border-radius:6px; padding:16px;
  color: var(--ikincil-metin, #6b7a8b); font-size:12.5px; line-height:1.7; }
@media (prefers-color-scheme: dark) {
  :root:not([data-tema="acik"]) .bo-tablo tr.top td { background: rgba(255,255,255,.04); }
  :root:not([data-tema="acik"]) .bo-islem th { background: rgba(255,255,255,.04); }
  :root:not([data-tema="acik"]) .bo-izgara input[readonly] { background: rgba(255,255,255,.04); }
  :root:not([data-tema="acik"]) .bo-serit { background: rgba(79,140,210,.12); border-color:#2f5882; }
  :root:not([data-tema="acik"]) .bo-kb { background: rgba(255,255,255,.04); }
}
`;

export default BankoOturumu;
