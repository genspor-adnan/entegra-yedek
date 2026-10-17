/**
 * HBYS MENÜ GRUP SIRASI (tek kaynak). Grup adları listeTanimlari'ndaki HAM (çevrilmemiş) `menuGrup`
 * değeridir; listede olmayan grup en sona düşer - yeni modül eklerken buraya da yaz
 * (`menuDuzeni.test.ts` denetler).
 *
 * BÖLGELER KALDIRILDI (kullanıcı 17.10.2026: "ana menüdeki bölgelere ihtiyaç yok artık sadece gruplar
 * kalsın.. genprofil'den de kaldır"): eskiden gruplar 8 bölge altında accordion'du (V2). Sıra o
 * bölgelerin düzleştirilmiş hali olarak korundu - hastanın yolculuğu: kapı, klinik, tetkik, yatış,
 * ödeyen, para, tedarik, yönetim. ERP (ürün modu 1) kendi sırasını kullanır (menuAgaci).
 */
export const GRUP_SIRA_HBYS: string[] = [
  // Hasta akışı - ÇAĞRI MERKEZİ (839) ilk temas.
  'Çağrı Merkezi', 'Randevu', 'Kayıt Kabul', 'Acil',
  // Klinikler - GÖZ muayeneden sonra; İŞYERİ HEKİMLİĞİ (741) OSGB'de tek klinik.
  'Muayene', 'Göz', 'Diş', 'FTR', 'İşyeri Hekimliği',
  // Tanı & tetkik
  'Laboratuvar', 'Radyoloji', 'Patoloji',
  // Yatan & cerrahi
  'Yatan Hasta', 'Ameliyathane',
  // Ödeyen & fatura - MEDULA (707) klinik akışın ardında, para önünde.
  'Medula', 'Kurumlar & Sigorta', 'e-Nabız',
  // Finans - hastanın işi bitince sıra tahsilata gelir.
  'Finans', 'Muhasebe', 'Cari & CRM',
  // Tedarik & teknik (722-724, 773): eczane, satınalma, depo, biyomedikal aynı zincirin halkaları.
  'Eczane', 'Satınalma', 'Stok & Hizmet', 'Sabit Varlıklar', 'Teknik Servis',
  // Yönetim - Kalite Onay'dan önce; Sistem (eski "Yönetim" grubu) ve Dökümler en sonda.
  'İK', 'Doküman', 'Kalite', 'Klinik Kalite', 'Onay', 'Güvenlik', 'Formlar', 'Platform',
  'Sistem', 'Dökümler',
];
