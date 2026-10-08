-- =====================================================================
-- 992 - BANKO POS: banka alani yerine TAHSILAT HESABI
--
-- Kullanici 08.10.2026: "banko kartinda pos sekmesinde banka sutunu kaldir
--   onun yerine tahsilat hesabi ni getir.. bu hesap listesinde sadece pos
--   listesi olsun".
--
-- NEDEN DOGRU: POS tahsilati kasaya nakit girmez, kendi POS HESABINA
--   yazilir ve mutabakati o hesabin ekstresiyle yapilir. Bankayi ayrica
--   sormak ayni bilgiyi iki kez istemek demekti - POS hesabi zaten bir
--   bankanin hesabi. Iki alan tutarsiz da kalabiliyordu: "Ziraat" secip
--   hesabi Garanti POS'u gostermek mumkundu.
--
-- banka_id KOLONU DURUYOR: eski kayitlarda dolu olabilir ve silmek gecmis
--   veriyi atmak olurdu. Kartta gorunmuyor, hicbir yerde okunmuyor.
-- =====================================================================

-- POS HESAPLARI (tur 'P'): tahsilat hesabi listesi bunlarla sinirli -
--   kasa ya da banka hesabi secilirse POS mutabakati hic tutmaz.
create or replace view public.v_pos_hesap_lookup as
select h.id,
       (h.ad || ' [' || h.doviz_cinsi || ']')::varchar(160) as ad,
       h.durum as aktif
  from public.hesap h
 where h.tur = 'P';

-- Oturum POS gorunumu: banka adi yerine HESAP adi. Kolon ADI degistigi
--   icin replace yetmez (PG kolon adini degistirmiyor), gorunum dusurulup
--   yeniden kuruluyor - bagimli nesne yok.
drop view if exists public.v_banko_oturum_pos;
create view public.v_banko_oturum_pos as
select o.id                          as oturum_id,
       p.id                          as banko_pos_id,
       coalesce(h.ad, '')            as hesap_adi,
       p.terminal_no,
       p.hesap_id,
       p.durum                       as pos_durum,
       coalesce(sis.toplam, 0)::numeric(18,2) as sistem_toplam,
       e.cihaz_toplam,
       e.fark,
       e.durum                       as eslesme_durum,
       e.aciklama                    as eslesme_not
  from public.banko_oturum o
  join public.banko_pos p on p.banko_id = o.banko_id
  left join public.hesap h on h.id = p.hesap_id
  left join public.banko_oturum_pos e on e.oturum_id = o.id and e.banko_pos_id = p.id
  left join (
        select k.oturum_id, k.banko_pos_id, sum(k.yerel_tutar) as toplam
          from public.kasa_islem k
          join public.kasa_islem_turu t on t.kod = k.tur
         where k.oturum_id is not null and k.durum <> 9
           and t.ana_hesap_turu = 'P' and k.kaynak_tur is distinct from 1385
           and k.banko_pos_id is not null
         group by k.oturum_id, k.banko_pos_id) sis
    on sis.oturum_id = o.id and sis.banko_pos_id = p.id;

do $$
declare n int;
begin
  select count(*) into n from public.v_pos_hesap_lookup where aktif = 1;
  raise notice '992: v_pos_hesap_lookup hazir (% aktif POS hesabi), oturum POS gorunumu hesap adini kullaniyor', n;
end $$;
