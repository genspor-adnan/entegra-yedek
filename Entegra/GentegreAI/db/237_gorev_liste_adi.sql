-- 237: "Pozisyon" -> "Görev" (kullanıcı). 235'te liste 'Pozisyon' adıyla
-- açılmıştı; ad değişikliği ayrı numarada, uygulanmış kurulumlarda da düzelsin.

update public.kod_liste
   set ad = 'Görev'
 where kod = 'taraf.gorev' and ad = 'Pozisyon';
