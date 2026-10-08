-- =====================================================================
-- 990 - POS GUN SONU ESLESMESI (mockup: "POS gun sonu 120,00 ₺ fark")
--
-- POS tahsilati kasaya nakit girmez; mutabakati CIHAZIN gun sonu
--   toplamiyla yapilir. Gorevli her POS icin cihazdan aldigi toplami
--   girer, sistem kendi toplamini karsisina koyar ve farki gosterir.
--
-- NEDEN AYRI TABLO (oturum satirinda tek kolon degil): bankoda birden
--   fazla POS olabilir ve fark CIHAZ BAZINDA anlam tasiyor - "hangi
--   terminalde 120 TL fark var" sorusu tek toplamla yanitlanamaz.
--
-- FARK GUN SONUNU ENGELLEMEZ: POS farki banka ekstresiyle kapanir
--   (komisyon, taksit, gun kaymasi), nakit sayim farkiyla ayni sey degil.
--   Kayit altina alinir, kapanis onayinda sorumlunun onune dusuruluir.
-- =====================================================================

create table if not exists public.banko_oturum_pos (
    id                  bigserial primary key,
    oturum_id           bigint       not null references public.banko_oturum(id) on delete cascade,
    banko_pos_id        integer      not null references public.banko_pos(id),
    -- Cihazin gun sonu raporundan okunan toplam.
    cihaz_toplam        numeric(18,2) not null default 0,
    -- Sistemin o cihaza yazdigi toplam (yazildigi an dondurulur; sonraki
    --   duzeltme fisleri gecmis mutabakati oynatmasin).
    sistem_toplam       numeric(18,2) not null default 0,
    fark                numeric(18,2) not null default 0,
    -- 1 = eslesti, 2 = fark var, 3 = cihaza ulasilamadi
    durum               smallint     not null default 1,
    aciklama            varchar(300) not null default '',
    ekleyen             integer      not null default 0,
    ekleme_tarihi       timestamptz  not null default now()
);

create unique index if not exists banko_oturum_pos_tek
    on public.banko_oturum_pos (oturum_id, banko_pos_id);

-- TAHSILAT HANGI TERMINALDEN GECTI: kasa_islem.banko_pos_id. Hesap
--   uzerinden tahmin etmek yetmez - ayni tahsilat hesabina bagli iki POS
--   varsa toplam ikisinde de gorunur ve eslestirme anlamsizlasir.
alter table public.kasa_islem add column if not exists banko_pos_id integer;
create index if not exists kasa_islem_banko_pos_ix
    on public.kasa_islem (banko_pos_id) where banko_pos_id is not null;

-- Oturumun POS cihazlari + sistemin o cihaza yazdigi toplam.
create or replace view public.v_banko_oturum_pos as
select o.id                          as oturum_id,
       p.id                          as banko_pos_id,
       coalesce(bk.ad, '')           as banka_adi,
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
  left join public.banka bk on bk.id = p.banka_id
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

-- TERMINALE BAGLANMAMIS POS TAHSILATI: eslestirme panelinde ayri satir
--   olarak gosterilir. Sessizce 0 gostermek, gorevliyi "cihazda para var
--   sistemde yok" yanilgisina surukler - para kayitta, yalniz hangi
--   terminalden gectigi yazilmamistir.
create or replace view public.v_banko_oturum_pos_atanmamis as
select k.oturum_id, sum(k.yerel_tutar)::numeric(18,2) as toplam, count(*) as adet
  from public.kasa_islem k
  join public.kasa_islem_turu t on t.kod = k.tur
 where k.oturum_id is not null and k.durum <> 9
   and t.ana_hesap_turu = 'P' and k.kaynak_tur is distinct from 1385
   and k.banko_pos_id is null
 group by k.oturum_id;

do $$
begin
  raise notice '990: banko_oturum_pos + v_banko_oturum_pos hazir';
end $$;
