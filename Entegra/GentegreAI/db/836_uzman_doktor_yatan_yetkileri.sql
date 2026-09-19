-- ============================================================================
--  Gentegre AI — UZMAN DOKTOR: YATAN HASTA YETKİLERİ + ROLÜ GEÇERLİ KIL
--  836_uzman_doktor_yatan_yetkileri.sql
--
--  835'te Uzman Doktor şablonuna yatan hasta order'ı eklendi (uzman ile
--  pratisyenin farkı orada). Şablon KURULU ROLÜ EZMEZ, bu yüzden eksik
--  yetkiler burada eklenir - 831 deseni: yalnız ekler, hiçbir şey silmez.
--
--  ============ ROL BU PROFİLDE GEÇERSİZ GÖRÜNÜYORDU =================
--  `hekim` rolü hastane profilinde `gecerli = 0` işaretliydi ve `rol.aktif`
--  0'a çekilmişti - oysa o rolde 50 kullanıcı var. Yetkiler çalışmaya devam
--  ediyordu (`fn_kullanici_rolleri` rol.aktif'e bakmıyor), ama rol listeleri
--  ve yeni hesap açma ekranları onu "geçersiz" gösteriyordu.
--
--  KİŞİSİ OLAN ROL PASİF BIRAKILMAZ: düzeltme yalnız bu koşulla sınırlı -
--  kişisi olmayan rollerin işareti kurumun kararıdır, dokunulmaz.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_kodlar text[] := array['yatan', 'yatan.izlem', 'yatan.order',
                             'ameliyathane', 'ameliyathane.plan'];
    v_kod text;
    v_eklenen integer := 0;
    v_sayi integer;
begin
    foreach v_kod in array v_kodlar loop
        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
        select r.id, y.id, 1,
               -- `ameliyathane%` SALT OKUMA: uzman çizelgeyi görür, planı
               --   başhekim/başhemşire kurar.
               case when v_kod like 'ameliyathane%' then 0 else 1 end,
               case when v_kod like 'ameliyathane%' then 0 else 1 end,
               0
          from public.rol r join public.yetki y on y.kod = v_kod
         where r.kod = 'hekim'
           and not exists (select 1 from public.rol_yetki x
                            where x.rol_id = r.id and x.yetki_id = y.id);
        get diagnostics v_sayi = row_count;
        v_eklenen := v_eklenen + v_sayi;
    end loop;

    -- Order imzası aksiyon: gör = izin.
    insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil)
    select r.id, y.id, 1, 0, 0, 0
      from public.rol r join public.yetki y on y.kod = 'yatan.order.imza'
     where r.kod = 'hekim'
       and not exists (select 1 from public.rol_yetki x
                        where x.rol_id = r.id and x.yetki_id = y.id);
    get diagnostics v_sayi = row_count;
    v_eklenen := v_eklenen + v_sayi;
    raise notice '836: Uzman Doktor rolune % yetki eklendi.', v_eklenen;
end $$;

-- ------------------------------------------------- kişisi olan rol açık ----
do $$
declare r record; v_sayi integer := 0;
begin
    for r in
        select rr.id, rr.kod, rr.ad,
               (select count(*) from public.taraf_kullanici k
                 where k.rol_id = rr.id and k.aktif = 1) as kisi
          from public.rol rr
         where rr.aktif = 0 and coalesce(rr.portal_turu, 0) = 0
    loop
        if r.kisi > 0 then
            update public.rol set aktif = 1, degistirme_tarihi = now() where id = r.id;
            update public.kurum_tipi_rol set gecerli = 1, degistirme_tarihi = now()
             where rol_kod = r.kod and gecerli = 0;
            v_sayi := v_sayi + 1;
            raise notice '836: "%" rolu % kisi tasidigi icin yeniden GECERLI '
                         'yapildi.', r.ad, r.kisi;
        end if;
    end loop;
    if v_sayi = 0 then
        raise notice '836: kisisi olup pasif kalan rol yok.';
    end if;
end $$;
