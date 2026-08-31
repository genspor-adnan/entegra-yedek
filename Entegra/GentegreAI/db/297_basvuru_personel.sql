-- 297: belge_basvuru.hekim_id → personel_id.
--
-- Kullanıcı: "başvuruyu karşılayan her zaman hekim olmayabilir" — diyetisyen,
-- fizyoterapist, psikolog, görüntüleme teknisyeni de başvuruyu karşılar.
-- Alan meslekten bağımsızlaşır: kısıt aynı kalır (randevu verilebilir personel
-- + seçili bölüm), yalnız adı ve ekran etiketi genelleşir ("Hekim / Personel").
--
-- Randevu tarafındaki randevu.hekim_id'ye DOKUNULMADI: orası gerçekten hekim
-- randevusu ve ayrı bir akış.

alter table public.belge_basvuru rename column hekim_id to personel_id;
alter index if exists public.ix_belge_basvuru_hekim rename to ix_belge_basvuru_personel;

comment on column public.belge_basvuru.personel_id is
  'Başvuruyu karşılayan personel (296/297) - taraf.id, randevu verilebilen personel (hekim, diyetisyen, teknisyen…).';
