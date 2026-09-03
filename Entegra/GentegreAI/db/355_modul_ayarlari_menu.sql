-- ============================================================================
--  355 - "Yönetim › Ayarlar" alt menusu "Modül Ayarları" oldu (kullanici)
--
--  Ekrandaki ad listeTanimlari'ndan gelir; ceviri tablosu yalniz EN/DE
--  karsiliklarini tasir. Eski 'Ayarlar' anahtari BASKA yerde kullanilabilecegi
--  icin SILINMEZ, yeni anahtar eklenir.
-- ============================================================================
insert into public.ceviri (kapsam, anahtar, dil, metin)
select v.kapsam, v.anahtar, v.dil, v.metin
  from (values
        ('menu', 'Modül Ayarları', 1, 'Module Settings'),
        ('menu', 'Modül Ayarları', 2, 'Moduleinstellungen')
       ) as v(kapsam, anahtar, dil, metin)
 where not exists (select 1 from public.ceviri c
                    where c.kapsam = v.kapsam and c.anahtar = v.anahtar and c.dil = v.dil);
