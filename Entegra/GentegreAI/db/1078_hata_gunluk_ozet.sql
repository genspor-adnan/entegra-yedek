-- =============================================================================
--  1078  HATA GÜNLÜĞÜ - GÜNLÜK ÖZET (dokuman/17 §2.1)
--
--  Kullanıcı (13.10.2026): "hata_log günlük özetini kur".
--
--  hata_log her 4xx/5xx'i izleme numarasıyla tutuyordu ama kimse bakmıyordu:
--  belge beyaz listesi hatası 8 gün, İzin Hakedişi ekranı açılmadan günlerce
--  kayıtta durdu. Bu betik hatayı TÜRÜNE göre gruplar ve "ilk kez görülen"i
--  ayırır - 400 satır yerine 15 tür, ikisi yeni.
--
--  İMZA = kod + HTTP durumu + yöntem + yol + mesaj; yoldaki ve mesajdaki
--  sayılar normalize edilir (/api/kart/kys-risk/317 ve /8 aynı tür).
--  YENİ = bu imza o günden önce hiç görülmemiş.
--
--    * v_hata_gunluk         - Platform › Hata Özeti listesi
--    * fn_hata_ozet_metin(d) - tek satır özet; `hata.ozet` zamanlı işi her
--                               sabah dünü işin son sonucuna yazar
--    * yetki `hata_ozet`     - yönetici + bilgi işlem, yalnız görme
--
--  Gün İstanbul saatine göre (veritabanı UTC). İdempotent.
-- =============================================================================

begin;

create or replace view public.v_hata_gunluk as
with h as (
    select h.id, h.tarih, h.kod, h.http_durum, h.yontem, h.kullanici_id,
           h.izleme_no, h.mesaj, h.yol,
           (h.tarih at time zone 'Europe/Istanbul')::date as gun,
           left(regexp_replace(h.yol, '/[0-9]+', '/{id}', 'g'), 200)  as yol_imza,
           left(regexp_replace(h.mesaj, '[0-9]+', '#', 'g'), 300)     as mesaj_imza
      from public.hata_log h
),
g as (
    select min(id)                                       as id,
           gun, kod, http_durum, yontem, yol_imza, mesaj_imza,
           count(*)::integer                             as adet,
           count(distinct kullanici_id)::integer         as kullanici_sayisi,
           min(tarih)                                    as ilk,
           max(tarih)                                    as son,
           (array_agg(izleme_no order by tarih desc))[1] as son_izleme_no,
           (array_agg(mesaj     order by tarih desc))[1] as ornek_mesaj,
           (array_agg(yol       order by tarih desc))[1] as ornek_yol
      from h
     group by gun, kod, http_durum, yontem, yol_imza, mesaj_imza
)
select g.*,
       (min(g.gun) over (partition by g.kod, g.http_durum, g.yontem,
                                      g.yol_imza, g.mesaj_imza) = g.gun)::integer as yeni,
       case when g.http_durum >= 500 then 'Sunucu'
            when g.http_durum in (401, 403) then 'Yetki'
            when g.http_durum = 404 then 'Bulunamadı'
            else 'İstek' end::varchar(20)                                        as sinif
  from g;

comment on view public.v_hata_gunluk is
    '1078: hata_log gün + imza (kod/durum/yöntem/yol/mesaj, sayılar normalize) özeti; yeni = imza o gün ilk kez görüldü.';

-- Tek satırlık özet (zamanli_is.son_sonuc 400 karakter).
create or replace function public.fn_hata_ozet_metin(p_gun date)
returns varchar
language sql stable as $$
    with o as (select * from public.v_hata_gunluk where gun = p_gun),
    s as (
        select coalesce(sum(adet), 0)                                   as toplam,
               coalesce(sum(adet) filter (where http_durum >= 500), 0)  as sunucu,
               count(*)                                                 as tur,
               count(*) filter (where yeni = 1)                         as yeni
          from o
    ),
    en as (   -- önce sunucu hataları, sonra yeni türler, sonra sıklık
        select string_agg(format('%s %s (%s)', http_durum, yol_imza, adet), '; '
                          order by (http_durum >= 500) desc, yeni desc, adet desc) as liste
          from (select * from o
                 order by (http_durum >= 500) desc, yeni desc, adet desc
                 limit 4) x
    )
    select left(
        case when s.toplam = 0
             then to_char(p_gun, 'DD.MM.YYYY') || ': hata yok.'
             else format('%s: %s hata, %s tür (%s yeni), %s sunucu hatası. %s',
                         to_char(p_gun, 'DD.MM.YYYY'), s.toplam, s.tur, s.yeni,
                         s.sunucu, en.liste)
        end, 400)::varchar
      from s, en
$$;

-- Yetki: menüde tek ekran (Platform › Hata Özeti), yalnız görme.
insert into public.yetki (kod, ad, grup, tur, sira, urun_modu, modul)
values ('hata_ozet', 'Hata Özeti', 'Yönetim', 0, 431, 0, '')
on conflict (kod) do nothing;

insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 0, 0, 0
  from public.rol r cross join public.yetki y
 where y.kod = 'hata_ozet' and (r.id = 1 or r.kod = 'bilgi_islem')
on conflict (rol_id, yetki_id) do nothing;

update public.rol set yetki_surumu = yetki_surumu + 1
 where id = 1 or kod = 'bilgi_islem';

-- Zamanlı iş: her sabah 07:30, dünün özeti.
insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aciklama)
select 'hata.ozet', 'Hata günlüğü günlük özeti', 2, 1, 7, 30,
       'Dünkü hataları türüne göre özetler (yeni türler, sunucu hataları); ayrıntı Platform › Hata Özeti.'
 where not exists (select 1 from public.zamanli_is where kod = 'hata.ozet');

commit;
