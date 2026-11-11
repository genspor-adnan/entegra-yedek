import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useOturum } from '../../kimlik/OturumBaglami';
import type { SevkiyatBilgisi, TeklifBilgisi }
  from '../../sayfalar/belgeKarti/useSevkiyatBilgisi';
import { GenLookup } from '../GenLookup';
import { api } from '../../api/istemci';
import { KodListesiModali } from '../KodListesiModali';
import { yerelAnMetni, para } from '../bicim';
import { TarafAlani } from './TarafAlani';
import { CariBilgiBandi } from '../CariBilgiBandi';
import { useCariSatiri } from '../cariSatiri';
import {
  LOOKUP_DEPO, GIRIS_FIS_TIPLERI, CIKIS_FIS_TIPLERI, SEKMELER, TEKLIF_DURUMLARI, FATURA_TIPLERI, SENARYO_SECENEK,
} from '../../sayfalar/belgeSabitleri';
import type { SatirDurumu } from '../../sayfalar/belgeSatir';
import type { Secim } from '../../sayfalar/belgeKaydet';
import type { BelgeYaniti } from '../../api/sozlesme';
import type { BelgeTuruBilgisi } from '../../sayfalar/belgeTuru';
import { c } from '../../dil/ceviri';
import { KAPANMA_ETIKET } from '../../sayfalar/belgeSabitleri';
import { gorunenBelgeNo } from '../../sayfalar/belgeKartiKurallari';

/**
 * BELGE KARTI BASLIGI - TEK 4 SUTUNLU izgara (kullanici). Once satis
 * irsaliyesinde denendi, sonra tum carili belgelere (fatura, siparis,
 * konsinye, tahakkuk), en son depo belgeleri ve stok fislerine yayildi -
 * artik her belge turu ayni duzeni kullaniyor.
 *
 * Hucre SIRASI sabit; bir tur icin anlamsiz olan hucre CIZILMEZ ve izgara
 * kendiliginden sarar (eski 3 sutunlu duzende sutun hizasini korumak icin
 * bos yer tutucu hucreler gerekiyordu, hepsi kalkti):
 *
 *   1) Kimlik  - cari / cikis deposu (depo belgesi) / fis tipi (stok fisi)
 *   2) Belge No
 *   3) Belge Tarihi
 *   4) e-Belge rozeti (kavrami olan turlerde)
 *   Faturada (kullanici 26.10.2026) sira: Fatura Tipi · Senaryo · No · Tarih | Temsilci · Depo · Vade · e-Belge+Sipariş No
 *   5) Kisi-1   - Satis Temsilcisi / Sorumlu / Teslim Eden
 *   6) Depo-2   - Giris Deposu / Teslim Deposu / fisin deposu
 *   7) Kisi-2   - Teslim Alan / Talep Eden (depo belgeleri)
 *   9) Vade (gun)
 *  10) Bagli Siparis / Kaynak Belge
 *  11) Faturalama Durumu (kapanma)
 *
 * Doviz/Kur BASLIKTA DEGIL: kalem gridinin altindaki "Rapor Dövizi" kutusunda
 * hem secim hem kur var - iki yerde gostermek tekrar oluyordu (kullanici).
 * Belge turu SECICISI de yok: tur ekranin kendisinden gelir ve pencere
 * basliginda yazili; kartta degistirilebilmesi belgenin hangi listede
 * cikacagini belirsizlestiriyordu.
 */
export function BelgeBaslik(p: BelgeBaslikProps) {
  const {
    aktifSekme, setAktifSekme, alanHatalari, bilgi, sonuc, kilitli, baslikKilitli, depoKilitli, belgeAdi,
    belgeNo, setBelgeNo, tarih, setTarih, tarihEnGec, tarihEnErken, vadeGun, setVadeGun,
    basvuruMu,
    cari, satici, depo, setDepo, girisDepo, setGirisDepo, sevkiyat, fisTipi,
    setFisTipi, satirlar, donusumler, setCariArama, setSaticiArama, setPersonelArama,
    kapanmaAlani, bagliSiparisAlani, odemeGenel = 0, odemeTahsil = 0, satirSayisiBaslik = 0, iade, setIade, alisMi, irsaliyeMi, faturaMi, siparisMi, konsinyeMi,
    tahakkukMu, depoBelgesi, stokFisiMi, fisCikisMi, transferMi, talepMi, disNumarali,
    eBelgeYok, teklif, provizyonVar, faturaTipi, setFaturaTipi, senaryo, setSenaryo,
    numaraElle, istisnaKodu = 0, setIstisnaKodu,
  } = p;

  /**
   * İSTİSNA NEDENİ BAŞLIKTA, VADE'NİN SAĞINDA (kullanıcı 08.11.2026: "bu combo istisna olduğunda görünecek"):
   * satış faturasında tipi KDV İstisna (24) iken GİB istisna kodu combosu (3xx). Değer belge_efatura.istisna_kodu -
   * kart kayıttan sonra yazar (useBelgeKaydetme); boşsa Kaydet listeden sorar (İhraç Kayıtlı / %0 KDV'li kalem
   * durumlarında da sorar - combo yalnız istisna tipinde).
   */
  const istisnaGoster = faturaMi && !alisMi && !!setIstisnaKodu && faturaTipi === 24;
  const [istisnaKodlari, setIstisnaKodlari] = useState<{ istisna: { deger: number; ad: string }[]; ihracKayitli: { deger: number; ad: string }[] } | null>(null);
  useEffect(() => {
    if (!istisnaGoster || istisnaKodlari) return;
    let iptal = false;
    void api.efaturaKodlari().then(k => { if (!iptal) setIstisnaKodlari({ istisna: k.istisna, ihracKayitli: k.ihracKayitli }) }, () => undefined);
    return () => { iptal = true };
  }, [istisnaGoster, istisnaKodlari]);
  const istisnaListesi = (faturaTipi === 9 ? istisnaKodlari?.ihracKayitli : istisnaKodlari?.istisna) ?? [];
  const istisnaHucresi = (
    <label className="alan">
      <span className="etiket">{c('İstisna Nedeni')}</span>
      <select value={istisnaKodu || ''} disabled={kilitli} onChange={e => setIstisnaKodu?.(Number(e.target.value) || 0)}>
        <option value="">{c('Seçin…')}</option>
        {istisnaKodu > 0 && !istisnaListesi.some(k => k.deger === istisnaKodu) && <option value={istisnaKodu}>{istisnaKodu}</option>}
        {istisnaListesi.map(k => <option key={k.deger} value={k.deger}>{k.ad}</option>)}
      </select>
    </label>
  );

  /**
   * CARİ BİLGİ BANDI (kullanıcı 26.10.2026: "satış/alış belgelere de firma bilgi bandı uygula... cari ad editi
   * kaldır"): carili belgede cari seçiliyse başlığın üstünde band (avatar, kod, VKN, bakiye...) ve cari hücresi
   * yok; "Değiştir" düğmesi de yok (kullanıcı 26.10.2026: "belge kartlarındaki değiştir butonları kaldır"). Cari seçili değilse (yeni belge) ya da cari listesinden
   * okunamazsa hücre yerinde - seçim ve "zorunlu" hatası orada.
   */
  const carili = !stokFisiMi && !depoBelgesi;
  const cariSatiri = useCariSatiri(carili && !basvuruMu ? cari?.id ?? 0 : 0);
  const bantli = carili && !!cari?.id && !!cariSatiri;
  const git = useNavigate();
  const { yetki } = useOturum();

  /** Teklif (216): katalog adi 'Teklif' - durum combosu ve sekme adi degisir. */
  const teklifMi = belgeAdi === 'Teklif';
  /**
   * FATURA BAŞLIĞI GÖRÜNTÜLEME / DÜZENLEME KİPİ (mockup Ekranlar/fatura_basligi_bant.html, kullanıcı 08.11.2026:
   * "fatura başlığını edit / display mode", "çip düzeni edit moda yakın olsun", "üstte 4 altta 4"): aynı 4 sütunlu
   * ızgara iki kipte de durur - görüntülemede kutular kaybolur, değer düz koyu metin (CSS .bb-goster); ✎ ya da
   * ızgaraya tıklamak düzenlemeye alır. YENİ belgede düzenleme açık başlar, Kaydet kapatmaz (seri giriş); kayıtlı
   * belge görüntüleme kipinde açılır; KİLİTLİ belgede (e-Belge gönderildi, yetki yok) hep görüntüleme, ✎ pasif.
   * Önce yalnız faturada, sonra TÜM ALIŞ / SATIŞ belgelerinde (kullanıcı 08.11.2026: "bu müşteri bandı ve fatura
   * başlığı desenini tüm alış/satış belgelere uygula"): carili türler - fatura, fiş, irsaliye, sipariş, teklif, konsinye,
   * tahakkuk. Depo belgesi (transfer / talep) ve başvuru ESKİSİ GİBİ. Cari bandı henüz yoksa (cari seçilmemiş) ✎
   * ızgaranın sağ üstünde durur (kayıtlı belgede).
   * STOK FİŞİ DE KİPLİ (kullanıcı 09.11.2026: "giriş/çıkış fişi kartında başlığı da view/edit moda getir"): cari
   * bandı yok, ✎ ızgaranın sağ üstünde; kilit ölçütü fişin kendi başlık kilidi (`baslikKilitli` - kalem varsa
   * başlık kilitlenir), ✎ o zaman pasif.
   * DEPO BELGESİ DE KİPLİ (kullanıcı 10.11.2026: "transfer kartı ve stoktan talep kartlarının başlıklarını view/edit
   * moda geçir", "sağ üstte çerçevesiz kalem olsun"): stok fişiyle aynı - bantsız, ✎ sağ üstte çerçevesiz
   * (.bb-kalem-serbest = .bs-kalem deseni), kilit ölçütü `baslikKilitli`. Başvuru ESKİSİ GİBİ.
   */
  const [baslikDuzenle, setBaslikDuzenle] = useState(!!p.yeniMi);
  /** Kart YENİ açıldı (sabit): yeni belgenin düzenleme kipi "yazıyorsun" çizgisi almaz - ilk kayıttan sonra da (inceleme). */
  const [yeniAcildi] = useState(!!p.yeniMi);
  const kipli = (carili || stokFisiMi || depoBelgesi) && !basvuruMu;
  /** Kipin kilit ölçütü: stok fişi / depo belgesinde başlık kilidi (kalem varsa), carili belgede belge kilidi. */
  const kipKilidi = stokFisiMi || depoBelgesi ? baslikKilitli : kilitli;
  // KALEM EKLEME başlığı kapatır (kullanıcı): "+" ile kalem penceresi açılınca düzenleme biter, bilgi okunur kalır.
  useEffect(() => { if (p.baslikKapatAnahtari) setBaslikDuzenle(false) }, [p.baslikKapatAnahtari]);
  const gosterKipi = kipli && (kipKilidi || !baslikDuzenle);
  /** ✎ - tek düğme, iki yuva (cari bandının sonu / bantsızken ızgaranın sağ üstü). */
  const kalemDugmesi = (ek = '') => (
    <button type="button" className={`${ek ? 'bs-kalem' : 'd ik kalem-dugme'}${ek}${gosterKipi ? '' : ' acik'}`} disabled={kipKilidi}
            title={kipKilidi ? c('Kilitli belge - başlık düzenlenemez') : gosterKipi ? c('Başlık alanlarını düzenle') : c('Düzenlemeyi kapat')}
            onClick={() => setBaslikDuzenle(v => !v)}>✎</button>
  );
  /** Bantsız serbest ✎ çizilsin mi: kipli ve bantsız; carili belgede kayıtlıysa, fiş / depo belgesinde hep. */
  const serbestKalem = !bantli && kipli && (!!sonuc || stokFisiMi || depoBelgesi);
  const efDurum = Number(sonuc?.belge.efaturaDurum ?? 0);
  const efSonuc = Number(sonuc?.belge.efaturaSonuc ?? 0);

  /**
   * Belge turunun adi - "İrsaliye No" / "Fatura No" / "Sipariş No". Depo
   * belgesi ve stok fisinde kartin kendi adi (Transfer, Talep, Giriş Fişi...)
   * kullanilir; `belgeAdi` zaten tur katalogundan geliyor.
   */
  // Katalog ozel bir ad verdiyse (Teklif) o kullanilir; 'Belge' generic'i
  //   fatura turlerinin adi olarak 'Fatura'ya cevrilir (216).
  // BASVURU (246): numara "Protokol No", tarih "Başvuru Tarihi" (kullanici) -
  //   siparis davranisini miras aliyor ama HBYS'de karsiligi protokoldur.
  //   Bayrak KARTTAN gelir (tur === 30); katalog adi degisse de kirilmaz.
  const belgeSozu = depoBelgesi || stokFisiMi ? belgeAdi
                  : basvuruMu ? 'Başvuru'
                  // KONSİNYE (kullanıcı 07.11.2026 "konsinye kartlardaki İrsaliye -> Konsinye"): "Konsinye No / Tarihi".
                  : konsinyeMi ? 'Konsinye'
                  : irsaliyeMi ? 'İrsaliye' : siparisMi ? 'Sipariş'
                  : tahakkukMu ? 'Tahakkuk'
                  : belgeAdi !== 'Belge' ? belgeAdi : 'Fatura';
  /** Numara etiketi: basvuruda "Protokol No", digerlerinde "<tur> No". */
  const numaraSozu = basvuruMu ? 'Protokol' : belgeSozu;

  /** Tarih hucresi: basvuruda bolum/hekimden SONRA cizildigi icin degisken. */
  /** e-Belge rozetleri; faturada Sipariş No da burada ve hücre 2. satırın sonunda (bkz. 4b). */
  const eBelgeHucresi = (
  <label className="alan">
    {/* FATURADA SIPARIS NO DA BURADA (kullanici 26.10.2026: "sip no da e-belge bölümüne gelsin 3. satır
        olmasın"): Fatura Tipi + Senaryo eklenince baslik 3. satira tasiyordu. */}
    <span className="etiket">{faturaMi ? 'e-Belge · Sipariş No' : 'e-Belge'}</span>
    <span className="deger-serit">
      {/* TUR + DURUM (11.10.2026): listedeki "e-Belge" ve "e-Belge Durum"
          kolonlariyla ayni kural. Eski hali hazirlanmis belgeye de
          "Gönderildi" diyor, e-Arsivi e-Fatura gosteriyordu. */}
      <span className="rozet bilgi">
        {konsinyeMi ? 'e-İrsaliye (konsinye)' : irsaliyeMi ? 'e-İrsaliye'
          : [11, 12].includes(efDurum) ? 'e-Arşiv' : 'e-Fatura'}
      </span>
      {[2, 12, 52].includes(efDurum) ? <span className="rozet ok">{c('Gönderildi')}</span>
        : efDurum > 0 && efSonuc === 3 ? <span className="rozet hata">{c('Gönderim hatası')}</span>
        : efDurum > 0 ? <span className="rozet uyari">{c('Hazır')}</span>
        : <span className="rozet gri">{c('Taslak')}</span>}
      {faturaMi && sonuc?.belge.kaynakBelgeNo ? (
        <span className="rozet gri" title={`${String(sonuc.belge.kaynakTurAdi ?? '')} · ${c('Belge No')}`}>
          {String(sonuc.belge.kaynakBelgeNo)}</span>) : null}
    </span>
  </label>
  );

  const saticiHucresi = (
    <TarafAlani
      etiket={stokFisiMi || alisMi ? 'Sorumlu' : 'Satış Temsilcisi'}
      deger={satici?.ad}
      kilitli={stokFisiMi ? baslikKilitli : kilitli}
      ipucu="Personel ara"
      onAc={() => setSaticiArama(true)}
    />
  );
  const vadeHucresi = bilgi.vade && (
    <label className="alan">
      <span className="etiket">{teklifMi ? 'Geçerlilik Süresi (gün)' : 'Vade (gün)'}</span>
      <input className="hiza-sag" value={vadeGun} disabled={kilitli}
             onChange={e => setVadeGun(e.target.value)} />
    </label>
  );

  const tarihHucresi = (
    <label className="alan">
      {/* ZORUNLU (kullanici): belge/siparis tarihi bos kalamaz - kalem, prim ve
          numara serisi hep bu tarihe bagli. Alan temizlenirse SIMDIKI AN geri
          yazilir; kullanici gecmis bir tarih secmek isterse ustune yazar. */}
      <span className="etiket zorunlu-isaret">{belgeSozu} Tarihi</span>
      <input type="datetime-local" value={tarih} disabled={baslikKilitli}
             max={tarihEnGec} min={tarihEnErken}
             onChange={e => setTarih(e.target.value || yerelAnMetni(new Date()))} />
      {alanHatalari.belgeTarihi && <span className="alan-hata">{alanHatalari.belgeTarihi}</span>}
    </label>
  );

  /**
   * Kapanma ("bu belgeden ne kadari faturalandi") hangi turde ANLAMLI:
   * faturada ve tahakkukta zincirin sonundayiz, depo belgesi ve stok fisi ise
   * fatura zincirinde hic degil.
   */
  // Teklif fatura zincirinde degil (216) - "Faturalanmadı" rozeti yaniltirdi.
  const kapanmaGoster = !faturaMi && !tahakkukMu && !depoBelgesi && !stokFisiMi
                        && belgeAdi !== 'Teklif';

  // DURUMLAR CARİ BAŞLIĞINDA (kullanıcı 02.11.2026: "e-belge / faturalama durumlarını cari başlığa al", mockup
  //   Ekranlar/Satinalma/alis_faturasi_cari_baslik.html): bant varken e-Belge ve Faturalama / Kapanma bandın
  //   sağında küçük kutular; ızgaradaki hücreleri boş kalır (yükseklik değişmez).
  const bosHucre = <span className="alan" aria-hidden />;
  const kapanma = KAPANMA_ETIKET[Number(sonuc?.belge.kapanmaDurum ?? 0)];
  const kaynakNo = sonuc?.belge.kaynakBelgeNo ? String(sonuc.belge.kaynakBelgeNo) : '';
  const kaynakTur = String(sonuc?.belge.kaynakTurAdi ?? '');
  // ÖDEME / TAHSİLAT (mockup): genel toplam - belgeye bağlı ödeme; vade = tarih + vade günü.
  const kalanOdeme = Math.round((odemeGenel - odemeTahsil) * 100) / 100;
  const vadeAn = (() => { const t = new Date(tarih); if (isNaN(t.getTime())) return null;
    t.setDate(t.getDate() + (Number(vadeGun) || 0)); return t })();
  const gecenGun = vadeAn ? Math.floor((Date.now() - vadeAn.getTime()) / 86400000) : 0;
  const vadeMetni = vadeAn ? `${c('vade')} ${String(vadeAn.getDate()).padStart(2, '0')}.${String(vadeAn.getMonth() + 1).padStart(2, '0')}` : '';
  const odemeKutusu = (
    <div className={`bdk${odemeGenel <= 0.005 ? '' : kalanOdeme <= 0.005 ? ' ok' : gecenGun > 0 ? ' hata' : odemeTahsil > 0.005 ? ' uy' : ''}`}
         title={alisMi ? c('Ödeme sekmesi') : c('Tahsilat sekmesi')} onClick={() => setAktifSekme('tahsilat')}>
      <span className="bdk-e">{alisMi ? c('Ödeme') : c('Tahsilat')}</span>
      <span className="bdk-v">{odemeGenel <= 0.005 ? '—'
        : kalanOdeme <= 0.005 ? <>{c('Kapandı')} <span className="rozet ok">✓</span></>
        : odemeTahsil > 0.005 ? <>{c('Kısmi')} <span className="rozet uyari">%{Math.round(odemeTahsil / odemeGenel * 100)}</span></>
        : <>{c('Açık')}{gecenGun > 0 && <span className="rozet hata">{gecenGun} {c('gün geçti')}</span>}</>}</span>
      <span className="bdk-a">{odemeGenel <= 0.005 ? c('kalem girilince')
        : kalanOdeme <= 0.005 ? vadeMetni : `${c('kalan')} ${para.format(kalanOdeme)}${vadeMetni ? ` · ${vadeMetni}` : ''}`}</span>
    </div>
  );
  // ALIŞ İRSALİYESİ (kullanıcı 02.11.2026: "giriş deposu 1.sırada irs tarihi sağına taşı.. sipariş no kaldır"):
  //   depo 1. satırın 4. hücresinde (e-Belge durumu cari başlığında), Sipariş No hücresi yok.
  // SATIŞ İRSALİYESİ DE AYNI DÜZEN (kullanıcı 02.11.2026: "alış irs kartındaki edit düzenini satış irs kartına da
  //   uygula" + "konsinye irsaliyelerine de aynı düzeni uygula"): No · Tarih (☐ İade) · Depo · Temsilci tek satır.
  //   Konsinyede İade kutusu yok (hiç olmadı).
  const alisIrsaliye = irsaliyeMi || konsinyeMi;
  // SATIŞ SİPARİŞİ (kullanıcı 02.11.2026: "depo sip tarih sağına taşı, kaynak belge kaldır, vade (%75 daralt) satış
  //   tems. soluna al" + "sip no ve sip tarihi depo edit kadar genişlikte" + "1.satırda sip no, sip tar, depo, vade,
  //   satış tem (daralt) yer alsın.. tek satır"): TEK SATIR No · Tarih · Depo · dar Vade · dar Satış Temsilcisi
  //   (ızgara yerine akış, tema.css .tek-satir); Kaynak Belge hücresi yok.
  const satisSiparis = siparisMi && !alisMi && !teklifMi && !basvuruMu;
  /** No / Tarih / Depo aynı genişlikte olan düzen (alış irsaliyesi, satış siparişi). */
  const darUst = alisIrsaliye || satisSiparis;
  const cariDepoHucresi = (
      <GenLookup
        kaynak="depo"
        etiket={siparisMi ? 'Depo' : alisMi ? 'Giriş Deposu' : 'Çıkış Deposu'}
        // ZORUNLU + KİLİT (genel kural 11.11.2026): başvuru dışında combo varsa seçilir, kalemle kilitlenir.
        zorunlu={!basvuruMu}
        // Pasif depo secilemez: kapatilmis depoya belge kesilmesin.
        sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
        alanlar={LOOKUP_DEPO}
        deger={depo?.ad}
        hata={alanHatalari.cikisDepoId ?? alanHatalari.girisDepoId}
        saltOkunur={depoKilitli}
        onSec={x => setDepo(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)}
      />
  );
  // TRANSFERDE GİRİŞ DEPOSU ÇIKIŞIN SAĞINDA (kullanıcı 02.11.2026): 1. satır Çıkış · Giriş · No · Tarih,
  //   2. satır Teslim Eden · Teslim Alan. Talepte de Teslim Deposu İstenen Deponun sağında (kullanıcı 02.11.2026).
  const girisDepoHucresi = (
      <GenLookup
        kaynak="depo"
        etiket={talepMi ? 'Teslim Deposu' : 'Giriş Deposu'}
        zorunlu
        sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
        alanlar={LOOKUP_DEPO}
        deger={girisDepo?.ad}
        saltOkunur={depoKilitli}
        hata={alanHatalari.girisDepoId}
        onSec={x => setGirisDepo(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)}
      />
  );
  const bandDurumlari = (
    <>
      {!eBelgeYok && (
        <div className={`bdk${[2, 12, 52].includes(efDurum) ? ' ok' : efDurum > 0 && efSonuc === 3 ? ' hata' : efDurum > 0 ? ' uy' : ''}`}
             title={c('e-Belge sekmesi')} onClick={() => setAktifSekme('ebelge')}>
          <span className="bdk-e">{c('e-Belge')}</span>
          <span className="bdk-v">
            <span className="rozet bilgi">{konsinyeMi ? 'e-İrsaliye (konsinye)' : irsaliyeMi ? 'e-İrsaliye'
              : [11, 12].includes(efDurum) ? 'e-Arşiv' : 'e-Fatura'}</span>
            {[2, 12, 52].includes(efDurum) ? <span className="rozet ok">{c('Gönderildi')}</span>
              : efDurum > 0 && efSonuc === 3 ? <span className="rozet hata">{c('Gönderim hatası')}</span>
              : efDurum > 0 ? <span className="rozet uyari">{c('Hazır')}</span>
              : <span className="rozet gri">{c('Taslak')}</span>}
          </span>
          <span className="bdk-a">{[2, 12, 52].includes(efDurum) ? c('GİB\'e iletildi') : efDurum > 0 && efSonuc === 3 ? c('yeniden gönderin')
            : efDurum > 0 ? c('gönderime hazır') : c('henüz hazırlanmadı')}</span>
        </div>
      )}
      {faturaMi ? (<>
        <div className={`bdk${kaynakNo ? ' ok' : ''}`} title={kaynakNo ? `${kaynakTur} · ${c('Belge No')}` : undefined}>
          <span className="bdk-e">{c('Faturalama')}</span>
          <span className="bdk-v">{kaynakNo
            ? <>{kaynakTur ? `${kaynakTur}` : c('Kaynak belge')} <span className="rozet gri">{kaynakNo}</span></>
            : c('Doğrudan')}</span>
          <span className="bdk-a">{kaynakNo ? c('kaynak belgeden') : c('sipariş / irsaliye bağı yok')}</span>
        </div>
        {odemeKutusu}
      </>) : kapanmaGoster && (
        <div className={`bdk${kapanma?.sinif === 'olumlu' ? ' ok' : kapanma?.sinif === 'uyari' ? ' uy' : ''}`}>
          <span className="bdk-e">{irsaliyeMi ? c('Faturalama') : c('Kapanma')}</span>
          <span className="bdk-v"><span className={`rozet ${kapanma?.sinif ?? ''}`}>{kapanma?.ad ?? '—'}</span></span>
          <span className="bdk-a">{satirSayisiBaslik} {c('kalem')}</span>
        </div>
      )}
    </>
  );

  return (
  <>
{/* BASVURUDA BASLIK SERIDI YOK (300, kullanici): kimlik hasta arama satiri
    ve hasta bandinda, tarih/bolum/hekim/odeyen kurum ise Basvuru sekmesinde.
    Basligi bosuna cizmek kart tepesinde iki kez ayni bilgiyi gosteriyordu. */}
{!basvuruMu && (
<div className={`belge-hdr-sar${serbestKalem ? ' kalemli' : ''}`}>
  {/* SERBEST ✎ (bantsız): carili belgede yalnız KAYITLI belgede (cari bandı gelince oraya taşınır); stok fişi ve depo
      belgesinde (transfer / talep) YENİ belgede de (kullanıcı 10.11.2026: "başlıkların sağ üst köşesine çerçevesiz
      kalem ekle, edit/view mode için") - "+" kalem ekleme başlığı görüntülemeye alınca geri açmanın yolu bu. */}
  {serbestKalem && kalemDugmesi(' bb-kalem-serbest')}
  {/* CARİ BAŞLIĞI MÜŞTERİ / TEDARİKÇİ KARTIYLA AYNI (kullanıcı 02.11.2026): kimlik bandı kod · VKN · il ·
      temsilci · DURUM. Özet şeridi YOK ("alış/satış belgelerinde özet şeride gerek yok"); bakiye bu yüzden
      bandın sağında kalır. */}
  {bantli && (
    <CariBilgiBandi id={cari!.id} tedarikci={alisMi} durumlu bakiyeKutu sagEk={bandDurumlari}
                    sonEk={kipli ? kalemDugmesi() : undefined}
                    onBakiye={() => git(`/ekstre?tur=cari&id=${cari!.id}`)}
                    // CARİ KARTI YENİ SEKMEDE (kullanıcı 02.11.2026): yalnız cari görme yetkisi olana.
                    onKartAc={yetki('cari', 'gor') ? () => git(alisMi ? `/tedarikci/${cari!.id}` : `/cari/${cari!.id}`) : undefined} />)}
  {/* GÖRÜNTÜLEME KİPİNDE ızgara `inert` (fare + klavye + odak kapalı; inceleme: yalnız fare kesiliyordu, Tab ile
      yazılabiliyordu); tıklama sarmalayıcıda yakalanır ve (kilitli değilse) düzenlemeye geçirir. */}
  <div className={gosterKipi ? 'bb-goster-sar' : undefined}
       onMouseDown={gosterKipi && !kipKilidi ? () => setBaslikDuzenle(true) : undefined}>
  <div className={`alan-izgara dort-sutun belge-hdr${tahakkukMu ? ' bes-sutun' : ''}${darUst ? ' dar-ust' : ''}${satisSiparis ? ' tek-satir' : ''}`
                  + (gosterKipi ? ' bb-goster' : kipli && !yeniAcildi ? ' bb-duzenle' : '')}
       inert={gosterKipi || undefined}>
    {/* --- 1) KIMLIK --- */}
    {/* Transferde/talepte CARI YOK: mal firmanin kendi depolari arasinda
        gezer, cari hucresinin yerini cikis deposu alir. Stok fisinde ise
        fisin SEBEBI (tipi) ilk sorulan sey - muhasebe hesabini o belirleyecek
        (F7). Carili turlerde secim GenLookup degil TarafArama modali: "yeni
        belge" akisiyla ayni ekran olsun (iki farkli cari secme bicimi
        kullaniciyi sasirtiyordu). */}
    {stokFisiMi ? (
      <label className="alan">
        <span className="etiket zorunlu-isaret">Tipi</span>
        <select value={fisTipi} disabled={baslikKilitli}
                autoFocus={!kilitli && !fisTipi}
                onChange={e => setFisTipi(Number(e.target.value))}>
          <option value={0}>{c('Seçiniz…')}</option>
          {(fisCikisMi ? CIKIS_FIS_TIPLERI : GIRIS_FIS_TIPLERI)
            .map(t => <option key={t.deger} value={t.deger}>{t.ad}</option>)}
        </select>
        {alanHatalari.tipi && <span className="alan-hata">{alanHatalari.tipi}</span>}
      </label>
    ) : depoBelgesi ? (
      <GenLookup
        kaynak="depo"
        etiket={talepMi ? 'İstenen Depo' : 'Çıkış Deposu'}
        zorunlu
        sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
        alanlar={LOOKUP_DEPO}
        deger={depo?.ad}
        saltOkunur={depoKilitli}
        hata={alanHatalari.cikisDepoId}
        onSec={x => setDepo(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)}
      />
    ) : bantli ? null : (
      <TarafAlani
        etiket={alisMi ? 'Tedarikçi (Cari)' : 'Müşteri (Cari)'}
        deger={cari?.unvan}
        kilitli={kilitli}
        zorunlu
        ipucu="Cari ara"
        hata={alanHatalari.tarafId}
        onAc={() => setCariArama(true)}
      />
    )}

    {/* --- 4b) FATURA TIPI + SENARYO (kullanici 26.10.2026: "satış/alış fatura kartına fatura tipi ve senaryoyu
        taşı"): Fatura Tipi arac cubugundaydi, Senaryo e-Belge sekmesindeydi. Faturanin cinsi hem muhasebe fisini
        hem e-Belge senaryosunu etkiler; belge.tipi alaninda tutulur (iade zaten 2 idi).
        SIRA (kullanici 26.10.2026): 1. satir Fatura Tipi · Senaryo · Fatura No · Tarih; 2. satir Temsilci · Depo ·
        Vade · e-Belge + Sipariş No (cari bantta - hucre yok). */}
    {faturaMi && (
      <label className="alan">
        <span className="etiket">{c('Fatura Tipi')}</span>
        <select value={faturaTipi} disabled={kilitli} onChange={e => setFaturaTipi(Number(e.target.value))}>
          {/* Tip 1 KATALOGTA "Alış / Satış" (tek kod, iki yon): belgenin kendi yonuyle yazilir. */}
          {FATURA_TIPLERI.map(t => (
            <option key={t.deger} value={t.deger}>{t.deger === 1 ? (alisMi ? 'Alış' : 'Satış') : t.ad}</option>))}
          {/* Gocten gelen tanimsiz tip (or. 17) listede yok: secenek olarak EKLENIR, yoksa kart acilinca ilk
              tipe duser ve kaydedince belgenin gercek tipi sessizce degisirdi. */}
          {!FATURA_TIPLERI.some(t => t.deger === faturaTipi) && <option value={faturaTipi}>Tanımsız ({faturaTipi})</option>}
        </select>
      </label>
    )}
    {faturaMi && !eBelgeYok && (
      <label className="alan">
        <span className="etiket">{c('Senaryo')}</span>
        <select value={senaryo} disabled={kilitli} onChange={e => setSenaryo(Number(e.target.value))}>
          {SENARYO_SECENEK.map(o => <option key={o.deger} value={o.deger}>{o.ad}</option>)}
        </select>
      </label>
    )}

    {/* --- 1b) TEKLIF KONUSU (kullanici 26.10.2026: "teklif kartı başlık 1.sıra: teklif konusu, teklif no,
        tek tarihi, durumu 2.sıra satış tem, teslim şekli, geçerlilik"). Cari bantta - hucre yok. */}
    {teklifMi && (
      <KodListeAlani etiket="Teklif Konusu" listeKod="belge.teklif_konusu"
                     deger={teklif.konu} onDeger={teklif.setKonu}
                     kilitli={kilitli} yazilabilir />
    )}
    {/* --- 1c) TAHAKKUK TEK SATIR (kullanici 26.10.2026: "Satış Tahakkuku.. başlık 1.sıra satış tem, vade, tah no,
        tah tarihi, sip no... tek satır olsun"): Temsilci ve Vade numaranin ONUNE, izgara 5 sutun (cari bantta). */}
    {tahakkukMu && <>{saticiHucresi}{vadeHucresi}</>}
    {(transferMi || talepMi) && girisDepoHucresi}

    {/* --- 2) BELGE NO ---
        Alis faturasinda numara TEDARIKCININ: sayacimiz uretemez (harf
        icerebilir, bizim seriyle iliskisi yok), kullanici girer. Diger
        turlerde numarayi kayitta sunucu verir - alan salt-okunur.
        Teklifte hucre IKIYE BOLUNUR (220, kullanici): solda numara, sagda
        REVIZE NO - serbest kullanici editi, varsayilan bos. */}
    <label className="alan">
      <span className={`etiket${disNumarali && !kilitli ? ' zorunlu-isaret' : ''}`}>
        {disNumarali ? `Tedarikçi ${konsinyeMi ? 'Konsinye' : irsaliyeMi ? 'İrsaliye' : /fiş/i.test(belgeAdi) ? 'Fiş' : 'Fatura'} No`
          : teklifMi ? `${belgeSozu} No / Revize No` : `${numaraSozu} No`}
      </span>
      {(disNumarali || numaraElle) && !kilitli ? (
        <input className="one-cikan" value={belgeNo} maxLength={20}
               // GELEN BELGE NO BOŞ (kullanıcı 02.11.2026: "içi boş kalsın.. örnek olmasın").
               placeholder={disNumarali ? undefined : '(boş bırakılırsa sistem verir)'}
               onChange={e => setBelgeNo(e.target.value)} />
      ) : teklifMi ? (
        <span className="ikili">
          <input className="one-cikan"
                 value={gorunenBelgeNo(sonuc?.belge.belgeNo) || (sonuc?.belge.belgeNo ? '(e-Belge gönderiminde verilir)' : kilitli ? '' : '(kaydedince verilir)')}
                 readOnly />
          {/* Revize, NUMARASI OLAN teklife yazilir (kullanici): numara yokken
              revize kavrami yok - kaydedilince edit acilir. */}
          <input value={teklif.revizeNo} maxLength={20} placeholder={c('Revize')}
                 style={{ flex: '0 0 76px' }}
                 disabled={kilitli || !gorunenBelgeNo(sonuc?.belge.belgeNo)}
                 onChange={e => teklif.setRevizeNo(e.target.value)} />
        </span>
      ) : (
        <input className="one-cikan"
               value={gorunenBelgeNo(sonuc?.belge.belgeNo) || (sonuc?.belge.belgeNo ? '(e-Belge gönderiminde verilir)' : kilitli ? '' : '(kaydedince verilir)')}
               readOnly />
      )}
      {alanHatalari.belgeNo && <span className="alan-hata">{alanHatalari.belgeNo}</span>}
    </label>

    {/* --- 3) TARIH ---
        ALIŞ İRSALİYESİNDE İADE KUTUSU TARİHİN SAĞINDA (kullanıcı 02.11.2026: "iade chek i irs tarihi sağına al") -
        araç çubuğundan buraya taşındı. */}
    {alisIrsaliye && setIade ? (
      <div className="alis-irs-yan">
        {tarihHucresi}
        <label className="satir-ici" title={alisMi ? c('İade: mal tedarikçiye geri gider - stok çıkar, cari borçlanır.') : c('İade: mal geri gelir - stok girer, cari alacaklanır.')}>
          <input type="checkbox" checked={!!iade} disabled={kilitli} onChange={e => setIade(e.target.checked)} />{c('İade')}
        </label>
      </div>
    ) : tarihHucresi}

    {/* --- 3b) TEKLIF DURUMU (218) - tarih sagina (kullanici). */}
    {teklifMi && (
      <label className="alan">
        <span className="etiket">{c('Durumu')}</span>
        <select value={teklif.durum} disabled={kilitli}
                onChange={e => teklif.setDurum(e.target.value)}>
          {Object.entries(TEKLIF_DURUMLARI).map(([k, v]) =>
            <option key={k} value={k}>{v}</option>)}
        </select>
      </label>
    )}

    {/* --- 4) e-BELGE ---
        Kavrami OLMAYAN turlerde (siparis, tahakkuk, depo belgesi, stok fisi)
        hucre cizilmez. Adres ve seri de basliktan cikti: e-Belge sekmesinde,
        XML'e giden alanlarla birlikte duruyorlar. Vergi Dairesi/VKN kartta
        gosterilmiyor - cari kartindan gelip belgeye DONDURULAN bilgi. */}
    {satisSiparis ? cariDepoHucresi : alisIrsaliye ? cariDepoHucresi : !eBelgeYok ? (
    faturaMi ? null : bantli ? bosHucre : eBelgeHucresi
    ) : depoBelgesi || stokFisiMi || teklifMi || basvuruMu || tahakkukMu ? null : kapanmaGoster ? (bantli ? bosHucre : kapanmaAlani) : (
      /* e-Belgesi de kapanmasi da olmayan tur (tahakkuk): hucre BOS BIRAKILIR.
         Yoksa temsilci yukari, 1. satirin sonuna kayardi - kullanici temsilciyi
         her turde CARININ ALTINDA istiyor. Teklifte yer tutucuya gerek yok:
         4. hucreyi zaten Durumu combosu dolduruyor - fazladan bos hucre
         2. sirayi bir saga kaydiriyordu (kullanici). */
      <span className="alan" aria-hidden />
    )}

    {/* --- 5) KISI-1 ---
        Transferde sorumluluk devri: Teslim Eden (zorunlu). Talepte bu hucre
        yok - talebi acan kisi 7. hucrede "Talep Eden" olarak sorulur.
        Satis temsilcisi PERSONEL'dir (cari degil) ve secim cari ile ayni
        TarafArama ekranindan yapilir - tek arama bicimi. */}
    {transferMi ? (
      <TarafAlani
        etiket="Teslim Eden"
        zorunlu
        deger={sevkiyat.teslimEden?.ad}
        kilitli={baslikKilitli}
        ipucu="Personel ara"
        onAc={() => setPersonelArama('eden')}
        hata={alanHatalari.teslimEdenId}
      />
    ) : talepMi || tahakkukMu ? null : satisSiparis ? <>{vadeHucresi}{saticiHucresi}</> : saticiHucresi}

    {/* --- 6) DEPO-2 ---
        Depo belgesinde malin GITTIGI depo, stok fisinde fisin tek deposu,
        carili belgelerde mal cikis/giris deposu. Tahakkukta depo YOK: stok
        etkilemez (kasa_islem_turu.stok_etkiler=0). */}
    {stokFisiMi ? (
      <GenLookup
        kaynak="depo"
        etiket={fisCikisMi ? 'Çıkış Deposu' : 'Giriş Deposu'}
        zorunlu
        sabitFiltre={{ alan: 'durum', op: 'esit', deger: 1 }}
        alanlar={LOOKUP_DEPO}
        deger={depo?.ad}
        saltOkunur={depoKilitli}
        hata={alanHatalari.cikisDepoId ?? alanHatalari.girisDepoId}
        onSec={x => setDepo(x ? { id: Number(x.id), ad: String(x.ad ?? '') } : null)}
      />
    ) : depoBelgesi ? null : teklifMi ? (
      /* Teklifte depo YOK (stok cikisi yapmaz, 222) - yerine 2. sira uclusu:
         Teslim Sekli (salt combo); Teklif Konusu 1. satirin basinda (bkz. 1b).
         Ikisi de kod listesinden; ETIKETE tiklaninca jenerik modalda
         duzenlenir (AyarAlani listeKod deseni). Gecerlilik Suresi = vade. */
      <KodListeAlani etiket="Teslim Şekli" listeKod="belge.teslim_sekli"
                     deger={teklif.teslim} onDeger={teklif.setTeslim}
                     kilitli={kilitli} />
    ) : !tahakkukMu && !darUst ? cariDepoHucresi : null}

    {/* --- 7) KISI-2 (yalniz depo belgeleri) --- */}
    {depoBelgesi && (
      <TarafAlani
        etiket={talepMi ? 'Talep Eden' : 'Teslim Alan'}
        zorunlu
        deger={sevkiyat.teslimAlan?.ad}
        kilitli={baslikKilitli}
        ipucu="Personel ara"
        onAc={() => setPersonelArama('alan')}
        hata={alanHatalari.teslimAlanId}
      />
    )}

    {/* --- 8) FATURA TIPI (130) BASLIKTAN CIKTI (kullanici): arac cubugunda,
        dugmelerin saginda duruyor - irsaliyedeki IADE kutusuyla ayni yerde. */}

    {/* --- 9) VADE / ODEYEN KURUM ---
        Faturada / tahakkukta vade anlamli (irsaliyede mal cikis tarihi esas).
        BASVURUDA (249) vade YOK, yerine ODEYEN KURUM: hizmeti kim odeyecek
        (kullanici: "basvuruda vade yerine Ödeyen Kurum olsun ve taraf_kurum
        listelensin"). Bos birakilirsa hasta kendi oder. */}
    {!tahakkukMu && !satisSiparis && vadeHucresi}
    {/* Bantlı faturada Vade'nin sağı boştu: istisna gerekiyorsa İstisna Nedeni oraya (08.11.2026). */}
    {faturaMi && !eBelgeYok && (bantli ? (istisnaGoster ? istisnaHucresi : bosHucre) : eBelgeHucresi)}

    {/* Fiyat Listesi combosu ASAGIDA, Rapor Dovizi cercevesinin saginda
        (kullanici, 218) - KalemSekmesi cizer. */}

    {/* --- 10-11) ZINCIR HUCRELERI ---
        Bagli Siparis, Faturalama Durumu'nun SOLUNDA (kullanici).
        Kapanma burada YALNIZ e-Belgeli turlerde: e-Belgesizde 4. hucreyi zaten
        o dolduruyor (temsilci carinin altina insin diye).
        Teklifte "Bağlı Sipariş" cizilmez (kullanici) - teklif zincirin BASI. */}
    {!depoBelgesi && !stokFisiMi && !teklifMi && !darUst && !(faturaMi && !eBelgeYok) && bagliSiparisAlani}
    {!eBelgeYok && kapanmaGoster && !bantli && kapanmaAlani}
  </div>
  </div>
</div>
)}

{/* Sekmeler BASLIK ALANLARININ ALTINDA, grid'in hemen ustunde -
    mockup duzeni (toolbar > hdr > tabs > pane). Tasiyici ve Imza/Teslim
    yalniz irsaliyede anlamli, o yuzden suzuluyor. */}
<div className="katab">
  {SEKMELER
    // Basvuruya ozel sekmeler (298) yalniz basvuruda; diger turlerde cizilmez.
    .filter(x => (!x.basvuru || basvuruMu)
              && (!x.teklif || teklifMi)
              && (!x.irsaliye || irsaliyeMi)
              && (!x.faturaYok || !(faturaMi || tahakkukMu))
              // Tahsilat: fatura/fis, tahakkuk VE SIPARIS (kullanici) - siparis
              //   avansi/on odemesi de bu sekmeden girilir, fatura kartindaki
              //   Nakit / Banka / POS / Çek / Senet dugmeleriyle ayni.
              && (!x.faturaMi || faturaMi || tahakkukMu || siparisMi)
              // Tahakkuk e-Belge DEGIL: GIB'e giden bir belge degil,
              //   ic muhasebe/cari ara kaydi.
              && !(eBelgeYok && x.anahtar === 'ebelge')
              // Transferde cari/fatura zinciri yok: yalniz Kalemler + Yorum.
              // "Faturalama" = bu belgeden turetilenler. Fatura zincirin
              //   sonu (faturaYok), depo belgesi ve stok fisi ise hic
              //   donusmez. Irsaliyede GORUNUR - kalem bicimine bakmak
              //   yanlisti, irsaliyeyi de gizliyordu.
              && !((bilgi.depoBelgesi || bilgi.stokFisi) && x.anahtar === 'fatura')
              // Teklifte Siparis sekmesi yalniz KABUL (3) durumunda (kullanici).
              && !(teklifMi && x.anahtar === 'fatura' && teklif.durum !== '3')
              // PROVIZYON yalniz ÖSS/SGK odeyen kurumda (kullanici): ozel
              //   kurumda ya da hasta kendi oderken alinacak provizyon yok,
              //   sekme bos duruyordu.
              && !(x.anahtar === 'provizyon' && !provizyonVar))
    .map(x => (
    <div key={x.anahtar}
         className={`kat${x.anahtar === aktifSekme ? ' on' : ''}`}
         // SEKME SEÇİMİ başlığı görüntüleme kipine alır (kullanıcı 08.11.2026) - alt bölüme geçince başlık okunur.
         onClick={() => { setBaslikDuzenle(false); setAktifSekme(x.anahtar) }}>
      {/* BASVURUDA kalem sekmesi "Ücretlendirme" (kullanici): hastaya yazilan
          islem/tetkik ucretleri - "kalem" ERP sozu, kayit kabulde karsiligi yok. */}
      {x.anahtar === 'tahsilat' && alisMi ? 'Ödeme'
        : x.anahtar === 'fatura' && teklifMi ? 'Sipariş'
        : x.anahtar === 'kalem' && basvuruMu ? 'Ücretlendirme' : x.baslik}
      {x.anahtar === 'kalem' && <span className="b">{satirlar.length}</span>}
      {x.anahtar === 'fatura' && donusumler.length > 0 && (
        <span className="b">{donusumler.length}</span>
      )}
    </div>
  ))}
</div>
  </>
  );
}

export interface BelgeBaslikProps {
  aktifSekme: string;
  setAktifSekme(v: string): void;
  alanHatalari: Record<string, string>;
  bilgi: BelgeTuruBilgisi;
  sonuc: BelgeYaniti | null;
  kilitli: boolean;
  /** Kalem girildikten sonra baslikta kilitlenen alanlar (depo, tip, tarih). */
  baslikKilitli: boolean;
  /** GENEL KURAL (11.11.2026): kalem varken depo combo(ları) salt okunur. */
  depoKilitli: boolean;
  /** Kart YENİ belge olarak açıldı (kayıtlı belge yok): fatura başlığı düzenleme kipinde başlar (bkz. baslikDuzenle). */
  yeniMi?: boolean;
  /**
   * Her artışta başlık GÖRÜNTÜLEME kipine döner (kullanıcı 08.11.2026: "başlık edit moddaysa ve +ekleme butona
   * basılırsa view moda geçmeli"): BelgeKarti kalem ekleme penceresi açılınca artırır. Sekme tıklaması başlığın
   * kendi içinde (katab).
   */
  baslikKapatAnahtari?: number;
  belgeAdi: string;
  belgeNo: string;
  setBelgeNo(v: string): void;
  tarih: string;
  setTarih(v: string): void;
  tarihEnGec: string;
  tarihEnErken?: string;
  /**
   * Provizyon sekmesi cizilsin mi (kullanici): yalniz odeyen kurumun turu
   * ÖSS (2) ya da SGK (3) iken. Özel kurumda / hasta kendi oderken alinacak
   * provizyon yoktur.
   */
  provizyonVar?: boolean;
  /**
   * Numarayi KULLANICI yazar (358, numara_sablonu.elle_girilir): numara alani
   * duzenlenebilir gelir. Bos birakilirsa sunucu yine uretir - belge numarasiz
   * kalmaz.
   */
  numaraElle?: boolean;
  /** Teklif basligi DEMET halinde (218/220/222): durum, revize no, konu,
      teslim sekli - sekiz ayri prop yerine tek nesne. */
  teklif: TeklifBilgisi;
  vadeGun: string;
  setVadeGun(v: string): void;
  /** Basvuru (249): vade yerine odeyen kurum combosu cizilir. */
  /**
   * Basvuru mu (246): baslik seridi HIC cizilmez - kimlik hasta bandinda,
   * tarih/bolum/hekim/odeyen kurum Basvuru sekmesinde (300). Bayrak yalniz
   * sekme suzgeci ve sekme adlari icin duruyor ("Kalemler" -> "Ücretlendirme").
   */
  basvuruMu?: boolean;
  cari: { id: number; unvan: string } | null;
  satici: Secim | null;
  depo: Secim | null;
  setDepo(v: Secim | null): void;
  girisDepo: Secim | null;
  setGirisDepo(v: Secim | null): void;
  /** Sevkiyat alanlari demeti - baslikta yalniz teslim eden/alan okunur. */
  sevkiyat: SevkiyatBilgisi;
  fisTipi: number;
  setFisTipi(v: number): void;
  /** Fatura tipi (130) - yalniz faturada gorunur. */
  faturaTipi: number;
  setFaturaTipi(v: number): void;
  senaryo: number;
  setSenaryo(v: number): void;
  /** KDV istisna nedeni (belge_efatura.istisna_kodu) - başlıkta Vade'nin sağında, yalnız gerektiğinde (08.11.2026). */
  istisnaKodu?: number;
  setIstisnaKodu?(v: number): void;
  satirlar: SatirDurumu[];
  donusumler: Record<string, unknown>[];
  /** Secim modallarini acan tetikleyiciler (kartta yasiyor). */
  setCariArama(v: boolean): void;
  setSaticiArama(v: boolean): void;
  setPersonelArama(v: 'eden' | 'alan' | null): void;
  /** Sag sutunda ture gore degisen hazir hucreler. */
  kapanmaAlani: React.ReactNode;
  /** Cari başlığındaki Ödeme / Tahsilat kutusu: belgenin genel toplamı ve bağlı ödeme toplamı. */
  odemeGenel?: number;
  odemeTahsil?: number;
  /** Kalem sayısı (Kapanma kutusunun alt satırı). */
  satirSayisiBaslik?: number;
  /** Alış irsaliyesinde İade kutusu başlıkta (giriş deposunun sağında). */
  iade?: boolean;
  setIade?(v: boolean): void;
  bagliSiparisAlani: React.ReactNode;
  // belgeTuru.ts davranis bayraklari
  alisMi: boolean;
  irsaliyeMi: boolean;
  faturaMi: boolean;
  siparisMi: boolean;
  konsinyeMi: boolean;
  tahakkukMu: boolean;
  depoBelgesi: boolean;
  stokFisiMi: boolean;
  fisCikisMi: boolean;
  transferMi: boolean;
  talepMi: boolean;
  disNumarali: boolean;
  eBelgeYok: boolean;
}

/**
 * KOD LISTELI KART ALANI (222): degeri kod listesinden onerilen combo.
 * `yazilabilir` ise input+datalist (kullanici listede olmayani da yazar),
 * degilse salt select. Etiket TIKLANINCA jenerik KodListesiModali acilir -
 * liste icerigi (Teklif Konusu, Teslim Sekli...) oradan yonetilir; modal
 * kapaninca oneriler tazelenir (AyarAlani listeKod deseniyle ayni).
 */
function KodListeAlani({ etiket, listeKod, deger, onDeger, kilitli, yazilabilir }: {
  etiket: string;
  listeKod: string;
  deger: string;
  onDeger(v: string): void;
  kilitli: boolean;
  yazilabilir?: boolean;
}) {
  const [secenekler, setSecenekler] = useState<string[]>([]);
  const [modal, setModal] = useState(false);
  const [surum, setSurum] = useState(0);
  const [acik, setAcik] = useState(false);
  useEffect(() => {
    if (!acik) return;
    const kapat = () => setAcik(false);
    window.addEventListener('click', kapat);
    return () => window.removeEventListener('click', kapat);
  }, [acik]);
  useEffect(() => {
    let iptal = false;
    void (async () => {
      try {
        const y = await api.kodListe(listeKod);
        if (!iptal)
          setSecenekler(y.degerler.filter(d => d.aktif === 1).map(d => d.ad));
      } catch { /* liste yoksa oneriler bos kalir */ }
    })();
    return () => { iptal = true };
  }, [listeKod, surum]);
  return (
    <label className="alan">
      <span className="etiket" role="button" tabIndex={0}
            title={c('Liste içeriğini düzenle')} style={{ cursor: 'pointer' }}
            onClick={e => { e.preventDefault(); setModal(true) }}>
        {etiket} ✎
      </span>
      {yazilabilir ? (
        /* TEK ALAN, HEM LISTE HEM SERBEST (kullanici 26.10.2026: "konusu 2 alan degil tek olsun.. hem listeden
           secebileyim hem de istersem serbest yazayim", "combo yap"): yazilabilir edit + ▾ - ok BUTUN listeyi acar,
           secim editi doldurur, yazilan serbest kalir. */
        <span className="lookup-kutu kla-combo" onClick={e => e.preventDefault()}>
          <input value={deger} maxLength={100} disabled={kilitli} autoComplete="off"
                 onChange={e => onDeger(e.target.value)} />
          {!kilitli && (
            <button type="button" className="mini" aria-haspopup="listbox" aria-expanded={acik}
                    title={c('Listeden seç')} onClick={e => { e.stopPropagation(); setAcik(a => !a) }}>▾</button>)}
          {acik && (
            <div className="dugme-menu-liste kla-liste" role="listbox" onClick={e => e.stopPropagation()}>
              {secenekler.length === 0
                ? <div className="sonuk kla-bos">{c('Liste boş - etikete tıklayıp ekleyin.')}</div>
                : secenekler.map(a => (
                    <button key={a} type="button" className="mi" role="option" aria-selected={a === deger}
                            onClick={() => { onDeger(a); setAcik(false) }}>{a}</button>))}
            </div>)}
        </span>
      ) : (
        <select value={deger} disabled={kilitli}
                onChange={e => onDeger(e.target.value)}>
          <option value="">{c('Seçiniz…')}</option>
          {/* Kayitli deger listeden silinmisse yine gorunsun. */}
          {deger && !secenekler.includes(deger) && <option value={deger}>{deger}</option>}
          {secenekler.map(a => <option key={a} value={a}>{a}</option>)}
        </select>
      )}
      {modal && (
        <KodListesiModali kod={listeKod} baslik={etiket}
                          onKapat={() => { setModal(false); setSurum(x => x + 1) }} />
      )}
    </label>
  );
}
