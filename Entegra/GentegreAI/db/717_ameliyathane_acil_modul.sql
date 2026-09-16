-- 717: Ameliyathane ve Acil için MODÜL kaydı.
--
-- 715/716 tabloları ve yetkileri kurdu; bu dosya iki modülü `kurum_modul`a
-- ekliyor ki menü grubu kurum profilinden AÇILIP KAPANABİLSİN.
--
-- NEDEN GEREKLİ: menü grubu bir modüle bağlı değilse hiçbir kuruluma
--   kapatılamaz. Ameliyathanesi olmayan bir poliklinikte "🔪 Ameliyathane"
--   grubunun menüde durması, kullanıcıya olmayan bir yeteneği vaat eder ve
--   ekranı açan kişi boş liste görür.
--
-- HANGİ KURUM TİPİNE VARSAYILAN AÇIK: yalnız yataklı/genel hastane. Dal
--   merkezlerinde (göz, diş, görüntüleme) ameliyathane ve acil ya yok ya da
--   bambaşka bir ölçekte; varsayılan açık gelseydi kurulum sonrası ilk iş
--   onları kapatmak olurdu.
insert into public.kurum_modul (kod, ad, sira)
select v.kod, v.ad, v.sira from (values
    ('ameliyathane', 'Ameliyathane', 44),
    ('acil',         'Acil Servis',  45)
  ) as v(kod, ad, sira)
 where not exists (select 1 from public.kurum_modul m where m.kod = v.kod);

-- Kurum tipi eşlemesi: mevcut tiplerden YATAKLI olanlara varsayılan açık.
--   `yatan_hasta` modülü açık olan tipi ölçüt alıyoruz - ameliyathane ve acil
--   yatan hasta olmadan işlemez, yani o tip zaten yataklıdır. Tip listesini
--   elle yazsaydık yeni bir kurum tipi eklendiğinde burası sessizce eksik
--   kalırdı.
insert into public.kurum_tipi_modul (kurum_tipi, modul, varsayilan)
select t.kurum_tipi, v.modul, 1
  from (select distinct kurum_tipi from public.kurum_tipi_modul
         where modul = 'yatan_hasta' and varsayilan = 1) t
 cross join (values ('ameliyathane'), ('acil')) as v(modul)
 where not exists (select 1 from public.kurum_tipi_modul k
                    where k.kurum_tipi = t.kurum_tipi and k.modul = v.modul);
