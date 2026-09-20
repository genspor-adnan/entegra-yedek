-- =====================================================================
--  888_lab_referans_cihaz.sql
--  REFERANS ARALIĞINA CİHAZ / YÖNTEM BOYUTU
--  (KTS denetim maddesi L3: "Yaş, cinsiyet, cihaz vb. kriterlere göre
--   referans aralığı tanımlanabiliyor mu?")
--
--  ZATEN VARDI: yaş bandı (gün cinsinden, çocuk bantları dahil), cinsiyet,
--  geçerlilik başlangıcı, panik sınırları ve "cinsiyet bilinmiyor" dalı
--  (642/644). EKSİK OLAN: aynı tetkikin referans aralığı ÖLÇÜM YÖNTEMİNE
--  göre değişir - 642 kendi notunda "cihaz/kit doğrulaması gerekir" diyor
--  ama tabloda cihaz boyutu yoktu.
--
--  NEDEN ÖNEMLİ: TSH, ferritin, D vitamini gibi immünoassay testlerinde
--  aralık üreticinin kitine bağlıdır; iki cihazda çalışan bir laboratuvar
--  tek aralık kullanırsa bir cihazın sonuçları sistematik olarak yanlış
--  bayraklanır (normal değer "yüksek", yüksek değer "normal" görünür).
--  Akredite laboratuvar zaten kendi cihazının aralığını doğrular; sistem
--  bunu tutamıyorsa doğrulama kâğıtta kalır.
--
--  KURAL: CİHAZA ÖZEL ARALIK, GENEL ARALIĞI EZER. Yaş bandı daha dar olsa
--  bile cihaza özel satır önce gelir - yöntem farkı, bant darlığından daha
--  belirleyicidir. Cihaz seçilemiyorsa (elle giriş, cihaz silinmiş) genel
--  aralık kullanılır; yani tanım yoksa davranış bire bir eskisi gibidir.
--
--  SONUÇ SATIRINA DONAR: `lab_sonuc.referans_alt/ust/metin` sonuç yazılırken
--  kopyalanıyor; cihaz aralığı da o anda donduğu için sonradan tanım
--  değişse bile eski rapor kendi aralığıyla kalır.
-- =====================================================================

alter table public.lab_tetkik_referans
  add column if not exists cihaz_id integer references public.cihaz(id),
  add column if not exists yontem   varchar(60) not null default '';

comment on column public.lab_tetkik_referans.cihaz_id is
  '888: araligin gecerli oldugu cihaz. BOS = tum cihazlar (genel aralik). '
  'Cihaza ozel satir genel satiri EZER.';
comment on column public.lab_tetkik_referans.yontem is
  '888: olcum yontemi/kit adi (ornek "Elektrokemilüminesans") - raporda ve '
  'kartta gorunur, secimi etkilemez; secim cihaz_id ile yapilir.';

create index if not exists ix_lab_tetkik_referans_cihaz
  on public.lab_tetkik_referans (tetkik_id, cihaz_id);

-- ------------------------------------------------------- secim motoru ----
--  ESKI 3 PARAMETRELI IMZA DUSURULUYOR: yeni imzada 4. parametrenin
--  varsayilani var, yani `fn_lab_referans(t, h, tarih)` cagrilari aynen
--  calisir. Iki imza birlikte dursaydi PG 3 argumanli cagriyi "function is
--  not unique" diye reddederdi.
drop function if exists public.fn_lab_referans(integer, integer, date);

create or replace function public.fn_lab_referans(p_tetkik_id integer,
                                                  p_hasta_id  integer,
                                                  p_tarih     date default null,
                                                  p_cihaz_id  integer default null)
returns public.lab_tetkik_referans
language plpgsql stable as $$
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

    -- 1) TAM EŞLEŞME: önce CİHAZA ÖZEL aralık, sonra en dar yaş bandı,
    --    sonra cinsiyete özel olan.
    select r.* into v_sonuc
      from public.lab_tetkik_referans r
     where r.tetkik_id = p_tetkik_id
       and (r.cinsiyet = 0 or r.cinsiyet = v_cinsiyet)
       and (r.cihaz_id is null or r.cihaz_id = p_cihaz_id)
       and (r.gecerli_bas is null or r.gecerli_bas <= v_tarih)
       and v_yas_gun between r.yas_alt_gun and r.yas_ust_gun
     order by (r.cihaz_id is not null) desc,
              (r.yas_ust_gun - r.yas_alt_gun) asc,
              r.cinsiyet desc, r.sira asc, r.id asc
     limit 1;

    if v_sonuc.id is not null then
        return v_sonuc;
    end if;

    -- 2) CİNSİYET BİLİNMİYOR: yaş bandındaki cinsiyete özel aralıkların
    --    BİRLEŞİMİ. Tek satır gibi döner; `id` yoktur (sentetik).
    --    Cihaz süzgeci burada da geçerli: başka cihazın aralığını birleşime
    --    katmak, hiçbir cihazda geçerli olmayan bir aralık üretirdi.
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
       and (r.cihaz_id is null or r.cihaz_id = p_cihaz_id)
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

comment on function public.fn_lab_referans(integer, integer, date, integer) is
  '888 (642/644 uzerine): hastanin yas/cinsiyetine VE olcumun yapildigi '
  'cihaza gore referans araligi. Cihaza ozel satir genel satigi ezer; '
  'cihaz verilmezse ya da tanim yoksa genel aralik doner.';

-- Metin yardımcısı da cihazı taşır: rapordaki "Referans" sütunu, sonucun
--   ölçüldüğü cihazın aralığını yazmalı.
create or replace function public.fn_lab_referans_metin(p_tetkik_id integer,
                                                        p_hasta_id  integer,
                                                        p_tarih     date default null,
                                                        p_cihaz_id  integer default null)
returns varchar language sql stable as $$
    select case
             when r.alt is null and r.ust is null then coalesce(r.metin, '')::varchar
             when r.alt is not null and r.ust is not null
                  then (public.fn_lab_sayi_metni(r.alt) || ' - '
                     || public.fn_lab_sayi_metni(r.ust))::varchar
             when r.alt is not null
                  then ('> ' || public.fn_lab_sayi_metni(r.alt))::varchar
             else ('< ' || public.fn_lab_sayi_metni(r.ust))::varchar
           end
      from public.fn_lab_referans(p_tetkik_id, p_hasta_id, p_tarih, p_cihaz_id) r
     where r.tetkik_id is not null;
$$;

-- ESKI 3 PARAMETRELI METIN IMZASI: yukaridaki 4 parametreli hali eskisini
--   EZMEZ (farkli imza), ikisi birlikte kalirsa 3 argumanli cagri belirsiz
--   olurdu.
drop function if exists public.fn_lab_referans_metin(integer, integer, date);

do $$
begin
    raise notice '888 tamam: % referans satiri, % tanesi cihaza ozel',
        (select count(*) from public.lab_tetkik_referans),
        (select count(*) from public.lab_tetkik_referans where cihaz_id is not null);
end $$;
