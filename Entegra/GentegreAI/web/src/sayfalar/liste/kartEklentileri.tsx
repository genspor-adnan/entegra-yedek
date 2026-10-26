import type { ComponentProps } from 'react';
import type { GenForm } from '../../bilesenler/GenForm';
import type { ListeTanimi } from '../listeTanimlari';
import { api } from '../../api/istemci';
import { c } from '../../dil/ceviri';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { LISTE_TAZELE_OLAYI } from '../../bilesenler/sekmeBaglami';
import { DokumanGalerisi } from '../../bilesenler/DokumanGalerisi';
import { LabCalismaTakvimi, type CalismaDuzeni } from '../../bilesenler/lab/LabCalismaTakvimi';
import { MuayeneBaslikNumaralari } from '../../bilesenler/MuayeneBaglamSeridi';
import { AcilYatakAraclari, AcilYatakBaslik, AcilYatakDonanimSekmesi, AcilYatakDurumSekmesi, AcilYatakGecmisSekmesi,
         AcilYatakTemizlikSekmesi } from '../../bilesenler/acil/AcilYatakSekmeleri';
import { BelgeTuruAraclari, BelgeTuruBaslik, BelgeTuruGenel, BelgeTuruHareketSekmesi, BelgeTuruHatirlatmaSekmesi,
         BelgeTuruKapsam, BelgeTuruPersonelSekmesi } from '../../bilesenler/kart/BelgeTuruKarti';
import { MetinMakroGovdesi } from '../../bilesenler/MetinMakroGovdesi';
import { IlgiliKisiler } from '../../bilesenler/IlgiliKisiler';
import { CariBelgeler, CariCrm, CariDevirSorusu, CariKimlikBandi, CariFinansal, CariHizliIslemler, CariOzetSeridi, CariYanPanel } from '../cari/CariKartParcalari';
import { SevkKartGovdesi } from '../sevk/SevkKarti';
import { KonsultasyonIstekGovdesi } from '../konsultasyon/KonsultasyonKarti';
import { GozMuayeneSeridi } from '../../bilesenler/goz/GozMuayeneSeridi';
import { GozGibEgilimi, GozTaniPlanPaneli } from '../goz/GozMuayenePanelleri';
import { gozlukYazdir } from '../goz/GozlukPanelleri';
import { OrderGecmisSekmesi, OrderGuvenlikSekmesi, OrderHastaSeridi, OrderOzetKutusu, OrderPlanSekmesi } from '../yatan/OrderPanelleri';
import { DofAraclari, dofBaslikEk } from '../kys/dof/kysDofKarti';
import { DenetimAraclari } from '../kys/denetim/kysDenetimKarti';
import { ToplantiAraclari } from '../kys/toplanti/KysToplantilar';
import { BankaBaglantiRozeti } from '../banka/BankaHareketPanelleri';
import { KasaOzetSeridi, KasaSayimSekmesi } from '../kasa/KasaPanelleri';
import { KayitSonraDolar, SablonKullanimSekmesi, SablonOnizlemeSekmesi, SablonSurumSekmesi, SmsOnizleme } from '../radyoloji/RadyolojiTanimPanelleri';
import { CihazDozSekmesi, CihazHaftaKapasite, CihazKapasite, CihazKullanimSekmesi } from '../radyoloji/CihazPanelleri';
import { HastaKartBandi } from '../hasta/HastaKartBandi';

/**
 * KART EKLENTİLERİ — ekran-özel kart parçaları KAYNAK BAŞINA tek kayıtta (refaktör 22.10.2026).
 *
 * `ListeKarti.tsx` her kartın ek sekmelerini, sekme sarmalayıcısını, araç çubuğu düğmelerini ve
 * başlık rozetini GenForm prop'larının içinde `tanim.kaynak === '...' ? ... :` zincirleriyle
 * taşıyordu (85 dal, ~1.000 satır). Bir kartın düzenini görmek için beş ayrı zincirde aramak
 * gerekiyordu. Burada kart kendi satırında: hangi prop'u neyle doldurduğu bir arada.
 *
 * YALNIZ ORTAK BAĞLAMLA çalışan dallar burada (kart id, gezinti, tazeleme, aksiyon). ListeKarti'nin
 * YEREL DURUMUNA bağlı olanlar (muayene pencereleri, göz kontrol verisi, cihaz önizlemesi, hasta
 * kartının izlem pencereleri) zincirde kaldı - onları buraya almak o durumu da bağlama taşımak demek.
 * Bir prop için eklenti tanımlıysa zincir hiç okunmaz; eklenti `undefined` dönerse prop boştur.
 */

type GenFormProps = ComponentProps<typeof GenForm>;

export interface KartEklentiBaglami {
  tanim: ListeTanimi;
  kartId: number | 'yeni' | null;
  git(yol: string, secenek?: { replace?: boolean }): void;
  /** Kart tazeleme sayacı (dışarıdan tazele). */
  tazele: number;
  /** Tazeleme + kayıt sayacı: kart kaydedilince de değişir (kayıttan etkilenen paneller). */
  tazeleKayit: number;
  kartiTazele(): void;
  listeyiTazele(): void;
  /** Kaydedilmemiş değişikliği yazar; başarısızsa false (alan hatası kartta görünür). */
  kartiKaydet(): Promise<boolean>;
  aksiyon(kod: string, satir?: Record<string, unknown> | null): void | Promise<void>;
  yetki(kod: string, islem?: 'gor' | 'ekle' | 'degistir' | 'sil'): boolean;
  /** Kart kendi ekran sekmesindeyse sekmeyi kapatır. */
  sekmeyiKapat?(): void;
  /** `rozetYukle`nin son değeri ve yazıcısı (sekme rozeti). */
  rozet: number | null;
  rozetYaz(n: number | null): void;
}

export interface KartEklentisi {
  ekSekmeler?(b: KartEklentiBaglami): GenFormProps['ekSekmeler'];
  sekmeSarmalayici?(b: KartEklentiBaglami): GenFormProps['sekmeSarmalayici'];
  seritSarmalayici?(b: KartEklentiBaglami): GenFormProps['seritSarmalayici'];
  ekAraclar?(b: KartEklentiBaglami): GenFormProps['ekAraclar'];
  baslikEk?(b: KartEklentiBaglami): GenFormProps['baslikEk'];
  /** Araç çubuğunun altında, sekmelerin üstünde (kimlik şeridinin yerinde) - ör. hasta isim bandı. */
  ustBaglam?(b: KartEklentiBaglami): GenFormProps['ustBaglam'];
  /** Gövdenin sağında hep görünen panel (yalnız kayıtlı kartta). */
  yanPanel?(b: KartEklentiBaglami): GenFormProps['yanPanel'];
  /** Kayıtlı kartta sekme rozeti sayısı - açılışta ve her kayıt / tazelemede okunur. */
  rozetYukle?(id: number): Promise<number>;
}

const kayitli = (id: KartEklentiBaglami['kartId']): id is number => typeof id === 'number';

export const KART_EKLENTILERI: Record<string, KartEklentisi> = {
  // ------------------------------------------------ hasta kartı v5 (24.10.2026) ----
  // Mockup Kayıt Kabul/hasta_karti_v5.html: etiketli kimlik şeridi yok (alanlar Genel › Kimlik),
  //   yerinde isim bandı + sayı kutuları.
  hasta: {
    ustBaglam: b => kayitli(b.kartId)
      ? d => <HastaKartBandi id={b.kartId as number} deger={d} git={b.git} /> : undefined,
  },
  // ------------------------------------------- müşteri kartı Ver3 (1150) ----
  // Mockup musteri_karti_ver3.html: kimlik şeridinin altında özet şeridi, sağda dikkat /
  //   yaşlandırma / kişiler / son olaylar, Finansal · Belgeler · CRM sekmeleri, araç
  //   çubuğunda bu cariyle dolu Aksiyon ▾ menüsü. Ekstre sekme DEĞİL
  //   (kullanıcı 23.10.2026): üstteki "Σ Ekstre" Kasa › Cari Ekstre'yi açar.
  //   Tedarikçi kartı da aynı kaynak (`cari`) - özet onda da geçerli.
  cari: {
    seritSarmalayici: b => kayitli(b.kartId)
      // FİRMA BİLGİ BANDI (CariKimlikBandi): bakiye rozetleri yok - özet şeridinde var. Yeni kartta band yok.
      ? (serit, d) => <><CariKimlikBandi id={b.kartId as number} tazele={b.tazeleKayit} serit={serit} /><CariDevirSorusu id={b.kartId as number} onDegisti={b.kartiTazele} />
                         <CariOzetSeridi id={b.kartId as number} tazele={b.tazeleKayit}
                                         ad={String(d.unvan ?? '')} git={b.git}
                                         tedarikci={Number(d.tedarikci ?? 0) === 1 && Number(d.musteri ?? 0) !== 1} /></>
      : undefined,
    yanPanel: b => kayitli(b.kartId)
      ? <CariYanPanel id={b.kartId} tazele={b.tazeleKayit} git={b.git} gitKart={b.git} /> : undefined,
    ekSekmeler: b => kayitli(b.kartId) ? [
      // İLGİLİ KİŞİLER SEKME (kullanıcı 25.10.2026: "ilgili kişiler bölümünü sekme olarak adres / fatura
      //   sekmesinden sonraya al"). Adres sekmesi gizli ekranda (Aday) Genel'de adresin yanında kalır.
      ...(b.tanim.gizliKartSekmeleri?.includes('Adres / Fatura Bilgisi') ? [] : [
        { anahtar: 'ozel:cari-kisi', baslik: 'İlgili Kişiler',
          ciz: () => <IlgiliKisiler tarafId={b.kartId as number} saltOkunur={!b.yetki('cari', 'degistir')} /> }]),
      { anahtar: 'ozel:cari-finans', baslik: 'Finansal', ciz: () => <CariFinansal id={b.kartId as number} tazele={b.tazeleKayit} onDegisti={b.kartiTazele} /> },
      { anahtar: 'ozel:cari-belge', baslik: 'Belgeler', ciz: () => <CariBelgeler id={b.kartId as number} /> },
      { anahtar: 'ozel:cari-crm', baslik: 'CRM', ciz: () => <CariCrm id={b.kartId as number} gitKart={b.git} /> },
    ] : undefined,
    ekAraclar: b => kayitli(b.kartId)
      ? d => <CariHizliIslemler id={b.kartId as number} ad={String(d.unvan ?? '')} git={b.git} />
      : undefined,
  },

  // ----------------------------------------- Banka Hesabı Kartı (1157) ----
  // Mockup banka_hareketleri.html: Genel · Banka Bilgileri · Banka Bağlantısı. "Hareketler" sekmesi
  //   kaldırıldı (kullanıcı 23.10.2026: "banka kartında hareketler sekmesini kaldır, hatırlat
  //   butonu sağına Ekstre butonu ekle") - hareketler tek Ekstre ekranında (KartAracGruplari › hesap).
  hesap: {
    // KASA KARTI V3 (1161, mockup kasa_karti_ver3.html): özet şeridi + "Sayım / Gün Sonu" sekmesi.
    seritSarmalayici: b => kayitli(b.kartId) && b.tanim.kartYolu === '/kasa-hesap'
      ? serit => <>{serit}<KasaOzetSeridi id={b.kartId as number} tazele={b.tazeleKayit} git={b.git} /></> : undefined,
    ekSekmeler: b => kayitli(b.kartId) && b.tanim.kartYolu === '/kasa-hesap' ? [
      { anahtar: 'ozel:kasa-sayim', baslik: 'Sayım / Gün Sonu',
        ciz: () => <KasaSayimSekmesi id={b.kartId as number} tazele={b.tazeleKayit} git={b.git} /> },
    ] : undefined,
    // Banka Bağlantısı sekmesinin altında onay notu (mockup).
    sekmeSarmalayici: b => b.tanim.kartYolu !== '/banka-hesap' ? undefined : (baslik, icerik) => baslik !== 'Banka Bağlantısı' ? icerik : (
      <>
        {icerik}
        <div className="not" style={{ margin: '0 12px 12px' }}>
          {c('Onay no, müşterinin bankada "Hesap Hareketleri API" hizmetine verdiği onaydan gelir (internet şubesi / şube). '
             + 'Onay süresi dolunca ekran uyarır, çekme durur. API anahtarı Entegrasyonlar\'daki banka satırındadır. '
             + 'Geliştirme / demo kurulumunda entegrasyonun test adresi API\'nin örnek Garanti sunucusu olabilir '
             + '(…/api/banka-ornek/garanti): bankaya gitmeden aynı biçimde örnek hareket döner, kaynak "benzetim" yazar.')}
        </div>
      </>
    ),
    // Başlıkta bağlantı hapı (mockup "API · 30 dk").
    baslikEk: b => b.tanim.kartYolu === '/banka-hesap' ? d => <BankaBaglantiRozeti deger={d} /> : undefined,
  },

  // ---------------------------------------------- İK belge türü (1135-1138) ----
  // Mockup personel_belge_turu.html (2): Genel üç kutu + özet, Kime zorunlu önizlemesi,
  //   Personel durumu (rozet = eksik + süresi dolan) · Hatırlatma · Hareketler.
  'personel-belge-turu': {
    rozetYukle: async id => { const o = await api.belgeTuruKartOzet(id); return o.eksik + o.doldu },
    ekSekmeler: b => kayitli(b.kartId) ? [
      { anahtar: 'ozel:bt-personel', baslik: 'Personel durumu',
        rozet: b.rozet ? { metin: String(b.rozet), hata: true } : undefined,
        ciz: e => <BelgeTuruPersonelSekmesi id={b.kartId as number} hatirlatGun={Number(e.deger.hatirlatGun ?? 60)}
                                            tazele={b.tazeleKayit} git={b.git}
                                            saltOkunur={e.saltOkunur} onSayilar={b.rozetYaz} /> },
      { anahtar: 'ozel:bt-hatirlatma', baslik: 'Hatırlatma',
        ciz: e => <BelgeTuruHatirlatmaSekmesi git={b.git}
                    gecerlilikAy={e.deger.gecerlilikAy == null || e.deger.gecerlilikAy === '' ? null : Number(e.deger.gecerlilikAy)}
                    hatirlatGun={Number(e.deger.hatirlatGun ?? 60)} /> },
      { anahtar: 'ozel:bt-gecmis', baslik: 'Hareketler',
        ciz: () => <BelgeTuruHareketSekmesi id={b.kartId as number} tazele={b.tazeleKayit} /> },
    ] : undefined,
    sekmeSarmalayici: b => b.kartId === null ? undefined
      : (baslik, icerik, deger, _izgara, parcalar, detay) => detay?.meta.ad === 'kapsam'
          ? <BelgeTuruKapsam id={kayitli(b.kartId) ? b.kartId : null} grid={icerik} satirlar={detay.satirlar} />
          : baslik === 'Genel'
          ? <BelgeTuruGenel id={kayitli(b.kartId) ? b.kartId : null} deger={deger} parcalar={parcalar} tazele={b.tazeleKayit} />
          : icerik,
    baslikEk: b => kayitli(b.kartId) ? () => <BelgeTuruBaslik id={b.kartId as number} tazele={b.tazeleKayit} /> : undefined,
    ekAraclar: b => kayitli(b.kartId)
      ? d => <BelgeTuruAraclari id={b.kartId as number} ad={String(d.ad ?? '')} git={b.git} saltOkunur={false} />
      : undefined,
  },

  // ------------------------------------------- entegrasyon hesabı (1140) ----
  // Mockup entegrasyon_hesaplari.html kart altı kutuları: test / canlı ayrımı ve hesap çözüm zinciri
  //   kartın kendisinde yazılı - kullanıcı belgeye çıkmadan görsün.
  'entegrasyon-hesap': {
    sekmeSarmalayici: () => (baslik, icerik) => baslik !== 'Genel' ? icerik : (
      <>
        {icerik}
        <div className="uyari-kutusu" style={{ margin: '10px 12px' }}>
          <b>{c('Test ve canlı AYRI SATIRDIR.')}</b> Kurum canlıya geçerken test hesabını silmez — test
          satırının “Aktif” kutusunu kaldırır, canlı satırınkini işaretler. Aynı entegrasyon + şube +
          ortam üçlüsünden ikinci satır açılamaz.
        </div>
        <div className="not" style={{ margin: '0 12px 12px' }}>
          <b>{c('Hesap çözümü:')}</b> şubenin kendi satırı → baz alınan şubenin satırı → kurum geneli
          satır (şube boş) → varsayılan şube (yalnız ÜTS). e-Fatura'da varsayılan şubeye düşülmez:
          “merkezin kimliğiyle gönder” kararı şube kartında verilir. Şifre listede gösterilmez —
          yalnız “dolu mu” işareti.
        </div>
      </>
    ),
  },

  // ---------------------------------------------------- acil yatak (1118) ----
  // Mockup acil_yatak_karti: Durum · Donanım · Kullanım Geçmişi · Temizlik & Bakım; araç çubuğu
  //   taşı · temizliğe al · kullanım dışı / kullanıma aç · etiket. Durum düğmeleri kartı tazeler.
  acilYatak: {
    ekSekmeler: b => kayitli(b.kartId) ? [
      { anahtar: 'ozel:ay-durum', baslik: 'Durum',
        ciz: e => <AcilYatakDurumSekmesi yatakId={b.kartId as number} durum={Number(e.deger.durum ?? 0)} tazele={b.tazele}
                                         onDegisti={b.kartiTazele} git={b.git} /> },
      // Donanım: katalog grubu yerine mockup karoları (aynı kart alanları).
      { anahtar: 'ozel:ay-donanim', baslik: 'Donanım', ciz: e => <AcilYatakDonanimSekmesi b={e} /> },
      { anahtar: 'ozel:ay-gecmis', baslik: 'Kullanım Geçmişi',
        ciz: () => <AcilYatakGecmisSekmesi yatakId={b.kartId as number} tazele={b.tazele} git={b.git} /> },
      { anahtar: 'ozel:ay-temizlik', baslik: 'Temizlik & Bakım',
        ciz: () => <AcilYatakTemizlikSekmesi yatakId={b.kartId as number} tazele={b.tazele} /> },
    ] : undefined,
    baslikEk: b => kayitli(b.kartId) ? d => <AcilYatakBaslik yatakId={b.kartId as number} deger={d} tazele={b.tazele} /> : undefined,
    ekAraclar: b => kayitli(b.kartId)
      ? d => <AcilYatakAraclari yatakId={b.kartId as number} deger={d} tazele={b.tazele} onDegisti={b.kartiTazele} />
      : undefined,
  },

  // --------------------------------------------------------- order (968) ----
  // Doz planı · Güvenlik kontrolleri · Geçmiş; Order sekmesinin sağında özet; kimlik şeridinin
  //   üstünde hasta şeridi; araç çubuğu hekim onayı · durdur · doz değiştir · tekrarla.
  'yatis-order': {
    ekSekmeler: b => kayitli(b.kartId) ? [
      { anahtar: 'ozel:od-plan', baslik: 'Doz planı', ciz: () => <OrderPlanSekmesi id={b.kartId as number} yenile={b.tazele} /> },
      { anahtar: 'ozel:od-guv', baslik: 'Güvenlik kontrolleri', ciz: () => <OrderGuvenlikSekmesi id={b.kartId as number} yenile={b.tazele} /> },
      { anahtar: 'ozel:od-gecmis', baslik: 'Geçmiş', ciz: () => <OrderGecmisSekmesi id={b.kartId as number} yenile={b.tazele} /> },
    ] : undefined,
    sekmeSarmalayici: b => (baslik, icerik) => baslik === 'Order' && kayitli(b.kartId)
      ? <div className="od-iki"><div>{icerik}</div><OrderOzetKutusu id={b.kartId} yenile={b.tazele} /></div>
      : icerik,
    seritSarmalayici: b => kayitli(b.kartId)
      ? serit => <><OrderHastaSeridi id={b.kartId as number} yenile={b.tazele} />{serit}</>
      : undefined,
    ekAraclar: b => {
      if (!kayitli(b.kartId)) return undefined;
      const id = b.kartId;
      return d => {
        const dd = d as Record<string, unknown>;
        const aktif = Number(dd.durum) === 1;
        const imzasiz = (dd.sozelOrder === true || Number(dd.sozelOrder) === 1) && !dd.onayTarihi;
        const kopyala = (durdur: boolean) => void guvenli(async () => {
          if (durdur && !await onay('Bu order durdurulup aynı bilgilerle yeni order açılsın mı? Yeni order kartında dozu değiştirip kaydedin.')) return;
          const y = await api.orderKopyala(id, durdur);
          b.git(`/yatis-order/${y.id}`);
        });
        return (
          <>
            {imzasiz && <button type="button" className="d" onClick={() => void guvenli(async () => {
              await api.orderImzala(id); b.kartiTazele(); void mesaj('Sözel order onaylandı.');
            })}>✔ Hekim onayı</button>}
            {aktif && <button type="button" className="d" onClick={() => void guvenli(async () => {
              if (!await onay('Order durdurulsun mu? Gelecekteki bekleyen dozlar düşer, uygulanmış dozlar kalır.')) return;
              await api.orderDurdur(id); b.kartiTazele();
            })}>⏸ Durdur</button>}
            {aktif && <button type="button" className="d" onClick={() => kopyala(true)}>✎ Doz değiştir</button>}
            <button type="button" className="d" onClick={() => kopyala(false)}>⟳ Tekrarla</button>
          </>
        );
      };
    },
  },

  // ------------------------------------------------ radyoloji (965-967) ----
  // CİHAZ: Doz · Kullanım · Belgeler; Randevu ayarları altında kapasite, sağında bu hafta ızgarası.
  //   Araç çubuğu yerel pencereye (kapat / bakıma al) bağlı - ListeKarti'de kaldı.
  'radyoloji-cihaz': {
    ekSekmeler: b => kayitli(b.kartId) ? [
      { anahtar: 'ozel:rc-doz', baslik: 'Doz', ciz: () => <CihazDozSekmesi id={b.kartId as number} /> },
      { anahtar: 'ozel:rc-kul', baslik: 'Kullanım', ciz: () => <CihazKullanimSekmesi id={b.kartId as number} /> },
      { anahtar: 'ozel:rc-belge', baslik: 'Belgeler',
        ciz: () => <DokumanGalerisi kartAdi="radyoloji-cihaz" kaynakId={b.kartId as number} saltOkunur={false} /> },
    ] : undefined,
    sekmeSarmalayici: b => (baslik, icerik, deger) => baslik === 'Randevu ayarları'
      // SAĞDA "BU HAFTA KAPASİTE" (mockup, kullanıcı): gün x saat boş slot ızgarası.
      ? <div className="rc-randevu"><div>{icerik}<CihazKapasite deger={deger as Record<string, unknown>} /></div>
          {kayitli(b.kartId) && <CihazHaftaKapasite id={b.kartId} yenile={b.tazele} />}</div>
      : icerik,
  },
  // ŞABLON: Önizleme · Sürümler · Kullanım - YENİ KARTTA DA (kullanıcı: "mockup'ta 7 sekme var");
  //   Önizleme girilen içerikle çalışır, Sürümler / Kullanım kayıttan sonra dolar.
  'radyoloji-sablon': {
    ekSekmeler: b => b.kartId === null ? undefined : [
      { anahtar: 'ozel:rt-oniz', baslik: 'Önizleme', yenideDe: true, ciz: e => <SablonOnizlemeSekmesi baglam={e} /> },
      { anahtar: 'ozel:rt-surum', baslik: 'Sürümler', yenideDe: true,
        ciz: () => kayitli(b.kartId) ? <SablonSurumSekmesi id={b.kartId} tazele={b.kartiTazele} /> : <KayitSonraDolar /> },
      { anahtar: 'ozel:rt-kul', baslik: 'Kullanım', yenideDe: true,
        ciz: () => kayitli(b.kartId) ? <SablonKullanimSekmesi id={b.kartId} /> : <KayitSonraDolar /> },
    ],
  },
  // PROTOKOL: hasta hazırlığı metni randevu SMS'inde nasıl görünür.
  'radyoloji-protokol': {
    sekmeSarmalayici: () => (baslik, icerik, deger) => baslik === 'Hasta hazırlığı'
      ? <>{icerik}<SmsOnizleme deger={deger as Record<string, unknown>} /></> : icerik,
  },

  // ------------------------------------------------------------- lab ----
  'lab-tetkik': {
    sekmeSarmalayici: () => (baslik, icerik, deger) => baslik.includes('Çalışma Zamanları')
      ? <>{icerik}<LabCalismaTakvimi deger={deger as CalismaDuzeni} /></> : icerik,
  },
  // LAB İSTEM NUMARASI BAŞLIKTA (kullanıcı: "kaydedince otomatik olsun, düzenle diye girince başlıkta
  //   görsün"): numara tetikle üretiliyor (641), yazılamayan bir numaraya alan ızgarasında kutu tutmak
  //   yerine başlıkta rozet - yeni kayıtta hiç çıkmaz.
  'lab-istem': {
    baslikEk: () => d => {
      const no = String(d.istemNo ?? '');
      return no ? <span className="rozet mavi">{no}</span> : null;
    },
  },

  // -------------------------------------------------- muayene / göz ----
  // Muayenenin ek sekmeleri, sarmalayıcısı ve araçları yerel duruma bağlı (ListeKarti); yalnız başlık
  //   numaraları buradadır. Durum rozeti Tamamla'nın sağında (kullanıcı 15.10.2026).
  muayene: {
    baslikEk: () => d => <MuayeneBaslikNumaralari muayeneId={Number(d.id ?? 0)} />,
  },
  // GÖZ MUAYENESİ (970): Tonometri sağında GİB eğilimi, Tanı & Plan sağında tanılar + işler; v4 hasta
  //   bandı üstte, muayene türü / dilatasyon bandı altında. Ek sekmeler ve araçlar ListeKarti'de.
  'goz-muayene': {
    sekmeSarmalayici: b => !kayitli(b.kartId) ? undefined
      : (baslik, icerik) => baslik === 'Tonometri & Pakimetri'
          ? <div className="gz-iki"><div>{icerik}</div><GozGibEgilimi id={b.kartId as number} yenile={b.tazele} /></div>
          : baslik === 'Tanı & Plan'
          ? <div className="gz-iki"><div>{icerik}</div><GozTaniPlanPaneli id={b.kartId as number} yenile={b.tazele} /></div>
          : icerik,
    seritSarmalayici: b => kayitli(b.kartId)
      ? serit => <><GozMuayeneSeridi gozMuayeneId={b.kartId as number} yenile={b.tazele} />{serit}</>
      : undefined,
  },
  // GÖZ GÖRÜNTÜLEME (974 mockup) araç çubuğu: çekildi (ödenmişse) · değerlendir ve imzala · yeniden
  //   çekim · yazdır. Ek sekmeler önizleme kancasına bağlı - ListeKarti'de.
  'goz-goruntuleme': {
    ekAraclar: b => {
      if (!kayitli(b.kartId)) return undefined;
      const id = b.kartId;
      return d => {
        const durum = Number(d.durum ?? 1), serbest = Number(d.serbest ?? 1);
        const islem = (f: () => Promise<unknown>) => void guvenli(async () => { await f(); b.kartiTazele(); b.listeyiTazele() });
        return (
          <>
            {durum === 1 && serbest === 0 && <span className="rozet hata" title={c('Bankoda ücretlendirilip başvuru kaydedilmeden çekim yapılamaz')}>{c('Ödeme bekliyor')}</span>}
            {durum === 1 && serbest === 1 && <button type="button" className="d" onClick={() => islem(async () => {
              if (!(await b.kartiKaydet())) return;
              await api.gozGoruntulemeCekildi(id);
            })}>📷 {c('Çekildi')}</button>}
            {durum === 2 && <button type="button" className="d bir" onClick={() => islem(async () => {
              if (!(await b.kartiKaydet())) return;
              if (!await onay(c('Değerlendirme imzalansın mı? İmzadan sonra sonuç değiştirilemez; muayene kartına düşer.'))) return;
              await api.gozGoruntulemeDegerlendir(id);
            })}>✍ {c('Değerlendir ve imzala')}</button>}
            {durum === 2 && <button type="button" className="d" onClick={() => void guvenli(async () => {
              if (!await onay(c('Yeniden çekim istensin mi? Bu çekim iptal edilir, yeni kayıt ücretsiz sıraya düşer.'))) return;
              const y = await api.gozGoruntulemeYeniden(id);
              b.git(`/goz-goruntuleme/${y.id}`, { replace: true });
            })}>↻ {c('Yeniden çekim iste')}</button>}
            <button type="button" className="d" onClick={() => window.print()}>🖨 {c('Rapor yazdır')}</button>
          </>
        );
      };
    },
  },
  // GÖZLÜK REÇETESİ (972) araç çubuğu: imzala · yazdır (A5) · optiğe ver · teslim. Reçete sekmesi ve
  //   hasta bandı reçete kaynağı kancasına bağlı - ListeKarti'de.
  'goz-gozluk-recete': {
    ekAraclar: b => {
      if (!kayitli(b.kartId)) return undefined;
      const id = b.kartId;
      return d => {
        const durum = Number(d.durum ?? 1);
        const islem = (f: () => Promise<unknown>) => void guvenli(async () => { await f(); b.kartiTazele(); b.listeyiTazele() });
        return (
          <>
            {durum === 1 && <button type="button" className="d" onClick={() => islem(async () => {
              if (!(await b.kartiKaydet())) return;
              if (!await onay(c('Reçete imzalansın mı? İmzadan sonra değerler değiştirilemez.'))) return;
              await api.gozlukImzala(id);
            })}>✍ {c('İmzala')}</button>}
            <button type="button" className="d" onClick={() => gozlukYazdir()}>🖨 {c('Yazdır (A5)')}</button>
            {durum === 2 && <button type="button" className="d" onClick={() => islem(() => api.gozlukDurum(id, 3))}>🏪 {c('Optike gönder')}</button>}
            {(durum === 2 || durum === 3) && <button type="button" className="d" onClick={() => islem(() => api.gozlukDurum(id, 4))}>✔ {c('Teslim edildi')}</button>}
          </>
        );
      };
    },
  },

  // ------------------------------------------------ sevk / konsültasyon ----
  // METİN MAKROSU KARTI (kullanıcı 14.10.2026): mockup düzeni - kaydet / yetki genel kartta.
  'metin-makro': {
    sekmeSarmalayici: b => b.kartId === null ? undefined
      : (_baslik, _icerik, deger, _izgara, parcalar) => (
          <MetinMakroGovdesi id={b.kartId as number | 'yeni'} deger={deger} alanDegistir={(ad, v) => parcalar?.alanDegistir(ad, v)} />),
  },
  // SEVK KARTI (1110, mockup sevk_karti_v2 - sade): gönderince sekme kapanır, liste tazelenir.
  sevk: {
    sekmeSarmalayici: b => b.kartId === null ? undefined
      : (_baslik, _icerik, deger, _izgara, parcalar) => (
          <SevkKartGovdesi kartId={b.kartId as number | 'yeni'} deger={deger} parcalar={parcalar}
            onGonderildi={() => {
              window.dispatchEvent(new CustomEvent(LISTE_TAZELE_OLAYI, { detail: 'sevk' }));
              b.sekmeyiKapat?.();
            }} />),
  },
  // KONSÜLTASYON İSTEK KARTI (1107, mockup konsultasyon_karti.html): İsteyen | Karşılayan.
  konsultasyon: {
    sekmeSarmalayici: b => b.kartId === null ? undefined
      : (_baslik, _icerik, deger, _izgara, parcalar) => (
          <KonsultasyonIstekGovdesi kartId={b.kartId as number | 'yeni'} deger={deger} parcalar={parcalar} />),
  },

  // ------------------------------------------------------------ randevu ----
  // KARTTA BAŞVURUYA DÖNÜŞTÜR (kullanıcı 17.10.2026: "takvimdeyken işaretleyip başvuruya dönüştür
  //   diyemiyorum, hemen kart açılıyor - kartın içine de buton ekle"): listedeki aksiyonun AYNISI -
  //   cihazlı randevuda kabul ekranı, diğerinde başvuru; dönüşmüşse mevcut başvuru açılır.
  randevu: {
    ekAraclar: b => {
      if (!kayitli(b.kartId)) return undefined;
      const id = b.kartId;
      return d => {
        const durum = Number(d.durum ?? 1);
        if (durum === 4 || durum === 5) return null;
        const belgeli = !!Number(d.belgeId);
        // YETKİ (pilot denetimi 17.10.2026): dönüştürmek Başvuru Kartı EKLE, açmak GÖR ister.
        if (!b.yetki('belge', belgeli ? 'gor' : 'ekle')) return null;
        return (
          <button type="button" className="d sari"
                  onClick={() => void (async () => {
                    // Satır listedekiyle AYNI biçimde okunur (hasta adı, bölüm, hizmet) - aksiyon tek kod.
                    const y = await api.liste('randevu', { sayfa: 1, boyut: 1, filtre: { alan: 'id', op: 'esit', deger: id } });
                    if (y.satirlar[0]) await b.aksiyon('randevu.basvuru', y.satirlar[0]);
                    else mesaj(c('Randevu okunamadı (başka şubede olabilir).'));
                    b.kartiTazele();
                  })()}>{belgeli ? c('📄 Başvuruyu Aç') : c('➜ Başvuruya Dönüştür')}</button>
        );
      };
    },
  },

  // ------------------------------------------------- kurumsal kalite ----
  // DÖF (1050, mockup Kalite2/dof_karti.html): sorun / kök neden -> faaliyetler -> doğrulama
  //   (varsayılan sıra tabloyu en alta koyardı); araç çubuğu kaynak kaydına git · DÖF formu (A4).
  'kys-dof': {
    sekmeSarmalayici: () => (_baslik, icerik, _d, _izgara, p) => p
      ? <><div className="kys-dof-yanyana">{p.altGrupCiz('Sorun')}</div>{p.tablolar.faaliyetler}<div className="kys-dof-yanyana">{p.altGrupCiz('Doğrulama')}</div></>
      : icerik,
    baslikEk: () => dofBaslikEk,
    ekAraclar: () => d => <DofAraclari deger={d} />,
  },
  'kys-denetim': {
    baslikEk: () => dofBaslikEk,
    ekAraclar: () => d => <DenetimAraclari deger={d} />,
  },
  'kys-toplanti': {
    ekAraclar: () => d => <ToplantiAraclari deger={d} />,
  },
};
