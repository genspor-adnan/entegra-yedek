-- =====================================================================
--  608_basvuru_sys_takip_no.sql
--  SYS TAKİP NUMARASI BAŞVURUNUN KENDİSİNDE TUTULUR.
--
--  Kılavuzun 101 açıklaması: "Bu işlem sonunda alınan SYSTakipNo değeri ilgili
--  BAŞVURUYLA İLİŞKİLİ OLARAK HBYS sisteminde tutulmalıdır. Bu takip numarası
--  diğer paketler gönderilirken kullanılacaktır."
--
--  605'te numara `enabiz_paket.sys_takip_no` alanına yazılmıştı - orası
--  gönderimin kendi kaydı. Ama numara PAKETİN değil BAŞVURUNUN özelliğidir:
--  başvuru USS'de bu numarayla yaşar, sonraki bütün paketler (103 muayene,
--  106 çıkış, 301 silme) onu taşır. Paket tablosundan okumak, her seferinde
--  "bu başvurunun en son gönderilmiş 101 paketi hangisiydi" sorusunu
--  çözmeyi gerektiriyordu.
--
--  Paketteki alan KALIYOR: o, "bu gönderim hangi numarayı döndürdü" izidir.
--  Başvurudaki ise yürürlükteki değerdir.
-- =====================================================================

alter table public.belge_basvuru
  add column if not exists sys_takip_no varchar(64) not null default '';

comment on column public.belge_basvuru.sys_takip_no is
  'USS SYS Takip No (608): 101 gonderiminde doner, basvurunun e-Nabiz kimligi. '
  'Sonraki paketler ve 301 silme bunu tasir.';

create index if not exists ix_belge_basvuru_takip
    on public.belge_basvuru (sys_takip_no) where sys_takip_no <> '';

-- Halihazirda gonderilmis paketlerden geriye doldur (varsa).
update public.belge_basvuru bb
   set sys_takip_no = p.sys_takip_no
  from public.enabiz_paket p
  join public.enabiz_paket_turu t on t.id = p.paket_turu_id
 where p.kaynak_tur = 1 and p.kaynak_id = bb.id
   and t.uss_paket_kodu = '101'
   and p.sys_takip_no <> '' and bb.sys_takip_no = '';

do $$
begin
    raise notice '608 tamam: % basvuruda takip no dolu',
        (select count(*) from public.belge_basvuru where sys_takip_no <> '');
end $$;
