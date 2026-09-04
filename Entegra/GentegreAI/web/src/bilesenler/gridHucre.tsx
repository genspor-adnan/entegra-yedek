import { Fragment } from 'react';
import type { KolonMeta } from '../api/sozlesme';

/**
 * GRID HUCRE YARDIMCILARI - durum rozeti, JSON/log govdesi cozumleme,
 * "eski -> yeni" degisim ayirmasi ve gorunum seridi.
 *
 * GenGrid 1002 satira ulasmisti; bu parcalar gridin DURUMUNA dokunmuyor
 * (yalniz gelen degeri bicimliyor), o yuzden ayri dosyada.
 */
/**
 * GENEL KURAL: aktif/pasif durumu her listede AYNI gorunur - yesil "Aktif" /
 * kirmizi "Pasif" rozeti (kullanici: "durumlar hep boyle gosterilmeli").
 *
 * Iki kaynak: mantik tipli `durum` kolonu (1/0) ve sunucuda metne cevrilmis
 * durum kolonlari ("Aktif"/"Pasif"). Belge/kasa gibi COK DEGERLI durum
 * kolonlari (taslak/kesin/iptal) bu kalibin disinda kalir - onlar rozet degil
 * duz metin, cunku iki renkli bir gosterim yaniltirdi.
 */
export function durumRozeti(deger: unknown, kolon: KolonMeta) {
  // "durum" kolonu bazi kaynaklarda mantik (1/0), bazilarinda kod tipinde -
  //   ikisinde de AYNI rozet cikmali; kod tipinde ham "1" gostermek kullaniciya
  //   hicbir sey soylemiyordu. Cok degerli durum kolonlari (belge/kasa:
  //   taslak/kesin/iptal) 0/1 disinda deger tasidigi icin bu kalibin disinda kalir.
  const sayisalDurum = kolon.ad === 'durum'
    && (kolon.tip === 'mantik' || kolon.tip === 'kod')
    && (Number(deger) === 1 || Number(deger) === 0);
  const aktifMi =
    sayisalDurum ? Number(deger) === 1
    : deger === 'Aktif' ? true
    : deger === 'Pasif' ? false
    : null;
  if (aktifMi === null) return null;
  return (
    <span className={`rozet ${aktifMi ? 'ok' : 'hata'}`}>{aktifMi ? 'Aktif' : 'Pasif'}</span>
  );
}

/**
 * ROZET BICIMLI kolon (Bicim: "rozet"): sunucu METNI doner (SQL case ile),
 * burada yalnizca RENK secilir. Cek/senet gibi cok degerli durum/yon
 * kolonlari icin - `durumRozeti` yalniz 0/1 (Aktif/Pasif) kalibini bilir.
 *
 * Renk anlama gore: olumlu biten haller yesil, sorunlu kirmizi, kapanmis gri,
 * digerleri notr. Eslesmeyen metin notr rozet olur - yeni bir durum kodu
 * eklenince ekran bozulmaz, yalnizca rengi notr kalir.
 */
/**
 * Rozet metni -> renk sinifi. DISA ACIK: renklerin gercekten AYRISTIGINI
 * tutan test bunu okur (bkz. rozetRenkleri.test.ts). "mor" / "bilgi" / "mavi"
 * siniflarinin ucu de ayni maviye dustugu icin prim rolleri ayni renk
 * gorunuyordu - gozle fark edilmesi zor, testle kolay.
 */
export const ROZET_SINIFI: Record<string, string> = {
  'Alınan': 'ok', 'Verilen': 'uyari',
  'Portföyde': 'bilgi', 'Ciro Edildi': 'uyari', 'Tahsilde': 'bilgi',
  'Teminatta': 'bilgi', 'Tahsil Edildi': 'ok', 'Ödendi': 'ok',
  'Karşılıksız': 'hata', 'İade': 'uyari', 'İptal': 'hata',
  // Kasa islemi durumlari (KasaDurum): taslak/planli henuz kesinlesmemis,
  //   gerceklesti tamam, iptal ters kayitli, plan kapandi bitmis.
  'Taslak': 'gri', 'Planlı': 'bilgi', 'Gerçekleşti': 'ok', 'Plan Kapandı': 'gri',
  // e-Belge turleri (156): seri kurallari gridinde tur bir bakista ayirt
  //   edilsin - ucu de ayni renkteyken hangi satirin hangi belgeye ait oldugu
  //   ancak okunarak anlasiliyordu.
  'e-Fatura': 'bilgi', 'e-Arşiv': 'bilgi', 'e-İrsaliye': 'uyari', 'e-SMM': 'gri',
  // HAZIRLANDI mavi/sari (henuz gonderilmedi), GONDERILDI yesil: belge
  //   listesinde asama bir bakista ayrilsin (163/164).
  'e-Fatura ✓': 'ok', 'e-Arşiv ✓': 'ok', 'e-İrsaliye ✓': 'ok',
  // Irsaliye listesi: e-Belge hic hazirlanmamis belge KAGIT (notr gri),
  //   GIB yaniti gelenler kabul/red (yesil/kirmizi).
  'Kağıt': 'gri', 'Kabul': 'ok', 'Red': 'hata',
  // Belge durumu (0 kesin / 1 taslak / 2 iptal), donusum ve odeme kapanisi.
  'Kesin': 'ok',
  'Açık': 'bilgi', 'Kısmi': 'uyari', 'Kapandı': 'gri', 'Kapalı': 'gri',
  // e-Belge SENARYOLARI: Temel notr, Ticari (yanit bekleyen akis) sari,
  //   Ihracat/Kamu/Ilac ozel akislar - bir bakista ayrilsinlar.
  'Temel': 'gri', 'Ticari': 'uyari', 'İhracat': 'mor', 'Kamu': 'mor',
  'İlaç / Tıbbi Cihaz': 'bilgi',
  // Fatura tipleri (satis fatura listesi).
  // Islem gunlugu islem tipleri (kullanici: rozet).
  'Ekleme': 'ok', 'Değişiklik': 'uyari', 'Silme': 'hata',
  // Teklif akisi (218): Kabul/Red/İptal yukarida zaten var.
  'Hazırlanıyor': 'gri', 'Sunuldu': 'bilgi',
  'Tevkifatlı': 'uyari', 'KDV İstisna': 'bilgi', 'İhraç Kayıtlı': 'bilgi',
  'Fiyat Farkı': 'gri', 'Kur Farkı': 'gri', 'SGK': 'bilgi',
  // Randevu durumlari (243, kullanici: "randevu listesi durum rozet olsun").
  'Planlandı': 'bilgi', 'Geldi': 'ok', 'Gelmedi': 'hata',
  'Bilinmiyor': 'hata',
  // Entegrasyon hesaplari (336-340): ortam TEST sari / CANLI yesil - yanlis
  //   ortamda gonderim en pahali hata, listede bir bakista ayrilsin.
  //   Sube rozetlerinde "Tümü" (kurum geneli hesap) notr gri.
  'TEST': 'uyari', 'CANLI': 'ok', 'Tümü': 'gri', 'Kendisi': 'gri',
  // AKTIF/PASIF her yerde ayni: yesil / KIRMIZI (kullanici: "pasifler hep
  //   kırmızı"). `durumRozeti` bunu zaten boyle ciziyordu ama o yalniz 0/1
  //   kolonlarini biliyor - METIN uretip rozet isteyen kolonlar (prim plani
  //   Durum'u gibi) sozlukten gectigi icin GRI dusuyordu.
  'Aktif': 'ok', 'Pasif': 'hata',
  // PRIM PLANI (kullanici: "rozet farklarda renk olsun"). Ayni listede dort
  //   rozet kolonu yan yana duruyor; hepsi gri olunca rozet olmalari hicbir
  //   sey soylemiyordu. Renk AYIRT ETMEK icin - "iyi/kotu" degil.
  //   DOKUZ ROLUN HER BIRI AYRI RENK (kullanici: "hep aynı renk olmasın") -
  //   ayni listede yan yana okunuyorlar, ayni renk rozeti anlamsiz kiliyordu.
  //   NOT: "mor" / "bilgi" / "mavi" siniflari GOZLE AYNI mavi (tema
  //   degiskeni --mor aslinda #2f6db3 mavi) - roller bu yuzden ayni renk
  //   gorunuyordu. Ucunden yalniz BIRI (mavi) kullanilir.
  'Gönderen': 'eflatun', 'İsteyen': 'turkuaz', 'Uygulayan': 'zeytin',
  'Yapan': 'turuncu', 'Raporlayan': 'mavi', 'Onaylayan': 'lacivert',
  'Anestezi': 'pembe', 'Asistan': 'uyari', 'Teknisyen': 'gri',
  // Prim zamani: para NE ZAMAN dogar - faturalama pesin, tahsilat beklemeli.
  'Faturalamada': 'uyari', 'Tahsilatta': 'ok',
  // Odeyen tipi ("SGK" yukarida zaten bilgi).
  'Özel (Ücretli)': 'turkuaz', 'ÖSS': 'uyari',
};

export function rozetHucre(deger: unknown, kolon: KolonMeta) {
  if (kolon.bicim !== 'rozet') return null;
  const metin = String(deger ?? '').trim();
  if (metin === '') return null;
  // Sozlukte olmayan metin (sube adi gibi degisken deger) NOTR GRI rozet:
  //   sinifsiz rozet yalniz "kalin yazi" gibi gorunuyordu, kolon rozet
  //   istendigi halde duz metinden ayirt edilemiyordu (kullanici).
  return <span className={`rozet ${ROZET_SINIFI[metin] ?? 'gri'}`}>{metin}</span>;
}

/** "İçerik" penceresi (ör. islem-log > bilgi) - JSON ise okunakli bicimde, degilse duz metin. */
function icerikMetni(deger: unknown): string {
  if (deger === null || deger === undefined || deger === '') return 'İçerik yok.';
  if (typeof deger !== 'string') return String(deger);
  try {
    return JSON.stringify(JSON.parse(deger), null, 2);
  } catch {
    return deger;
  }
}

function jsonCoz(deger: unknown): unknown {
  if (deger === null || deger === undefined || deger === '') return null;
  if (typeof deger !== 'string') return deger;
  try {
    return JSON.parse(deger);
  } catch {
    return deger;
  }
}

const degerMetni = (deger: unknown) =>
  deger === null || deger === undefined || deger === '' ? '-' : String(deger);

const degisimAyir = (deger: unknown): { onceki?: string; sonraki?: string; duz: string } => {
  const metin = degerMetni(deger);
  const ayirac = ' -> ';
  const indeks = metin.indexOf(ayirac);
  if (indeks < 0) return { duz: metin };
  return {
    onceki: metin.slice(0, indeks) || '-',
    sonraki: metin.slice(indeks + ayirac.length) || '-',
    duz: metin,
  };
};

export function LogTablosu({ deger }: { deger: unknown }) {
  const veri = jsonCoz(deger);
  if (veri === null) return <div className="grid-bilgi">İçerik yok.</div>;
  if (typeof veri !== 'object') return <div className="grid-bilgi">{icerikMetni(veri)}</div>;

  const satirlar: { bolum: string; alan: string; onceki?: string; sonraki?: string; deger: string }[] = [];
  const ekle = (bolum: string, alan: string, ham: unknown) => {
    const d = degisimAyir(ham);
    satirlar.push({ bolum, alan, onceki: d.onceki, sonraki: d.sonraki, deger: d.duz });
  };
  const nesneEkle = (bolum: string, nesne: Record<string, unknown>) =>
    Object.entries(nesne).forEach(([alan, ham]) => ekle(bolum, alan, ham));

  const kok = veri as Record<string, unknown>;
  if (kok.kart && typeof kok.kart === 'object' && !Array.isArray(kok.kart))
    nesneEkle('Kart', kok.kart as Record<string, unknown>);
  if (kok.detaylar && typeof kok.detaylar === 'object' && !Array.isArray(kok.detaylar)) {
    Object.entries(kok.detaylar as Record<string, unknown>).forEach(([detayAd, liste]) => {
      if (Array.isArray(liste)) {
        liste.forEach((satir, i) => {
          if (satir && typeof satir === 'object' && !Array.isArray(satir))
            nesneEkle(`${detayAd} #${i + 1}`, satir as Record<string, unknown>);
        });
      }
    });
  }
  if (satirlar.length === 0) nesneEkle('Bilgi', kok);

  const degisimVar = satirlar.some(s => s.onceki !== undefined || s.sonraki !== undefined);
  const gruplar = satirlar.reduce<Record<string, typeof satirlar>>((sonuc, satir) => {
    (sonuc[satir.bolum] ??= []).push(satir);
    return sonuc;
  }, {});
  const kolonSayisi = degisimVar ? 3 : 2;

  return (
    <table className="grid">
      <thead>
        <tr>
          <th>Alan</th>
          {degisimVar ? <><th>Önceki</th><th>Sonraki</th></> : <th>Değer</th>}
        </tr>
      </thead>
      <tbody>
        {Object.entries(gruplar).map(([bolum, liste]) => (
          <Fragment key={bolum}>
            <tr className="log-bolum-satiri">
              <td colSpan={kolonSayisi}>Bölüm: {bolum}</td>
            </tr>
            {liste.map((s, i) => (
              <tr key={`${s.bolum}:${s.alan}:${i}`}>
                <td>{s.alan}</td>
                {degisimVar ? <><td>{s.onceki ?? '-'}</td><td>{s.sonraki ?? s.deger}</td></> : <td>{s.deger}</td>}
              </tr>
            ))}
          </Fragment>
        ))}
      </tbody>
    </table>
  );
}

/** Mockup: cip seridinde Liste/Grup/Analiz gorunum secimi (search kutusunun hemen sagi). */
export const GORUNUMLER: { v: 'liste' | 'grup' | 'analiz'; ik: string; ad: string }[] = [
  { v: 'liste', ik: '▤', ad: 'Liste' },
  { v: 'grup', ik: '▦', ad: 'Grup' },
  { v: 'analiz', ik: '📊', ad: 'Analiz' },
];
