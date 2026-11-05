-- =============================================================================
--  1268  DELPHI AKTARIMI - ŞUBE / FİRMA BİLGİSİ REHBER ID<0'DAN  (kullanıcı 05.11.2026: "şube/firma bilgileri
--        rehberde ID<0'da, aktarımlarda şube bilgisi için kullan")
--
--  Delphi'de kurumun kendi firma / şubeleri REHBER'de NEGATİF kimlikle durur (ID -1 merkez; bütün tabloların
--  SUBEID'si bu kimliktir: FATBASLIK.SUBEID = -1). Vergi dairesi / no, mersis, ticaret sicil REHBERBILGI'de
--  (YERI 2, YER_ID = REHBER.ID); adres / ilçe / il / ülke / telefon / e-posta / web varsayılan REHBERILETISIM
--  satırının REHBERBILGI'sinde (YERI 1). Cari adımı (1081) bu satırları "cari değil" diye atlıyordu; web şubesi
--  kurulum tohumuyla (Merkez, demo VKN) kalıyor ve e-Belge göndericisi (v_ebelge_gonderici) yanlış kimlik taşıyordu.
--
--  Bu dosya:
--   * sube tablosuna aktarım kimliği (aktarim_kaynak / tablo / id, 1080 deseni).
--   * fn_aktarim_sube_isle(p): paketteki REHBER ID<0 satırlarını web şubesine yazar. İLK BAĞ: Delphi merkezi (-1)
--     web'in varsayılan şubesine (aktarımsız tek şube) bağlanır - belgeler zaten fn_aktarim_sube ile ona düşmüştü;
--     öteki negatif kimlikler yeni şube açar. aktarim_sube_esleme doldurulur (SUBEID -> web şube).
--     Alanlar her pakette Delphi'den yenilenir (unvan, vkno, vd, mersis, sicil, adres, ilçe, il, ülke, pk,
--     telefon, e-posta, web); kısa ad (ad) yalnız yer tutucuysa ("Merkez" / ünvanla aynı / boş) ünvan olur.
--     e-Belge alias'ı (efatura_alias), entegratör ve mükellefiyet bayrakları DOKUNULMAZ (Delphi REHBERALIAS'ta
--     firma satırı yok; web'de girilir).
--   * fn_aktar_cari sarmalanır: önce şubeler, sonra 1081 gövdesi (fn_aktar_cari_1081). Sonuca 'sube' sayısı eklenir.
-- =============================================================================

begin;

alter table public.sube add column if not exists aktarim_kaynak smallint;
alter table public.sube add column if not exists aktarim_tablo varchar(30);
alter table public.sube add column if not exists aktarim_id bigint;
create unique index if not exists ux_sube_aktarim on public.sube (aktarim_kaynak, aktarim_tablo, aktarim_id)
    where aktarim_kaynak is not null;

create or replace function public.fn_aktarim_sube_isle(p jsonb)
returns integer language plpgsql as $$
declare
    v_sayi int := 0; v_yeni int := 0;
begin
    create temp table if not exists _sr  (like stg.rehber)         on commit drop;
    create temp table if not exists _sri (like stg.rehberiletisim) on commit drop;
    create temp table if not exists _srb (like stg.rehberbilgi)    on commit drop;
    truncate _sr, _sri, _srb;
    insert into _sr  select * from jsonb_populate_recordset(null::stg.rehber,         coalesce(p->'U'->'REHBER', '[]'));
    delete from _sr where id >= 0;
    if not exists (select 1 from _sr) then return 0; end if;
    insert into _sri select * from jsonb_populate_recordset(null::stg.rehberiletisim, coalesce(p->'U'->'REHBERILETISIM', '[]'));
    insert into _srb select * from jsonb_populate_recordset(null::stg.rehberbilgi,    coalesce(p->'U'->'REHBERBILGI', '[]'));

    -- 1) Bağ: aktarım kimliğiyle bulunur; -1 (merkez) ilk kez geliyorsa web'in aktarımsız varsayılan şubesine bağlanır.
    update public.sube s
       set aktarim_kaynak = 1, aktarim_tablo = 'REHBER', aktarim_id = r.id
      from _sr r
     where r.id = (select min(x.id) from _sr x where x.id = -1)
       and s.id = (select v.id from public.sube v where v.aktarim_kaynak is null order by v.varsayilan desc, v.id limit 1)
       and not exists (select 1 from public.sube y where y.aktarim_kaynak = 1 and y.aktarim_tablo = 'REHBER' and y.aktarim_id = r.id);

    insert into public.sube (kod, ad, unvan, aktif, varsayilan, ekleyen, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select left(coalesce(nullif(btrim(r.kod), ''), 'S' || abs(r.id)), 20),
           left(coalesce(nullif(btrim(r.firma), ''), 'Şube ' || abs(r.id)), 100),
           left(coalesce(nullif(btrim(r.firma), ''), ''), 200),
           case when coalesce(r.durum, 1) = 0 then 0 else 1 end, 0, 0, 1, 'REHBER', r.id
      from _sr r
     where not exists (select 1 from public.sube y where y.aktarim_kaynak = 1 and y.aktarim_tablo = 'REHBER' and y.aktarim_id = r.id);
    get diagnostics v_yeni = row_count;

    -- 2) Alanlar (mali kimlik YERI 2; adres varsayılan iletişim + YERI 1).
    with b2 as (
        select bi.yer_id as rehber_id, public.fn_etiket_anahtar(bi.etiket) as anahtar, btrim(bi.bilgi) as deger,
               row_number() over (partition by bi.yer_id, public.fn_etiket_anahtar(bi.etiket) order by bi.sira, bi.id) sn
          from _srb bi where bi.yeri = 2 and coalesce(btrim(bi.bilgi), '') <> ''
    ), il as (
        select distinct on (i.rehberid) i.rehberid as rehber_id, i.id as iletisim_id
          from _sri i where i.rehberid < 0
         order by i.rehberid, coalesce(i.varsayilan, 0) desc, coalesce(i.aktif, 1) desc, i.id
    ), b1 as (
        select bi.yer_id as iletisim_id, public.fn_etiket_anahtar(bi.etiket) as anahtar, btrim(bi.bilgi) as deger,
               row_number() over (partition by bi.yer_id, public.fn_etiket_anahtar(bi.etiket) order by bi.sira, bi.id) sn
          from _srb bi where bi.yeri = 1 and coalesce(btrim(bi.bilgi), '') <> ''
    ), m as (
        select r.id as rehber_id, btrim(r.firma) as firma, coalesce(r.durum, 1) as durum,
               max(b2.deger) filter (where b2.anahtar = 'vergi no')                              as vkno,
               max(b2.deger) filter (where b2.anahtar = 'vergi dairesi')                         as vd,
               max(b2.deger) filter (where b2.anahtar = 'mersis no')                             as mersis,
               max(b2.deger) filter (where b2.anahtar in ('ticari sicil no', 'ticaret sicil no', 'sicil no')) as sicil,
               max(b1.deger) filter (where b1.anahtar = 'adres')                                 as adres,
               max(b1.deger) filter (where b1.anahtar = 'ilce')                                  as ilce,
               max(b1.deger) filter (where b1.anahtar = 'il')                                    as il,
               max(b1.deger) filter (where b1.anahtar = 'ulke')                                  as ulke,
               max(b1.deger) filter (where b1.anahtar = 'pk')                                    as pk,
               max(b1.deger) filter (where b1.anahtar in ('is tel', 'tel', 'telefon'))           as telefon,
               max(b1.deger) filter (where b1.anahtar in ('eposta', 'e-posta', 'email'))         as eposta,
               max(b1.deger) filter (where b1.anahtar = 'web')                                   as web
          from _sr r
          left join b2 on b2.rehber_id = r.id and b2.sn = 1
          left join il on il.rehber_id = r.id
          left join b1 on b1.iletisim_id = il.iletisim_id and b1.sn = 1
         group by r.id, r.firma, r.durum
    )
    update public.sube s
       set unvan = left(coalesce(nullif(m.firma, ''), s.unvan), 200),
           ad = case when coalesce(s.ad, '') = '' or lower(s.ad) = 'merkez' or s.ad = s.unvan
                     then left(coalesce(nullif(m.firma, ''), s.ad), 100) else s.ad end,
           vkno = left(coalesce(m.vkno, s.vkno), 20), vd = left(coalesce(m.vd, s.vd), 60),
           mersis_no = left(coalesce(m.mersis, s.mersis_no), 20), ticaret_sicil_no = left(coalesce(m.sicil, s.ticaret_sicil_no), 30),
           adres = left(coalesce(m.adres, s.adres), 300), ilce = left(coalesce(m.ilce, s.ilce), 60), il = left(coalesce(m.il, s.il), 60),
           ulke = left(coalesce(m.ulke, s.ulke), 60), posta_kodu = left(coalesce(m.pk, s.posta_kodu), 10),
           telefon = left(coalesce(m.telefon, s.telefon), 30), eposta = left(coalesce(m.eposta, s.eposta), 120),
           web = left(coalesce(m.web, s.web), 200),
           aktif = case when m.durum = 0 then 0 else 1 end,
           degistirme_tarihi = now()
      from m
     where s.aktarim_kaynak = 1 and s.aktarim_tablo = 'REHBER' and s.aktarim_id = m.rehber_id
       and (s.unvan, s.vkno, s.vd, s.mersis_no, s.ticaret_sicil_no, s.adres, s.ilce, s.il, s.ulke, s.posta_kodu,
            s.telefon, s.eposta, s.web, s.aktif)
           is distinct from
           (left(coalesce(nullif(m.firma, ''), s.unvan), 200), left(coalesce(m.vkno, s.vkno), 20), left(coalesce(m.vd, s.vd), 60),
            left(coalesce(m.mersis, s.mersis_no), 20), left(coalesce(m.sicil, s.ticaret_sicil_no), 30),
            left(coalesce(m.adres, s.adres), 300), left(coalesce(m.ilce, s.ilce), 60), left(coalesce(m.il, s.il), 60),
            left(coalesce(m.ulke, s.ulke), 60), left(coalesce(m.pk, s.posta_kodu), 10), left(coalesce(m.telefon, s.telefon), 30),
            left(coalesce(m.eposta, s.eposta), 120), left(coalesce(m.web, s.web), 200), case when m.durum = 0 then 0 else 1 end);
    get diagnostics v_sayi = row_count;

    -- 3) SUBEID eşlemesi: bundan sonra fn_aktarim_sube(-1) bu şubeyi verir.
    insert into public.aktarim_sube_esleme (delphi_sube_id, sube_id)
    select s.aktarim_id, s.id from public.sube s
     where s.aktarim_kaynak = 1 and s.aktarim_tablo = 'REHBER' and s.aktarim_id in (select id from _sr)
    on conflict (delphi_sube_id) do update set sube_id = excluded.sube_id;

    return v_sayi + v_yeni;              -- yeni açılan + alanı değişen şube
end $$;

comment on function public.fn_aktarim_sube_isle(jsonb) is
    '1268: paketteki REHBER ID<0 (kurumun firma / şubeleri) -> sube; -1 web varsayılan şubesine bağlanır; aktarim_sube_esleme.';

-- ------------------------------------------- fn_aktar_cari sarmalı (1081 gövdesi) ---
do $$ begin
    if not exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                    where n.nspname = 'public' and p.proname = 'fn_aktar_cari_1081') then
        alter function public.fn_aktar_cari(jsonb) rename to fn_aktar_cari_1081;
    end if;
end $$;

create or replace function public.fn_aktar_cari(p jsonb)
returns jsonb language plpgsql as $$
declare v_sube int;
begin
    v_sube := public.fn_aktarim_sube_isle(p);
    return public.fn_aktar_cari_1081(p) || jsonb_build_object('sube', v_sube);
end $$;

comment on function public.fn_aktar_cari(jsonb) is
    '1268: şubeler (REHBER ID<0, fn_aktarim_sube_isle) + 1081 cari gövdesi (fn_aktar_cari_1081).';

commit;
