-- 239: Hesabı olmayan personellere kullanıcı hesabı (kullanıcı: "personel
-- ekleyince otomatik kullanıcı hesabı açsın", "mevcut personele de şimdi
-- kullanıcı oluştur").
--
-- Parola BOŞ bırakılır ve parola_degismeli = 1 olur: kişi ilk girişte kendi
-- parolasını tanımlar (POST /api/kimlik/ilk-parola, TCKN'nin son 4 hanesiyle
-- doğrulanır). Rol "Rol Atanmamış" havuzu - yetkiyi yönetici sonra verir.
-- Kod sicil numarasıdır; boş ya da çakışıksa taraf id'si kullanılır.

insert into public.taraf_kullanici
       (id, kod, parola_hash, parola_degismeli, rol_id, eposta, aktif, ekleyen)
select t.id,
       case when nullif(trim(t.kod), '') is not null
             and not exists (select 1 from public.taraf_kullanici k
                              where lower(k.kod) = lower(trim(t.kod)))
            then lower(trim(t.kod))
            else t.id::text end,
       '', 1,
       coalesce((select id from public.rol where kod = 'atanmamis'),
                (select id from public.rol order by id limit 1)),
       coalesce(nullif(trim(t.eposta), ''), ''),
       1, 0
  from public.taraf t
 where t.personel = 1
   and t.durum = 1
   and not exists (select 1 from public.taraf_kullanici k where k.id = t.id);
