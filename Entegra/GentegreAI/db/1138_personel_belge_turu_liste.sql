-- =============================================================================
--  1138  PERSONEL BELGE TÜRLERİ - LİSTE SAYILARI
--
--  Kullanıcı (22.10.2026): "mockup'a göre yap, öneriler hariç" - mockup
--  Ekranlar/IK/personel_belge_turu.html (1) Belge Türleri listesi:
--  Personel · Tamam · Eksik · Doldu · Yaklaşan sütunları, sayaç kartları
--  (zorunlu / süreli / eksiği olan / isteğe bağlı) ve "📄 zorunlu" dosya metni.
--
--  v_personel_belge_turu yeniden kurulur; yeni kolonlar SONA eklenir.
--  `eksik` anlamı daralır: önceden zorunlu + (eksik ya da süresi dolmuş) idi,
--  artık yalnız zorunlu + eksik/dosya yok - süresi dolan `doldu` kolonunda.
--  Kolonu okuyan tek yer tür listesi (KaynakKatalogu.PersonelBelge).
--
--  Sayılar personel kartı rozetiyle aynı kural (PersonelBelgePaneli):
--    personel  = türün zorunlu olduğu aktif personel
--    tamam     = belgesi geçerli olan (zorunlu ya da değil)
--    eksik     = zorunlu ve belgesi yok / dosyası yok
--    doldu     = süresi dolmuş (zorunlu ya da değil)
--    yaklasan  = uyarı süresine girmiş
--  v_personel_belge_durum TEK kez hesaplanır (tür başına alt sorgu değil).
-- =============================================================================

begin;

create or replace view public.v_personel_belge_turu as
with sayi as (
  select x.belge_turu_id,
         count(*) filter (where x.zorunlu = 1)::integer                   as personel,
         count(*) filter (where x.durum = 4)::integer                     as tamam,
         count(*) filter (where x.zorunlu = 1 and x.durum = 1)::integer   as eksik,
         count(*) filter (where x.durum = 2)::integer                     as doldu,
         count(*) filter (where x.durum = 3)::integer                     as yaklasan
    from public.v_personel_belge_durum x
   group by x.belge_turu_id
)
select bt.id, bt.ad, bt.grup,
       case bt.grup when 1 then 'Kimlik / işe giriş' when 2 then 'Mesleki' when 3 then 'Sağlık / İSG'
                    when 4 then 'İdari' else 'Diğer' end as grup_adi,
       bt.gecerlilik_ay,
       case when bt.gecerlilik_ay is null then 'Süresiz' else bt.gecerlilik_ay || ' ay' end as gecerlilik_adi,
       bt.hatirlat_gun, bt.sira, bt.aktif,
       case when bt.aktif = 1 then 'Aktif' else 'Pasif' end as aktif_adi,
       coalesce((select string_agg(case when k.departman_id is null and k.gorev_id is null then 'Tüm personel'
                                        else concat_ws(' / ', d.ad, g.ad) end, ', ')
                   from public.personel_belge_kapsam k
                   left join public.departman d on d.id = k.departman_id
                   left join public.personel_gorev g on g.id = k.gorev_id
                  where k.belge_turu_id = bt.id), 'İsteğe bağlı')::varchar(400) as kapsam,
       coalesce(s.eksik, 0)::integer as eksik,
       bt.aciklama, bt.sube_id,
       bt.dosya_zorunlu,
       -- 1138 ------------------------------------------------------------
       coalesce(s.personel, 0)::integer as personel,
       coalesce(s.tamam, 0)::integer    as tamam,
       coalesce(s.doldu, 0)::integer    as doldu,
       coalesce(s.yaklasan, 0)::integer as yaklasan,
       (case when bt.dosya_zorunlu = 1 then '📄 zorunlu' else 'isteğe bağlı' end)::varchar(20) as dosya_adi,
       (case when exists (select 1 from public.personel_belge_kapsam k where k.belge_turu_id = bt.id)
             then 1 else 0 end)::smallint as kapsamli,
       (case when bt.gecerlilik_ay is null then 0 else 1 end)::smallint as sureli,
       -- Süresiz belgede uyarı günü anlamsız: listede "—".
       (case when bt.gecerlilik_ay is null then '' else bt.hatirlat_gun || ' gün' end)::varchar(20) as uyari_adi
  from public.personel_belge_turu bt
  left join sayi s on s.belge_turu_id = bt.id;

commit;
