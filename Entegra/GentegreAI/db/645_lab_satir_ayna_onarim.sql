-- =====================================================================
--  645_lab_satir_ayna_onarim.sql
--  SONUCU OLAN SATIRLARIN AYNA KOLONLARI - geçmişe dönük doldurma.
--
--  642 ile `SonucYazAsync` artık `lab_istem_satir` üzerindeki
--  sonuc/birim/referans/isaret kolonlarını da yazıyor (istem kartının
--  "Tetkikler" gridi ve raporlar oradan okuyor). Daha ÖNCE yazılmış
--  sonuçların satırında bu kolonlar boş kaldı: kullanıcı kartta sonucu
--  girilmiş tetkiği boş görüyor.
--
--  KAYNAK DAİMA `lab_sonuc`: satıra onun SON geçerli (iptal olmayan)
--  sonucu kopyalanır - değer, birim ve o gün damgalanmış referans.
--  Buradaki referans 643/644'ün katalog referansıyla değiştirilmez;
--  sonuç hangi aralıkla değerlendirildiyse rapor onu göstermelidir.
--
--  YALNIZ BOŞ KOLON: kurum satıra elle bir şey yazdıysa korunur.
-- =====================================================================

-- Satir basina SON gecerli sonuc. (`update ... from lateral` hedef
--   tabloyu goremez; once CTE ile tekillestirilir.)
with son as (
    select distinct on (x.istem_satir_id) x.*
      from public.lab_sonuc x
     where x.durum <> 4
     order by x.istem_satir_id, x.id desc)
update public.lab_istem_satir s
   set sonuc = case when coalesce(s.sonuc, '') = ''
                    then coalesce(ls.deger_metin, '') else s.sonuc end,
       birim = case when coalesce(s.birim, '') = ''
                    then coalesce(nullif(ls.birim, ''), t.birim, '') else s.birim end,
       referans = case when coalesce(s.referans, '') = ''
                       then coalesce(
                              nullif(ls.referans_metin, ''),
                              case when ls.referans_alt is not null
                                        and ls.referans_ust is not null
                                   then public.fn_lab_sayi_metni(ls.referans_alt)
                                     || ' - ' || public.fn_lab_sayi_metni(ls.referans_ust)
                                   when ls.referans_alt is not null
                                   then '> ' || public.fn_lab_sayi_metni(ls.referans_alt)
                                   when ls.referans_ust is not null
                                   then '< ' || public.fn_lab_sayi_metni(ls.referans_ust)
                                   else '' end)
                       else s.referans end,
       -- İşaret: 0 normal, 1 düşük, 2 yüksek, 3 panik. Panik HER İKİ yönde
       --   de 3 - kartta "düşük" görünen kritik değer aciliyetini söylemez.
       isaret = case when coalesce(s.isaret, 0) <> 0 then s.isaret
                     when coalesce(ls.panik, 0) = 1 then 3
                     when ls.bayrak like 'L%' then 1
                     when ls.bayrak like 'H%' then 2
                     else 0 end,
       sonuc_tarihi = coalesce(s.sonuc_tarihi, ls.olcum_zamani)
  from public.lab_tetkik t, son ls
 where t.id = s.tetkik_id
   and ls.istem_satir_id = s.id
   and (coalesce(s.sonuc, '') = '' or coalesce(s.birim, '') = ''
        or coalesce(s.referans, '') = '');

do $kontrol$
declare
    v_eksik int;
begin
    select count(*) into v_eksik
      from public.lab_istem_satir s
     where exists (select 1 from public.lab_sonuc x
                    where x.istem_satir_id = s.id and x.durum <> 4)
       and coalesce(s.sonuc, '') = '';
    raise notice '645 tamam: sonucu olup satirda bos kalan % satir', v_eksik;
end $kontrol$;
