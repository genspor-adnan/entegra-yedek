-- 981 · MENÜ DÜZENİ: BENZERSİZLİK TÜRÜ DE KAPSAR
--
-- 979'daki kısıt `(sube_id, sistem_kod)` idi. Ad çakışması olabileceği
-- hesaba katılmamıştı: "Yönetim" hem bir BÖLGE hem bir GRUP adı
-- (menuBolgeleri: Yönetim bölgesi altında Yönetim grubu). İkisinin ayrı
-- kaydı olması gerekirken kısıt buna izin vermiyor, kaydetme
-- "Ayni kayit zaten var (menu_duzen_benzersiz)" ile düşüyordu.
--
-- `dugum_tur` zaten satırda duruyor; benzersizlik de onu kapsar. Mevcut
-- satırlar etkilenmez: eski kısıtı sağlayan her küme yenisini de sağlar.
alter table public.menu_duzen drop constraint if exists menu_duzen_benzersiz;

alter table public.menu_duzen
  add constraint menu_duzen_benzersiz unique (sube_id, dugum_tur, sistem_kod);

comment on constraint menu_duzen_benzersiz on public.menu_duzen is
  'Bir şubede aynı TÜR + KOD bir kez: "Yönetim" bölgesi ile "Yönetim" grubu ayrı satırlardır.';
