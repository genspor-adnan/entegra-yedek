-- =====================================================================
--  578_basvuru_hekim_kaynagi.sql
--  Başvurudaki hekim listesi PRİM ROLÜNDEN KURTARILIR; kaynak KURUM PROFİLİNE
--  göre seçilir.
--
--  Kullanıcı: "kural şu: prim alsa da almasa da — eğer kurum profili
--  laboratuvar ve/veya görüntüleme merkezi ise bölüm ve doktor kısmına dış
--  doktorlar gelir; profil bunların dışında ise personelden randevu
--  verilebilir olanlar gelecek."
--
--  ESKİ DAVRANIŞ: hekim combosu `prim-rol-aday`dan besleniyordu, yani kişi
--  ancak PRİM ROLÜ işaretliyse listeye giriyordu. Prim, hekimin kim olduğuyla
--  ilgili değil ÜCRETLENDİRMEYLE ilgili bir karar - biri prim almasa da
--  başvuruyu karşılayan hekimdir. 573'ten sonra bu tam da ısırdı: yeni
--  hekimlerin prim rolü yoktu, liste boş geldi.
--
--  YENİ KURAL tek bir görünümde:
--    profil lab / goruntuleme / goruntuleme_lab  -> DIŞ HEKİMLER
--    ötekiler (tıp merkezi, hastane, muayenehane…) -> kendi personelinden
--                                                     randevu verilebilirler
--  Bölüm süzgeci her iki tarafta AYNI alandan çalışır: `taraf.departman`
--  (577'de dış hekim de bu alanı kullanmaya başladı).
-- =====================================================================

create or replace function public.fn_basvuru_hekim_dis_mi(p_sube integer default 0)
returns smallint language sql stable as $$
    select case when p.kurum_tipi in ('lab', 'goruntuleme', 'goruntuleme_lab')
                then 1::smallint else 0::smallint end
      from public.fn_kurum_profil(p_sube) p;
$$;

comment on function public.fn_basvuru_hekim_dis_mi(integer) is
  'Basvuruda hekim listesi DIS hekimlerden mi gelsin (578): lab/goruntuleme '
  'subesinde 1, digerlerinde 0.';

create or replace view public.v_basvuru_hekim as
-- DIS HEKIMLER (lab / goruntuleme profili)
select t.id,
       t.unvan                              as ad,
       coalesce(t.departman, 0)             as bolum_id,
       coalesce(t.durum::integer, 1)        as durum,
       1::smallint                          as dis_mi
  from public.taraf t
  join public.taraf_personel p on p.id = t.id
 where t.personel = 1 and p.dis_hekim = 1
   and public.fn_basvuru_hekim_dis_mi(0) = 1
union all
-- KENDI PERSONELI (oteki profiller): randevu verilebilir olanlar
select t.id,
       t.unvan,
       coalesce(t.departman, 0),
       coalesce(t.durum::integer, 1),
       0::smallint
  from public.taraf t
 where t.personel = 1 and t.randevu_verilebilir = 1
   and public.fn_basvuru_hekim_dis_mi(0) = 0;

comment on view public.v_basvuru_hekim is
  'Basvuruda secilebilecek hekimler (578): profil lab/goruntuleme ise DIS '
  'hekimler, degilse randevu verilebilir personel. Prim rolu ARANMAZ.';
