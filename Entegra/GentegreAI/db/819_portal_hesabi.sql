-- ============================================================================
--  Gentegre AI — PORTAL HESABI: KİŞİ BAŞI KURUM ERİŞİMİ
--  819_portal_hesabi.sql
--
--  Kullanıcı: *"1 ve 2'yi yap, kurum hesabı kişi başı olsun"*.
--
--  ============ SORUN ================================================
--  Portal kapsam kuralları (794) giriş yapanın TARAF KİMLİĞİNE bakıyor:
--    dış kurum  -> `li.dis_kurum_id = {kullanici}`
--    dış hekim  -> `i.istek_hekim_id = {kullanici}`
--    hasta      -> `t.id = {kullanici}`
--  Dış hekim ve hastada bu doğru: hesap kişinin kendi kaydında açılır.
--  KURUMDA değil - kurum bir tüzel kişilik, ekranı kullanan İNSAN. Kuralı
--  olduğu gibi bırakıp hesabı kurumun cari kaydında açmak, üç kişinin TEK
--  paylaşımlı hesabı demekti: kim ne yaptı bilinmez, biri ayrılınca parola
--  hepsi için değişir.
--
--  ============ ÇÖZÜM ================================================
--  Hesap KİŞİNİN kaydında açılır; hesap ayrıca "hangi tarafın kapsamında
--  çalıştığını" taşır: `portal_taraf_id`. Kapsam çözümü artık
--  `coalesce(portal_taraf_id, id)` - dış hekim ve hastada kolon BOŞ kalır
--  ve davranış hiç değişmez.
--
--  Kural kaynak katalogunda AYNEN kalıyor; değişen tek şey `{kullanici}`
--  yerine konan sayı. Kuralları kişi/kurum diye ikiye bölmek, aynı soruyu
--  iki yerde bakım etmek olurdu.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.taraf_kullanici
    add column if not exists portal_taraf_id integer references public.taraf(id);

comment on column public.taraf_kullanici.portal_taraf_id is
  '819: portal hesabının KAPSAM tarafı - kurum portalında temsil edilen '
  'kurumun cari kaydı. Dış hekim/hastada BOŞ (kendi kaydı geçerlidir).';

create index if not exists ix_taraf_kullanici_portal_taraf
    on public.taraf_kullanici (portal_taraf_id) where portal_taraf_id is not null;

-- ------------------------------------------------------------- doğrulama ----
-- KAPSAM DEVRİ YALNIZ PORTAL HESABINDA: kurum içi bir hesaba bu kolonu
--   yazmak, o kişiye başka bir tarafın kayıtlarını açardı.
create or replace function public.tg_kullanici_portal_taraf()
returns trigger
language plpgsql
as $$
declare
    v_portal smallint;
    v_musteri smallint;
begin
    if new.portal_taraf_id is null then return new; end if;

    select coalesce(r.portal_turu, 0) into v_portal
      from public.rol r where r.id = new.rol_id;
    if coalesce(v_portal, 0) = 0 then
        raise exception 'Kapsam devri yalnız portal hesabında olur (rol portal rolü değil).'
              using errcode = 'GK422';
    end if;

    -- KENDİ KAYDINA DEVİR ANLAMSIZ: kolonun boş hâli zaten bu.
    if new.portal_taraf_id = new.id then
        new.portal_taraf_id := null;
        return new;
    end if;

    select coalesce(t.musteri, 0) into v_musteri
      from public.taraf t where t.id = new.portal_taraf_id;
    if coalesce(v_musteri, 0) <> 1 then
        raise exception 'Portal kapsamı yalnız CARİ bir kuruma devredilebilir (taraf %).',
              new.portal_taraf_id using errcode = 'GK422';
    end if;
    return new;
end $$;

drop trigger if exists tg_kullanici_portal_taraf on public.taraf_kullanici;
create trigger tg_kullanici_portal_taraf
    before insert or update of portal_taraf_id, rol_id on public.taraf_kullanici
    for each row execute function public.tg_kullanici_portal_taraf();

-- ------------------------------------------------------- kapsam kimliği ----
-- TEK OKUYUCU: kapsam süzgecini kuran her yol buradan sorar.
create or replace function public.fn_kullanici_portal_taraf(p_kullanici integer)
returns integer
language sql stable as $$
  select coalesce(k.portal_taraf_id, k.id)
    from public.taraf_kullanici k where k.id = p_kullanici;
$$;

comment on function public.fn_kullanici_portal_taraf(integer) is
  '819: portal kapsamının bağlanacağı taraf - kurum hesabında temsil edilen '
  'kurum, ötekilerde kişinin kendisi.';

-- --------------------------------------------------------------- yetki ----
-- PORTAL HESABI AÇMAK AYRI BİR HAK: kurum içi kullanıcı açma yetkisi
--   (`kullanici`) bankoda birçok kişide var; dışarıya erişim vermek ayrı
--   bir karardır ve ayrı bir kutu ister.
insert into public.yetki (kod, ad, grup, tur, sira, aktif)
select 'kullanici.portal', 'Portal erişimi ver (dış hekim / kurum / hasta)',
       'yonetim', 1, 75, 1
 where not exists (select 1 from public.yetki y where y.kod = 'kullanici.portal');

-- Yalnız YÖNETİCİ rolüne: kimin dışarıya kapı açabileceği kurulumda
--   bilinçli genişletilir.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
select r.id, y.id, 1, 1, 1, 0
  from public.rol r
  join public.yetki y on y.kod = 'kullanici.portal'
 where r.id = 1
   and not exists (select 1 from public.rol_yetki x
                    where x.rol_id = r.id and x.yetki_id = y.id);

do $$
declare v_kurum integer;
begin
    select count(*) into v_kurum from public.taraf_kullanici where portal_taraf_id is not null;
    raise notice '819 tamam: portal_taraf_id acildi (% hesapta dolu), '
                 'kullanici.portal yetkisi tanimlandi.', v_kurum;
end $$;
