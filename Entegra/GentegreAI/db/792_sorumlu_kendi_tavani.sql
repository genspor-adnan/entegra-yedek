-- ============================================================================
--  Gentegre AI — ONAY BASAMAĞININ SAHİBİ KENDİ TAVANINA KADAR DOĞRUDAN İSKONTO
--  792_sorumlu_kendi_tavani.sql
--
--  Kullanıcı: *"banko sorumlusu kendi kayıt yapıyorsa ona tanımlanmış orana
--  kadar direkt iskonto yapabilir"*.
--
--  ============ BUGÜNKÜ KİLİT =========================================
--  783 şu kuralı koydu: kurumun eşiği (`basvuru.iskonto_onay_esik`, %10)
--  üstündeki her iskonto, tavan ne olursa olsun ONAYLI talepten gelmek
--  zorunda. O gün doğruydu - tavanı %100 olan rol sınırsız indirimi tek
--  başına, kayıtsız yapıyordu.
--
--  Ama 787 birim imzasını banko şefine verdi, 789 da yedeği yöneticiden aldı.
--  Sonuç bir KİLİT: banko şefi kendi açtığı kayda %20 indirim yapmak isterse
--  talep açmak zorunda, talebin ilk imzası yine KENDİSİNDE ve kendi talebini
--  onaylayamıyor (783). Talep kuyrukta kalıyor - kimse imzalayamıyor.
--
--  ============ KURAL =================================================
--  Bir basamağın SAHİBİ o basamak için eşiğe tabi değildir; onun sınırı
--  KENDİ TAVANIDIR (`basvuru.iskonto` yetkisinin değeri, 661).
--
--  Gerekçe: eşik "bu oranın üstünü tek başına yapma, bir imza daha al" demek.
--  İmzanın sahibi zaten o kişiyse alınacak ikinci imza yok - kuralı
--  uygulamak, işi yapmayı imkânsız kılmaktan başka bir şey üretmiyor.
--  Denetim kaybolmuyor: kişi kendi tavanını AŞAMIYOR ve tavanı kurum veriyor
--  (Yönetim › Yetkiler › Sınır).
--
--  MUAFİYET YALNIZ BİRİM BASAMAĞI SAHİBİNE: mali ve üst imza sahibi
--  (`belge.iskonto_onay_mali/_ust`) kayıt açtığında zincirin İLK imzası
--  başkasındadır - onlar için kilit yok, eşik olduğu gibi işler.
--
--  ============ TAVAN DB'DE DE KORUNUYOR ==============================
--  Muafiyet, eşiği tek DB kuralı olmaktan çıkarıyor; yerine tavan kontrolü
--  konuyor. Tavan bugüne kadar yalnız ekranda ve API'de bakılıyordu (661) -
--  muaf yola çıkan kullanıcı için veritabanında da bir duvar olmalı.
--
--  YAZAN KİŞİ satırın `degistiren`/`ekleyen` damgasından okunuyor: API her
--  yazıya kullanıcıyı damgalıyor (YazmaBaglami). Damga yoksa (göç, elle SQL)
--  muafiyet çalışmaz, eski eşik kuralı geçerlidir - kimliği bilinmeyen yazıma
--  ayrıcalık verilmez.
-- ============================================================================
\set ON_ERROR_STOP on

-- ------------------------------------------------------------- yardımcılar --
create or replace function public.fn_kullanici_yetkili(
    p_kullanici integer, p_yetki character varying)
returns boolean
language sql
stable
as $function$
    select exists (select 1 from public.fn_kullanici_yetkileri(p_kullanici) y
                    where y.yetki_kod = p_yetki and y.gor = 1);
$function$;

comment on function public.fn_kullanici_yetkili is
  '792: kullanicinin bir yetkiyi GORME hakki var mi (rollerinden cozulur).';

create or replace function public.fn_kullanici_iskonto_tavani(p_kullanici integer)
returns numeric
language sql
stable
as $function$
    -- EN YUKSEK TAVAN: kullanici birden cok rol tasiyabilir (kullanici_rol);
    --   yetki cozumu de en genisini verir - tavan da oyle olmali.
    select coalesce(max(case when y.deger ~ '^[0-9]+([.,][0-9]+)?$'
                             then replace(y.deger, ',', '.')::numeric else 0 end), 0)
      from public.fn_kullanici_yetkileri(p_kullanici) y
     where y.yetki_kod = 'basvuru.iskonto' and y.gor = 1;
$function$;

comment on function public.fn_kullanici_iskonto_tavani is
  '792/661: kullanicinin iskonto TAVANI - `basvuru.iskonto` yetkisinin degeri.';

-- ------------------------------------------------------------------ tetik --
create or replace function public.tg_belge_satir_iskonto_esik()
returns trigger
language plpgsql
as $function$
declare
    v_esik      numeric;
    v_tur       smallint;
    v_tipi      smallint;
    v_yazi      text;
    v_kullanici integer;
    v_tavan     numeric;
begin
    if coalesce(new.iskonto, 0) <= 0 then return new; end if;
    -- ONAYDAN GELEN SATIR (662): `fn_iskonto_talep_karar` kilitle yazar.
    if coalesce(new.iskonto_kilit, 0) = 1 then return new; end if;

    select b.tur, b.tipi into v_tur, v_tipi
      from public.belge b where b.id = new.belge_id;
    -- YALNIZ BASVURU (19/30): ERP belgesinde iskonto ticari pazarliktir.
    if coalesce(v_tur, 0) <> 19 or coalesce(v_tipi, 0) <> 30 then return new; end if;

    -- BASAMAK SAHIBI MUAF (792): onu esige tabi tutmak, imzayi kendisinden
    --   istemek olurdu - 783 kendi talebini onaylamayi zaten yasakliyor,
    --   yani talep hic imzalanamazdi. Sinir artik KENDI TAVANI.
    v_kullanici := nullif(coalesce(nullif(new.degistiren, 0), nullif(new.ekleyen, 0)), 0);
    if v_kullanici is not null
       and public.fn_kullanici_yetkili(v_kullanici, 'belge.iskonto_onay_birim') then
        v_tavan := public.fn_kullanici_iskonto_tavani(v_kullanici);
        if new.iskonto > v_tavan then
            v_yazi := '%' || trim(to_char(v_tavan, 'FM999990.##'));
            raise exception 'Kendi iskonto tavanınız % - daha yükseği için bir '
                            'üst kademeden onay isteyin.', v_yazi
                  using errcode = 'GK422';
        end if;
        return new;
    end if;

    select coalesce(nullif(deger, '')::numeric, 0) into v_esik
      from public.referans where anahtar = 'basvuru.iskonto_onay_esik';
    if coalesce(v_esik, 0) <= 0 then return new; end if;      -- kural kapali

    if new.iskonto > v_esik then
        v_yazi := '%' || trim(to_char(v_esik, 'FM999990.##'));
        raise exception '% üstü iskonto onay ister (en çok % doğrudan '
                        'uygulanabilir); satırı seçip "İskonto Onayı İste" ile '
                        'gönderin.', v_yazi, v_yazi using errcode = 'GK422';
    end if;
    return new;
end $function$;

comment on function public.tg_belge_satir_iskonto_esik() is
  '783/792: esik ustu iskonto onay ister; ANCAK birim imzasinin sahibi kendi '
  'TAVANINA kadar dogrudan uygular - imzayi kendisinden isteyemez.';

-- --------------------------------------- sorumlunun baslangic tavani -------
-- 787 rolu kurarken bankonun tavanini (%10) kopyalamisti; sorumlunun tavani
--   bankonunkiyle ayni kalirsa muafiyetin pratikte bir karsiligi olmaz.
--   Baslangic %25 - muhasebenin tavaniyla ayni (785). DEGISTIRILMISSE
--   DOKUNULMAZ: kurum kendi degerini koyduysa korunur.
update public.rol_yetki ry
   set deger = '25', degistirme_tarihi = now()
  from public.rol r, public.yetki y
 where ry.rol_id = r.id and ry.yetki_id = y.id
   and r.kod = 'kayit_kabul_sorumlu' and y.kod = 'basvuru.iskonto'
   and ry.deger = '10';

do $$
declare r record;
begin
    for r in
        select rl.ad, ry.deger,
               (select count(*) from public.taraf_kullanici k
                 where k.rol_id = rl.id and k.aktif = 1) as kisi
          from public.rol rl
          join public.rol_yetki ry on ry.rol_id = rl.id
          join public.yetki y on y.id = ry.yetki_id and y.kod = 'basvuru.iskonto'
         where coalesce(nullif(ry.deger, ''), '0') <> '0'
         order by (ry.deger)::numeric desc
    loop
        -- plpgsql'de "%" bicim belirtecidir; yuzde isareti metne ONCEDEN
        --   gomulur (783'te ayni tuzak "%10s" gibi bozuk cikti vermisti).
        raise notice '792: % -> tavan % (% kisi)', r.ad, '%' || r.deger, r.kisi;
    end loop;
    raise notice '792: birim imzasinin sahibi esikten muaf, sinir kendi tavani.';
end $$;
