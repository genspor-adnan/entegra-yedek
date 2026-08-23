-- ============================================================================
--  Gentegre AI — HELP: alan/opsiyon yardim metinleri
--  103_help.sql
--
--  GENEL KURAL (kullanici karari): bir ayarin/alanin aciklamasi ekranin altina
--  paragraf olarak yazilmaz; alanin saginda "?" ikonu durur, basilinca aciklama
--  gosterilir. Metinler KODDA degil burada: dil eklemek, musteriye gore
--  degistirmek ve yeni opsiyona metin yazmak yeni surum gerektirmesin.
--
--  ANAHTAR duzeni "<alan>.<yer>": ayar ekranindaki opsiyonlar icin
--  'ayar.<referans anahtari>'. Ilerideki kart alanlari 'kart.<kart>.<alan>',
--  liste kolonlari 'liste.<kaynak>.<kolon>' seklinde ayni tabloya yazilir.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.help (
    anahtar           varchar(120) not null,
    dil               smallint     not null default 0,
    baslik            varchar(160) not null default '',
    metin             text         not null default '',
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamp    not null default now()::timestamp,
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamp,
    constraint pk_help primary key (anahtar, dil)
);

comment on table public.help is
  'Alan/opsiyon yardim metinleri - ekranlardaki "?" ikonu bunu gosterir (103).';
comment on column public.help.anahtar is
  'ayar.<referans anahtari> | kart.<kart>.<alan> | liste.<kaynak>.<kolon>';
comment on column public.help.dil is '0 = Turkce (varsayilan).';

do $$
begin
    if not exists (select 1 from pg_trigger where tgname = 'trg_help_degistirme') then
        create trigger trg_help_degistirme before update on public.help
            for each row execute function public.fn_degistirme_tarihi();
    end if;
end $$;

-- --------------------------------------------------------------- icerik ----
insert into public.help (anahtar, dil, baslik, metin) values
('ayar.belge.geri_gun_siniri', 0, 'Geriye dönük belge girişi',
 'Belge tarihi bugünden bu kadar gün öncesine kadar seçilebilir; daha eskisi kaydedilmez. '
 || E'\n\n'
 || '0 yazılırsa geriye dönük sınır kalkar. İleri tarihli belge her durumda engellenir '
 || '(GİB ileri tarihli e-Belgeyi kabul etmez).'
 || E'\n\n'
 || 'Kural bütün belge türlerinde geçerlidir (fatura, irsaliye, sipariş, fiş, transfer…) '
 || 've sunucuda uygulanır: ekrandan atlatılamaz.')
on conflict (anahtar, dil) do update
   set baslik = excluded.baslik, metin = excluded.metin;

do $$
declare v integer;
begin
    select count(*) into v from public.help;
    raise notice '103 tamam: help tablosu, % kayit', v;
end $$;
