import { type ListeGirdisi } from './listeTanimlari.Ortak';

/**
 * PORTAL MALİ EKRANLARI (824) — anlaşmalı kurumun YÖNETİCİ rolü.
 *
 * Kullanıcı kararı: *"kurum kapsamı olsun, fatura satırında hasta adı
 * görünmesin"*. Kurum içi `belge` / `cari-ekstre` ekranları hasta adı,
 * doktor ve poliklinik taşıdığı için portala AÇILMADI; sunucuda dar kaynak
 * yazıldı (`KaynakKatalogu.Portal.cs`: `kurum-belge`, `kurum-ekstre`).
 *
 * Yetki `portal.mali` yalnız "Dış Kurum · Yönetici (portal)" rolünde:
 * - klinik rol (hasta gönderen doktor) bu iki ekranı GÖRMEZ,
 * - iç roller de görmez (mali işleri kendi ekranlarından yapar).
 *
 * `modul` verilmedi: mali ekran bir HBYS modülüne bağlı değil, kurum
 * profilinde "teleradyoloji" kapalı olsa da kurumun faturası durur.
 */
export const PORTAL_LISTELERI: ListeGirdisi[] = [
  {
    // FATURALAR: başlık düzeyi. Satır detayına (hizmet kalemleri) inilmiyor -
    //   kalemde hasta adı ve tetkik adı var; portalda cevabı aranan soru
    //   "ne kadar, ödendi mi".
    kaynak: 'kurum-belge', rota: 'kurum-belge', baslik: 'Faturalarım',
    yol: 'Portal › Faturalarım',
    cipler: [
      { ad: 'Açık', filtre: { alan: 'odemeDurum', op: 'esit', deger: 'Açık' } },
      { ad: 'Tümü' },
    ],
    menuAd: 'Faturalarım', ic: '🧾', menuSira: 60, yetkiKodu: 'portal.mali',
  },
  {
    // EKSTRE: borç/alacak/bakiye. `aciklama` kolonu kaynakta HİÇ YOK
    //   (başvuru faturasının açıklaması hasta adı taşıyabiliyor).
    kaynak: 'kurum-ekstre', rota: 'kurum-ekstre', baslik: 'Cari Ekstrem',
    yol: 'Portal › Cari Ekstre',
    menuAd: 'Cari Ekstrem', ic: '📑', menuSira: 62, yetkiKodu: 'portal.mali',
  },
];
