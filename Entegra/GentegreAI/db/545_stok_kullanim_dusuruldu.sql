-- =====================================================================
--  545 - STOK "KULLANIM" ALANI KALDIRILDI
--  (kullanici: "kullanım ekrandan ve tablodan kaldır")
--
--  486'da Ozellik / Icerik / Kullanim uclusu karta acilmisti; kolonlar
--  gocten (Delphi STOKLAR) geliyordu. Kullanim TEK BIR YERDE BILE
--  doldurulmadi: 4.292 stok satirinin hepsinde 0, `stok.kullanim` kod
--  listesinde tek deger yok, hicbir sorgu okumuyor. Kullanilmayan alan
--  kartta "doldurulmasi gereken bir sey" izlenimi uretiyordu.
--
--  Ozellik ve Icerik DURUYOR - onlar Excel aktariminda dolu geliyor.
-- =====================================================================

create table if not exists public._yedek_stok_kullanim_545 as
select id, kullanim from public.stok where coalesce(kullanim, 0) <> 0;

do $$
declare v_dolu int;
begin
    select count(*) into v_dolu from public._yedek_stok_kullanim_545;
    raise notice '545: kullanim degeri dolu satir = % (yedek: _yedek_stok_kullanim_545)', v_dolu;
end $$;

alter table public.stok drop column if exists kullanim;
