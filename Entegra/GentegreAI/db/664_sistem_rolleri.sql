-- ============================================================================
--  Gentegre AI — SİSTEM ROLLERİ (korumalı roller + amaç metni)
--  664_sistem_rolleri.sql
--
--  Kullanıcı: "iskonto onaylayanlar sistem rolü olmalı silinememeli..
--  düzenlenebilir ama bir yerde onun onay rolü olduğu belli olmalı. böylece
--  iskonto onaylayacaklar için bu role bakılıp zile uyarı gitmeli. buna
--  benzer başka sistem rolleri de olabilir"
--
--  ÜÇ PARÇA:
--   1) `rol.sistem = 1`  — ROLÜN KENDİSİ silinemez, kodu değişemez, pasife
--      alınamaz. Programın DAVRANIŞI bu role bağlı olduğu için rol bir veri
--      satırı değil, sözleşmedir: silinirse iskonto onayı sessizce sahipsiz
--      kalırdı ("kimseye zil gitmiyor" diye aranan hata).
--   2) `rol.amac`        — rolün NEDEN sistem rolü olduğunu söyleyen tek
--      cümle. Liste ve kartta okunur; kullanıcı "bu rol ne işe yarıyor"
--      sorusunu ekranda cevaplasın diye. Kod değil METİN saklanır: yeni bir
--      sistem rolü eklemek için uygulama derlemesi gerekmesin.
--   3) Koruma TETİĞİ     — kuralı kart ekranına değil VERİTABANINA koyar.
--      Kartten, listeden, API'den ya da bir betikten silen herkes aynı
--      cevabı alır (543'teki fiyat listesi korumasıyla aynı gerekçe).
--
--  NE SERBEST KALIR: ad, üst rol, departman, görev, ROLÜN YETKİLERİ ve
--  ROLDEKİ KULLANICILAR. Kurum "İskonto Onaylayanlar" adını "Onay Kurulu"
--  yapabilir, tavanı %100'den %25'e düşürebilir, içine kişi alır/çıkarır —
--  sistem rolü olmak rolü dondurmak değil, ORTADAN KALDIRMAYI engellemektir.
--
--  ZİL: ayrı bir "onaylayanlar tablosu" YOK. Talep, `basvuru.iskonto`
--  yetkisi + tavanı olan kullanıcıların ziline düşer (661/662); bu rol o
--  yetkiyi taşıyan hazır kutudur (663). İki kaynaktan beslenen bir yetki,
--  birinde açık öbüründe kapalı kaldığı gün sessizce yanlış davranır —
--  o yüzden rol "adres", yetki "kural" olmaya devam eder. `amac` metni de
--  kullanıcıya tam olarak bunu söyler.
-- ============================================================================
\set ON_ERROR_STOP on

-- ---------------------------------------------------------------------------
--  1) AMAÇ KOLONU
-- ---------------------------------------------------------------------------
alter table public.rol add column if not exists amac varchar(200) not null default '';

comment on column public.rol.amac is
  'Sistem rolunun ne ise yaradigini anlatan tek cumle (664). Bos = siradan rol. '
  'Kullanici duzenlemez - liste/kartta salt okunur gosterilir.';
comment on column public.rol.sistem is
  '1 = SISTEM ROLU: programin davranisi bu role bagli. Silinemez, kodu degismez, '
  'pasife alinmaz (664). Adi, yetkileri ve icindeki kullanicilar SERBESTTIR.';

-- ---------------------------------------------------------------------------
--  2) MEVCUT SİSTEM ROLLERİNE AMAÇ + İSKONTO ROLÜNÜ SİSTEM ROLÜ YAP
--
--     Amaç metinleri KORUNUR: kurum kendi cümlesini yazdıysa (amac <> '')
--     üzerine yazmayız — betik müşteri veritabanında da çalışacak.
-- ---------------------------------------------------------------------------
update public.rol
   set sistem = 1,
       amac   = case when amac = '' then
                  'İskonto onay talepleri bu roldeki kullanıcıların ziline düşer '
                  '(yetki: basvuru.iskonto, tavanı Yetkiler ekranından ayarlanır).'
                else amac end,
       degistiren = 0, degistirme_tarihi = now()::timestamp
 where kod = 'iskonto_onay'
   and (sistem <> 1 or amac = '');

update public.rol
   set amac = 'Tüm yetkiler açık. Kurulum ve yetki dağıtımı bu rolle yapılır.'
 where kod = 'yonetici' and amac = '';

update public.rol
   set amac = 'Yalnız görme yetkisi. Denetim / eğitim kullanıcıları için hazır kutu.'
 where kod = 'salt_okur' and amac = '';

-- "Rol Atanmamış" (233) DA SİSTEM ROLÜDÜR: bir kullanıcı rolünden çıkarıldığında
--   (RolYetkiUclari · kullanıcı sil) buraya taşınır ve yeni personel kartı bu
--   rolle açılır (KullaniciDeposu). Silinirse kullanıcı rolden çıkarma ve
--   personel açma NOT NULL / FK hatasıyla durur - kaydın kendisi değil, ona
--   bağlı iki akış kırılır. Adı serbest, kodu değil.
update public.rol
   set sistem = 1,
       amac   = case when amac = '' then
                  'Rolü henüz belirlenmemiş kullanıcıların durağı. Yeni personel bu rolle '
                  'açılır, rolden çıkarılan kullanıcı buraya döner. Yetki verilmemelidir.'
                else amac end
 where kod = 'atanmamis'
   and (sistem <> 1 or amac = '');

-- ---------------------------------------------------------------------------
--  3) KORUMA TETİĞİ
--
--     GK422 = is kurali ihlali; API bunu 422 + mesaj olarak dondurur
--     (VeriHatasi.Cevir). 500 + "beklenmeyen hata" degil.
-- ---------------------------------------------------------------------------
create or replace function public.fn_rol_sistem_koru()
returns trigger language plpgsql as $$
begin
    if tg_op = 'DELETE' then
        if old.sistem = 1 then
            raise exception '"%" bir sistem rolüdür, silinemez. Kullanmıyorsanız içindeki kullanıcıları başka role alın.',
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
        -- Pasif sistem rolu = sessizce calismayan ozellik: rol duruyor, kimse
        --   uyari almiyor ve neden alinmadigi hicbir ekranda yazmiyor.
        if new.aktif = 0 then
            raise exception '"%" sistem rolü pasife alınamaz. Özelliği kullanmıyorsanız rolü boş bırakın (içinde kullanıcı olmasın).',
                  old.ad using errcode = 'GK422';
        end if;
    end if;
    return new;
end $$;

comment on function public.fn_rol_sistem_koru() is
  'Sistem rollerini (rol.sistem = 1) silinmeye / kod degistirmeye / pasiflesmeye karsi korur (664).';

drop trigger if exists tg_rol_sistem_koru_sil on public.rol;
create trigger tg_rol_sistem_koru_sil
    before delete on public.rol
    for each row execute function public.fn_rol_sistem_koru();

drop trigger if exists tg_rol_sistem_koru_guncelle on public.rol;
create trigger tg_rol_sistem_koru_guncelle
    before update on public.rol
    for each row execute function public.fn_rol_sistem_koru();

-- ---------------------------------------------------------------------------
--  DOĞRULAMA
-- ---------------------------------------------------------------------------
do $$
declare v_sistem integer; v_amacsiz integer;
begin
    select count(*) into v_sistem   from public.rol where sistem = 1;
    select count(*) into v_amacsiz  from public.rol where sistem = 1 and amac = '';
    raise notice '664 tamam: % sistem rolu (% tanesi amac metni olmadan)', v_sistem, v_amacsiz;
    if not exists (select 1 from public.rol where kod = 'iskonto_onay' and sistem = 1) then
        raise warning '664: iskonto_onay rolu bulunamadi - once 663 uygulanmali.';
    end if;
end $$;
