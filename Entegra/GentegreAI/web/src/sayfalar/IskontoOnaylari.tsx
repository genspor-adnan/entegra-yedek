import { useCallback, useEffect, useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { api } from '../api/istemci';
import { hataMetni, type IskontoTalebi, type IskontoLimiti } from '../api/sozlesme';
import { para } from '../bilesenler/bicim';
import { useOturum } from '../kimlik/OturumBaglami';
import { mesaj } from '../bilesenler/mesaj';
import { KuyrukTablosu } from './iskonto/KuyrukTablosu';
import { TalepDetayi } from './iskonto/TalepDetayi';
import { YetkiLimitleri } from './iskonto/YetkiLimitleri';
import { GecmisAnaliz } from './iskonto/GecmisAnaliz';
import {
  gerekceAnalizi, isteyenAnalizi, kuyrugaDiz, ozetCikar, sure,
} from './iskonto/ortak';

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
 * DOSYA SEKMELERE BÖLÜNDÜ (refaktör): burada yalnız VERİ ve KARAR akışı kalır
 * (yükleme, 60 sn yoklama, karar isteği, sayaçlar). Her sekmenin çizimi
 * `sayfalar/iskonto/` altında; ortak hesaplar `ortak.ts`'te - sayaçtaki rakam
 * ile tablodaki rakam aynı yerden gelsin, ayrışırsa kullanıcı hangisine
 * inanacağını bilemez.
 */

type Sekme = 'kuyruk' | 'detay' | 'limit' | 'gecmis';

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

  const kuyruk = useMemo(() => kuyrugaDiz(bekleyen), [bekleyen]);
  const ozet = useMemo(() => ozetCikar(gecmis, kuyruk), [gecmis, kuyruk]);
  const gerekceler = useMemo(() => gerekceAnalizi(gecmis), [gecmis]);
  const isteyenler = useMemo(() => isteyenAnalizi(gecmis, bekleyen), [gecmis, bekleyen]);

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

        {sekme === 'kuyruk' && (
          <>
            <div className="kagrup">
              <h6>Onay Bekleyen İskonto Talepleri
                <span className="sonuk">hasta bekleten en üstte · çift tık karar penceresi</span>
              </h6>
              <KuyrukTablosu liste={kuyruk} gecmisMi={false} seciliId={secili?.id}
                             yukleniyor={yukleniyor} kararVerilir={kararVerilir}
                             onSec={detayAc} />
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
              {/* SON 20 KAYIT: kuyruk sekmesi "bugun ne oldu" ozetidir, tamami
                  Geçmiş & Analiz sekmesinde. */}
              <KuyrukTablosu liste={gecmis.slice(0, 20)} gecmisMi seciliId={secili?.id}
                             yukleniyor={yukleniyor} kararVerilir={kararVerilir}
                             onSec={detayAc} />
            </div>
          </>
        )}

        {sekme === 'detay' && !secili && (
          <div className="kagrup"><div className="bos">
            Kuyruktan bir talep seçin (satıra çift tıklayın).
          </div></div>
        )}

        {sekme === 'detay' && secili && (
          <TalepDetayi talep={secili} tavan={tavan}
                       kararOran={kararOran} setKararOran={setKararOran}
                       kararNot={kararNot} setKararNot={setKararNot}
                       calisiyor={calisiyor}
                       onKarar={tur => void karar(tur)}
                       onBasvuru={belgeId => git(`/basvuru/${belgeId}`)} />
        )}

        {sekme === 'limit' && (
          <YetkiLimitleri limitler={limitler} rolId={kullanici?.rolId} />
        )}

        {sekme === 'gecmis' && (
          <GecmisAnaliz gerekceler={gerekceler} isteyenler={isteyenler} gun={gun} />
        )}
      </div>
    </>
  );
}
