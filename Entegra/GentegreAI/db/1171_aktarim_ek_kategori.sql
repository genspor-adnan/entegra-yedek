-- =============================================================================
--  1171  DELPHI AKTARIMI - STOK KATEGORİLERİ (KATEGORI)
--
--  Kullanıcı (24.10.2026, UNIVERSE): "universe stok kategorileri düzgün ama hizmet
--  eski kalmış". İnceleme: Delphi KATEGORI tablosu HİÇ aktarılmıyordu.
--    - stok.kategori Delphi kimliğini ham taşır (FK yok).
--    - kategori tablosunda 029'un SABİT yazdığı BILIM kategorileri (id 4-18) + kurulumun
--      HBYS tohumları (STK.* tıbbi malzeme, lab / radyoloji hizmet ağacı, id 19-99) vardı.
--    -> UNIVERSE stokları yanlış adla (5 = BILIM'in "Dental El Aletleri", Delphi'de
--       İMPLANT_ALPHADENT) ya da HBYS tohumuna (20 = "Biyokimya") düşüyordu; 105 DİĞER
--       (158 stok) hiç yoktu. UNIVERSE elle düzeltildi (yedekli); bu dosya kuralı koyar.
--
--  fn_aktar_ek_kategori(): stg.kategori'den AYNI KİMLİKLE stok kategorisi (tur 1) yazar,
--  üst kategori koddan ("K010.01" -> "K010"); Delphi'de olmayan ve hizmete bağlı olmayan
--  kategoriler silinir (tohum). fn_aktar_ek'in İLK adımı. İdempotent.
--  Delphi'de hizmet kategorisi yok (hizmetler MASRAFGELIR'den kategorisiz gelir).
-- =============================================================================
\set ON_ERROR_STOP on

begin;

create table if not exists stg.kategori (
    id     integer,
    kod    varchar(50),
    ad     varchar(100),
    durum  smallint
);

create or replace function public.fn_aktar_ek_kategori()
returns jsonb language plpgsql as $$
declare
    v_yaz integer;
    v_sil integer;
    v_ust integer;
begin
    if not exists (select 1 from stg.kategori) then
        return jsonb_build_object('atlandi', 'stg.kategori bos');
    end if;
    perform set_config('gentegre.aktarim', '1', true);

    -- Ağaç yeniden kurulur: önce bağlar çözülür (silinecek tohumun alt dalı kalmasın).
    update public.kategori set ust_id = null where ust_id is not null;

    insert into public.kategori (id, kod, ad, aktif, tur)
    select s.id, btrim(coalesce(s.kod, '')), btrim(coalesce(s.ad, '')),
           case when s.durum = 0 then 0 else 1 end, 1
      from stg.kategori s
     where s.id is not null
    on conflict (id) do update
       set kod = excluded.kod, ad = excluded.ad, aktif = excluded.aktif, tur = 1;
    get diagnostics v_yaz = row_count;

    update public.kategori k set ust_id = u.id
      from public.kategori u
     where k.id in (select id from stg.kategori)
       and position('.' in k.kod) > 0
       and u.kod = regexp_replace(k.kod, '\.[^.]*$', '')
       and u.id <> k.id;
    get diagnostics v_ust = row_count;

    -- Delphi'de olmayan kategori = kurulum tohumu (BILIM 029, HBYS) - hizmete bağlı değilse silinir.
    delete from public.kategori k
     where k.id not in (select id from stg.kategori where id is not null)
       and not exists (select 1 from public.hizmet h where h.kategori = k.id)
       and not exists (select 1 from public.stok_sayim y where y.kategori_id = k.id);
    get diagnostics v_sil = row_count;

    perform setval(pg_get_serial_sequence('public.kategori', 'id'),
                   greatest((select max(id) from public.kategori), 1));
    return jsonb_build_object('kategori', v_yaz, 'alt_kategori', v_ust, 'tohum_silinen', v_sil);
end $$;

comment on function public.fn_aktar_ek_kategori() is
  '1171: Delphi KATEGORI -> stok kategorileri (ayni kimlik, ust koddan). Delphi''de olmayan tohumlar silinir.';

-- fn_aktar_ek (1149): kategori İLK adım.
create or replace function public.fn_aktar_ek()
returns jsonb language plpgsql as $$
declare
    v_sonuc jsonb := '{}';
    v_m text;
    v_r jsonb;
begin
    perform set_config('gentegre.aktarim', '1', true);
    foreach v_m in array array['kategori', 'kisi', 'hesap_plani', 'demirbas', 'cek', 'teklif', 'gorev', 'dokuman', 'ebelge'] loop
        begin
            execute format('select public.fn_aktar_ek_%s()', v_m) into v_r;
            v_sonuc := v_sonuc || jsonb_build_object(v_m, v_r);
        exception when others then
            v_sonuc := v_sonuc || jsonb_build_object(v_m, jsonb_build_object('hata', sqlerrm));
        end;
    end loop;
    return v_sonuc;
end $$;

comment on function public.fn_aktar_ek() is
    '1149/1171: Delphi ek modülleri (stg) sırayla aktarır - kategori, kişi, hesap planı, demirbaş, çek, teklif, görev, döküman, e-Belge. Modül hatası diğerlerini durdurmaz.';

commit;
