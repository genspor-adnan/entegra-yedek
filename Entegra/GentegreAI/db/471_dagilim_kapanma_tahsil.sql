-- =====================================================================
-- 471 - KAPANMA, TAHSİLAT VE KASA DAĞITIMI BEŞ KOVAYA GEÇTİ
--
-- 470 dağılımı ayrı tabloya aldı; kapanma (dönüşüm) ve tahsilat hâlâ iki
-- kovadan (kurum/hasta) okuyordu. Bu göç okuyucuların hepsini
-- `belge_satir_dagilim` üzerine alır.
--
-- PAY KODU İNCELDİ: 1 hasta_provizyon · 2 sgk · 3 oss · 4 hasta_ek_katki ·
-- 5 sgk_katilim_payi. Eski 1/2, 470'te aynı kuralla ikiye ayrılmıştı; burada
-- `kasa_islem_dagitim` ve `hakedis_satir` da aynı eşlemeyle taşınır.
--
-- KATILIM PAYI (pay 5) tahsil edilir ama SATIR TUTARINDA YOKTUR: sınır kendi
-- kovasından okunur, ciro toplamına girmez.
-- =====================================================================

create table if not exists public._yedek_kasa_dagitim_pay_471 (
    dagitim_id integer primary key,
    eski_pay   smallint not null,
    yeni_pay   smallint not null,
    tarih      timestamp not null default now()
);

-- ---------------------------------------------------------- kasa dağıtımı --
insert into public._yedek_kasa_dagitim_pay_471 (dagitim_id, eski_pay, yeni_pay)
select d.id, d.pay,
       case when d.pay = 2 then (case when dg.sgk > 0 then 2 else 3 end)
            else (case when dg.hasta_provizyon > 0 then 1 else 4 end) end
  from public.kasa_islem_dagitim d
  join public.belge_satir_dagilim dg on dg.belge_satir_id = d.belge_satir_id
 where d.pay in (1, 2)
on conflict (dagitim_id) do nothing;

update public.kasa_islem_dagitim d
   set pay = y.yeni_pay
  from public._yedek_kasa_dagitim_pay_471 y
 where y.dagitim_id = d.id and d.pay = y.eski_pay and d.pay <> y.yeni_pay;

-- ------------------------------------------------------------- tahsilat --
-- Beş kova, beş sayaç. Kova adı kolon adını verir; pay kodu ile kolon
--   arasındaki eşleme TEK yerde (burada) durur.
create or replace function public.fn_belge_satir_tahsil_tazele(p_satir_id integer)
returns void language plpgsql as $$
begin
    if coalesce(p_satir_id, 0) = 0 then return; end if;

    update public.belge_satir_dagilim dg
       set hasta_provizyon_tahsil = coalesce(x.p1, 0),
           sgk_tahsil             = coalesce(x.p2, 0),
           oss_tahsil             = coalesce(x.p3, 0),
           hasta_ek_katki_tahsil  = coalesce(x.p4, 0),
           sgk_katilim_tahsil     = coalesce(x.p5, 0)
      from (
        select sum(d.tutar) filter (where d.pay = 1) as p1,
               sum(d.tutar) filter (where d.pay = 2) as p2,
               sum(d.tutar) filter (where d.pay = 3) as p3,
               sum(d.tutar) filter (where d.pay = 4) as p4,
               sum(d.tutar) filter (where d.pay = 5) as p5
          from public.kasa_islem_dagitim d
          join public.kasa_islem k on k.id = d.kasa_islem_id
         where d.belge_satir_id = p_satir_id
           and coalesce(k.durum, 0) = 2
           and k.iptal_islem_id is null
      ) x
     where dg.belge_satir_id = p_satir_id;

    -- ESKİ KOLONLAR 474'e kadar okunuyor: iki yol da doğru göstersin.
    update public.belge_satir s
       set hasta_tahsil = coalesce(dg.hasta_provizyon_tahsil, 0)
                        + coalesce(dg.hasta_ek_katki_tahsil, 0),
           kurum_tahsil = coalesce(dg.sgk_tahsil, 0) + coalesce(dg.oss_tahsil, 0)
      from public.belge_satir_dagilim dg
     where s.id = p_satir_id and dg.belge_satir_id = s.id;
end $$;

comment on function public.fn_belge_satir_tahsil_tazele(integer) is
  'Satırın kova bazlı tahsilat sayaçları (471). Katılım payı (pay 5) ayrı sayılır - ciro değildir.';

-- ------------------------------------------------------------ kapatma --
create or replace function public.fn_belge_satir_kapatma_tazele(p_satir_id integer)
returns void
language plpgsql as $function$
declare
  v_belge   integer;
  v_miktar  numeric(19,6);
  v_p1 numeric(19,4); v_p2 numeric(19,4); v_p3 numeric(19,4); v_p4 numeric(19,4);
  v_toplam  numeric(19,4);
begin
    if p_satir_id is null or p_satir_id = 0 then return; end if;

    -- Pay TAŞIMAYAN hedefler miktarı kapatır (klasik sipariş → irsaliye/fatura).
    select coalesce(sum(h.miktar) filter (where coalesce(h.pay, 0) = 0), 0),
           coalesce(sum(h.tutar)  filter (where h.pay = 1), 0),
           coalesce(sum(h.tutar)  filter (where h.pay = 2), 0),
           coalesce(sum(h.tutar)  filter (where h.pay = 3), 0),
           coalesce(sum(h.tutar)  filter (where h.pay = 4), 0)
      into v_miktar, v_p1, v_p2, v_p3, v_p4
      from public.belge_satir h
     where h.kaynak_tur = 30 and h.kaynak_id = p_satir_id;

    update public.belge_satir_dagilim dg
       set sgk_kapatilan             = v_p2,
           oss_kapatilan             = v_p3,
           hasta_provizyon_kapatilan = v_p1,
           hasta_ek_katki_kapatilan  = v_p4
     where dg.belge_satir_id = p_satir_id;

    select coalesce(dg.sgk + dg.oss + dg.hasta_provizyon + dg.hasta_ek_katki, 0)
      into v_toplam
      from public.belge_satir_dagilim dg where dg.belge_satir_id = p_satir_id;

    update public.belge_satir k
       set kapatilan_miktar = case
             -- Dağılımlı satır: bütün kovalar kapandıysa miktar da kapanmıştır.
             when coalesce(v_toplam, 0) > 0
              and (v_p1 + v_p2 + v_p3 + v_p4) >= coalesce(v_toplam, 0) - 0.005 then k.miktar
             when coalesce(v_toplam, 0) > 0 then v_miktar
             else v_miktar end,
           -- Eski kolonlar 474'e kadar yaşıyor.
           hasta_kapatilan = v_p1 + v_p4,
           kurum_kapatilan = v_p2 + v_p3
     where k.id = p_satir_id
    returning k.belge_id into v_belge;

    if v_belge is null then
        select belge_id into v_belge from public.belge_satir where id = p_satir_id;
    end if;
    if v_belge is null then return; end if;

    perform public.fn_belge_kapanma_tazele(v_belge);
end $function$;

-- Belge kapanma durumu: dağılımlı satırda kalan = Σ(kova − kapatılan).
create or replace function public.fn_belge_kapanma_tazele(p_belge_id integer)
returns void
language plpgsql as $function$
begin
    if coalesce(p_belge_id, 0) = 0 then return; end if;

    update public.belge b
       set kapanma_durum = x.durum
      from (
        select case
                 when count(*) = 0 then 0
                 when sum(case when kalan > 0 then 1 else 0 end) = 0 then 2
                 when sum(kapanan) > 0 then 1
                 else 0
               end as durum
          from (
            select case when s.kalan_miktar <= 0 then 0
                        when coalesce(dg.sgk + dg.oss + dg.hasta_provizyon
                                    + dg.hasta_ek_katki, 0) > 0
                        then greatest(dg.sgk - dg.sgk_kapatilan, 0)
                           + greatest(dg.oss - dg.oss_kapatilan, 0)
                           + greatest(dg.hasta_provizyon - dg.hasta_provizyon_kapatilan, 0)
                           + greatest(dg.hasta_ek_katki - dg.hasta_ek_katki_kapatilan, 0)
                        else s.kalan_miktar end as kalan,
                   case when coalesce(dg.sgk + dg.oss + dg.hasta_provizyon
                                    + dg.hasta_ek_katki, 0) > 0
                        then dg.sgk_kapatilan + dg.oss_kapatilan
                           + dg.hasta_provizyon_kapatilan + dg.hasta_ek_katki_kapatilan
                             + case when s.kapatilan_miktar > 0 then 1 else 0 end
                        else s.kapatilan_miktar end as kapanan
              from public.belge_satir s
              left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
             where s.belge_id = p_belge_id
          ) y
      ) x
     where b.id = p_belge_id
       and b.kapanma_durum is distinct from x.durum;
end $function$;

-- --------------------------------------------------------- açık satır view --
-- Kolon adlari degistigi icin view YENIDEN kurulur: PG "create or
--   replace" ile ad degistirmeye izin vermez.
drop view if exists public.v_belge_acik_satir;
create view public.v_belge_acik_satir as
select s.id            as satir_id,
       s.belge_id,
       b.tur           as belge_tur,
       kt.ad           as belge_tur_adi,
       b.belge_no,
       b.belge_tarihi,
       b.taraf_id,
       b.taraf_unvan,
       b.belge_dovizi,
       b.sube_id,
       s.sira,
       s.tur           as satir_tur,
       s.stok_id, st.kod as stok_kodu, st.ad as stok_adi,
       s.hizmet_id, s.masraf_id,
       s.aciklama,
       s.miktar,
       s.kapatilan_miktar,
       s.kalan_miktar,
       s.birim,
       s.birim_fiyat,
       s.iskonto,
       s.kdv,
       b.kapanma_durum,
       coalesce(dg.rota, 1)                as rota,
       coalesce(dg.sgk, 0)                 as sgk,
       coalesce(dg.oss, 0)                 as oss,
       coalesce(dg.hasta_provizyon, 0)     as hasta_provizyon,
       coalesce(dg.hasta_ek_katki, 0)      as hasta_ek_katki,
       coalesce(dg.sgk_katilim_payi, 0)    as sgk_katilim_payi,
       greatest(coalesce(dg.sgk, 0) - coalesce(dg.sgk_kapatilan, 0), 0) as sgk_kalan,
       greatest(coalesce(dg.oss, 0) - coalesce(dg.oss_kapatilan, 0), 0) as oss_kalan,
       greatest(coalesce(dg.hasta_provizyon, 0)
              - coalesce(dg.hasta_provizyon_kapatilan, 0), 0) as hasta_provizyon_kalan,
       greatest(coalesce(dg.hasta_ek_katki, 0)
              - coalesce(dg.hasta_ek_katki_kapatilan, 0), 0)  as hasta_ek_katki_kalan,
       coalesce(st.kod, hz.kod, ms.kod, '') as kalem_kodu,
       coalesce(st.ad,  hz.ad,  ms.ad,  '') as kalem_adi,
       s.tutar,
       -- Tahsil edilen MATRAH: tahsilat KDV dahil dağıtılır (321), kovalar
       --   matrahtır; öneri aynı düzlemde olsun.
       round(coalesce(dg.hasta_provizyon_tahsil + dg.hasta_ek_katki_tahsil, 0)
             / (1 + coalesce(s.kdv, 0) / 100.0), 4) as hasta_tahsil_matrah,
       round(coalesce(dg.sgk_tahsil + dg.oss_tahsil, 0)
             / (1 + coalesce(s.kdv, 0) / 100.0), 4) as kurum_tahsil_matrah,
       case when coalesce(dg.sgk + dg.oss + dg.hasta_provizyon + dg.hasta_ek_katki, 0) > 0
            then greatest(coalesce(dg.sgk, 0) - coalesce(dg.sgk_kapatilan, 0), 0)
               + greatest(coalesce(dg.oss, 0) - coalesce(dg.oss_kapatilan, 0), 0)
               + greatest(coalesce(dg.hasta_provizyon, 0)
                        - coalesce(dg.hasta_provizyon_kapatilan, 0), 0)
               + greatest(coalesce(dg.hasta_ek_katki, 0)
                        - coalesce(dg.hasta_ek_katki_kapatilan, 0), 0)
            when s.miktar > 0 then round(s.tutar * s.kalan_miktar / s.miktar, 4)
            else 0 end                       as tutar_kalan
  from public.belge_satir s
  join public.belge b on b.id = s.belge_id
  left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
  left join public.kasa_islem_turu kt on kt.kod = b.tur
  left join public.stok   st on st.id = s.stok_id
  left join public.hizmet hz on hz.id = s.hizmet_id
  left join public.masraf ms on ms.id = s.masraf_id
 where (   coalesce(dg.sgk + dg.oss + dg.hasta_provizyon + dg.hasta_ek_katki, 0) = 0
           and s.kalan_miktar > 0
        or coalesce(dg.sgk + dg.oss + dg.hasta_provizyon + dg.hasta_ek_katki, 0) > 0
           and (dg.sgk - dg.sgk_kapatilan > 0
             or dg.oss - dg.oss_kapatilan > 0
             or dg.hasta_provizyon - dg.hasta_provizyon_kapatilan > 0
             or dg.hasta_ek_katki - dg.hasta_ek_katki_kapatilan > 0))
   and b.durum = 0;

-- ------------------------------------------------------- tahsilat view --
-- Kolon adlari degistigi icin view YENIDEN kurulur: PG "create or
--   replace" ile ad degistirmeye izin vermez.
drop view if exists public.v_belge_satir_tahsilat;
create view public.v_belge_satir_tahsilat as
select s.id                                   as satir_id,
       s.belge_id,
       s.sira,
       coalesce(nullif(hz.ad, ''), nullif(st.ad, ''), nullif(s.aciklama, ''), '')
                                              as kalem,
       coalesce(nullif(hz.kod, ''), nullif(st.kod, ''), '')
                                              as kalem_kod,
       s.miktar,
       s.tutar,
       coalesce(s.kdv, 0)                     as kdv,
       coalesce(dg.rota, 1)                   as rota,
       -- MATRAH (KDV hariç) - prim tabanı bu.
       coalesce(dg.hasta_provizyon, 0)        as hasta_provizyon_matrah,
       coalesce(dg.sgk, 0)                    as sgk_matrah,
       coalesce(dg.oss, 0)                    as oss_matrah,
       coalesce(dg.hasta_ek_katki, 0)         as hasta_ek_katki_matrah,
       coalesce(dg.sgk_katilim_payi, 0)       as sgk_katilim_matrah,
       -- ÖDENECEK (KDV dahil) - tahsilat ve dağıtım tabanı bu.
       round(coalesce(dg.hasta_provizyon, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 2)
                                              as hasta_provizyon_tutar,
       round(coalesce(dg.sgk, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 2) as sgk_tutar,
       round(coalesce(dg.oss, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 2) as oss_tutar,
       round(coalesce(dg.hasta_ek_katki, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 2)
                                              as hasta_ek_katki_tutar,
       -- KATILIM PAYI KDV'siz tahsil edilir: hastanenin geliri değil, emanet.
       coalesce(dg.sgk_katilim_payi, 0)       as sgk_katilim_tutar,
       coalesce(dg.hasta_provizyon_tahsil, 0) as hasta_provizyon_tahsil,
       coalesce(dg.sgk_tahsil, 0)             as sgk_tahsil,
       coalesce(dg.oss_tahsil, 0)             as oss_tahsil,
       coalesce(dg.hasta_ek_katki_tahsil, 0)  as hasta_ek_katki_tahsil,
       coalesce(dg.sgk_katilim_tahsil, 0)     as sgk_katilim_tahsil,
       greatest(round(coalesce(dg.hasta_provizyon, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 2)
                - coalesce(dg.hasta_provizyon_tahsil, 0), 0) as hasta_provizyon_kalan,
       greatest(round(coalesce(dg.sgk, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 2)
                - coalesce(dg.sgk_tahsil, 0), 0)             as sgk_kalan,
       greatest(round(coalesce(dg.oss, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 2)
                - coalesce(dg.oss_tahsil, 0), 0)             as oss_kalan,
       greatest(round(coalesce(dg.hasta_ek_katki, 0) * (1 + coalesce(s.kdv, 0) / 100.0), 2)
                - coalesce(dg.hasta_ek_katki_tahsil, 0), 0)  as hasta_ek_katki_kalan,
       greatest(coalesce(dg.sgk_katilim_payi, 0)
                - coalesce(dg.sgk_katilim_tahsil, 0), 0)     as sgk_katilim_kalan,
       -- PRİM TABANI: tahsil edilenin KDV'siz karşılığı.
       round((coalesce(dg.hasta_provizyon_tahsil, 0) + coalesce(dg.hasta_ek_katki_tahsil, 0))
             / (1 + coalesce(s.kdv, 0) / 100.0), 4) as hasta_tahsil_matrah,
       round((coalesce(dg.sgk_tahsil, 0) + coalesce(dg.oss_tahsil, 0))
             / (1 + coalesce(s.kdv, 0) / 100.0), 4) as kurum_tahsil_matrah,
       s.hizmet_id,
       s.stok_id
  from public.belge_satir s
  left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
  left join public.hizmet hz on hz.id = s.hizmet_id
  left join public.stok st on st.id = s.stok_id
 order by s.sira, s.id;

-- --------------------------------------------------- kasa dağıtım kontrolü --
create or replace function public.tg_kasa_dagitim_kontrol()
returns trigger language plpgsql as $$
declare
  v_pay_tutar numeric(19,4);
  v_dagitilan numeric(19,4);
  v_islem     numeric(19,4);
begin
    if new.tutar <= 0 then
        raise exception 'Dağıtılan tutar sıfırdan büyük olmalı.' using errcode = 'GK422';
    end if;
    if new.pay not in (1, 2, 3, 4, 5) then
        raise exception 'Bilinmeyen ödeme payı: %.', new.pay using errcode = 'GK422';
    end if;

    -- KDV DAHİL kova sınırı (323): tahsilat gerçek ödemedir, matrahla
    --   sınırlanamaz. KATILIM PAYI istisnadır - KDV'siz emanettir.
    select case new.pay
             when 5 then coalesce(dg.sgk_katilim_payi, 0)
             else round(case new.pay
                          when 1 then coalesce(dg.hasta_provizyon, 0)
                          when 2 then coalesce(dg.sgk, 0)
                          when 3 then coalesce(dg.oss, 0)
                          else coalesce(dg.hasta_ek_katki, 0) end
                        * (1 + coalesce(s.kdv, 0) / 100.0), 2)
           end
      into v_pay_tutar
      from public.belge_satir s
      left join public.belge_satir_dagilim dg on dg.belge_satir_id = s.id
     where s.id = new.belge_satir_id;

    select coalesce(sum(d.tutar), 0) into v_dagitilan
      from public.kasa_islem_dagitim d
      join public.kasa_islem k on k.id = d.kasa_islem_id
     where d.belge_satir_id = new.belge_satir_id and d.pay = new.pay
       and d.id is distinct from new.id
       and coalesce(k.durum, 0) = 2 and k.iptal_islem_id is null;

    if coalesce(v_pay_tutar, 0) > 0 and v_dagitilan + new.tutar > v_pay_tutar + 0.005 then
        raise exception 'Satıra payından fazla tahsilat dağıtılamaz (pay %, dağıtılan %, eklenen %).',
            v_pay_tutar, v_dagitilan, new.tutar using errcode = 'GK422';
    end if;

    select coalesce(k.tutar, 0) into v_islem
      from public.kasa_islem k where k.id = new.kasa_islem_id;

    select coalesce(sum(d.tutar), 0) into v_dagitilan
      from public.kasa_islem_dagitim d
     where d.kasa_islem_id = new.kasa_islem_id and d.id is distinct from new.id;

    if v_dagitilan + new.tutar > v_islem + 0.005 then
        raise exception 'Dağıtım toplamı işlem tutarını aşamaz (işlem %, dağıtılan %).',
            v_islem, v_dagitilan + new.tutar using errcode = 'GK422';
    end if;

    return new;
end $$;

-- Göç sonrası sayaçlar yeniden hesaplanır: eski kolonlardan gelen değerler
--   kova kova doğrulansın.
do $$
declare r record; v_sayi integer := 0;
begin
    for r in select distinct d.belge_satir_id
               from public.kasa_islem_dagitim d
              where d.belge_satir_id is not null
    loop
        perform public.fn_belge_satir_tahsil_tazele(r.belge_satir_id);
        v_sayi := v_sayi + 1;
    end loop;
    raise notice '471 tamam: % satirin tahsilat sayaci tazelendi, % dagitim payi tasindi',
        v_sayi, (select count(*) from public._yedek_kasa_dagitim_pay_471);
end $$;
