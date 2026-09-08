-- =====================================================================
-- 478 - ESKİ PAY KOLONLARI DÜŞTÜ (kullanıcı: "eski pay kolonlarını düşür")
--
-- 470'ten beri ödeme dağılımı `belge_satir_dagilim`da; `belge_satir` üzerindeki
-- kurum/hasta payı kolonları API kesme yayınına kadar İKİNCİ KOPYA olarak
-- yazılıyordu. İki kopya bir süre sonra ayrışır - okuyanların hepsi dağılıma
-- geçtiğine göre kopya kaldırılır.
--
-- DÜŞENLER:
--   belge_satir : kurum_tutar · hasta_tutar · karsilama · kurum_kapatilan ·
--                 hasta_kapatilan · kurum_tahsil · hasta_tahsil
--   taraf_kurum : sozlesme_no · baslangic · bitis · durum · kampanya_id ·
--                 fiyat_listesi_id · faturalama_modu · paylasim_modu ·
--                 varsayilan_karsilama · aciklama   (hepsi kurum_sozlesme'de)
--
-- `taraf_kurum`da yalnız `tur` kalır: kurumun kendisine ait tek bilgi budur,
-- gerisi ANLAŞMAYA aittir ve bir kurumun birden çok anlaşması olur (468).
--
-- YEDEK: düşmeden önce satırlar yedek tablolara kopyalanır. Kurulumda veri
-- varsa geri dönülebilsin - kolon düşürmek geri alınamaz bir işlemdir.
-- =====================================================================

-- ------------------------------------------------------------- yedekler --
-- IDEMPOTENT: ikinci koşuda kolonlar zaten yok - `create table as select`
--   tabloyu atlasa bile sorguyu AYRIŞTIRIR ve "column does not exist" verir.
--   Bu yüzden yedekleme dinamik ve yalnız tablo yokken çalışır.
do $$
begin
    if to_regclass('public._yedek_belge_satir_pay_478') is null then
        execute 'create table public._yedek_belge_satir_pay_478 as
                 select id, kurum_tutar, hasta_tutar, karsilama, kurum_kapatilan,
                        hasta_kapatilan, kurum_tahsil, hasta_tahsil,
                        now() as yedek_tarihi
                   from public.belge_satir';
    end if;
    if to_regclass('public._yedek_taraf_kurum_sozlesme_478') is null then
        execute 'create table public._yedek_taraf_kurum_sozlesme_478 as
                 select id, sozlesme_no, baslangic, bitis, durum, kampanya_id,
                        fiyat_listesi_id, faturalama_modu, paylasim_modu,
                        varsayilan_karsilama, aciklama, now() as yedek_tarihi
                   from public.taraf_kurum';
    end if;
end $$;

-- ------------------------------------------- eski kolonlara yazan kurallar --
-- Kapatma / tahsilat tazeleme fonksiyonları 471'de eski kolonları da
--   dolduruyordu ("iki yol da doğru göstersin"). Kolonlar düştüğüne göre o
--   satırlar çıkarılır - yoksa fonksiyon "column does not exist" verir.
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
end $$;

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
             when coalesce(v_toplam, 0) > 0
              and (v_p1 + v_p2 + v_p3 + v_p4) >= coalesce(v_toplam, 0) - 0.005 then k.miktar
             when coalesce(v_toplam, 0) > 0 then v_miktar
             else v_miktar end
     where k.id = p_satir_id
    returning k.belge_id into v_belge;

    if v_belge is null then
        select belge_id into v_belge from public.belge_satir where id = p_satir_id;
    end if;
    if v_belge is null then return; end if;

    perform public.fn_belge_kapanma_tazele(v_belge);
end $function$;

-- Dağılım hesabı da eski kolonlara yazıyordu (474/476): o blok çıkarılır.
create or replace function public.fn_belge_satir_dagilim_hesapla(
    p_satir_id  integer,
    p_sgk_prov  numeric default null,
    p_oss_prov  numeric default null)
returns integer
language plpgsql as $$
declare
    s          record;
    v_rota     smallint;
    v_sgk_liste numeric := 0;
    v_huv      numeric := 0;
    v_ek       numeric := 0;
    v_katilim  numeric := 0;
    v_ham      numeric;
    v_kdvli    smallint;
    v_carpan   numeric;
    d          record;
    v_elle     smallint;
    v_donmus   numeric;
begin
    if coalesce(p_satir_id, 0) = 0 then return null; end if;

    select bs.id, bs.belge_id, bs.miktar, bs.tutar, bs.iskonto, bs.iskonto2, bs.kdv,
           bs.stok_id, bs.hizmet_id, bs.birim_fiyat,
           b.belge_tarihi::date as tarih,
           bb.odeyen_kurum_id, bb.sozlesme_id, bb.alt_kurum, bb.sgk_kullan,
           k.tur as kurum_tur,
           sz.fiyat_listesi_id, sz.sgk_fiyat_listesi_id, sz.varsayilan_karsilama
      into s
      from public.belge_satir bs
      join public.belge b on b.id = bs.belge_id
      left join public.belge_basvuru bb on bb.id = bs.belge_id
      left join public.taraf_kurum k on k.id = bb.odeyen_kurum_id
      left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
     where bs.id = p_satir_id;
    if not found then return null; end if;

    -- ELLE sabitlenmiş ya da PARASI DÖNMÜŞ dağılıma dokunulmaz.
    select dg.elle,
           dg.sgk_kapatilan + dg.oss_kapatilan + dg.hasta_provizyon_kapatilan
         + dg.hasta_ek_katki_kapatilan + dg.sgk_tahsil + dg.oss_tahsil
         + dg.hasta_provizyon_tahsil + dg.hasta_ek_katki_tahsil
         + dg.sgk_katilim_tahsil
      into v_elle, v_donmus
      from public.belge_satir_dagilim dg where dg.belge_satir_id = p_satir_id;
    if coalesce(v_elle, 0) = 1 or coalesce(v_donmus, 0) > 0 then
        return s.belge_id;
    end if;

    v_rota := public.fn_dagilim_rota(coalesce(s.kurum_tur, 1)::smallint,
                                     coalesce(s.alt_kurum, 0)::smallint,
                                     coalesce(s.sgk_kullan, 1)::smallint);

    v_carpan := coalesce(s.miktar, 0)
              * (1 - coalesce(s.iskonto, 0) / 100.0)
              * (1 - coalesce(s.iskonto2, 0) / 100.0);

    if s.sgk_fiyat_listesi_id is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(
                   s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id) f;
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(s.kdv, 0) / 100.0);
        end if;
        v_sgk_liste := round(coalesce(v_ham, 0) * v_carpan, 2);

        v_katilim := round(coalesce(public.fn_fiyat_listesi_katki(
                               s.sgk_fiyat_listesi_id, s.stok_id, s.hizmet_id), 0)
                           * coalesce(s.miktar, 0), 2);
        v_ek := public.fn_fiyat_listesi_ek_katki(s.sgk_fiyat_listesi_id,
                                                 s.stok_id, s.hizmet_id, v_sgk_liste);
    end if;

    if s.fiyat_listesi_id is not null then
        select f.fiyat, f.kdv_dahil into v_ham, v_kdvli
          from public.fn_fiyat_listesi_fiyat(
                   s.fiyat_listesi_id, s.stok_id, s.hizmet_id) f;
        if coalesce(v_kdvli, 0) = 1 then
            v_ham := coalesce(v_ham, 0) / (1 + coalesce(s.kdv, 0) / 100.0);
        end if;
        v_huv := round(coalesce(v_ham, 0) * v_carpan, 2);
    end if;

    if v_huv = 0 then v_huv := coalesce(s.tutar, 0); end if;

    select * into d from public.fn_belge_satir_dagit(
        v_rota, coalesce(s.tutar, 0), v_sgk_liste, v_huv, v_ek, v_katilim,
        p_sgk_prov, p_oss_prov, coalesce(s.varsayilan_karsilama, 0));

    if v_rota in (3, 5) and coalesce(s.miktar, 0) > 0
       and abs(coalesce(s.tutar, 0) - d.tutar) > 0.005 then
        update public.belge_satir
           set birim_fiyat = round(d.tutar / s.miktar, 4),
               tutar       = d.tutar,
               tutar_kdvli = round(d.tutar * (1 + coalesce(s.kdv, 0) / 100.0), 2)
         where id = p_satir_id;
    end if;

    insert into public.belge_satir_dagilim
           (belge_satir_id, rota, sgk_liste, huv_liste, sgk, oss,
            hasta_provizyon, hasta_ek_katki, sgk_katilim_payi, degistirme_tarihi)
    values (p_satir_id, v_rota, v_sgk_liste, v_huv, d.sgk, d.oss,
            d.hasta_provizyon, d.hasta_ek_katki, d.sgk_katilim_payi, now())
    on conflict (belge_satir_id) do update
       set rota = excluded.rota, sgk_liste = excluded.sgk_liste,
           huv_liste = excluded.huv_liste, sgk = excluded.sgk, oss = excluded.oss,
           hasta_provizyon = excluded.hasta_provizyon,
           hasta_ek_katki = excluded.hasta_ek_katki,
           sgk_katilim_payi = excluded.sgk_katilim_payi,
           degistirme_tarihi = now();

    return s.belge_id;
end $$;

-- Eski paylaşım fonksiyonu artık kimse tarafından çağrılmıyor ve
--   `taraf_kurum.paylasim_modu` düşecek: bırakılırsa kırık kalırdı.
drop function if exists public.fn_belge_satir_paylastir(numeric, numeric, integer, numeric);
drop function if exists public.fn_belge_satir_paylastir(numeric, numeric, integer);

-- 302'nin dört parametreli imzası `taraf_kurum.fiyat_listesi_id` okuyordu;
--   468 sözleşmeli sürümü yazdı. Eski imza düşürülür (varsayılanlar zaten
--   yeni sürümü karşılıyor).
drop function if exists public.fn_belge_varsayilan_liste(integer, integer, date, integer);

-- ------------------------------------------------------------ kolonlar --
alter table public.belge_satir
  drop column if exists kurum_tutar,
  drop column if exists hasta_tutar,
  drop column if exists karsilama,
  drop column if exists kurum_kapatilan,
  drop column if exists hasta_kapatilan,
  drop column if exists kurum_tahsil,
  drop column if exists hasta_tahsil;

-- v_kurum_lookup `taraf_kurum.durum` okuyordu: sözleşme durumuna geçer.
drop view if exists public.v_kurum_lookup;
create view public.v_kurum_lookup as
select t.id,
       case when t.kod = '' then t.unvan else t.kod || ' - ' || t.unvan end as ad,
       -- AKTİF = carisi açık VE yürürlükte en az bir sözleşmesi var (478).
       case when t.durum = 1
             and exists (select 1 from public.kurum_sozlesme s
                          where s.kurum_id = t.id and s.durum = 1
                            and (s.baslangic is null or s.baslangic <= current_date)
                            and (s.bitis is null or s.bitis >= current_date))
            then 1 else 0 end as aktif
  from public.taraf t
  join public.taraf_kurum k on k.id = t.id
 where t.kurum = 1;

alter table public.taraf_kurum
  drop column if exists sozlesme_no,
  drop column if exists baslangic,
  drop column if exists bitis,
  drop column if exists durum,
  drop column if exists kampanya_id,
  drop column if exists fiyat_listesi_id,
  drop column if exists faturalama_modu,
  drop column if exists paylasim_modu,
  drop column if exists varsayilan_karsilama,
  drop column if exists aciklama;

-- Pay hesaplama modu kod listesi de anlamını yitirdi: rota sözleşmeden çıkar.
do $$
declare v_liste integer;
begin
    select id into v_liste from public.kod_liste where kod = 'kurum.paylasim_modu';
    if v_liste is not null then
        update public.kod_deger set aktif = 0 where liste_id = v_liste;
    end if;
end $$;

do $$
begin
    raise notice '478 tamam: belge_satir 7 kolon, taraf_kurum 10 kolon dustu (yedekler _478)';
end $$;
