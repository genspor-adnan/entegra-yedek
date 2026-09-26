-- =====================================================================
--  913_istem_ucret_kapisi.sql
--  İSTEM ÜCRET KAPISI — "acil ve yatan dışında ödeyen kurum + ücret
--  girilmeden lab ve radyolojiye düşmez" (kullanıcı).
--
--  912 poliklinik-banko kapısını GENELLEŞTİRİR: worklist görünürlüğü artık
--  ÜCRETLENDİRME yapılıp yapılmadığına bağlıdır, kaynağa/kuruma değil.
--
--  serbest = 1 (çalışma listesi görür) koşulları:
--    * öncelik ACİL (>=2), ya da
--    * başvuru ACİL(2) / YATAN(3), ya da
--    * başvuruda ÜCRET SATIRI var (belge_satir.hizmet_id dolu) = ödeyen kurum
--      + ücret girilmiş.
--  Aksi halde serbest = 0: istem başvuruda "ücretlendirme bekliyor" durur,
--  banko ücreti girince (belge_satir) TETİKLE serbest olur.
--
--  Not: 912'nin kurum_profil.istem_banko_kapisi kolonu kalır ama artık kural
--  evrensel (ücret temelli); kolon ileride "kapıyı tümüyle kapat" seçeneği
--  için duruyor.
-- =====================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------- karar fonksiyonu (yeni imza) ----
drop function if exists public.fn_istem_serbest(smallint, smallint, smallint, smallint);

/**
 * İstem serbest kararı. Ücret temelli: başvuruda ücret satırı yoksa (ve
 * acil/yatan değilse) istem worklist'e DÜŞMEZ.
 *   döner: 1 = kabule/çekime açık · 0 = ödeyen kurum + ücret bekliyor
 */
create or replace function public.fn_istem_serbest(
    p_basvuru_turu smallint,
    p_oncelik      smallint,
    p_belge_id     integer)
returns smallint
language plpgsql stable
as $$
begin
    -- Acil öncelik: beklemez.
    if coalesce(p_oncelik, 1) >= 2 then return 1; end if;
    -- Acil(2) / Yatan(3) başvuru: ücret sonra, iş önce.
    if coalesce(p_basvuru_turu, 0) in (2, 3) then return 1; end if;
    -- Başvurusuz (belge yok): gating uygulanamaz - görünür bırak.
    if p_belge_id is null then return 1; end if;
    -- ÜCRET GİRİLDİ Mİ: başvuruda hizmet (tetkik/işlem) kalemi var mı.
    if exists (select 1 from public.belge_satir s
                where s.belge_id = p_belge_id and s.hizmet_id is not null) then
        return 1;
    end if;
    return 0;   -- ödeyen kurum + ücret bekliyor
end $$;

comment on function public.fn_istem_serbest(smallint, smallint, integer) is
  '913: istem serbest kararı - ücret temelli (acil/yatan bypass). Tek kaynak.';

-- ------------------------------------- ücret girilince serbest bırak (tetik) ----
/**
 * Başvuruya ÜCRET SATIRI (hizmet kalemi) eklenince, o başvurunun bekleyen
 * (serbest=0) lab/radyoloji istemleri KENDİLİĞİNDEN serbest olur ve çalışma
 * listelerine düşer. Banko ücreti girer girmez iş akışa girsin diye.
 */
create or replace function public.tg_belge_satir_istem_serbest()
returns trigger language plpgsql as $$
begin
    if new.hizmet_id is null then return new; end if;
    update public.lab_istem
       set serbest = 1
     where belge_id = new.belge_id and serbest = 0;
    update public.radyoloji_istem
       set serbest = 1
     where belge_id = new.belge_id and serbest = 0;
    return new;
end $$;

drop trigger if exists trg_belge_satir_istem_serbest on public.belge_satir;
create trigger trg_belge_satir_istem_serbest
    after insert on public.belge_satir
    for each row execute function public.tg_belge_satir_istem_serbest();

-- ---------------------------------------------------------------- backfill ----
-- Mevcut istemleri yeni kurala göre yeniden hesapla (başvurulular).
update public.lab_istem li
   set serbest = public.fn_istem_serbest(bb.basvuru_turu, li.oncelik, li.belge_id)
  from public.belge_basvuru bb
 where bb.id = li.belge_id;

update public.radyoloji_istem ri
   set serbest = public.fn_istem_serbest(bb.basvuru_turu, ri.oncelik, ri.belge_id)
  from public.belge_basvuru bb
 where bb.id = ri.belge_id;

do $$
begin
    raise notice '913 tamam: ucret kapisi (lab bekleyen %, rad bekleyen %) + belge_satir tetigi',
        (select count(*) from public.lab_istem where serbest = 0),
        (select count(*) from public.radyoloji_istem where serbest = 0);
end $$;
