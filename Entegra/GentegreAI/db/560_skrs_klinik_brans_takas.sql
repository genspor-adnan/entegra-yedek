-- =====================================================================
--  560_skrs_klinik_brans_takas.sql
--  SKRS "klinik" ve "branş" kod listeleri ÇAPRAZ duruyordu - düzeltilir ve
--  bölüm/görev tabloları doğru listeden yeniden kurulur.
--
--  559 bölümleri `skrs.klinik`ten, görevleri `hekim.brans`tan doldurdu ve
--  sonuç TERS çıktı:
--      `skrs.klinik` içeriği : 101 ACIL TIP · 102 ADLI TIP · TIBBI PATOLOJI…
--                              -> bunlar UZMANLIK DALI (branş)
--      `hekim.brans` içeriği : 1 Acil Yoğun Bakım · 2 Genel Yoğun Bakım…
--                              -> bunlar KLİNİK
--
--  Yani bölüm listesine branşlar, görev listesine klinikler yazılmıştı.
--  Kaynak iki kod listesinin İÇERİĞİ ters; önce onlar yerine konur, sonra
--  tablolar doğru listeden doldurulur.
--
--  PERSONEL BRANŞI TAŞINIR: `taraf_personel.brans` eski (klinik içerikli)
--  listeden seçilmişti - 6 kayıt. Eski kodun ADI, yeni branş listesinde
--  aranır; bulunamayan BOŞALTILIR ve sayısı raporlanır. Yanlış listeden
--  gelen bir kodu olduğu gibi bırakmak, başka bir uzmanlığı göstermek olurdu.
--
--  SONRAKİ SKRS SENKRONU: eşleme tablosu ("KLİNİKLER" -> skrs.klinik,
--  "PERSONEL BRANŞ KODU" -> hekim.brans) içerikle uyumlu görünüyor; ters veri
--  eski bir yüklemeden kalmış olmalı. Senkron tekrar çalıştırıldıktan sonra
--  listelerin içeriği yine çaprazsa düzeltilecek yer `EntegrasyonUclari`
--  içindeki o eşleme satırlarıdır.
-- =====================================================================

do $$
declare
    v_klinik_id integer;   -- kod_liste.id : 'skrs.klinik'
    v_brans_id  integer;   -- kod_liste.id : 'hekim.brans'
    v_gecici    integer;
    v_sayi      integer;
    v_bosalan   integer;
begin
    select id into v_klinik_id from public.kod_liste where kod = 'skrs.klinik';
    select id into v_brans_id  from public.kod_liste where kod = 'hekim.brans';
    if v_klinik_id is null or v_brans_id is null then
        raise notice '560: kod listeleri yok - atlandi.';
        return;
    end if;

    -- Eski brans secimlerinin ADI yedeklenir (takastan ONCE okunmali).
    create temporary table zz_brans_ad on commit drop as
    select p.id as personel_id, btrim(kd.ad) as eski_ad
      from public.taraf_personel p
      join public.kod_deger kd
        on kd.liste_id = v_brans_id and kd.deger::text = p.brans
     where coalesce(p.brans, '') <> '';

    -- ------------------------------------------------------------ takas ----
    -- Ucuncu bir liste UZERINDEN: (liste_id, deger) benzersiz oldugu icin
    --   dogrudan degistokus cakisir. Gecici liste GERCEKTEN acilir - kolonda
    --   FK var, uydurma id kabul edilmiyor; is bitince silinir.
    insert into public.kod_liste (kod, ad)
    values ('zz.takas.560', 'Gecici takas listesi (560)')
    returning id into v_gecici;
    update public.kod_deger set liste_id = v_gecici where liste_id = v_klinik_id;
    update public.kod_deger set liste_id = v_klinik_id where liste_id = v_brans_id;
    update public.kod_deger set liste_id = v_brans_id where liste_id = v_gecici;
    delete from public.kod_liste where id = v_gecici;

    -- ------------------------------------------- personel bransini tasi ----
    update public.taraf_personel p
       set brans = (select kd.deger::text from public.kod_deger kd
                     where kd.liste_id = v_brans_id
                       and public.fn_ara_metin(btrim(kd.ad)) = public.fn_ara_metin(z.eski_ad)
                     limit 1)
      from zz_brans_ad z
     where p.id = z.personel_id;

    update public.taraf_personel set brans = '' where brans is null;
    select count(*) into v_bosalan
      from zz_brans_ad z join public.taraf_personel p on p.id = z.personel_id
     where coalesce(p.brans, '') = '';

    -- ------------------------------- bolum / gorev yeniden (559 mantigi) ----
    delete from public.randevu_bolum_ayar;
    update public.departman set ustbirim_id = null where ustbirim_id is not null;
    delete from public.personel_gorev;
    delete from public.departman;
    alter sequence if exists public.departman_id_seq restart with 1;
    alter sequence if exists public.personel_gorev_id_seq restart with 1;

    -- BOLUM <- KLINIKLER (artik `skrs.klinik` gercekten klinik)
    insert into public.departman (kod, ad, durum, sira, randevu_verilebilir, ekleyen)
    select kd.deger::text, btrim(kd.ad), case when kd.aktif = 1 then 1 else 0 end,
           coalesce(kd.sira, 0), 1, 0
      from public.kod_deger kd
     where kd.liste_id = v_klinik_id
     order by btrim(kd.ad);
    get diagnostics v_sayi = row_count;
    raise notice '560: % bolum SKRS KLINIK listesinden yazildi.', v_sayi;

    -- GOREV <- PERSONEL BRANS KODU
    insert into public.personel_gorev (kod, ad, departman_id, durum, sira, ekleyen)
    select kd.deger::text, btrim(kd.ad), 0,
           case when kd.aktif = 1 then 1 else 0 end, coalesce(kd.sira, 0), 0
      from public.kod_deger kd
     where kd.liste_id = v_brans_id
     order by btrim(kd.ad);
    get diagnostics v_sayi = row_count;
    raise notice '560: % gorev SKRS BRANS listesinden yazildi (% personelin bransi cozulemedi).',
                 v_sayi, v_bosalan;
end $$;
