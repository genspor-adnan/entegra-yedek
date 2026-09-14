import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni, type IskontoTalebi, type IskontoLimiti } from '../api/sozlesme';
import { para, tarihSaat } from '../bilesenler/bicim';
import { useOturum } from '../kimlik/OturumBaglami';
import { mesaj } from '../bilesenler/mesaj';

/**
 * İSKONTO ONAY EKRANI (674) — mockup Ekranlar/Kayıt Kabul/iskonto_onay.html.
 *
 * Zil tek bir talebi hızlı karara bağlar; BURASI KUYRUĞUN KENDİSİ: kim ne
 * kadar bekliyor, bugün ne verildi, kim onayladı, hangi gerekçe büyüyor.
 * Onaylayan kişi gün boyu zilin açılmasını bekleyemez - hastayı vezne önünde
 * bekleten talep listenin EN ÜSTÜNDE ve kırmızıdır.
 *
 * Mockup'ın "Banko Görünümü" sekmesi BURADA YOK: o sekme başvuru/tahsilat
 * ekranının kendisini anlatıyor, ikinci bir kopyasını çizmek aynı ekranı iki
 * yerde bakımı gereken bir şeye çevirirdi.
 *
 * Sayaçlar SUNUCUDAN GELMEZ, listeden hesaplanır - ayrı bir özet ucu aynı
 * satırları ikinci kez okuyup farklı sonuç verebilirdi.
 */

type Sekme = 'kuyruk' | 'detay' | 'limit' | 'gecmis';

/** Bekleme süresi: 42 -> "42 dk", 195 -> "3 sa 15 dk". */
const sure = (dakika: number) => {
  const d = Math.max(0, Math.round(dakika));
  if (d < 1) return '< 1 dk';
  if (d < 60) return `${d} dk`;
  const sa = Math.floor(d / 60);
  return d % 60 === 0 ? `${sa} sa` : `${sa} sa ${d % 60} dk`;
};

const dakikaFarki = (bas: string, son?: string | null) =>
  ((son ? new Date(son).getTime() : Date.now()) - new Date(bas).getTime()) / 60000;

/** Kalem bazlı indirim toplamı (673) - kalem yoksa başlık oranına düşer. */
const indirim = (t: IskontoTalebi, carpan = 1) =>
  t.kalemler.length > 0
    ? t.kalemler.reduce((s, k) => s + k.tutar * k.oran / 100, 0) * carpan
    : t.tutar * t.oran / 100 * carpan;

/** Kararın gerçekleşen indirimi: onayda oranlar orantılı düşer (673). */
const verilenIndirim = (t: IskontoTalebi) =>
  t.durum === 1 ? indirim(t, t.oran > 0 ? t.onaylananOran / t.oran : 0) : 0;

/** "Personel yakını — kızı" -> "Personel yakını": analiz başlığı kategoridir. */
const gerekceBasi = (g: string) => (g.split('—')[0] || '(belirtilmemiş)').trim();

const DURUM_ROZET: Record<number, { ad: string; sinif: string }> = {
  0: { ad: 'Bekliyor',     sinif: 'uyari' },
  1: { ad: 'Onay',         sinif: 'ok' },
  2: { ad: 'Red',          sinif: 'hata' },
  3: { ad: 'Geri çekildi', sinif: 'gri' },
};

/** Yetkiden BAĞIMSIZ kurallar (mockup: Kural İstisnaları) - ekranda okunur. */
const ISTISNALAR: { kural: string; etki: string; sinif: string; neden: string }[] = [
  { kural: 'SGK katkı payı', etki: 'İndirilemez', sinif: 'hata',
    neden: 'Yasal olarak hastadan tahsili zorunlu; birim fiyat zaten kapalıdır.' },
  { kural: 'Kurum anlaşmalı fiyat', etki: 'İndirilemez', sinif: 'hata',
    neden: 'Fiyat sözleşmeyle belirlenmiş; üstüne indirim sözleşme ihlalidir.' },
  { kural: 'Onaylanmış satır', etki: 'Kilitli', sinif: 'hata',
    neden: 'Onaydan sonra satırın oranı değişmez (iskonto_kilit) — değişseydi '
         + 'onaylanan rakam ile tahsil edilen rakam ayrışırdı.' },
  { kural: 'Kısmi onay', etki: 'Oranlar orantılı düşer', sinif: 'mavi',
    neden: '%20 istenip %10 verilirse her kalem kendi oranının yarısını alır; '
         + 'görevlinin kurduğu kalem dengesi korunur.' },
  { kural: 'İskonto sonrası iade', etki: 'Oranla iade', sinif: 'mavi',
    neden: 'İade indirimli tutar üzerinden yapılır; liste fiyatından iade '
         + 'kurumu zarara sokardı.' },
];

export function IskontoOnaylari() {
  const git = useNavigate();
  const { aksiyonDegeri, kullanici } = useOturum();
  const tavan = aksiyonDegeri('basvuru.iskonto');

  const [sekme, setSekme] = useState<Sekme>('kuyruk');
  const [gun, setGun] = useState(1);
  const [bekleyen, setBekleyen] = useState<IskontoTalebi[]>([]);
  const [gecmis, setGecmis] = useState<IskontoTalebi[]>([]);
  const [limitler, setLimitler] = useState<IskontoLimiti[]>([]);
  const [secili, setSecili] = useState<IskontoTalebi | null>(null);
  const [kararOran, setKararOran] = useState('');
  const [kararNot, setKararNot] = useState('');
  const [calisiyor, setCalisiyor] = useState(false);
  const [hata, setHata] = useState('');
  const [yukleniyor, setYukleniyor] = useState(true);

  const yukle = useCallback(async () => {
    setYukleniyor(true); setHata('');
    try {
      // Bekleyenler ucu TAVANA GORE suzulu doner: yetkisi olmayana bos.
      const [b, g, l] = await Promise.all([
        tavan > 0 ? api.iskontoBekleyenler() : Promise.resolve([] as IskontoTalebi[]),
        api.iskontoGecmis(gun),
        api.iskontoLimitler(),
      ]);
      setBekleyen(b); setGecmis(g); setLimitler(l);
      // Acik detay TAZELENIR ya da DUSER: baskasi karar verdiyse ekranda
      //   duran karar paneli artik gecersizdir.
      setSecili(s => s ? b.find(x => x.id === s.id) ?? g.find(x => x.id === s.id) ?? null : null);
    } catch (h) { setHata(hataMetni(h)) }
    finally { setYukleniyor(false) }
  }, [tavan, gun]);

  useEffect(() => { void yukle() }, [yukle]);

  /* 60 sn yoklama: karar hastayi bekletir, ekran acikken kuyruk kendiliginden
     tazelenmeli - baskasi onayladiysa satir dusmeli. */
  useEffect(() => {
    const z = window.setInterval(() => void yukle(), 60000);
    return () => window.clearInterval(z);
  }, [yukle]);

  /** En uzun bekleyen en üstte: hastayı bekleten talep kuyrukta sıra beklemez. */
  const kuyruk = useMemo(() => [...bekleyen].sort(
    (a, b) => new Date(a.istekTs).getTime() - new Date(b.istekTs).getTime()), [bekleyen]);

  const ozet = useMemo(() => {
    const onayli = gecmis.filter(t => t.durum === 1);
    const red = gecmis.filter(t => t.durum === 2);
    const verilen = onayli.reduce((s, t) => s + verilenIndirim(t), 0);
    const kismi = onayli.filter(t => t.onaylananOran > 0 && t.onaylananOran < t.oran).length;
    const sureler = gecmis.filter(t => t.onayTs).map(t => dakikaFarki(t.istekTs, t.onayTs));
    const ort = sureler.length > 0 ? sureler.reduce((s, x) => s + x, 0) / sureler.length : 0;
    const enEski = kuyruk.length > 0 ? dakikaFarki(kuyruk[0].istekTs) : 0;
    const hizmet = onayli.reduce((s, t) => s + t.tutar, 0);
    return { onayli: onayli.length, red: red.length, verilen, kismi, ort, enEski, hizmet };
  }, [gecmis, kuyruk]);

  /** Gerekçeye göre: hangi sebep büyüyor - indirim değil SEBEP izlenir. */
  const gerekceAnalizi = useMemo(() => {
    const kova = new Map<string, { adet: number; red: number; tutar: number; oran: number }>();
    for (const t of gecmis) {
      const a = gerekceBasi(t.gerekce);
      const k = kova.get(a) ?? { adet: 0, red: 0, tutar: 0, oran: 0 };
      k.adet++;
      if (t.durum === 2) k.red++;
      k.tutar += verilenIndirim(t);
      k.oran += t.durum === 1 ? t.onaylananOran : t.oran;
      kova.set(a, k);
    }
    return [...kova.entries()]
      .map(([ad, k]) => ({ ad, ...k, ortOran: k.adet > 0 ? k.oran / k.adet : 0 }))
      .sort((a, b) => b.tutar - a.tutar);
  }, [gecmis]);

  /** İsteyene göre: yüksek red oranı limitin gerçeğe uymadığını gösterir. */
  const isteyenAnalizi = useMemo(() => {
    const kova = new Map<string, { talep: number; onay: number; kismi: number;
                                   red: number; tutar: number }>();
    for (const t of [...gecmis, ...bekleyen]) {
      const k = kova.get(t.isteyen || '—')
        ?? { talep: 0, onay: 0, kismi: 0, red: 0, tutar: 0 };
      k.talep++;
      if (t.durum === 1) {
        if (t.onaylananOran < t.oran) k.kismi++; else k.onay++;
        k.tutar += verilenIndirim(t);
      }
      if (t.durum === 2) k.red++;
      kova.set(t.isteyen || '—', k);
    }
    return [...kova.entries()].map(([ad, k]) => ({ ad, ...k }))
      .sort((a, b) => b.talep - a.talep);
  }, [gecmis, bekleyen]);

  /** Karar verilebilir mi: bekleyen + tavan yeter (sunucu yine doğrular). */
  const kararVerilir = (t: IskontoTalebi) => t.durum === 0 && tavan >= t.oran;

  const detayAc = (t: IskontoTalebi) => {
    setSecili(t);
    setKararOran(String(t.durum === 1 ? t.onaylananOran : t.oran));
    setKararNot('');
    setSekme('detay');
  };

  const karar = async (tur: 'onay' | 'kismi' | 'ret') => {
    if (!secili) return;
    const oran = tur === 'onay' ? secili.oran : Number(kararOran.replace(',', '.'));
    if (tur !== 'ret') {
      if (!(oran > 0)) { void mesaj('Onaylanan oran sıfırdan büyük olmalı.'); return }
      if (oran > secili.oran) {
        void mesaj('Onaylanan oran talepten büyük olamaz - yetkili indirimi '
                + 'artırmak istiyorsa kendi talebini açar.'); return;
      }
      if (oran > tavan) { void mesaj(`Yetkiniz en çok %${tavan}.`); return }
    }
    if (tur === 'ret' && kararNot.trim().length === 0) {
      void mesaj('Ret gerekçesi zorunlu - banko onu hastaya söyleyecek.'); return;
    }
    setCalisiyor(true);
    try {
      if (tur === 'ret') await api.iskontoReddet(secili.id, kararNot.trim());
      else await api.iskontoOnayla(secili.id, oran, kararNot.trim());
      setSecili(null); setSekme('kuyruk');
      await yukle();
    } catch (h) { setHata(hataMetni(h)) }
    finally { setCalisiyor(false) }
  };

  /* ------------------------------------------------------------ sayaçlar */
  const kutular = [
    { a: 'bekleyen', ik: '⏳', s: String(kuyruk.length), e: 'Onay bekleyen',
      alt: kuyruk.length > 0 ? `en eski ${sure(ozet.enEski)}` : 'kuyruk boş',
      vurgu: kuyruk.length > 0 ? 'teh' : undefined },
    { a: 'onay', ik: '✔', s: String(ozet.onayli), e: 'Onaylanan',
      alt: ozet.kismi > 0 ? `${ozet.kismi}'i kısmi onay` : 'tamamı istenen oranda',
      vurgu: 'ok' },
    { a: 'red', ik: '✖', s: String(ozet.red), e: 'Reddedilen', alt: 'gerekçeli' },
    { a: 'tutar', ik: '🏷', s: para.format(ozet.verilen), e: 'Verilen iskonto',
      alt: ozet.hizmet > 0
        ? `hizmetin %${(ozet.verilen / ozet.hizmet * 100).toFixed(1)}'i`
        : (gun === 1 ? 'bugün' : `son ${gun} gün`),
      vurgu: 'uy' },
    { a: 'sure', ik: '⏱', s: ozet.ort > 0 ? sure(ozet.ort) : '—',
      e: 'Ort. karar süresi', alt: 'talepten karara' },
  ];

  /* --------------------------------------------------------- kuyruk satırı */
  const kuyrukTablosu = (liste: IskontoTalebi[], gecmisMi: boolean) => (
    <table className="detay-tablo isk-kuyruk">
      <thead>
        <tr>
          <th style={{ width: 96 }}>{gecmisMi ? 'Süre' : 'Bekleme'}</th>
          <th style={{ width: 118 }}>Saat</th>
          <th style={{ width: 160 }}>Hasta</th>
          <th style={{ width: 104 }}>Protokol</th>
          <th>Talep edilen indirim</th>
          <th style={{ width: 150 }}>Gerekçe</th>
          <th className="hiza-sag" style={{ width: 100 }}>Tutar</th>
          <th className="hiza-sag" style={{ width: 96 }}>İndirim</th>
          <th style={{ width: 140 }}>İsteyen</th>
          <th style={{ width: 150 }}>{gecmisMi ? 'Karar' : 'Durum'}</th>
          <th style={{ width: 86 }} />
        </tr>
      </thead>
      <tbody>
        {liste.map(t => {
          const bekleme = dakikaFarki(t.istekTs, t.durum === 0 ? null : t.onayTs);
          // ACIL: 15 dk ustu bekleyen talep - hasta veznede duruyor.
          const acil = t.durum === 0 && bekleme >= 15;
          const rz = DURUM_ROZET[t.durum] ?? DURUM_ROZET[0];
          return (
            <tr key={t.id} className={acil ? 'acil' : (secili?.id === t.id ? 'secili' : undefined)}
                onDoubleClick={() => detayAc(t)}>
              <td>
                {acil ? <span className="rozet hata">{sure(bekleme)} ⏳</span>
                      : <span className="sonuk">{sure(bekleme)}</span>}
              </td>
              <td className="sonuk">{tarihSaat(t.istekTs)}</td>
              <td>{t.hasta || '—'}</td>
              <td className="sonuk">{t.belgeNo}</td>
              <td>
                {t.satirSayisi} kalem · <b>%{t.oran}</b>
                {t.durum === 1 && t.onaylananOran < t.oran && (
                  <span className="rozet uyari" style={{ marginLeft: 6 }}>
                    %{t.onaylananOran} verildi
                  </span>
                )}
                {t.kalemler.length > 0 && (
                  <div className="sonuk">{t.kalemler.map(k => k.ad).join(', ')}</div>
                )}
              </td>
              <td className="sonuk">{t.gerekce}</td>
              <td className="hiza-sag">{para.format(t.tutar)}</td>
              <td className="hiza-sag">
                <b>{para.format(t.durum === 1 ? verilenIndirim(t) : indirim(t))}</b>
              </td>
              <td>{t.isteyen}</td>
              <td>
                {gecmisMi ? (
                  <>
                    <span className={`rozet ${rz.sinif}`}>
                      {t.durum === 1 && t.onaylananOran < t.oran ? 'Kısmi onay' : rz.ad}
                    </span>
                    <div className="sonuk">{t.onaylayan || '—'}</div>
                    {t.kararNotu && <div className="sonuk">“{t.kararNotu}”</div>}
                  </>
                ) : (
                  <span className={`rozet ${acil ? 'hata' : rz.sinif}`}>
                    {acil ? 'Hasta bekliyor' : rz.ad}
                  </span>
                )}
              </td>
              <td>
                <button type="button" className={kararVerilir(t) ? 'd bir' : 'd'}
                        onClick={() => detayAc(t)}>
                  {kararVerilir(t) ? 'Karar' : 'İncele'}
                </button>
              </td>
            </tr>
          );
        })}
        {liste.length === 0 && !yukleniyor && (
          <tr><td colSpan={11} className="bos">
            {gecmisMi ? 'Bu aralıkta sonuçlanmış talep yok.'
                      : 'Bekleyen iskonto talebi yok.'}
          </td></tr>
        )}
      </tbody>
    </table>
  );

  return (
    <>
      <div className="sayfabas">
        <div className="basrow">
          <h1>İskonto Onayı</h1>
          <span className="yol">Kayıt Kabul › İskonto Onayı</span>
        </div>
        <div className="basarac">
          <select value={gun} onChange={e => setGun(Number(e.target.value))}
                  title="Sonuçlananlar ve analiz aralığı">
            <option value={1}>Bugün</option>
            <option value={7}>Son 7 gün</option>
            <option value={30}>Son 30 gün</option>
            <option value={90}>Son 90 gün</option>
          </select>
          <button className="d" onClick={() => void yukle()} title="Yenile">⟳</button>
          {yukleniyor && <span className="sonuk">Yükleniyor…</span>}
        </div>
      </div>

      <div className="sahne">
        {hata && <div className="hata-kutusu">{hata}</div>}

        <div className="pano-sayaclar">
          {kutular.map(k => (
            <div key={k.a} className={`pano-kutu${k.vurgu ? ` ${k.vurgu}` : ''}`}>
              <span className="ik">{k.ik}</span>
              <span className="s">{k.s}</span>
              <span className="e">{k.e}</span>
              <span className="pano-kutu-alt">{k.alt}</span>
            </div>
          ))}
        </div>

        {tavan <= 0 && (
          <div className="bilgi-kutusu">
            Onay yetkiniz yok — kuyruk boş görünür. Bu ekranda yalnız
            <b> sonuçlanan</b> talepleri (denetim izi) okuyabilirsiniz.
          </div>
        )}

        <div className="isk-sekmeler">
          {([['kuyruk', 'Onay Kuyruğu'], ['detay', 'Talep Detayı'],
             ['limit', 'Yetki Limitleri'], ['gecmis', 'Geçmiş & Analiz']] as const)
            .map(([k, ad]) => (
              <button key={k} type="button"
                      className={`isk-sekme${sekme === k ? ' on' : ''}`}
                      onClick={() => setSekme(k)}>
                {ad}
                {k === 'kuyruk' && kuyruk.length > 0 && (
                  <span className="rozet hata">{kuyruk.length}</span>
                )}
              </button>
            ))}
        </div>

        {/* ============================================= ONAY KUYRUGU */}
        {sekme === 'kuyruk' && (
          <>
            <div className="kagrup">
              <h6>Onay Bekleyen İskonto Talepleri
                <span className="sonuk">hasta bekleten en üstte · çift tık karar penceresi</span>
              </h6>
              {kuyrukTablosu(kuyruk, false)}
              <div className="pano-not">
                Hastayı bekleten talep <b>en üstte</b> ve kırmızıdır — banko tahsilatı
                bu onaya bağladıysa kuyrukta sıra beklemek hastayı vezne önünde tutar.
              </div>
            </div>

            <div className="kagrup">
              <h6>Sonuçlananlar
                <span className="sonuk">
                  {gun === 1 ? 'bugün' : `son ${gun} gün`} · denetim izi kalır
                </span>
              </h6>
              {kuyrukTablosu(gecmis.slice(0, 20), true)}
            </div>
          </>
        )}

        {/* ============================================== TALEP DETAYI */}
        {sekme === 'detay' && !secili && (
          <div className="kagrup"><div className="bos">
            Kuyruktan bir talep seçin (satıra çift tıklayın).
          </div></div>
        )}

        {sekme === 'detay' && secili && (
          <>
            <div className="isk-detay-serit">
              <span className="kutu">👤 <b>{secili.hasta || '—'}</b></span>
              <span className="kutu">
                🧾 <b>{secili.belgeNo}</b>
                {secili.kurum ? ` · ${secili.kurum}` : ''}
                {secili.doktor ? ` · ${secili.doktor}` : ''}
              </span>
              <span className="kutu">🏷 Talep <b>#{secili.id}</b> · {tarihSaat(secili.istekTs)}</span>
              <span className="kutu">👩 İsteyen: <b>{secili.isteyen}</b></span>
              {secili.durum === 0 && (
                <span className="rozet hata">
                  Bekliyor · {sure(dakikaFarki(secili.istekTs))}
                </span>
              )}
            </div>

            <div className="isk-detay">
              <div>
                <div className="kagrup">
                  <h6>Kalem Bazında İskonto
                    <span className="sonuk">indirim hizmet satırına yazılır</span></h6>
                  <table className="detay-tablo">
                    <thead>
                      <tr>
                        <th>Hizmet</th>
                        <th className="hiza-sag" style={{ width: 110 }}>Tutar</th>
                        <th className="hiza-sag" style={{ width: 90 }}>İstenen</th>
                        <th className="hiza-sag" style={{ width: 110 }}>İnd. tutar</th>
                        <th className="hiza-sag" style={{ width: 110 }}>Net</th>
                      </tr>
                    </thead>
                    <tbody>
                      {secili.kalemler.map((k, i) => {
                        const ind = k.tutar * k.oran / 100;
                        return (
                          <tr key={i}>
                            <td>{k.ad}</td>
                            <td className="hiza-sag">{para.format(k.tutar)}</td>
                            <td className="hiza-sag">%{k.oran}</td>
                            <td className="hiza-sag">{para.format(ind)}</td>
                            <td className="hiza-sag"><b>{para.format(k.tutar - ind)}</b></td>
                          </tr>
                        );
                      })}
                      <tr className="genel">
                        <td>TOPLAM</td>
                        <td className="hiza-sag">{para.format(secili.tutar)}</td>
                        <td className="hiza-sag">%{secili.oran}</td>
                        <td className="hiza-sag">{para.format(indirim(secili))}</td>
                        <td className="hiza-sag">
                          {para.format(secili.tutar - indirim(secili))}
                        </td>
                      </tr>
                    </tbody>
                  </table>
                  <div className="pano-not">
                    Oranlar <b>kalem kalem</b> saklanır — tümüne aynı oranı uygulamak
                    zorunlu değildir. Kısmi onayda hepsi <b>aynı oranda</b> düşer,
                    böylece görevlinin kurduğu denge korunur.
                  </div>
                </div>

                <div className="kagrup">
                  <h6>Talep Gerekçesi <span className="sonuk">banko beyanı</span></h6>
                  <div className="isk-gerekce">“{secili.gerekce || '—'}”</div>
                </div>
              </div>

              {/* ------------------------------------------ karar paneli */}
              <div className="isk-karar">
                <div className="kagrup">
                  <h6>Yetki Durumu</h6>
                  <div className="isk-sat"><span>İsteyen</span><b>{secili.isteyen}</b></div>
                  <div className="isk-sat teh">
                    <span>Talep</span>
                    <b>%{secili.oran} · {para.format(indirim(secili))}</b>
                  </div>
                  <div className="isk-sat"><span>Sizin limitiniz</span><b>%{tavan}</b></div>
                  <div className={`isk-sat ${tavan >= secili.oran ? 'ok' : 'teh'}`}>
                    <span>Karar</span>
                    <b>{tavan >= secili.oran ? 'Yetkiniz yeterli'
                        : 'Yetkiniz yetmiyor — üst role gider'}</b>
                  </div>
                </div>

                <div className="kagrup">
                  <h6>Karar <span className="sonuk">ret gerekçesi zorunlu</span></h6>
                  {secili.durum !== 0 ? (
                    <div className="isk-gerekce">
                      <b>{DURUM_ROZET[secili.durum]?.ad}</b>
                      {secili.durum === 1 && ` · %${secili.onaylananOran} uygulandı`}
                      {' · '}{secili.onaylayan || '—'}
                      {secili.kararNotu && <div className="sonuk">“{secili.kararNotu}”</div>}
                    </div>
                  ) : (
                    <div className="alan-izgara">
                      <label className="alan">
                        <span>Onaylanan oran (%)</span>
                        <input className="hiza-sag" value={kararOran}
                               onChange={e => setKararOran(e.target.value)} />
                      </label>
                      <label className="alan gen">
                        <span>Karar notu</span>
                        <textarea rows={3} value={kararNot}
                                  onChange={e => setKararNot(e.target.value)} />
                      </label>
                    </div>
                  )}

                  {secili.durum === 0 && (
                    <>
                      <div className="isk-karar-dugmeler">
                        <button type="button" className="d ok"
                                disabled={calisiyor || tavan < secili.oran}
                                title={tavan < secili.oran
                                  ? `Yetkiniz %${tavan}` : 'İstenen oranı aynen onaylar'}
                                onClick={() => void karar('onay')}>
                          ✔ Onayla (%{secili.oran})
                        </button>
                        <button type="button" className="d bir" disabled={calisiyor}
                                title="Talebi düşürerek onaylar"
                                onClick={() => void karar('kismi')}>
                          ✂ Kısmi Onayla
                        </button>
                        <button type="button" className="d teh" disabled={calisiyor}
                                onClick={() => void karar('ret')}>✖ Reddet</button>
                      </div>
                      <div className="pano-not">
                        Kısmi onay talebi <b>düşürerek</b> onaylar: banko %{secili.oran}
                        {' '}istedi, siz daha azını verirsiniz. Reddetmekle aynı şey
                        değildir — hasta yine indirim alır.
                      </div>
                    </>
                  )}
                  <div className="isk-karar-dugmeler">
                    <button type="button" className="d"
                            onClick={() => git(`/basvuru/${secili.belgeId}`)}>
                      📝 Başvuruyu Aç
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </>
        )}

        {/* ============================================ YETKI LIMITLERI */}
        {sekme === 'limit' && (
          <>
            <div className="kagrup">
              <h6>İskonto Yetki Matrisi
                <span className="sonuk">
                  rol tavanı · limit içi doğrudan uygulanır, üstü kuyruğa düşer
                </span></h6>
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th>Rol</th>
                    <th className="hiza-sag" style={{ width: 120 }}>Oran tavanı</th>
                    <th className="hiza-sag" style={{ width: 120 }}>Kişi</th>
                    <th>Not</th>
                  </tr>
                </thead>
                <tbody>
                  {limitler.map(l => (
                    <tr key={l.rolId}
                        className={l.rolId === kullanici?.rolId ? 'secili' : undefined}>
                      <td>
                        {l.rolAd}
                        {l.rolId === kullanici?.rolId && (
                          <span className="rozet mavi" style={{ marginLeft: 6 }}>siz</span>
                        )}
                      </td>
                      <td className="hiza-sag"><b>%{l.tavan}</b></td>
                      <td className="hiza-sag">{l.kullaniciSayisi}</td>
                      <td className="sonuk">
                        {l.tavan >= 100 ? 'Sınırsız — her talebi karşılar'
                          : `%${l.tavan} üstü talep bu role düşmez`}
                      </td>
                    </tr>
                  ))}
                  {limitler.length === 0 && (
                    <tr><td colSpan={4} className="bos">
                      Tanımlı iskonto tavanı yok — yetki ekranından
                      “Başvuru › İskonto” değeri verilmeli.
                    </td></tr>
                  )}
                </tbody>
              </table>
              <div className="pano-not">
                Tavan <b>rol yetkisindeki sayısal değerdir</b> (Yetkiler ekranı ›
                Başvuru › İskonto). Talep, isteyenin tavanını aşmıyorsa onaya hiç
                düşmez — her indirimi onaya göndermek gerçek istisnayı gürültüde
                kaybederdi.
              </div>
            </div>

            <div className="kagrup">
              <h6>Kural İstisnaları <span className="sonuk">yetkiden bağımsız</span></h6>
              <table className="detay-tablo">
                <thead>
                  <tr><th style={{ width: 220 }}>Kural</th>
                      <th style={{ width: 190 }}>Etki</th><th>Neden</th></tr>
                </thead>
                <tbody>
                  {ISTISNALAR.map(k => (
                    <tr key={k.kural}>
                      <td>{k.kural}</td>
                      <td><span className={`rozet ${k.sinif}`}>{k.etki}</span></td>
                      <td className="sonuk">{k.neden}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}

        {/* =========================================== GECMIS & ANALIZ */}
        {sekme === 'gecmis' && (
          <>
            <div className="kagrup">
              <h6>Gerekçeye Göre İskonto
                <span className="sonuk">{gun === 1 ? 'bugün' : `son ${gun} gün`}</span></h6>
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th>Gerekçe</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Adet</th>
                    <th className="hiza-sag" style={{ width: 130 }}>Verilen tutar</th>
                    <th className="hiza-sag" style={{ width: 100 }}>Ort. oran</th>
                    <th className="hiza-sag" style={{ width: 100 }}>Red oranı</th>
                  </tr>
                </thead>
                <tbody>
                  {gerekceAnalizi.map(g => (
                    <tr key={g.ad}>
                      <td>{g.ad}</td>
                      <td className="hiza-sag">{g.adet}</td>
                      <td className="hiza-sag">{para.format(g.tutar)}</td>
                      <td className="hiza-sag">%{g.ortOran.toFixed(1)}</td>
                      <td className="hiza-sag">
                        %{g.adet > 0 ? (g.red / g.adet * 100).toFixed(0) : 0}
                      </td>
                    </tr>
                  ))}
                  {gerekceAnalizi.length === 0 && (
                    <tr><td colSpan={5} className="bos">Bu aralıkta karar yok.</td></tr>
                  )}
                </tbody>
              </table>
              <div className="pano-not">
                Analiz indirimi değil, indirimin <b>sebebini</b> izler: “şikâyet
                telafisi” kaleminin büyümesi bir indirim sorunu değil hizmet sorunudur.
              </div>
            </div>

            <div className="kagrup">
              <h6>İsteyene Göre
                <span className="sonuk">kimin talebi ne kadar onaylanıyor</span></h6>
              <table className="detay-tablo">
                <thead>
                  <tr>
                    <th>İsteyen</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Talep</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Onay</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Kısmi</th>
                    <th className="hiza-sag" style={{ width: 90 }}>Red</th>
                    <th className="hiza-sag" style={{ width: 130 }}>Verilen tutar</th>
                    <th style={{ width: 240 }}>Değerlendirme</th>
                  </tr>
                </thead>
                <tbody>
                  {isteyenAnalizi.map(i => {
                    const redOran = i.talep > 0 ? i.red / i.talep * 100 : 0;
                    return (
                      <tr key={i.ad}>
                        <td>{i.ad}</td>
                        <td className="hiza-sag">{i.talep}</td>
                        <td className="hiza-sag">{i.onay}</td>
                        <td className="hiza-sag">{i.kismi}</td>
                        <td className="hiza-sag">{i.red}</td>
                        <td className="hiza-sag">{para.format(i.tutar)}</td>
                        <td>
                          {redOran >= 25
                            ? <span className="rozet hata">
                                Red oranı %{redOran.toFixed(0)} — limit/eğitim gözden geçirilmeli
                              </span>
                            : <span className="rozet ok">Olağan</span>}
                        </td>
                      </tr>
                    );
                  })}
                  {isteyenAnalizi.length === 0 && (
                    <tr><td colSpan={7} className="bos">Bu aralıkta talep yok.</td></tr>
                  )}
                </tbody>
              </table>
              <div className="pano-not">
                Yüksek red oranı iki şeyin belirtisidir: ya limit gerçeğe uymuyor
                (her gün aşılıyorsa limit yanlıştır), ya da talep disiplini zayıf.
              </div>
            </div>
          </>
        )}
      </div>
    </>
  );
}
