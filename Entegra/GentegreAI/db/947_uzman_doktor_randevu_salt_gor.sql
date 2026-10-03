-- =====================================================================
--  947_uzman_doktor_randevu_salt_gor.sql
--  UZMAN DOKTOR ROLÜNDE RANDEVU VARSAYILANI "YALNIZ GÖR" (kullanıcı:
--  "uzman doktor rolüne default randevu ekle/değiş/sil yetkilerini verme..
--  eğer kurum isterse değişebilsin").
--
--  Standart rol şablonu (StandartRolUclari, `hekim`) artık randevuyu yalnız
--  GÖR olarak verir: doktor kendi randevularını görür (hekim kısıtı), randevuyu
--  banko / çağrı merkezi verir. Kurum isterse Yönetim › Yetkiler'den açar.
--
--  MEVCUT KURULUMLAR: yalnız ŞABLONDAN GELDİĞİ GİBİ DURAN satır düzeltilir -
--  `hekim` rolünde `randevu` satırı ekle=1, değiştir=1, sil=0 VE kurulumdan
--  sonra hiç değiştirilmemiş (degistiren = 0). Kurumun bilerek açtığı ya da
--  düzenlediği satıra DOKUNULMAZ. Değişen satırlar önce yedek tabloya alınır.
--
--  Idempotent: ikinci çalıştırmada eşleşen satır kalmaz.
-- =====================================================================
\set ON_ERROR_STOP on

create table if not exists public.yedek_947_rol_yetki as
select ry.*, now() as yedek_tarihi from public.rol_yetki ry where false;

with hedef as (
    select ry.rol_id, ry.yetki_id
      from public.rol_yetki ry
      join public.rol r on r.id = ry.rol_id
      join public.yetki y on y.id = ry.yetki_id
     where r.kod = 'hekim' and y.kod = 'randevu'
       and ry.ekle = 1 and ry.degistir = 1 and ry.sil = 0
       and coalesce(ry.degistiren, 0) = 0
), yedek as (
    insert into public.yedek_947_rol_yetki
    select ry.*, now() from public.rol_yetki ry
      join hedef h on h.rol_id = ry.rol_id and h.yetki_id = ry.yetki_id
    returning rol_id
), duzelt as (
    update public.rol_yetki ry
       set ekle = 0, degistir = 0, sil = 0
      from hedef h
     where ry.rol_id = h.rol_id and ry.yetki_id = h.yetki_id
    returning ry.rol_id
)
select count(*) as duzeltilen from duzelt;

-- Yetki önbelleği rol sürümüyle geçersizlenir (YetkiCozucu).
update public.rol set yetki_surumu = yetki_surumu + 1 where kod = 'hekim';

do $$
begin
    raise notice '947 tamam: hekim rolünde randevu - yedeklenen % satır; şu an: %',
        (select count(*) from public.yedek_947_rol_yetki),
        (select string_agg(format('gor=%s ekle=%s degistir=%s sil=%s', ry.gor, ry.ekle, ry.degistir, ry.sil), '; ')
           from public.rol_yetki ry join public.rol r on r.id = ry.rol_id join public.yetki y on y.id = ry.yetki_id
          where r.kod = 'hekim' and y.kod = 'randevu');
end $$;
