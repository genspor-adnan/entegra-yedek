-- =============================================================================
--  1105  PATOLOJİ - BAŞVURU KAPISI
--
--  Kullanıcı (14.10.2026): "hekim istem yapınca başvuruya düşecek.. başvuru kaydı
--  yapılınca patoloji istemi çalışılabilecek".
--
--  Lab / radyoloji / göz görüntüleme istemleriyle AYNI KAPI (912-925, 974):
--    - Muayeneden açılan istem muayenenin başvurusuna bağlanır (pat_vaka.basvuru_id)
--      ve serbest = fn_istem_serbest(başvuru türü, öncelik, kaynak) ile açılır:
--      poliklinik istemi 0 (banko bekliyor), acil / yatan / acil öncelik 1.
--    - Banko "Doktor İstemi" ile materyallerin hizmetlerini başvuruya ücret satırı
--      olarak yazar; başvuru KAYDEDİLİNCE fn_basvuru_istem_serbest_uygula, hizmeti
--      ücret satırında (ya da paketinde) olan vakayı serbest bırakır.
--    - serbest = 0 vaka hazırlanamaz / gönderilemez / kabul edilemez (uçlarda kural).
--  Patoloji ekranından elle açılan vaka (dış kurum, konsültasyon) serbest = 1 (varsayılan).
--  İdempotent.
-- =============================================================================

begin;

alter table public.pat_vaka add column if not exists serbest smallint not null default 1;
comment on column public.pat_vaka.serbest is
  'Başvuru kapısı (1105): 0 = bankoda ücretlendirilip başvuru kaydedilmeden çalışılamaz · 1 = çalışılabilir.';
create index if not exists ix_pat_vaka_basvuru on public.pat_vaka (basvuru_id) where basvuru_id is not null;

create or replace function public.fn_basvuru_istem_serbest_uygula(p_belge_id integer)
returns void language plpgsql as $fn$
begin
    update public.radyoloji_istem i
       set serbest = 1
     where i.belge_id = p_belge_id and i.serbest = 0
       and exists (select 1 from public.belge_satir s
                    cross join lateral public.fn_hizmet_paket_kapsam(s.hizmet_id) k
                    where s.belge_id = p_belge_id and s.hizmet_id is not null
                      and k.hizmet_id = i.hizmet_id);

    update public.lab_istem i
       set serbest = 1
     where i.belge_id = p_belge_id and i.serbest = 0
       and exists (select 1
                     from public.lab_istem_satir ls
                     join public.lab_tetkik t on t.id = ls.tetkik_id
                     left join public.lab_panel lp on lp.id = ls.panel_id
                     join public.belge_satir s on s.belge_id = p_belge_id
                                              and s.hizmet_id is not null
                     cross join lateral public.fn_hizmet_paket_kapsam(s.hizmet_id) k
                    where ls.istem_id = i.id
                      and k.hizmet_id in (t.hizmet_id, lp.hizmet_id));

    -- 974 GÖZ GÖRÜNTÜLEME: istemin hizmeti başvurunun ücret satırında (ya da paketinde) varsa.
    update public.goz_goruntuleme g
       set serbest = 1
     where g.belge_id = p_belge_id and g.serbest = 0 and g.durum <> 0
       and exists (select 1 from public.belge_satir s
                    cross join lateral public.fn_hizmet_paket_kapsam(s.hizmet_id) k
                    where s.belge_id = p_belge_id and s.hizmet_id is not null
                      and k.hizmet_id = g.hizmet_id);

    -- 1105 PATOLOJİ: vakanın materyallerinden birinin hizmeti ücret satırında (ya da
    --   paketinde) varsa vaka serbest. Hizmeti olmayan materyal (tanımda hizmet
    --   bağlanmamış) kapıyı kilitlemesin: hizmetsiz vaka başvuru kaydında serbest.
    update public.pat_vaka v
       set serbest = 1
     where v.basvuru_id = p_belge_id and v.serbest = 0 and v.durum not in (0, 90)
       and (exists (select 1
                      from public.pat_materyal m
                      join public.belge_satir s on s.belge_id = p_belge_id and s.hizmet_id is not null
                      cross join lateral public.fn_hizmet_paket_kapsam(s.hizmet_id) k
                     where m.vaka_id = v.id and k.hizmet_id = m.hizmet_id)
            or not exists (select 1 from public.pat_materyal m where m.vaka_id = v.id and m.hizmet_id is not null));
end $fn$;

comment on function public.fn_basvuru_istem_serbest_uygula(integer) is
  '925 + 974 + 1105: başvuru kaydında, ücret satırının kapsadığı bekleyen lab / radyoloji / göz görüntüleme / patoloji istemlerini serbest bırakır.';

-- ---------------------------------------- muayene istem bağı (sonuç durumu) --
--  muayene_istem.tur 7 = patoloji, hedef_tablo 'pat_vaka'.
--  sonuc_durum: 0 bekliyor · 1 kısmi (işlemde) · 2 tamam (rapor) · 3 iptal / ret
create or replace function public.fn_patoloji_sonuc_durumu(p_durum smallint)
returns smallint language sql immutable as $$
    select case when p_durum in (0, 90) then 3::smallint
                when p_durum in (11, 12) then 2::smallint
                when p_durum between 4 and 10 then 1::smallint
                else 0::smallint end
$$;

create or replace function public.tg_muayene_istem_patoloji()
returns trigger language plpgsql as $$
declare v_yeni smallint;
begin
    v_yeni := public.fn_patoloji_sonuc_durumu(new.durum);
    update public.muayene_istem s
       set sonuc_durum = v_yeni,
           sonuc_zamani = case when v_yeni = 2 and s.sonuc_zamani is null then now() else s.sonuc_zamani end,
           degistirme_tarihi = now()
     where s.tur = 7 and s.hedef_tablo = 'pat_vaka' and s.hedef_id = new.id
       and s.sonuc_durum is distinct from v_yeni;
    return new;
end $$;

drop trigger if exists trg_muayene_istem_patoloji on public.pat_vaka;
create trigger trg_muayene_istem_patoloji
    after update of durum on public.pat_vaka
    for each row execute function public.tg_muayene_istem_patoloji();

commit;
