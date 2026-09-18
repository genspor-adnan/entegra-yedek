-- ============================================================================
--  Gentegre AI — ELLE EKLENEN ROLLER KALDIRILDI (doktor · bnk1)
--  790_elle_eklenen_roller_temizligi.sql
--
--  Kullanıcı: *"benim eklediğim rolleri kaldır"* + (soru üzerine) *"Hekim
--  rolüne taşı"*.
--
--  ============ NE SİLİNİYOR ===========================================
--  Standart roller gelmeden önce elle açılmış iki rol:
--    · `doktor` (Doktor)  — 1 yetkisi var, içinde 50 kullanıcı
--    · `bnk1`   (Banko)   — 7 yetkisi var, içinde kimse yok
--
--  İkisi de `sistem = 0`: şablondan gelmediler, kimse onlara bakmıyor.
--  Karşılıkları standart rollerde var (`hekim`, `kayit_kabul`).
--
--  ============ ÖNCE KİŞİLER, SONRA ROL ================================
--  Rol silmek kullanıcıyı rolsüz bırakır. Bu yüzden sıra:
--   1. `doktor` rolündeki herkes `hekim` rolüne geçer (kullanıcının kararı).
--   2. `hekim` rolü AKTİF edilir ve profil haritasında geçerli işaretlenir -
--      yoksa 50 kişi PASİF bir role taşınmış olur ve ilk profil kaydında
--      (786) yeniden kapatılır.
--   3. Boşalan iki rol silinir; `kurum_tipi_rol` satırları da (FK yok, yetim
--      kalırlardı).
--
--  KOŞULLU VE İDEMPOTENT: roller yoksa ya da `sistem = 1` ise dokunulmaz;
--  başka bir kurulumda bu dosya sessizce hiçbir şey yapmaz.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_hekim  integer;
    v_rol    integer;
    v_tasidi integer;
    v_kod    text;
begin
    select id into v_hekim from public.rol where kod = 'hekim';

    -- ---------------------------------------------------- 1) doktor -> hekim
    select id into v_rol from public.rol where kod = 'doktor' and sistem = 0;
    if v_rol is not null then
        if v_hekim is null then
            raise exception 'Hedef rol "hekim" yok - once standart rolleri kurun.'
                  using errcode = 'GK422';
        end if;

        update public.taraf_kullanici set rol_id = v_hekim,
               degistirme_tarihi = now()::timestamp
         where rol_id = v_rol;
        get diagnostics v_tasidi = row_count;

        -- Ek rol satirlari da (kullanici_rol): ayni kisi iki kez hekim olmasin.
        delete from public.kullanici_rol kr
         where kr.rol_id = v_rol
           and exists (select 1 from public.taraf_kullanici k
                        where k.id = kr.kullanici_id and k.rol_id = v_hekim);
        update public.kullanici_rol set rol_id = v_hekim where rol_id = v_rol;

        -- 2) HEKIM ROLU ACIK OLMALI: pasif role tasimak kimseyi kurtarmaz.
        update public.rol set aktif = 1 where id = v_hekim and aktif = 0;
        -- Profil haritasinda da gecerli (786): sonraki profil kaydi kapatmasin.
        update public.kurum_tipi_rol set gecerli = 1, degistirme_tarihi = now()
         where rol_kod = 'hekim' and gecerli = 0;

        delete from public.kurum_tipi_rol where rol_kod = 'doktor';
        delete from public.rol where id = v_rol;
        raise notice '790: elle eklenen "Doktor" rolu silindi; % kullanici '
                     'standart hekim roluna tasindi (rol aktif edildi).', v_tasidi;
    else
        raise notice '790: elle eklenmis "doktor" rolu yok - atlandi.';
    end if;

    -- ------------------------------------------------------------ bnk1 -----
    select id into v_rol from public.rol where kod = 'bnk1' and sistem = 0;
    if v_rol is not null then
        select count(*) into v_tasidi from public.taraf_kullanici where rol_id = v_rol;
        if v_tasidi > 0 then
            -- Kullanicisi olan rolu silmek onlari rolsuz birakirdi; bu dosya
            --   yalniz BOS rolu siler, dolusunu bildirir.
            raise notice '790 UYARI: "bnk1" rolunde % kullanici var - SILINMEDI. '
                         'Once Yonetim > Roller''den baska role tasiyin.', v_tasidi;
        else
            delete from public.kurum_tipi_rol where rol_kod = 'bnk1';
            delete from public.rol where id = v_rol;
            raise notice '790: bos "Banko" (bnk1) rolu silindi.';
        end if;
    else
        raise notice '790: elle eklenmis "bnk1" rolu yok - atlandi.';
    end if;

    for v_kod in select kod from public.rol where sistem = 0 order by kod loop
        raise notice '790: geriye kalan sistem-disi rol: %', v_kod;
    end loop;
end $$;

-- ============================================================================
--  "İSKONTO ONAYLAYANLAR" ARTIK GERÇEKTEN SİLİNİYOR
--
--  Kullanıcı: *"İskonto Onaylayanlar'ı kaldır demiştim hala görünüyor"*.
--
--  784 rolü SİLEMEDİ, boşalttı: `iskonto_onay` bir SİSTEM rolüydü ve o gün
--  `fn_rol_sistem_koru` pasife almayı bile reddediyordu; göç yetkileri
--  kaldırıp adına "(kullanılmıyor - 784)" notu düşmekle yetindi. 785 korumayı
--  gevşetip rolü pasife aldı - ama kayıt listede durmaya devam etti ve ilk
--  profil kaydında yeniden aktif işaretlendi.
--
--  Rol artık BOŞ: 0 yetki, 0 kullanıcı. Basamak sahipliği rol kaydına değil
--  YETKİ KODUNA bakıyor (754) ve üç basamak 787/788'de kadro rollerine geçti -
--  bu kaydın taşıdığı hiçbir şey kalmadı.
--
--  TETİK NEDEN KAPATILIYOR: `fn_rol_sistem_koru` sistem rolünün silinmesini
--  reddeder ve bu DOĞRU kuraldır - korumayı gevşetip "boş sistem rolü
--  silinebilir" demek, bir rolü önce boşaltıp sonra silmenin yolunu açardı.
--  Bu tek kayıt için tetik açıkça devre dışı bırakılıp hemen geri alınıyor:
--  istisna görünür ve tek satırlık.
-- ============================================================================
do $$
declare
    v_rol  integer;
    v_y    integer;
    v_k    integer;
begin
    select id into v_rol from public.rol where kod = 'iskonto_onay';
    if v_rol is null then
        raise notice '790: iskonto_onay rolu zaten yok.';
        return;
    end if;

    select count(*) into v_y from public.rol_yetki where rol_id = v_rol;
    select count(*) into v_k from public.taraf_kullanici where rol_id = v_rol;
    if v_y > 0 or v_k > 0 then
        raise notice '790 UYARI: iskonto_onay rolu BOS DEGIL (% yetki, % kullanici) - '
                     'silinmedi. Once bosaltin (784 gocu yeniden calisir).', v_y, v_k;
        return;
    end if;

    -- Bagli satirlar (FK'lar cascade degil).
    delete from public.rol_sube       where rol_id = v_rol;
    delete from public.rol_alan_yetki where rol_id = v_rol;
    delete from public.kullanici_rol  where rol_id = v_rol;
    delete from public.kurum_tipi_rol where rol_kod = 'iskonto_onay';
    update public.rol set ust_rol_id = null where ust_rol_id = v_rol;

    alter table public.rol disable trigger tg_rol_sistem_koru_sil;
    delete from public.rol where id = v_rol;
    alter table public.rol enable trigger tg_rol_sistem_koru_sil;

    raise notice '790: "İskonto Onaylayanlar" (iskonto_onay) rolu SILINDI. '
                 'Basamaklar kadro rollerinde (787/788), rol kaydinin tasidigi '
                 'bir sey kalmamisti.';
end $$;

-- ============================================================================
--  ROLÜN ADI "DOKTOR" (kullanıcı: *"Hekim rename Doktor"*)
--
--  KOD DEĞİŞMEZ (`hekim`): program basamakları, şablonları ve menü süzgeçlerini
--  koda göre çözüyor; sistem rolünün kodunu değiştirmeyi `fn_rol_sistem_koru`
--  zaten reddeder. Değişen yalnız ekranda yazan ADdır - kurumun kendi dili.
--  Elle açılmış "Doktor" rolü yukarıda silindiği için ad çakışması kalmadı.
-- ============================================================================
update public.rol set ad = 'Doktor', degistirme_tarihi = now()
 where kod = 'hekim' and ad <> 'Doktor';

do $$
declare v_ad text; v_kisi int;
begin
    select ad into v_ad from public.rol where kod = 'hekim';
    select count(*) into v_kisi from public.taraf_kullanici k
      join public.rol r on r.id = k.rol_id where r.kod = 'hekim' and k.aktif = 1;
    raise notice '790: hekim rolunun adi artik "%" (% aktif kullanici).', v_ad, v_kisi;
end $$;
