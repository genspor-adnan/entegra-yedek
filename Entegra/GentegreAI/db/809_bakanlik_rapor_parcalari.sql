-- ============================================================================
--  Gentegre AI — BAKANLIK PROFİLİ 1/4: RAPOR GÖVDESİ DÖRT PARÇA
--  809_bakanlik_rapor_parcalari.sql
--
--  Kullanıcı: *"sağlık bakanlığının teleradyoloji süreci var ona bak bi"* →
--  *"bunları yap"* (dokuman/14, bölüm 5.5 · madde 1).
--
--  ============ NEDEN ================================================
--  Bakanlık Teleradyoloji Sistemi raporu TEK METİN olarak kabul etmiyor
--  (Entegrasyon Kılavuzu 3.46, OBX-5): gövde `~` ile DÖRT parçaya bölünür -
--    ^1 Teknik · ^2 Karşılaştırma · ^3 Bulgular · ^4 Sonuç ve Öneriler
--  ve her parça base64'tür. **^3 ile ^4 eksikse mesaj reddediliyor; Bulgular
--  50 karakterden kısaysa da reddediliyor.**
--
--  Bizde rapor gövdesi `radyoloji_rapor_bolum` - başlığı SERBEST metin
--  ("Teknik", "Bulgular", "BULGULAR", "Tekniği ve Bulgular"...). Serbest
--  başlığa göre parça ayırmak, gönderim anında tahmin yürütmek demekti;
--  reddedilen mesajı da radyolog değil operasyon görür. Bu yüzden parça
--  numarası VERİ OLARAK saklanıyor ve eksiklik RAPOR ONAYINDA yakalanıyor.
--
--  ============ KAPALI VARSAYILAN ====================================
--  Kural HERKESE uygulanmaz: özel hastane / muayenehane müşterisi Bakanlık
--  sistemine bağlı değildir ve onun radyoloğunu 50 karakter kuralıyla
--  durdurmak yanlış olurdu. Kapı tek ayar: `radyoloji.bakanlik_profili`
--  (varsayılan '0' = kapalı). Açıkken onay kapısı kontrol eder.
--
--  Parça numarası ise ayardan BAĞIMSIZ doldurulur: veri her zaman doğru
--  etiketlenir, yalnız zorlama ayara bağlıdır.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------ kod listesi ----
insert into public.kod_liste (kod, ad)
select 'rad.bakanlik_parca', 'Bakanlık Rapor Parçası'
 where not exists (select 1 from public.kod_liste l where l.kod = 'rad.bakanlik_parca');

insert into public.kod_deger (liste_id, deger, ad, sira, aktif, ekleyen)
select l.id, v.deger, v.ad, v.deger * 10, 1, 0
  from public.kod_liste l
  join (values (1, 'Teknik'), (2, 'Karşılaştırma'),
               (3, 'Bulgular'), (4, 'Sonuç ve Öneriler')) as v(deger, ad)
    on true
 where l.kod = 'rad.bakanlik_parca'
   and not exists (select 1 from public.kod_deger d
                    where d.liste_id = l.id and d.deger = v.deger and d.dil = 0);

-- ----------------------------------------------------------------- ayar ----
insert into public.referans (anahtar, deger, tip, kapsam, aciklama)
values ('radyoloji.bakanlik_profili', '0', 'bool', 'firma',
        'Bakanlık Teleradyoloji profili: rapor gövdesi dört parça, Bulgular en az 50 karakter')
on conflict (anahtar) do nothing;

-- -------------------------------------------------------------- kolonlar ----
alter table public.radyoloji_sablon_bolum
    add column if not exists bakanlik_parca smallint not null default 0;
alter table public.radyoloji_rapor_bolum
    add column if not exists bakanlik_parca smallint not null default 0;

comment on column public.radyoloji_sablon_bolum.bakanlik_parca is
  '809: OBX-5 parça numarası (kod_liste rad.bakanlik_parca) - 0 gönderilmez.';
comment on column public.radyoloji_rapor_bolum.bakanlik_parca is
  '809: raporun bu bölümü hangi Bakanlık parçasına yazılacak - 0 gönderilmez.';

-- ---------------------------------------------------- başlıktan çıkarma ----
-- ŞABLON ELLE İŞARETLENMEDİYSE başlığa bakılır. Tahmin DEĞİL, kapalı bir
--   sözlük: yalnız tanınan başlıklar eşlenir, tanınmayan 0 kalır ve onay
--   kapısında "eksik" olarak görünür. Sessizce yanlış parçaya yazmaktansa
--   eksik demek yeğdir.
create or replace function public.fn_rad_bakanlik_parca(p_baslik text)
returns smallint
language sql immutable as $$
  select case
           when b like 'teknik%'                                then 1::smallint
           when b like 'karsilastirma%' or b like 'karşılaştırma%'
             or b like 'onceki tetkik%'                         then 2::smallint
           when b like 'bulgu%' or b like 'radyolojik bulgu%'    then 3::smallint
           when b like 'sonuc%' or b like 'sonuç%'
             or b like 'oneri%'  or b like 'öneri%'
             or b like 'kanaat%'                                then 4::smallint
           else 0::smallint
         end
    from (select btrim(lower(coalesce(p_baslik, ''))) as b) x;
$$;

comment on function public.fn_rad_bakanlik_parca(text) is
  '809: serbest bölüm başlığından OBX-5 parça numarası (tanınmayan başlık 0).';

-- ------------------------------------------------------ mevcut veri izi ----
-- Şablon bölümleri başlığa göre işaretlenir. ELLE GİRİLMİŞ bir değer varsa
--   (bu göç ilk kez çalışıyorsa yoktur) dokunulmaz.
update public.radyoloji_sablon_bolum sb
   set bakanlik_parca = public.fn_rad_bakanlik_parca(sb.baslik)
 where sb.bakanlik_parca = 0
   and public.fn_rad_bakanlik_parca(sb.baslik) > 0;

update public.radyoloji_rapor_bolum rb
   set bakanlik_parca = public.fn_rad_bakanlik_parca(rb.baslik)
 where rb.bakanlik_parca = 0
   and public.fn_rad_bakanlik_parca(rb.baslik) > 0;

-- --------------------------------------------------- rapora yazarken ------
-- Rapor bölümü kaydedilirken parça numarası ŞABLONDAN gelir; şablonda yoksa
--   başlıktan çıkarılır. Tek yazıcı: uç, web ya da test - hangisi yazarsa
--   yazsın aynı kural işler.
create or replace function public.tg_rad_rapor_bolum_parca()
returns trigger
language plpgsql
as $$
declare v_parca smallint;
begin
    if coalesce(new.bakanlik_parca, 0) > 0 then
        return new;                              -- elle verilmiş: dokunma
    end if;

    select sb.bakanlik_parca into v_parca
      from public.radyoloji_rapor rp
      join public.radyoloji_sablon_bolum sb
        on sb.sablon_id = rp.sablon_id and sb.baslik = new.baslik
     where rp.id = new.rapor_id
     limit 1;

    new.bakanlik_parca := coalesce(nullif(coalesce(v_parca, 0), 0),
                                   public.fn_rad_bakanlik_parca(new.baslik));
    return new;
end $$;

drop trigger if exists tg_rad_rapor_bolum_parca on public.radyoloji_rapor_bolum;
create trigger tg_rad_rapor_bolum_parca
    before insert or update of baslik on public.radyoloji_rapor_bolum
    for each row execute function public.tg_rad_rapor_bolum_parca();

-- ------------------------------------------------------- eksik parçalar ----
-- TEK OKUYUCU: onay kapısı da, ileride ORU üreticisi de buradan sorar.
create or replace function public.fn_rad_bakanlik_eksik(p_rapor_id integer)
returns text
language plpgsql stable as $$
declare
    v_bulgular integer;
    v_sonuc    integer;
    v_uzunluk  integer;
begin
    select count(*) filter (where b.bakanlik_parca = 3
                              and btrim(coalesce(b.metin, '')) <> ''),
           count(*) filter (where b.bakanlik_parca = 4
                              and btrim(coalesce(b.metin, '')) <> ''),
           coalesce(sum(length(btrim(coalesce(b.metin, ''))))
                      filter (where b.bakanlik_parca = 3), 0)
      into v_bulgular, v_sonuc, v_uzunluk
      from public.radyoloji_rapor_bolum b
     where b.rapor_id = p_rapor_id;

    if v_bulgular = 0 then
        return 'Bakanlık profili: "Bulgular" bölümü boş - rapor gönderilemez.';
    end if;
    -- 50 KARAKTER KILAVUZUN KURALI, bizim keyfimiz değil: kısa Bulgular
    --   mesajı reddettiriyor (3.46, OBX-5).
    if v_uzunluk < 50 then
        return format('Bakanlık profili: "Bulgular" en az 50 karakter olmalı (şu an %s).',
                      v_uzunluk);
    end if;
    if v_sonuc = 0 then
        return 'Bakanlık profili: "Sonuç ve Öneriler" bölümü boş - rapor gönderilemez.';
    end if;
    return '';
end $$;

comment on function public.fn_rad_bakanlik_eksik(integer) is
  '809: Bakanlık OBX-5 kuralı - Bulgular (>= 50 karakter) ve Sonuç/Öneriler '
  'dolu mu. Boş dönerse gönderilebilir.';

-- ------------------------------------------------------------ onay kapısı ----
-- 284'teki işlev KORUNUYOR, üzerine tek dal ekleniyor.
create or replace function public.fn_radyoloji_rapor_onaylanabilir(p_rapor_id integer)
returns text
language plpgsql stable as $$
declare
  r       record;
  v_adet  integer;
  v_eksik text;
begin
  select rp.id, rp.durum, rp.kilit, rp.istem_id, i.kritik
    into r
    from public.radyoloji_rapor rp
    join public.radyoloji_istem i on i.id = rp.istem_id
   where rp.id = p_rapor_id;
  if not found then return 'Rapor bulunamadı.'; end if;

  if r.kilit = 1 then
    return 'Rapor onaylanmış ve kilitli; düzeltme ek rapor (addendum) olarak yazılır.';
  end if;

  -- Şablonda ZORUNLU işaretli bölüm boş kalamaz.
  select count(*) into v_adet
    from public.radyoloji_rapor_bolum b
    join public.radyoloji_rapor rp on rp.id = b.rapor_id
    left join public.radyoloji_sablon_bolum sb
           on sb.sablon_id = rp.sablon_id and sb.baslik = b.baslik
   where b.rapor_id = p_rapor_id
     and coalesce(sb.zorunlu, 0) = 1
     and btrim(coalesce(b.metin, '')) = '';
  if v_adet > 0 then
    return 'Zorunlu bölümler boş: rapor onaya gönderilemez.';
  end if;

  -- KRİTİK BULGU: işaretliyse bildirim kaydı ŞART.
  if coalesce(r.kritik, 0) = 1 then
    select count(*) into v_adet
      from public.radyoloji_kritik_bulgu k
     where k.istem_id = r.istem_id;
    if v_adet = 0 then
      return 'Kritik bulgu bildirimi kaydedilmeden rapor onaylanamaz.';
    end if;
  end if;

  -- BAKANLIK PROFİLİ (809): yalnız ayar açıkken. Kapıyı onaya koymanın
  --   nedeni: reddedilen HL7 mesajını radyolog görmez, saatler sonra
  --   operasyon görür ve rapor kilitlenmiş olur.
  if coalesce((select r2.deger from public.referans r2
                where r2.anahtar = 'radyoloji.bakanlik_profili'), '0') = '1' then
    v_eksik := public.fn_rad_bakanlik_eksik(p_rapor_id);
    if v_eksik <> '' then return v_eksik; end if;
  end if;

  return '';                                   -- boş = onaylanabilir
end $$;

comment on function public.fn_radyoloji_rapor_onaylanabilir(integer) is
  'Rapor onay ön koşulları (284/809): kilit, zorunlu bölümler, kritik bulgu '
  'bildirimi ve - ayar açıksa - Bakanlık dört parça kuralı.';

do $$
declare v_sablon integer; v_rapor integer;
begin
    select count(*) into v_sablon from public.radyoloji_sablon_bolum
     where bakanlik_parca > 0;
    select count(*) into v_rapor  from public.radyoloji_rapor_bolum
     where bakanlik_parca > 0;
    raise notice '809 tamam: % sablon bolumu, % rapor bolumu parca ile '
                 'isaretlendi. Ayar radyoloji.bakanlik_profili varsayilan KAPALI.',
                 v_sablon, v_rapor;
end $$;
