-- ============================================================================
--  Gentegre AI — STOK ADLARINDA YAZIM ONARIMI (867)
--  867_stok_ad_yazim_onarimi.sql
--
--  Kullanıcı: *"stok adlarında da aynı taramayı yap"*.
--  865 (ilaç) ve 866 (hizmet) ile aynı yöntem: kataloğun kendi
--  sözvarlığı çıkarılıp (4.292 adda 2.851 tekil sözcük) nadir
--  sözcükler sık sözcüklerle karşılaştırıldı. 88 aday okundu,
--  13 satır onarıldı.
--
--  ============ ONARILANLAR ==========================================
--    KATATER → KATETER          (6)   BİRİLİKTE → BİRLİKTE      (2)
--    DİSTALTİBİA → DİSTAL TİBİA (1)   PROKSİMALTİBİA → aynı şekilde (1)
--    BİLİER → BİLİYER           (1)   KAFESR → KAFES            (1)
--    SİSTEMMODÜLER → SİSTEM MODÜLER (1)
--
--  ============ EN ÖNEMLİ BULGU: TYPO DEĞİL, KESME ==================
--  Aday listesindeki "İMPLAN", "ZIRCONI", "DEZARTİKÜLASYO", "KOMPOZİ",
--  "BAĞLANT", "PROTE" gibi sözcükler YAZIM HATASI DEĞİL: `stok.ad`
--  varchar(100) ve SUT metni tam 100. karakterde KESİLMİŞ. Böyle
--  742 SATIR var. Onarımı kaynak SUT metnini ve kolon genişletmesini
--  gerektirir - yazım onarımının kapsamı değil, uydurulmadı.
--
--  ============ ADAY OLUP DOKUNULMAYANLAR ============================
--    · GEÇERLİ BİLEŞİK SÖZCÜKLER: MİKROVASKÜLER, MİKROCERRAHİ,
--      MİKROELEKTROT, BAŞPARMAK.
--    · SUT'UN KENDİ YAZIMI: "SİFİNKTEROTOM" (12 ardışık katalog
--      satırında aynı yazım - kaynak böyle yazıyor, veri giriş hatası
--      değil), "PARAFİN TÜL KAPAMALAR" (kapama = yara örtüsü; KAPLAMA
--      değil), RİJİD/RİGİD.
--    · GEÇERLİ ÇEKİMLER: UYGULAMALARI, REVİZYONU, KILAVUZU, PLAKLARI…
--      ve farklı sözcükler (KILIF≠KILIT, MAKRO≠MİKRO).
--
--  SGK faturalaması STOK/SUT KODU üzerinden yürür; ad değişmesi
--  ödemeyi etkilemez. Yeni bir SUT/ÜTS aktarımı eski yazımı geri
--  getirirse dosya yeniden çalıştırılır.
--
--  GÜVENLİK: yedek `stok_ad_yedek_867`, eski ad listenin kendisinden;
--  güncelleme id + eski metin eşleştirir, ikinci çalıştırma 0 satır.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

create table if not exists public.stok_ad_yedek_867 (
    id           integer primary key,
    ad           character varying(100) not null,
    yedek_tarihi timestamptz not null default now()
);

with d(id, eski, yeni) as (values
    (186, 'SERVİKAL İNTERBODY KAFESR, RİGİD, PEEK, KORPUS PLAKLI', 'SERVİKAL İNTERBODY KAFES, RİGİD, PEEK, KORPUS PLAKLI'),
    (476, 'MASİF, DİSTALTİBİA, TÜM BOY VE KALINLIKLAR', 'MASİF, DİSTAL TİBİA, TÜM BOY VE KALINLIKLAR'),
    (480, 'MASİF, PROKSİMALTİBİA, TÜM BOY VE KALINLIKLAR', 'MASİF, PROKSİMAL TİBİA, TÜM BOY VE KALINLIKLAR'),
    (1132, 'KATETER, ATEREKTOMİ/MOTORU İLE BİRİLİKTE', 'KATETER, ATEREKTOMİ/MOTORU İLE BİRLİKTE'),
    (1272, 'KATETER, DRENAJ, BİLİER, KİLİTSİZ', 'KATETER, DRENAJ, BİLİYER, KİLİTSİZ'),
    (1870, 'DRENAJ REZERVUARI(OMMAYA TİPİ) İÇİN KATATER', 'DRENAJ REZERVUARI(OMMAYA TİPİ) İÇİN KATETER'),
    (2017, 'DİAGNOSTİK KATATERLER', 'DİAGNOSTİK KATETERLER'),
    (2018, 'DİAGNOSTİK KATATERLER, RADYAL ARTER', 'DİAGNOSTİK KATETERLER, RADYAL ARTER'),
    (2094, 'ROTABİLATÖR VE KATATERİ', 'ROTABİLATÖR VE KATETERİ'),
    (2139, 'SNARE KATATER', 'SNARE KATETER'),
    (2454, 'KATETER, ATEREKTOMİ/MOTORU İLE BİRİLİKTE', 'KATETER, ATEREKTOMİ/MOTORU İLE BİRLİKTE'),
    (3898, 'TAŞ TOPLAYAN, ÇIKARAN, KAÇMASINI ÖNLEYEN KATATERLER (TÜM ŞEKİL VE ÖZELLİK)', 'TAŞ TOPLAYAN, ÇIKARAN, KAÇMASINI ÖNLEYEN KATETERLER (TÜM ŞEKİL VE ÖZELLİK)'),
    (4251, 'SALINIM FAZI MİKROİŞLEMCİ, DURUŞ FAZI HİDROLİK KONTROLLÜ DİZ EKLEMLİ, PASİF VAKUM SİSTEMMODÜLER DİZ', 'SALINIM FAZI MİKROİŞLEMCİ, DURUŞ FAZI HİDROLİK KONTROLLÜ DİZ EKLEMLİ, PASİF VAKUM SİSTEM MODÜLER DİZ')
)
insert into public.stok_ad_yedek_867 (id, ad)
select d.id, d.eski from d join public.stok s on s.id = d.id
 where s.ad in (d.eski, d.yeni)
on conflict (id) do nothing;

with d(id, eski, yeni) as (values
    (186, 'SERVİKAL İNTERBODY KAFESR, RİGİD, PEEK, KORPUS PLAKLI', 'SERVİKAL İNTERBODY KAFES, RİGİD, PEEK, KORPUS PLAKLI'),
    (476, 'MASİF, DİSTALTİBİA, TÜM BOY VE KALINLIKLAR', 'MASİF, DİSTAL TİBİA, TÜM BOY VE KALINLIKLAR'),
    (480, 'MASİF, PROKSİMALTİBİA, TÜM BOY VE KALINLIKLAR', 'MASİF, PROKSİMAL TİBİA, TÜM BOY VE KALINLIKLAR'),
    (1132, 'KATETER, ATEREKTOMİ/MOTORU İLE BİRİLİKTE', 'KATETER, ATEREKTOMİ/MOTORU İLE BİRLİKTE'),
    (1272, 'KATETER, DRENAJ, BİLİER, KİLİTSİZ', 'KATETER, DRENAJ, BİLİYER, KİLİTSİZ'),
    (1870, 'DRENAJ REZERVUARI(OMMAYA TİPİ) İÇİN KATATER', 'DRENAJ REZERVUARI(OMMAYA TİPİ) İÇİN KATETER'),
    (2017, 'DİAGNOSTİK KATATERLER', 'DİAGNOSTİK KATETERLER'),
    (2018, 'DİAGNOSTİK KATATERLER, RADYAL ARTER', 'DİAGNOSTİK KATETERLER, RADYAL ARTER'),
    (2094, 'ROTABİLATÖR VE KATATERİ', 'ROTABİLATÖR VE KATETERİ'),
    (2139, 'SNARE KATATER', 'SNARE KATETER'),
    (2454, 'KATETER, ATEREKTOMİ/MOTORU İLE BİRİLİKTE', 'KATETER, ATEREKTOMİ/MOTORU İLE BİRLİKTE'),
    (3898, 'TAŞ TOPLAYAN, ÇIKARAN, KAÇMASINI ÖNLEYEN KATATERLER (TÜM ŞEKİL VE ÖZELLİK)', 'TAŞ TOPLAYAN, ÇIKARAN, KAÇMASINI ÖNLEYEN KATETERLER (TÜM ŞEKİL VE ÖZELLİK)'),
    (4251, 'SALINIM FAZI MİKROİŞLEMCİ, DURUŞ FAZI HİDROLİK KONTROLLÜ DİZ EKLEMLİ, PASİF VAKUM SİSTEMMODÜLER DİZ', 'SALINIM FAZI MİKROİŞLEMCİ, DURUŞ FAZI HİDROLİK KONTROLLÜ DİZ EKLEMLİ, PASİF VAKUM SİSTEM MODÜLER DİZ')
)
update public.stok s set ad = d.yeni, degistirme_tarihi = now()
  from d where s.id = d.id and s.ad = d.eski;

do $$
declare v_yedek integer; v_kalan integer;
begin
    select count(*) into v_yedek from public.stok_ad_yedek_867;
    select count(*) into v_kalan from public.stok s
      join public.stok_ad_yedek_867 y on y.id = s.id where s.ad = y.ad;
    raise notice '867 tamam: yedek % satir, eski yazimi kalan %.', v_yedek, v_kalan;
end $$;

commit;
