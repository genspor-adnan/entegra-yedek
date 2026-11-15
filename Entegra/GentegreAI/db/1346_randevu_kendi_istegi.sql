-- ============================================================================
--  1346 - RANDEVUDA "KENDİ İSTEĞİ" İŞARETİ
--
--  Kullanıcı (15.11.2026): "randevu kartında gönderen yoksa başvuru gibi Kendi İsteği check olmalı".
--
--  Başvurudaki 370 kuralının randevuya taşınması: gönderen hekimin olmaması bir eksiklik değil, bir SEÇİMDİR.
--  Görüntüleme / lab kurulumunda gönderen zorunlu ("!randevu.bolum_doktor" kapısı); kendi isteğiyle gelen
--  hastada bu zorunluluk işaretle karşılanır (KartAlani.ZorunluMuafAlan). Hekim seçilince işaret kalkar - iki
--  bilgi aynı anda doğru olamaz (KartAlani.KarsitAlan; sunucu kayıtta da 0'a çeker, kısıt son savunma).
--
--  VERİ GÖÇÜ YOK: eski randevularda işaret 0 kalır (370 ile aynı karar); kart yeniden düzenlenirse kullanıcı
--  ya gönderen seçer ya işaretler. Erteleme (RandevuUclari.Ertele) gönderen ve işareti yeni randevuya taşır.
-- ============================================================================
alter table public.randevu add column if not exists kendi_istegi smallint not null default 0;
comment on column public.randevu.kendi_istegi is
  'Hasta KENDİ İSTEĞİYLE geldi (1346): gönderen hekim yok ama bu bir seçimdir. Gönderen zorunluluğu '
  '"gonderen_id dolu VEYA kendi_istegi = 1" ile karşılanır; hekim seçilince işaret kalkar.';
alter table public.randevu drop constraint if exists ck_randevu_kendi_istegi;
alter table public.randevu add constraint ck_randevu_kendi_istegi check (kendi_istegi = 0 or gonderen_id is null);
