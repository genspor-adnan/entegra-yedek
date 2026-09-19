-- ============================================================================
--  Gentegre AI — "Doktor" → "Uzman Doktor"
--  835_uzman_doktor_adi.sql
--
--  Kullanıcı: *"Doktor yerine Uzman Doktor olsun bir de Pratisyen Doktor
--  ekle"*.
--
--  KOD `hekim` DEĞİŞMEZ: şablon eşlemesi, prim rolleri ve atanmış hesaplar
--  (bu kurulumda 50 kişi) koda bakıyor. 790'da "Hekim → Doktor" da böyle
--  yapılmıştı; aynı yol.
--
--  Kurumun kendi verdiği adı EZMEZ: yalnız eski varsayılan addaki satır
--  güncellenir. Pratisyen Doktor rolü şablondan kurulur (Kurum Profili >
--  Roller); burada rol AÇILMAZ - kurulum kararı kurumundur.
-- ============================================================================
\set ON_ERROR_STOP on

update public.rol
   set ad = 'Uzman Doktor', degistirme_tarihi = now()
 where kod = 'hekim' and ad in ('Doktor', 'Hekim');

do $$
declare v_ad varchar; v_kisi integer;
begin
    select r.ad, (select count(*) from public.taraf_kullanici k
                   where k.rol_id = r.id and k.aktif = 1)
      into v_ad, v_kisi
      from public.rol r where r.kod = 'hekim';
    raise notice '835 tamam: hekim rolunun adi "%" (% atanmis kisi etkilenmedi).',
                 coalesce(v_ad, '(rol kurulu degil)'), coalesce(v_kisi, 0);
end $$;
