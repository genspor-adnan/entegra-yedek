-- =====================================================================
-- 450 - AI DİL MODELİ BAĞLANTISI (kontör muhasebesi + günlük)
--
-- 447 kontör tablolarını "model bağlanınca ücretlendirme geriye dönük
-- eklenmesin" diye kurmuştu. Bu göç modeli açıyor: hangi çağrı hangi modele
-- gitti, kaç jeton yaktı, kaç kontör düştü.
--
-- ANAHTAR BURAYA YAZILMAZ. API anahtarı satıcının hesabıdır, müşteri
-- veritabanına girmez; sunucudan okunur (ANTHROPIC_API_KEY / Ai:ApiAnahtar /
-- gizli/ai-anahtar.txt). Müşteri DB'sinde duran bir anahtar, DB'yi görebilen
-- herkese satıcının faturasını açardı.
--
-- SINIR DEĞİŞMEDİ: model REHBERDİR. Katalogdan çıkan konu/ekran/adım
-- doğruluk kaynağıdır; model yalnız kullanıcının cümlesine uyan kısa yol
-- tarifini yazar ve verdiği her ekran beyaz listeden doğrulanır.
-- =====================================================================

-- --------------------------------------------------------------------
--  1) KONTÖR: kurumsal açma/kapama + günlük tavan
--
--  Kontör bakiyesi tek başına yetmez: "bir gecede bakiyeyi yakan döngü"
--  riskine karşı günlük çağrı tavanı da kurumun elinde olmalı.
-- --------------------------------------------------------------------
alter table public.ai_kontor
    add column if not exists model_aktif smallint not null default 1;
alter table public.ai_kontor
    add column if not exists gunluk_cagri_siniri integer not null default 500;

comment on column public.ai_kontor.model_aktif is
    'Kurum dil modelini kapatabilir: 0 iken yalnız katalog rehberi çalışır.';
comment on column public.ai_kontor.gunluk_cagri_siniri is
    'Bir gündeki azami model çağrısı (0 = sınırsız). Bakiyeyi koruyan ikinci kapı.';

-- --------------------------------------------------------------------
--  2) GÜNLÜK: hangi model, kaç jeton
--
--  Kontör fiyatını (ve "hangi soru pahalıya patlıyor") ancak jeton
--  sayacıyla ölçebiliriz. `kaynak` kod listesine 5 eklendi.
-- --------------------------------------------------------------------
alter table public.ai_rehber_log
    add column if not exists model varchar(60) not null default '';
alter table public.ai_rehber_log
    add column if not exists giris_jeton integer not null default 0;
alter table public.ai_rehber_log
    add column if not exists cikis_jeton integer not null default 0;

comment on column public.ai_rehber_log.kaynak is
    '0 cevaplanamadı · 1 katalog konusu · 2 ekran eşleşmesi · 3 bağlamsal yardım · '
    '4 kontrollü öneri · 5 model destekli cevap';

do $$
begin
    raise notice '450 tamam: ai_kontor.model_aktif/gunluk_cagri_siniri, '
                 'ai_rehber_log.model/giris_jeton/cikis_jeton';
end $$;
