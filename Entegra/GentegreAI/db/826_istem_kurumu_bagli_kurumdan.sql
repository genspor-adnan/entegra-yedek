-- ============================================================================
--  Gentegre AI — İSTEM KURUMU: HEKİMİN BAĞLI KURUMUNDAN VARSAYILAN
--  826_istem_kurumu_bagli_kurumdan.sql
--
--  825'te gönderen primi istemin `istek_kurum_id` alanına bağlandı: dolu =
--  kurum adına, boş = hekim kendi adına. Ama o alanı bugün yalnız EKRAN
--  dolduruyor (`RadyolojiUclari.cs` insert'i hekimin kurumuna bakmıyor) -
--  kuruma bağlı hekimin istemi kurumsuz kaydolunca:
--    · kurumun portalı o satırı görmüyor (kapsam `istek_kurum_id`),
--    · fatura kuruma bağlanmıyor,
--    · ve 825'ten sonra prim yanlışlıkla HEKİME yazılıyor.
--
--  ============ TEK YAZAN: TETİK ======================================
--  Varsayılan API'de değil TETİKTE: ekran, portal, göç ve HL7 aynı kuraldan
--  geçsin. Uçta yazılsaydı ikinci bir giriş yolu kuralı atlardı.
--
--  ============ VARSAYILAN, ZORLAMA DEĞİL =============================
--  · INSERT: kurum boşsa hekimin `taraf.bag_id`'sinden doldurulur.
--  · UPDATE: yalnız HEKİM DEĞİŞTİĞİNDE yeniden türetilir ve yalnız kurum
--    alanı elle SEÇİLMEMİŞSE (eski değer boş ya da eski hekimin bağlı
--    kurumuysa). Memur kurumu bilerek boşalttıysa (hekim kendi özel
--    hastasını gönderiyor) tetik onu geri doldurmaz - yoksa "kendi adına
--    gönderme" hiç yazılamazdı.
--
--  ============ GEÇMİŞ SATIRA DOKUNULMADI ==============================
--  Geri dolgu YOK: kapanmış istemin kurumunu sonradan yazmak, prim rolünü ve
--  kimin hak ettiğini geçmişe dönük değiştirir - bu para kararıdır, tetik
--  kararı değil. (Bu veritabanında etkilenen satır zaten 0.)
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.tg_rad_istem_kurumu()
returns trigger language plpgsql as $$
declare
  v_yeni_bag integer;
  v_eski_bag integer;
begin
    if new.istek_hekim_id is null then return new; end if;

    select t.bag_id into v_yeni_bag
      from public.taraf t where t.id = new.istek_hekim_id;

    if tg_op = 'INSERT' then
        if new.istek_kurum_id is null then
            new.istek_kurum_id := v_yeni_bag;
        end if;
        return new;
    end if;

    -- UPDATE: hekim degismediyse karisma.
    if new.istek_hekim_id is not distinct from old.istek_hekim_id then
        return new;
    end if;
    -- Kurum alani bu islemde ELLE degistirildiyse (ornegin ayni anda secildi)
    --   o secim gecerlidir.
    if new.istek_kurum_id is distinct from old.istek_kurum_id then
        return new;
    end if;

    select t.bag_id into v_eski_bag
      from public.taraf t where t.id = old.istek_hekim_id;

    -- Eski deger turetilmis miydi: bos ya da eski hekimin bagli kurumu ise
    --   evet - yeni hekime gore tazelenir (bagimsiz hekimde bosalir).
    if old.istek_kurum_id is null or old.istek_kurum_id = v_eski_bag then
        new.istek_kurum_id := v_yeni_bag;
    end if;
    return new;
end $$;

comment on function public.tg_rad_istem_kurumu is
  'Istem kurumu bos ise hekimin bagli kurumundan (taraf.bag_id) doldurulur (826); '
  'elle secilmis/bosaltilmis kuruma dokunmaz.';

drop trigger if exists tg_rad_istem_kurumu on public.radyoloji_istem;
create trigger tg_rad_istem_kurumu
before insert or update of istek_hekim_id, istek_kurum_id on public.radyoloji_istem
for each row execute function public.tg_rad_istem_kurumu();

do $$
declare v_acik integer;
begin
    select count(*) into v_acik
      from public.radyoloji_istem i
      join public.taraf t on t.id = i.istek_hekim_id
     where i.istek_kurum_id is null and t.bag_id is not null;
    raise notice '826 tamam: yeni istemlerde kurum hekimin bagli kurumundan doluyor. '
                 'GECMISTE kurumsuz kalan % istem BILEREK degistirilmedi (prim gecmisi).',
                 v_acik;
end $$;
