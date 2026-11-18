-- =============================================================================
--  1376 - SÖZLÜ ONAYCI LİSTESİNDE ŞUBE ERİŞİMİ (1375 düzeltmesi)
--
--  1375 `fn_iskonto_sozlu_onaycilar` şube erişimini yalnız `fn_kullanici_subeleri` (ROL şubeleri) ile ölçüyordu.
--  Oturum ise şubeyi dört adımda çözer (KullaniciDeposu.SubeleriHamAsync): 1) kişiye tanımlı şubeler
--  (kullanici_sube) 2) yoksa rol şubeleri 3) yoksa çalıştığı şube (taraf.sube_id) 4) tek şubeli kurulum.
--  Şubesi kişiye tanımlanmış yönetici listeden düşüyordu (test yakaladı). Aynı kural `fn_kullanici_sube_erisir`de.
-- =============================================================================

begin;

create or replace function public.fn_kullanici_sube_erisir(p_kullanici integer, p_sube integer)
returns boolean
language sql stable
as $$
  select case
    when exists (select 1 from public.kullanici_sube ks join public.sube s on s.id = ks.sube_id and s.aktif = 1
                  where ks.taraf_id = p_kullanici)
      then exists (select 1 from public.kullanici_sube ks join public.sube s on s.id = ks.sube_id and s.aktif = 1
                    where ks.taraf_id = p_kullanici and ks.sube_id = p_sube)
    when exists (select 1 from public.fn_kullanici_subeleri(p_kullanici))
      then exists (select 1 from public.fn_kullanici_subeleri(p_kullanici) x where x.sube_id = p_sube)
    when exists (select 1 from public.taraf t join public.sube s on s.id = t.sube_id and s.aktif = 1
                  where t.id = p_kullanici)
      then exists (select 1 from public.taraf t where t.id = p_kullanici and t.sube_id = p_sube)
    else (select count(*) from public.sube where aktif = 1) = 1
         and exists (select 1 from public.sube where id = p_sube and aktif = 1)
  end
$$;

comment on function public.fn_kullanici_sube_erisir(integer, integer) is
  '1376: kullanıcı bu şubeye girebilir mi - oturumla aynı dört adım (KullaniciDeposu.SubeleriHamAsync)';

create or replace function public.fn_iskonto_sozlu_onaycilar(p_sube integer, p_kullanici integer)
returns table (id integer, ad character varying)
language sql stable
as $$
  select distinct k.id, coalesce(public.fn_taraf_ad(t.unvan, t.ad, t.soyad)::varchar(120), k.kod)::varchar
    from public.taraf_kullanici k
    join public.taraf t on t.id = k.id
    join public.rol_yetki ry
      on ry.rol_id = k.rol_id
      or ry.rol_id in (select kr.rol_id from public.kullanici_rol kr where kr.kullanici_id = k.id)
    join public.yetki y on y.id = ry.yetki_id
   where k.aktif = 1 and k.id <> p_kullanici
     and y.kod in ('belge.iskonto_onay_birim', 'belge.iskonto_onay_mali', 'belge.iskonto_onay_ust')
     and coalesce(ry.gor, 0) = 1
     and (coalesce(p_sube, 0) = 0 or public.fn_kullanici_sube_erisir(k.id, p_sube))
   order by 2
$$;

commit;
