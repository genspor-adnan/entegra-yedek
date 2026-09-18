-- ============================================================================
--  Gentegre AI — İSKONTO BASAMAKLARI YÖNETİCİ ROLÜNDEN KALKTI · SAHİPSİZ ADIM GÖRÜNÜR
--  789_yonetici_basamak_yetkileri.sql
--
--  Kullanıcı: *"yönetici rolünden basamak yetkilerini kaldır"*.
--
--  ============ NE DEĞİŞİYOR ===========================================
--  787/788 üç basamağı üç kadro rolüne verdi ama `yonetici` rolü üçünü de
--  YEDEK olarak taşımaya devam ediyordu: kadro atanana kadar talep kuyrukta
--  kalmasın diye. Kurum artık yedeği istemiyor - imza yalnız kadroda olsun.
--
--    belge.iskonto_onay_birim -> Kayıt Kabul Sorumlusu (Banko Şefi)
--    belge.iskonto_onay_mali  -> Mali İşler Müdürü
--    belge.iskonto_onay_ust   -> Üst Yönetim (Mesul Müdür / Genel Müdür)
--
--  Sistem yöneticisi bundan sonra iskonto zincirinde imza ATMAZ. Rolü yine
--  yetki dağıtır: gerekirse basamağı Yönetim › Yetkiler'den kendine ya da
--  başka bir role geri verebilir - kural rol kaydına değil YETKİ KODUNA bağlı
--  (754), bu yüzden geri alınabilir bir karardır.
--
--  ============ SESSİZ KALMASIN ========================================
--  Yedek kalkınca yeni bir tehlike doğuyor: kadro rolüne kimse atanmamışsa o
--  basamağı imzalayacak KİMSE yok ve talep kuyrukta sessizce bekler - kimse
--  hata almaz, kullanıcı "onaya gitti" sanır. `v_onay_basamak_sahibi` bunu
--  görünür kılar: her basamak yetkisinin kaç aktif kullanıcıda olduğunu
--  sayar, sıfırsa `sahipsiz = 1`. Göç de sonunda uyarıyı basar.
--
--  Bu bir SAYIM görünümüdür, kapı değil: talebi açmayı engellemek, indirim
--  yapmak isteyen bankoyu kurumun kadro eksiğinden ötürü durdurmak olurdu.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------- basamak sahibi sayimi (görünüm)
create or replace view public.v_onay_basamak_sahibi as
select y.kod                                        as yetki_kodu,
       y.ad                                         as yetki_adi,
       count(distinct r.id)                         as rol_sayisi,
       count(distinct k.id)                         as kisi_sayisi,
       case when count(distinct k.id) = 0 then 1 else 0 end::smallint as sahipsiz,
       coalesce(string_agg(distinct r.ad, ' · '), '') as roller
  from public.yetki y
  left join public.rol_yetki ry on ry.yetki_id = y.id and ry.gor = 1
  left join public.rol r        on r.id = ry.rol_id and r.aktif = 1
  left join public.taraf_kullanici k on k.rol_id = r.id and k.aktif = 1
 where y.kod like 'belge.%onay%' or y.kod like '%.onayla'
 group by y.kod, y.ad;

comment on view public.v_onay_basamak_sahibi is
  '789: onay basamagi yetkisini kac AKTIF kullanici tasiyor. sahipsiz=1 ise o '
  'basamagi imzalayacak kimse yok - talep kuyrukta sessizce bekler.';

-- --------------------------------- basamak yetkileri yoneticiden kaldirilir
do $$
declare
    v_rol  integer;
    v_sayi integer;
    r      record;
begin
    select id into v_rol from public.rol where kod = 'yonetici';
    if v_rol is null then
        raise notice '789: yonetici rolu yok, atlaniyor.';
        return;
    end if;

    delete from public.rol_yetki ry
     using public.yetki y
     where ry.yetki_id = y.id and ry.rol_id = v_rol
       and y.kod in ('belge.iskonto_onay_birim', 'belge.iskonto_onay_mali',
                     'belge.iskonto_onay_ust');
    get diagnostics v_sayi = row_count;
    raise notice '789: yonetici rolunden % basamak yetkisi kaldirildi.', v_sayi;

    -- ONAY EKRANI KALIR: yonetici imza atmaz ama zincirin nerede takildigini
    --   gormek zorunda - "onaya gitti, sonra ne oldu" sorusunun tek cevabi o
    --   ekran.
    insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
    select v_rol, y.id, 1, 0, 0, 0, ''
      from public.yetki y
     where y.kod = 'iskonto_onay'
       and not exists (select 1 from public.rol_yetki ry
                        where ry.rol_id = v_rol and ry.yetki_id = y.id);

    for r in select * from public.v_onay_basamak_sahibi
              where yetki_kodu like 'belge.iskonto_onay_%' order by yetki_kodu
    loop
        if r.sahipsiz = 1 then
            raise notice '789 UYARI: "%" basamagini imzalayacak KIMSE YOK '
                         '(rol: %). Bu basamaga gelen talep kuyrukta bekler - '
                         'Yonetim > Roller''den kadroyu atayin.',
                         r.yetki_adi, coalesce(nullif(r.roller, ''), 'rol da yok');
        else
            raise notice '789: "%" -> % kisi (%).', r.yetki_adi, r.kisi_sayisi, r.roller;
        end if;
    end loop;
end $$;
