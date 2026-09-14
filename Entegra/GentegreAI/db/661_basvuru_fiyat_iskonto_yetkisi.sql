-- ============================================================================
--  Gentegre AI — BAŞVURUDA İSKONTO YETKİSİ
--  661_basvuru_fiyat_iskonto_yetkisi.sql
--  (dosya adı ilk halinden kalma: fiyat yetkisi sonradan kaldırıldı)
--
--  Kullanıcı: "iskonto max oranı yetkiye tabi olmalı (Başvuru yetki altında
--  rol yetkisi)."
--
--  TEK İZİN: `basvuru.iskonto` - iskonto yapabilir mi ve EN ÇOK yüzde kaç.
--  Tavan `rol_yetki.deger`de durur (yetki.deger_alir = 1). Şema bunu zaten
--  öngörüyor: 020_sema_kimlik.sql'de `deger_alir` yorumu birebir
--  "or. izin verilen iskonto orani" diyor.
--
--  BİRİM FİYAT YETKİSİ YOK (kullanıcı, 14.09.2026): başvuruda birim fiyat /
--  hasta katkısı kutusu TÜM ROLLERE kapalıdır - fiyat listeden gelir. İndirim
--  yapılacaksa İskonto satırından yapılır; orada kim ne kadar indirdi oran
--  olarak kayda geçer ve onaya tabidir (662). Fiyatın üstüne yazmak aynı
--  indirimi izsiz bırakırdı, o yüzden "yetkiyle açılabilir" bir kutu da
--  tutulmadı.
--
--  Yetkisi olmayan iskonto YAPAMAZ (satır yoksa yetki yok - varsayılan kapalı);
--  `deger` boş ya da 0 ise de yapamaz. Tavan bir SINIRDIR, hedef değil.
--
--  `fn_kullanici_yetkileri` artık `deger` de döndürüyor - tavanı okumanın
--  başka yolu yoktu; imza genişledi, var olan kolonlar aynı sırada kaldı.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) YETKİ TANIMLARI
-- ---------------------------------------------------------------------------
insert into public.yetki (kod, ad, grup, tur, deger_alir, kapsam_alir, sira, aktif)
select 'basvuru.iskonto', 'Başvuruda iskonto (en çok %)', 'Başvuru', 1, 1, 0,
       coalesce((select max(sira) from public.yetki), 0) + 1, 1
 where not exists (select 1 from public.yetki where kod = 'basvuru.iskonto');

comment on column public.rol_yetki.deger is
  'Yetkinin sayisal siniri (yetki.deger_alir = 1 olanlarda). basvuru.iskonto: '
  'izin verilen EN YUKSEK iskonto yuzdesi, bos/0 = iskonto yapilamaz (661).';

-- ---------------------------------------------------------------------------
--  2) VARSAYILAN KAPALI — YALNIZ YÖNETİCİ VE ADMİN AÇIK (kullanıcı).
--
--  İskonto bir para kararıdır: kayıt kabul, vezne, hekim
--  rolleri bunu KENDİLİĞİNDEN alamaz - satır yoksa yetki yok (tablonun kendi
--  kuralı). Kimin hangi tavanla iskonto yapacağını kurum Yetkiler ekranından
--  bilinçli olarak verir.
--
--  Yönetici/admin istisna: sistemi kuran rolün kendi ekranını açamaması,
--  yetkiyi dağıtacak kişiyi de kilitlerdi. Tavan %100 - yönetici için sınır
--  koymak, sınırı koyan kişiyi sınırlamak olurdu.
-- ---------------------------------------------------------------------------
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select r.id, y.id, 1, 0, 0, 0, '100'
  from public.rol r
  cross join public.yetki y
 where y.kod = 'basvuru.iskonto'
   and r.kod in ('yonetici', 'admin')
   and not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- ---------------------------------------------------------------------------
--  3) YETKİ ÇÖZÜMÜNE `deger` EKLENDİ.
--     Var olan kolonlar aynı sırada; `deger` sona eklendi ki konumsal okuyan
--     bir çağıran varsa kırılmasın.
-- ---------------------------------------------------------------------------
-- Donus tipi degistigi icin `create or replace` yetmiyor: once dusurulur.
--   Bagimli nesne yok (fonksiyon yalniz uygulamadan cagriliyor).
drop function if exists public.fn_kullanici_yetkileri(integer);

create function public.fn_kullanici_yetkileri(p_kullanici_id integer)
returns table (yetki_kod varchar, tur smallint, gor smallint, ekle smallint,
               degistir smallint, sil smallint, deger varchar)
language sql stable as $$
    select y.kod, y.tur, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger
      from public.taraf_kullanici k
      join public.rol_yetki ry on ry.rol_id = k.rol_id
      join public.yetki y      on y.id = ry.yetki_id and y.aktif = 1
     where k.id = p_kullanici_id
       and k.aktif = 1
       and (ry.gor = 1 or ry.ekle = 1 or ry.degistir = 1 or ry.sil = 1)
$$;

comment on function public.fn_kullanici_yetkileri(integer) is
  'Kullanicinin rolunden cozulen yetkiler; deger = sayisal sinir '
  '(basvuru.iskonto icin iskonto tavani) - 661.';

do $$
begin
    raise notice '661 tamam: yetki % · rol atamasi %',
        (select count(*) from public.yetki where kod = 'basvuru.iskonto'),
        (select count(*) from public.rol_yetki ry
           join public.yetki y on y.id = ry.yetki_id
          where y.kod = 'basvuru.iskonto');
end $$;
