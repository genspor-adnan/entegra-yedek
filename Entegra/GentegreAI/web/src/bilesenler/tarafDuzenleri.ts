import { AKTIF_KOSULU, cariCipleri, cariSatirSinifi } from './cariArama';
import { CariBasliklar, CariEkDugmeler, CariHucreler, CariOnizleme } from './TarafAramaCari';
import { KisiBasliklar, KisiHucreler, KisiOnizleme } from './TarafAramaKisi';
import { PersonelBasliklar, PersonelHucreler, PersonelOnizleme } from './TarafAramaPersonel';
import { type TarafDuzeni, sayiya } from './tarafDuzeni';

/**
 * KAYNAK → DÜZEN (bkz. tarafDuzeni.ts). Yalnız TEK kaynaklı aramada uygulanır; karma aramada (cari + personel)
 * TarafArama'nın genel taraf düzeni kalır. Hasta / dış hekim / başvuru hekimi düzenleri henüz bu çatıda değil.
 */
export const TARAF_DUZENLERI: Record<string, TarafDuzeni> = {
  cari: {
    genislik: 'min(1280px, 96vw)',
    sabitKosul: AKTIF_KOSULU,
    cipler: cariCipleri,
    secimler: [{ alan: 'il', etiket: 'İl' }, { alan: 'temsilci', etiket: 'Temsilci' }],
    // İlgili kişi, fatura ünvanı ve il de aranır; vergi / kimlik no ARANMAZ (kullanıcı 05.11.2026).
    ekArama: ['ilgiliKisi', 'faturaUnvan', 'il'],
    kolonSayisi: 14,
    yeniEtiketi: b => b.tedarikci ? '＋ Yeni Tedarikçi' : b.musteri ? '＋ Yeni Müşteri' : '＋ Yeni Cari',
    Basliklar: CariBasliklar,
    Hucreler: CariHucreler,
    Onizleme: CariOnizleme,
    EkDugmeler: CariEkDugmeler,
    satirSinifi: cariSatirSinifi,
    lejant: [{ renk: '#f7cfcf', ad: 'risk aşıldı' }, { renk: '#f6d9c0', ad: 'vadesi geçen' }, { renk: '#e4e7eb', ad: 'aday' }],
  },
  personel: {
    genislik: 'min(1180px, 96vw)',
    sabitKosul: AKTIF_KOSULU,
    cipler: () => [
      { kod: 'izinde',   ad: 'İzinde',            kosul: { alan: 'bugunKod', op: 'esit', deger: 2 } },
      { kod: 'raporlu',  ad: 'Raporlu',           kosul: { alan: 'bugunKod', op: 'esit', deger: 3 } },
      { kod: 'deneme',   ad: 'Deneme süresinde',  kosul: { alan: 'bugunKod', op: 'esit', deger: 4 } },
      { kod: 'talep',    ad: 'Onayda talep',      ipucu: 'Onay bekleyen izin / avans / masraf / belge talebi',
        kosul: { alan: 'onaydaTalep', op: 'buyuk', deger: 0 } },
      { kod: 'eksik',    ad: 'Eksik bilgi',       kosul: { alan: 'eksik', op: 'bosDegil' } },
      { kod: 'dogum',    ad: 'Doğum günü bu ay',  kosul: { alan: 'dogumBuAy', op: 'esit', deger: 1 } },
    ],
    secimler: [{ alan: 'departmanAdi', etiket: 'Bölüm' }, { alan: 'rolAdi', etiket: 'Rol' }],
    // Rol / bölüm / görev / ham kimlik no (08.10.2026 isteği) TarafArama.KAYNAK_EK_ARAMA'da; burada ek yok.
    ekArama: [],
    kolonSayisi: 11,
    yeniEtiketi: () => '＋ Yeni Personel',
    Basliklar: PersonelBasliklar,
    Hucreler: PersonelHucreler,
    Onizleme: PersonelOnizleme,
    // Satır rengi: raporlu turuncu, izinde gri (lejant). bugunKod 963: 2 izinde · 3 raporlu.
    satirSinifi: s => { const k = sayiya(s.bugunKod); return k === 3 ? 's-vade' : k === 2 ? 's-gri' : '' },
    lejant: [{ renk: '#f6d9c0', ad: 'raporlu' }, { renk: '#e4e7eb', ad: 'izinde' }],
  },
  kisi: {
    genislik: 'min(1080px, 96vw)',
    sabitKosul: AKTIF_KOSULU,
    cipler: () => [],
    secimler: [{ alan: 'bagliCari', etiket: 'Bağlı cari' }, { alan: 'gorev', etiket: 'Görev' }],
    ekArama: ['bagliCari', 'gorev'],
    kolonSayisi: 8,
    yeniEtiketi: () => '＋ Yeni Kişi',
    Basliklar: KisiBasliklar,
    Hucreler: KisiHucreler,
    Onizleme: KisiOnizleme,
    satirSinifi: () => '',
    lejant: [],
  },
};
