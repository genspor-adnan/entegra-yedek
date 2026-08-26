-- ============================================================================
--  Gentegre AI — "AKTIF" AYARLARI YERINE MUKELLEFIYET BAYRAKLARI
--  172_ebelge_mukellefiyet.sql
--
--  Kullanici: "e-Fatura aktif : e-Fatura mükellefi / e-Arşiv aktif : e-Arşiv
--  mükellefi (earsiv.aktif kaldır) / e-İrsaliye aktif : e-İrsaliye mükellefi
--  (eirsaliye.aktif kaldır) / e-SMM aktif : e-SMM mükellefi (esmm.aktif kaldır,
--  e-SMM mükellefi ekle). Seçili olanların sekmeleri görünür olsun."
--
--  NEDEN DOGRU: "aktif" ile "mükellefiyet" ayni seydi ama iki yerde duruyordu -
--  biri firma geneli ayar (`referans`), digeri sube kolonu. Kullanici e-Arşiv'i
--  ayardan acip subede mukellef isaretlemeyi unutunca belge sessizce yanlis
--  turde hazirlanabiliyordu. Tek dogruluk kaynagi: SUBENIN MUKELLEFIYETI.
--
--  Mukellefiyet GIB kaydidir ve mukellefe (VKN'ye) baglidir - firma geneli
--  olamaz: ayri VKN'li sube e-Fatura mukellefi iken digeri olmayabilir.
-- ============================================================================
\set ON_ERROR_STOP on

-- e-SMM mukellefiyeti (digerleri 165 oncesinden var).
alter table public.sube
    add column if not exists esmm_mukellef smallint not null default 0;

comment on column public.sube.esmm_mukellef is
  'Serbest meslek makbuzu mukellefi mi (172).';

-- Eski "aktif" ayarlari SUBEYE tasinir: acik olan tur, varsayilan subede
--   mukellefiyet olarak isaretlenir. Sonra ayar silinir - iki kaynak kalmasin.
do $$
declare
    v_sube integer := (select id from public.sube where varsayilan = 1 and aktif = 1
                        order by id limit 1);
begin
    if v_sube is null then
        select min(id) into v_sube from public.sube;
    end if;
    if v_sube is null then
        return;
    end if;

    update public.sube s
       set earsiv_mukellef =
               case when coalesce((select deger from public.referans where anahtar = 'earsiv.aktif'), '0') = '1'
                    then 1 else s.earsiv_mukellef end,
           eirsaliye_mukellef =
               case when coalesce((select deger from public.referans where anahtar = 'eirsaliye.aktif'), '0') = '1'
                    then 1 else s.eirsaliye_mukellef end,
           esmm_mukellef =
               case when coalesce((select deger from public.referans where anahtar = 'esmm.aktif'), '0') = '1'
                    then 1 else s.esmm_mukellef end,
           -- e-Fatura'nin ayri "aktif" ayari yoktu; mukellefiyeti zaten kolonda.
           efatura_mukellef = s.efatura_mukellef
     where s.id = v_sube;

    raise notice '172: tur aktifligi sube %in mukellefiyet bayraklarina tasindi.', v_sube;
end $$;

delete from public.referans
 where anahtar in ('earsiv.aktif', 'eirsaliye.aktif', 'esmm.aktif');

-- --------------------------------------------------- hazirlama kontrolleri --
-- `fn_ebelge_hazirla` (163) e-Irsaliye icin `eirsaliye.aktif` ayarina bakiyordu;
--   o ayar artik yok. Kontrol SUBENIN mukellefiyetine gecer ve e-Arsiv/e-Fatura
--   icin de yapilir - mukellef olmadigimiz turde belge hazirlamak, gonderimde
--   entegratorden hata almak demektir.
create or replace function public.fn_ebelge_mukellef_mi(p_sube_id integer, p_belge_turu integer)
returns boolean language sql stable as $$
    -- Mukellefiyet KIMLIK subesinindir: merkezin kimligiyle gonderen sube,
    --   merkezin mukellefiyetini kullanir (169).
    select case p_belge_turu
             when 1 then ki.efatura_mukellef
             when 2 then ki.earsiv_mukellef
             when 7 then ki.eirsaliye_mukellef
             when 8 then ki.esmm_mukellef
             else 0 end = 1
      from public.v_ebelge_gonderici g
      join public.sube ki on ki.id = g.kimlik_sube_id
     where g.sube_id = coalesce(p_sube_id, (select id from public.sube
                                             where varsayilan = 1 and aktif = 1
                                             order by id limit 1))
$$;

comment on function public.fn_ebelge_mukellef_mi(integer, integer) is
  'Sube (ya da kimligini kullandigi merkez) bu belge turunde mukellef mi (172).';

create or replace function public.fn_ebelge_tur_adi(p_belge_turu integer)
returns text language sql immutable as $$
    select case p_belge_turu when 1 then 'e-Fatura' when 2 then 'e-Arşiv'
                             when 7 then 'e-İrsaliye' when 8 then 'e-SMM'
                             else 'e-Belge' end
$$;

do $$
begin
    raise notice '172 tamam: mukellefiyet bayraklari tek kaynak, aktif ayarlari silindi.';
end $$;
