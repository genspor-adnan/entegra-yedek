-- =====================================================================
--  527_profil_kategori.sql
--  KURUM PROFİLİNE GÖRE KATEGORİ: hangi kurum neyi kullanıyor.
--
--  Kullanıcı: "firma profiline bu 2 kategoriyi eklesen, profile göre kimler
--  neyi kullanacak. Örneğin görüntüleme merkezi sadece radyoloji kullanır,
--  laboratuvar sadece tahlil işlemleri gibi." · "hizmet de o kategori
--  aktif/pasif veya hizmetin kendisi aktif/pasif olsun yeter" · "ikisi de
--  pasif olsun veya aktif".
--
--  KATEGORİ ANAHTAR, HİZMET ONU İZLER: kategori pasife çekilince altındaki
--  hizmet/stoklar da pasif olur, aktife alınınca geri açılır. Tek tek 10 bin
--  satır işaretlemek kullanıcının işi değil.
--
--  ELLE KAPATILAN GERİ AÇILMAZ: `profil_pasif` izi tutulur. Kullanıcı bir
--  hizmeti kendi kararıyla kapattıysa (artık yapmıyoruz), kategori yeniden
--  aktifleştiğinde o kayıt KAPALI kalır - yoksa profil değişimi kullanıcının
--  kararını sessizce siler ve kimse fark etmez.
--
--  TİP -> KATEGORİ ÖNERİSİ `kurum_tipi_kategori` tablosunda; 359'daki
--  `kurum_tipi_modul` deseninin aynısı. Öneri BAĞLAYICI DEĞİL: ekran işaretli
--  getirir, kullanıcı değiştirir (bir görüntüleme merkezi de muayene açabilir).
-- =====================================================================

alter table public.hizmet add column if not exists profil_pasif smallint not null default 0;
alter table public.stok   add column if not exists profil_pasif smallint not null default 0;

comment on column public.hizmet.profil_pasif is
    '1 = kategorisi kapatıldığı için pasif (527). Elle kapatılanlarda 0 kalır -
     kategori yeniden açılınca yalnız bu işaretliler geri aktifleşir.';
comment on column public.stok.profil_pasif is
    '1 = kategorisi kapatıldığı için pasif (527); bkz. hizmet.profil_pasif.';

/**
 * Kategorinin aktifliğini alt ağacıyla birlikte hizmet/stoklara yansıtır.
 * Ağaç: verilen kategori + altındaki tüm dallar.
 */
create or replace function public.fn_kategori_aktiflik_yay(p_kategori integer)
returns integer language plpgsql as $$
declare
    v_aktif smallint;
    v_sayi  integer := 0;
    v_ek    integer;
begin
    select aktif into v_aktif from public.kategori where id = p_kategori;
    if v_aktif is null then return 0; end if;

    -- Dal, her iki UPDATE'te de aynı CTE ile çözülür: geçici tablo aynı
    --   oturumda tekrar tekrar kurulunca "already exists" gürültüsü üretiyordu.
    if v_aktif = 0 then
        -- KAPAT: açık olanları kapat ve "profil kapattı" diye işaretle.
        with recursive dal as (
            select p_kategori as id
            union all select k.id from public.kategori k join dal d on k.ust_id = d.id)
        update public.hizmet h set durum = 0, profil_pasif = 1
         where h.kategori in (select id from dal) and h.durum <> 0;
        get diagnostics v_sayi = row_count;

        with recursive dal as (
            select p_kategori as id
            union all select k.id from public.kategori k join dal d on k.ust_id = d.id)
        update public.stok t set durum = 0, profil_pasif = 1
         where t.kategori in (select id from dal) and t.durum <> 0;
        get diagnostics v_ek = row_count;
    else
        -- AÇ: yalnız profilin kapattıkları geri gelir; kullanıcının elle
        --   kapattığı kayıt kapalı kalır.
        with recursive dal as (
            select p_kategori as id
            union all select k.id from public.kategori k join dal d on k.ust_id = d.id)
        update public.hizmet h set durum = 1, profil_pasif = 0
         where h.kategori in (select id from dal) and h.profil_pasif = 1;
        get diagnostics v_sayi = row_count;

        with recursive dal as (
            select p_kategori as id
            union all select k.id from public.kategori k join dal d on k.ust_id = d.id)
        update public.stok t set durum = 1, profil_pasif = 0
         where t.kategori in (select id from dal) and t.profil_pasif = 1;
        get diagnostics v_ek = row_count;
    end if;

    return v_sayi + coalesce(v_ek, 0);
end $$;

comment on function public.fn_kategori_aktiflik_yay(integer) is
    'Kategori aktif/pasif durumunu alt ağacıyla hizmet ve stoklara yayar (527).';

/**
 * Kategori aktifliği değişince yayılım KENDİLİĞİNDEN işler: kategoriyi
 * kim kapatırsa kapatsın (profil ekranı, kategori kartı, göç) sonuç aynı
 * olsun - kural tek yerde dursun.
 */
create or replace function public.tg_kategori_aktiflik() returns trigger
language plpgsql as $$
begin
    if new.aktif is distinct from old.aktif then
        perform public.fn_kategori_aktiflik_yay(new.id);
    end if;
    return new;
end $$;

drop trigger if exists tg_kategori_aktiflik on public.kategori;
create trigger tg_kategori_aktiflik
    after update of aktif on public.kategori
    for each row execute function public.tg_kategori_aktiflik();

-- ======================================== tip -> kategori önerisi ==
create table if not exists public.kurum_tipi_kategori (
    kurum_tipi   varchar(30) not null references public.kurum_tipi(kod) on delete cascade,
    kategori_kod varchar(80) not null,      -- kategori.kod ("SUT.7")
    varsayilan   smallint    not null default 1,   -- 1 açık · 0 kapalı
    primary key (kurum_tipi, kategori_kod)
);
comment on table public.kurum_tipi_kategori is
    'Kurum tipinin ÖNERDİĞİ kategori seti (527) - bağlayıcı değil, ekran işaretli getirir.';

do $$
declare
    v_tip  text;
    v_kat  text;
    -- Tip başına AÇIK kategoriler; burada olmayan kategori o tipte kapalı gelir.
    v_oneri jsonb := jsonb_build_object(
        -- Görüntüleme merkezi: radyoloji tetkiki + muayene (istem hekimi).
        'goruntuleme',     jsonb_build_array('SUT.7', 'SUT.1'),
        -- Laboratuvar: tahlil + kan işlemleri.
        'lab',             jsonb_build_array('SUT.8', 'SUT.10'),
        'goruntuleme_lab', jsonb_build_array('SUT.7', 'SUT.8', 'SUT.10', 'SUT.1'),
        -- Diş kliniği: diş işlemi + muayene + röntgen.
        'dis',             jsonb_build_array('SUT.3', 'SUT.1', 'SUT.7'),
        -- Muayenehane: muayene + diğer işlemler + konsültasyon.
        'muayenehane',     jsonb_build_array('SUT.1', 'SUT.9', 'SUT.4'),
        'dal_goz',         jsonb_build_array('SUT.1', 'SUT.9', 'SUT.6', 'SUT.7'),
        'dal_ftr',         jsonb_build_array('SUT.1', 'SUT.9'),
        -- Tıp merkezi / hastane: hepsi (malzeme dâhil).
        'tip_merkezi',     jsonb_build_array('SUT.1','SUT.2','SUT.3','SUT.4','SUT.6',
                                             'SUT.7','SUT.8','SUT.9','SUT.10','SUT.TTB','SUT.5'),
        'hastane',         jsonb_build_array('SUT.1','SUT.2','SUT.3','SUT.4','SUT.6',
                                             'SUT.7','SUT.8','SUT.9','SUT.10','SUT.TTB','SUT.5'),
        -- ERP kurulumunda SUT katalogu kullanılmaz.
        'erp',             jsonb_build_array()
    );
begin
    for v_tip in select kod from public.kurum_tipi loop
        for v_kat in select kod from public.kategori loop
            insert into public.kurum_tipi_kategori (kurum_tipi, kategori_kod, varsayilan)
            select v_tip, v_kat,
                   case when v_oneri -> v_tip ? v_kat then 1 else 0 end
             where not exists (select 1 from public.kurum_tipi_kategori x
                                where x.kurum_tipi = v_tip and x.kategori_kod = v_kat);
        end loop;
    end loop;
end $$;

/**
 * Profilin tipine göre kategori setini uygular: öneride açık olanlar aktif,
 * ötekiler pasif. Hizmet/stok durumu tetikle kendiliğinden izler.
 * Dönen sayı: durumu DEĞİŞEN kategori adedi.
 */
create or replace function public.fn_kurum_kategori_uygula(p_tip text)
returns integer language plpgsql as $$
declare v_sayi integer;
begin
    update public.kategori k
       set aktif = coalesce(t.varsayilan, 0)
      from public.kurum_tipi_kategori t
     where t.kurum_tipi = p_tip and t.kategori_kod = k.kod
       and k.aktif is distinct from coalesce(t.varsayilan, 0);
    get diagnostics v_sayi = row_count;
    return v_sayi;
end $$;

comment on function public.fn_kurum_kategori_uygula(text) is
    'Kurum tipinin önerdiği kategori setini uygular; hizmet/stok durumu tetikle izler (527).';
