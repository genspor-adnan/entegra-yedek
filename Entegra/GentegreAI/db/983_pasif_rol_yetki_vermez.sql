-- 983 · PASİF ROL YETKİ VERMEZ
--
-- `fn_kullanici_rolleri` kullanıcının aktifliğini kontrol ediyordu ama ROLÜN
-- aktifliğini kontrol etmiyordu: pasife alınan bir rol, o role bağlı kullanıcıya
-- yetki vermeye devam ediyordu. Rol listesinden kaldırılan bir rolün etkisini
-- sürdürmesi, "bu kullanıcı neden bu ekrana girebiliyor" sorusunu cevapsız
-- bırakır - rol pasifse yetkisi de düşmeli.
--
-- Kullanıcı 08.10.2026, kuruluma uygun rol seti kurulurken bulundu: gereksiz
-- roller pasife alındığında yetkilerinin de kalkması gerekiyor.
--
-- `aktif = 1` şartı HER İKİ DALA da konur: ana rol (taraf_kullanici.rol_id) ve
-- ek roller (kullanici_rol). Yalnız birine koymak, aynı rolü iki yoldan alan
-- kullanıcıda yetkinin sessizce durmasına yol açardı.
create or replace function public.fn_kullanici_rolleri(p_kullanici_id integer)
returns table(rol_id integer, ana smallint)
language sql
stable
as $$
    select k.rol_id, 1::smallint
      from public.taraf_kullanici k
      join public.rol r on r.id = k.rol_id and r.aktif = 1
     where k.id = p_kullanici_id and k.aktif = 1
    union all
    select kr.rol_id, 0::smallint
      from public.kullanici_rol kr
      join public.taraf_kullanici k on k.id = kr.kullanici_id and k.aktif = 1
      join public.rol r on r.id = kr.rol_id and r.aktif = 1
     where kr.kullanici_id = p_kullanici_id
$$;

comment on function public.fn_kullanici_rolleri(integer) is
  'Kullanıcının rolleri (ana + ek). Yalnız AKTİF roller döner: pasif rol yetki vermez (983).';
