import type { ReactNode } from 'react';
import type { KartDetayMeta } from '../../api/sozlesme';
import type { DetayDurumu } from '../detayDurumu';
import { GenGrid } from '../GenGrid';
import { HizmetListeFiyatlari } from '../HizmetListeFiyatlari';
import { PaketSekmesi } from '../PaketSekmesi';
import { HekimGonderimOzeti } from '../radyoloji/HekimGonderimOzeti';
import { KontrolListesi } from '../radyoloji/KontrolListesi';
import { RolYetkiMatrisi } from '../RolYetkiMatrisi';
import { TekKayit } from '../TekKayit';

/**
 * KARTA ÖZEL SEKME GÖVDELERİ (refaktör 23.10.2026, GenForm'dan ayrıldı).
 *
 * GenForm'un sekme gövdesi bazı ekranlarda generic detay gridi / "yakında" yer tutucusu yerine
 * kendi bileşenini çiziyordu - her biri bir `kaynak === '...' && ad === '...'` dalı, generic
 * dalda da aynı koşulun DEĞİLİ. Tablolar burada: kayıt varsa generic çizilmez.
 */

/** Detay sekmesi gövdesinin ihtiyacı. */
export interface OzelDetayBaglami {
  detay: KartDetayMeta;
  durum: DetayDurumu;
  salt: boolean;
  yeniMi: boolean;
  id: number | 'yeni';
  onDegis(yeni: DetayDurumu): void;
}

/** Yer tutucu / özel sekme gövdesinin ihtiyacı. */
export interface OzelSekmeBaglami {
  salt: boolean;
  yeniMi: boolean;
  id: number | 'yeni';
}

const yeniKartNotu = (metin: string) => <div className="not" style={{ padding: 20 }}>{metin}</div>;

/** kaynak -> detay adı -> gövde. */
const OZEL_DETAYLAR: Record<string, Record<string, (b: OzelDetayBaglami) => ReactNode>> = {
  // DIS HEKIM "Hekim Bilgisi" (305): 1:1 uzanti - satir ekle/sil'li grid
  //   degil TEK KAYIT formu (kullanici: "mockup gibi label ve edit olsun").
  //   Ikinci satir DB'de zaten yazilamaz; grid yanlis bir vaat.
  'dis-hekim': {
    hekim: b => (
      <TekKayit meta={b.detay} durum={b.durum} saltOkunur={b.salt || b.detay.saltOkunur}
                onDegis={b.onDegis} baslik="Hekim Bilgisi" />
    ),
  },
  // Müşteri kartı "Satış & Risk" (musteri_karti_ver3.html): taraf_musteri 1:1 uzantı -
  //   grid değil tek kayıt formu. Risk limiti listedeki "Risk Limiti %" ve "Limit aşan"ı,
  //   vade günü vadesi geçen hesabını besler.
  cari: {
    satisKosul: b => (
      <TekKayit meta={b.detay} durum={b.durum} saltOkunur={b.salt || b.detay.saltOkunur}
                onDegis={b.onDegis} baslik="Satış & Risk"
                not={<>Risk limiti 0 ise limitsiz. Vade günü, vade tarihi girilmemiş faturalarda
                     vadeyi belirler (vadesi geçen tutarı ve yaşlandırmayı etkiler).</>} />
    ),
  },
  stok: {
    // Stok > ÜTS: stok_uts 1:1 uzanti (119) - grid degil TEK kayit formu.
    //   Bir stokun bir ÜTS kaydi olur; "satir ekle" yanlis bir vaat olurdu.
    uts: b => (
      <TekKayit meta={b.detay} durum={b.durum} saltOkunur={b.salt || b.detay.saltOkunur}
                onDegis={b.onDegis} baslik="ÜTS / Medikal Bilgileri"
                not={<>ÜTS REF ve GTIN, ÜTS bildiriminde ürün eşleştirmesinde kullanılır.
                     Menşei ülke listesi ülke tablosundan gelir.</>} />
    ),
    // Stok > Paket: icerik satiri stok arama penceresinden gelir (grid salt
    //   gorunum) - baslik/cerceve yok, sekmenin adi zaten "Paket".
    paket: b => (
      <PaketSekmesi meta={b.detay} durum={b.durum} saltOkunur={b.salt || b.detay.saltOkunur} onDegis={b.onDegis} />
    ),
  },
  // Hizmet > Fiyatlar: kalemin gectigi fiyat listesi satirlari
  //   (kullanici: "bu hizmete ait tum fiyatlar gelsin"; kartin kendi
  //   hizmet_fiyat gridi kaldirildi).
  hizmet: {
    fiyatlar: b => b.yeniMi
      ? <div className="not" style={{ marginTop: 12 }}>
          Fiyatlar kart kaydedildikten sonra fiyat listelerinden gelir.
        </div>
      : <HizmetListeFiyatlari hizmetId={b.id as number} />,
  },
};

/** kaynak -> yer tutucu sekme başlığı -> gövde ("yakında" yerine). */
const OZEL_YER_TUTUCULAR: Record<string, Record<string, (b: OzelSekmeBaglami) => ReactNode>> = {
  // Cekim oncesi kontrol listesi (310) - yer tutucu sekme.
  'radyoloji-istem': {
    'Kontrol Listesi': b => b.yeniMi
      ? yeniKartNotu('İstem kaydedildikten sonra kontrol listesi doldurulur.')
      : <KontrolListesi istemId={b.id as number} saltOkunur={b.salt} />,
  },
  // DIS HEKIM "Gönderim Geçmişi" (305): kart DETAYI degil - baska bir
  //   ekranin kayitlari (radyoloji istemleri). Duzenlenebilir satir gridi
  //   yerine liste ekranlarindaki GenGrid, SALT OKUNUR ve hekim filtreli.
  'dis-hekim': {
    'Gönderim Geçmişi': b => b.yeniMi
      ? yeniKartNotu('Hekim kaydedildikten sonra gönderdiği tetkikler burada listelenir.')
      : <>
          {/* Ozet + modalite dagilimi GRIDIN USTUNDE: satirlar "hangi
              tetkik", ozet "ne kadar / hangi cihaz" sorusunu cevaplar. */}
          <HekimGonderimOzeti hekimId={b.id as number} />
          <GenGrid kaynak="radyoloji-istem" gomulu seritGizli boyut={25}
                   sabitFiltre={{ alan: 'istekHekimId', op: 'esit', deger: b.id as number }} />
        </>,
  },
  // BANKO "Oturumlar" (mockup banko_tanimi_v2.html): bankonun vardiya
  //   geçmişi. Oturum = banko + görevli; fark eğilimi buradan okunur.
  //   Kart detayı değil, Banko Oturumları listesinin bu bankoya süzülmüş
  //   hali - salt okunur.
  banko: {
    Oturumlar: b => b.yeniMi
      ? yeniKartNotu('Banko kaydedildikten sonra açılan oturumlar burada listelenir.')
      : <GenGrid
          kaynak="bankoOturum"
          gomulu
          seritGizli
          boyut={25}
          sabitFiltre={{ alan: 'bankoId', op: 'esit', deger: b.id as number }}
          kolonSirasi={['id', 'acilisTs', 'gorevli', 'devirTutar', 'nakitTahsilat',
                        'posTutar', 'kapanisSayim', 'kapanisFark', 'teslimAlan', 'durumAdi']}
          cipler={[
            { ad: 'Tümü' },
            { ad: 'Açık', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
            { ad: 'Farklı kapananlar', filtre: { op: 'and', kosullar: [
              { alan: 'durum', op: 'esit', deger: 4 },
              { alan: 'kapanisFark', op: 'esitDegil', deger: 0 },
            ] } },
          ]}
        />,
  },
};

/** kaynak -> özel sekme anahtarı -> gövde (sunucunun `ozel:` sekmeleri, ekrana bağlı olanlar). */
const OZEL_SEKMELER: Record<string, Record<string, (b: OzelSekmeBaglami) => ReactNode>> = {
  rol: { 'ozel:yetkiler': b => <RolYetkiMatrisi rolId={b.id as number} saltOkunur={b.salt} /> },
};

/** Bu kaynağın bu detayı kendi gövdesiyle mi çiziliyor (generic grid çizilmez). */
export const ozelDetayGovdesi = (kaynak: string, detayAd: string) => OZEL_DETAYLAR[kaynak]?.[detayAd];
/** Yer tutucu sekmenin gövdesi (yoksa "yakında"). */
export const ozelYerTutucuGovdesi = (kaynak: string, baslik: string) => OZEL_YER_TUTUCULAR[kaynak]?.[baslik];
/** Ekrana bağlı `ozel:` sekmenin gövdesi. */
export const ozelSekmeGovdesi = (kaynak: string, anahtar: string) => OZEL_SEKMELER[kaynak]?.[anahtar];
