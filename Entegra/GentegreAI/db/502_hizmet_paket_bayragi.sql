-- =====================================================================
--  502_hizmet_paket_bayragi.sql
--  `hizmet.paket` - stoktaki (124) `stok.paket` deseninin hizmet karşılığı.
--
--  Kullanıcı: "hizmet.paket ekle stok gibi".
--
--  Bugüne kadar "paket mi" sorusu tamamen TÜRETİLİYORDU: `hizmet_paket`'te
--  satırı varsa paket. Bunun açığı, İÇERİĞİ HENÜZ GİRİLMEMİŞ panel: kart
--  açılıp kaydediliyor, içerik ertesi gün girilecek - o arada sıradan bir
--  hizmet gibi davranıyor, belgeye tek satır gidiyor ve HİÇ İSTEM DOĞMUYOR.
--
--  Bayrak ile türetim işi bölüşür:
--    * `hizmet.paket`   = NİYET  - "Panel İçeriği" sekmesini açar, listede
--                         işaretler, boş paneli görünür kılar.
--    * `hizmet_paket`   = DAVRANIŞ - açılım, istem üretimi, içerik toplamı.
--  Bayrak davranışı belirlemez: işaretli ama içeriği boşsa açılacak bir şey
--  yoktur. Tersi de doğru değil - içerik yazılınca bayrak KENDİLİĞİNDEN
--  kalkar (tetik), çünkü içeriği olan bir hizmet zaten pakettir ve bayrağı
--  elle işaretlemeyi beklemek sessiz hataya davetiyedir.
--
--  İçerik SİLİNİNCE bayrak DÜŞMEZ: kullanıcı paneli boşaltıp yeniden
--  dolduruyor olabilir; sekmeyi kapatmak yarım işi kaybettirirdi.
-- =====================================================================

alter table public.hizmet
    add column if not exists paket smallint not null default 0;

comment on column public.hizmet.paket is
    'Panel/paket mi (502) - "Panel İçeriği" sekmesini açar; içerik hizmet_paket''te.';

-- Mevcut paketler işaretlenir (496/497'de içeriği yazılmış 116 kayıt).
update public.hizmet h
   set paket = 1
 where h.paket = 0
   and exists (select 1 from public.hizmet_paket p where p.paket_hizmet_id = h.id);

-- İçerik yazılınca bayrak kendiliğinden kalkar.
create or replace function public.tg_hizmet_paket_bayrak() returns trigger
language plpgsql as $$
begin
    update public.hizmet set paket = 1
     where id = new.paket_hizmet_id and paket = 0;
    return null;
end $$;

drop trigger if exists tg_hizmet_paket_bayrak on public.hizmet_paket;
create trigger tg_hizmet_paket_bayrak
    after insert or update of paket_hizmet_id on public.hizmet_paket
    for each row execute function public.tg_hizmet_paket_bayrak();

-- İÇERİĞİ OLAN HİZMET PAKET OLMAKTAN ÇIKARILAMAZ: bayrağı elle indirmek,
--   içerik durduğu hâlde sekmeyi gizler ve açılım hâlâ çalışır - ekranla
--   davranış ayrışır.
create or replace function public.tg_hizmet_paket_bayrak_kontrol() returns trigger
language plpgsql as $$
begin
    if new.paket = 0 and old.paket = 1
       and exists (select 1 from public.hizmet_paket p where p.paket_hizmet_id = new.id) then
        raise exception 'GK422: Bu hizmetin panel içeriği var - önce içerik satırlarını silin.';
    end if;
    return new;
end $$;

drop trigger if exists tg_hizmet_paket_bayrak_kontrol on public.hizmet;
create trigger tg_hizmet_paket_bayrak_kontrol
    before update of paket on public.hizmet
    for each row execute function public.tg_hizmet_paket_bayrak_kontrol();

/**
 * İÇERİĞİ BOŞ PAKET: kart uyarısı ve liste rozeti bunu sorar. Ayrı bir
 * kolon değil - bayrak ile içerik sayısının FARKI zaten cevap.
 */
create or replace view public.v_hizmet_paket_eksik as
select h.id, h.kod, h.ad, h.kategori
  from public.hizmet h
 where h.paket = 1
   and not exists (select 1 from public.hizmet_paket p where p.paket_hizmet_id = h.id);
