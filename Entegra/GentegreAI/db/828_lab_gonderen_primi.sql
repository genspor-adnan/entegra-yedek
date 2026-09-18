-- ============================================================================
--  Gentegre AI — LAB KALEMİNDE GÖNDEREN PRİMİ
--  828_lab_gonderen_primi.sql
--
--  825 kuralı ("kendi adına gönderen doktor tanımlıysa gönderen primi alır,
--  kurum adına gönderen almaz") radyolojide çalışıyordu; laboratuvarda kalem
--  ROLÜ HİÇ YAZILMIYORDU - rol yazan tek yerler radyoloji (326/825), muayene
--  (584) ve teleradyoloji (807) idi. Dış hekimin gönderdiği lab işi hakedişte
--  hiç görünmüyordu.
--
--  ============ HANGİ KALEM ===========================================
--  `lab_istem_satir.belge_satir_id` şemada var ama HİÇBİR yol onu yazmıyor
--  (bu veritabanında 0/103). Bu yüzden bağ ÜCRET SATIRI üzerinden kurulur:
--  istemin belgesindeki, hizmeti bir `lab_tetkik` ya da `lab_panel`
--  karşılığı olan satırlar. Aynı eşleme `LabServisi.BasvurudanIstemTamamla`
--  istemi üretirken de kullanılıyor - iki yerde iki ölçü olmasın.
--
--  ============ KİM ===================================================
--  825 ile birebir aynı: `dis_kurum_id` doluysa GÖNDEREN KURUMDUR (hekime
--  prim yok), boşsa ve gönderen dış hekimse HEKİMDİR. İç personelin istemi
--  gönderen primi doğurmaz - o iş kurumun kendi işidir.
--
--  Belgede FARKLI göndericili birden çok lab istemi varsa hiç rol yazılmaz:
--  aynı kaleme iki gönderen yazmak primi ikiye katlardı, birini seçmek de
--  uydurma olurdu. Böyle bir belge elle rollenir.
--
--  ============ PLAN KAPISI YOK (326 ile aynı) =========================
--  Rol yazılması prim DEĞİLDİR: `fn_prim_plan_satiri` eşleşen plan bulamazsa
--  prim üretilmez. Planı olmayan hekimde rol durur (kimin gönderdiği
--  hakedişte görünür), para doğmaz. "Tanımlıysa alır" kapısı budur.
--
--  ELLE GİRİLEN EZİLMEZ: kalemde `kaynak = 1` bir Gönderen satırı varsa o
--  kaleme dokunulmaz.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.fn_lab_rol_tazele(p_belge_id integer)
returns integer language plpgsql as $$
declare
  v_hedef  integer;
  v_sayi   integer;
  v_sayac  integer := 0;
  r        record;
begin
    if coalesce(p_belge_id, 0) = 0 then return 0; end if;

    -- GÖNDEREN: kurum adına gelen işte kurum, kendi adına gelende dış hekim.
    --   Iç personelin istemi hic gonderen uretmez (null).
    select count(distinct hedef), min(hedef) into v_sayi, v_hedef
      from (
        select coalesce(i.dis_kurum_id,
                        public.fn_dis_hekim_kurumu(i.personel_id),
                        case when exists (select 1 from public.taraf_personel p
                                           where p.id = i.personel_id
                                             and coalesce(p.dis_hekim, 0) = 1)
                             then i.personel_id end) as hedef
          from public.lab_istem i
         where i.belge_id = p_belge_id
      ) h
     where hedef is not null;

    -- Belgede farkli gonderici varsa otomatik rol YAZILMAZ (ve eskisi silinir).
    if coalesce(v_sayi, 0) <> 1 then v_hedef := null; end if;

    -- LAB KALEMLERİ: hizmeti tetkik ya da panel karşılığı olan satırlar.
    create temporary table if not exists gecici_lab_kalem (satir_id integer)
        on commit drop;
    delete from gecici_lab_kalem;
    insert into gecici_lab_kalem (satir_id)
    select bs.id
      from public.belge_satir bs
     where bs.belge_id = p_belge_id
       and bs.hizmet_id is not null
       and (exists (select 1 from public.lab_tetkik t
                     where t.hizmet_id = bs.hizmet_id and t.durum = 0)
         or exists (select 1 from public.lab_panel p
                     where p.hizmet_id = bs.hizmet_id and p.durum = 0));

    -- ESKİ OTOMATİK ROL: hedef değiştiyse (ya da belirsizleştiyse) temizlenir.
    --   Elle girilmiş (kaynak = 1) satır korunur.
    delete from public.belge_satir_rol bsr
     using gecici_lab_kalem g
     where bsr.belge_satir_id = g.satir_id
       and bsr.rol = 1
       and bsr.kaynak = 2
       and (v_hedef is null or bsr.taraf_id <> v_hedef);

    if v_hedef is not null then
        insert into public.belge_satir_rol (belge_satir_id, rol, taraf_id,
                                            pay_yuzde, kaynak)
        select g.satir_id, 1, v_hedef, 100, 2
          from gecici_lab_kalem g
         where not exists (select 1 from public.belge_satir_rol e
                            where e.belge_satir_id = g.satir_id and e.rol = 1
                              and e.kaynak = 1)
        on conflict (belge_satir_id, rol, taraf_id) do nothing;
        get diagnostics v_sayac = row_count;
    end if;

    -- Rol degisti: kalemin ACIK primleri yeniden uretilir (326 deseni).
    for r in select g.satir_id from gecici_lab_kalem g
    loop
        perform public.fn_prim_uret_belge(r.satir_id);
    end loop;
    for r in select d.id from public.kasa_islem_dagitim d
              join gecici_lab_kalem g on g.satir_id = d.belge_satir_id
    loop
        perform public.fn_prim_uret(r.id);
    end loop;

    return v_sayac;
end $$;

comment on function public.fn_lab_rol_tazele is
  'Lab kalemlerine Gonderen (rol 1) yazar (828): kurum adina gelen iste KURUM, '
  'kendi adina gelende DIS HEKIM; elle girilen rolu ezmez.';

-- ------------------------------------------------------------- tetikler ---
create or replace function public.tg_lab_rol_istem()
returns trigger language plpgsql as $$
begin
    perform public.fn_lab_rol_tazele(new.belge_id);
    -- Belge degistiyse eski belgenin kalemleri de tazelenmeli.
    if tg_op = 'UPDATE' and old.belge_id is distinct from new.belge_id then
        perform public.fn_lab_rol_tazele(old.belge_id);
    end if;
    return null;
end $$;

drop trigger if exists tr_lab_rol_istem on public.lab_istem;
create trigger tr_lab_rol_istem
  after insert or update of belge_id, personel_id, dis_kurum_id on public.lab_istem
  for each row execute function public.tg_lab_rol_istem();

-- ÜCRET SATIRI SONRA GELEBİLİR: istem açıldığında kalem henüz yoksa rol
--   yazılamaz; kalem eklenince aynı fonksiyon yeniden çalışır (326'daki
--   "kalem sonradan oluşunca tetik yeniden çalışır" kuralının lab karşılığı).
create or replace function public.tg_lab_rol_kalem()
returns trigger language plpgsql as $$
begin
    if exists (select 1 from public.lab_istem i where i.belge_id = new.belge_id) then
        perform public.fn_lab_rol_tazele(new.belge_id);
    end if;
    return null;
end $$;

drop trigger if exists tr_lab_rol_kalem on public.belge_satir;
create trigger tr_lab_rol_kalem
  after insert or update of hizmet_id, belge_id on public.belge_satir
  for each row execute function public.tg_lab_rol_kalem();

-- GERİ DOLGU YOK: geçmiş lab kalemine bugün rol yazmak, kapanmamış
--   hakedişlerde yeni prim doğurur - para kararı ayrı verilir.
do $$
declare v_belge integer;
begin
    select count(distinct i.belge_id) into v_belge
      from public.lab_istem i
     where i.belge_id is not null
       and (i.dis_kurum_id is not null
            or public.fn_dis_hekim_kurumu(i.personel_id) is not null);
    raise notice '828 tamam: yeni lab kalemlerinde Gonderen rolu yaziliyor. '
                 'GECMISTEKI % belge BILEREK rollenmedi (prim gecmisi).', v_belge;
end $$;
