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

  return (
    <>
    <GenGrid
      kaynak={tanim.kaynak}
      baslik={tanim.baslik}
      yol={tanim.yol}
      toplam={tanim.toplam}
      cipler={tanim.cipler}
      aksiyonEkrani={tanim.aksiyonEkrani}
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
        onKapat={() => git(tanim.kartYolu!)}
        onKaydedildi={yeniId => { if (kartId === 'yeni') git(`${tanim.kartYolu}/${yeniId}`, { replace: true }) }}
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

/** Menu + rota kaynagi. Yetki sunucudan gelir; burada yalnizca ekran tanimi var. */
export const LISTELER: (ListeTanimi & { menuAd: string; ic: string; yetkiKodu: string })[] = [
  {
    kaynak: 'cari', baslik: 'Cariler', yol: 'Cari › Musteriler', kartYolu: '/cari',
    aksiyonEkrani: 'cari-liste', cipler: DURUM_CIPLERI,
    // Mockup'ta (cari_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    yerTutucuSekmeler: ['Mali Durum', 'Banka / IBAN', 'Yorum / Medya', 'Ekstre', 'Ek Alanlar'],
    menuAd: 'Cari', ic: '👥', yetkiKodu: 'cari',
  },
  {
    // kisi_listesi.html mockup - kullanici "sade grid olsun, altta sekme yanda bilgi
    // olmasin" dedi; GenGrid zaten duz grid (mockup'taki sag "Secili Kisi" paneli hic
    // yapilmadi, ozel bir "sadelestirme" gerekmedi).
    kaynak: 'kisi', baslik: 'Kisiler', yol: 'Cari › Kisiler', kartYolu: '/kisi',
    aksiyonEkrani: 'kisi-liste', cipler: DURUM_CIPLERI,
    menuAd: 'Kisiler', ic: '🧑', yetkiKodu: 'cari',
  },
  {
    kaynak: 'stok', baslik: 'Stoklar', yol: 'Stok › Stok Karti', kartYolu: '/stok',
    aksiyonEkrani: 'stok-liste', cipler: DURUM_CIPLERI,
    // Mockup'ta (stok_karti.html) var ama backend'i henuz yok - "yakinda" gorunur.
    //   Stok Durumu icin gercek tablo (stok_durum) var ama PK'si (stok_id,depo_id) -
    //   detay tablosu id kolonu varsayar, o yuzden bu da simdilik yer tutucu.
    yerTutucuSekmeler: ['ÜTS Bilgileri', 'Reçete', 'Stok Durumu', 'Hareketler', 'Yorum / Medya', 'Ek Alanlar'],
    resimYerTutucu: true,
    menuAd: 'Stok', ic: '📦', yetkiKodu: 'stok',
  },
  {
    kaynak: 'belge', baslik: 'Belgeler', yol: 'Satis › Faturalar',
    aksiyonEkrani: 'belge-liste',
    toplam: ['matrah', 'kdvTutari', 'genelToplam'],
    cipler: [
      { ad: 'Tumu' },
      { ad: 'Satis', filtre: { alan: 'tur', op: 'icinde', deger: [14, 15, 16] } },
      { ad: 'Alis', filtre: { alan: 'tur', op: 'icinde', deger: [10, 11, 12] } },
    ],
    menuAd: 'Belgeler', ic: '🧾', yetkiKodu: 'belge',
  },
  {
    kaynak: 'mali-hareket', baslik: 'Cari Hareketleri', yol: 'Mali › Hareketler',
    toplam: ['borc', 'alacak'],
    menuAd: 'Hareketler', ic: '💰', yetkiKodu: 'mali_hareket',
  },
  {
    kaynak: 'hizmet', baslik: 'Hizmetler', yol: 'Stok › Hizmetler', cipler: DURUM_CIPLERI,
    menuAd: 'Hizmet', ic: '🛠️', yetkiKodu: 'hizmet',
  },
  {
    kaynak: 'masraf', baslik: 'Masraflar', yol: 'Stok › Masraflar', cipler: DURUM_CIPLERI,
    menuAd: 'Masraf', ic: '🧾', yetkiKodu: 'masraf',
  },
  {
    kaynak: 'personel', baslik: 'Personel', yol: 'IK › Personel', cipler: DURUM_CIPLERI,
    menuAd: 'Personel', ic: '🪪', yetkiKodu: 'personel',
  },
  {
    kaynak: 'e-belge', baslik: 'e-Belge Kuyrugu', yol: 'e-Belge › Kuyruk',
    menuAd: 'e-Belge', ic: '📨', yetkiKodu: 'e_belge',
  },
  {
    kaynak: 'islem-log', baslik: 'Islem Gunlugu', yol: 'Yonetim › Islem Gunlugu',
    menuAd: 'Islem Gunlugu', ic: '📋', yetkiKodu: 'islem_log',
  },
];
