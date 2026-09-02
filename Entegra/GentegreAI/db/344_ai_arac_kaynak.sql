-- 344: AI araç kataloğuna KAYNAK ve LİSTE ROTASI.
--
-- Mockup `Ekranlar/ai_asistan.html`: asistanın cevabının altında hangi tablodan
-- kaç kayıt okunduğu ("📄 CARİHAREKET · 5 kayıt") ve aynı veriyi asıl ekranda
-- açan bağlantı ("🔗 Cari Listesi'nde aç") duruyor.
--
-- Bunlar sunum değil DENETİM bilgisidir: kullanıcı asistanın sayısına
-- güvenecekse veriyi nereden okuduğunu ve kendi gözüyle nerede
-- doğrulayacağını görmeli. Bu yüzden araç kataloğunda tutulur - fonksiyonu
-- yazan, kaynağını da yazar.
\set ON_ERROR_STOP on

alter table public.ai_arac
    add column if not exists kaynak_tablo varchar(120) not null default '',
    add column if not exists liste_rota   varchar(80)  not null default '',
    add column if not exists liste_adi    varchar(80)  not null default '';

comment on column public.ai_arac.kaynak_tablo is
  'Fonksiyonun okudugu tablo(lar) - cevabin altinda kaynak rozeti (344).';
comment on column public.ai_arac.liste_rota is
  'Ayni veriyi gosteren ekranin rotasi - "listede ac" baglantisi (344).';

update public.ai_arac set kaynak_tablo = v.kaynak, liste_rota = v.rota, liste_adi = v.ad
  from (values ('cari_vadesi_gecen', 'mali_hareket · taraf', '/cari',   'Cari Listesi'),
               ('stok_kritik',       'stok_durum · stok',    '/stok',   'Stok Listesi'),
               ('bugun_ozet',        'belge · kasa_islem · gorev', '/panel', 'Panel'),
               ('gorev_taslagi',     '',                     '/gorev',  'Görevler')) as v(kod, kaynak, rota, ad)
 where public.ai_arac.kod = v.kod;

do $$
begin
    raise notice '344 tamam: arac kaynak/rota bilgisi (% arac).',
        (select count(*) from public.ai_arac where kaynak_tablo <> '' or liste_rota <> '');
end $$;
