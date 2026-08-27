-- ============================================================================
--  Gentegre AI — GIB e-FATURA KULLANICI LISTESI ve ALIAS
--  186_gib_kullanici_alias.sql
--
--  SORUN (gercek gonderim testinde cikti): mukellefiyet, entegratorun
--  /v2/taxpayers ucuyla belirleniyordu. O uc VERGI DAIRESI kaydini doner -
--  faal her firma icin "aktif" der. Oysa e-Fatura kesilebilmesi icin alicinin
--  GIB e-FATURA KULLANICI LISTESINDE olmasi gerekir. Sonuc: her cari mukellef
--  sayiliyor, e-Fatura hazirlaniyor ve gonderimde entegrator
--  "RECEIVER_COULD_NOT_FOUND_IN_GIB_USER_LIST" ile reddediyordu.
--
--  DOGRU KAYNAK (Delphi UEBelgeAliasServis.pas ile ayni uc):
--      GET /v1/resources/gib-users?identifier=<VKN>
--  Donen her kayit bir POSTA KUTUSU (alias) + belge turu (INVOICE /
--  DESPATCHADVICE). Liste bossa alici e-Fatura kullanicisi DEGILDIR -> e-Arsiv.
--
--  Bu dosya: aliaslarin carida saklanacagi alanlar + hazirlamanin alias'i
--  belgeye tasimasi. Sorgunun kendisi C# tarafinda (EBelgeSorgu).
-- ============================================================================
\set ON_ERROR_STOP on

-- e-IRSALIYE posta kutusu AYRI olabilir (ayni VKN icin INVOICE ve
--   DESPATCHADVICE kayitlari farkli alias tasiyabiliyor).
alter table public.taraf
    add column if not exists alias_irsaliye varchar(200) not null default '';

-- e-Irsaliye kullanicisi mi (GIB listesinde DESPATCHADVICE kaydi var mi).
alter table public.taraf
    add column if not exists eirsaliye smallint not null default 0;

comment on column public.taraf.alias_eposta is
  'e-Fatura GIB posta kutusu (alias). e-Arsivde ayni alan ALICI E-POSTASI olur (Delphi ile ayni ikili anlam).';
comment on column public.taraf.alias_irsaliye is
  'e-Irsaliye GIB posta kutusu (186). Bos ise alias_eposta kullanilir.';
comment on column public.taraf.eirsaliye is
  'Alici GIB e-Irsaliye kullanicisi mi (186): 1 evet, 0 hayir.';

-- ---------------------------------------------------------------------------
--  Hazirlama: alici alias'ini CARIDEN belgeye tasi.
--    e-Fatura   -> taraf.alias_eposta
--    e-Irsaliye -> taraf.alias_irsaliye (yoksa alias_eposta)
--    e-Arsiv    -> bos; gonderimde kullaniciya e-posta sorulur (184).
--  Geri kalan mantik 179'dakiyle AYNI - yalniz alias satiri eklendi.
-- ---------------------------------------------------------------------------
create or replace function public.fn_ebelge_hazirla(p_belge_id integer,
                                                    p_kullanici integer)
returns table (e_belge_id bigint, belge_turu smallint, belge_no varchar,
               seri varchar, uyari text)
language plpgsql as $$
declare
    b            record;
    v_tur        smallint;
    v_durum      smallint;
    v_seri       varchar(10);
    v_no         varchar(30);
    v_id         bigint;
    v_mukellef   boolean;
    v_uyari      text := '';
    v_alias      varchar(200) := '';
begin
    select bl.*, t.efatura as taraf_efatura, t.unvan as taraf_ad,
           t.vkno as taraf_vkno, t.alias_eposta, t.alias_irsaliye
      into b
      from public.belge bl
      left join public.taraf t on t.id = bl.taraf_id
     where bl.id = p_belge_id;

    if b.id is null then
        raise exception 'Belge bulunamadı.';
    end if;
    if not public.fn_ebelge_acik(b.sube_id) then
        raise exception 'Bu şube e-Fatura mükellefi değil. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.';
    end if;
    if exists (select 1 from public.e_belge e where e.belge_id = b.id and e.durum > 0) then
        raise exception 'Bu belge için e-Belge zaten hazırlanmış (durum %).',
              (select max(e.durum) from public.e_belge e where e.belge_id = b.id);
    end if;

    -- DOGRULAMALAR - numara/seri TUKETILMEDEN.
    if coalesce(b.taraf_id, 0) = 0 then
        raise exception 'Belgede cari seçilmemiş.';
    end if;
    if coalesce(btrim(b.taraf_vkno), '') = '' then
        raise exception '% için vergi/kimlik numarası girilmemiş; e-Belge gönderilemez.', b.taraf_ad;
    end if;
    if not exists (select 1 from public.belge_satir s where s.belge_id = b.id) then
        raise exception 'Belgede kalem yok.';
    end if;
    if coalesce(b.genel_toplam, 0) <= 0 then
        raise exception 'Belge tutarı sıfır; e-Belge hazırlanamaz.';
    end if;
    if b.tur = 14
       and coalesce(btrim((select sv.arac_plaka from public.v_belge_sevkiyat sv
                            where sv.belge_id = b.id)), '') = ''
       and coalesce((select sv.tasiyici_id from public.v_belge_sevkiyat sv
                      where sv.belge_id = b.id), 0) = 0 then
        raise exception 'e-İrsaliyede taşıyıcı ya da araç plakası girilmeli (Taşıyıcı / Sevkiyat sekmesi).';
    end if;

    -- BELGE TURU: alici GIB e-Fatura KULLANICISI mi (cari kartindaki bayrak;
    --   bayragi entegratorun gib-users listesi tazeler - bkz. 186 basligi).
    v_mukellef := coalesce(b.taraf_efatura, 0) = 1;
    if b.tur = 14 then
        v_tur := 7; v_durum := 51;
    elsif coalesce(b.senaryo, 0) = 3 or v_mukellef then
        v_tur := 1; v_durum := 1;
        if coalesce(b.senaryo, 0) = 3 and not v_mukellef then
            v_uyari := 'İhracat faturası: alıcı GİB mükellefi değil, belge e-Fatura olarak hazırlandı.';
        end if;
    else
        v_tur := 2; v_durum := 11;
        v_uyari := 'Alıcı e-Fatura mükellefi değil; belge e-Arşiv olarak hazırlandı.';
    end if;

    if not public.fn_ebelge_mukellef_mi(b.sube_id, v_tur) then
        raise exception 'Bu şube % mükellefi değil. Yönetim › Firma Bilgileri › e-Belge''den işaretleyin.',
              public.fn_ebelge_tur_adi(v_tur);
    end if;

    -- ALICI POSTA KUTUSU (186): e-Arsivde bos kalir, gonderimde e-posta sorulur.
    v_alias := case
                 when v_tur = 1 then coalesce(btrim(b.alias_eposta), '')
                 when v_tur = 7 then coalesce(nullif(btrim(b.alias_irsaliye), ''),
                                              btrim(coalesce(b.alias_eposta, '')))
                 else ''
               end;
    if v_tur in (1, 7) and v_alias = '' then
        v_uyari := btrim(v_uyari || ' Alıcının GİB posta kutusu (alias) boş; ' ||
                         'cari kartından ya da mükellefiyet sorgusundan doldurun.');
    end if;

    v_seri := public.fn_ebelge_seri_bul(v_tur, coalesce(b.senaryo, 0), p_kullanici);
    if coalesce(btrim(v_seri), '') = '' then
        raise exception 'Bu belge türü için seri tanımı yok. Firma Bilgileri › e-Belge › Seri Bilgileri''nden ekleyin.';
    end if;

    v_no := public.fn_ebelge_no_uret(v_seri, extract(year from b.belge_tarihi)::integer);

    insert into public.e_belge (belge_id, taraf_id, belge_turu, yon, belge_no,
                                uuid, alici_alias, durum, ekleyen)
    values (b.id, b.taraf_id, v_tur, 1, v_no,
            gen_random_uuid()::text, v_alias, 1, p_kullanici)
    returning id into v_id;

    update public.belge bl
       set efatura_durum = v_durum,
           efatura_sonuc = 0,
           belge_no = case when coalesce(btrim(bl.belge_no), '') in ('', '0')
                           then v_no else bl.belge_no end,
           degistiren = p_kullanici,
           degistirme_tarihi = now()::timestamp
     where bl.id = b.id;

    return query select v_id, v_tur, v_no::varchar, v_seri::varchar, v_uyari;
end $$;

do $$
begin
    raise notice '186 tamam: taraf.alias_irsaliye + taraf.eirsaliye; hazirlama alias''i belgeye tasiyor.';
end $$;
