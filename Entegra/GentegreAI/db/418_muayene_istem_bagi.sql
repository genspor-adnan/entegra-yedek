-- ============================================================================
--  418 - MUAYENE İSTEM BAĞI (Faz 1 · Muayene v1)
--
--  muayene_istem (409) bir BAG ve DURUM tablosudur: asil kayit modul
--  tablosunda (radyoloji_istem, lab_istem, belge_satir) kalir. Sorun sudur:
--  modulde sonuc onaylandiginda muayene tarafi bunu KENDILIGINDEN bilmez -
--  hekim "sonuc bekliyor" rozetine bakip bosuna bekler.
--
--  Iki yol vardi:
--    * modul kodlarina "muayene_istem'i de guncelle" satiri eklemek
--    * durumu VERITABANI TETIGIYLE yansitmak
--
--  Ikincisi secildi: radyoloji raporu uc ayri yoldan onaylanabiliyor (ekran,
--  toplu onay, cihaz entegrasyonu) ve her yola ayni satiri eklemek, birini
--  unutunca sessizce bozulan bir bag birakirdi.
--
--  BEKLEYEN ISTEM MUAYENE DURUMUNU DA SURUKLER: acik muayenede bekleyen istem
--  varsa durum "sonuc bekliyor" (2), hepsi gelince "acik" (1). Hekimin
--  listesinde bu ayrim gunun isini bolen sey.
-- ============================================================================

-- --------------------------------------------------------------------------
--  Radyoloji istem durumu -> muayene istem sonuc durumu
--     radyoloji: 0 iptal · 1 bekliyor · 2 cekildi · 3 raporlaniyor
--                4 on rapor · 5 onaylandi · 6 teslim
--     muayene  : 0 bekliyor · 1 kismi · 2 tamam · 3 iptal
-- --------------------------------------------------------------------------
create or replace function public.fn_radyoloji_sonuc_durumu(p_durum smallint)
returns smallint language sql immutable as $$
    select case p_durum
                when 0 then 3::smallint          -- iptal
                when 5 then 2::smallint          -- onaylandi = sonuc tamam
                when 6 then 2::smallint          -- teslim edildi
                when 4 then 1::smallint          -- on rapor = kismi
                when 3 then 1::smallint          -- raporlaniyor = kismi
                else 0::smallint                 -- bekliyor / cekildi
           end
$$;

create or replace function public.tg_muayene_istem_radyoloji()
returns trigger language plpgsql as $$
declare v_yeni smallint;
begin
    v_yeni := public.fn_radyoloji_sonuc_durumu(new.durum);

    update public.muayene_istem s
       set sonuc_durum = v_yeni,
           -- Sonuc zamani ILK TAMAMLANMADA yazilir, sonraki durum
           --   degisikliklerinde kaymaz (teslim edildi -> yeniden yazilmasin).
           sonuc_zamani = case when v_yeni = 2 and s.sonuc_zamani is null
                               then now() else s.sonuc_zamani end,
           degistirme_tarihi = now()
     where s.tur = 2 and s.hedef_tablo = 'radyoloji_istem' and s.hedef_id = new.id
       and s.sonuc_durum is distinct from v_yeni;

    return new;
end $$;

drop trigger if exists trg_muayene_istem_radyoloji on public.radyoloji_istem;
create trigger trg_muayene_istem_radyoloji
    after update of durum on public.radyoloji_istem
    for each row execute function public.tg_muayene_istem_radyoloji();

-- --------------------------------------------------------------------------
--  Muayene durumu istemlerden turer.
--
--  TAMAMLANMIS muayene (3) ve iptal (0) DISINDA: onlarin durumu artik
--  istemden etkilenmemeli - tamamlanan muayene sonuc gelince yeniden acilmaz.
-- --------------------------------------------------------------------------
create or replace function public.tg_muayene_durum_istemden()
returns trigger language plpgsql as $$
declare v_muayene integer; v_bekleyen integer;
begin
    v_muayene := coalesce(new.muayene_id, old.muayene_id);

    select count(*) into v_bekleyen
      from public.muayene_istem s
     where s.muayene_id = v_muayene and s.sonuc_durum in (0, 1);

    update public.muayene m
       set durum = case when v_bekleyen > 0 then 2::smallint else 1::smallint end,
           degistirme_tarihi = now()
     where m.id = v_muayene
       and m.durum in (1, 2)
       and m.durum is distinct from case when v_bekleyen > 0 then 2 else 1 end;

    return null;
end $$;

drop trigger if exists trg_muayene_durum_istemden on public.muayene_istem;
create trigger trg_muayene_durum_istemden
    after insert or update of sonuc_durum or delete on public.muayene_istem
    for each row execute function public.tg_muayene_durum_istemden();
