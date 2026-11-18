-- =============================================================================
--  1370  AKTARIM İNCELEMESİ 18.11.2026 (bulgu 1, 2, 6, 7) - SÜREKLİ SENKRON
--
--  1) SİLİNEN BELGE SENKRONU KİLİTLİYORDU: fn_aktar_belge Delphi'de silinen belgeyi doğrudan siliyordu. Belgeye
--     web'de bağlı kayıt (1261'in kurduğu üretim fişi; web tahsilatı, randevu, istem...) varsa FK ihlali adımı
--     düşürüyor, fn_aktar_paket ilk hatalı adımda durduğu için kasa / e-Belge / XSLT hiç çalışmıyordu - senkron elle
--     düzeltilene kadar kilitli. fn_aktar_belge SARMALANIR (1188 gövdesi fn_aktar_belge_1188): silme sarmalda
--     belge belge yapılır; aktarım üretim fişi önce kalkar, başka bağlı kayıt varsa belge SİLİNMEZ, iptal (6) olur -
--     cari satırı ve lot izlemi kalkar (Delphi'deki etkisi gibi), web kaydının bağı yaşar. Sonuç: 'silinemeyen'.
--  6) TRANSFER VARIŞI SÜREKLİ SENKRONDA: 1248 varış satırını (STOKIZLEME_VARIS) yalnız tek seferlik ek aktarımda
--     kuruyordu; sonraki Delphi transferinde varış deposunun lot bakiyesi hiç artmıyor, düzenlenen / silinen
--     transferin varışı kalıyordu. Sarmal, paketteki belgelerin varış satırlarını siler ve eksikleri yeniden kurar
--     (öksüz varış da silinir); lot bakiyesi aktarım tetiğiyle (tg_stok_izleme_lot_aktarim) yeniden hesaplanır.
--  7) ÜRETİM FİŞİ İPTALİ: 1261 yalnız belge durum 2'yi iptal sayıyordu; Delphi iptali DURUM = 6
--     (UFaturaWizard: update FATBASLIK set DURUM=6). İptal üretim fişi "gerçekleşti" görünüyor ve mamul maliyet
--     ortalamasına (fn_uretim_stok_maliyeti, durum süzgeçsiz) giriyordu. Fiş durumu belgeden eşitlenir (2/6 ->
--     0 ters kayıt); ortalama maliyet son maliyetle aynı süzgeçte (b.durum = 0). Üretim fişi de sürekli senkronda:
--     paketteki tür 6 belgenin aktarım fişi yeniden kurulur (fn_aktarim_uretim_fisi_kur), yeni üretim fiş olur.
--  2) ŞUBE EŞLEMESİ EZİLİYORDU: fn_aktarim_sube_isle her REHBER ID<0 satırında aktarim_sube_esleme'yi `do update`
--     ile yazıyor, eşlenmemiş aktarım kimliği için yeni şube açıyordu - kullanıcının elle eşlemesi (PUT
--     /api/kurum-profil/aktarim/sube-esleme) kopya şubeye çevriliyordu. Eşleme varsa yeni şube açılmaz, eşlenen
--     aktarımsız şubeye bağlanılır; eşleme yalnız eksikse yazılır.
--
--  VERİ ONARIMI (yalnız kanıtlı satırlar, sayılar bildirilir): eksik transfer varış satırları kurulur (1248 kuralı;
--  ilk ölçüm: MEDX 4.423), aktarım üretim fişi durumu belgeden eşitlenir. Aktarımsız kurulumda 0 iş. İdempotent.
-- =============================================================================
\set ON_ERROR_STOP on
begin;
set local gentegre.aktarim = '1';     -- aktarım oturumu: salt okunur tetikleri geçer, lot tetiği çalışır

-- ------------------------------------------------------------------ (2) şube --
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

    -- 1370: KULLANICININ EŞLEMESİ ESASTIR. Delphi şubesi (SUBEID) Kurum Profili > Aktarım'da bir web şubesine elle
    --   eşlendiyse yeni şube AÇILMAZ; eşlenen şube aktarım bağı taşımıyorsa ona bağlanır (alanları Delphi'den gelir).
    update public.sube s
       set aktarim_kaynak = 1, aktarim_tablo = 'REHBER', aktarim_id = r.id
      from _sr r
      join public.aktarim_sube_esleme e on e.delphi_sube_id = r.id
     where s.id = e.sube_id and s.aktarim_kaynak is null
       and not exists (select 1 from public.sube y where y.aktarim_kaynak = 1 and y.aktarim_tablo = 'REHBER' and y.aktarim_id = r.id);

    insert into public.sube (kod, ad, unvan, aktif, varsayilan, ekleyen, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select left(coalesce(nullif(btrim(r.kod), ''), 'S' || abs(r.id)), 20),
           left(coalesce(nullif(btrim(r.firma), ''), 'Şube ' || abs(r.id)), 100),
           left(coalesce(nullif(btrim(r.firma), ''), ''), 200),
           case when coalesce(r.durum, 1) = 0 then 0 else 1 end, 0, 0, 1, 'REHBER', r.id
      from _sr r
     where not exists (select 1 from public.sube y where y.aktarim_kaynak = 1 and y.aktarim_tablo = 'REHBER' and y.aktarim_id = r.id)
       and not exists (select 1 from public.aktarim_sube_esleme e where e.delphi_sube_id = r.id);   -- 1370: eşlenmiş
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

    -- 3) SUBEID eşlemesi: bundan sonra fn_aktarim_sube(-1) bu şubeyi verir. 1370: YALNIZ EKSİK EŞLEME yazılır -
    --   eskiden her pakette `do update` ile kullanıcının elle yaptığı eşleme ezilip kopya şubeye çevriliyordu.
    insert into public.aktarim_sube_esleme (delphi_sube_id, sube_id)
    select s.aktarim_id, s.id from public.sube s
     where s.aktarim_kaynak = 1 and s.aktarim_tablo = 'REHBER' and s.aktarim_id in (select id from _sr)
    on conflict (delphi_sube_id) do nothing;

    return v_sayi + v_yeni;              -- yeni açılan + alanı değişen şube
end $$;

comment on function public.fn_aktarim_sube_isle(jsonb) is
    '1268/1370: paketteki REHBER ID<0 -> sube; -1 web varsayılan şubesine, elle eşlenmiş SUBEID eşlenen şubeye bağlanır; eşleme ezilmez.';

-- ------------------------------------------------------- (7) maliyet süzgeci --
create or replace function public.fn_uretim_stok_maliyeti(p_stok_id integer)
returns numeric language sql stable as $$
    select coalesce(
      (select case when sum(bs.miktar) > 0
                   then round(sum(bs.tutar) / sum(bs.miktar), 4) else null end
         from public.belge_satir bs
         join public.belge b on b.id = bs.belge_id
        where bs.stok_id = p_stok_id
          and bs.miktar > 0
          and b.durum = 0                -- 1370: taslak / iptal (Delphi 6) girişi ortalamaya girmez (son maliyetle aynı)
          and b.tur in (3, 6, 10, 11, 12, 109, 122)),
      (select f.fiyat from public.stok_fiyat f
        where f.stok_id = p_stok_id and f.satis = 0 and f.fiyat > 0
        order by f.id limit 1),
      0);
$$;

-- ------------------------------------------------- (7) üretim fişi durumu --
create or replace function public.fn_aktarim_uretim_fisi_durum_esitle()
returns integer language plpgsql as $$
declare v_n integer;
begin
    update public.uretim_fisi f
       set durum = case when b.durum in (2, 6) then 0 else 2 end,
           ters_an = case when b.durum in (2, 6) then coalesce(f.ters_an, b.degistirme_tarihi, b.belge_tarihi) end,
           ters_kullanici_id = case when b.durum in (2, 6) then coalesce(f.ters_kullanici_id, b.degistiren) end,
           ters_neden = case when b.durum in (2, 6) then 'Delphi: iptal edilmiş üretim fişi' else '' end
      from public.belge b
     where f.aktarim_tablo = 'FATBASLIK' and b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK'
       and b.aktarim_id = f.aktarim_id
       and f.durum is distinct from (case when b.durum in (2, 6) then 0 else 2 end)::smallint;
    get diagnostics v_n = row_count;
    return v_n;
end $$;

comment on function public.fn_aktarim_uretim_fisi_durum_esitle() is
    '1370: aktarım üretim fişinin durumu belgeden - Delphi iptali (2 / 6) ters kayıt (0), değilse gerçekleşti (2).';

-- ---------------------------------------------------- (6) transfer varışı --
-- p_belgeler: yalnız bu web belgelerinin varışı yenilenir (null = hepsi). Varış satırı silinip eksikler kurulur;
-- lot bakiyesi aktarım tetiğiyle (gentegre.aktarim = 1) hesaplanır - fn_aktarim_transfer_varis_tamamla'nın elle
-- +adet yazması burada YOK (tetikle çift sayılırdı).
create or replace function public.fn_aktarim_transfer_varis_esitle(p_belgeler integer[])
returns jsonb language plpgsql as $$
declare v_sil integer; v_ekle integer;
begin
    perform set_config('gentegre.aktarim', '1', true);
    delete from public.stok_izleme v
     where v.aktarim_kaynak = 1 and v.aktarim_tablo = 'STOKIZLEME_VARIS'
       and (p_belgeler is null or v.belge_id = any (p_belgeler)
            or not exists (select 1 from public.stok_izleme c where c.id = v.donus_id
                            and c.aktarim_kaynak = 1 and c.aktarim_tablo = 'STOKIZLEME'));
    get diagnostics v_sil = row_count;

    insert into public.stok_izleme
           (stok_id, seri_lot_id, izlem_tur, belge_tur, belge_id, belge_satir_id, adet, kalan,
            donus_id, depo_id, aktarim_kaynak, aktarim_tablo, aktarim_id)
    select i.stok_id, i.seri_lot_id, i.izlem_tur, 20, i.belge_id, i.belge_satir_id, i.adet, i.kalan,
           i.id, coalesce(bs.giris_depo_id, b.giris_depo_id), 1, 'STOKIZLEME_VARIS', i.aktarim_id
      from public.stok_izleme i
      left join public.belge_satir bs on bs.id = i.belge_satir_id
      join public.belge b on b.id = i.belge_id
     where i.aktarim_kaynak = 1 and i.aktarim_tablo = 'STOKIZLEME'
       and i.belge_tur = 20 and coalesce(i.donus_id, 0) = 0
       and (p_belgeler is null or i.belge_id = any (p_belgeler))
       and coalesce(bs.giris_depo_id, b.giris_depo_id) is not null
       and coalesce(bs.giris_depo_id, b.giris_depo_id) is distinct from i.depo_id
       and not exists (select 1 from public.stok_izleme v where v.belge_tur = 20 and v.donus_id = i.id);
    get diagnostics v_ekle = row_count;
    return jsonb_build_object('varis_silinen', v_sil, 'varis_eklenen', v_ekle);
end $$;

comment on function public.fn_aktarim_transfer_varis_esitle(integer[]) is
    '1370: Delphi transferinin varış lot satırını (STOKIZLEME_VARIS) verilen belgeler için yeniden kurar (null = hepsi); sürekli senkron.';

-- ------------------------------------------------------- fn_aktar_belge sarmalı --
do $$ begin
    if not exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
                    where n.nspname = 'public' and p.proname = 'fn_aktar_belge_1188') then
        alter function public.fn_aktar_belge(jsonb) rename to fn_aktar_belge_1188;
    end if;
end $$;

create or replace function public.fn_aktar_belge(p jsonb)
returns jsonb language plpgsql as $$
declare
    v_d        bigint[];
    v_u        bigint[];
    v_web      integer;
    v_delphi   bigint;
    v_iptal    jsonb := '[]';
    v_sonuc    jsonb;
    v_fis_sil  integer;
    v_belgeler integer[];
    v_varis    jsonb;
    v_fis      jsonb := null;
    v_fis_durum integer := 0;
begin
    perform set_config('gentegre.aktarim', '1', true);   -- aktarım oturumu (salt okunur tetik geçer, lot tetiği çalışır)
    select coalesce(array_agg((e #>> '{}')::bigint), '{}') into v_d
      from jsonb_array_elements(coalesce(p->'D'->'FATBASLIK', '[]')) e;
    select coalesce(array_agg((e ->> 'id')::bigint), '{}') into v_u
      from jsonb_array_elements(coalesce(p->'U'->'FATBASLIK', '[]')) e;

    -- (7) Paketteki belgelerin AKTARIM üretim fişleri kalkar; aşağıda güncel belgeden yeniden kurulur.
    update public.belge x set kaynak_tur = 0, kaynak_id = 0
     where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATBASLIK' and x.aktarim_id = any (v_d || v_u)
       and x.kaynak_tur = 61
       and x.kaynak_id in (select f.id from public.uretim_fisi f
                            where f.aktarim_tablo = 'FATBASLIK' and f.aktarim_id = any (v_d || v_u));
    delete from public.uretim_fisi f where f.aktarim_tablo = 'FATBASLIK' and f.aktarim_id = any (v_d || v_u);
    get diagnostics v_fis_sil = row_count;

    -- (1) Silinen belgeler BELGE BELGE: web'de bağlı kayıt varsa silinmez, iptal (6) olur.
    for v_web, v_delphi in
        select x.id, x.aktarim_id from public.belge x
         where x.aktarim_kaynak = 1 and x.aktarim_tablo = 'FATBASLIK' and x.aktarim_id = any (v_d)
    loop
        begin
            delete from public.mali_hareket m
             where m.belge_id = v_web and m.aktarim_kaynak = 1 and m.aktarim_tablo = 'FATBASLIK';
            delete from public.belge x where x.id = v_web;
        exception when foreign_key_violation then
            delete from public.mali_hareket m
             where m.belge_id = v_web and m.aktarim_kaynak = 1 and m.aktarim_tablo = 'FATBASLIK';
            delete from public.stok_izleme i where i.belge_id = v_web and i.aktarim_kaynak = 1;
            update public.belge x set durum = 6 where x.id = v_web;
            v_iptal := v_iptal || to_jsonb(v_delphi);
        end;
    end loop;

    v_sonuc := public.fn_aktar_belge_1188(jsonb_set(p, '{D}', coalesce(p->'D', '{}') - 'FATBASLIK'));

    -- (6) Transfer varışı: paketteki belgeler (başlığı ya da izlemi gelen) + öksüz varışlar.
    select coalesce(array_agg(distinct x.id), '{}') into v_belgeler
      from (select b.id from public.belge b
             where b.aktarim_kaynak = 1 and b.aktarim_tablo = 'FATBASLIK' and b.aktarim_id = any (v_u) and b.tur = 20
            union
            select i.belge_id from public.stok_izleme i
             where i.aktarim_kaynak = 1 and i.aktarim_tablo = 'STOKIZLEME' and i.belge_tur = 20
               and i.aktarim_id in (select (e ->> 'id')::bigint
                                      from jsonb_array_elements(coalesce(p->'U'->'STOKIZLEME', '[]')) e)) x;
    v_varis := public.fn_aktarim_transfer_varis_esitle(v_belgeler);

    -- (7) Üretim fişleri: eksikler kurulur (yeni Delphi üretimi + yukarıda kalkanlar), durum belgeden.
    if cardinality(v_u) > 0 or v_fis_sil > 0 then
        v_fis := public.fn_aktarim_uretim_fisi_kur();
    end if;
    v_fis_durum := public.fn_aktarim_uretim_fisi_durum_esitle();

    return v_sonuc || jsonb_build_object(
        'silinemeyen_iptal', v_iptal, 'transfer_varis', v_varis,
        'uretim_fisi', coalesce(v_fis, '{}'::jsonb) || jsonb_build_object('yenilenen', v_fis_sil, 'durum_esitlenen', v_fis_durum));
end $$;

comment on function public.fn_aktar_belge(jsonb) is
    '1370: silme belge belge (bağlı web kaydı varsa iptal 6) + 1188 gövdesi (fn_aktar_belge_1188) + transfer varışı + üretim fişi.';

-- ------------------------------------------------------------------ onarım --
do $$
declare v_varis jsonb; v_fis integer;
begin
    v_varis := public.fn_aktarim_transfer_varis_esitle(null);
    v_fis := public.fn_aktarim_uretim_fisi_durum_esitle();
    raise notice '1370: transfer varışı %, üretim fişi durumu eşitlenen %', v_varis, v_fis;
end $$;

commit;
