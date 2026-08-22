import { useMemo, useState } from 'react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import { ApiHatasi, type Kosul, type ListeSatiri } from '../api/sozlesme';
import { api } from '../api/istemci';
import { BelgeDonusumModali } from '../bilesenler/BelgeDonusumModali';
import { BelgeKarti } from './BelgeKarti';

export interface ListeTanimi {
  kaynak: string;
  baslik: string;
  yol: string;
  /** Kart ekrani olan kaynaklarda cift tik karta gider. */
  kartYolu?: string;
  aksiyonEkrani?: string;
  toplam?: string[];
  cipler?: { ad: string; filtre?: Kosul }[];
  /** Mockup'ta olup backend'i henuz olmayan kart sekmeleri (or. stok: "ÜTS Bilgileri"). */
  yerTutucuSekmeler?: string[];
  /** Mockup'taki "Genel" sekmesindeki bos "Resim" kutusu (IMAJ→DOSYA hic baglanmadi). */
  resimYerTutucu?: boolean;
  /** Verilirse (ör. islem-log > "bilgi") satir bu alaniyla "İçerik" penceresinde gosterilir. */
  icerikAlani?: string;
  icerikBaslik?: string;
  /** Kosulsuz sunucu filtresi (ör. Tedarikci Listesi: tedarikci=1) - cip/arama filtreleriyle
      AND'lenir. Ayni kaynagi (ör. 'cari') farkli görünümlerde tekrar kullanmak icin. */
  sabitFiltre?: Kosul;
  /** Verilirse rota (URL/route path) `kaynak` yerine bunu kullanir - ayni kaynagi
      ("cari") birden fazla ekranda (Musteri/Tedarikci) farkli URL'lerle kullanmak icin. */
  rota?: string;
  /** Yeni kayitta mantik alanlara ekrana ozel varsayilan (ör. Tedarikci Listesi ->
      tedarikci:true, musteri:false) - GenForm'a gecirilir. */
  yeniKayitVarsayilanlari?: Record<string, boolean>;
  /** Ekstre ekranlari: URL'deki ?<alan>=<id> sorgu parametresi sunucu filtresine
      cevrilir (ör. /hesap-ekstre?hesapId=12). Parametre yoksa liste TUM kayitlari
      gosterir - bos ekran yerine "hepsi" daha kullanisli. */
  urlFiltreAlani?: string;
  /** Kart generic GenForm degil, kendi sayfasi (ör. kasa-islem): Liste modal ACMAZ,
      rotayi App.tsx kendisi tanimlar. Cift tik yine kartYolu'na gider. */
  ozelKart?: boolean;
  /** "Yeni" aksiyonunda belge kartinin acilacagi tur (ör. Siparisler -> 19).
      Verilmezse kart kendi varsayilanini (satis faturasi) kullanir. */
  yeniBelgeTuru?: number;
}

/**
 * Tek bilesen tum liste ekranlarini karsilar. Kolonlar, filtreler ve yetki
 * sunucudan geldigi icin ekran basina kod yazmaya gerek yok — yeni bir liste
 * eklemek katalogda kaynak tanimlamak + burada bir satir demek.
 */
export function Liste({ tanim }: { tanim: ListeTanimi }) {
  const git = useNavigate();
  const { id } = useParams();
  const [sorgu] = useSearchParams();

  // Kart MODAL acilir (mockup deseni): liste arkada kalir, URL yine /cari/4911.
  const kartId = id === undefined ? null : (id === 'yeni' ? 'yeni' as const : Number(id));

  // Ekstre ekranlari: /hesap-ekstre?hesapId=12 -> sunucu filtresi. Tanimdaki
  //   sabitFiltre ile birlikte gelirse ikisi AND'lenir.
  const urlDegeri = tanim.urlFiltreAlani ? sorgu.get(tanim.urlFiltreAlani) : null;
  const sabitFiltre = useMemo<Kosul | undefined>(() => {
    if (!tanim.urlFiltreAlani || !urlDegeri) return tanim.sabitFiltre;
    const urlKosul: Kosul = { alan: tanim.urlFiltreAlani, op: 'esit', deger: Number(urlDegeri) };
    return tanim.sabitFiltre
      ? { op: 'and', kosullar: [tanim.sabitFiltre, urlKosul] }
      : urlKosul;
  }, [tanim.urlFiltreAlani, tanim.sabitFiltre, urlDegeri]);

  // Kart kaydedilince (ekleme ya da duzenleme) grid'i yeniden yukletmek icin - GenForm
  //   onKaydedildi'de bir arttirilir, GenGrid bu degisimi izleyip yukle() cagirir.
  const [yenile, setYenile] = useState(0);
  // Yeni kart EKLENINCE (duzenlemede degil) grid "Son Aranan"a gecsin - kullanici
  //   az once ekledigi kaydi listede otomatik en ustte gorsun.
  const [odaklaSonEklenen, setOdaklaSonEklenen] = useState(0);
  // Donusum modali (F8): siparis/irsaliye satirlarindan yeni belge uretir.
  const [donusum, setDonusum] = useState<{ belgeId: number; belgeTur: number } | null>(null);
  // Belge (fatura/siparis) karti da MODAL: liste arkada kalir, rota degismez.
  const [yeniBelgeTuru, setYeniBelgeTuru] = useState<number | null>(null);
  // Mevcut belgeyi ac (salt gorunum) - ayni modal, id ile.
  const [acikBelgeId, setAcikBelgeId] = useState<number | null>(null);

  // Aksiyon yonlendirme. Kasa aksiyonlari API cagirir (kesinlestir/iptal/sil) ve
  //   sonrasinda grid'i tazeler; digerleri kart rotasina gider.
  async function aksiyon(kod: string, satir?: ListeSatiri | null) {
    const kartaGit = (kayitId: unknown) => git(`${tanim.kartYolu}/${kayitId}`);

    try {
      switch (kod) {
        // Grup basina bir giris: kart tur seridini o grubun turleriyle acar.
        case 'kasa.tahsilat.yeni': git('/kasa-islem/yeni?tur=21'); return;
        case 'kasa.odeme.yeni':    git('/kasa-islem/yeni?tur=31'); return;
        case 'kasa.virman.yeni':   git('/kasa-islem/yeni?tur=41'); return;
        case 'kasa.doviz.yeni':    git('/kasa-islem/yeni?tur=45'); return;
        case 'kasa.plan.yeni':     git('/kasa-islem/yeni?tur=61'); return;
        case 'kasa.gerceklestir':
          // Gerceklestirme hesap/tutar secimi ister - plan kartindaki panele goturur.
          if (satir) git(`/kasa-islem/${satir.id}`);
          return;
        case 'kasa.ac':
        case 'kasa.fis-gor':
          if (satir) git(`/kasa-islem/${satir.id}`);
          return;

        case 'kasa.kesinlestir':
          if (!satir) return;
          if (!confirm('İşlem kesinleştirilecek: makbuz numarası verilir ve muhasebe fişi yazılır. Onaylıyor musunuz?')) return;
          await api.kasaKesinlestir(Number(satir.id));
          setYenile(t => t + 1);
          return;

        case 'kasa.iptal': {
          if (!satir) return;
          const sebep = window.prompt('İptal sebebi:');
          if (!sebep) return;
          await api.kasaIptal(Number(satir.id), sebep);
          setYenile(t => t + 1);
          return;
        }

        case 'kasa.sil':
          if (!satir) return;
          if (!confirm('Taslak/plan kaydı silinecek. Onaylıyor musunuz?')) return;
          await api.kasaSil(Number(satir.id));
          setYenile(t => t + 1);
          return;

        case 'belge.yeni': setYeniBelgeTuru(tanim.yeniBelgeTuru ?? 15); return;
        case 'belge.ac':
          if (satir) setAcikBelgeId(Number(satir.id));
          return;
        case 'belge.donustur':
          if (!satir) return;
          setDonusum({ belgeId: Number(satir.id), belgeTur: Number(satir.tur) });
          return;
        case 'genel.yazdir': alert('Yazdirma henuz baglanmadi.'); return;
      }

      if (kod.endsWith('.yeni') && tanim.kartYolu) git(`${tanim.kartYolu}/yeni`);
      else if ((kod.endsWith('.duzenle') || kod.endsWith('.sil') || kod.endsWith('.ac')) && satir && tanim.kartYolu)
        kartaGit(satir.id);
      else if (satir) alert(`"${kod}" aksiyonu henuz baglanmadi.`);
    } catch (h) {
      alert(h instanceof ApiHatasi ? h.message : String(h));
    }
  }

  return (
    <>
    <GenGrid
      // key: kaynak degisince (baska liste ekranina gecince) GenGrid TAMAMEN yeniden
      //   kurulsun - Route ayni tree konumunda kaldigi icin React bilesen orneğini
      //   REUSE ediyordu, onceki ekranin state'i (aramaGorunumu, sirala, arama, sayfa...)
      //   yeni ekrana sizip yanlis/bos sonuc gosteriyordu (ör. Cari'de "Son Aranan"
      //   secilince Islem Gunlugu'ne gecince orada da "son" gonderiliyordu).
      key={tanim.rota ?? tanim.kaynak}
      kaynak={tanim.kaynak}
      baslik={tanim.baslik}
      yol={tanim.yol}
      toplam={tanim.toplam}
      cipler={tanim.cipler}
      sabitFiltre={sabitFiltre}
      aksiyonEkrani={tanim.aksiyonEkrani}
      yenile={yenile}
      odaklaSonEklenen={odaklaSonEklenen}
      icerikAlani={tanim.icerikAlani}
      icerikBaslik={tanim.icerikBaslik}
      onSatirAc={satir => {
        // Belge listelerinde kart MODAL acilir (rota yok); digerlerinde kartYolu.
        if (tanim.kaynak === 'belge') setAcikBelgeId(Number(satir.id));
        else if (tanim.kartYolu) git(`${tanim.kartYolu}/${satir.id}`);
      }}
      onAksiyon={(kod, satir) => { void aksiyon(kod, satir) }}
    />

    {acikBelgeId !== null && (
      <BelgeKarti id={acikBelgeId} onKapat={() => setAcikBelgeId(null)} />
    )}

    {yeniBelgeTuru !== null && (
      <BelgeKarti
        tur={yeniBelgeTuru}
        onKapat={() => setYeniBelgeTuru(null)}
        onKaydedildi={() => setYenile(t => t + 1)}
      />
    )}

    {donusum && (
      <BelgeDonusumModali
        belgeId={donusum.belgeId}
        belgeTur={donusum.belgeTur}
        onKapat={() => setDonusum(null)}
        // Modal KAPANMAZ: sonucu (yeni belge no + tutar) kendi icinde gosterir.
        //   alert() kullanmak tarayici diyalogu acar ve sayfayi kilitler.
        onTamam={() => setYenile(t => t + 1)}
      />
    )}

    {kartId !== null && tanim.kartYolu && !tanim.ozelKart && (
      <GenForm
        kaynak={tanim.kaynak}
        id={kartId}
        baslik={tanim.baslik.replace(/ler$|lar$/, '')}
        yerTutucuSekmeler={tanim.yerTutucuSekmeler}
        resimYerTutucu={tanim.resimYerTutucu}
        yeniKayitVarsayilanlari={tanim.yeniKayitVarsayilanlari}
        onKapat={() => git(tanim.kartYolu!)}
        onKaydedildi={yeniId => {
          setYenile(t => t + 1);
          if (kartId === 'yeni') {
            setOdaklaSonEklenen(t => t + 1);
            git(`${tanim.kartYolu}/${yeniId}`, { replace: true });
          }
        }}
      />
    )}
    </>
  );
}

const DURUM_CIPLERI: ListeTanimi['cipler'] = [
  { ad: 'Aktif', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
  { ad: 'Pasif', filtre: { alan: 'durum', op: 'esit', deger: 0 } },
  { ad: 'Tumu' },
];

/** Menu + rota kaynagi. Yetki sunucudan gelir; burada yalnizca ekran tanimi var.
    menuGrup verilirse Kabuk.tsx'te ayni gruptaki ogeler "Cari" gibi acilir-kapanir bir
    ana menu altinda TOPLANIR. */
export const LISTELER: (ListeTanimi & { menuAd: string; ic: string; yetkiKodu: string; menuGrup?: string })[] = [
  {
    // Tek ogeli grup (kullanici: "Cari menu ustune Hasta menusu ac, altina Hasta
    // Listesi ekle") - Cari grubunun HEMEN USTUNDE, ayni acilir-kapanir desende.
    kaynak: 'hasta', baslik: 'Hastalar', yol: 'Hasta › Hastalar', kartYolu: '/hasta',
    aksiyonEkrani: 'hasta-liste', cipler: DURUM_CIPLERI,
    menuGrup: 'Hasta', menuAd: 'Hasta Listesi', ic: '🏥', yetkiKodu: 'personel',
  },
  {
    // Kaynak id, API route ve yetki kodu 'cari' KALDI - Musteri Listesi kendi URL'ini
    // ('/cari') korur (eski link/rota kirilmasin); Tedarikci Listesi asagida AYNI
    // kaynagi farkli `rota` ile kullanir. Ekran artik SADECE musteri=1 gosterir
    // (sabitFiltre) - Tedarikci Listesi ayrildigi icin "ikisi birden" gorunumu gerekmiyor.
    kaynak: 'cari', baslik: 'Müşteriler', yol: 'Cari › Müşteriler', kartYolu: '/cari',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    sabitFiltre: { alan: 'musteri', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { musteri: true, tedarikci: false },
    // Mockup'ta (cari_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    yerTutucuSekmeler: ['Mali Durum', 'Banka / IBAN', 'Yorum / Medya', 'Ekstre', 'Ek Alanlar'],
    menuGrup: 'Cari', menuAd: 'Müşteri Listesi', ic: '👥', yetkiKodu: 'cari',
  },
  {
    // Musteri Listesi'nin BIREBIR kopyasi (kullanici istegi) - ayni kaynak ('cari'),
    // ayni kart, farkli `rota`/kartYolu ('/tedarikci') + ters sabitFiltre.
    kaynak: 'cari', rota: 'tedarikci', baslik: 'Tedarikçiler', yol: 'Cari › Tedarikçiler',
    kartYolu: '/tedarikci',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    sabitFiltre: { alan: 'tedarikci', op: 'esit', deger: 1 },
    yeniKayitVarsayilanlari: { musteri: false, tedarikci: true },
    yerTutucuSekmeler: ['Mali Durum', 'Banka / IBAN', 'Yorum / Medya', 'Ekstre', 'Ek Alanlar'],
    menuGrup: 'Cari', menuAd: 'Tedarikçi Listesi', ic: '🚚', yetkiKodu: 'cari',
  },
  {
    // kisi_listesi.html mockup - kullanici "sade grid olsun, altta sekme yanda bilgi
    // olmasin" dedi; GenGrid zaten duz grid (mockup'taki sag "Secili Kisi" paneli hic
    // yapilmadi, ozel bir "sadelestirme" gerekmedi).
    kaynak: 'kisi', baslik: 'Kisiler', yol: 'Cari › Kisiler', kartYolu: '/kisi',
    aksiyonEkrani: 'kisi-liste', cipler: DURUM_CIPLERI,
    menuGrup: 'Cari', menuAd: 'Kişi Listesi', ic: '🧑', yetkiKodu: 'cari',
  },
  {
    // "Satış" grubu, Cari'nin HEMEN ALTINDA (kullanici istegi) - "Belgeler" ayni kaynak/
    // ekran, sadece grup+menu adi degisti (filtre/kapsam AYNI - hala hem satis hem alis
    // faturalarini gosterir, cip'lerle (Tumu/Satis/Alis) secilir; "kopyala" DENMEDI).
    kaynak: 'belge', baslik: 'Belgeler', yol: 'Satis › Faturalar',
    aksiyonEkrani: 'belge-liste',
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Satis', filtre: { alan: 'tur', op: 'icinde', deger: [14, 15, 16] } },
      { ad: 'Alis', filtre: { alan: 'tur', op: 'icinde', deger: [10, 11, 12] } },
    ],
    menuGrup: 'Satış', menuAd: 'Satış Fatura Listesi', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    // Siparisler AYNI 'belge' kaynagi, tur in (9,19) sabit filtresiyle (Musteri/
    //   Tedarikci deseni). "Kalan" takibi belge_satir.kapatilan_miktar uzerinden;
    //   "Dönüştür" aksiyonu secili siparisten irsaliye/fatura uretir (F8).
    kaynak: 'belge', rota: 'siparis', baslik: 'Siparişler', yol: 'Satis › Siparisler',
    aksiyonEkrani: 'siparis-liste', yeniBelgeTuru: 19,
    sabitFiltre: { alan: 'tur', op: 'icinde', deger: [9, 19] },
    toplam: ['genelToplam'],
    cipler: [
      { ad: 'Açık',    filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 0 } },
      { ad: 'Kısmi',   filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 1 } },
      { ad: 'Kapanan', filtre: { alan: 'kapanmaDurum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Satış', menuAd: 'Siparişler', ic: '📋', yetkiKodu: 'belge',
  },
  {
    // "Hangi siparisin nesi teslim edilmedi" - satir bazli acik liste.
    kaynak: 'belge-acik-satir', baslik: 'Açık Sipariş Satırları', yol: 'Satis › Acik Satirlar',
    toplam: ['miktar', 'kapatilanMiktar', 'kalanMiktar'],
    menuGrup: 'Satış', menuAd: 'Açık Satırlar', ic: '📑', yetkiKodu: 'belge',
  },
  {
    // Kasa alt sisteminin ANA ekrani (F2): makbuz seviyesindeki islemler.
    //   Karti generic GenForm degil, kendi sayfasi (KasaIslemKarti) - tur sablonu,
    //   bacaklar ve muhasebe fisi paneli generic karta sigmiyor.
    kaynak: 'kasa-islem', baslik: 'Kasa İşlemleri', yol: 'Kasa › İşlemler',
    kartYolu: '/kasa-islem', ozelKart: true, aksiyonEkrani: 'kasa-liste',
    toplam: ['yerelTutar'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Tahsilat', filtre: { alan: 'turGrup', op: 'esit', deger: 'tahsilat' } },
      { ad: 'Ödeme',    filtre: { alan: 'turGrup', op: 'esit', deger: 'odeme' } },
      { ad: 'Taslak',   filtre: { alan: 'durum', op: 'esit', deger: 0 } },
      { ad: 'Plan',     filtre: { alan: 'durum', op: 'esit', deger: 1 } },
    ],
    menuGrup: 'Kasa', menuAd: 'Kasa İşlemleri', ic: '🧾', yetkiKodu: 'kasa_islem',
  },
  {
    // Acik planlar (v_plan_vade): beklenen tahsilat/odemeler, en yakin vade ustte.
    //   "Gerceklestir" plan kaydini DEGISTIRMEZ - yeni bir islem acar (K10).
    kaynak: 'plan-vade', baslik: 'Vade / Planlar', yol: 'Kasa › Vadeler',
    kartYolu: '/kasa-islem', ozelKart: true, aksiyonEkrani: 'plan-liste',
    toplam: ['tutar', 'gerceklesenTutar', 'kalanTutar'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Vadesi Geçmiş', filtre: { alan: 'gecikmeGun', op: 'buyuk', deger: 0 } },
      { ad: 'Tahsilat', filtre: { alan: 'turAdi', op: 'icerir', deger: 'Tahsilat' } },
      { ad: 'Ödeme',    filtre: { alan: 'turAdi', op: 'icerir', deger: 'Ödeme' } },
    ],
    menuGrup: 'Kasa', menuAd: 'Vade / Planlar', ic: '📅', yetkiKodu: 'kasa_islem',
  },
  {
    // "Kasa" grubu, Satış'in HEMEN ALTINDA (kullanici istegi) - "Cari Hareketleri"
    // (mali-hareket) yeniden adlandirildi: hem sayfa basligi hem menu adi "Kasa
    // Hareketleri" oldu (Satış'in aksine kullanici burada baslik metnini ACIKCA verdi).
    kaynak: 'mali-hareket', baslik: 'Kasa Hareketleri', yol: 'Kasa › Hareketler',
    toplam: ['borc', 'alacak'],
    menuGrup: 'Kasa', menuAd: 'Kasa Hareketleri', ic: '💰', yetkiKodu: 'mali_hareket',
  },
  // --- Hesaplar: TEK kaynak ('hesap'), tur'e gore 5 ayri ekran. Musteri/Tedarikci
  //     deseninin aynisi: sabitFiltre + rota + yeniKayitVarsayilanlari.
  {
    kaynak: 'hesap', rota: 'kasa-hesap', baslik: 'Kasalar', yol: 'Kasa › Kasa Hesaplari',
    kartYolu: '/kasa-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'K' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Kasa', menuAd: 'Kasa Hesapları', ic: '💵', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'banka-hesap', baslik: 'Banka Hesapları', yol: 'Kasa › Banka Hesaplari',
    kartYolu: '/banka-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'B' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Kasa', menuAd: 'Banka Hesapları', ic: '🏦', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'pos-hesap', baslik: 'POS Hesapları', yol: 'Kasa › POS',
    kartYolu: '/pos-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'P' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Kasa', menuAd: 'POS', ic: '💳', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'kredi-karti', baslik: 'Kredi Kartları', yol: 'Kasa › Kredi Kartlari',
    kartYolu: '/kredi-karti', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'V' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Kasa', menuAd: 'Kredi Kartları', ic: '💳', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'hesap', rota: 'kredi-hesap', baslik: 'Krediler', yol: 'Kasa › Krediler',
    kartYolu: '/kredi-hesap', sabitFiltre: { alan: 'tur', op: 'esit', deger: 'R' },
    toplam: ['yerelBakiye'],
    menuGrup: 'Kasa', menuAd: 'Krediler', ic: '🏛️', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'cek-senet', baslik: 'Çek / Senet', yol: 'Kasa › Cek ve Senet', kartYolu: '/cek-senet',
    toplam: ['tutar'],
    cipler: [
      { ad: 'Portföy', filtre: { alan: 'durum', op: 'esit', deger: 10 } },
      { ad: 'Tahsilde', filtre: { alan: 'durum', op: 'esit', deger: 30 } },
      { ad: 'Kapanan', filtre: { alan: 'durum', op: 'icinde', deger: [50, 70] } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Kasa', menuAd: 'Çek / Senet', ic: '📃', yetkiKodu: 'cek_senet',
  },
  {
    // Yuruyen bakiyeli ekstre: hesap secimi URL'den gelir (?hesapId=), grid
    //   sabit tarih sirasinda kalir (bakiye kolonu siralanamaz - sunucu tarafi).
    kaynak: 'hesap-ekstre', baslik: 'Hesap Ekstresi', yol: 'Kasa › Hesap Ekstresi',
    urlFiltreAlani: 'hesapId', toplam: ['giris', 'cikis'],
    menuGrup: 'Kasa', menuAd: 'Hesap Ekstresi', ic: '📈', yetkiKodu: 'hesap',
  },
  {
    kaynak: 'cari-ekstre', baslik: 'Cari Ekstre', yol: 'Kasa › Cari Ekstre',
    urlFiltreAlani: 'tarafId', toplam: ['yerelBorc', 'yerelAlacak'],
    menuGrup: 'Kasa', menuAd: 'Cari Ekstre', ic: '🧮', yetkiKodu: 'mali_hareket',
  },
  {
    // Kullanici: "Kasa altına Hizmet Listesi ve Masraf Listesi'ı taşı".
    kaynak: 'hizmet', baslik: 'Hizmetler', yol: 'Stok › Hizmetler', cipler: DURUM_CIPLERI,
    menuGrup: 'Kasa', menuAd: 'Hizmet Listesi', ic: '🛠️', yetkiKodu: 'hizmet',
  },
  {
    kaynak: 'masraf', baslik: 'Masraflar', yol: 'Stok › Masraflar', cipler: DURUM_CIPLERI,
    menuGrup: 'Kasa', menuAd: 'Masraf Listesi', ic: '🧾', yetkiKodu: 'masraf',
  },
  {
    kaynak: 'proje', baslik: 'Projeler', yol: 'Proje › Projeler', kartYolu: '/proje',
    cipler: [
      { ad: 'Açık',       filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tamamlanan', filtre: { alan: 'durum', op: 'esit', deger: 2 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Proje', menuAd: 'Projeler', ic: '📁', yetkiKodu: 'proje',
  },
  {
    // Kullanici: "Stok altına Stok Listesi [taşı]" - tek ogeli grup, digerleriyle ayni desen.
    kaynak: 'stok', baslik: 'Stoklar', yol: 'Stok › Stok Karti', kartYolu: '/stok',
    aksiyonEkrani: 'stok-liste', cipler: DURUM_CIPLERI,
    // Mockup'ta (stok_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    //   Stok Durumu icin gercek tablo (stok_durum) var ama PK'si (stok_id,depo_id) -
    //   detay tablosu id kolonu varsayar, o yuzden bu da simdilik yer tutucu.
    yerTutucuSekmeler: ['ÜTS Bilgileri', 'Reçete', 'Stok Durumu', 'Hareketler', 'Yorum / Medya', 'Ek Alanlar'],
    resimYerTutucu: true,
    menuGrup: 'Stok', menuAd: 'Stok Listesi', ic: '📦', yetkiKodu: 'stok',
  },
  {
    // Kullanici: "İK altına Personel Listesi taşı" - tek ogeli grup, digerleriyle ayni desen.
    kaynak: 'personel', baslik: 'Personel', yol: 'IK › Personel', kartYolu: '/personel',
    aksiyonEkrani: 'personel-liste', cipler: DURUM_CIPLERI,
    menuGrup: 'İK', menuAd: 'Personel Listesi', ic: '🪪', yetkiKodu: 'personel',
  },
  {
    // Kullanici: "e-Belge'yi de bir Yönetim altına".
    kaynak: 'e-belge', baslik: 'e-Belge Kuyrugu', yol: 'e-Belge › Kuyruk',
    menuGrup: 'Yönetim', menuAd: 'e-Belge', ic: '📨', yetkiKodu: 'e_belge',
  },
  {
    // Kullanici: "Yönetim altına Roller ve İşlem Günlüğü al".
    kaynak: 'islem-log', baslik: 'Islem Gunlugu', yol: 'Yonetim › Islem Gunlugu',
    icerikAlani: 'bilgi', icerikBaslik: 'Log İçeriği',
    menuGrup: 'Yönetim', menuAd: 'İşlem Günlüğü', ic: '📋', yetkiKodu: 'islem_log',
  },
  {
    // Muhasebe fisleri: kasa islemi/belge kesinlestikce OTOMATIK uretilir; buradan
    //   yalniz izlenir (elle fis girisi F4/F7 kapsaminda degil).
    kaynak: 'muhasebe-fis', baslik: 'Muhasebe Fişleri', yol: 'Yonetim › Muhasebe Fisleri',
    aksiyonEkrani: 'fis-liste', toplam: ['toplamBorc', 'toplamAlacak'],
    cipler: [
      { ad: 'Kayıtlı', filtre: { alan: 'durum', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Yönetim', menuAd: 'Muhasebe Fişleri', ic: '📕', yetkiKodu: 'muhasebe_fis',
  },
  {
    kaynak: 'muhasebe-fis-satir', baslik: 'Fiş Satırları', yol: 'Yonetim › Fis Satirlari',
    toplam: ['borc', 'alacak'],
    menuGrup: 'Yönetim', menuAd: 'Fiş Satırları', ic: '📗', yetkiKodu: 'muhasebe_fis',
  },
  {
    kaynak: 'hesap-plani', baslik: 'Hesap Planı', yol: 'Yonetim › Hesap Plani',
    kartYolu: '/hesap-plani',
    cipler: [
      { ad: 'Çalışan', filtre: { alan: 'calisirMi', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Yönetim', menuAd: 'Hesap Planı', ic: '📒', yetkiKodu: 'hesap_plani',
  },
  {
    kaynak: 'masraf-merkezi', baslik: 'Masraf Merkezleri', yol: 'Yonetim › Masraf Merkezleri',
    kartYolu: '/masraf-merkezi', cipler: DURUM_CIPLERI,
    menuGrup: 'Yönetim', menuAd: 'Masraf Merkezleri', ic: '🏷️', yetkiKodu: 'masraf_merkezi',
  },
  {
    // Islem turu katalogu: kasa hareketlerinin ekstre/fis davranisini VERI olarak
    //   tasir (bkz. 073). Salt gorunum - duzenleme yonetici isi, kart yok.
    kaynak: 'kasa-islem-turu', baslik: 'İşlem Türleri', yol: 'Yonetim › Islem Turleri',
    cipler: [
      { ad: 'Aktif', filtre: { alan: 'aktif', op: 'esit', deger: 1 } },
      { ad: 'Tumu' },
    ],
    menuGrup: 'Yönetim', menuAd: 'İşlem Türleri', ic: '⚙️', yetkiKodu: 'kasa_islem_turu',
  },
  {
    // Rol'un durum kolonu "durum" degil "aktif" - DURUM_CIPLERI (alan:'durum') buraya
    //   UYMAZ, kullanilmadi (yoksa "Bilinmeyen alan: durum" 400 verirdi).
    kaynak: 'rol', baslik: 'Roller', yol: 'Yonetim › Roller ve Yetkiler', kartYolu: '/rol',
    aksiyonEkrani: 'rol-liste',
    menuGrup: 'Yönetim', menuAd: 'Roller', ic: '🛡️', yetkiKodu: 'rol',
  },
];
