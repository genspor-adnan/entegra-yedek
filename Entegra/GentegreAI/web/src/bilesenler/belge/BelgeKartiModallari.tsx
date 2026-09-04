import type { Dispatch, SetStateAction } from 'react';
import { api } from '../../api/istemci';
import type { BelgeYaniti } from '../../api/sozlesme';
import { TarafArama } from '../TarafArama';
import { StokAramaPenceresi } from '../StokAramaPenceresi';
import { BelgeDonusumModali } from '../BelgeDonusumModali';
import { IstemModali } from '../radyoloji/IstemModali';
import { KalemPenceresi } from './KalemPenceresi';
import { TerminModali } from './TerminModali';
import { KalemRolModali } from '../prim/KalemRolModali';
import { IadeSatirPenceresi } from './IadeSatirPenceresi';
import { BelgeTahsilatModallari } from './BelgeTahsilatModallari';
import { HesapSecModali } from './HesapSecModali';
import type { BelgeTuruBilgisi } from '../../sayfalar/belgeTuru';
import type { SatirDurumu } from '../../sayfalar/belgeSatir';
import { iadeSatirlari, sonAnahtar } from '../../sayfalar/belgeKalem';
import type { useBelgeTahsilat } from '../../sayfalar/belgeTahsilat';
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
  odeyenKurumId: number | null;
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
  stokSecildi(sec: Record<string, unknown>): void | Promise<void>;
  kalem: SatirDurumu | null;
  setKalem: Ayarla<SatirDurumu | null>;
  kalemKaydet(satir: SatirDurumu): void;
  iadeArama: boolean;
  setIadeArama: Ayarla<boolean>;

  /* ---- tahsilat ---- */
  tahsilat: ReturnType<typeof useBelgeTahsilat>;
  tahsilatTutariSor(baslik: string): Promise<number>;
  /** POS tahsilati sonrasi ayarli aksiyon (355) - otomatik fis / sor. */
  posSonrasi?(tur: number): Promise<void>;
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
    depoBelgesi, yerelPara, tarih, odeyenKurumId, depo, sonuc, setSonuc,
    cari, setCari, cariArama, setCariArama,
    hastaAramaMetni, setHastaAramaMetni, hastaAramaYeni, setHastaAramaYeni,
    hastaKartId, setHastaKartId,
    saticiArama, setSaticiArama, setSatici,
    personelArama, setPersonelArama, setTeslimEden, setTeslimAlan,
    satirlar, setSatirlar, stokArama, setStokArama, aramaEklenen, setAramaEklenen,
    stokSecildi, kalem, setKalem, kalemKaydet, iadeArama, setIadeArama,
    tahsilat, tahsilatTutariSor, posSonrasi, hesapSecim, setHesapSecim,
    donusum, setDonusum, donusumPay, setDonusumPay,
    acilanDonusum, setAcilanDonusum, donusumleriYukle,
    terminAcik, setTerminAcik, rolModali, setRolModali,
    istemModali, setIstemModali, onKaydedildi, git,
  } = p;

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
        baslangicKartId={hastaKartId}
        onKapat={() => {
          setCariArama(false);
          setHastaAramaMetni('');
          setHastaAramaYeni(false);
          setHastaKartId(null);
        }}
        onSec={sec => {
          setCari({ id: sec.id, unvan: sec.unvan });
          setCariArama(false);
          setHastaAramaMetni('');
          setHastaAramaYeni(false);
          setHastaKartId(null);
        }}
      />

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
          onKapat={() => { setStokArama(false); setAramaEklenen({ sayi: 0, son: '' }) }}
          onSec={sec => void stokSecildi(sec)}
        />
      )}

      {/* 2) Adet / birim fiyat - Enter satiri gride ekler ve buraya doner. */}
      {kalem !== null && (
        <KalemPenceresi
          satir={kalem}
          transferMi={bilgi.kalem === 'miktar'}
          siparisMi={siparisMi}
          paylasimli={basvuruMu && !!odeyenKurumId}
          // Basvuruda fiyat HER ZAMAN KDV dahil girilir (kullanici).
          basvuruMu={basvuruMu}
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
      {hesapSecim && (
        <HesapSecModali
          tur={hesapSecim}
          baslik={hesapSecim === 'B' ? 'Banka Hesabı Seç' : 'POS Hesabı Seç'}
          // Yerel para birimi (kullanici): dovizli hesap hizli tahsilatta
          //   secilirse islem dovizi tutmaz.
          doviz={yerelPara}
          onKapat={() => setHesapSecim(null)}
          onSec={h => void (async () => {
            const t = hesapSecim === 'B' ? (alisMi ? 32 : 22) : (alisMi ? 35 : 25);
            setHesapSecim(null);
            const tutar = await tahsilatTutariSor(hesapSecim === 'B' ? 'Banka' : 'POS');
            if (!(tutar > 0)) return;
            await tahsilat.hizliTahsilat(t, h.id, tutar, h.ad);
            // POS SONRASI OTOMATIK FIS (355) HIZLI AKISTA DA (kullanici):
            //   kural yalniz kasa KARTI kapanirken isliyordu; POS dugmesiyle
            //   tahsil edilince fis hic kesilmiyordu - ayni ayar iki yolda
            //   farkli davraniyordu.
            await posSonrasi?.(t);
          })()}
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
