-- =====================================================================
--  574_personel_bolum_gorev.sql
--  573'ün eksiği: bölüm/görev KARTIN okuduğu kolona yazılmalıydı.
--
--  Personelin bölümü İKİ yerde duruyor: `taraf.departman` (kartın ve listenin
--  okuduğu alan) ve `taraf_personel.departman` (özlük uzantısı). 573 yalnız
--  ikincisine yazdı; ekranda "Bölüm" kolonu boş görünüyordu.
--
--  Ayrıca hekimlere GÖREV verilir: bölümün adıyla eşleşen SKRS branşı varsa
--  o, yoksa "Uzman Hekim". İdari personelin görevi 573'te zaten yazılmıştı.
-- =====================================================================

-- Bolum: ozluk uzantisindan kartin kolonuna.
update public.taraf t
   set departman = p.departman
  from public.taraf_personel p
 where p.id = t.id and coalesce(t.departman, 0) = 0 and coalesce(p.departman, 0) <> 0;

-- Hekim gorevi: once bolum adiyla ayni brans, yoksa "Uzman Hekim".
update public.taraf t
   set gorev_id = coalesce(
         (select g.id from public.personel_gorev g
           join public.departman d on d.id = t.departman
          where public.fn_ara_metin(g.ad) = public.fn_ara_metin(d.ad)
          limit 1),
         (select g.id from public.personel_gorev g
           where public.fn_ara_metin(g.ad) = 'uzman hekim' limit 1))
 where t.personel = 1 and t.randevu_verilebilir = 1
   and coalesce(t.gorev_id, 0) = 0;
