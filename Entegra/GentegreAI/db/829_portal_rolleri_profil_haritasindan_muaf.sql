-- ============================================================================
--  Gentegre AI — PORTAL ROLLERİ KURUM PROFİLİ ROL HARİTASINDAN MUAF
--  829_portal_rolleri_profil_haritasindan_muaf.sql
--
--  Kullanıcı: *"portal rollerini o listeden muaf tut"*.
--
--  ============ NEDEN ================================================
--  786'daki harita ("bu profilde geçerli roller") kurum İÇİ kadroyu anlatıyor:
--  bir tıp merkezinde diş hekimi rolü gerekmez, kapatılır. Portal rolleri
--  (dış doktor, dış kurum klinik/yönetici, hasta) ise kadro değil DIŞARIYA
--  AÇILAN KAPIdır - kurum tipiyle ilgisi yok.
--
--  Canlı denemede görüldü: "Hastane" profilinde Kaydet'e basınca, işaretlenmemiş
--  olan `dis_istem_kurumu` PASİFE ALINDI - dış kurumun klinik kullanıcıları
--  bir anda giriş yapamaz hale geldi. Kimse portal rolünü kapatmayı istememişti;
--  yalnızca iç kadro listesinde işaretlememişti.
--
--  ============ ÜÇ KATMAN ============================================
--  1) UYGULAMA: `fn_kurum_tipi_rol_uygula` artık portal rolüne dokunmaz -
--     kural TEK YERDE kalsın (eski harita, göç, betik hepsi buradan geçiyor).
--  2) HARİTA: portal rolü haritaya hiç yazılmasın (tetik reddeder) ve
--     bugüne kadar yazılmış satırlar temizlensin.
--  3) ONARIM: yalnız haritada `gecerli = 0` yüzünden kapanmış portal rolleri
--     yeniden açılır. Elle kapatılmış olabileceği için KÖRÜ KÖRÜNE hepsi
--     açılmaz - sadece kapanma sebebi PROVABLY bu harita olanlar.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------ onarim ----
-- Once yedek: hangi satirlar neyi kapatmisti.
create table if not exists public.kurum_tipi_rol_portal_yedek_829 as
select k.*, r.aktif as rol_aktif_oncesi, now() as yedek_zamani
  from public.kurum_tipi_rol k
  join public.rol r on r.kod = k.rol_kod
 where coalesce(r.portal_turu, 0) > 0;

-- Haritada "gecersiz" isaretlendigi icin kapanmis portal rolleri geri acilir.
update public.rol r
   set aktif = 1, degistirme_tarihi = now()
  from public.kurum_tipi_rol k
 where k.rol_kod = r.kod
   and coalesce(r.portal_turu, 0) > 0
   and k.gecerli = 0
   and r.aktif = 0;

-- Portal satirlari haritadan cikar: bundan sonra orada isi yok.
delete from public.kurum_tipi_rol k
 using public.rol r
 where r.kod = k.rol_kod and coalesce(r.portal_turu, 0) > 0;

-- -------------------------------------------------------- uygulama ----
create or replace function public.fn_kurum_tipi_rol_uygula(p_tip varchar)
returns integer
language plpgsql
as $function$
declare
    v_sayi integer;
begin
    if coalesce(p_tip, '') = '' then
        raise exception 'Kurum tipi boş olamaz.' using errcode = 'GK422';
    end if;

    update public.rol r
       set aktif = k.gecerli,
           degistirme_tarihi = now()
      from public.kurum_tipi_rol k
     where k.kurum_tipi = p_tip
       and k.rol_kod = r.kod
       and r.aktif <> k.gecerli
       and r.kod not in ('yonetici', 'atanmamis')
       -- PORTAL ROLU KURUM ICI KADRO DEGILDIR (829): kurum tipi haritasi onu
       --   kapatmamali. Kapali portal rolu = disaridan giris yapan hekim,
       --   kurum ve hastanin hepsinin birden kapisinin kapanmasi.
       and coalesce(r.portal_turu, 0) = 0;

    get diagnostics v_sayi = row_count;
    return v_sayi;
end $function$;

comment on function public.fn_kurum_tipi_rol_uygula is
  '786/829: kurum_tipi_rol haritasini rol.aktif alanina yazan TEK yer. '
  'Haritada olmayan role, yonetici/atanmamis''a ve PORTAL rollerine dokunmaz.';

-- ------------------------------------------------------------ tetik ----
-- Haritaya portal rolu yazilmasin: uygulama kati filtreliyor ama harita
--   betikle ya da eski surumle de doldurulabiliyor. Sessizce ATLANIR
--   (hata degil): toplu yazan cagri tek satir yuzunden durmasin.
create or replace function public.fn_kurum_tipi_rol_portal_atla()
returns trigger language plpgsql as $$
begin
    if exists (select 1 from public.rol r
                where r.kod = new.rol_kod and coalesce(r.portal_turu, 0) > 0) then
        return null;
    end if;
    return new;
end $$;

comment on function public.fn_kurum_tipi_rol_portal_atla is
  '829: portal rolu kurum tipi rol haritasina girmez - sessizce atlanir.';

drop trigger if exists tg_kurum_tipi_rol_portal on public.kurum_tipi_rol;
create trigger tg_kurum_tipi_rol_portal
before insert or update on public.kurum_tipi_rol
for each row execute function public.fn_kurum_tipi_rol_portal_atla();

do $$
declare v_yedek integer; v_kapali integer;
begin
    select count(*) into v_yedek from public.kurum_tipi_rol_portal_yedek_829;
    select count(*) into v_kapali from public.rol
     where coalesce(portal_turu, 0) > 0 and aktif = 0;
    raise notice '829 tamam: % portal satiri haritadan cikarildi (yedek: '
                 'kurum_tipi_rol_portal_yedek_829). Kapali portal rolu: %.',
                 v_yedek, v_kapali;
end $$;
