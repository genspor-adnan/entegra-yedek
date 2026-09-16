/**
 * MENÜ BÖLGELERİ V2 (mockup Ekranlar/Ayarlar/hastane_menu_v2.html; kullanıcı:
 * "son eklenen modüllere göre bir hastane için ideal menü düzeni").
 *
 * 24 grup tek seviyede alt alta ekran boyunu aşıyordu; klinik dallar, tanı
 * hizmetleri ve para aynı düzlemde duruyordu. HBYS'de gruplar artık 8 BÖLGE
 * altında toplanır. Bölge sırası HASTANIN YOLCULUĞUDUR: kapıdan girer, muayene
 * olur, tetkik yaptırır, yatar / ameliyat olur, ödeyeni işlenir, para hareket
 * eder, en sonda kurumun yönetimi.
 *
 * Bölge başlığı ekran açmaz; tıklanınca bölge açılır ve DİĞER BÖLGELER KAPANIR
 * (accordion) - menü hiçbir zaman bir ekranı aşmaz. Aktif rotayı içeren bölge
 * kendiliğinden açık gelir.
 *
 * Rota, yetki ve `MENU_GRUP_MODUL` eşlemesi DEĞİŞMEZ: bölge yalnız Kabuk'un
 * gruplamasına bir seviye ekler. Grup adları listeTanimlari'ndaki HAM (çevrilmemiş)
 * `menuGrup` değeridir. Listede olmayan grup en son bölgeye (Yönetim) düşer -
 * yeni modül eklerken buraya da yaz, `menuDuzeni.test.ts` bunu denetler.
 *
 * ERP (ürün modu 1) bölge kullanmaz: 10 grup tek seviyede yeterli.
 */
export interface MenuBolgesi {
  /** Çevrilmemiş ad; Kabuk `cm()` ile çevirir. */
  ad: string;
  /** Bölge rengi (başlıktaki kare) - hangi bölgede olduğun renkten okunur. */
  renk: string;
  gruplar: string[];
}

export const BOLGE_HBYS: MenuBolgesi[] = [
  { ad: 'Hasta Akışı',      renk: '#2f6db3', gruplar: ['Randevu', 'Kayıt Kabul', 'Acil'] },
  // GÖZ MUAYENEDEN SONRA (kullanıcı): günlük iş hacmi en yüksek dallardan biri.
  { ad: 'Klinikler',        renk: '#3f9a5e', gruplar: ['Muayene', 'Göz', 'Diş', 'FTR'] },
  { ad: 'Tanı & Tetkik',    renk: '#6a3fb5', gruplar: ['Laboratuvar', 'Radyoloji'] },
  { ad: 'Yatan & Cerrahi',  renk: '#c0392b', gruplar: ['Yatan Hasta', 'Ameliyathane'] },
  // MEDULA (707) klinik akışın ardında, para önünde.
  { ad: 'Ödeyen & Fatura',  renk: '#d9a12b', gruplar: ['Medula', 'Kurumlar & Sigorta', 'e-Nabız'] },
  // PARA HEMEN ARKASINDA (kullanıcı): hastanın işi bitince sıra tahsilata gelir.
  { ad: 'Finans',           renk: '#1c8b8b', gruplar: ['Finans', 'Muhasebe', 'Cari & CRM'] },
  // TEDARİK KENDİ BÖLGESİ (722/723/724): eczane, satınalma, depo ve
  //   biyomedikal AYNI ZİNCİRİN halkalarıdır - eczanenin kritik stoğu
  //   satınalma talebi doğurur, biyomedikalin arızası da öyle; satınalmanın
  //   mal kabulü ikisinin de stoğunu besler. Bunları Finans'ın ve Yönetim'in
  //   içine dağıtmak, günlük tedarik işini iki menü dalına bölerdi.
  { ad: 'Tedarik & Teknik', renk: '#8a6d3b', gruplar: ['Eczane', 'Satınalma', 'Stok & Hizmet', 'Demirbaş'] },
  // Kalite Yönetim grubunun alt grubudur (KlinikKalite); Doküman kendi grubu
  //   (kullanıcı: "kurum dokümanı günlük iş, ayar değil").
  { ad: 'Yönetim',          renk: '#6b7a8b', gruplar: ['İK & Prim', 'Doküman', 'Yönetim'] },
];

/** HBYS grup sırası = bölgelerin düzleştirilmiş hali (tek kaynak). */
export const GRUP_SIRA_HBYS = BOLGE_HBYS.flatMap(b => b.gruplar);

/** Grubun bölgesi; tanımsız grup son bölgeye (Yönetim) düşer. */
export function grupBolgesi(grupHam: string | undefined): MenuBolgesi {
  return BOLGE_HBYS.find(b => grupHam !== undefined && b.gruplar.includes(grupHam))
    ?? BOLGE_HBYS[BOLGE_HBYS.length - 1];
}

/**
 * ÇALIŞMA ALANI (V2 mockup üst çip; kullanıcı: "çalışma alanı çipini de ekle"):
 * kullanıcının gün boyu kullandığı bölgeler. Alan dışındaki bölgeler menüde
 * ÇİZİLMEZ (yetki değil, görünüm - "Diğer bölgeler" satırıyla açılır); banko
 * her gün 20 gruba bakmaz. Varsayılan rolden gelir (`rolCalismaAlani`), kullanıcı
 * değiştirince tercih sunucuda saklanır (`calismaAlani`, favoriler gibi).
 */
export interface CalismaAlani {
  kod: string;
  ad: string;
  /** Boş = tüm bölgeler. */
  bolgeler: string[];
}

export const CALISMA_ALANLARI: CalismaAlani[] = [
  { kod: 'tumu',     ad: 'Tümü',              bolgeler: [] },
  { kod: 'banko',    ad: 'Banko',             bolgeler: ['Hasta Akışı', 'Ödeyen & Fatura'] },
  { kod: 'hekim',    ad: 'Hekim',             bolgeler: ['Klinikler', 'Tanı & Tetkik'] },
  { kod: 'hemsire',  ad: 'Hemşire',           bolgeler: ['Klinikler', 'Yatan & Cerrahi'] },
  { kod: 'tani',     ad: 'Lab / Görüntüleme', bolgeler: ['Tanı & Tetkik'] },
  { kod: 'muhasebe', ad: 'Muhasebe',          bolgeler: ['Ödeyen & Fatura', 'Finans'] },
  // ECZACI / DEPO / BİYOMEDİKAL (722-724): günü Tedarik bölgesinde geçer ama
  //   order kontrolü ve ünite doz klinik akışa bağlıdır - iki bölge birden.
  { kod: 'tedarik',  ad: 'Eczane / Tedarik',  bolgeler: ['Tedarik & Teknik', 'Yatan & Cerrahi'] },
];

export function calismaAlaniBul(kod: string | undefined): CalismaAlani {
  return CALISMA_ALANLARI.find(a => a.kod === kod) ?? CALISMA_ALANLARI[0];
}

/**
 * Rol adından varsayılan alan. Standart roller (StandartRolUclari.cs) ad ile
 * eşlenir; kurumun kendi rol adları da çoğu zaman aynı sözcükleri taşır
 * ("Banko", "Hekim", "Hemşire"...). Eşleşmeyen rol = Tümü.
 */
export function rolCalismaAlani(rolAdi: string | undefined): string {
  const r = (rolAdi ?? '').toLocaleLowerCase('tr');
  if (!r) return 'tumu';
  if (/banko|kayıt kabul|kayit kabul|vezne|yatış|yatis/.test(r)) return 'banko';
  // ECZANE/DEPO ROLÜ muhasebeden ÖNCE bakılır: "Eczane / Depo" içindeki
  //   sözcükler başka dala düşmesin.
  if (/eczac|eczane|depo|biyomedikal|satınalma|satinalma/.test(r)) return 'tedarik';
  if (/muhasebe|finans|medula/.test(r)) return 'muhasebe';
  if (/radyolo|lab |lab$|laboratuvar|numune|teknisyen|teleradyoloji/.test(r)) return 'tani';
  if (/hemşire|hemsire|fizyoterapist|asistan/.test(r)) return 'hemsire';
  if (/hekim|uzman|optometrist|doktor/.test(r)) return 'hekim';
  return 'tumu';
}
