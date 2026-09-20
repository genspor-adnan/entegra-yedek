-- =====================================================================
--  901_gebelik_bildirim.sql
--  USS 223 GEBELİK BİLDİRİM
--  (KTS denetim maddesi H10; 900'ün açtığı gebelik dosyasının üzerine.)
--
--  ŞEMA REHBERDEN OKUNDU (rehber.enabiz.gov.tr → 223 → YAPI) ve KISA:
--    HASTA_TAKIP_BILGISI/SYSTakipNo                      zorunlu
--    GEBELIK_BILDIRIM_VERI_SETI
--      BIR_ONCEKI_DOGUM_DURUMU  zorunlu  SKRS d7e6d65a-b82a-6717-e040-7c0a021654a2
--      SON_ADET_TARIHI          zorunlu  datetime
--
--  Yani paket, 900'de açtığımız dosyanın iki alanından ibaret. Eksik olan
--  tek şey "bir önceki doğum durumu"ydu; dosyaya kolon olarak eklendi -
--  ayrı bir "bildirim" tablosu açmak, aynı gebeliği iki yerde tutmak
--  olurdu.
--
--  PAKET DOSYA AÇILINCA DOĞAR. Gebelik bildirimi, gebeliğin Bakanlığa ilk
--  duyurulmasıdır; izlem beklenmez. SAT'ı olmayan dosya (yalnız beklenen
--  doğumla açılmış) paket üretmez - SON_ADET_TARIHI zorunlu ve tahmini bir
--  tarih göndermek, Bakanlık tarafındaki izlem takvimini kaydırırdı.
-- =====================================================================

insert into public.kod_liste (kod, ad, skrs_liste)
select 'gebe.onceki_dogum', 'SKRS Bir Önceki Doğum Durumu',
       'd7e6d65a-b82a-6717-e040-7c0a021654a2'
 where not exists (select 1 from public.kod_liste l where l.kod = 'gebe.onceki_dogum');

alter table public.gebelik
  add column if not exists onceki_dogum smallint;

comment on column public.gebelik.onceki_dogum is
  '901: SKRS "bir onceki dogum durumu" - USS 223''un ZORUNLU ogesi. Bos ise '
  'bildirim paketi eksik alanla uretilir ve gonderilmez.';

-- Dosya dökümüne de girsin: ekran eksiği görebilmeli.
--   DROP + CREATE: PG görünümün kolon SIRASINI değiştirmeye izin vermiyor
--   ("cannot change name of view column") - 881'de de aynı tuzağa
--   düşmüştük.
drop view if exists public.v_gebelik;
create view public.v_gebelik as
select g.id, g.taraf_id,
       coalesce(nullif(trim(h.ad || ' ' || h.soyad), ''), h.unvan) as gebe,
       g.sat, g.beklenen_dogum,
       coalesce(g.beklenen_dogum, g.sat + 280) as tahmini_dogum,
       public.fn_gebelik_hafta(g.sat, g.beklenen_dogum) as hafta,
       g.gebelik_no, g.risk_durumu, g.onceki_dogum, g.durum, g.sonuc_tarihi,
       g.aciklama, g.sube_id,
       (select count(*) from public.gebe_izlem i
         where i.gebelik_id = g.id and i.durum = 1) as izlem_sayisi,
       -- BİLDİRİME HAZIR MI: 223 iki alanı da ZORUNLU istiyor.
       (g.sat is not null and g.onceki_dogum is not null) as bildirime_hazir
  from public.gebelik g
  left join public.taraf h on h.id = g.taraf_id;

comment on view public.v_gebelik is
  '900/901: gebelik dosyalari - hafta, tahmini dogum, izlem sayisi ve 223 '
  'bildirimine hazir olup olmadigi.';

-- --------------------------------------------------------- 223 paketi ----
insert into public.enabiz_paket_turu (kod, uss_paket_kodu, ad, zorunlu_alanlar, aktif)
select 'GEBELIK_BILDIRIM', 223, 'Gebelik Bildirim Veri Seti',
       '["SYSTakipNo","GEBELIK_BILDIRIM_VERI_SETI/BIR_ONCEKI_DOGUM_DURUMU",
         "GEBELIK_BILDIRIM_VERI_SETI/SON_ADET_TARIHI"]'::jsonb,
       1
 where not exists (select 1 from public.enabiz_paket_turu t
                    where t.kod = 'GEBELIK_BILDIRIM');

do $$
begin
    raise notice '901 tamam: % dosya bildirime hazir (SAT + onceki dogum durumu)',
        (select count(*) from public.v_gebelik where bildirime_hazir);
end $$;
