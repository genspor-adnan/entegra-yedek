-- 1036: "Faturalar" listesinin adi "Satış Faturaları" (kullanici 11.10.2026:
--   "Faturalar (liste) rename Satış Faturaları"). Ekran tanimi (web) ile yetki
--   matrisi ve asistan rehberi ayni adi gostersin. Yalniz ad / yol; kod degismez.
--   Idempotent.
begin;

update public.yetki
   set ad = 'Kurum faturaları (Kurumlar & Sigorta › Satış Faturaları)'
 where kod = 'belge.kurum_fatura' and ad = 'Kurum faturaları (Kurumlar & Sigorta › Faturalar)';

update public.ai_rehber_ekran
   set baslik = 'Satış Faturaları', yol = 'Kurumlar & Sigorta › Satış Faturaları',
       menu_ad = case when menu_ad = 'Faturalar' then 'Satış Faturaları' else menu_ad end
 where rota = '/fatura' and baslik = 'Faturalar';

commit;
