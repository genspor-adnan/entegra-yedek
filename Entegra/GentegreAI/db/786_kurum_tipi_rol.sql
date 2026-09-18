-- ============================================================================
--  Gentegre AI — PROFİLE GÖRE GEÇERLİ ROLLER
--  786_kurum_tipi_rol.sql
--
--  Kullanıcı: *"profili görüntüleme yaptım bütün roller görünüyor.. isg yaptım
--  yine bütün roller görünüyor.. böyle olmasın.. profil sayfasında altta her
--  bir profil için geçerli (aktif) rolleri işaretleyeyim.. üstte kaydet deyip
--  o profilin rollerine girince onlar geçerli olsun"*.
--
--  ============ NEDEN GEREKLİ ==========================================
--  785'te on kurum tipinin şablonları birden kuruldu (kullanıcının isteğiyle:
--  "her profil için rolleri çıkar ben aktif/pasif yapayım"). Sonuç: `rol`
--  tablosunda 36 sistem rolü var ve Roller ekranı profil ne olursa olsun
--  HEPSİNİ gösteriyor. Şablonun kendi süzgeci (kurum tipi + açık modül) yalnız
--  KURULUM anında çalışıyor; kurulduktan sonra rolün hangi profile ait olduğu
--  hiçbir yerde yazmıyordu.
--
--  Bu tablo o eksik bağdır: hangi rol hangi kurum tipinde GEÇERLİ.
--
--  ============ ŞABLON VARSAYILAN, TABLO KARARDIR ======================
--  Tablo BOŞ başlar ve boş kaldığı sürece şablonun kendi listesi (kod:
--  `StandartRolUclari.Sablonlar[].Tipler` + `SablonModul`) varsayılan olarak
--  geçerlidir. Kurum ekrandan işaretleyince satır yazılır ve ARTIK KURUMUN
--  KARARI geçerlidir - şablon yeni sürümde değişse bile kurumun seçimi
--  ezilmez. Bu yüzden burada seed YOK: varsayılanı iki yerde tutmak, ikisinin
--  ayrışmasını beklemek demektir.
--
--  ============ UYGULAMA TEK YERDEN ====================================
--  `fn_kurum_tipi_rol_uygula(tip)` haritayı `rol.aktif` alanına yazan TEK
--  yerdir (API de, ileride bir betik de aynı duvara çarpsın). 785 sistem
--  rolünün pasife alınmasını zaten serbest bırakmıştı - bu iş tam olarak o
--  kapıdan geçiyor.
--
--  ============ KENDİNİ KİLİTLEME KORUMASI =============================
--  `yonetici` ve `atanmamis` pasife ALINAMAZ: ilki kurulumu yöneten tek rol,
--  ikincisi rolsüz kalan kullanıcının düştüğü yer. İkisi de kapanırsa kurum
--  kendi sistemine giremez hale gelir. Kural tetikte - ekran unutsa da,
--  doğrudan SQL yazılsa da tutar.
-- ============================================================================
\set ON_ERROR_STOP on

create table if not exists public.kurum_tipi_rol (
    kurum_tipi        varchar(40)  not null,
    rol_kod           varchar(40)  not null,
    -- 1 = bu profilde gecerli (aktif) · 0 = gecerli degil (pasif)
    gecerli           smallint     not null default 1,
    ekleyen           integer      not null default 0,
    ekleme_tarihi     timestamptz  not null default now(),
    degistiren        integer      not null default 0,
    degistirme_tarihi timestamptz,
    constraint pk_kurum_tipi_rol primary key (kurum_tipi, rol_kod),
    constraint ck_kurum_tipi_rol_gecerli check (gecerli in (0, 1))
);

comment on table public.kurum_tipi_rol is
  '786: hangi rol hangi kurum tipinde GECERLI. Bos = sablon varsayilani '
  '(StandartRolUclari). Satir varsa KURUMUN karari gecerlidir.';

-- ROL KODUNA FK YOK: sablon rolu heniz kurulmamis olabilir (kurum "gecerli"
--   isaretler, rol sonra kurulur). Yetim satir zararsizdir - uygulama
--   fonksiyonu yalniz VAR OLAN role dokunur.
create index if not exists ix_kurum_tipi_rol_kod on public.kurum_tipi_rol (rol_kod);

-- ------------------------------------------- kendini kilitleme korumasi ----
create or replace function public.fn_rol_kilit_koru()
returns trigger
language plpgsql
as $function$
begin
    if new.aktif = 0 and old.aktif = 1 and new.kod in ('yonetici', 'atanmamis') then
        raise exception '"%" rolü pasife alınamaz: % Bu rol kapanırsa kurum kendi sistemini yönetemez.',
              old.ad,
              case when new.kod = 'yonetici'
                   then 'kurulumu ve yetki dağıtımını yapan tek roldür.'
                   else 'rolü kaldırılan kullanıcıların düştüğü yerdir.' end
              using errcode = 'GK422';
    end if;
    return new;
end $function$;

comment on function public.fn_rol_kilit_koru() is
  '786: yonetici ve atanmamis rolleri pasife alinamaz - ikisi de kapanirsa '
  'kurum kendi sistemine giremez.';

drop trigger if exists tg_rol_kilit_koru on public.rol;

create trigger tg_rol_kilit_koru
    before update of aktif on public.rol
    for each row execute function public.fn_rol_kilit_koru();

-- --------------------------------------------- haritayi rol.aktif'e yaz ----
create or replace function public.fn_kurum_tipi_rol_uygula(p_tip varchar)
returns integer
language plpgsql
as $function$
declare
    v_sayi integer;
begin
    if coalesce(p_tip, '') = '' then
        raise exception 'Kurum tipi boş olamaz.' using errcode = 'GK422';
    end if;

    -- YALNIZ HARITADA ADI GECEN ROL: kurumun kendi actigi, haritaya hic
    --   girmemis rollere dokunulmaz - profil degisimi kimsenin elle kurdugu
    --   rolu sessizce kapatmamali.
    update public.rol r
       set aktif = k.gecerli,
           degistirme_tarihi = now()
      from public.kurum_tipi_rol k
     where k.kurum_tipi = p_tip
       and k.rol_kod = r.kod
       and r.aktif <> k.gecerli
       -- Kilitli roller tetikle zaten korunuyor; burada da atlanir ki
       --   uygulama tek bir rol yuzunden tamamen durmasin.
       and r.kod not in ('yonetici', 'atanmamis');

    get diagnostics v_sayi = row_count;
    return v_sayi;
end $function$;

comment on function public.fn_kurum_tipi_rol_uygula is
  '786: kurum_tipi_rol haritasini rol.aktif alanina yazan TEK yer. '
  'Haritada olmayan role dokunmaz; yonetici/atanmamis her zaman acik kalir.';

do $$
declare v_rol int; v_sistem int;
begin
    select count(*), count(*) filter (where sistem = 1) into v_rol, v_sistem
      from public.rol;
    raise notice '786 tamam: % rol (% sistem). kurum_tipi_rol BOS - profil '
                 'ekranindan isaretlenene kadar sablon varsayilani gecerli.',
                 v_rol, v_sistem;
end $$;
