-- ============================================================================
--  Gentegre AI — DUYURU YARDIMCILARI
--  958_duyuru_yardimci.sql
--
--  957'nin uçları için: düz metin özeti, "kime" özeti ve zamanlanmış
--  duyurunun e-posta / SMS gönderimi için saatlik iş. Yalnız dev docker.
-- ============================================================================

-- Zil satırının özeti: etiketsiz, boşlukları sıkıştırılmış metin.
create or replace function public.fn_duyuru_duz(p_html text)
returns text language sql immutable as $fn$
    select btrim(regexp_replace(
             replace(replace(replace(replace(replace(
               regexp_replace(coalesce(p_html, ''), '<[^>]+>', ' ', 'g'),
               '&nbsp;', ' '), '&amp;', '&'), '&lt;', '<'), '&gt;', '>'), '&quot;', '"'),
             '\s+', ' ', 'g'))
$fn$;

-- "Kardiyoloji, Dahiliye · Uzman Doktor" - herkes ise "herkes".
create or replace function public.fn_duyuru_hedef_ozet(p_duyuru integer)
returns varchar language sql stable as $fn$
    select case when d.herkes = 1 then 'herkes'
                else coalesce((select string_agg(x.ad, ', ' order by x.tur, x.ad)
                                 from (select h.tur,
                                              case h.tur when 1 then (select s.ad from public.sube s where s.id = h.hedef_id)
                                                         when 2 then (select dp.ad from public.departman dp where dp.id = h.hedef_id)
                                                         when 3 then (select r.ad from public.rol r where r.id = h.hedef_id)
                                                         else (select coalesce(nullif(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), ''), k.kod)
                                                                 from public.taraf_kullanici k left join public.taraf t on t.id = k.id
                                                                where k.id = h.hedef_id) end as ad
                                         from public.duyuru_hedef h where h.duyuru_id = d.id) x), '—') end
      from public.duyuru d where d.id = p_duyuru
$fn$;

-- Zamanlanmış duyurunun e-posta / SMS'i: saatte bir, yayını başlamış ve
--   gönderimi yapılmamış olanlar (uç: DuyuruUclari.DisKanalGonderAsync).
insert into public.zamanli_is (kod, ad, aktif, periyot, gun, saat, dakika)
select 'duyuru.gonderim', 'Zamanlanmış duyurunun e-posta / SMS gönderimi', 1, 1, 1, 0, 5
 where not exists (select 1 from public.zamanli_is where kod = 'duyuru.gonderim');
