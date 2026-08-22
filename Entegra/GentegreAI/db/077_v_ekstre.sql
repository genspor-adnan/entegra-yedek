-- ============================================================================
--  Gentegre AI — Kasa alt sistemi / EKSTRE GORUNUMLERI
--  077_v_ekstre.sql  —  v_mali_hareket_ek, v_cari_ekstre, v_hesap_ekstre,
--                       v_hesap_bakiye, v_proje_ekstre, v_masraf_ekstre,
--                       v_plan_vade, fn_mizan
--
--  SIHIRLI ARALIK YOK: legacy ekstreleri "TUR NOT BETWEEN 40 AND 79 except
--    49/61/71" gibi sabit araliklarla suzuyordu (SQL'in 6 ayri yerinde,
--    birbirinden kayarak). Burada ayni karar kasa_islem_turu bayraklarindan
--    okunur: cari_ekstre / hesap_ekstre / bakiye_dahil.
--
--  ISARET (K4): hesap bacaginda borc = hesaba GIRIS. Hesap ekstresinde bu
--    "giris" sutunu olarak gosterilir - legacy'nin "ekranda ters cevir"
--    hilesine gerek kalmaz.
-- ============================================================================
\set ON_ERROR_STOP on

-- --------------------------------------------------------- temel gorunum ----
create or replace view public.v_mali_hareket_ek as
select m.id,
       m.kasa_islem_id,
       m.sira,
       m.tur,
       t.ad            as tur_adi,
       t.grup          as tur_grup,
       t.cari_ekstre,
       t.hesap_ekstre,
       t.bakiye_dahil,
       m.hesap_turu,
       m.hesap_id,
       h.ad            as hesap_adi,
       h.doviz_cinsi   as hesap_dovizi,
       m.taraf_id,
       coalesce(nullif(ki.taraf_unvan, ''), tr.unvan, '') as taraf_unvan,
       m.belge_id,
       m.belge_no,
       coalesce(ki.islem_no, '')  as islem_no,
       m.islem_tarihi,
       m.plan_tarihi,
       m.borc,
       m.alacak,
       m.doviz_cinsi,
       m.doviz_kuru,
       m.yerel_borc,
       m.yerel_alacak,
       m.masraf_id,
       ma.ad           as masraf_adi,
       m.hizmet_id,
       hz.ad           as hizmet_adi,
       coalesce(m.proje_id, ki.proje_id) as proje_id,
       p.ad            as proje_adi,
       m.merkez_id,
       m.cek_senet_id,
       m.aciklama,
       m.sube_id,
       coalesce(ki.durum, 2) as islem_durum      -- baslik yoksa (fatura kaynakli) gerceklesmis sayilir
  from public.mali_hareket m
  join public.kasa_islem_turu t on t.kod = m.tur
  left join public.kasa_islem ki on ki.id = m.kasa_islem_id
  left join public.hesap      h  on h.id  = m.hesap_id
  left join public.taraf      tr on tr.id = m.taraf_id
  left join public.masraf     ma on ma.id = m.masraf_id
  left join public.hizmet     hz on hz.id = m.hizmet_id
  left join public.proje      p  on p.id  = coalesce(m.proje_id, ki.proje_id);

comment on view public.v_mali_hareket_ek is
  'Bacak + tur katalogu + baslik + hesap/taraf/kalem adlari. Tum ekstre gorunumleri bunun uzerine kurulur.';

-- ------------------------------------------------------------ cari ekstre ----
-- Taslak (0) ve iptal (3) haric; plan (1) GORUNUR ama bakiyeye girmez.
create or replace view public.v_cari_ekstre as
select e.id, e.taraf_id, e.taraf_unvan, e.islem_tarihi, e.plan_tarihi, e.tur, e.tur_adi, e.tur_grup,
       e.islem_no, e.belge_no, e.belge_id, e.aciklama,
       e.doviz_cinsi, e.borc, e.alacak, e.doviz_kuru,
       e.yerel_borc, e.yerel_alacak, e.bakiye_dahil, e.proje_id, e.sube_id,
       sum(case when e.bakiye_dahil = 1 then e.yerel_borc - e.yerel_alacak else 0 end)
           over (partition by e.taraf_id order by e.islem_tarihi, e.id
                 rows between unbounded preceding and current row) as yerel_bakiye,
       sum(case when e.bakiye_dahil = 1 then e.borc - e.alacak else 0 end)
           over (partition by e.taraf_id, e.doviz_cinsi order by e.islem_tarihi, e.id
                 rows between unbounded preceding and current row) as doviz_bakiye
  from public.v_mali_hareket_ek e
 where e.hesap_turu = 'C'
   and e.taraf_id is not null
   and e.cari_ekstre = 1
   and e.islem_durum in (1, 2);

comment on view public.v_cari_ekstre is
  'Cari hesap ekstresi. Yuruyen bakiye yalniz bakiye_dahil=1 satirlari toplar (plan satiri gorunur, bakiyeyi degistirmez).';

-- ----------------------------------------------------------- hesap ekstre ----
create or replace view public.v_hesap_ekstre as
select e.id, e.hesap_id, e.hesap_adi, e.hesap_dovizi, e.islem_tarihi, e.tur, e.tur_adi,
       e.islem_no, e.belge_no, e.taraf_id, e.taraf_unvan, e.aciklama,
       e.doviz_cinsi, e.doviz_kuru,
       e.borc   as giris,          -- K4: hesap bacaginda borc = hesaba giris
       e.alacak as cikis,
       e.yerel_borc, e.yerel_alacak, e.proje_id, e.sube_id,
       sum(e.borc - e.alacak)
           over (partition by e.hesap_id order by e.islem_tarihi, e.id
                 rows between unbounded preceding and current row) as bakiye,
       sum(e.yerel_borc - e.yerel_alacak)
           over (partition by e.hesap_id order by e.islem_tarihi, e.id
                 rows between unbounded preceding and current row) as yerel_bakiye
  from public.v_mali_hareket_ek e
 where e.hesap_id is not null
   and e.hesap_ekstre = 1
   and e.islem_durum = 2;

comment on view public.v_hesap_ekstre is
  'Kasa / banka / POS / kredi karti hesap ekstresi. bakiye hesabin KENDI dovizinde, yerel_bakiye TL.';

create or replace view public.v_hesap_bakiye as
select h.id as hesap_id, h.tur, h.kod, h.ad, h.doviz_cinsi, h.sube_id, h.durum,
       coalesce(sum(m.borc - m.alacak), 0)             as bakiye,
       coalesce(sum(m.yerel_borc - m.yerel_alacak), 0) as yerel_bakiye,
       count(m.id)                                     as hareket_adedi,
       max(m.islem_tarihi)                             as son_hareket
  from public.hesap h
  left join public.v_mali_hareket_ek m
         on m.hesap_id = h.id and m.hesap_ekstre = 1 and m.islem_durum = 2
 group by h.id, h.tur, h.kod, h.ad, h.doviz_cinsi, h.sube_id, h.durum;

comment on view public.v_hesap_bakiye is 'Hesap bazli guncel bakiye ozeti (dashboard / hesap listesi kolonu).';

-- ----------------------------------------------------------- proje ekstre ----
create or replace view public.v_proje_ekstre as
select e.id, e.proje_id, e.islem_tarihi, e.tur, e.tur_adi, e.tur_grup,
       e.islem_no, e.belge_no, e.taraf_id, e.taraf_unvan, e.aciklama,
       e.masraf_id, e.masraf_adi, e.hizmet_id, e.hizmet_adi,
       e.doviz_cinsi, e.borc, e.alacak, e.yerel_borc, e.yerel_alacak,
       case when e.hizmet_id is not null then e.yerel_alacak else 0 end as gelir,
       case when e.masraf_id is not null then e.yerel_borc   else 0 end as gider,
       e.sube_id
  from public.v_mali_hareket_ek e
 where e.proje_id is not null
   and e.islem_durum = 2;

comment on view public.v_proje_ekstre is 'Proje bazli gelir/gider hareketleri (eski PROJEMALIYET + proje ekstresi).';

-- ---------------------------------------------------- masraf/gelir ekstre ----
create or replace view public.v_masraf_ekstre as
select e.id, e.masraf_id, e.hizmet_id, e.masraf_adi, e.hizmet_adi,
       e.islem_tarihi, e.tur, e.tur_adi, e.islem_no, e.taraf_id, e.taraf_unvan,
       e.aciklama, e.doviz_cinsi, e.borc, e.alacak, e.yerel_borc, e.yerel_alacak,
       e.proje_id, e.merkez_id, e.sube_id
  from public.v_mali_hareket_ek e
 where (e.masraf_id is not null or e.hizmet_id is not null)
   and e.islem_durum = 2;

comment on view public.v_masraf_ekstre is 'Masraf / gelir kalemi bazli hareket dokumu.';

-- -------------------------------------------------------------- plan vade ----
create or replace view public.v_plan_vade as
select ki.id, ki.tur, t.ad as tur_adi, t.grup as tur_grup,
       ki.plan_tarihi, ki.taraf_id,
       coalesce(nullif(ki.taraf_unvan, ''), tr.unvan, '') as taraf_unvan,
       ki.doviz_cinsi, ki.tutar, ki.gerceklesen_tutar, ki.kalan_tutar,
       ki.yerel_tutar, ki.aciklama, ki.proje_id, ki.sube_id,
       (current_date - ki.plan_tarihi) as gecikme_gun
  from public.kasa_islem ki
  join public.kasa_islem_turu t on t.kod = ki.tur
  left join public.taraf tr on tr.id = ki.taraf_id
 where ki.durum = 1;

comment on view public.v_plan_vade is 'Acik tahsilat/odeme planlari; gecikme_gun pozitifse vadesi gecmis.';

-- ------------------------------------------------------------------ mizan ----
create or replace function public.fn_mizan(p_bas date, p_bit date)
returns table (
    hesap_plani_id integer,
    kod            varchar,
    ad             varchar,
    borc           numeric,
    alacak         numeric,
    bakiye         numeric
)
language sql stable
as $$
    select hp.id, hp.kod, hp.ad,
           coalesce(sum(fs.borc), 0)   as borc,
           coalesce(sum(fs.alacak), 0) as alacak,
           coalesce(sum(fs.borc - fs.alacak), 0) as bakiye
      from public.hesap_plani hp
      left join public.muhasebe_fis_satir fs on fs.hesap_plani_id = hp.id
      left join public.muhasebe_fis f on f.id = fs.fis_id
                                     and f.durum in (1, 3)
                                     and f.fis_tarihi between p_bas and p_bit
     where hp.calisir_mi = 1
     group by hp.id, hp.kod, hp.ad
    having coalesce(sum(fs.borc), 0) <> 0 or coalesce(sum(fs.alacak), 0) <> 0
     order by hp.kod;
$$;

comment on function public.fn_mizan(date, date) is
  'Tarih araligi mizani. Iptal edilmis fis (durum=2) haric; ters fis (3) DAHIL - net etkiyi gosterir.';

-- ------------------------------------------------------------- dogrulama ----
do $$
declare v integer;
begin
    select count(*) into v from information_schema.views
     where table_schema = 'public'
       and table_name in ('v_mali_hareket_ek','v_cari_ekstre','v_hesap_ekstre','v_hesap_bakiye',
                          'v_proje_ekstre','v_masraf_ekstre','v_plan_vade');
    raise notice '077 tamam: % / 7 gorunum kuruldu', v;
end $$;
