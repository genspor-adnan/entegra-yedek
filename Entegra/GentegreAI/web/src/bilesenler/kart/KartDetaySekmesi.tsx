import type { ReactNode } from 'react';
import { GenDetayTablo, type DetayDurumu, bosDetay } from '../GenDetayTablo';
import { KademeGridi } from '../prim/KademeGridi';
import { KategoriSuzgeci } from '../KategoriSuzgeci';
import { tarifeHizli, ttbFiyatTuret, tarifeGizli, fiyatSatirKurali, kurumTarifeTipi }
  from './tarifeKurallari';
import type { Deger } from '../kartAlanCizim';
import type { SekmeTanimi } from '../kartSekmeleri';
import { api } from '../../api/istemci';
import { GozOlcumMatrisi } from '../goz/GozOlcumMatrisi';
import { GOZ_MATRISLERI } from '../goz/gozMatrisTanimlari';
import { mesaj } from '../mesaj';

/** Sekme icin detay sayfalama/suzme cagrilari - kart govdesinden gelir. */
export interface KartDetaySekmesiOzellikleri {
  /** Acik sekme (tur === 'detay' oldugu YERDE cagrilir). */
  aktif: Extract<SekmeTanimi, { tur: 'detay' }>;
  kaynak: string;
  salt: boolean;
  deger: Record<string, Deger>;
  alanHatalari: Record<string, string>;
  detaylar: Record<string, DetayDurumu>;
  setDetaylar(f: (t: Record<string, DetayDurumu>) => Record<string, DetayDurumu>): void;
  detaySayfa: Record<string, number>;
  detayToplam: Record<string, number>;
  detaySayfaYuk: string | null;
  detaySayfaDegis(ad: string, sayfa: number): void | Promise<void>;
  detaySuzgecUygula(ad: string,
                    suz: { ara?: string; cip?: string; kategori?: number }): void | Promise<void>;
  detaySecenekleri?: Record<string, { gizli?: string[]; sinif?: string;
                                      sade?: boolean; gridKipi?: boolean;
                                      salt?: boolean; ekleGizli?: boolean;
                                      /** YALNIZ gridde gizli - modalde durur. */
                                      gridGizli?: string[] }>;
  satirKategori: { id: number; agac: number[]; ad: string } | null;
  setSatirKategori(v: { id: number; agac: number[]; ad: string } | null): void;
  satirKategorileri?: Set<number>;
  setSeciliSatirlar(v: ReadonlySet<number>): void;
  /** Ekran sekmenin altina kendi panelini ekleyebilir (muayene sonuclari). */
  sekmeSarmalayici?(baslik: string, icerik: ReactNode,
                    deger: Record<string, Deger>): ReactNode;
}

/**
 * KART DETAY SEKMESI - satir ici duzenlemeli ya da GRID kipinde detay tablosu.
 *
 * `GenForm` govdesinde 175 satirlik bir IIFE olarak duruyordu: grid kipi
 * karari, sunucu sayfalamasi, kategori suzgeci ve tarife kurallari bir arada.
 * Davranis degismedi - yalniz yeri degisti.
 */
export function KartDetaySekmesi({
  aktif, kaynak, salt, deger, alanHatalari,
  detaylar, setDetaylar, detaySayfa, detayToplam, detaySayfaYuk,
  detaySayfaDegis, detaySuzgecUygula, detaySecenekleri,
  satirKategori, setSatirKategori, satirKategorileri,
  setSeciliSatirlar, sekmeSarmalayici,
}: KartDetaySekmesiOzellikleri) {
        /**
         * GRID KIPI: satir ici duzenleme yerine SECIM KUTUSU + ust satirda
         * ekle/duzenle/sil + grid menusu (kolonlar / CSV) - liste
         * ekranlarindaki grid davranisi.
         *   - fiyat listesi satirlari: satir ici kip 1.400 satirda milyonlarca
         *     DOM dugumu uretiyordu,
         *   - aramayla dolan detaylar (375): alanlarin cogu salt okunur,
         *   - prim plani detaylari (kullanici): kod/oran alanlari satir ici
         *     kutularda okunaksizdi.
         */
        const ayar = detaySecenekleri?.[aktif.detay.ad];
        const gridKipi = ayar?.gridKipi
          || (kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar')
          || kaynak === 'prim-plani'
          // DOKUMAN (419, kullanici: "gridleri gengrid readonly yap"): tum
          //   detaylari SALT GORUNUM + grid kipi. Surum, onay, baglanti,
          //   paylasim ve gunluk zaten elle duzenlenmez - satir ici kutular
          //   yanlis bir "burayi degistirebilirsin" izlenimi veriyordu.
          //   Grid kipi ayrica kolon menusu ve CSV'yi getirir: liste
          //   ekranlarindaki grid ile ayni davranis.
          || kaynak === 'dokuman'
          || aktif.detay.alanlar.some(a => a.tip === 'kod' && a.aramaKaynagi);
        /* LAB ISTEMI "Tetkikler" gridi: sonuc satir ici girilir. */
        const labSonucGridi = kaynak === 'lab-istem' && aktif.detay.ad === 'satirlar'
                              && !salt && !aktif.detay.saltOkunur;
        // GÖZ ÖLÇÜM MATRİSİ (mockup goz_detayli_muayene.html `.odos`):
        //   satır = parametre, sütun = göz. Genel detay gridi aynı veriyi
        //   tutuyordu ama hekime her satırda "bu hangi göz, bu hangi tür"
        //   sorusunu yeniden sorduruyordu; matris iki soruyu da ızgaranın
        //   kendisine taşır. VERİ MODELİ AYNI - satırlar yine goz_gorme /
        //   goz_refraksiyon kayıtları, kaydetme yine kartın normal akışı.
        const gozMatris = kaynak === 'goz-muayene'
          ? GOZ_MATRISLERI[aktif.detay.ad] : undefined;
        if (gozMatris) {
          // EK MATRİS AYNI SEKMEDE (mockup "Görme & Refraksiyon"): iki ölçüm
          //   birlikte okunuyorsa sekmeye bölmek, hekimi her karşılaştırmada
          //   sekme değiştirmeye zorlar. İkisi de KENDİ detay durumunu
          //   günceller - veri modeli değişmiyor, yalnız çizim yeri ortak.
          const ek = gozMatris.ekMatris ? GOZ_MATRISLERI[gozMatris.ekMatris] : undefined;
          return (
            <>
              <GozOlcumMatrisi
                tanim={gozMatris}
                durum={detaylar[aktif.detay.ad] ?? bosDetay()}
                salt={salt || aktif.detay.saltOkunur}
                onDegis={yeni => setDetaylar(t => ({ ...t, [aktif.detay.ad]: yeni }))}
              />
              {ek && (
                <GozOlcumMatrisi
                  tanim={ek}
                  durum={detaylar[ek.detay] ?? bosDetay()}
                  salt={salt || aktif.detay.saltOkunur}
                  onDegis={yeni => setDetaylar(t => ({ ...t, [ek.detay]: yeni }))}
                />
              )}
            </>
          );
        }

        const grid = (
        <GenDetayTablo
          meta={aktif.detay}
          durum={detaylar[aktif.detay.ad] ?? bosDetay()}
          // DOKUMAN: en dis cerceve YOK (kullanici) - sekme zaten bir
          //   cercevedir, grid'in kendi baslik seridiyle cift cizgi olusuyordu.
          kutuSinif={ayar?.sinif ?? (kaynak === 'dokuman' ? 'kutu-cercevesiz' : undefined)}
          sadeGrid={ayar?.sade}
          // SATIR EKLE/SIL GIZLI (536, kullanici: "satir ekleme ve silme
          //   simdilik gorunmez olsun, dursun ama gorunmesin"): fiyat listesi
          //   SKRS katalogundan kuruluyor - satiri elle eklemek/silmek
          //   listeyle katalogu ayirir. Yetenek duruyor, dugme cizilmiyor.
          ekleGizli={ayar?.ekleGizli
            || (kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar')}
          silGizli={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'}
          saltOkunur={salt || aktif.detay.saltOkunur || !!ayar?.salt}
          hatalar={alanHatalari}
          onDegis={yeni => setDetaylar(t => ({
            ...t,
            [aktif.detay.ad]:
              kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
                && Number(deger.tarifeTipi) === 2
                ? ttbFiyatTuret(yeni) : yeni,
          }))}
          // Fiyat listesi satirlari SALT GORUNUM + modal duzenleme: satir ici
          //   kipte her satir stok (5.000+) ve hizmet (3.700+) lookup'unu ayri
          //   <select> olarak cizer - 1.438 satirlik listede ~12 MILYON DOM
          //   dugumu sekmeyi donduruyordu ("Satirlar acilmiyor").
          // ARAMAYLA DOLAN DETAY (375) da SALT GORUNUM + ikonlu baslik: satirin
          //   tek yazilabilir alani aciklama, geri kalani tarafin kendi
          //   kaydindan okunuyor - satir ici duzenleme kutulari yanlis bir
          //   "burayi degistirebilirsin" izlenimi veriyordu. Ikonlu baslik
          //   ayrica secim kutusunu, sil ikonunu ve grid menusunu (kolonlar /
          //   CSV) getirir - liste ekranlarindaki grid ile ayni davranis.
          // GRID KIPI (secim kutusu, ust satirda ekle/duzenle/sil, grid menusu):
          //   fiyat listesi satirlari, aramayla dolan detaylar ve PRIM PLANI
          //   detaylari. Prim satirinda alanlarin cogu kod/oran - satir ici
          //   kutular yerine modal duzenleme daha okunakli (kullanici).
          modalDuzenle={gridKipi}
          ikonlu={gridKipi}
          // SAYFALI DETAY (525): serit yalniz katalog sayfa boyu verdiginde
          //   cizilir; sayfasiz detaylarda bu proplarin hicbir etkisi yok.
          sayfa={detaySayfa[aktif.detay.ad] ?? 1}
          toplam={detayToplam[aktif.detay.ad]}
          sayfaYukleniyor={detaySayfaYuk === aktif.detay.ad}
          onSayfa={n => { void detaySayfaDegis(aktif.detay.ad, n) }}
          // Secim yukari akar (534): toplu "Çarpan Gir" dugmesi kartin UST
          //   arac cubugunda, Sil'in saginda duruyor.
          onSecim={setSeciliSatirlar}
          // Satir ici giris tarife tipine gore (533): TTB'de katsayi/carpan,
          //   SUT'ta yalniz katki - fiyat ikisinde de turetilmis degerdir.
          hizliAlanlar={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? tarifeHizli(Number(deger.tarifeTipi) || 1)
            : labSonucGridi ? new Set(['sonuc']) : undefined}
          // LAB SONUCU SATIR ICINDE (kullanici: "tetkikler sekmesinde sonuc
          //   kolonu girise izin vermiyor" · "modalsiz de girmem lazim").
          //   Grid, tetkik aramasi tanimli oldugu icin SALT GORUNUM kipine
          //   dusuyordu; sonuc kolonu artik satir ici yaziliyor.
          //   Deger KARTIN TASLAGINA DEGIL, `POST /api/lab/sonuc`a gider:
          //   referans, bayrak, panik ve delta sunucuda hesaplanmali.
          // DEGERIN SAGINDA YON OKU (kullanici): dusuk ↓, yuksek ↑,
          //   panik ⚠. Ayri "Degerlendirme" kolonuna bakmadan, sayiyi
          //   okurken yonu de gorunur.
          hucreEki={labSonucGridi
            ? (satir, alan) => {
                if (alan !== 'sonuc') return null;
                const i = Number(satir.isaret ?? 0);
                const delta = Number(satir.deltaUyari ?? 0) === 1;
                if (!i && !delta) return null;
                return (
                  <>
                    {!!i && (
                      <span className={`rozet ${i === 3 ? 'hata' : 'uyari'} hucre-ok`}
                            title={i === 3 ? 'Panik değer' : i === 1 ? 'Düşük' : 'Yüksek'}>
                        {i === 3 ? '⚠' : i === 1 ? '↓' : '↑'}
                      </span>
                    )}
                    {/* DELTA: onceki sonucla arada buyuk fark var. Kolonu
                        yok, mesaj da vermiyoruz - isaret kalir. */}
                    {delta && (
                      <span className="rozet uyari hucre-ok"
                            title="Delta uyarısı: önceki sonuçla arada büyük fark var">
                        Δ
                      </span>
                    )}
                  </>
                );
              }
            : undefined}
          // PANIKTE HUCRE KIRMIZI (kullanici): rozet kucuk kaliyor, panik
          //   deger hekime bildirilmek zorunda - hucrenin kendisi isaretli.
          hucreSinifi={labSonucGridi
            ? (satir, alan) => (alan === 'sonuc' && Number(satir.isaret) === 3
                                ? 'hucre-panik' : undefined)
            : undefined}
          hucreYaz={labSonucGridi
            ? async (satir, _alan, girilen) => {
                const satirId = Number(satir.id ?? 0);
                if (!satirId)
                  throw new Error('Önce istemi kaydedin - sonuç kayıtlı satıra yazılır.');
                const y = await api.labSonucYaz({
                  istemSatirId: satirId, deger: girilen,
                  birim: String(satir.birim ?? '') || undefined,
                });
                // BASARILI YAZIMDA MESAJ YOK (kullanici: "panik ve yuksek
                //   mesajlari da gelmesin, zaten isaretlerle gosteriyor").
                //   Satir satir girerken her degerden sonra pencere acilmasi
                //   akisi kesiyordu; sonucun durumu hucrede duruyor: ok,
                //   kirmizi panik hucresi, Degerlendirme kolonu.
                //   TEK ISTISNA DELTA (kullanici: "delta uyarisi gelsin
                //   sadece"): onceki sonucla celisen deger, bayrak normal
                //   olsa bile teknisyenin DURUP bakmasini gerektirir -
                //   numune karisikligi ya da cihaz kaymasi olabilir.
                //   Satirda ayrica "Δ" isareti kalir.
                //   Hata halinde mesaj yine cikar (GenDetayTablo yakalar).
                if (y.deltaUyari) mesaj(y.mesaj);
                return {
                  // `isaret` sunucudaki ayna kolonuyla ayni kod: 0 normal,
                  //   1 dusuk, 2 yuksek, 3 panik.
                  isaret: y.panik ? 3
                          : y.bayrak.startsWith('L') ? 1
                          : y.bayrak.startsWith('H') ? 2 : 0,
                  durum: 3,
                  deltaUyari: y.deltaUyari ? 1 : 0,
                };
              }
            : undefined}
          // FIYAT LISTESI KURUM TURUNE GORE (587, kullanici): sozlesme
          //   satirinin listesi, kartin basligindaki KURUM TURUNE uyan
          //   tarifeyle sinirlanir - SGK sozlesmesine Özel tarifesi secmek
          //   sessiz yanlis fiyatlandirmadir. Kurum turu ayri bir 1:1 detayda
          //   (`kurumRolu`) durdugu icin satirdan degil BURADAN gecer.
          ustSuzgec={kaynak === 'kurum' && aktif.detay.ad === 'sozlesmeler'
            ? (() => {
                const tur = Number(detaylar.kurumRolu?.guncel[0]?.tur ?? 0);
                const tarife = kurumTarifeTipi(tur);
                // SUT LISTESI HER ZAMAN SUT TARIFESI (3, kullanici): kurum
                //   turunden bagimsiz - alanin tanimi zaten "SGK'nin odedigi
                //   bedel". Fiyat listesi ise kurum turune gore daralir.
                return { ...(tarife ? { fiyatListesiId: String(tarife) } : {}),
                         sgkFiyatListesiId: '3' };
              })()
            : undefined}
          // SUZGEC SUNUCUDA yalniz SAYFALI detayda (526); sayfasiz detaylar
          //   bugunku istemci suzmesini surdurur.
          onSuzgec={aktif.detay.sayfaBoyu
            ? suz => { void detaySuzgecUygula(aktif.detay.ad, suz) } : undefined}
          // PRIM ZAMANI "Faturalamada" ISE TAHSILAT TURU SORULMAZ (kullanici):
          //   fatura kesilirken paranin hangi araçla tahsil edilecegi HENUZ
          //   BELLI DEGIL. Eslestirme zaten bu kriteri o kipte yok sayiyor;
          //   alani ekranda tutmak, uygulanmayan bir ayar uretiyordu.
          // kategoriId SUZGEC ANAHTARI (asagida): gridde de modalde de
          //   gorunmez - kullaniciya "Kategori" zaten yol metniyle gosteriliyor.
          // TARIFE TIPINE GORE SUTUN (518, kullanici: "bu listede sutunlar
          //   tipe gore gorunur/gorunmez olacak"):
          //     1 Özel : yalniz Fiyat (hasta oder) - katsayi/carpan/katki yok
          //     2 TTB  : Katsayi x Carpan = Fiyat + Katki (TSS hastasi)
          //     3 SUT  : Fiyat (SKRS'den, elle degismez) + Katki (hasta)
          //   Anlamsiz kolonu gostermek, doldurulmasi gereken bir alan
          //   izlenimi veriyordu.
          gizliAlanlar={ayar?.gizli ? new Set(ayar.gizli)
            : kaynak === 'prim-plani' && Number(deger.primZamani) === 2
            ? new Set(['tahsilatTuru'])
            : kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? new Set(['kategoriId', 'kalemAdi', ...tarifeGizli(Number(deger.tarifeTipi) || 1)])
            : undefined}
          // Tabloyu sadelestirir, DUZENLEMEYI kisitlamaz: modal tam kalir.
          gridGizliAlanlar={ayar?.gridGizli ? new Set(ayar.gridGizli) : undefined}
          // ARAMA PLANIN ROLUNE BAGLI (383, kullanici): yalnizca O ROLDE ADAY
          //   olan kisiler listelenir. Rolu isaretlenmemis birine yazilan
          //   satir `belge_satir_rol`'de hic gorunmez, hakedis HIC dogmaz ve
          //   eksik prim ancak ay sonunda fark edilir.
          //   "Dis hekim yalniz Gönderen planina" kurali bundan KENDILIGINDEN
          //   cikar: aday gorunumunde dis hekimin tek rolu Gönderen.
          // KADEMELER (388): plan SATIRININ cocugu - satir modalinin altinda.
          //   Ayri sekme yapilamiyor cunku cerceve detayi kartin id'siyle
          //   baglar, kademe ise satir_id'ye bagli (torun).
          modalAltBilesen={kaynak === 'prim-plani' && aktif.detay.ad === 'satirlar'
            ? (satirId => <KademeGridi planSatirId={satirId} />) : undefined}
          aramaEkFiltre={kaynak === 'prim-plani' && aktif.detay.ad === 'taraflar'
            ? { alan: 'rol', op: 'esit' as const, deger: Number(deger.rol) || 1 }
            : undefined}
          taslakKural={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? ((alan, v, taslak) => fiyatSatirKurali(alan, v, taslak, deger))
            : undefined}
          // Tumu / Stok / Hizmet cipleri (kullanici) - karma listede tek tur gorunur.
          cipler={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            // `kod`: SAYFALI DETAYDA sunucuya giden cip anahtari (526) -
            //   katalogdaki SQL kosuluyla eslesir.
            // PASIF KALEM GIZLI (531): "Tümü" bile pasif kalemi getirmez -
            //   kategorisi kapatilan (527) kalem kurumun yapmadigi islemdir.
            //   Fiyati kaybolmaz, "Pasif" cipiyle gorulur.
            ? [{ ad: 'Tümü', kod: 'aktif', suz: () => true },
               { ad: '📦 Stok', kod: 'stok',
                 suz: s => s.stokId != null && s.stokId !== '' },
               { ad: '🛠️ Hizmet', kod: 'hizmet',
                 suz: s => s.hizmetId != null && s.hizmetId !== '' },
               { ad: '🚫 Pasif', kod: 'pasif', suz: () => true }]
            : undefined}
          // KATEGORI AGAC COMBOSU (kullanici) - arama kutusunun saginda.
          //   Secenekler SATIRLARDA GECEN dallarla sinirli: 5.000 stok
          //   kategorisinin tamamini listelemek, cogu secimde bos grid verirdi.
          ekSuzgec={kaynak === 'fiyat-listesi' && aktif.detay.ad === 'satirlar'
            ? {
                cizim: (
                  <KategoriSuzgeci
                    tur={[1, 2]}
                    baslik="🌳 Tüm Kategoriler"
                    sinirla={satirKategorileri}
                    deger={satirKategori?.id ?? null}
                    onDegis={(id, agac, ad) => {
                      setSatirKategori(id === null ? null : { id, agac, ad });
                      // SAYFALI DETAYDA SUZGEC SUNUCUDA (526): dal secimi
                      //   ekrandaki 200 satiri degil listenin TAMAMINI suzer.
                      if (aktif.detay.sayfaBoyu)
                        void detaySuzgecUygula(aktif.detay.ad, { kategori: id ?? undefined });
                    }}
                  />
                ),
                deger: satirKategori?.id ?? undefined,
                suz: satirKategori
                  ? (s: Record<string, unknown>) =>
                      satirKategori.agac.includes(Number(s.kategoriId))
                  : undefined,
              }
            : undefined}
        />
        );
        // SARMALAYICI DETAY SEKMESINDE DE CALISIR (461): muayenenin
        //   "Istem & Sonuclar" paneli bir DETAY sekmesinin altina giriyor;
        //   sarmalayici yalniz grup sekmelerinde cagrildigi icin panel hic
        //   cizilmiyordu (grid "satir yok" derken sonuclar duruyordu).
        return sekmeSarmalayici ? sekmeSarmalayici(aktif.baslik, grid, deger) : grid;
}
