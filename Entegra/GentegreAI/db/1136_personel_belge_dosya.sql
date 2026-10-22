-- =============================================================================
--  1136  PERSONEL BELGE TAKİBİ - DOSYA EKİ (faz 2)
--
--  Kullanıcı (22.10.2026): "dosya ekini yap". 1135 belgenin yalnız bilgisini
--  tutuyordu (no, tarih, geçerlilik); belgenin kendisi (taranmış PDF / foto)
--  sistemde yoktu.
--
--  DOSYA: genel doküman deposu (dokuman), kaynak 'personel-belge', kaynak_id =
--    personel_belge.id. Yeni depolama yok; sürüm / paylaşım / erişim kapısı
--    (DokumanErisimi) aynen kullanılır.
--  ZORUNLU DOSYA: personel_belge_turu.dosya_zorunlu = 1 ise belgesi girilmiş
--    ama dosyası yüklenmemiş kayıt EKSİK sayılır ("Dosya yok").
--  EKSİK KURALI DÜZELTMESİ: 1135 tarihsiz girilmiş belgeyi de eksik sayıyordu
--    (yalnız tarihlere bakıyordu); artık belge satırı var mı diye bakılır.
--  SİLME: belge satırı silinince dosyaları kaybolmaz - personelin genel
--    Dokümanlar galerisine (kaynak 'taraf') belge türü adıyla taşınır.
--  Görünüm kolonları yalnız SONA eklenir (create or replace view kuralı).
--  İdempotent.
-- =============================================================================

begin;

alter table public.personel_belge_turu
  add column if not exists dosya_zorunlu smallint not null default 0;
comment on column public.personel_belge_turu.dosya_zorunlu is
  'Belge takibi (1136): 1 = belgenin dosyası (tarama) yüklenmeden kayıt eksik sayılır.';

-- Silinen belgenin dosyaları personelin kendi galerisine geçer.
create or replace function public.fn_personel_belge_dosya_tasi()
returns trigger language plpgsql as $$
begin
  update public.dokuman d
     set kaynak = 'taraf', kaynak_id = old.taraf_id, varsayilan = 0,
         belge_turu = left(coalesce((select bt.ad from public.personel_belge_turu bt
                                      where bt.id = old.belge_turu_id), d.belge_turu), 80)
   where d.kaynak = 'personel-belge' and d.kaynak_id = old.id;
  return old;
end $$;
do $$ begin
  if not exists (select 1 from pg_trigger where tgname = 'trg_personel_belge_dosya_tasi') then
    create trigger trg_personel_belge_dosya_tasi before delete on public.personel_belge
      for each row execute function public.fn_personel_belge_dosya_tasi();
  end if;
end $$;

-- ------------------------------------------------------------ görünümler --
create or replace view public.v_personel_belge_durum as
with zorunlu as (
  select distinct t.id as personel_id, bt.id as belge_turu_id, 1::smallint as zorunlu
    from public.taraf t
    join public.personel_belge_kapsam k
      on (k.departman_id is null or k.departman_id = t.departman)
     and (k.gorev_id is null or k.gorev_id = t.gorev_id)
    join public.personel_belge_turu bt on bt.id = k.belge_turu_id and bt.aktif = 1
   where t.personel = 1 and t.durum = 1
), girilen as (
  select distinct b.taraf_id as personel_id, b.belge_turu_id, 0::smallint as zorunlu
    from public.personel_belge b
    join public.taraf t on t.id = b.taraf_id and t.personel = 1 and t.durum = 1
), hepsi as (
  select personel_id, belge_turu_id, max(zorunlu)::smallint as zorunlu
    from (select * from zorunlu union all select * from girilen) u
   group by personel_id, belge_turu_id
)
select row_number() over (order by h.personel_id, bt.grup, bt.sira, bt.ad)::integer as id,
       h.personel_id,
       public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120) as ad,
       t.departman::integer                                      as departman_id,
       coalesce(d.ad, '')::varchar(150)                          as birim,
       coalesce(g.ad, '')::varchar(150)                          as gorev,
       bt.id                                                     as belge_turu_id,
       bt.ad                                                     as belge,
       bt.grup,
       case bt.grup when 1 then 'Kimlik / işe giriş' when 2 then 'Mesleki' when 3 then 'Sağlık / İSG'
                    when 4 then 'İdari' else 'Diğer' end         as grup_adi,
       h.zorunlu,
       s.belge_tarihi,
       s.gecerlilik_tarihi,
       case when s.gecerlilik_tarihi is not null then (s.gecerlilik_tarihi - current_date) end as kalan_gun,
       x.durum::smallint                                         as durum,
       case when x.durum = 1 and s.id is not null then 'Dosya yok'
            else case x.durum when 1 then 'Eksik' when 2 then 'Süresi doldu' when 3 then 'Yaklaşıyor' else 'Tamam' end
       end                                                       as durum_adi,
       t.sube_id,
       s.id                                                      as belge_id,
       coalesce(f.sayi, 0)::integer                              as dosya_sayisi,
       bt.dosya_zorunlu
  from hepsi h
  join public.taraf t on t.id = h.personel_id
  join public.personel_belge_turu bt on bt.id = h.belge_turu_id
  left join public.departman d on d.id = t.departman
  left join public.personel_gorev g on g.id = t.gorev_id
  left join lateral (
        select b.id, b.belge_tarihi, b.gecerlilik_tarihi
          from public.personel_belge b
         where b.taraf_id = h.personel_id and b.belge_turu_id = h.belge_turu_id
         order by coalesce(b.gecerlilik_tarihi, 'infinity'::date) desc, b.belge_tarihi desc nulls last, b.id desc
         limit 1) s on true
  left join lateral (
        select count(*) as sayi from public.dokuman dk
         where dk.kaynak = 'personel-belge' and dk.kaynak_id = s.id) f on true
  cross join lateral (
        select case when s.id is null then 1
                    when bt.dosya_zorunlu = 1 and coalesce(f.sayi, 0) = 0 then 1
                    when s.gecerlilik_tarihi is not null and s.gecerlilik_tarihi < current_date then 2
                    when s.gecerlilik_tarihi is not null and s.gecerlilik_tarihi < current_date + bt.hatirlat_gun then 3
                    else 4 end as durum) x;

create or replace view public.v_personel_belge_turu as
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
       (select count(*) from public.v_personel_belge_durum x where x.belge_turu_id = bt.id and x.zorunlu = 1 and x.durum in (1, 2))::integer as eksik,
       bt.aciklama, bt.sube_id,
       bt.dosya_zorunlu
  from public.personel_belge_turu bt;

commit;
