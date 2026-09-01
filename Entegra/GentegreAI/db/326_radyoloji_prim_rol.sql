-- 326: RADYOLOJİ İSTEMİNDEN OTOMATİK PRİM ROLÜ (324 üzerine).
--
-- Prim kaleme bağlanır, kalemin rolleri de "primi kim hak ediyor" sorusunun
-- cevabıdır. Radyolojide bu bilgi ZATEN istemde duruyor: kim gönderdi
-- (istek hekimi / sevk eden kurum), kim çekti (tekniker), kim raporladı ve
-- onayladı. Elle ikinci kez girilmesi hem angarya hem hata kaynağı - burada
-- istemden türetilir.
--
-- İKİ KURAL:
--   1) ELLE GİRİLEN EZİLMEZ. Bir rolde kaynak=1 (elle) satır varsa o rol hiç
--      yönetilmez: kullanıcı bilerek düzeltmiştir (ör. raporu başkası yazdı
--      ama prim başhekimin). Otomatik satırlar (kaynak=2) senkronlanır.
--   2) ROL DEĞİŞİNCE PRİM YENİDEN ÜRETİLİR - ama yalnız AÇIK satırlar.
--      Dönemi kapanmış (durum 2) hakediş dondurulmuştur.
--
-- Rol eşlemesi (kod listesi prim.rol):
--   istek hekimi  -> dış hekimse 1 Gönderen, kurum personeliyse 2 İsteyen
--   sevk kurumu   -> 1 Gönderen (yalnız istek hekimi YOKKEN; yoksa çift sayım)
--   tekniker      -> 9 Teknisyen
--   raporu yazan  -> 5 Raporlayan
--   onaylayan     -> 6 Onaylayan

-- ============================================ kesinleşmiş satır koruması ===
-- fn_prim_uret taslakları siliyordu ama "on conflict do update" kesinleşmiş
-- satırın tutarını da güncelleyebiliyordu: dönem kapandıktan sonra rol/oran
-- değişince donmuş hakediş değişirdi. Güncelleme AÇIK satırla sınırlandı.
create or replace function public.fn_prim_uret(p_dagitim_id integer)
returns integer language plpgsql as $$
declare
  d          record;
  r          record;
  kural      record;
  v_matrah   numeric(19,4);
  v_tutar    numeric(19,4);
  v_belgetur smallint;
  v_kurum    integer;
  v_sube     integer;
  v_modalite smallint;
  v_tarih    date;
  v_sayac    integer := 0;
begin
    select d2.id, d2.belge_satir_id, d2.pay, d2.tutar,
           k.islem_tarihi::date as tarih, k.durum, k.iptal_islem_id,
           s.hizmet_id, s.kdv, b.sube_id, bb.odeyen_kurum_id
      into d
      from public.kasa_islem_dagitim d2
      join public.kasa_islem k on k.id = d2.kasa_islem_id
      join public.belge_satir s on s.id = d2.belge_satir_id
      join public.belge b on b.id = s.belge_id
      left join public.belge_basvuru bb on bb.id = b.id
     where d2.id = p_dagitim_id;

    if not found then return 0; end if;

    -- Taslak satirlari temizle (kesinlesmislere dokunma).
    delete from public.hakedis_satir
     where dagitim_id = p_dagitim_id and durum = 1;

    -- Iptal edilmis ya da gerceklesmemis tahsilat prim uretmez.
    if coalesce(d.durum, 0) <> 2 or d.iptal_islem_id is not null then
        return 0;
    end if;

    -- PRIM TABANI: dagitilan tutarin KDV'siz karsiligi (323 karari).
    v_matrah := round(d.tutar / (1 + coalesce(d.kdv, 0) / 100.0), 4);
    v_belgetur := public.fn_prim_belge_turu(d.belge_satir_id);
    v_kurum := d.odeyen_kurum_id;
    v_sube := d.sube_id;
    v_tarih := d.tarih;

    select h.modalite into v_modalite from public.hizmet h where h.id = d.hizmet_id;

    for r in select br.rol, br.taraf_id, br.pay_yuzde
               from public.belge_satir_rol br
              where br.belge_satir_id = d.belge_satir_id
    loop
        select * into kural
          from public.fn_prim_plan_satiri(r.rol, r.taraf_id, d.hizmet_id, v_modalite,
                                          v_belgetur, d.pay, v_kurum, v_sube, v_tarih);
        if not found then continue; end if;

        v_tutar := case when kural.oran_tipi = 2
                        then kural.deger
                        else round(v_matrah * kural.deger / 100.0, 2) end;
        v_tutar := round(v_tutar * coalesce(r.pay_yuzde, 100) / 100.0, 2);

        if kural.alt_sinir is not null and v_tutar < kural.alt_sinir then
            v_tutar := kural.alt_sinir;
        end if;
        if kural.ust_sinir is not null and v_tutar > kural.ust_sinir then
            v_tutar := kural.ust_sinir;
        end if;
        if v_tutar <= 0 then continue; end if;

        insert into public.hakedis_satir
               (taraf_id, rol, dagitim_id, belge_satir_id, plan_id, plan_satir_id,
                tarih, belge_tur, pay, taban, oran_tipi, deger, pay_yuzde, tutar, durum)
        values (r.taraf_id, r.rol, p_dagitim_id, d.belge_satir_id,
                kural.plan_id, kural.satir_id, v_tarih, v_belgetur, d.pay,
                v_matrah, kural.oran_tipi, kural.deger,
                coalesce(r.pay_yuzde, 100), v_tutar, 1)
        -- Kismi benzersiz indeks (dagitim_id is not null) hedeflenirken
        --   AYNI kosul yazilmali - yoksa PG indeksi eslestiremez.
        on conflict (dagitim_id, taraf_id, rol) where dagitim_id is not null
        do update set tutar = excluded.tutar, taban = excluded.taban,
                      deger = excluded.deger, belge_tur = excluded.belge_tur,
                      plan_id = excluded.plan_id, plan_satir_id = excluded.plan_satir_id
        -- DONDURULMUS satira dokunma: donemi kapanmis hakedis yeniden
        --   hesaplanmaz, fark sonraki doneme duzeltme olarak girer.
        where hakedis_satir.durum = 1;

        v_sayac := v_sayac + 1;
    end loop;

    return v_sayac;
end $$;

-- ================================================== istemden rol türetme ===
create or replace function public.fn_rad_rol_tazele(p_istem_id integer)
returns integer language plpgsql as $$
declare
  v_satir  integer;
  v_hedef  jsonb;
  v_sayac  integer := 0;
  r        record;
begin
    select i.belge_satir_id into v_satir
      from public.radyoloji_istem i where i.id = p_istem_id;

    -- Istem henuz ucretlendirilmemis (kalemi yok): prim bagi kurulamaz.
    --   Kalem sonradan olusunca tetik yeniden calisir.
    if coalesce(v_satir, 0) = 0 then return 0; end if;

    select coalesce(jsonb_agg(jsonb_build_object('rol', h.rol, 'taraf', h.taraf_id)),
                    '[]'::jsonb)
      into v_hedef
      from (
        -- Istek hekimi: DIS hekimse "Gönderen", kurum personeliyse "İsteyen".
        select case when exists (select 1 from public.taraf_personel p
                                  where p.id = i.istek_hekim_id and p.dis_hekim = 1)
                    then 1 else 2 end   as rol,
               i.istek_hekim_id         as taraf_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.istek_hekim_id is not null
        union all
        -- Sevk eden KURUM yalniz hekim yokken gonderen sayilir: ikisi birden
        --   yazilirsa ayni sevk icin iki kez prim doğar.
        select 1, i.istek_kurum_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.istek_hekim_id is null
           and i.istek_kurum_id is not null
        union all
        select 9, i.tekniker_id
          from public.radyoloji_istem i
         where i.id = p_istem_id and i.tekniker_id is not null
        union all
        -- Rapor: ANA rapor (ust_rapor_id bos). Ek rapor primi ayri yazilmaz.
        select 5, rp.yazan_id
          from public.radyoloji_rapor rp
         where rp.istem_id = p_istem_id and rp.ust_rapor_id is null
           and rp.yazan_id is not null
        union all
        select 6, rp.onaylayan_id
          from public.radyoloji_rapor rp
         where rp.istem_id = p_istem_id and rp.ust_rapor_id is null
           and rp.onaylayan_id is not null
      ) h;

    -- ELLE girilmis rol DOKUNULMAZ: o rolde kaynak=1 satir varsa hem silme
    --   hem ekleme atlanir (kullanici bilerek duzeltmis olabilir).
    delete from public.belge_satir_rol bsr
     where bsr.belge_satir_id = v_satir
       and bsr.kaynak = 2
       and not exists (select 1
                         from jsonb_to_recordset(v_hedef) as x(rol smallint, taraf integer)
                        where x.rol = bsr.rol and x.taraf = bsr.taraf_id)
       and not exists (select 1 from public.belge_satir_rol e
                        where e.belge_satir_id = v_satir and e.rol = bsr.rol
                          and e.kaynak = 1);

    insert into public.belge_satir_rol (belge_satir_id, rol, taraf_id, pay_yuzde, kaynak)
    select v_satir, x.rol, x.taraf, 100, 2
      from jsonb_to_recordset(v_hedef) as x(rol smallint, taraf integer)
     where not exists (select 1 from public.belge_satir_rol e
                        where e.belge_satir_id = v_satir and e.rol = x.rol
                          and e.kaynak = 1)
    on conflict (belge_satir_id, rol, taraf_id) do nothing;

    get diagnostics v_sayac = row_count;

    -- Rol degisti: kalemin AÇIK primleri yeniden uretilir.
    for r in select d.id from public.kasa_islem_dagitim d
              where d.belge_satir_id = v_satir
    loop
        perform public.fn_prim_uret(r.id);
    end loop;

    return v_sayac;
end $$;

comment on function public.fn_rad_rol_tazele is
  'Radyoloji isteminden kalemin prim rollerini turetir (326); elle girilen rolu ezmez.';

-- ------------------------------------------------------------- tetikler ---
create or replace function public.tg_rad_rol_istem()
returns trigger language plpgsql as $$
begin
    perform public.fn_rad_rol_tazele(new.id);
    return null;
end $$;

drop trigger if exists tr_rad_rol_istem on public.radyoloji_istem;
create trigger tr_rad_rol_istem
  after insert or update of belge_satir_id, istek_hekim_id, istek_kurum_id, tekniker_id
  on public.radyoloji_istem
  for each row execute function public.tg_rad_rol_istem();

create or replace function public.tg_rad_rol_rapor()
returns trigger language plpgsql as $$
begin
    perform public.fn_rad_rol_tazele(new.istem_id);
    return null;
end $$;

drop trigger if exists tr_rad_rol_rapor on public.radyoloji_rapor;
create trigger tr_rad_rol_rapor
  after insert or update of yazan_id, onaylayan_id, durum on public.radyoloji_rapor
  for each row execute function public.tg_rad_rol_rapor();

-- ---------------------------------------------------------- geri dolgu ----
-- Mevcut istemler icin bir kez calistirilir. Idempotent: ayni rol tekrar
-- yazilmaz, elle girilen korunur, kesinlesmis hakedis satiri degismez.
do $$
declare r record;
begin
    for r in select i.id from public.radyoloji_istem i
              where i.belge_satir_id is not null
    loop
        perform public.fn_rad_rol_tazele(r.id);
    end loop;
end $$;
