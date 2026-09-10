-- =====================================================================
--  538_ozel_kat_on.sql
--  Özel tarife katı 3 → 10.
--
--  Kullanıcı: "özel fiyatı SUT'un 10 katı yap."
--
--  536/537'de kat 3 kullanılmıştı. Kat DEĞİŞTİRİLEBİLİR bir karardır
--  (kurumun fiyat politikası); üretim fonksiyonu zaten kat parametresi
--  alıyor - yeni bir mekanizma yok, aynı fonksiyon yeni katla koşuyor.
--
--  SIRA ÖNEMLİ: önce TTB, sonra SUT. İki liste 4.145 kalemde ÇAKIŞIYOR;
--  SUT sonra koştuğu için çakışanlarda SUT fiyatı kazanır (SGK bedeli daha
--  gerçekçi bir taban). SUT'ta karşılığı olmayan kalemler TTB'den kalır.
--
--  ELLE GİRİLEN FİYAT KORUNMAZ bu koşuda: kat değişimi listenin TAMAMINI
--  yeniden fiyatlandırma kararıdır. Kullanıcı tek tek düzelttiyse (bugün
--  düzeltmedi - liste 536/537 ile üretilmişti) yeniden düzeltmeli.
-- =====================================================================


-- ÖNCE FONKSİYON DÜZELTMESİ: `zz_turet` geçici tablosu `on commit drop` ile
--   açılıyordu; fonksiyon AYNI İŞLEMDE iki kez çağrılınca (önce TTB, sonra
--   SUT) ikinci çağrı "relation zz_turet already exists" ile düşüyordu.
--   Tablo her çağrının başında düşürülür.
create or replace function public.fn_fiyat_liste_turet(
    p_hedef integer,
    p_kaynak integer,
    p_kat numeric,
    p_kategori integer default null,
    p_elle_yazilani_koru boolean default false,
    p_yuvarlama integer default 2)
returns integer language plpgsql as $$
declare v_sayi integer;
begin
    if p_hedef = p_kaynak then
        raise exception 'Hedef ve kaynak liste aynı olamaz.' using errcode = 'GK422';
    end if;
    if coalesce(p_kat, 0) <= 0 then
        raise exception 'Kat (çarpan) sıfırdan büyük olmalı.' using errcode = 'GK422';
    end if;

    drop table if exists zz_turet;
    create temporary table zz_turet on commit drop as
    select s.id as satir_id, k.fiyat as kaynak_fiyat
      from public.fiyat_listesi_satir s
      join public.fiyat_listesi_satir k
        on k.liste_id = p_kaynak
       and coalesce(k.hizmet_id, 0) = coalesce(s.hizmet_id, 0)
       and coalesce(k.stok_id, 0)   = coalesce(s.stok_id, 0)
      left join public.hizmet h on h.id = s.hizmet_id
      left join public.stok   t on t.id = s.stok_id
     where s.liste_id = p_hedef
       and coalesce(k.fiyat, 0) > 0
       and (p_kategori is null
            or coalesce(h.kategori, t.kategori) in (
                 with recursive dal as (
                     select p_kategori::integer id
                     union all
                     select k2.id from public.kategori k2 join dal d on k2.ust_id = d.id)
                 select id from dal));

    update public.fiyat_listesi_satir s
       set fiyat = round(z.kaynak_fiyat * p_kat, p_yuvarlama),
           yazim = 2
      from zz_turet z
     where s.id = z.satir_id
       and (not p_elle_yazilani_koru or coalesce(s.fiyat, 0) = 0)
       and s.fiyat is distinct from round(z.kaynak_fiyat * p_kat, p_yuvarlama);
    get diagnostics v_sayi = row_count;
    return v_sayi;
end $$;

do $$
declare
    v_ozel integer;
    v_sut  integer;
    v_ttb  integer;
    v_a    integer;
    v_b    integer;
begin
    select id into v_ozel from public.fiyat_listesi where tarife_tipi = 1 order by id limit 1;
    select id into v_sut  from public.fiyat_listesi where tarife_tipi = 3 order by id limit 1;
    select id into v_ttb  from public.fiyat_listesi where tarife_tipi = 2 order by id limit 1;
    if v_ozel is null or v_sut is null then
        raise notice '538: Özel ya da SUT listesi yok - atlandı.';
        return;
    end if;

    if v_ttb is not null then
        select public.fn_fiyat_liste_turet(v_ozel, v_ttb, 10) into v_a;
    end if;
    select public.fn_fiyat_liste_turet(v_ozel, v_sut, 10) into v_b;

    raise notice '538: Özel liste x10 - TTB''den % satır, SUT''tan % satır.',
                 coalesce(v_a, 0), v_b;
end $$;
