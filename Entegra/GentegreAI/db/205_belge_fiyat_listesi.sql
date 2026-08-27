-- ============================================================================
--  Gentegre AI — BELGENIN FIYAT LISTESI + TOPLU YENIDEN FIYATLAMA
--  205_belge_fiyat_listesi.sql
--
--  Kullanici: "belgelerdeki fiyat listesine gore urun fiyatlanmalidir; fiyat
--  listesi degisirse tum urunlerin fiyatlari yenilenir."
--
--  Belge ARTIK LISTEYI TASIYOR (`belge.fiyat_listesi_id`). Iki sebep:
--    - Belge acilinca cariden cozulen liste kart uzerinde GORUNUR ve
--      degistirilebilir (kampanya listesine gecmek gibi).
--    - Kesilmis belge hangi listeyle fiyatlandigini SAKLAR. Liste sonradan
--      degisse bile "bu fatura hangi listeden cikti" sorusu cevaplanabilir;
--      belge_satir zaten fiyati donduruyor, bu onun aciklamasi.
--
--  YENIDEN FIYATLAMA elle tetiklenir (liste degisince arayuz cagirir), kendi
--  kendine calismaz: kullanicinin elle duzelttigi satir fiyatini bir tetik
--  sessizce ezerse fatura yanlis tutarla kesilir.
-- ============================================================================
\set ON_ERROR_STOP on

alter table public.belge
    add column if not exists fiyat_listesi_id integer;

do $$
begin
    if not exists (select 1 from pg_constraint where conname = 'fk_belge_fiyat_listesi') then
        alter table public.belge add constraint fk_belge_fiyat_listesi
            foreign key (fiyat_listesi_id) references public.fiyat_listesi (id);
    end if;
end $$;

comment on column public.belge.fiyat_listesi_id is
  'Bu belgeye uygulanan fiyat listesi (205). Acilista cariden cozulur, kullanici degistirebilir.';

create index if not exists ix_belge_fiyat_listesi on public.belge (fiyat_listesi_id)
    where fiyat_listesi_id is not null;

-- ---------------------------------------------------------------------------
--  Belge turu hangi YONDE? Alis belgelerinde alis listesi, satista satis.
--  Tur kodlari kasa_islem_turu katalogunda; burada belge turu -> yon esleme
--  TEK YERDE olsun diye fonksiyona alindi.
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_yon(p_tur integer)
returns smallint
language sql immutable parallel safe as $$
    -- Alis tarafi: 9 alis siparisi, 10 alis irsaliyesi, 11 alis faturasi,
    --   12 alis fisi, 109 alis konsinye. Kalanlar satis kabul edilir.
    select case when p_tur in (9, 10, 11, 12, 109) then 1 else 2 end::smallint
$$;

comment on function public.fn_belge_yon(integer) is
  'Belge turunun fiyat yonu (205): 1 alis, 2 satis.';

-- ---------------------------------------------------------------------------
--  BELGEYI YENIDEN FIYATLA
--
--  Liste degistiginde butun satirlarin birim fiyati listeden yeniden okunur.
--  Donen sayilar arayuzde gosterilir: kac satir degisti, kac satirin fiyati
--  listede bulunamadi (o satirlara DOKUNULMAZ - 0 TL yazmak sessiz bir hata
--  olurdu).
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_fiyatlandir(
    p_belge_id  integer,
    p_liste_id  integer default null,     -- null ise belgenin kendi listesi
    p_kullanici integer default 0)
returns table (degisen integer, ayni integer, bulunamayan integer, liste_adi varchar)
language plpgsql as $$
declare
    b        public.belge%rowtype;
    v_liste  integer;
    v_deg    integer := 0;
    v_ayni   integer := 0;
    v_yok    integer := 0;
    s        record;
    v_f      record;
begin
    select * into b from public.belge where id = p_belge_id;
    if not found then
        raise exception 'Belge bulunamadi: %', p_belge_id;
    end if;
    -- KESIN belge yeniden fiyatlanmaz: tutari degistirmek muhasebe fisini ve
    --   (gonderilmisse) e-Belgeyi yalanci yapar. Duzeltme = iptal + yeni belge.
    if b.durum = 0 then
        raise exception 'Kesin belge yeniden fiyatlanamaz; duzeltme icin belge iptal edilip yeniden kesilmeli.'
            using errcode = 'GK422';
    end if;

    v_liste := coalesce(p_liste_id, b.fiyat_listesi_id);
    if v_liste is null then
        raise exception 'Fiyat listesi verilmedi ve belgede tanimli liste yok.'
            using errcode = 'GK422';
    end if;

    for s in select id, stok_id, hizmet_id, birim_fiyat
               from public.belge_satir where belge_id = p_belge_id
              order by sira, id
    loop
        -- Masraf satirlari (stok ve hizmet bos) listede yer almaz - atlanir.
        if s.stok_id is null and s.hizmet_id is null then
            continue;
        end if;

        select * into v_f from public.fn_fiyat_listesi_fiyat(v_liste, s.stok_id, s.hizmet_id);

        if v_f.fiyat is null or v_f.fiyat <= 0 then
            v_yok := v_yok + 1;
            continue;                      -- satira DOKUNMA
        end if;

        if round(coalesce(s.birim_fiyat, 0), 4) = round(v_f.fiyat, 4) then
            v_ayni := v_ayni + 1;
        else
            update public.belge_satir
               set birim_fiyat = v_f.fiyat,
                   doviz_cinsi = coalesce(nullif(v_f.doviz_cinsi, ''), doviz_cinsi),
                   degistiren  = p_kullanici
             where id = s.id;
            v_deg := v_deg + 1;
        end if;
    end loop;

    update public.belge
       set fiyat_listesi_id = v_liste, degistiren = p_kullanici
     where id = p_belge_id;

    return query select v_deg, v_ayni, v_yok,
                        (select ad from public.fiyat_listesi where id = v_liste);
end $$;

comment on function public.fn_belge_fiyatlandir(integer, integer, integer) is
  'Belgenin TUM satirlarini listeden yeniden fiyatlar (205). Listede olmayan kalemin satirina DOKUNMAZ.';

-- ---------------------------------------------------------------------------
--  Belge acilirken/olusturulurken cariden cozulen liste.
-- ---------------------------------------------------------------------------
create or replace function public.fn_belge_varsayilan_liste(
    p_tur      integer,
    p_taraf_id integer,
    p_tarih    date default current_date)
returns integer
language sql stable parallel safe as $$
    select public.fn_cari_fiyat_listesi(p_taraf_id, public.fn_belge_yon(p_tur), p_tarih)
$$;

comment on function public.fn_belge_varsayilan_liste(integer, integer, date) is
  'Belge acilirken gelecek fiyat listesi (205): belge turunun yonune gore cari listesi > varsayilan.';

do $$
begin
    raise notice '205 tamam: belge.fiyat_listesi_id + fn_belge_yon / fn_belge_fiyatlandir / fn_belge_varsayilan_liste.';
end $$;
