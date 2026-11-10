-- 1296 - Saha rolleri SİSTEM rolü (10.11.2026, code review 20e1705 bulgu 4)
--
-- RolKapsami "saha_temsilci" rol KODUNA bakar (temsilci yalnız kendi hekim /
-- ziyaret / talep / vade kayıtlarını görür). Rol yalnız standart rol şablonu
-- ekranından açılıyordu: kodu farklı açılan ya da sonradan değiştirilen rolde
-- kural sessizce yok oluyor, temsilci HER ŞEYİ görüyordu. Bu göç iki rolü her
-- kurulumda sistem rolü yapar (fn_rol_sistem_koru: kod değişmez, silinmez,
-- pasife alınmaz). Var olan rolün yetkileri DOKUNULMAZ (müşteri ayarı);
-- yalnız yeni açılan role şablon yetkileri ve şube satırları yazılır.
--
-- Tekrar çalıştırılabilir.
begin;

alter table public.rol disable trigger tg_rol_sistem_koru_guncelle;
update public.rol set sistem = 1, aktif = 1
 where kod in ('saha_temsilci', 'saha_sorumlu') and (sistem <> 1 or aktif <> 1);
alter table public.rol enable trigger tg_rol_sistem_koru_guncelle;

create temp table yeni_rol (kod varchar(50), id int) on commit drop;

with ekleyen as (select min(id) as id from public.taraf_kullanici),
     ekle as (
    insert into public.rol (kod, ad, amac, sistem, aktif, ekleyen, portal_turu)
    select v.kod, v.ad, v.amac, 1, 1, e.id, 0
      from (values
            ('saha_temsilci', 'Müşteri Temsilcisi (Saha)',
             'Dış doktor ziyaretleri, doktor talepleri, ziyaret vadesi ve haftalık plan; dış doktor kartını düzenler, silmez.'),
            ('saha_sorumlu', 'Müşteri Temsilci Sorumlusu (Saha)',
             'Temsilcinin ekranları + silme, şube temsilcisi atama, Saha Performansı, prim planı görme.')
           ) as v(kod, ad, amac)
     cross join ekleyen e
     where not exists (select 1 from public.rol r where r.kod = v.kod)
    returning kod, id)
insert into yeni_rol select kod, id from ekle;

-- Şablon yetkileri (StandartRolUclari: Ortak + rol satırları) - yalnız YENİ role.
insert into public.rol_yetki (rol_id, yetki_id, gor, ekle, degistir, sil, ekleyen)
select n.id, y.id, s.gor, s.ekle, s.degistir, s.sil, (select min(id) from public.taraf_kullanici)
  from yeni_rol n
  join (values
        -- ortak
        ('saha_temsilci', 'panel', 1, 0, 0, 0), ('saha_temsilci', 'mesaj', 1, 1, 1, 0), ('saha_temsilci', 'gorev', 1, 1, 1, 0),
        ('saha_temsilci', 'dokum', 1, 0, 0, 0), ('saha_temsilci', 'ai', 1, 0, 0, 0), ('saha_temsilci', 'ai.rehber', 1, 0, 0, 0),
        ('saha_temsilci', 'dokuman', 1, 1, 0, 0),
        ('saha_temsilci', 'dis_doktor.liste', 1, 0, 0, 0), ('saha_temsilci', 'dis_doktor', 1, 1, 1, 0),
        ('saha_temsilci', 'dis_doktor.ziyaret', 1, 1, 1, 0), ('saha_temsilci', 'dis_doktor.talep', 1, 1, 1, 0),
        ('saha_temsilci', 'dis_doktor.vade', 1, 1, 1, 0), ('saha_temsilci', 'dis_doktor.plan', 1, 1, 1, 0),
        ('saha_temsilci', 'kurum', 1, 0, 0, 0),
        -- ortak
        ('saha_sorumlu', 'panel', 1, 0, 0, 0), ('saha_sorumlu', 'mesaj', 1, 1, 1, 0), ('saha_sorumlu', 'gorev', 1, 1, 1, 0),
        ('saha_sorumlu', 'dokum', 1, 0, 0, 0), ('saha_sorumlu', 'ai', 1, 0, 0, 0), ('saha_sorumlu', 'ai.rehber', 1, 0, 0, 0),
        ('saha_sorumlu', 'dokuman', 1, 1, 0, 0),
        ('saha_sorumlu', 'dis_doktor.liste', 1, 0, 0, 0), ('saha_sorumlu', 'dis_doktor', 1, 1, 1, 1),
        ('saha_sorumlu', 'dis_doktor.ziyaret', 1, 1, 1, 1), ('saha_sorumlu', 'dis_doktor.talep', 1, 1, 1, 1),
        ('saha_sorumlu', 'dis_doktor.vade', 1, 1, 1, 1), ('saha_sorumlu', 'dis_doktor.plan', 1, 1, 1, 1),
        ('saha_sorumlu', 'dis_doktor.performans', 1, 0, 0, 0), ('saha_sorumlu', 'kurum', 1, 0, 0, 0),
        ('saha_sorumlu', 'prim', 1, 0, 0, 0), ('saha_sorumlu', 'prim.plan', 1, 0, 0, 0)
       ) as s(rol_kod, yetki_kod, gor, ekle, degistir, sil) on s.rol_kod = n.kod
  join public.yetki y on y.kod = s.yetki_kod
on conflict (rol_id, yetki_id) do nothing;

-- Şube satırları (şablon ekranı gibi: her şube, ilk şube varsayılan, yazma açık) - yalnız YENİ role.
insert into public.rol_sube (rol_id, sube_id, varsayilan, yazma, ekleyen)
select n.id, s.id, case when s.id = (select min(id) from public.sube) then 1 else 0 end, 1,
       (select min(id) from public.taraf_kullanici)
  from yeni_rol n cross join public.sube s
on conflict do nothing;

do $$
declare n int;
begin
    select count(*) into n from public.rol where kod in ('saha_temsilci', 'saha_sorumlu') and sistem = 1 and aktif = 1;
    if n <> 2 then raise exception '1296: saha rolleri sistem rolü yapılamadı (%/2)', n; end if;
end $$;

commit;
