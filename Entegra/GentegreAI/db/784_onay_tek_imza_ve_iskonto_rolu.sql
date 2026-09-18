-- ============================================================================
--  Gentegre AI — ZİNCİRDE TEK İMZA · "İSKONTO ONAYLAYANLAR" ROLÜ EMEKLİ
--  784_onay_tek_imza_ve_iskonto_rolu.sql
--
--  Kullanıcı: *"'İskonto Onaylayanlar' rolünü kaldır ve 1'i yaz"* (1 =
--  "aynı kişi ardışık basamakları imzalayamaz").
--
--  ============ 1) BİR ZİNCİRDE BİR KİŞİ BİR İMZA =====================
--  783 kendi TALEBİNİ onaylamayı kapattı. Açık kalan taraf şuydu: basamaklar
--  role düşüyor (754: birim · mali · üst) ve üç rolü birden taşıyan bir kişi
--  BAŞKASININ talebinde üç imzayı tek başına atabiliyordu. İki imza aynı
--  elden çıkınca ikinci imza denetim değil tekrardır; zincirin varlık sebebi
--  ortadan kalkar.
--
--  Kural OMURGANIN TAMAMINDA geçerli (satınalma · izin · avans · iskonto ·
--  doküman): "bu zincirde daha önce karar veren kişi ikinci bir basamağı
--  imzalayamaz". Modüle özel istisna yazılmadı - bir modülde gevşetilen kural,
--  ötekilerde de gevşemiş sayılır.
--
--  İMZA SAYILAN DURUMLAR: 1 onay · 2 ret · 4 sözlü onay. "Bilgi istendi" (3)
--  ve "atlandı" (5) imza değildir: ilki soru sorar, ikincisi kimse
--  imzalamadan geçer.
--
--  VEKÂLET (763) BU KURALI BOZMAZ ama ondan muaf da değildir: `karar_veren_id`
--  fiilen imzalayan kişidir; vekil bir zincirde iki kez imzalayamaz.
--
--  KÜÇÜK KURUMDA ZİNCİR BEKLEYEBİLİR: tek yetkilinin iki basamağı olduğu
--  kurulumda ikinci basamak bekler. Çözüm zinciri kısaltmaktır (eşik ayarı),
--  aynı imzayı iki kez saymak değil.
--
--  ============ 2) "İSKONTO ONAYLAYANLAR" ROLÜ ========================
--  663'te "adres kutusu" olarak açılmıştı: basamağı hak eden yetkiler
--  (`belge.iskonto_onay_birim/_mali/_ust`) + %100 tavan tek pakette. Basamak
--  sahipliği rol KAYDINA değil YETKİ KODUNA bağlı (754) - kurum aynı
--  yetkileri kendi rollerine (Başhekim, Mali İşler Müdürü) verdiğinde kutuya
--  gerek kalmıyor. Üstelik kutu üç basamağı birden taşıdığı için 754'ün
--  ayrımını kâğıt üstünde bırakıyordu.
--
--  ROL SİLİNMİYOR, BOŞALTILIYOR: `taraf_kullanici.rol_id` ona işaret ediyor
--  olabilir; silmek FK'yi kırar ya da kullanıcıyı rolsüz bırakır. Pasife de
--  ALINAMAZ - `iskonto_onay` bir SİSTEM rolü ve `fn_rol_sistem_koru` pasif
--  sistem rolünü bilerek reddediyor ("özelliği kullanmıyorsanız rolü boş
--  bırakın"). Bu göç tam olarak onu yapıyor: yetkileri kaldırır, adına
--  "kullanılmıyor" notunu düşer, rol boş bir kabuk olarak kalır.
--
--  Kurum yeniden kullanmak isterse Yetkiler ekranından doldurur; onay
--  basamakları zaten YETKİ koduna bakar, rol kaydına değil.
--
--  KULLANICISI VARSA DOKUNULMAZ: rolü o anda taşıyan biri varsa yetkileri
--  kaldırmak onu sessizce yetkisiz bırakırdı (gerçek vaka: dev veritabanında
--  SİSTEM YÖNETİCİSİ bu roldeydi). Böyle bir kurulumda göç yalnız UYARIR;
--  yönetici kişilere uygun rolü atadıktan sonra bu dosya yeniden
--  çalıştırılabilir (idempotent).
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------ 1) zincirde tek imza ----
create or replace function public.tg_onay_adim_tek_imza()
returns trigger
language plpgsql
as $$
declare
    v_var integer;
begin
    -- Yalnız İMZA anına bak: bekleyen/atlanan/bilgi istenen basamak kuralın
    --   dışında. Durum değişmiyorsa (gerekçe düzeltmesi gibi) de karışma.
    if new.durum not in (1, 2, 4) then return new; end if;
    if old.durum = new.durum then return new; end if;
    if new.karar_veren_id is null then return new; end if;

    select count(*) into v_var
      from public.onay_adim a
     where a.onay_id = new.onay_id
       and a.sira <> new.sira
       and a.durum in (1, 2, 4)
       and a.karar_veren_id = new.karar_veren_id;

    if v_var > 0 then
        raise exception 'Bu onay zincirinde daha önce imza attınız; ikinci '
                        'basamağı başka bir yetkili imzalamalı.'
              using errcode = 'GK422';
    end if;
    return new;
end $$;

comment on function public.tg_onay_adim_tek_imza() is
  '784: bir onay zincirinde bir kisi yalniz BIR basamagi imzalar - iki imza '
  'ayni elden cikinca ikincisi denetim degil tekrardir.';

drop trigger if exists tg_onay_adim_tek_imza on public.onay_adim;

create trigger tg_onay_adim_tek_imza
    before update of durum on public.onay_adim
    for each row execute function public.tg_onay_adim_tek_imza();

-- --------------------------------------- 2) iskonto onay rolu emekliye ----
do $$
declare
    v_rol   integer;
    v_kisi  integer;
begin
    select id into v_rol from public.rol where kod = 'iskonto_onay';
    if v_rol is null then
        raise notice '784: iskonto_onay rolu zaten yok.';
        return;
    end if;

    select count(*) into v_kisi from public.taraf_kullanici where rol_id = v_rol;
    if v_kisi > 0 then
        raise notice '784 UYARI: iskonto_onay rolunde % kullanici var - rol '
                     'DOKUNULMADAN birakildi. Once onlara uygun rolu atayin, '
                     'sonra bu dosyayi yeniden calistirin.', v_kisi;
        return;
    end if;

    delete from public.rol_yetki where rol_id = v_rol;
    -- AD bir NOT tasir: bos bir rolu ekranda goren yonetici neden bos
    --   oldugunu bilsin (sistem rolu oldugu icin listeden kaldiramiyoruz).
    update public.rol
       set ad = case when ad like '%kullanılmıyor%' then ad
                     else ad || ' (kullanılmıyor - 784)' end
     where id = v_rol;
    raise notice '784: iskonto_onay rolu bosaltildi (yetkileri kaldirildi). '
                 'Basamak yetkileri (belge.iskonto_onay_*) kurumun kendi '
                 'rollerine verilir; yonetici rolu zaten tasiyor.';
end $$;
