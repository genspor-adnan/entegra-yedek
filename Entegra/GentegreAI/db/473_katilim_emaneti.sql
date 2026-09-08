-- =====================================================================
-- 473 - SGK KATILIM PAYI: EMANET (hasta → SGK cari virmanı)
--
-- Kullanıcı kararı: "Emanet - SGK carisine alacak".
--
-- Katılım payı hastadan TAHSİL EDİLİR ama hastanenin GELİRİ DEĞİLDİR: SGK
-- adına toplanır, icmalde SGK'dan alacaktan düşülür. Ciroya yazılırsa hem
-- gelir şişer hem prim tabanı bozulur; hiç kaydedilmezse kasa tutmaz.
--
-- ÇÖZÜM: tahsilat kasaya normal girer (pay 5), ardından TÜR 49 CARİ VİRMAN
-- ile hasta carisinden SGK carisine aktarılır. Sonuç: kasa +, hasta cari
-- net 0, SGK carisi alacaklı.
--
-- Virman KAYNAĞA BAĞLI (kaynak_tur = 473): tahsilat iptal edilirse virman da
-- iptal edilir, tutar değişirse yeniden üretilir - iki kayıt asla ayrışmaz.
-- =====================================================================

alter table public.kurum_icmal
  add column if not exists katilim_toplam numeric(19,4) not null default 0;

comment on column public.kurum_icmal.katilim_toplam is
  'Dönemde hastadan toplanan SGK katılım payı (473). Bilgi amaçlı: alacaktan düşülür, ciroya girmez.';

-- Bir tahsilatın pay-5 dağıtımı toplamı kadar virman üretir/günceller/iptal eder.
create or replace function public.fn_sgk_katilim_emanet_yaz(p_kasa_islem_id integer)
returns integer
language plpgsql as $$
declare
    v_toplam   numeric(19,4);
    v_islem    record;
    v_sgk      integer;
    v_hasta    integer;
    v_mevcut   integer;
    v_yeni     integer;
begin
    if coalesce(p_kasa_islem_id, 0) = 0 then return null; end if;

    select k.id, k.taraf_id, k.islem_tarihi, k.hesap_id, k.doviz_cinsi,
           k.doviz_kuru, k.sube_id, k.durum, k.iptal_islem_id, k.ekleyen
      into v_islem
      from public.kasa_islem k where k.id = p_kasa_islem_id;
    if not found then return null; end if;

    -- Katılım payı toplamı ve SGK carisi: dağıtımın bağlı olduğu başvurudan.
    select coalesce(sum(d.tutar), 0),
           max(coalesce(sz.sgk_kurum_id, bb.odeyen_kurum_id))
      into v_toplam, v_sgk
      from public.kasa_islem_dagitim d
      join public.belge_satir bs on bs.id = d.belge_satir_id
      left join public.belge_basvuru bb on bb.id = bs.belge_id
      left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
     where d.kasa_islem_id = p_kasa_islem_id and d.pay = 5;

    select k.id into v_mevcut
      from public.kasa_islem k
     where k.kaynak_tur = 473 and k.kaynak_id = p_kasa_islem_id
       and k.iptal_islem_id is null
     limit 1;

    -- Tahsilat iptal/taslak ya da katılım kalmadıysa virman da yaşamamalı.
    if coalesce(v_toplam, 0) <= 0 or v_sgk is null
       or coalesce(v_islem.durum, 0) <> 2 or v_islem.iptal_islem_id is not null then
        if v_mevcut is not null then
            perform public.fn_kasa_islem_iptal(v_mevcut, v_islem.ekleyen);
        end if;
        return null;
    end if;

    -- Tutar değiştiyse eskisini iptal edip yenisini yaz: virman kesinleşmiş
    --   bir muhasebe kaydıdır, üzerine yazılmaz.
    if v_mevcut is not null then
        if exists (select 1 from public.kasa_islem k
                    where k.id = v_mevcut and abs(k.tutar - v_toplam) <= 0.005) then
            return v_mevcut;
        end if;
        perform public.fn_kasa_islem_iptal(v_mevcut, v_islem.ekleyen);
    end if;

    v_hasta := v_islem.taraf_id;
    if v_hasta is null then return null; end if;

    insert into public.kasa_islem
           (tur, islem_tarihi, durum, taraf_id, karsi_taraf_id, doviz_cinsi,
            tutar, doviz_kuru, yerel_tutar, kaynak_tur, kaynak_id, aciklama,
            sube_id, ekleyen)
    values (49, v_islem.islem_tarihi, 0, v_hasta, v_sgk,
            coalesce(v_islem.doviz_cinsi, 0), v_toplam,
            coalesce(v_islem.doviz_kuru, 1),
            round(v_toplam * coalesce(v_islem.doviz_kuru, 1), 2),
            473, p_kasa_islem_id,
            'SGK katılım payı emaneti (tahsilat #' || p_kasa_islem_id || ')',
            v_islem.sube_id, coalesce(v_islem.ekleyen, 0))
    returning id into v_yeni;

    perform public.fn_kasa_islem_bacak_uret(v_yeni);
    perform public.fn_kasa_islem_kesinlestir(v_yeni, coalesce(v_islem.ekleyen, 0));
    return v_yeni;
end $$;

comment on function public.fn_sgk_katilim_emanet_yaz(integer) is
  'Tahsilattaki SGK katılım payını hasta carisinden SGK carisine virmanlar (473). Ciro değil, emanet.';

-- Mutabakat görünümü: hangi tahsilatta ne kadar emanet toplandı, virmanı var mı.
create or replace view public.v_sgk_katilim_emanet as
select k.id                          as kasa_islem_id,
       k.islem_tarihi,
       k.taraf_id                    as hasta_id,
       k.taraf_unvan,
       k.sube_id,
       sum(d.tutar)                  as katilim_toplam,
       max(coalesce(sz.sgk_kurum_id, bb.odeyen_kurum_id)) as sgk_kurum_id,
       (select v.id from public.kasa_islem v
         where v.kaynak_tur = 473 and v.kaynak_id = k.id
           and v.iptal_islem_id is null limit 1) as virman_id
  from public.kasa_islem k
  join public.kasa_islem_dagitim d on d.kasa_islem_id = k.id and d.pay = 5
  join public.belge_satir bs on bs.id = d.belge_satir_id
  left join public.belge_basvuru bb on bb.id = bs.belge_id
  left join public.kurum_sozlesme sz on sz.id = bb.sozlesme_id
 where coalesce(k.durum, 0) = 2 and k.iptal_islem_id is null
 group by k.id, k.islem_tarihi, k.taraf_id, k.taraf_unvan, k.sube_id;

comment on view public.v_sgk_katilim_emanet is
  'SGK katılım payı emaneti mutabakatı (473): tahsilat başına toplam ve virman kaydı.';

do $$
begin
    raise notice '473 tamam: % tahsilatta katilim payi dagitimi var',
        (select count(*) from public.v_sgk_katilim_emanet);
end $$;
