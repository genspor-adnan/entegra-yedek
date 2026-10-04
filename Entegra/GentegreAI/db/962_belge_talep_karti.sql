-- ============================================================================
--  Gentegre AI — BELGE TALEP KARTI
--  962_belge_talep_karti.sql
--
--  Kullanıcı: "Belge talepleri listesinde belge talep kartı için mockup yap" →
--  "mockup uygun, uygula" (Ekranlar/IK/belge_talep_karti.html).
--
--  1. istenen_tarih: kişi belgeyi ne zamana istiyor - hazırlık kuyruğu buna
--     göre sıralanır, geçen / bugünkü kart uyarır.
--  2. teslim_eposta / teslim_adres: teslim şekli e-posta / kargo ise nereye.
--  3. dogrulama_kodu: HAZIRLANINCA üretilir (tetik), yazıda barkodla basılır;
--     /api/belge-dogrula/{kod} kimliksiz sorgulanır (yalnız tür, no, tarih,
--     maskeli ad - kişisel bilgi sızdırmaz).
--  4. kod listesi `ik.belge_amac`.
--  Yalnız dev docker.
-- ============================================================================

alter table public.personel_belge_talep add column if not exists istenen_tarih  date;
alter table public.personel_belge_talep add column if not exists teslim_eposta  varchar(150) not null default '';
alter table public.personel_belge_talep add column if not exists teslim_adres   varchar(300) not null default '';
alter table public.personel_belge_talep add column if not exists dogrulama_kodu varchar(20);
create unique index if not exists ux_belge_talep_dogrulama on public.personel_belge_talep (dogrulama_kodu)
    where dogrulama_kodu is not null;

-- DOĞRULAMA KODU: hazırlandı (4) anında, bir kez. Karışmayan 8 karakter (0/O, 1/I yok).
create or replace function public.tg_belge_talep_dogrulama()
returns trigger language plpgsql as $fn$
declare
    v_harf constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    v_kod  text;
    i      int;
begin
    if new.durum = 4 and new.dogrulama_kodu is null then
        loop
            v_kod := '';
            for i in 1..8 loop
                v_kod := v_kod || substr(v_harf, 1 + floor(random() * length(v_harf))::int, 1);
                if i = 4 then v_kod := v_kod || '-'; end if;
            end loop;
            exit when not exists (select 1 from public.personel_belge_talep where dogrulama_kodu = v_kod);
        end loop;
        new.dogrulama_kodu := v_kod;
    end if;
    return new;
end $fn$;

drop trigger if exists tg_belge_talep_dogrulama on public.personel_belge_talep;
create trigger tg_belge_talep_dogrulama before update of durum on public.personel_belge_talep
    for each row execute function public.tg_belge_talep_dogrulama();

-- Var olan hazırlanmış / teslim edilmiş talepler de kod alsın.
update public.personel_belge_talep set durum = durum
 where durum in (4, 5) and dogrulama_kodu is null;
update public.personel_belge_talep b
   set dogrulama_kodu = upper(substr(md5(b.id::text || clock_timestamp()::text), 1, 4) || '-'
                              || substr(md5(b.id::text || random()::text), 1, 4))
 where b.durum = 5 and b.dogrulama_kodu is null;

insert into public.kod_liste (kod, ad)
select 'ik.belge_amac', 'Belge Talebi Amacı'
 where not exists (select 1 from public.kod_liste where kod = 'ik.belge_amac');

insert into public.kod_deger (liste_id, deger, ad, dil, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, 0, v.deger, 1, 0
  from (values (1, 'Banka kredi başvurusu'), (2, 'Vize başvurusu'), (3, 'Kira sözleşmesi'),
               (4, 'Okul / burs'), (5, 'Resmî kurum'), (6, 'Mahkeme / icra'), (9, 'Diğer')) v(deger, ad)
  join public.kod_liste l on l.kod = 'ik.belge_amac'
 where not exists (select 1 from public.kod_deger x where x.liste_id = l.id and x.deger = v.deger and x.dil = 0);
