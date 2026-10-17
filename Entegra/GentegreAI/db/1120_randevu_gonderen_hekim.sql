-- ============================================================================
--  1120_randevu_gonderen_hekim.sql
--  RANDEVUDA GÖNDEREN (DIŞ) HEKİM (kullanıcı 17.10.2026: "görüntüleme merkezinde dış dr gönderiyor..
--  onun adını randevudan seçebilir miyiz.. tabi doktora değil sadece cihaza randevu verilecek").
--
--  randevu.gonderen_id: hastayı gönderen hekim (dış hekim kartı, 305). Yalnız BİLGİ - kaynak değil:
--  hekim_id gibi çakışma / mesai / izin kontrolüne girmez, doktorun takviminde görünmez. Hasta
--  geldiğinde kabul ekranında istemin "isteyen hekim"i buradan dolar.
--  İstemden verilen (radyoloji) randevularda istemin isteyen hekimi geriye doğru yazılır.
--  Tekrar çalıştırılabilir.
-- ============================================================================

alter table public.randevu
    add column if not exists gonderen_id integer references public.taraf(id);
create index if not exists ix_randevu_gonderen on public.randevu (gonderen_id, baslangic) where gonderen_id is not null;

comment on column public.randevu.gonderen_id is
  '1120: hastayi gonderen (dis) hekim - yalniz bilgi, kaynak degil (cakisma/mesai kontrolu yok)';

-- Geriye dönük: istemden açılmış randevularda istemin dış hekimi (yalnız boş olanlar).
update public.randevu r
   set gonderen_id = i.istek_hekim_id
  from public.radyoloji_istem i
 where i.randevu_id = r.id
   and r.gonderen_id is null
   and i.istek_hekim_id is not null
   and exists (select 1 from public.taraf_personel p where p.id = i.istek_hekim_id and p.dis_hekim = 1);
