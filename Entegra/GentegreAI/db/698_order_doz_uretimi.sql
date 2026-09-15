-- 698: ORDER SAATLERİNDEN DOZ SATIRI ÜRETİMİ (eMAR'ın girdisi).
--
-- TEMEL KARAR — PLAN ÖNCEDEN ÜRETİLİR, uygulama anında değil.
--   "Günde 2×1 IV" bir TALİMATTIR; 08:00 ve 20:00 dozları ise birer OLAYDIR.
--   Satırlar hemşire ilacı verdiğinde üretilseydi, ATLANMIŞ doz hiç var
--   olmazdı: eMAR ekranı yalnız verilenleri gösterir, verilmeyeni kimse
--   göremezdi. Bu yüzden bekleyen satır önceden yazılır ve verilmeyen doz
--   kendi satırında "geciken" olarak durur.
--
-- TEMEL KARAR — ÜRETİM TETİKLEYİCİDE, uygulamada değil. Order kartından,
--   toplu order şablonundan ya da göç betiğinden yazılan order aynı planı
--   üretmeli. Üretimi API'ye koymak, ikinci yazma yolunda planı sessizce
--   eksik bırakırdı.
--
-- TEMEL KARAR — UFUK SINIRLI (varsayılan 48 saat). Üç aylık bir order'ın
--   bütün dozlarını bugünden yazmak, tabloyu hiç uygulanmayacak satırla
--   doldurur ve order değişince binlerce satırı düzeltmek gerekir. Gece
--   çalışan iş ufku her gün ileri taşır.
--
-- TEMEL KARAR — GEÇMİŞE DOKUNULMAZ. Yeniden üretim yalnız GELECEKTEKİ
--   "bekliyor" satırlarını temizler; uygulanmış, atlanmış ya da reddedilmiş
--   satır asla silinmez - silinen doz kaydı, olmamış bir uygulamayı da
--   olmuş bir uygulamayı da geri getirilemez biçimde yok eder.

-- ============================================================ tek order ==
create or replace function public.fn_order_uygulama_uret(
    p_order_id  integer,
    p_ufuk_saat integer default 48
) returns integer
language plpgsql
as $$
declare
    o        public.yatis_order%rowtype;
    v_bas    timestamptz;
    v_son    timestamptz;
    v_gun    date;
    v_saat   text;
    v_an     timestamptz;
    v_ek     integer;
    v_sayi   integer := 0;
begin
    select * into o from public.yatis_order where id = p_order_id;
    if not found then return 0; end if;

    if o.durum <> 1 or o.tur not in (1, 2) then return 0; end if;
    if jsonb_typeof(o.saatler) <> 'array' or jsonb_array_length(o.saatler) = 0 then
        return 0;
    end if;

    v_bas := greatest(o.baslangic, now() - interval '12 hours');
    v_son := now() + make_interval(hours => greatest(p_ufuk_saat, 1));
    if o.bitis is not null and o.bitis < v_son then v_son := o.bitis; end if;
    if v_son <= v_bas then return 0; end if;

    delete from public.order_uygulama u
     where u.order_id = p_order_id
       and u.durum = 1
       and u.planlanan > now();

    v_gun := v_bas::date;
    while v_gun <= v_son::date loop
        for v_saat in select jsonb_array_elements_text(o.saatler) loop
            begin
                v_an := (v_gun::text || ' ' || v_saat)::timestamptz;
            exception when others then
                continue;
            end;

            if v_an < v_bas or v_an > v_son then continue; end if;

            insert into public.order_uygulama
                (order_id, planlanan, durum, ekleyen)
            select p_order_id, v_an, 1, coalesce(o.ekleyen, 0)
             where not exists (
                 select 1 from public.order_uygulama x
                  where x.order_id = p_order_id and x.planlanan = v_an);

            get diagnostics v_ek = row_count;
            v_sayi := v_sayi + v_ek;
        end loop;
        v_gun := v_gun + 1;
    end loop;

    return v_sayi;
end $$;

comment on function public.fn_order_uygulama_uret(integer, integer) is
  'Order saatlerinden BEKLEYEN doz satırı üretir (698). Geçmişe ve uygulanmış/'
  'atlanmış satıra dokunmaz; gelecekteki bekleyen satırları plana göre yeniler.';

-- ========================================================== tetikleyici ==
create or replace function public.tg_yatis_order_doz() returns trigger
language plpgsql
as $$
begin
    -- Sadece planı ETKİLEYEN alanlar değişince üret: her `degistirme_tarihi`
    --   dokunuşunda yeniden üretmek, gereksiz silme/ekleme trafiği olurdu.
    if tg_op = 'INSERT'
       or new.saatler is distinct from old.saatler
       or new.baslangic is distinct from old.baslangic
       or new.bitis is distinct from old.bitis
       or new.durum is distinct from old.durum then
        perform public.fn_order_uygulama_uret(new.id, 48);
    end if;

    -- ORDER DURDURULDU/İPTAL EDİLDİ: gelecekteki bekleyen dozlar düşer.
    --   Geçmiş kalır - "durdurulana kadar şu dozlar verildi" cevabı lazım.
    if tg_op = 'UPDATE' and new.durum <> 1 and old.durum = 1 then
        delete from public.order_uygulama u
         where u.order_id = new.id and u.durum = 1 and u.planlanan > now();
    end if;

    return null;
end $$;

drop trigger if exists tg_yatis_order_doz on public.yatis_order;
create trigger tg_yatis_order_doz
    after insert or update on public.yatis_order
    for each row execute function public.tg_yatis_order_doz();

-- ====================================================== gece çalışan iş ==
-- UFKU İLERİ TAŞIR. Ayrıca zamanı geçmiş "bekliyor" satırını GECİKTİ'ye çeker:
--   eMAR ekranı "geciken" listesini bu durumdan okur ve hemşire nöbet
--   devrinde ekranın söylediğine güvenir. Hesabı ekranda yapsaydık, ekranı
--   açmayan kimse gecikmeyi göremezdi.
create or replace function public.fn_order_doz_gunluk(
    p_ufuk_saat integer default 48
) returns table (uretilen integer, geciken integer, aciklama text)
language plpgsql
as $$
declare
    o      record;
    v_top  integer := 0;
    v_gec  integer := 0;
begin
    for o in
        select od.id
          from public.yatis_order od
          join public.yatis y on y.id = od.yatis_id
         where od.durum = 1 and od.tur in (1, 2)
           and y.durum in (1, 2, 3)
    loop
        v_top := v_top + public.fn_order_uygulama_uret(o.id, p_ufuk_saat);
    end loop;

    -- 30 DAKİKA: klinik uygulamada "geciken doz" eşiği; yatış kartındaki açık
    --   iş sayacı da aynı eşiği kullanır (iki yerde iki eşik, iki farklı
    --   gerçek demek olurdu).
    update public.order_uygulama u
       set durum = 5
     where u.durum = 1
       and u.planlanan < now() - interval '30 minutes';
    get diagnostics v_gec = row_count;

    uretilen := v_top;
    geciken  := v_gec;
    aciklama := v_top || ' doz planlandı, ' || v_gec || ' doz gecikti.';
    return next;
end $$;

comment on function public.fn_order_doz_gunluk(integer) is
  'Gece işi (698): aktif order''ların doz ufkunu ileri taşır, zamanı geçen '
  'bekleyen dozu "gecikti" yapar.';

-- ZAMANLI İŞ KAYDI: kod API tarafında (`ZamanliIsler`) `yatan.doz` olarak
--   tanımlı. SAATLİK (periyot 1, dakika 5): gecikme durumu saat başı
--   güncellenmeli - günde bir çalışsaydı, sabah geciken doz akşama kadar
--   "bekliyor" görünürdü ve nöbet devri yanlış listeye bakardı.
insert into public.zamanli_is (kod, ad, periyot, gun, saat, dakika, aktif, aciklama)
select 'yatan.doz', 'Yatan hasta doz planı', 1, 1, 0, 5, 1,
       'Order saatlerinden doz üretir, zamanı geçen dozu gecikti yapar.'
 where not exists (select 1 from public.zamanli_is where kod = 'yatan.doz');
