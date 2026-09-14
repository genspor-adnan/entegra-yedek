-- =====================================================================
--  644_lab_referans_cinsiyetsiz.sql
--  (1) CİNSİYETİ BİLİNMEYEN hastada referans BULUNAMIYORDU.
--  (2) Aralık metni "4. - 10." gibi sondaki noktayla çıkıyordu.
--
--  (1) HGB, HCT, RBC, KRE, ALT, AST gibi tetkiklerin erişkin bandı
--  CİNSİYETE ÖZELDİR (E/K). `fn_lab_referans` "cinsiyet = 0 ya da hastanın
--  cinsiyeti" diye arıyor; hastanın cinsiyeti kayıtlı değilse (0) hiçbir
--  satır tutmuyor ve tetkik REFERANSSIZ kalıyordu - yani sonuç hep normal
--  bayrağı alırdı. Dış kurum numunesinde ve acil kayıtta cinsiyet çoğu
--  zaman boştur; bu hasta grubunu bayraksız bırakmak kabul edilemez.
--
--  ÇÖZÜM - EN GENİŞ BANT: cinsiyet eşleşmezse o yaş bandındaki kadın ve
--  erkek aralıklarının BİRLEŞİMİ döner (alt = min, üst = max). Bilinmeyen
--  cinsiyette dar bandı seçmek sağlıklı hastayı bayraklardı; geniş bant
--  yalnız gerçekten sınır dışı değeri işaretler. Panik sınırı da aynı
--  mantıkla en geniş alınır - panik eşiğini daraltmak yanlış acil çağrı
--  üretirdi.
--
--  (2) `to_char(..., 'FM999999990.999')` tam sayıda ondalık noktayı
--  bırakıyor ("4."). Metin kullanıcıya gösteriliyor; sondaki nokta
--  temizlenir.
-- =====================================================================

create or replace function public.fn_lab_referans(
        p_tetkik_id integer, p_hasta_id integer, p_tarih date default null)
returns public.lab_tetkik_referans
language plpgsql
stable
as $$
declare
    v_sonuc public.lab_tetkik_referans;
    v_cinsiyet smallint := 0;
    v_yas_gun  integer  := 6570;   -- dogum tarihi yoksa eriskin
    v_tarih    date     := coalesce(p_tarih, current_date);
begin
    select coalesce(h.cinsiyet, 0),
           coalesce((v_tarih - h.dogum_tarihi::date), 6570)
      into v_cinsiyet, v_yas_gun
      from public.taraf_hasta h
     where h.id = p_hasta_id;

    -- 1) TAM EŞLEŞME: en dar aralık, cinsiyete özel olan önce.
    select r.* into v_sonuc
      from public.lab_tetkik_referans r
     where r.tetkik_id = p_tetkik_id
       and (r.cinsiyet = 0 or r.cinsiyet = v_cinsiyet)
       and (r.gecerli_bas is null or r.gecerli_bas <= v_tarih)
       and v_yas_gun between r.yas_alt_gun and r.yas_ust_gun
     order by (r.yas_ust_gun - r.yas_alt_gun) asc,
              r.cinsiyet desc, r.sira asc, r.id asc
     limit 1;

    if v_sonuc.id is not null then
        return v_sonuc;
    end if;

    -- 2) CİNSİYET BİLİNMİYOR: yaş bandındaki cinsiyete özel aralıkların
    --    BİRLEŞİMİ. Tek satır gibi döner; `id` yoktur (sentetik).
    select min(r.yas_alt_gun), max(r.yas_ust_gun),
           min(r.alt), max(r.ust),
           min(r.panik_alt), max(r.panik_ust),
           max(r.metin)
      into v_sonuc.yas_alt_gun, v_sonuc.yas_ust_gun,
           v_sonuc.alt, v_sonuc.ust,
           v_sonuc.panik_alt, v_sonuc.panik_ust,
           v_sonuc.metin
      from public.lab_tetkik_referans r
     where r.tetkik_id = p_tetkik_id
       and (r.gecerli_bas is null or r.gecerli_bas <= v_tarih)
       and v_yas_gun between r.yas_alt_gun and r.yas_ust_gun;

    if v_sonuc.alt is null and v_sonuc.ust is null
       and coalesce(v_sonuc.metin, '') = '' then
        return null;                         -- tetkigin referansi yok
    end if;

    v_sonuc.tetkik_id := p_tetkik_id;
    v_sonuc.cinsiyet  := 0;
    v_sonuc.metin     := coalesce(v_sonuc.metin, '');
    v_sonuc.kaynak    := 'Cinsiyet bilinmiyor - E/K aralıklarının birleşimi';
    return v_sonuc;
end $$;

-- --------------------------------------------------------------- metin
create or replace function public.fn_lab_sayi_metni(p_sayi numeric)
returns text
language sql
immutable
as $$
    -- FM sondaki sifirlari atar ama ondalik NOKTAYI birakir ("4."):
    --   metin kullaniciya gosteriliyor, nokta temizlenir.
    select rtrim(rtrim(trim(to_char(p_sayi, 'FM999999990.999')), '0'), '.');
$$;

create or replace function public.fn_lab_referans_metin(
        p_tetkik_id integer, p_hasta_id integer, p_tarih date default null)
returns varchar
language sql
stable
as $$
    select case
             when r.alt is null and r.ust is null then coalesce(r.metin, '')::varchar
             when r.alt is not null and r.ust is not null
                  then (public.fn_lab_sayi_metni(r.alt) || ' - '
                     || public.fn_lab_sayi_metni(r.ust))::varchar
             when r.alt is not null
                  then ('> ' || public.fn_lab_sayi_metni(r.alt))::varchar
             else ('< ' || public.fn_lab_sayi_metni(r.ust))::varchar
           end
      from public.fn_lab_referans(p_tetkik_id, p_hasta_id, p_tarih) r
     where r.tetkik_id is not null;
$$;

-- ------------------------------------------------------------- onarim
--  Sondaki noktayla yazilmis ve cinsiyetsizlikten bos kalmis satirlari
--  yeniden coz. Sonucu yazilmis satira DOKUNULMAZ (rapor gecmisi).
update public.lab_istem_satir s
   set referans = public.fn_lab_referans_metin(t.id, i.taraf_id, current_date)
  from public.lab_tetkik t, public.lab_istem i
 where t.id = s.tetkik_id
   and i.id = s.istem_id
   and coalesce(s.referans, '') is distinct from
       coalesce(public.fn_lab_referans_metin(t.id, i.taraf_id, current_date), '')
   and (coalesce(s.referans, '') = '' or s.referans like '%.' or s.referans like '%. %')
   and not exists (select 1 from public.lab_sonuc x
                    where x.istem_satir_id = s.id and x.durum <> 4);

do $kontrol$
declare
    v_bos int;
begin
    select count(*) into v_bos
      from public.lab_istem_satir s
      join public.lab_tetkik t on t.id = s.tetkik_id
     where coalesce(s.referans, '') = ''
       and exists (select 1 from public.lab_tetkik_referans r
                    where r.tetkik_id = t.id);
    raise notice '644 tamam: referansi olan ama satirda bos kalan % satir', v_bos;
end $kontrol$;
