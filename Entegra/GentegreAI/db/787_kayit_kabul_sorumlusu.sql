-- ============================================================================
--  Gentegre AI — KAYIT KABUL SORUMLUSU (BANKO ŞEFİ) · BİRİM İMZASI ONA GEÇTİ
--  787_kayit_kabul_sorumlusu.sql
--
--  Kullanıcı: *"kayıt kabul (banko) sorumlusu bulamadım, iskonto talebi ilk
--  olarak ona gitmeyecek miydi"*.
--
--  ============ EKSİK OLAN ROLDÜ =======================================
--  785 iskonto zincirinin üç basamağını üç role dağıtırken BİRİM basamağını
--  `kayit_kabul` rolüne verdi ve tarihçeye "banko sorumlusu" diye yazdı - ama
--  öyle bir rol yoktu. Sonuç: bankodaki HER çalışan birim onaycısı oldu.
--  783 kendi talebini onaylamayı kapatıyor, yani kişi kendi talebini
--  imzalayamıyor; ama yanındaki mesai arkadaşı imzalayabiliyordu. Bu denetim
--  değil KARŞILIKLI İMZAdır: iki banko çalışanı birbirinin indirimini sırayla
--  onaylar ve zincir kâğıt üstünde kalır.
--
--  Basamak bir KADRO UNVANINA ait: banko şefi / kayıt kabul sorumlusu.
--  Ekranları bankonun aynısıdır, farkı imza yetkisidir.
--
--  ============ BU GÖÇ NE YAPAR =======================================
--   1) `kayit_kabul_sorumlu` rolünü açar (yoksa): bankonun yetkileri +
--      `belge.iskonto_onay_birim` + `iskonto_onay` ekranı (karar veren denetim
--      izini de görmeli, 685) + vardiya/kasa kapatma.
--   2) `belge.iskonto_onay_birim` yetkisini `kayit_kabul` rolünden KALDIRIR.
--   3) Rolü tüm aktif şubelere bağlar.
--
--  ZİNCİR BOŞTA KALMAZ: `yonetici` rolü üç basamağı da taşıyor (754/785).
--  Sorumlu rolüne kimse atanmamışken talep doğrudan yöneticiye düşer; kurum
--  banko şefini atayınca ilk imza ona gelir. Rol kaydı yetkiyi taşır, kişi
--  atamasını yönetici Yönetim › Roller'den yapar - göç kimseyi role atamaz.
--
--  ROL TAVANI DEĞİŞMEZ: `basvuru.iskonto` değeri (kayit_kabul %10) bankonun
--  ONAYSIZ uygulayabildiği orandır; sorumluya da aynı tavan gelir. Tavanı
--  yükseltmek kurumun kararı (Yönetim › Yetkiler › Sınır).
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare
    v_kaynak integer;   -- kayit_kabul
    v_yeni   integer;   -- kayit_kabul_sorumlu
    v_yetki  integer;
    v_sayi   integer;
begin
    select id into v_kaynak from public.rol where kod = 'kayit_kabul';
    if v_kaynak is null then
        raise notice '787: kayit_kabul rolu yok - standart roller kurulmamis, '
                     'atlaniyor. Kurum Profili > Standart rolleri kur.';
        return;
    end if;

    -- 1) ROL
    select id into v_yeni from public.rol where kod = 'kayit_kabul_sorumlu';
    if v_yeni is null then
        insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen)
        values ('kayit_kabul_sorumlu', 'Kayıt Kabul Sorumlusu (Banko Şefi)',
                'Bankonun tüm işleri + iskonto talebinin birim imzası, vardiya/kasa kapatma.',
                1, 1, 0)
        returning id into v_yeni;

        -- Bankonun yetkilerinin AYNISI: sorumlu ayni ekranlarda calisir.
        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
        select v_yeni, ry.yetki_id, ry.gor, ry.ekle, ry.degistir, ry.sil, ry.deger
          from public.rol_yetki ry where ry.rol_id = v_kaynak;

        -- Uzerine: birim imzasi + onay ekrani + vardiya kapatma.
        insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, deger)
        select v_yeni, y.id, 1,
               case when y.kod in ('kasa_kapatma', 'iskonto_onay') then 1 else 0 end,
               case when y.kod in ('kasa_kapatma', 'iskonto_onay') then 1 else 0 end,
               0, ''
          from public.yetki y
         where y.kod in ('belge.iskonto_onay_birim', 'iskonto_onay', 'kasa_kapatma',
                         'kasa.kapat', 'kasa.kesinlestir')
           and not exists (select 1 from public.rol_yetki ry
                            where ry.rol_id = v_yeni and ry.yetki_id = y.id);

        -- Tum aktif subeler (sablon kurulumunun yaptigi gibi).
        insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen)
        select v_yeni, s.id, s.varsayilan, 1, 0
          from public.sube s where s.aktif = 1
        on conflict do nothing;

        raise notice '787: "Kayıt Kabul Sorumlusu (Banko Şefi)" rolu kuruldu (id %).', v_yeni;
    else
        raise notice '787: kayit_kabul_sorumlu rolu zaten var (id %) - dokunulmadi.', v_yeni;
    end if;

    -- 2) BIRIM IMZASI BANKODAN KALKAR
    select id into v_yetki from public.yetki where kod = 'belge.iskonto_onay_birim';
    delete from public.rol_yetki where rol_id = v_kaynak and yetki_id = v_yetki;
    get diagnostics v_sayi = row_count;
    if v_sayi > 0 then
        raise notice '787: birim imzasi "Kayıt Kabul / Banko" rolunden kaldirildi - '
                     'artik banko calisani mesai arkadasinin iskontosunu onaylayamaz.';
    end if;

    select count(*) into v_sayi from public.taraf_kullanici where rol_id = v_yeni and aktif = 1;
    raise notice '787: sorumlu rolunde % kullanici var. Kimse yoksa talep '
                 'dogrudan yoneticiye duser (yonetici uc basamagi da tasir); '
                 'banko sefini Yonetim > Roller''den atayin.', v_sayi;
end $$;
