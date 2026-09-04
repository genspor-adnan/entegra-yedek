import { useEffect, useRef, useState } from 'react';
import { Modal } from '../Modal';
import { api } from '../../api/istemci';
import { para, hamSayi, yerelAnMetni } from '../bicim';
import {
  type SatirDurumu, satirTutari, adetKaydir, KDV_ORANLARI,
} from '../../sayfalar/belgeSatir';
import { DOVIZ_KODLARI } from '../../sayfalar/belgeSabitleri';
import { moduCevir } from '../../sayfalar/belgeKarti/kdvModu';
import { IzlemPenceresi } from './IzlemPenceresi';

export function KalemPenceresi({ satir, transferMi, vergisiz, yerelPara, siparisMi, paylasimli,
                         basvuruMu,
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
   * ODEME PAYLASIMI (289): odeyen kurumlu basvuruda satirin kurum/hasta payi
   * sorulur. EK KATKI (istisnai hizmet farki, ilave ucret) kutusu isaretlenince
   * tutarin TAMAMI hastaya yazilir - o satir kurum icmaline hic girmez.
   */
  paylasimli?: boolean;
  /** Basvuru (kayit kabul): fiyat HER ZAMAN KDV dahil girilir. */
  basvuruMu?: boolean;
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
  const [brutMetni, setBrutMetni] = useState(() =>
    moduCevir(String((Number(satir.kdvDahil ?? 0) === 1
      ? (satir.fiyatDovizi && satir.fiyatDovizi !== '' ? satir.dovizFiyat : satir.birimFiyat)
      : '') ?? ''), satir.kdv, true));
  const [hata, setHata] = useState<string | null>(null);
  /** Lot penceresi acik mi - miktar/fiyat girildikten SONRA acilir. */
  const [izlemAcik, setIzlemAcik] = useState(false);
  /** Kur kutusu kullanici tarafindan degistirildi mi - degistiyse ustune yazma. */
  const kurElle = useRef(false);

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
    if (e.key === 'Enter') { e.preventDefault(); kaydet() }
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

  /** Izlemli stokta lot adimi: giriste DAGITIM, cikista SECIM (db/114). */
  const izlemGerekli = (girisIzlemi || cikisIzlemi) && r.satirTur === 1 && r.izleme > 0;

  function kaydet() {
    if (!r.stokId && !r.hizmetId) { setHata('Stok ya da hizmet seçilmeli.'); return }
    if (adet <= 0) { setHata('Miktar sıfırdan büyük olmalı.'); return }
    if (dovizli && kur <= 0) { setHata('Kur sıfırdan büyük olmalı.'); return }
    // Izlemli stokta once LOT dagitimi: miktar ve fiyat girildikten sonra lot
    //   ekrani acilir, kalem ancak dagitim tamamlaninca gride eklenir.
    if (izlemGerekli) { setHata(null); setIzlemAcik(true); return }
    // Belgeye YEREL fiyat gider; doviz/kur bilgisi satirda saklanir ki kalem
    //   tekrar acildiginda ayni degerlerle gelsin.
    onKaydet({ ...r, birimFiyat: String(fiyat) });
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
              <span className="etiket">Birim Fiyat</span>
              <span className="ikili">
                {/* DAHIL modunda kutuda BRUT deger durur; satira yazilan
                    her zaman MATRAHTIR (satir matematigi, dip toplam ve
                    e-Belge matrah uzerinden yurur). */}
                <input className="hiza-sag"
                       value={kdvDahil ? brutMetni : (dovizli ? r.dovizFiyat : r.birimFiyat)}
                       onKeyDown={tus}
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

            {!transferMi && dovizli && (
              <label className="alan">
                <span className="etiket">Yerel Para</span>
                <span className="ikili">
                  <input className="hiza-sag onizleme" value={para.format(fiyat)} readOnly />
                  <input className="birim" value={yerelPara} readOnly tabIndex={-1} />
                </span>
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
              <span className="etiket">İskonto %</span>
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

            {/* EK KATKI (289): istisnai hizmet farki / ilave ucret. Isaretliyse
                tutarin tamami HASTA payidir; kurum icmaline girmez ve kuruma
                faturalanmaz. Isaret kaldirilinca satir yeniden kurumun
                karsilama oranindan paylastirilir (bos birakilir, sunucu hesaplar). */}
            {paylasimli && !transferMi && (
              <label className="alan">
                <span className="etiket">Ek Katkı</span>
                <span className="deger-serit">
                  <input type="checkbox"
                         checked={hamSayi(r.hastaTutar ?? '0') > 0
                                  && hamSayi(r.kurumTutar ?? '0') === 0}
                         onChange={e => setR(x => e.target.checked
                           ? { ...x, kurumTutar: '0', hastaTutar: String(tutar), karsilama: '0' }
                           : { ...x, kurumTutar: undefined, hastaTutar: undefined,
                               karsilama: undefined })} />
                  <span>Tamamı hastadan tahsil edilir (kuruma faturalanmaz)</span>
                </span>
              </label>
            )}

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

            {!transferMi && (
            <label className="alan">
              <span className="etiket">Tutar (önizleme)</span>
              <input className="hiza-sag onizleme" value={para.format(tutar)} readOnly />
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
