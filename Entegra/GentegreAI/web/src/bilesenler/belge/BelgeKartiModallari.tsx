import { useEffect, useState } from 'react';
import type { Dispatch, SetStateAction } from 'react';
import { api } from '../../api/istemci';
import type { BelgeYaniti } from '../../api/sozlesme';
import { TarafArama } from '../TarafArama';
import { GenForm } from '../GenForm';
import { StokAramaPenceresi } from '../StokAramaPenceresi';
import { BelgeDonusumModali } from '../BelgeDonusumModali';
import { IstemModali } from '../radyoloji/IstemModali';
import { KalemPenceresi } from './KalemPenceresi';
import { TerminModali } from './TerminModali';
import { KalemRolModali } from '../prim/KalemRolModali';
import { IadeSatirPenceresi } from './IadeSatirPenceresi';
import { BelgeTahsilatModallari } from './BelgeTahsilatModallari';
import { PosSecModali } from '../banko/PosSecModali';
import { HesapSecModali } from './HesapSecModali';
import { IskontoTalepModali } from './IskontoTalepModali';
import type { BelgeTuruBilgisi } from '../../sayfalar/belgeTuru';
import type { SatirDurumu } from '../../sayfalar/belgeSatir';
import { iadeSatirlari, sonAnahtar } from '../../sayfalar/belgeKalem';
import type { useBelgeTahsilat, HizliTahsilatEki } from '../../sayfalar/belgeTahsilat';
import type { ParaSecimi } from '../mesaj';
import { BelgeKarti } from '../../sayfalar/BelgeKarti';

type Ayarla<T> = Dispatch<SetStateAction<T>>;
type Kisi = { id: number; ad: string };

/**
 * BELGE KARTININ PENCERELERI - kartin uzerine acilan butun modaller.
 *
 * `BelgeKarti.tsx` 2050 satiri gecmisti ve son ~215 satiri sirf pencere
 * cizimiydi; kartin is mantigini okumak icin once o yigini asmak gerekiyordu.
 * Cizim buraya alindi: KART "hangi pencere acik" durumunu tutar, pencerelerin
 * kendisi burada durur. Davranis degismedi - bu bir tasima refaktorudur.
 *
 * PROP SAYISI COK, cunku pencereler kartin durumunu ve setter'larini
 * kullaniyor. Tek nesnede toplandi: alan eklenince/cikinca derleyici yakalar,
 * 50 ayri parametre siralamasi tutturulmaya calisilmaz.
 *
 * NOT (dairesel bagimlilik): `acilanDonusum` icin kartin KENDISI (BelgeKarti)
 * kullaniliyor - turetilmis belge bu kartin ustunde acilir. Modul dongusu
 * ES modullerinde sorun degil: her iki taraf da cizim aninda cozulur.
 */
export interface BelgeKartiModalProps {
  /* ---- belge kimligi / turu ---- */
  kayitliId: number;
  tur: number;
  bilgi: BelgeTuruBilgisi;
  basvuruMu: boolean;
  alisMi: boolean;
  irsaliyeMi: boolean;
  siparisMi: boolean;
  stokFisiMi: boolean;
  depoBelgesi: boolean;
  yerelPara: string;
  tarih: string;
  /** Ödeyen kurum - kart tarafında çözülür; modallar artık okumuyor (586:
      "Ek Katkı" kutusu kalktı, payları sunucu bölüyor). */
  odeyenKurumId?: number | null;
  /** Belgenin fiyat listesi (495) - arama ekraninin fiyat sutunu icin. */
  fiyatListesiId?: number | null;
  /** SUT bedeli icin sozlesme (602) - arama ekraninin SUT sutunu icin. */
  sgkBaglami?: { sozlesmeId?: number | null; kurumId?: number | null;
                 sgkKullan?: number | null };
  /** Belgenin fiyat listesinin tarife tipi (586): 1 Özel · 2 TTB/HUV · 3 SUT. */
  tarifeTipi?: number;
  /** Ödeme rotası (595) - Katkı Fiyatı kutusu yalnız TSS/SGK'da sorulur. */
  rota?: number;
  /** BASVURUNUN BOLUMU (550): hizmet aramasi o poliklinigin kullanim
      puanina gore siralansin. Basvuru disi belgelerde null. */
  bolumId?: number | null;
  depo: Kisi | null;
  sonuc: BelgeYaniti | null;
  setSonuc: Ayarla<BelgeYaniti | null>;

  /* ---- cari / hasta secimi ---- */
  cari: { id: number; unvan: string } | null;
  setCari: Ayarla<{ id: number; unvan: string } | null>;
  cariArama: boolean;
  setCariArama: Ayarla<boolean>;
  hastaAramaMetni: string;
  setHastaAramaMetni: Ayarla<string>;
  hastaAramaYeni: boolean;
  setHastaAramaYeni: Ayarla<boolean>;
  /** Doğrudan açılacak hasta kartının id'si (781) - arama penceresinden
      geçmez; null = kart kapalı. */
  hastaKartId: number | null;
  setHastaKartId: Ayarla<number | null>;

  /* ---- personel secimleri ---- */
  saticiArama: boolean;
  setSaticiArama: Ayarla<boolean>;
  setSatici: Ayarla<Kisi | null>;
  personelArama: 'eden' | 'alan' | null;
  setPersonelArama: Ayarla<'eden' | 'alan' | null>;
  setTeslimEden: Ayarla<Kisi | null>;
  setTeslimAlan: Ayarla<Kisi | null>;

  /* ---- satir girisi ---- */
  satirlar: SatirDurumu[];
  setSatirlar: Ayarla<SatirDurumu[]>;
  stokArama: boolean;
  setStokArama: Ayarla<boolean>;
  aramaEklenen: { sayi: number; son: string };
  setAramaEklenen: Ayarla<{ sayi: number; son: string }>;
  /** `hizli` (786): kalem penceresi acilmadan 1 adet eklenir. */
  stokSecildi(sec: Record<string, unknown>, hizli?: boolean): void | Promise<void>;
  kalem: SatirDurumu | null;
  setKalem: Ayarla<SatirDurumu | null>;
  kalemKaydet(satir: SatirDurumu): void;
  iadeArama: boolean;
  setIadeArama: Ayarla<boolean>;

  /* ---- tahsilat ---- */
  tahsilat: ReturnType<typeof useBelgeTahsilat>;
  tahsilatTutariSor(baslik: string): Promise<number>;
  /** Banka/POS hesabi IADE icin mi secildi (tutar eksi, neden sorulur). */
  hesapSecimIade?: boolean;
  setHesapSecimIade?: Ayarla<boolean>;
  /** Hesap secimi ACILMADAN ONCE sorulmus tutar / para birimi / kur. */
  hesapSecimPara?: ParaSecimi | null;
  setHesapSecimPara?: Ayarla<ParaSecimi | null>;
  /** Sorulmus iadeyi yazar (eksi tutar + neden acikalamasi + para ustu). */
  /** Kalem penceresinin ust seridi: hasta · odeyen · fiyat listesi (basvuru). */
  kalemSeridi?: { hasta?: string; odeyen?: string; liste?: string };
  /** Acik iskonto talep penceresinin satir anahtarlari (null = kapali). */
  iskontoTalebi?: number[] | null;
  setIskontoTalebi?: Ayarla<number[] | null>;
  /** Rolun iskonto tavani (%) - pencere hangi dugmeyi acacagini bundan bilir. */
  iskontoTavani?: number;
  iadeYaz?(tur: number, hesapId: number, hesapAdi: string,
           s: ParaSecimi): Promise<void>;
  /** POS tahsilati sonrasi ayarli aksiyon (355) - otomatik fis / sor. */
  posSonrasi?(tur: number): Promise<void>;
  /**
   * HIZLI TAHSILAT - KARTIN SARMALANMIS SURUMU (kullanici: "tahsilat yaptığım
   * halde açık tahsilat 500 görünüyor").
   *
   * Kart, `tahsilat.hizliTahsilat`i sarmalayip ardina kurum tahakkukunu ve
   * SATIR TAZELEMESINI ekliyor; burada kanca DOGRUDAN cagrilinca o adimlar
   * atlaniyor ve serit/dipnot tahsilattan once ki rakamda kaliyordu.
   * Verilmezse eski davranis (dogrudan kanca).
   */
  hizliTahsilat?(tur: number, hesapId: number, tutar: number,
                 hesapAdi: string, ek?: HizliTahsilatEki): Promise<void>;
  hesapSecim: 'B' | 'P' | null;
  setHesapSecim: Ayarla<'B' | 'P' | null>;

  /* ---- donusum / termin / prim / istem ---- */
  donusum: number | null;
  setDonusum: Ayarla<number | null>;
  donusumPay: number;
  setDonusumPay: Ayarla<number>;
  acilanDonusum: number | null;
  setAcilanDonusum: Ayarla<number | null>;
  donusumleriYukle(id?: number): Promise<void>;
  terminAcik: boolean;
  setTerminAcik: Ayarla<boolean>;
  rolModali: { satirId: number; ad: string } | null;
  setRolModali: Ayarla<{ satirId: number; ad: string } | null>;
  istemModali: boolean;
  setIstemModali: Ayarla<boolean>;

  /* ---- kartin disariya acilan uclari ---- */
  onKaydedildi?(): void;
  git(delta: number): void;
}

export function BelgeKartiModallari(p: BelgeKartiModalProps) {
  const {
    kayitliId, tur, bilgi, basvuruMu, alisMi, irsaliyeMi, siparisMi, stokFisiMi,
    depoBelgesi, yerelPara, tarih, fiyatListesiId, sgkBaglami, tarifeTipi, rota, bolumId,
    depo, sonuc, setSonuc,
    cari, setCari, cariArama, setCariArama,
    hastaAramaMetni, setHastaAramaMetni, hastaAramaYeni, setHastaAramaYeni,
    hastaKartId, setHastaKartId,
    saticiArama, setSaticiArama, setSatici,
    personelArama, setPersonelArama, setTeslimEden, setTeslimAlan,
    satirlar, setSatirlar, stokArama, setStokArama, aramaEklenen, setAramaEklenen,
    stokSecildi, kalem, setKalem, kalemKaydet, iadeArama, setIadeArama,
    tahsilat, tahsilatTutariSor, posSonrasi, hizliTahsilat,
    hesapSecim, setHesapSecim, hesapSecimIade, setHesapSecimIade,
    hesapSecimPara, setHesapSecimPara, iadeYaz, kalemSeridi,
    iskontoTalebi, setIskontoTalebi, iskontoTavani = 0,
    donusum, setDonusum, donusumPay, setDonusumPay,
    acilanDonusum, setAcilanDonusum, donusumleriYukle,
    terminAcik, setTerminAcik, rolModali, setRolModali,
    istemModali, setIstemModali, onKaydedildi, git,
  } = p;

  // POS SEÇİMİ ATLANDI: açık oturum ya da çalışan POS yoksa eski "POS hesabı"
  //   seçimine düşülür (muhasebeden girilen bankosuz POS tahsilatı). Bayrak
  //   seçim kapanınca sıfırlanıyor; yoksa bir sonraki tahsilatta POS listesi
  //   hiç denenmezdi.
  const [posAtlandi, setPosAtlandi] = useState(false);
  useEffect(() => { if (!hesapSecim) setPosAtlandi(false) }, [hesapSecim]);

  return (
    <>
      {/* Kalem penceresi: grid salt gorunum oldugu icin ekleme/duzenleme burada.
          Alanlar ture gore degisir (irsaliyede seri/lot, faturada iskonto/KDV). */}
      {/* 0) Cari secimi - yeni belgenin ilk adimi. */}
      <TarafArama
        acik={cariArama}
        // BASVURUDA yalniz HASTALAR (kullanici): basvurunun tarafi hastadir,
        //   tedarikci/kurum bu pencerede cikmamali. Kaynak 'hasta' sunucuda
        //   grup = 101 ile suzuluyor; "＋ Yeni" de hasta karti acar.
        kaynaklar={basvuruMu ? ['hasta'] : ['cari']}
        yerTutucu={basvuruMu
          ? 'Hastayı isim/tel ile ara…' : 'Müşteri / tedarikçi ara…'}
        baslangicMetni={hastaAramaMetni}
        baslangicYeni={hastaAramaYeni}
        onKapat={() => {
          setCariArama(false);
          setHastaAramaMetni('');
          setHastaAramaYeni(false);
        }}
        onSec={sec => {
          setCari({ id: sec.id, unvan: sec.unvan });
          setCariArama(false);
          setHastaAramaMetni('');
          setHastaAramaYeni(false);
        }}
      />

      {/* HASTA KARTI (781) - "👤 Hasta Kartını Aç".
          Kart ONCE arama penceresinden geciyordu (`baslangicKartId`): hasta
          ZATEN secili oldugu halde bir arama ekrani aciliyor, kart kapaninca
          da kullanici basvuruya degil o arama listesine dusuyordu (kullanici:
          "basvurudayken kimlik karti ac denince hasta arama ekrani gelmesin").
          Secili hastanin karti artik DOGRUDAN aciliyor; kapaninca basvuruya
          donulur. Ad degistiyse serit eskiyi gostermesin diye kayitta unvan
          tazelenir. */}
      {hastaKartId != null && (
        <GenForm
          kaynak="hasta"
          id={hastaKartId}
          cariyeBaglaGizli
          onKapat={() => setHastaKartId(null)}
          onKaydedildi={async id => {
            try {
              const y = await api.kartOku('hasta', id);
              const k = y.kart as Record<string, unknown>;
              const unvan = String(k.unvan
                ?? `${k.ad ?? ''} ${k.soyad ?? ''}`).trim();
              if (unvan) setCari({ id, unvan });
            } catch {
              // Ad tazelenemedi: serit eski adla kalir, kart kaydi gecerlidir.
            }
          }}
        />
      )}

      {/* RADYOLOJI ISTEMI (304): basvurudan acilan IC istem - hasta ve
          protokol hazir, ucret satirlari bu basvuruya eklenir. */}
      {istemModali && cari && (
        <IstemModali
          acik
          hastaId={cari.id}
          hastaAdi={cari.unvan}
          belgeId={kayitliId || null}
          onKapat={() => setIstemModali(false)}
          // Istemler basvuruya ucret satiri ekledi: liste tazelensin,
          //   kart ise kaydedilmis halini yeniden okusun.
          onTamam={() => { onKaydedildi?.(); if (kayitliId) git(0) }}
        />
      )}

      {/* Tahsilat pencereleri (duzeltme · cek/senet · dogrudan kasa islemi)
          ayri dosyada: BelgeTahsilatModallari. */}
      <BelgeTahsilatModallari
        tahsilat={tahsilat} cari={cari} genelToplam={sonuc?.belge.genelToplam}
      />

      {/* 0b) Satis temsilcisi - ayni ekran, kaynak personel. */}
      <TarafArama
        acik={saticiArama}
        kaynaklar={['personel']}
        yerTutucu="Personel ara…"
        onKapat={() => setSaticiArama(false)}
        onSec={sec => {
          setSatici({ id: sec.id, ad: sec.unvan });
          setSaticiArama(false);
        }}
      />

      {/* 0c) Transferde teslim eden / teslim alan - ayni personel ekrani,
             hangi alanin doldurulacagi personelArama ile secilir. */}
      <TarafArama
        acik={personelArama !== null}
        kaynaklar={['personel']}
        yerTutucu="Personel ara…"
        onKapat={() => setPersonelArama(null)}
        onSec={sec => {
          const kayit = { id: sec.id, ad: sec.unvan };
          if (personelArama === 'eden') setTeslimEden(kayit); else setTeslimAlan(kayit);
          setPersonelArama(null);
        }}
      />

      {/* IADE (tipi 2): kalem stok aramadan degil, carinin ONCEKI faturalarindan
             secilir - fiyat/iskonto/KDV kaynaktan gelir ve ayni kalem iki kez
             iade edilemez (132). */}
      {iadeArama && cari && (
        <IadeSatirPenceresi
          tarafId={cari.id}
          tarafUnvan={cari.unvan}
          /* Iade IRSALIYESI irsaliyelerden, iade FATURASI faturalardan (133). */
          turler={irsaliyeMi ? (alisMi ? [10, 109] : [14, 119])
                             : (alisMi ? [11, 12] : [15, 16])}
          onKapat={() => setIadeArama(false)}
          onSec={secilenler => {
            const yeniler = iadeSatirlari(secilenler, sonAnahtar(satirlar));
            setSatirlar(s => [...s, ...yeniler]);
            setIadeArama(false);
          }}
        />
      )}

      {/* 1) Stok/hizmet arama - satir eklemenin BASLANGICI. Secim yapilinca
             kapanmaz; kalem penceresi ustune acilir, o kapaninca buraya donulur
             ve siradaki stok secilir (ardisik hizli giris). */}
      {stokArama && (
        <StokAramaPenceresi
          etkin={kalem === null}
          // Pencere ACIK KALDIGI icin (ardisik giris) eklenen kalem burada
          //   gorunur: satirin gride dustugu belli olsun.
          eklenen={{ sayi: aramaEklenen.sayi, son: aramaEklenen.son }}
          // Belgenin yonu (141): satista yalniz "Satılan", alista yalniz
          //   "Alınan" isaretli stoklar listelenir. Transfer/talep gibi
          //   yonsuz belgelerde suzme yok.
          yon={depoBelgesi || stokFisiMi ? undefined : alisMi ? 'alis' : 'satis'}
          // FIYAT SUTUNU BELGENIN LISTESINDEN (495): aramada gorunen rakam
          //   ile kalem penceresinde cikan rakam ayni olsun.
          fiyatListesiId={fiyatListesiId}
          // SUT SUTUNU (602): SGK'nin odedigi bedel de aramada gorunsun -
          //   "Fiyat" belgenin listesinden gelir, TSS'de o TTB tarifesidir.
          sgkBaglami={sgkBaglami}
          // KULLANIM SIRASI (550): basvuruda hizmetler bu poliklinigin
          //   gecmisine gore siralanir.
          bolumId={bolumId}
          // MUKERRER KONTROL (kullanici): ayni stok/hizmet belgede zaten varsa
          //   cift tik / Enter ile eklemeden once uyarilir.
          zatenVarMi={r => satirlar.some(s => r.tip === 'hizmet'
            ? s.hizmetId === Number(r.id)
            : s.stokId === Number(r.id))}
          onKapat={() => { setStokArama(false); setAramaEklenen({ sayi: 0, son: '' }) }}
          // HIZLI EKLEME (786): kalem penceresi acilmadan gride dustugu icin
          //   sayaci BURASI artirir - pencere yoluyla eklemede sayaci kalem
          //   penceresinin onKaydet'i artiriyor.
          onSec={(sec, hizli) => void (async () => {
            await stokSecildi(sec, hizli);
            if (hizli)
              setAramaEklenen(o => ({ sayi: o.sayi + 1,
                                      son: String(sec.ad ?? sec.stokAdi ?? '') }));
          })()}
        />
      )}

      {/* 2) Adet / birim fiyat - Enter satiri gride ekler ve buraya doner. */}
      {kalem !== null && (
        <KalemPenceresi
          satir={kalem}
          transferMi={bilgi.kalem === 'miktar'}
          siparisMi={siparisMi}
          // TARIFE TIPI (586): 1 Özel · 2 TTB/HUV · 3 SUT - pencere Katkı
          //   Fiyatı kutusunu ve iskontonun tabanını buna göre belirler.
          tarifeTipi={tarifeTipi}
          // ROTA (595): ÖSS ve Karma'da hasta ek katkısı YOKTUR - kutu
          //   yalnız TSS/SGK'da sorulur.
          rota={rota}
          // Basvuruda fiyat HER ZAMAN KDV dahil girilir (kullanici).
          basvuruMu={basvuruMu}
          // UST SERIT: kim icin, kim odeyecek, hangi tarife (yalniz basvuru).
          ustSerit={basvuruMu ? kalemSeridi : undefined}
          anaBirimKod={kalem?.birim ?? 0}
          anaBirimAdi={kalem?.birimAdi ?? ''}
          vergisiz={bilgi.kalem === 'sade' && stokFisiMi}
          yerelPara={yerelPara}
          girisIzlemi={bilgi.girisIzlemi}
          cikisIzlemi={bilgi.cikisIzlemi}
          cikisDepoId={depo?.id ?? null}
          belgeTarihi={tarih}
          onKapat={() => setKalem(null)}
          onKaydet={r => {
            kalemKaydet(r);
            setKalem(null);
            // Arama penceresi acik kaldigi icin (ardisik giris) sayaci artir -
            //   satirin gride dustugu arama penceresinden gorunsun.
            if (stokArama)
              setAramaEklenen(o => ({ sayi: o.sayi + 1, son: r.stokAdi || '' }));
          }}
        />
      )}

      {/* HIZLI TAHSILAT hesap secimi (banka / POS): secilince kart acilmadan
          satir eklenir, tutar acik borcun tamami gelir. */}
      {/* POS TAHSILATI: once ACIK OTURUMUN terminalleri (997). Oturum ya da
          calisan POS yoksa eski POS HESABI secimine dusulur - muhasebeden
          girilen bankosuz POS tahsilati icin. */}
      {hesapSecim === 'P' && !posAtlandi && (
        <PosSecModali
          onOturumYok={() => setPosAtlandi(true)}
          onKapat={() => { setHesapSecim(null); setHesapSecimIade?.(false);
                           setHesapSecimPara?.(null) }}
          onSec={p => void (async () => {
            const t = alisMi ? 35 : 25;
            const iadeMi = !!hesapSecimIade;
            const secilen = hesapSecimPara ?? null;
            setHesapSecim(null);
            setHesapSecimIade?.(false);
            setHesapSecimPara?.(null);
            if (iadeMi) {
              if (secilen) await iadeYaz?.(t, p.hesapId, p.terminalNo, secilen);
              return;
            }
            const tutar = secilen ? secilen.tutar : await tahsilatTutariSor('POS');
            if (!(tutar > 0)) return;
            const ek = {
              ...(secilen ? { dovizCinsi: secilen.doviz, dovizKuru: secilen.kur } : {}),
              bankoPosId: p.id,
            };
            // Hesap, TERMINALIN kendi tahsilat hesabi: ayrica sormak ayni
            //   bilgiyi iki kez istemekti.
            if (hizliTahsilat) await hizliTahsilat(t, p.hesapId, tutar, p.terminalNo, ek);
            else { await tahsilat.hizliTahsilat(t, p.hesapId, tutar, p.terminalNo, ek);
                   await posSonrasi?.(t) }
          })()}
        />
      )}

      {hesapSecim && (hesapSecim === 'B' || posAtlandi) && (
        <HesapSecModali
          tur={hesapSecim}
          baslik={hesapSecim === 'B' ? 'Banka Hesabı Seç' : 'POS Hesabı Seç'}
          // ISLEMIN PARA BIRIMINDEKI hesaplar: tutar penceresi hesap
          //   seciminden ONCE acilir, secilen birim listeyi suzer. Hesap once
          //   secilseydi kullanici dovizi degistirdiginde secim gecersiz
          //   kalir, sunucu "hesabin para birimi farkli" derdi.
          doviz={hesapSecimPara?.doviz || yerelPara}
          onKapat={() => { setHesapSecim(null); setHesapSecimIade?.(false);
                           setHesapSecimPara?.(null) }}
          onSec={h => void (async () => {
            const t = hesapSecim === 'B' ? (alisMi ? 32 : 22) : (alisMi ? 35 : 25);
            const ad = hesapSecim === 'B' ? 'Banka' : 'POS';
            const iadeMi = !!hesapSecimIade;
            const secilen = hesapSecimPara ?? null;
            setHesapSecim(null);
            setHesapSecimIade?.(false);
            setHesapSecimPara?.(null);
            // IADE: tutar EKSI, neden aciklamaya yazilir, para ustu ayri satir.
            if (iadeMi) { if (secilen) await iadeYaz?.(t, h.id, h.ad, secilen); return }
            // Tutar ONCEDEN soruldu (para birimiyle birlikte). Onceden
            //   sorulmadiysa - eski akis, or. testlerde - burada sorulur.
            const s = secilen;
            const tutar = s ? s.tutar : await tahsilatTutariSor(ad);
            if (!(tutar > 0)) return;
            // POS SONRASI OTOMATIK FIS (355), kurum tahakkuku ve satir
            //   tazelemesi SARMALAYICIDA (kartin `hizliTahsilat`i). Burada
            //   ayrica `posSonrasi` cagirmak, sarmalayici verildiginde fisi
            //   IKI KEZ kesme riski demekti.
            const ek = s ? { dovizCinsi: s.doviz, dovizKuru: s.kur } : undefined;
            if (hizliTahsilat) await hizliTahsilat(t, h.id, tutar, h.ad, ek);
            else { await tahsilat.hizliTahsilat(t, h.id, tutar, h.ad, ek);
                   await posSonrasi?.(t) }
          })()}
        />
      )}

      {/* ISKONTO TALEP PENCERESI (mockup: iskonto_talep_penceresi.html):
          kalemler + oran + gerekce + yetki tek ekranda. Limit ici "Uygula"
          satirlara dogrudan yazar, asan "Onaya Gönder" talep acar. */}
      {iskontoTalebi && (
        <IskontoTalepModali
          satirlar={satirlar.filter(x => iskontoTalebi.includes(x.anahtar))}
          tavan={iskontoTavani}
          hasta={cari?.unvan}
          onKapat={() => setIskontoTalebi?.(null)}
          onSonuc={async se => {
            if (se.onaya) {
              await api.iskontoTalepAc(kayitliId, se.oran, se.gerekce,
                se.kalemler.map(k => ({ satirId: k.satirId, oran: k.oran })));
              return;
            }
            // LIMIT ICI: onaya dusmez, oran satirlara DOGRUDAN yazilir.
            //   Satir listesi ekranda tutuldugu icin yazma da burada; kart
            //   kaydedince sunucuya gider. Oran KALEM BAZLI (664) - her satira
            //   kendi yuzdesi, toplu oran zaten kalemlere dagitilmis gelir.
            const oranlar = new Map(se.kalemler.map(k => [k.anahtar, k.oran]));
            setSatirlar(liste => liste.map(x => oranlar.has(x.anahtar)
              ? { ...x, iskonto: String(oranlar.get(x.anahtar)), iskonto2: '0' } : x));
          }}
        />
      )}

      {/* TURETILMIS BELGE (Faturalama sekmesi ✎ / cift tik): fis, tahakkuk ya
          da fatura BU KARTIN USTUNDE acilir. Kapaninca donusum listesi ve
          belge yeniden okunur - orada yapilan degisiklik (or. tutar) basvuruda
          hemen gorunsun. */}
      {acilanDonusum && (
        <BelgeKarti
          id={acilanDonusum}
          onKapat={() => {
            setAcilanDonusum(null);
            void donusumleriYukle();
            if (kayitliId) void api.belgeOku(kayitliId).then(setSonuc).catch(() => {});
          }}
        />
      )}

      {/* PRIM ROLLERI (324): kalem gridinden acilir. Rol degisince o kalemin
          primleri yeniden hesaplanir - belge yeniden kaydedilmez. */}
      {rolModali && (
        <KalemRolModali
          belgeSatirId={rolModali.satirId}
          kalemAdi={rolModali.ad}
          onKapat={() => setRolModali(null)}
        />
      )}

      {/* Donusum modali bu kartin USTUNDE acilir: hedef turu ve satir miktarlari
          orada secilir, kalan bu belgede kalir (F8). */}
      {/* Termin modali (140): satirlarin teslim tarihini toplu gunceller.
          Sunucu belgeyi yeniden yazmaz - yalniz tarih kolonu degisir. */}
      {terminAcik && kayitliId > 0 && (
        <TerminModali
          belgeId={kayitliId}
          satirlar={satirlar}
          onKapat={() => setTerminAcik(false)}
          onTamam={y => {
            setSonuc(y);
            // Gridin termin kolonu tazelensin: satirlar sunucudan geldi.
            setSatirlar(s => s.map(x => {
              const yeni = (y.satirlar ?? []).find(r => Number(r.id) === x.satirId);
              return yeni
                ? { ...x, teslimTarihi: String(yeni.teslimTarihi ?? '').slice(0, 10) }
                : x;
            }));
            onKaydedildi?.();
          }}
        />
      )}

      {donusum !== null && kayitliId > 0 && (
        <BelgeDonusumModali
          belgeId={kayitliId}
          belgeTur={tur}
          varsayilanHedef={donusum}
          varsayilanPay={donusumPay}
          onKapat={() => { setDonusum(null); setDonusumPay(0) }}
          onTamam={() => onKaydedildi?.()}
        />
      )}    </>
  );
}
