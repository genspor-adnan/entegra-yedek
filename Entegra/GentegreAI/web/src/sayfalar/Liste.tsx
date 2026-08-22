import { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { GenGrid } from '../bilesenler/GenGrid';
import { GenForm } from '../bilesenler/GenForm';
import type { Kosul } from '../api/sozlesme';

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
}

/**
 * Tek bilesen tum liste ekranlarini karsilar. Kolonlar, filtreler ve yetki
 * sunucudan geldigi icin ekran basina kod yazmaya gerek yok — yeni bir liste
 * eklemek katalogda kaynak tanimlamak + burada bir satir demek.
 */
export function Liste({ tanim }: { tanim: ListeTanimi }) {
  const git = useNavigate();
  const { id } = useParams();

  // Kart MODAL acilir (mockup deseni): liste arkada kalir, URL yine /cari/4911.
  const kartId = id === undefined ? null : (id === 'yeni' ? 'yeni' as const : Number(id));

  // Kart kaydedilince (ekleme ya da duzenleme) grid'i yeniden yukletmek icin - GenForm
  //   onKaydedildi'de bir arttirilir, GenGrid bu degisimi izleyip yukle() cagirir.
  const [yenile, setYenile] = useState(0);
  // Yeni kart EKLENINCE (duzenlemede degil) grid "Son Aranan"a gecsin - kullanici
  //   az once ekledigi kaydi listede otomatik en ustte gorsun.
  const [odaklaSonEklenen, setOdaklaSonEklenen] = useState(0);

  return (
    <>
    <GenGrid
      // key: kaynak degisince (baska liste ekranina gecince) GenGrid TAMAMEN yeniden
      //   kurulsun - Route ayni tree konumunda kaldigi icin React bilesen orneğini
      //   REUSE ediyordu, onceki ekranin state'i (aramaGorunumu, sirala, arama, sayfa...)
      //   yeni ekrana sizip yanlis/bos sonuc gosteriyordu (ör. Cari'de "Son Aranan"
      //   secilince Islem Gunlugu'ne gecince orada da "son" gonderiliyordu).
      key={tanim.kaynak}
      kaynak={tanim.kaynak}
      baslik={tanim.baslik}
      yol={tanim.yol}
      toplam={tanim.toplam}
      cipler={tanim.cipler}
      sabitFiltre={tanim.sabitFiltre}
      aksiyonEkrani={tanim.aksiyonEkrani}
      yenile={yenile}
      odaklaSonEklenen={odaklaSonEklenen}
      icerikAlani={tanim.icerikAlani}
      icerikBaslik={tanim.icerikBaslik}
      onSatirAc={satir => { if (tanim.kartYolu) git(`${tanim.kartYolu}/${satir.id}`) }}
      onAksiyon={(kod, satir) => {
        if (kod.endsWith('.yeni') && tanim.kartYolu) git(`${tanim.kartYolu}/yeni`);
        else if (kod === 'belge.yeni') git('/belge/yeni');
        else if ((kod.endsWith('.duzenle') || kod.endsWith('.sil')) && satir && tanim.kartYolu)
          git(`${tanim.kartYolu}/${satir.id}`);
        else if (kod === 'genel.yazdir') alert('Yazdirma henuz baglanmadi.');
        else if (satir) alert(`"${kod}" aksiyonu henuz baglanmadi.`);
      }}
    />

    {kartId !== null && tanim.kartYolu && (
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
    // "Kasa" grubu, Satış'in HEMEN ALTINDA (kullanici istegi) - "Cari Hareketleri"
    // (mali-hareket) yeniden adlandirildi: hem sayfa basligi hem menu adi "Kasa
    // Hareketleri" oldu (Satış'in aksine kullanici burada baslik metnini ACIKCA verdi).
    kaynak: 'mali-hareket', baslik: 'Kasa Hareketleri', yol: 'Kasa › Hareketler',
    toplam: ['borc', 'alacak'],
    menuGrup: 'Kasa', menuAd: 'Kasa Hareketleri', ic: '💰', yetkiKodu: 'mali_hareket',
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
    kaynak: 'e-belge', baslik: 'e-Belge Kuyrugu', yol: 'e-Belge › Kuyruk',
    menuAd: 'e-Belge', ic: '📨', yetkiKodu: 'e_belge',
  },
  {
    // Kullanici: "Yönetim altına Roller ve İşlem Günlüğü al".
    kaynak: 'islem-log', baslik: 'Islem Gunlugu', yol: 'Yonetim › Islem Gunlugu',
    icerikAlani: 'bilgi', icerikBaslik: 'Log İçeriği',
    menuGrup: 'Yönetim', menuAd: 'İşlem Günlüğü', ic: '📋', yetkiKodu: 'islem_log',
  },
  {
    // Rol'un durum kolonu "durum" degil "aktif" - DURUM_CIPLERI (alan:'durum') buraya
    //   UYMAZ, kullanilmadi (yoksa "Bilinmeyen alan: durum" 400 verirdi).
    kaynak: 'rol', baslik: 'Roller', yol: 'Yonetim › Roller ve Yetkiler', kartYolu: '/rol',
    aksiyonEkrani: 'rol-liste',
    menuGrup: 'Yönetim', menuAd: 'Roller', ic: '🛡️', yetkiKodu: 'rol',
  },
];
