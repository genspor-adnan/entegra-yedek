import type { KartAlanMeta, KartDetayMeta, KartMetaYaniti, DovizMetasi } from '../api/sozlesme';
import type { Deger } from './kartAlanCizim';

export type SekmeTanimi =
  | { tur: 'grup'; anahtar: string; baslik: string; alanlar: KartAlanMeta[] }
  | { tur: 'detay'; anahtar: string; baslik: string; detay: KartDetayMeta }
  | { tur: 'yerTutucu'; anahtar: string; baslik: string }
  // Generic Detay mekanizmasina uymayan kaynaga-ozel sekmeler (ör. Rol > Yetki Matrisi).
  | { tur: 'ozel'; anahtar: string; baslik: string };

export const detaySekmeAnahtari = (detayAd: string) => `d:${detayAd}`;
export const grupSekmeAnahtari = (grupAd: string) => `g:${grupAd}`;

/** Sekme DEGIL, ust seritte sabit gorunen grup (mockup idstrip). */
export const KIMLIK_GRUP = 'Kimlik';

// Az alanli ayar kartlari: alanlar yan yana degil ALT ALTA (tek sutun) - 4-5 alan
//   genis izgaraya yayilinca form dagilmis gorunuyor, sira da okunmuyordu.
export const TEK_SUTUN_KARTLAR = new Set(['depo']);

/**
 * KART SEKMELERI - hangi alan hangi gruba, hangi grup/detay hangi sekmeye.
 *
 * Iki SAF fonksiyon: girdi katalog metasi + ekran secenekleri, cikti sekme
 * listesi. GenForm bunlari useMemo icinde cagirir; kart govdesinde durmalarinin
 * tek sonucu 110 satirlik bir okuma engeliydi.
 */
export function alanGruplari(meta: KartMetaYaniti | null, secenek: {
  doviz?: DovizMetasi | null;
  yerelParada: boolean;
  gizliAlanlar?: string[];
}): [string, KartAlanMeta[]][] {
  const { doviz, yerelParada, gizliAlanlar } = secenek;
  const harita = new Map<string, KartAlanMeta[]>();
  meta?.alanlar.forEach(a => {
    if (a.ad === 'id') return;
    // ARKA PLAN alani: degeri tasinir (kaydetmede gonderilir) ama CIZILMEZ.
    if (a.gizli) return;
    // Yerel parada Kur (hep 1) ve Yerel Tutar (= Tutar) alanlari GORUNMEZ -
    //   tekrar bilgi, formu uzatmaktan baska ise yaramaz.
    if (yerelParada && doviz && (a.ad === doviz.kurAlani || a.ad === doviz.yerelAlani)) return;
    // Ekrana ozel gizleme (ör. Aday kartinda "Kod"): alan katalogda kalir,
    //   degeri tasinir, yalniz CIZILMEZ.
    if (gizliAlanlar?.includes(a.ad)) return;
    const g = a.grup ?? 'Genel';
    harita.set(g, [...(harita.get(g) ?? []), a]);
  });
  return [...harita.entries()];
}

export function sekmeleriKur(secenek: {
  gruplar: [string, KartAlanMeta[]][];
  meta: KartMetaYaniti | null;
  kaynak: string;
  deger: Record<string, Deger>;
  yeniMi: boolean;
  personelGibiKart: boolean;
  yerTutucuSekmeler?: string[];
  gizliSekmeler?: string[];
}): SekmeTanimi[] {
  const { gruplar, meta, kaynak, deger, yeniMi, personelGibiKart,
          yerTutucuSekmeler, gizliSekmeler } = secenek;
  const dokumanliKart = personelGibiKart || kaynak === 'kisi' || kaynak === 'cari' || kaynak === 'stok';
  const yorumMedyaSekmesiVar = (yerTutucuSekmeler ?? []).includes('Yorum / Medya');
  const s: SekmeTanimi[] = gruplar
    .filter(([ad]) => ad !== KIMLIK_GRUP)
    // Ekrana ozel sekme gizleme (ör. Aday kartinda "Fatura Bilgileri").
    .filter(([ad]) => !gizliSekmeler?.includes(ad))
    .filter(([ad]) => !(kaynak === 'hasta' && ad === 'İletişim'))
    .map(([ad, alanlar]) => ({ tur: 'grup', anahtar: grupSekmeAnahtari(ad), baslik: ad, alanlar }));
  if (kaynak === 'cari' || kaynak === 'hasta') {
    const genel = s.findIndex(sekme => sekme.tur === 'grup' && sekme.baslik === 'Genel');
    const fatura = s.findIndex(sekme => sekme.tur === 'grup' && sekme.baslik === 'Fatura Bilgileri');
    if (genel >= 0 && fatura >= 0 && fatura !== genel + 1) {
      const [sekme] = s.splice(fatura, 1);
      const yeniGenel = s.findIndex(x => x.tur === 'grup' && x.baslik === 'Genel');
      s.splice(yeniGenel + 1, 0, sekme);
    }
  }
  meta?.detaylar.forEach(d => {
    // KOSULLU sekme (ör. stok "Paket"): ilgili kutu isaretli degilse sekme
    //   hic acilmaz - bos sekme "burada doldurulacak bir sey var" izlenimi
    //   verir. Kutu isaretlenince ANINDA gorunur (deger state'i degisir).
    if (d.kosulAlani && !deger[d.kosulAlani]) return;
    // Cari/Kisi/Personel'e ozel: Adresler mockup'ta ayri sekme DEGIL, ilgili grup
    //   sekmesinin icine gomulu bir tek-satir form - kendi sekmesi acilmasin (bkz.
    //   asagida grup render'i - Personel'de İletişim sekmesine gomulu, ik_karti.html).
    if ((kaynak === 'cari' || kaynak === 'kisi' || personelGibiKart) && d.ad === 'adresler') return;
    // Personel'de Eğitim/Sertifika artık Genel sekmesinde Kimlik Bilgileri'nin altında
    //   gömülü grid; ayrı sekme açılmasın.
    if (personelGibiKart && d.ad === 'egitimler') return;
    // Hasta'da kimlik/hasta bilgisi Genel sekmesindeki özetin içinde kalır; izinler
    // hasta kartında kullanılmaz, ayrı sekme olarak gösterilmez.
    if (kaynak === 'hasta' && (d.ad === 'ozluk' || d.ad === 'izinler')) return;
    // Personel'de acil kişiler ik_karti.html mockup'ta İletişim sekmesinin altında
    // gömülü grid; ayrı sekme açılmasın.
    if (personelGibiKart && d.ad === 'acilKisiler') return;
    s.push({ tur: 'detay', anahtar: detaySekmeAnahtari(d.ad), baslik: d.baslik, detay: d });
  });
  (yerTutucuSekmeler ?? []).forEach(baslik => {
    if (dokumanliKart && !yeniMi && baslik === 'Yorum / Medya') {
      s.push({ tur: 'ozel', anahtar: 'ozel:dokuman', baslik: 'Resim / Doküman' });
    } else if (kaynak === 'stok' && !yeniMi && baslik === 'Hareketler') {
      // Salt okunur hareket dokumu (stok_karti.html "Hareketler").
      s.push({ tur: 'ozel', anahtar: 'ozel:stokHareket', baslik });
    } else if (kaynak === 'stok' && !yeniMi && baslik === 'Stok Durumu') {
      // Artik yer tutucu degil: depo bazli miktar/rezerve gercek veriden gelir
      //   (stok_karti.html "Stok Durumu"). Yeni kayitta stok_id yok - kart once
      //   kaydedilmeli, o yuzden yeniMi'de yer tutucu olarak kalir.
      s.push({ tur: 'ozel', anahtar: 'ozel:stokDurum', baslik });
    } else {
      s.push({ tur: 'yerTutucu', anahtar: `y:${baslik}`, baslik });
    }
  });
  // Rol'e ozel: Yetki Matrisi generic Detay degil (satir ekle/sil yok, sabit yetki
  //   listesi x Gor/Ekle/Degistir/Sil checkbox'lari) - ayri "ozel" sekme. Yeni kayitta
  //   henuz rolId yok, kart once kaydedilmeli (Kisi'nin İlgili Kişiler'iyle ayni kural).
  if (kaynak === 'rol' && !yeniMi) {
    s.push({ tur: 'ozel', anahtar: 'ozel:yetkiler', baslik: 'Yetki Matrisi' });
  }
  // Personel'e ozel: Resim/Doküman galerisi (057_dokuman.sql, generic DokumanGalerisi -
  // Kişi/Cari/Stok'ta da aynı bileşen kullanılabilir). Yeni kayıtta henüz id yok.
  if (dokumanliKart && !yeniMi && !yorumMedyaSekmesiVar) {
    s.push({ tur: 'ozel', anahtar: 'ozel:dokuman', baslik: 'Resim / Doküman' });
  }
  return s;
}
