-- ============================================================================
--  Gentegre AI — İSKONTO BASAMAKLARI ROLLERE DAĞITILDI · STANDART ROLLER SİSTEM
--  785_iskonto_basamak_rolleri_ve_sistem_rolleri.sql
--
--  Kullanıcı: *"785'i kur ama yüzdeleri ben ayarlayabileyim.. bir de hbys için
--  standart rolleri sistem rolü olarak ekle.. silinemesin aktif/pasif
--  yapılabilsin"*.
--
--  ============ 1) BASAMAKLAR ARTIK ÜÇ AYRI ROLDE ======================
--  784'te "İskonto Onaylayanlar" boşaltılınca üç basamak yetkisi yalnız
--  `yonetici` rolünde kalmıştı: bankonun açtığı her talep yöneticiye düşüyor,
--  784'ün tek-imza kuralı yüzünden %10 üstü talep İKİ ayrı yönetici istiyordu.
--  754'ün üç kademesi (birim · mali · üst) ancak üç ayrı rolde anlam kazanır:
--
--     Birim Sorumlusu  -> kayit_kabul  (banko sorumlusu; talebi AÇAN kişi
--                         kendi talebini onaylayamaz - 783/784)
--     Mali İşler       -> muhasebe
--     Üst Yönetim      -> yonetici     (zaten taşıyordu)
--
--  ============ YÜZDELER EKRANDAN AYARLANIR ============================
--  Buradaki sayılar YALNIZCA BAŞLANGIÇ değeridir; üçü de ekrandan değişir:
--
--   · Rol tavanı (`basvuru.iskonto` değeri, 661) -> Yönetim › Yetkiler,
--     "Sınır" sütunu. Başlangıç: kayit_kabul %10 · muhasebe %25 · yonetici %100.
--   · Basamak eşiği (`onay_akis_adim.esik_alt`, 754) -> Onay Akışları ekranı,
--     "Eşik (≥)" alanı. Mali işler %10, üst yönetim %25 olarak duruyor.
--   · Onaysız uygulanabilen tavan (`basvuru.iskonto_onay_esik`, 783) ->
--     Genel Ayarlar. Varsayılan %10.
--
--  VAR OLAN DEĞER EZİLMEZ: göç yalnız EKSİK satırı yazar. Kurum tavanı
--  değiştirdiyse yeniden çalıştırmak onu geri almaz.
--
--  ============ 2) STANDART ROLLER SİSTEM ROLÜ =========================
--  712'nin "standart rolleri kur" şablonları (Kayıt Kabul, Hekim, Hemşire,
--  Muhasebe, Diş Hekimi, Radyolog, Lab, İSG…) `sistem = 0` yazıyordu: yönetici
--  bunları silebiliyordu ve silinen rolün kullanıcıları rolsüz kalıyordu.
--  Artık SİSTEM rolü: silinemez.
--
--  AMA PASİFE ALINABİLİR (kullanıcı): kurum diş hekimliği yapmıyorsa "Diş
--  Hekimi" rolünü listeden kaldırabilmeli. 663'te konulan "sistem rolü pasife
--  alınamaz" kuralı bu yüzden gevşetiliyor - koruma SİLMEYE ve KİMLİĞE
--  (kod / sistem bayrağı) kalıyor.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------- 1) basamak yetkileri + tavanlar ----
--  (rol kodu, yetki kodu, tavan) - tavan yalnız `basvuru.iskonto` icin.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select r.id, y.id, 1, 1, 1, 0, ''
  from (values ('kayit_kabul', 'belge.iskonto_onay_birim'),
               ('muhasebe',    'belge.iskonto_onay_mali'),
               ('yonetici',    'belge.iskonto_onay_ust')) as x(rol, yetki)
  join public.rol r   on r.kod = x.rol
  join public.yetki y on y.kod = x.yetki
 where not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- TAVAN: `basvuru.iskonto` satiri VARSA degeri bos ise doldurulur, doluysa
--   DOKUNULMAZ (kurum kendi ayarini korur); satir yoksa eklenir.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select r.id, y.id, 1, 0, 0, 0, x.tavan
  from (values ('kayit_kabul', '10'), ('muhasebe', '25')) as x(rol, tavan)
  join public.rol r   on r.kod = x.rol
  join public.yetki y on y.kod = 'basvuru.iskonto'
 where not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

update public.rol_yetki ry
   set deger = x.tavan
  from (values ('kayit_kabul', '10'), ('muhasebe', '25')) as x(rol, tavan)
  join public.rol r   on r.kod = x.rol
  join public.yetki y on y.kod = 'basvuru.iskonto'
 where ry.rol_id = r.id and ry.yetki_id = y.id
   and coalesce(nullif(ry.deger, ''), '0') = '0';

-- ONAY EKRANI: karar veren rol denetim izini de gormeli (685).
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
select r.id, y.id, 1, 0, 0, 0, ''
  from (values ('muhasebe')) as x(rol)
  join public.rol r   on r.kod = x.rol
  join public.yetki y on y.kod = 'iskonto_onay'
 where not exists (select 1 from public.rol_yetki ry
                    where ry.rol_id = r.id and ry.yetki_id = y.id);

-- --------------------------------- 2) sistem rolu korumasi gevsetiliyor ---
create or replace function public.fn_rol_sistem_koru()
returns trigger
language plpgsql
as $function$
begin
    if tg_op = 'DELETE' then
        if old.sistem = 1 then
            raise exception '"%" bir sistem rolüdür, silinemez. Kullanmıyorsanız PASİFE alın ya da içindeki kullanıcıları başka role taşıyın.',
                  old.ad using errcode = 'GK422';
        end if;
        return old;
    end if;

    -- UPDATE: sistem rolunun KIMLIGI sabit, geri kalani serbest.
    if old.sistem = 1 then
        if new.kod is distinct from old.kod then
            raise exception '"%" sistem rolünün kodu (%) değiştirilemez - program bu koda bakıyor. Adı serbestçe değiştirilebilir.',
                  old.ad, old.kod using errcode = 'GK422';
        end if;
        if new.sistem <> 1 then
            raise exception '"%" sistem rolüdür; sistem işareti kaldırılamaz.',
                  old.ad using errcode = 'GK422';
        end if;
        -- PASIFE ALMA SERBEST (785, kullanici: "silinemesin aktif/pasif
        --   yapilabilsin"): kurum dis hekimligi yapmiyorsa "Diş Hekimi"
        --   rolunu listeden kaldirabilmeli. 663'teki yasak, rolun sessizce
        --   calismamasini onlemek icindi; pasif rol ekranda PASIF gorunur -
        --   sessiz degildir.
    end if;
    return new;
end $function$;

comment on function public.fn_rol_sistem_koru() is
  '663/785: sistem rolu SILINEMEZ, kodu ve sistem isareti degismez; '
  'pasife alinabilir (kurumun kullanmadigi rol listeden dusebilsin).';

-- ------------------------------- 3) standart roller sistem olarak isaret --
-- 712'nin sablon kodlari. Liste burada TEKRARLANIYOR cunku sablonlar kodda
--   (StandartRolUclari) duruyor; yeni kurulumlarda rol zaten `sistem = 1`
--   acilir, bu blok VAR OLAN kurulumlari hizalar.
update public.rol
   set sistem = 1
 where sistem = 0
   and kod in ('kayit_kabul','hekim','hemsire','muhasebe','vezne',
               'rapor_goruntuleyici','kalite','medula_sorumlu','bilgi_islem',
               'dis_hekimi','dis_asistan','tedavi_danismani','dis_lab_sorumlu',
               'dis_istem_kurumu','goz_hekimi','optometrist','goz_teknisyen',
               'ftr_uzmani','fizyoterapist','radyolog','rad_teknisyen',
               'teleradyoloji_hekim','lab_uzmani','lab_teknisyen','numune_kabul',
               'yatan_hemsire','yatis_ofisi','eczane_depo','isyeri_hekimi',
               'isg_uzmani','osgb_sekreter','firma_yetkilisi','dsp');

-- 784'te BOSALTILAN rol artik PASIFE alinabilir (koruma gevsedi): bos ve
--   yetkisiz bir rol listede aktif gorunmesin.
update public.rol
   set aktif = 0
 where kod = 'iskonto_onay'
   and aktif = 1
   and not exists (select 1 from public.rol_yetki ry where ry.rol_id = rol.id)
   and not exists (select 1 from public.taraf_kullanici k where k.rol_id = rol.id);

do $$
declare v_sistem int; v_birim int;
begin
    select count(*) into v_sistem from public.rol where sistem = 1;
    select count(*) into v_birim
      from public.rol r join public.rol_yetki ry on ry.rol_id = r.id
      join public.yetki y on y.id = ry.yetki_id
     where y.kod like 'belge.iskonto_onay_%';
    raise notice '785 tamam: sistem rolu %, iskonto basamak yetkisi tasiyan '
                 'rol-yetki satiri %. Yuzdeler ekrandan degistirilebilir '
                 '(Yetkiler > Sinir · Onay Akislari > Esik · Genel Ayarlar).',
                 v_sistem, v_birim;
end $$;
