-- =============================================================================
--  1068  KURUMSAL KALİTE - KALİTE DOKÜMANLARI MOCKUP'A UYDU (Kalite2/kalite_dokumanlari.html)
--
--  Kullanıcı (12.10.2026): "kalite dokümanlarını mockup gibi yap". Liste
--  Kod · Ad · Tür · Rev · Yayın · Sonraki gözden geçirme · Durum; çipler
--  Yürürlükte · Onay bekliyor · Gözden geçirme vakti · Tümü. Kart Doküman
--  modülünün kartı (yeniden yazılmaz).
--
--  KENDİ GÖRÜNÜMÜ (v_kalite_dokuman): 1049 Doküman modülünün `dokuman`
--  kaynağını kategori yolu süzgeciyle kullanıyordu - o kaynak `dokuman`
--  yetkisi istiyor, yalnız kys.dokuman yetkili kalite sorumlusu liste
--  göremiyordu; tür tam yol ("Kalite Dokümanları › Prosedür") görünüyordu.
--    kök          : referans kys.dokuman_kategori_id (1049) ve tüm alt kategoriler
--    tur          : kategori adı (Prosedür, Talimat, Form...)
--    rev          : sürüm no iki hane ("03")
--    yayin        : geçerlilik başı, yoksa son değişiklik / yükleme günü
--    durum_adi    : Taslak · Onay bekliyor · Yürürlükte · Arşiv; yürürlükteki
--                   dokümanın gözden geçirme tarihi geçtiyse "Gözden geçirilmeli"
--  İdempotent.
-- =============================================================================

begin;

create or replace view public.v_kalite_dokuman as
with recursive agac as (
    select k.id from public.dokuman_kategori k
     where k.id = (select nullif(deger, '')::integer from public.referans where anahtar = 'kys.dokuman_kategori_id')
    union all
    select k.id from public.dokuman_kategori k join agac a on k.ust_id = a.id
)
select d.id, d.kod, d.ad,
       coalesce(t.ad, '')::varchar(120)                           as tur,
       d.kategori_id,
       lpad(coalesce(d.surum_no, 1)::text, 2, '0')::varchar(5)     as rev,
       coalesce(d.gecerli_bas, d.degistirme_tarihi::date, d.ekleme_tarihi::date) as yayin,
       d.sonraki_gozden_gecirme,
       (d.durum = 3 and d.sonraki_gozden_gecirme < current_date)::int as gozden_gecti,
       d.durum,
       (case when d.durum = 3 and d.sonraki_gozden_gecirme < current_date then 'Gözden geçirilmeli'
             when d.durum = 1 then 'Taslak' when d.durum = 2 then 'Onay bekliyor'
             when d.durum = 3 then 'Yürürlükte' when d.durum = 4 then 'Arşiv' else '' end)::varchar(30) as durum_adi,
       coalesce(u.ad, '')::varchar(120)                           as sahip_adi,
       d.sube_id
  from public.dokuman d
  join agac a on a.id = d.kategori_id
  left join public.dokuman_kategori t on t.id = d.kategori_id
  left join public.v_kullanici_lookup u on u.id = d.sahip_id
 where d.durum <> 0;

update public.ai_rehber_ekran set aksiyon_ekrani = 'kys-dokuman-liste'
 where rota = '/kys-dokuman';

commit;
