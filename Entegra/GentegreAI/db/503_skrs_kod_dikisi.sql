-- =====================================================================
--  503_skrs_kod_dikisi.sql
--  SKRS TÜM KOD LİSTELERİNE: hangi listemiz hangi SKRS listesi, hangi
--  değerimiz hangi SKRS kodu.
--
--  Kullanıcı: "bizim ana yönümüz e-Nabız ve SKRS, o yüzden tüm kodlarımızda
--  SKRS'yi aynen uygulayalım."
--
--  KURAL: SKRS'de karşılığı olan bir listede DEĞERLERİMİZ SKRS KODUNUN
--  AYNISIDIR - kendi numaralandırmamızı uydurup dışarıya çevirmeyiz. Ama
--  aktarımdan gelen eski listelerde bu her zaman böyle değil; o yüzden iki
--  kolon gerekiyor:
--    * `kod_liste.skrs_liste` - bu liste SKRS'nin HANGİ listesi ("SKRS Klinik",
--      "SKRS Ölçü Birimi"...). Boşsa SKRS'de karşılığı yok demektir.
--    * `kod_deger.skrs_kod`   - değerin SKRS karşılığı. Değerimiz zaten SKRS
--      kodu ise ikisi AYNI olur (kural sağlanıyor); farklıysa bu kolon köprüdür
--      ve `v_skrs_sapma` onu rapor eder.
--
--  SKRS KOD DEĞERLERİ UYDURULMAZ. Resmî listeler SKRS servisinden
--  (`entegrasyon_hesap`, db/336) ya da kullanıcının verdiği dosyadan gelir;
--  elimizde yokken eşleme BOŞ bırakılır - yanlış kod, sessizce yanlış bildirim
--  demektir.
--
--  `enabiz_kod_esleme` (mevcut) tekil kayıt eşlemesi için kalır (klinik, kurum
--  kodu gibi); bu göç KOD LİSTELERİNİN kendisini SKRS'ye bağlar.
-- =====================================================================

alter table public.kod_liste
    add column if not exists skrs_liste varchar(80) not null default '';
alter table public.kod_deger
    add column if not exists skrs_kod   varchar(20) not null default '';

comment on column public.kod_liste.skrs_liste is
    'Bu kod listesinin SKRS karşılığı ("SKRS Klinik" gibi); boş = SKRS''de yok (503).';
comment on column public.kod_deger.skrs_kod is
    'Değerin SKRS kodu. Kural: SKRS''li listede deger = skrs_kod (503).';

create index if not exists ix_kod_deger_skrs
    on public.kod_deger (liste_id, skrs_kod) where skrs_kod <> '';

-- Adında "(SKRS)" geçen listeler zaten SKRS karşılığı olduğu bilinerek
--   açılmıştı; liste adını buradan işaretleriz (kod değerleri DOLDURULMAZ).
update public.kod_liste
   set skrs_liste = 'SKRS ' || btrim(replace(ad, '(SKRS)', ''))
 where skrs_liste = '' and ad like '%(SKRS)%';

-- Kesin bilinen eşlemeler (adı SKRS'de birebir geçen listeler).
update public.kod_liste set skrs_liste = 'SKRS Klinik'      where kod = 'klinik.kod'        and skrs_liste = '';
update public.kod_liste set skrs_liste = 'SKRS Cinsiyet'    where kod = 'hasta.cinsiyet'    and skrs_liste = '';
update public.kod_liste set skrs_liste = 'SKRS Ölçü Birimi' where kod = 'stok.ana_birim'    and skrs_liste = '';

/**
 * SAPMA RAPORU: SKRS'ye bağlı listelerde kuralın tutup tutmadığı.
 *   durum = 'eslenmemis' -> skrs_kod boş (resmî liste henüz yüklenmedi)
 *           'sapma'      -> değerimiz SKRS kodundan FARKLI (köprü çalışıyor
 *                           ama kural bozuk - bildirimde çeviri gerekiyor)
 *           'uyumlu'     -> deger = skrs_kod
 */
create or replace view public.v_skrs_sapma as
select l.kod          as liste,
       l.ad           as liste_adi,
       l.skrs_liste,
       d.deger,
       d.ad           as deger_adi,
       d.skrs_kod,
       case when d.skrs_kod = ''                    then 'eslenmemis'
            when d.skrs_kod = d.deger::text         then 'uyumlu'
            else 'sapma' end                        as durum
  from public.kod_liste l
  join public.kod_deger d on d.liste_id = l.id
 where l.skrs_liste <> '' and d.aktif = 1;

comment on view public.v_skrs_sapma is
    'SKRS''ye bağlı kod listelerinde eşleşme durumu: uyumlu / sapma / eslenmemis (503).';

/**
 * SKRS KODU ÇÖZÜCÜ: bildirim yazan kod tek yerden sorar.
 * Kural gereği çoğu listede değerin kendisi döner; eşleme varsa o kazanır.
 * SKRS'ye bağlı OLMAYAN listede boş döner - çağıran "bu alan bildirilmez"
 * kararını buradan verir, kendi tahminini yazmaz.
 */
create or replace function public.fn_skrs_kod(p_liste text, p_deger integer)
returns varchar language sql stable as $$
    select case when l.skrs_liste = '' then ''
                when d.skrs_kod <> ''  then d.skrs_kod
                else d.deger::text end
      from public.kod_liste l
      join public.kod_deger d on d.liste_id = l.id and d.deger = p_deger
     where l.kod = p_liste
     limit 1;
$$;

comment on function public.fn_skrs_kod(text, integer) is
    'Kod değerinin SKRS karşılığı; SKRS''siz listede boş döner (503).';
