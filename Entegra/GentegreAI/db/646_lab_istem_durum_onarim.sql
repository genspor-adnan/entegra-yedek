-- =====================================================================
--  646_lab_istem_durum_onarim.sql
--  İSTEM DURUMU YENİ EŞİKLE YENİDEN TÜRETİLİR.
--
--  Kullanıcı: "bütün sonuçlar dolunca sonuçlandı durumuna geçer".
--  Eski kural ilk ONAYLI satırda istemi 4 (Sonuçlandı) yapıyordu: 23
--  parametrelik hemogramın biri onaylanınca istem listede "Sonuçlandı"
--  görünüyor, kalan 22 tetkik kimsenin dikkatini çekmiyordu.
--
--  YENİ EŞİK (`LabServisi.IstemDurumTazeleAsync` ile aynı):
--    5 Onaylandı  - HER satır onaylı (durum 5)
--    4 Sonuçlandı - HER satır sonuçlanmış (3 sonuçlandı / 4 teknik onay /
--                   5 onaylı); onay bekliyor olabilir
--    3 Çalışılıyor- bir kısmı sonuçlanmış
--    aksi halde dokunulmaz (İstendi / Numune alındı)
--  6 (tekrar numune bekliyor) ve 7 (dış laboratuvarda) SONUÇLU SAYILMAZ:
--  ikisinde de o tetkiğin sonucu hâlâ yok.
--
--  İPTAL (9) ve SATIRSIZ istemlere dokunulmaz.
-- =====================================================================

update public.lab_istem i
   set durum = k.yeni,
       sonuc_tarihi = case when k.sonuclu = k.toplam
                           then coalesce(i.sonuc_tarihi, k.son_olcum, now())
                           else i.sonuc_tarihi end,
       degistirme_tarihi = now()
  from (select s.istem_id,
               count(*) as toplam,
               count(*) filter (where s.durum = 5) as onayli,
               count(*) filter (where s.durum in (3, 4, 5)) as sonuclu,
               max(ls.olcum_zamani) as son_olcum,
               case when count(*) filter (where s.durum = 5) = count(*) then 5
                    when count(*) filter (where s.durum in (3, 4, 5)) = count(*) then 4
                    when count(*) filter (where s.durum in (3, 4, 5)) > 0 then 3
                    else null end as yeni
          from public.lab_istem_satir s
          left join lateral (
                select x.olcum_zamani from public.lab_sonuc x
                 where x.istem_satir_id = s.id and x.durum <> 4
                 order by x.id desc limit 1) ls on true
         where s.durum <> 0
         group by s.istem_id) k
 where k.istem_id = i.id
   and k.yeni is not null
   and i.durum <> 9
   and i.durum is distinct from k.yeni;

do $kontrol$
declare
    v_sonuclandi int; v_calisiliyor int;
begin
    select count(*) filter (where durum = 4), count(*) filter (where durum = 3)
      into v_sonuclandi, v_calisiliyor
      from public.lab_istem;
    raise notice '646 tamam: sonuclandi %, calisiliyor %', v_sonuclandi, v_calisiliyor;
end $kontrol$;
