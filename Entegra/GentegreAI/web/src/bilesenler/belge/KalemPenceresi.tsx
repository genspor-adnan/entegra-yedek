import { useEffect, useRef, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { para, hamSayi, yerelAnMetni } from '../bicim';
import {
  type SatirDurumu, satirTutari, adetKaydir, KDV_ORANLARI,
} from '../../sayfalar/belgeSatir';
import { DOVIZ_KODLARI } from '../../sayfalar/belgeSabitleri';
import { baslangicBrutMetni, bruta, moduCevir } from '../../sayfalar/belgeKarti/kdvModu';
import { IzlemPenceresi } from './IzlemPenceresi';
import { EK_KATKILI_ROTALAR, SAF_SGK_ROTA } from '../../sayfalar/belgeKartiKurallari';

export function KalemPenceresi({ satir, transferMi, vergisiz, yerelPara, siparisMi,
                         basvuruMu, tarifeTipi = 0, rota = 0,
                         anaBirimKod = 0, anaBirimAdi = '',
                         girisIzlemi, cikisIzlemi, cikisDepoId, belgeTarihi,
                         onKapat, onKaydet }: {
  satir: SatirDurumu;
  /** Mal DEPOYA giriyor: izlemli stokta fiyattan sonra lot GIRIS ekrani acilir. */
  girisIzlemi: boolean;
  /** Mal DEPODAN cikiyor: izlemli stokta lot SECIM ekrani acilir. */
  cikisIzlemi: boolean;
  /** Cikis deposu - lot listesi bu depoya gore suzulur. */
  cikisDepoId: number | null;
  /** Genel Ayarlar'daki defter para birimi - "dovizli mi" karari buna gore. */
  yerelPara: string;
  /** Stok fisi: fiyat var (muhasebe matrahi) ama KDV/iskonto YOK - vergi dogurmaz. */
  vergisiz: boolean;
  /** Depo transferi: para yok - yalniz miktar, seri/lot ve aciklama sorulur. */
  transferMi: boolean;
  /** Siparis: satira TESLIM TARIHI (termin) sorulur (140). */
  siparisMi: boolean;
  /**
   * ODEME PAYLASIMI (289) bayragi KALDIRILDI (586): pencerede ona bagli tek sey
   * "Ek Katkı" kutusuydu, o da kalkti - hastanin payi artik Katkı Fiyatı
   * kutusundan FIYAT olarak giriliyor ve kovalari sunucu boluyor.
   */
  /** Basvuru (kayit kabul): fiyat HER ZAMAN KDV dahil girilir. */
  basvuruMu?: boolean;
  /**
   * BELGENIN FIYAT LISTESININ TARIFE TIPI (586): 1 Özel · 2 TTB/HUV · 3 SUT.
   *
   * Özel tarifede satirin TEK fiyati vardir; TTB/SUT'ta ise fiyat KURUMUN
   * odedigi bedeldir, hastanin cebinden cikan tutar KATKI PAYIDIR. Pencere
   * buna gore hem "Katkı Fiyatı" kutusunu acar hem de iskontonun hangi tabana
   * islediğini soyler (kullanici: "iskonto yapılırsa özelde tek olan fiyat
   * üzerinden, ttb ve sut ta ise katkı üzerinden olur").
   */
  tarifeTipi?: number;
  /**
   * ÖDEME ROTASI (595) - 1 Özel · 2 ÖSS · 3 TSS · 4 Karma · 5 SGK.
   * "Katkı Fiyatı" kutusu yalnız EK KATKI KOVASI OLAN rotalarda sorulur.
   */
  rota?: number;
  /** Stok kartinin ANA BIRIMI (143) - ambalaj listesinin ilk ogesi, carpan 1. */
  anaBirimKod?: number;
  anaBirimAdi?: string;
  /** Kur bu tarihten okunur (belge tarihi) - bugunun kuru degil. */
  belgeTarihi: string;
  onKapat(): void;
  onKaydet(r: SatirDurumu): void;
}) {
  const [r, setR] = useState<SatirDurumu>(satir);
  /**
   * KDV GIRIS MODU (kullanici): fiyat kutusuna BRUT mu MATRAH mi yaziliyor.
   * Varsayilan FIYAT LISTESINDEN gelir (`satir.kdvDahil` - fiyat cozulurken
   * yazilir); kullanici degistirebilir, cunku liste yanlis kurulmus ya da o
   * kalem istisna olabilir. Saklanan `birimFiyat` HER ZAMAN matrahtir.
   */
  /**
   * BASVURUDA MOD HEP "DAHIL" (kullanici: "hbys'de fiyatlar hep kdv dahil
   * veriliyor, ücretlemede o görülmek isteniyor") - combo cizilir ama
   * kilitlidir; oteki belge turlerinde fiyat listesinin ayarindan gelir ve
   * kullanici degistirebilir.
   */
  const [kdvDahil, setKdvDahil] = useState(
    basvuruMu || Number(satir.kdvDahil ?? 0) === 1);
  /**
   * DAHIL modunda kutuda gorunen BRUT METIN. Kullanicinin yazdigi metin
   * oldugu gibi tutulur; satira MATRAH yazilir. Her tusa basista matrahtan
   * geri uretmek "12," gibi ara yazimlarda ondalik ayracini yiyordu.
   */
  const [brutMetni, setBrutMetni] = useState(() => baslangicBrutMetni(satir, basvuruMu));
  /**
   * SGK (SUT) BEDELI KUTUSUNDAKI METIN - 483.
   *
   * TSS / Karma / SGK rotalarinda satirda IKI fiyat calisir: SGK'nin odedigi
   * SUT bedeli ve tarife (TTB/HUV) bedeli. Ekran bugune kadar yalniz tarifeyi
   * soruyordu; sozlesmenin SUT listesinde kalem yoksa SGK payi sessizce sifir
   * kaliyor ve tutarin tamami sigortaya/hastaya yaziliyordu (kullanici: "bana
   * sadece bir defa sigorta ucretini sordu, oysa sgk sut fiyatini da bulup
   * atmasi gerekirdi; eger yoksa ekrandan onu almasi gerekir").
   *
   * Kutu ANA FIYATLA AYNI MODDA yazilir (dahil/haric); satirda saklanan
   * `sgkListe` her zaman MATRAHTIR - kovalar KDV haric tutulur.
   */
  const [sutMetni, setSutMetni] = useState(() => {
    const ham = String(satir.sgkListe ?? '');
    if (ham === '') return '';
    return (basvuruMu || Number(satir.kdvDahil ?? 0) === 1)
      ? moduCevir(ham, satir.kdv, true) : ham;
  });
  /**
   * KATKI KUTUSU METNI (591) - SUT bedeli kutusuyla AYNI DESEN. Kullanici:
   * "hasta katkı 750 KDV dahildi, sen tekrar KDV eklemişsin". Kutu Dahil
   * modunda BRUT gosterir, satira yazilan her zaman MATRAHTIR (kovalar KDV
   * haric tutulur). Onceden kutu ham degeri gosteriyor, satira da onu
   * yaziyordu - KDV dahil listeden gelen 750 TL katki kovaya matrah girip
   * ekranda 825 TL olarak okunuyordu.
   */
  const [katkiMetni, setKatkiMetni] = useState(() => {
    const ham = String(satir.katkiTutar ?? '');
    if (ham === '') return '';
    return (basvuruMu || Number(satir.kdvDahil ?? 0) === 1)
      ? moduCevir(ham, satir.kdv, true) : ham;
  });
  const [hata, setHata] = useState<string | null>(null);
  /** Lot penceresi acik mi - miktar/fiyat girildikten SONRA acilir. */
  const [izlemAcik, setIzlemAcik] = useState(false);
  /** Kur kutusu kullanici tarafindan degistirildi mi - degistiyse ustune yazma. */
  const kurElle = useRef(false);
  /** Kalem gride YAZILDI mi - ikinci "Tamam" (Enter + tik) satiri cogaltmasin. */
  const kaydedildi = useRef(false);

  const degis = (alan: keyof SatirDurumu, deger: string | number) =>
    setR(x => ({ ...x, [alan]: deger }));

  /**
   * AMBALAJ BIRIMLERI (143). Liste her zaman ANA BIRIMLE baslar (carpan 1),
   * ardindan stogun tanimli ambalajlari gelir. Ambalaj yoksa liste tek ogeli
   * kalir ve secici hic cizilmez - eski davranis aynen surer.
   */
  const [birimler, setBirimler] = useState<{ birim: number; ad: string; carpan: number }[]>([]);
  useEffect(() => {
    if (!r.stokId) { setBirimler([]); return }
    void (async () => {
      const ana = { birim: anaBirimKod, ad: anaBirimAdi, carpan: 1 };
      try {
        const y = await api.liste('stok-birim', {
          sayfa: 1, boyut: 20,
          filtre: { op: 'and', kosullar: [
            { alan: 'stokId', op: 'esit', deger: r.stokId },
            { alan: 'durum', op: 'esit', deger: 1 },
          ] },
        });
        setBirimler([ana, ...y.satirlar
          .filter(s => Number(s.birim) !== anaBirimKod)
          .map(s => ({
            birim: Number(s.birim),
            ad: String(s.birimAdi ?? ''),
            carpan: Number(s.carpan) || 1,
          }))]);
      } catch { setBirimler([ana]) }
    })();
  }, [r.stokId, anaBirimKod, anaBirimAdi]);

  /** Enter = Tamam: adet/fiyat yazip Enter'a basinca satir gride eklenir. */
  const tus = (e: React.KeyboardEvent) => {
    // Basili tutulan Enter'in TEKRARI kaydetme sayilmaz (594): ilk tus kalemi
    //   kaydedip pencereyi kapatiyor, tekrarlar arkadaki arama penceresine
    //   dusup ikinci bir kalem ekliyordu.
    if (e.key === 'Enter' && !e.repeat) { e.preventDefault(); kaydet() }
  };

  const dovizli = r.fiyatDovizi !== yerelPara && r.fiyatDovizi !== '';

  // Dovizli kalemde gunun kuru cekilir; kullanici kutuyu elle degistirdiyse
  //   dokunulmaz (kur pazarlikli olabiliyor - "istenirse degistirilebilsin").
  useEffect(() => {
    if (!dovizli || kurElle.current) return;
    void (async () => {
      try {
        const y = await api.dovizKur(r.fiyatDovizi, belgeTarihi);
        if (y.kur && y.kur > 0 && !kurElle.current) setR(x => ({ ...x, kur: String(y.kur) }));
      } catch { /* kur yoksa kullanici elle girer */ }
    })();
  }, [dovizli, r.fiyatDovizi, belgeTarihi]);

  const adet = hamSayi(r.adet);
  /** Ana birim karsiligi: "2 Kutu = 24 Adet". Ana birim seciliyse gosterilmez. */
  const seciliCarpan = Number(r.birimCarpan ?? 1) || 1;
  const anaBirimMiktar = seciliCarpan !== 1 && adet > 0
    ? Math.round(adet * seciliCarpan * 1e6) / 1e6
    : null;
  const kur = dovizli ? (hamSayi(r.kur)) : 1;
  const dovizFiyat = hamSayi(r.dovizFiyat);
  // Yerel birim fiyat: dovizli kalemde doviz fiyati x kur, degilse dogrudan girilen.
  const fiyat = dovizli
    ? Math.round(dovizFiyat * kur * 100) / 100
    : (hamSayi(r.birimFiyat));
  const tutar = satirTutari(adet, fiyat, r.iskonto, r.iskonto2);
  /**
   * ONIZLEME KDV MODUNU IZLER (kullanici: "tutar (önizleme) için kdv durumuna
   * bak, dahilse burayı da dahil, hariçse hariç yap").
   *
   * Satirda saklanan `birimFiyat` HER ZAMAN matrahtir; onizleme ise kullanicinin
   * KUTUYA YAZDIGI sayiyla ayni dilde konusmali - "100 TL dahil" yazip altta
   * 83,33 gormek, fiyati yanlis girdim sanisi veriyordu.
   */
  /**
   * BRUT, MATRAHI CARPARAK DEGIL KULLANICININ YAZDIGI SAYIDAN (kullanici:
   * "fiyat ekranina 500 girdim, altta onizlemede 500,01 gorundu").
   *
   * Dahil modunda kutuya yazilan BRUTTUR; satira matrah olarak cevrilip
   * saklanir. Onizleme ise ters yone gidiyordu: 500 / 1,10 = 454,5455,
   * satir tutari 454,55'e yuvarlaniyor, x 1,10 = 500,005 -> 500,01. Kurus
   * bir kez yuvarlandiktan sonra geri gelmiyor.
   *
   * Dogrusu brut fiyati TABAN almak; satir tutari yuvarlamasi ona uygulanir.
   * Sunucu da ayni kurali izler - dip toplamda KDV "brut tutar - matrah
   * tutar"dir, orandan hesaplanmaz (`BelgeDeposu.Yazma`).
   */
  const brutFiyat = kdvDahil ? (hamSayi(brutMetni) || bruta(fiyat, r.kdv)) : fiyat;
  const onizlemeTutar = kdvDahil
    ? satirTutari(adet, brutFiyat, r.iskonto, r.iskonto2) : tutar;
  /**
   * KATKI (HASTA EK KATKISI) KUTUSU (586) - yalniz TTB/HUV ve SUT tarifesinde
   * ve kalemin katkisi VARSA. Özel tarifede boyle bir ayrim yok: tek fiyat
   * zaten hastanindir.
   *
   * ROTA DA SORULUR (595, kullanici: "ÖSS, Karma'da katkı ve ek katkı payı
   * yok"): hasta ek katkısı yalnız TSS (3) ve SGK (5) rotasında doğar -
   * ÖSS ve Karma'da hastanin payi KARSILAMA ORANINDAN cikar. Kutu oralarda da
   * aciliyor, kullanici hicbir yere yazilmayan bir rakam giriyordu.
   * Satirin kendi rotasi (kayitli satirda sunucudan gelir) onceliklidir.
   */
  const etkinRota = Number(r.rota ?? 0) || Number(rota ?? 0);
  const katkiliTarife = [2, 3].includes(Number(tarifeTipi))
                     && EK_KATKILI_ROTALAR.includes(etkinRota);
  /**
   * SGK HASTASINDA SUT KUTUSU YOK (601, kullanici: "SGK (SUT) Bedeli zaten
   * birim fiyatta var bir daha yazmaya gerek yok"). Saf SGK'da tarife = SUT
   * oldugu icin ustteki "Birim Fiyat" ile bu kutu AYNI sayiyi soruyordu.
   * Bedel kaydederken birim fiyattan turetilir (bkz. `kaydet`).
   */
  const sutKutusu = !!r.sgkGerekli && etkinRota !== SAF_SGK_ROTA;
  /**
   * SGK'DA FIYAT VE KATKI SALT OKUNUR (602, kullanici: "SGK'da birim fiyat ve
   * katkı değişmez. İskonto uygulanabilir ama o da sadece katkıya uygulanır.
   * SUT fiyatı hiçbir şekilde değişmez").
   *
   * Saf SGK'da birim fiyat SUT bedelidir - SGK'nin mevzuatla belirlenmis
   * odemesi. Hastanenin onu degistirmesi diye bir sey yoktur; katki da
   * listeden gelen tanimli tutardir. Degistirilebilir birakmak, kaydedince
   * sunucunun listeden okudugu rakama geri donen bir kutu demekti.
   *
   * ISKONTO KUTUSU ACIK KALIR: indirim mesrudur, yalniz KATKIYA isler
   * (fn_dagilim_coz - SUT carpani koşulsuz miktardir).
   */
  const sgkKilitli = etkinRota === SAF_SGK_ROTA;
  const katkiVar = katkiliTarife && hamSayi(r.katkiTutar ?? '0') > 0;
  /** Iskontolu katki - sunucudaki kural (586) ile ayni: birim x adet x iskonto. */
  const katkiTutari = satirTutari(adet, hamSayi(r.katkiTutar ?? '0'),
                                  r.iskonto, r.iskonto2);

  /**
   * ISKONTO SONRASI BIRIM FIYAT - ONIZLEME (602, kullanici: "fiyat ekranında
   * en alta önizlemeye iskonto sonrası birim fiyatı getir").
   *
   * Ust kutu iskontoSUZ birimi gosterir (özel iste oldugu gibi); iskonto ancak
   * Tutar'a bakilinca anlasiliyor ve adet 1'den buyukse orada da goze
   * carpmiyordu. Taban, UST KUTUDA YAZAN sayidir: saf SGK'da hasta katkisi,
   * oteki rotalarda birim fiyat - SUT iskontolanmaz (fn_dagilim_coz), onu
   * iskontolu gostermek yanlis olurdu.
   *
   * Hesap `satirTutari` ile yapilir (adet 1): satir tutarindaki yuvarlama
   * kuralinin AYNISI - kendi carpanini yazmak kurus farki uretirdi.
   */
  const iskontoTabani = sgkKilitli ? hamSayi(r.katkiTutar ?? '0') : fiyat;
  const iskontoluBirim = satirTutari(1, iskontoTabani, r.iskonto, r.iskonto2);
  // Iskontolu birim de brut tabandan (yukaridaki ayni gerekce).
  const onizlemeBirim = kdvDahil
    ? satirTutari(1, sgkKilitli ? bruta(iskontoTabani, r.kdv) : brutFiyat,
                  r.iskonto, r.iskonto2)
    : iskontoluBirim;
  /** Iskonto gercekten var mi - yoksa satir ust kutunun kopyasi olurdu. */
  const iskontoluMu = Math.abs(iskontoTabani - iskontoluBirim) > 0.004;

  /** Izlemli stokta lot adimi: giriste DAGITIM, cikista SECIM (db/114). */
  const izlemGerekli = (girisIzlemi || cikisIzlemi) && r.satirTur === 1 && r.izleme > 0;

  function kaydet() {
    // TEK SEFER (kullanici: "tamam deyince ücret satırına 2 tane muayene
    //   ekledi"): Enter ile dugme tiklamasi ust uste gelebiliyor (Enter
    //   odaktaki dugmeyi de tetikler) ve ayni kalem IKI KEZ gride giriyordu.
    //   Pencere zaten kaydettikten sonra kapaniyor; ikinci cagri yok sayilir.
    if (kaydedildi.current) return;
    if (!r.stokId && !r.hizmetId) { setHata('Stok ya da hizmet seçilmeli.'); return }
    if (adet <= 0) { setHata('Miktar sıfırdan büyük olmalı.'); return }
    if (dovizli && kur <= 0) { setHata('Kur sıfırdan büyük olmalı.'); return }
    // SGK (SUT) BEDELI ZORUNLU (483): bu rotada SGK bir pay oder ve bedel
    //   listeden cozulemedi. Bos birakilirsa pay sessizce sifir kalir ve
    //   tutarin tamami sigortaya/hastaya yuklenir - sessiz para hatasi.
    //   "SGK bu hizmeti odemiyor" da gecerli bir cevaptir: 0 yazilir.
    //   SAF SGK BUNUN DISINDA (601): orada kutu hic cizilmiyor, bedel birim
    //   fiyattan turetiliyor - sorulmayan bir alani zorunlu tutmak kalemin
    //   kaydedilmesini imkansiz kilardi.
    if (sutKutusu && String(r.sgkListe ?? '').trim() === '') {
      setHata('SGK (SUT) bedeli girilmeli. SGK bu hizmeti ödemiyorsa 0 yazın.');
      return;
    }
    // Izlemli stokta once LOT dagitimi: miktar ve fiyat girildikten sonra lot
    //   ekrani acilir, kalem ancak dagitim tamamlaninca gride eklenir.
    if (izlemGerekli) { setHata(null); setIzlemAcik(true); return }
    // Belgeye YEREL fiyat gider; doviz/kur bilgisi satirda saklanir ki kalem
    //   tekrar acildiginda ayni degerlerle gelsin.
    kaydedildi.current = true;
    // SAF SGK'DA SUT ELLE GONDERILMEZ (602, kullanici: "SUT fiyatı hiçbir
    //   şekilde değişmez"): bedel her zaman SOZLESMENIN SUT listesinden okunur
    //   (fn_dagilim_coz). Elle deger gecmek `sgk_liste_elle` bayragini takar ve
    //   satiri listeden tazelenemez hale getirirdi - SUT guncellenince eski
    //   rakam satirda donardi. Alan temizlenir ki onceki denemelerden kalmis
    //   bir deger de bayragi tetiklemesin.
    const sgk = etkinRota === SAF_SGK_ROTA ? { sgkListe: '' } : {};
    onKaydet({ ...r, birimFiyat: String(fiyat), ...sgk });
  }

  return (
    <Modal
      baslik={r.stokAdi || 'Kalem'}
      dar
      onKapat={onKapat}
      alt={
        <>
          <button className="d onay" onClick={kaydet}>💾 Tamam (Enter)</button>
          <button className="d kapat-dugmesi" onClick={onKapat}>✖ Kapat</button>
        </>
      }
    >
      <>
        {hata && <div className="hata-kutusu">{hata}</div>}
        {/* Cerceve kalir, BASLIK yok: pencere basligi zaten stok/hizmet adi. */}
        <div className="kagrup">
          {/* Alanlar ALT ALTA ve giris sirasinda: Miktar > Birim Fiyat > KDV >
              Iskonto. Stok/hizmet adi PENCERE BASLIGINDA yaziyor - burada
              tekrarlamak yer kaplamaktan baska ise yaramiyordu. */}
          <div className="alan-izgara tek-sutun">
            <label className="alan">
              <span className="etiket">Miktar</span>
              <span className="ikili">
                {/* Eksi isareti elle de yazilamaz. Yukari/asagi ok = +1 / -1. */}
                <input autoFocus className="hiza-sag" value={r.adet}
                       onKeyDown={e => {
                         if (e.key === 'ArrowUp') { e.preventDefault(); degis('adet', adetKaydir(r.adet, +1)) }
                         else if (e.key === 'ArrowDown') { e.preventDefault(); degis('adet', adetKaydir(r.adet, -1)) }
                         else tus(e);
                       }}
                       onChange={e => degis('adet', e.target.value.replace(/-/g, ''))} />
                {/* Fare ile hizli artir/azalt - klavyeden yazmak da serbest. */}
                <button type="button" className="mini" title="Azalt"
                        onClick={() => degis('adet', adetKaydir(r.adet, -1))}>−</button>
                <button type="button" className="mini" title="Artır"
                        onClick={() => degis('adet', adetKaydir(r.adet, +1))}>+</button>
                {/* AMBALAJ BIRIMI (143): stogun tanimli birimleri. Secilen birim
                    yalnizca GIRIS bicimidir - stok her zaman ANA BIRIMDE hareket
                    eder, carpim asagida gosterilir. Tek birim varsa (ambalaj
                    tanimlanmamis) liste cizilmez. */}
                {birimler.length > 1 && (
                  <select className="birim" value={String(r.birim ?? 0)}
                          title="Giriş birimi"
                          onChange={e => {
                            const b = birimler.find(x => String(x.birim) === e.target.value);
                            degis('birim', Number(e.target.value));
                            degis('birimCarpan', b?.carpan ?? 1);
                          }}>
                    {birimler.map(b => (
                      <option key={b.birim} value={b.birim}>{b.ad}</option>
                    ))}
                  </select>
                )}
              </span>
              {/* Ana birim karsiligi: "2 Kutu = 24 Adet". Kullanici ne kadar mal
                  cikacagini kaydetmeden gorur. */}
              {anaBirimMiktar !== null && (
                <span className="alan-notu">
                  = {anaBirimMiktar.toLocaleString('tr-TR')} {anaBirimAdi}
                </span>
              )}
            </label>

            {/* Birim fiyat KARTIN para biriminde girilir (stok arama ekraninda
                gorulen fiyat/doviz). Yerel para disindaysa yaninda gunun kuru
                (elle degistirilebilir) ve ALTINDA yerel karsilik satiri cikar.
                TRANSFERDE hic sorulmaz: mal satilmiyor, depo degistiriyor. */}
            {!transferMi && (
            <label className="alan">
              {/* SGK'DA UST KUTU HASTA KATKISI (602, kullanici: "sgk için fiyat
                  ekranına da artık birim fiyat yerine katılım payı gelsin,
                  altında sut fiyatı görünsün ve iskonto yine birim fiyat
                  üzerinden olsun - özel gibi sistem değişmesin").

                  Saf SGK'da satirin iki bedeli vardir ve HASTANIN odedigi
                  katkidir; iskonto da yalniz ona isler (fn_dagilim_coz). Ust
                  kutuda SUT durunca "iskonto birim fiyata uygulanir" kurali
                  ekranda yalan soyluyordu - SUT degismiyor, asagidaki katki
                  degisiyordu. Kutular yer degistirdi: ustte katki, altinda
                  SUT. Ozel/TSS/ÖSS'de hicbir sey degismez. */}
              <span className="etiket">{sgkKilitli ? 'Hasta Katkısı' : 'Birim Fiyat'}</span>
              <span className="ikili">
                {/* DAHIL modunda kutuda BRUT deger durur; satira yazilan
                    her zaman MATRAHTIR (satir matematigi, dip toplam ve
                    e-Belge matrah uzerinden yurur). */}
                <input className="hiza-sag"
                       value={sgkKilitli
                         ? (kdvDahil ? katkiMetni : String(r.katkiTutar ?? ''))
                         : (kdvDahil ? brutMetni : (dovizli ? r.dovizFiyat : r.birimFiyat))}
                       onKeyDown={tus}
                       readOnly={sgkKilitli}
                       title={sgkKilitli
                         ? 'Hastanın ödeyeceği katkı - SUT listesinden gelir, '
                           + 'değiştirilemez. İskonto bu tutara işler.'
                         : undefined}
                       onChange={e => {
                         const alan = dovizli ? 'dovizFiyat' : 'birimFiyat';
                         if (!kdvDahil) {
                           // HARIC modda brut TURETILIR - kullanici matrah yaziyor.
                           setR(x => ({ ...x, [alan]: e.target.value,
                                        birimFiyatKdvli: moduCevir(e.target.value,
                                                                   x.kdv, true) }));
                           return;
                         }
                         setBrutMetni(e.target.value);
                         // Kullanicinin YAZDIGI brut oldugu gibi saklanir;
                         //   matrah ondan turetilir (371).
                         setR(x => ({ ...x, birimFiyatKdvli: e.target.value,
                                      [alan]: moduCevir(e.target.value, x.kdv, false) }));
                       }} />
                {/* Para birimi SECILEBILIR (kullanici): stok kartindan gelen doviz
                    degistirilebilmeli - ayni urun bir belgede USD, otekinde TL
                    fiyatlanabiliyor. Yerel paraya donunce kur 1'e cekilir. */}
                <select className="birim" value={r.fiyatDovizi || yerelPara}
                        onChange={e => {
                          const yeniCins = e.target.value;
                          kurElle.current = false;
                          if (yeniCins === yerelPara) {
                            // Yerel paraya donus: o anki YEREL fiyat korunur.
                            setR(x => ({ ...x, fiyatDovizi: yeniCins, kur: '1',
                                         dovizFiyat: x.birimFiyat }));
                          } else {
                            // Dovize gecis: yerel fiyat kur ile boluner (kur
                            //   birazdan gunluk kurla guncellenir).
                            const k = hamSayi(r.kur) || 1;
                            const yerel = hamSayi(r.birimFiyat);
                            setR(x => ({ ...x, fiyatDovizi: yeniCins,
                                         dovizFiyat: k > 0 ? String(yerel / k) : x.dovizFiyat }));
                          }
                        }}>
                  {[yerelPara, ...DOVIZ_KODLARI.filter(k => k !== yerelPara)]
                    .map(k => <option key={k} value={k}>{k}</option>)}
                </select>
                {dovizli && (
                  <input className="hiza-sag kur" value={r.kur} onKeyDown={tus}
                         title="Günlük kur — değiştirilebilir"
                         onChange={e => { kurElle.current = true; degis('kur', e.target.value) }} />
                )}
              </span>
            </label>
            )}

            {/* SUT BEDELI - SGK'DA KATKININ ALTINDA (602, kullanici: "altında
                sut fiyatı görünsün"). SALT OKUNUR: SGK'nin mevzuatla belirlenmis
                odemesidir, iskonto da islemez - burada yalnizca GORUNUR, cunku
                satirin tutari bu bedel + hasta katkisidir ve kullanici toplami
                nereden geldigini okuyabilmeli. Duzenlenebilir SUT kutusu
                TSS/Karma'da (asagida, `sutKutusu`) durmaya devam eder - orada
                bedel gercekten ekrandan gelebilir. */}
            {sgkKilitli && !transferMi && (
              <label className="alan">
                <span className="etiket">SUT Bedeli</span>
                <span className="ikili">
                  <input className="hiza-sag" readOnly tabIndex={-1}
                         value={kdvDahil ? brutMetni : r.birimFiyat}
                         title={r.sgkListeBulundu === false
                           ? 'SUT listesinde bu kalem yok - SGK payı doğmaz'
                           : "SGK'nın ödediği bedel - sözleşmenin SUT listesinden"} />
                  <input className="birim" value={r.fiyatDovizi || yerelPara}
                         readOnly tabIndex={-1} />
                </span>
                {r.sgkListeBulundu === false && (
                  <span className="ipucu uyari">
                    SUT listesinde fiyat bulunamadı - bu kalem için SGK payı doğmaz.
                  </span>
                )}
              </label>
            )}

            {/* KATKI FIYATI (586, kullanici: "kurum ödeme fiyat tipi ttb/huv veya
                sut ise ve hasta katkı payı varsa Birim Fiyat, Döviz altına aynı
                genişliklerde Katkı Fiyatı ve Döviz ekle"). Birim fiyat KURUMUN
                odedigi tarife bedeli; bu kutu HASTANIN odedigi katilim payidir.
                Birim basina girilir - miktar ve iskonto sunucuda islenir. */}
            {/* SGK'DA BU KUTU CIZILMEZ (602): katki artik EN USTTE, "Hasta
                Katkısı" basligiyla duruyor - ikinci kez sormak ayni sayiyi iki
                kutuda gostermek olurdu. TSS/HUV'da eski yerinde kalir. */}
            {katkiVar && !sgkKilitli && !transferMi && (
              <label className="alan">
                <span className="etiket">Hasta Katkısı</span>
                <span className="ikili">
                  <input className="hiza-sag" onKeyDown={tus}
                         value={kdvDahil ? katkiMetni : String(r.katkiTutar ?? '')}
                         readOnly={sgkKilitli}
                         title={sgkKilitli
                           ? 'SGK hastasında hasta katkısı listeden gelir - değiştirilemez'
                           : 'Hastadan alınacak katkı - hastaneye kalır (birim başına)'}
                         onChange={e => {
                           const v = e.target.value;
                           if (kdvDahil) setKatkiMetni(v);
                           setR(x => ({ ...x,
                             katkiTutar: kdvDahil ? moduCevir(v, x.kdv, false) : v }));
                         }} />
                  {/* Doviz kutusu ana fiyatla AYNI GENISLIKTE ve ayni cinste:
                      katki tarife fiyatiyla ayni para biriminde tanimlanir. */}
                  <input className="birim" value={r.fiyatDovizi || yerelPara}
                         readOnly tabIndex={-1} />
                </span>
                <span className="alan-notu">
                  {adet.toLocaleString('tr-TR')} × katkı
                  {hamSayi(r.iskonto) > 0 || hamSayi(r.iskonto2) > 0 ? ' − iskonto' : ''}
                  {' = '}{para.format(kdvDahil
                      ? satirTutari(adet, bruta(hamSayi(r.katkiTutar ?? '0'), r.kdv),
                                    r.iskonto, r.iskonto2)
                      : katkiTutari)}
                  {' · kalanı kurum öder'}
                </span>
              </label>
            )}

            {!transferMi && dovizli && (
              <label className="alan">
                <span className="etiket">Yerel Para</span>
                <span className="ikili">
                  <input className="hiza-sag onizleme" value={para.format(fiyat)} readOnly />
                  <input className="birim" value={yerelPara} readOnly tabIndex={-1} />
                </span>
              </label>
            )}

            {/* SGK (SUT) BEDELI (483) - yalniz SGK payi olan rotalarda
                (TSS/Karma/SGK). Ustteki fiyat SIGORTANIN/hastanin odedigi
                tarife bedelidir; bu ise SGK'nin odedigidir. Ikisi ayri
                fiyattir ve satirda birlikte yasar. */}
            {sutKutusu && !transferMi && (
              <label className="alan">
                <span className="etiket">SGK (SUT) Bedeli</span>
                <span className="ikili">
                  {/* Ana fiyat kutusuyla ayni desen: DAHIL modunda kullanicinin
                      yazdigi BRUT metin ayri tutulur, satira MATRAH yazilir -
                      her tusa basista matrahtan geri uretmek "12," gibi ara
                      yazimlarda ondalik ayracini yiyordu. */}
                  <input className="hiza-sag" onKeyDown={tus}
                         value={kdvDahil ? sutMetni : String(r.sgkListe ?? '')}
                         title={r.sgkListeBulundu
                           ? 'Sözleşmenin SUT listesinden geldi - değiştirebilirsiniz'
                           : 'SUT listesinde bu kalem yok: bedeli siz girin'}
                         onChange={e => {
                           const v = e.target.value;
                           if (kdvDahil) setSutMetni(v);
                           setR(x => ({ ...x,
                             sgkListe: kdvDahil ? moduCevir(v, x.kdv, false) : v }));
                         }} />
                  <input className="birim" value={r.fiyatDovizi || yerelPara}
                         readOnly tabIndex={-1} />
                </span>
                {!r.sgkListeBulundu && (
                  <span className="ipucu uyari">
                    SUT listesinde fiyat bulunamadı - SGK payı için bedeli girin
                    (ödenmiyorsa 0).
                  </span>
                )}
              </label>
            )}

            {/* Iskonto ve KDV HER TURDE girilir - irsaliyede de matrah/KDV
                hesaplanir (dip toplam ondan cikar), yalniz gridde gosterilmez. */}
            {!transferMi && !vergisiz && (
            <label className="alan">
              <span className="etiket">KDV %</span>
              {/* ORAN ve GIRIS MODU yan yana, ESIT GENISLIKTE (kullanici):
                  ikisi de ayni soruya ait - "bu fiyatin KDV'si ne ve iceride
                  mi". Mod listenin ayarindan gelir, kullanici degistirebilir.
                  `.esit` ikisini ortadan boler; alanin sol/sag siniri
                  Açıklama gibi oteki alanlarla ayni hizada kalir. */}
              <span className="ikili esit">
                <select value={r.kdv} onKeyDown={tus}
                        onChange={e => degis('kdv', e.target.value)}>
                  {/* Stok kartindan gelen oran listede yoksa kaybolmasin. */}
                  {(KDV_ORANLARI as readonly number[]).includes(Number(r.kdv))
                    ? null : <option value={r.kdv}>%{r.kdv}</option>}
                  {KDV_ORANLARI.map(o => <option key={o} value={o}>%{o}</option>)}
                </select>
                {/* Mod DEGISINCE kutudaki sayi DEGISMEZ, anlami degisir:
                    "yazdigim 100 aslinda KDV dahildi" demek matrahi dusurur.
                    Bu yuzden satirdaki matrah yeniden hesaplanir. */}
                <select value={kdvDahil ? '1' : '0'}
                        disabled={basvuruMu}
                        title={basvuruMu
                          ? 'Başvuruda fiyatlar her zaman KDV dahil girilir'
                          : 'Girilen fiyat KDV dahil mi?'}
                        onChange={e => {
                          const yeniDahil = e.target.value === '1';
                          setKdvDahil(yeniDahil);
                          const alan = dovizli ? 'dovizFiyat' : 'birimFiyat';
                          const yazili = String(r[alan] ?? '');
                          // Kutudaki SAYI DEGISMEZ, anlami degisir: "yazdigim
                          //   100 aslinda KDV dahildi" demek matrahi dusurur.
                          if (yeniDahil) setBrutMetni(yazili);
                          // SUT kutusu ANA FIYATLA AYNI MODDA yazilir (483):
                          //   kutudaki SAYI degismez, anlami degisir - o
                          //   yuzden cevrim SAKLANAN matrah uzerinden yapilir.
                          const sut = String(r.sgkListe ?? '');
                          if (yeniDahil) setSutMetni(sut);
                          setR(x => ({ ...x,
                            sgkListe: moduCevir(sut, x.kdv, !yeniDahil) }));
                          // KATKI kutusu da ayni kurala uyar (591): kutudaki
                          //   SAYI degismez, anlami degisir.
                          const ktk = String(r.katkiTutar ?? '');
                          if (yeniDahil) setKatkiMetni(ktk);
                          setR(x => ({ ...x,
                            katkiTutar: moduCevir(ktk, x.kdv, !yeniDahil) }));
                          setR(x => ({ ...x, kdvDahil: yeniDahil ? 1 : 0,
                                       [alan]: moduCevir(yazili, x.kdv, !yeniDahil),
                                       birimFiyatKdvli: yeniDahil
                                         ? yazili : moduCevir(yazili, x.kdv, true) }));
                        }}>
                  <option value="0">Hariç</option>
                  <option value="1">Dahil</option>
                </select>
              </span>
            </label>
            )}

            {/* Iki kademeli iskonto: ikincisi birincinin ARDINDAN carpimsal
                uygulanir (sunucudaki BelgeHesap.SatirTutari ile ayni sira). */}
            {!transferMi && !vergisiz && (
            <label className="alan">
              {/* ISKONTO TABANI (586): Özel'de satirin tek fiyati, TTB/SUT'ta
                  hastanin katki payi. Kurumun odedigi SUT/tarife bedeli
                  indirimden ETKILENMEZ - hastaneyle hasta arasindaki anlasma
                  SGK'nin odemesini kisamaz. Hesap sunucuda. */}
              <span className="etiket">
                İskonto %{katkiVar ? ' (katkı üzerinden)' : ''}</span>
              <span className="ikili">
                <input className="hiza-sag" value={r.iskonto} onKeyDown={tus}
                       title="1. iskonto"
                       onChange={e => degis('iskonto', e.target.value)} />
                <input className="hiza-sag" value={r.iskonto2} onKeyDown={tus}
                       title="2. iskonto (birincinin ardindan uygulanir)"
                       onChange={e => degis('iskonto2', e.target.value)} />
              </span>
            </label>
            )}

            {/* EK KATKI KUTUSU KALDIRILDI (586, kullanici). "Tamamı hastadan
                tahsil edilir" isareti satirin kovalarini ELLE sabitliyordu;
                aynı soruya artık Katkı Fiyatı cevap veriyor - hastanin payi
                tutar degil FIYAT olarak giriliyor, kalanini kurum odiyor.
                Kovalar her zaman sunucudaki rota kuralindan cikar (586). */}

            {/* Duz metin "Seri / Lot" alani kaldirildi (kullanici): izlemli
                stokta lot dagitimi kendi ekraninda yapiliyor, izlemsiz stokta
                da serbest metin lot iki ayri yerde tutulan, birbirini tutmayan
                kayit uretiyordu. */}

            {/* KALEM TARIHI (140/368): siparişte satirin TERMINI, basvuruda
                ISLEM ZAMANI - "islem ne zaman yapildi". SAATLI ve BOS OLMAZ
                (kullanici): temizlenirse o anki zaman geri yazilir; ayni gun
                icindeki sira ancak saatle anlasiliyor. */}
            {siparisMi && (
              <label className="alan">
                <span className="etiket zorunlu-isaret">Tarih</span>
                <input type="datetime-local" value={r.teslimTarihi ?? ''} onKeyDown={tus}
                       onChange={e => degis('teslimTarihi',
                                            e.target.value || yerelAnMetni(new Date()))} />
              </label>
            )}

            <label className="alan">
              <span className="etiket">Açıklama</span>
              <input value={r.aciklama} onKeyDown={tus} placeholder="Satır açıklaması"
                     onChange={e => degis('aciklama', e.target.value)} />
            </label>

            {/* ISKONTO SONRASI BIRIM (602): yalniz iskonto VARSA cizilir -
                iskontosuz satirda ust kutudaki sayinin aynisi olurdu. */}
            {!transferMi && iskontoluMu && (
            <label className="alan">
              <span className="etiket">
                {sgkKilitli ? 'İskontolu hasta katkısı' : 'İskontolu birim fiyat'}
                {' '}(önizleme, KDV {kdvDahil ? 'dahil' : 'hariç'})</span>
              <input className="hiza-sag onizleme"
                     value={para.format(onizlemeBirim)} readOnly />
            </label>
            )}

            {!transferMi && (
            <label className="alan">
              <span className="etiket">
                Tutar (önizleme, KDV {kdvDahil ? 'dahil' : 'hariç'})</span>
              <input className="hiza-sag onizleme"
                     value={para.format(onizlemeTutar)} readOnly />
            </label>
            )}

            {/* Izlemli stokta girilmis lotlarin ozeti - kalem penceresine
                donuldugunde dagitimin yapildigi gorunsun. */}
            {izlemGerekli && r.izlemler.length > 0 && (
              <label className="alan">
                <span className="etiket">Lot / Seri</span>
                <input className="onizleme" readOnly
                       value={r.izlemler.map(z => `${z.lotNo || z.seriNo} (${z.miktar})`).join(', ')}
                       onClick={() => setIzlemAcik(true)}
                       title="Değiştirmek için tıklayın" />
              </label>
            )}
          </div>
        </div>

        {izlemAcik && (
          <IzlemPenceresi
            stokAdi={r.stokAdi}
            stokId={r.stokId}
            depoId={cikisDepoId}
            cikis={cikisIzlemi}
            izleme={r.izleme}
            miktar={adet}
            satirlar={r.izlemler}
            onKapat={() => setIzlemAcik(false)}
            onKaydet={izlemler => {
              setIzlemAcik(false);
              onKaydet({ ...r, birimFiyat: String(fiyat), izlemler });
            }}
          />
        )}
      </>
    </Modal>
  );
}
