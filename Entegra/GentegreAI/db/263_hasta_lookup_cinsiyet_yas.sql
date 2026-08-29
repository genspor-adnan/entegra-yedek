-- 263: HASTA LOOKUP'ında TC yerine cinsiyet + yaş (kullanıcı: "hasta isminden
-- TC no'yu çıkar, yerine cinsiyetin ilk harfini ve yaşını sadece yıl olarak,
-- onun da sağına tel'i yaz; cinsiyetin soluna cinsiyet ikonu gelsin").
--
-- Kayıt kabul masasında ekran açık duruyor: TC numarası orada görünmesin,
-- ama randevu verirken hastayı ayırt etmeye yarayan cinsiyet/yaş dursun.
-- Biçim:  "MERVE DEMİR — ♀ K 34 · ☎ +90 532 123 45 67"

drop view if exists public.v_hasta_lookup;
create view public.v_hasta_lookup as
select t.id,
       (coalesce(nullif(trim(t.unvan), ''), trim(t.ad || ' ' || t.soyad))
        -- Cinsiyet: ikon + baş harf (1 Erkek / 2 Kadın; boşsa hiç yazılmaz).
        || case h.cinsiyet when 1 then ' — ♂ E' when 2 then ' — ♀ K' else '' end
        -- Yaş yalnız YIL: doğum tarihi yoksa hiç yazılmaz.
        || case when h.dogum_tarihi is not null
                then case when h.cinsiyet in (1, 2) then ' ' else ' — ' end
                     || extract(year from age(h.dogum_tarihi))::int::text
                else '' end
        || case when coalesce(nullif(t.cep_tel, ''), nullif(t.telefon, ''), '') <> ''
                then ' · ☎ ' || coalesce(nullif(t.cep_tel, ''), t.telefon)
                else '' end)::varchar(200) as ad,
       case when t.durum = 1 then 1 else 0 end as aktif
  from public.taraf t
  left join public.taraf_hasta h on h.id = t.id
 where t.hasta = 1;
