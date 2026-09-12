-- =====================================================================
--  584_basvuru_yapan_primi.sql
--  MUAYENE kaleminde "Yapan" primi BAŞVURUNUN HEKİMİNE otomatik yazılır.
--
--  Kullanıcı: "ücretlemede muayene kategorisi geldiğinde bu başvurudaki
--  hekim otomatik olarak yapan primi alacaktır.. eğer yapan prim planında
--  varsa."
--
--  Bilgi ZATEN başvuruda duruyor (belge_basvuru.personel_id) - hastayı gören
--  hekim odur. Ücretlemede aynı kişiyi bir de kalem rolü olarak seçtirmek hem
--  angarya hem unutulunca sessiz prim kaybı. Radyolojideki desenin (326)
--  muayene karşılığı.
--
--  KURALLAR (326 ile aynı):
--    1) ELLE GİRİLEN EZİLMEZ: kalemde kaynak=1 (elle) bir "Yapan" satırı
--       varsa o kaleme hiç dokunulmaz.
--    2) Hekim DEĞİŞİRSE otomatik satır (kaynak=2) takip eder; eski hekimin
--       otomatik satırı silinir.
--    3) Rol değişince kalemin AÇIK primleri yeniden üretilir; dönemi kapanmış
--       hakediş dondurulmuştur.
--
--  İKİ EK ŞART:
--    · PLAN OLMALI (kullanıcı: "eğer yapan prim planında varsa"): o tarihte
--      geçerli, hekimi kapsayan, şubesi uyan ve KALEME denk gelen bir
--      "Yapan" planı yoksa rol yazılmaz - rol satırı prim demektir, plansız
--      rol hakedişte karşılıksız durur.
--    · DIŞ HEKİME YAZILMAZ: dış hekim yalnız "Gönderen" rolünde prim alır
--      (361 tetiği bunu zorluyor). Görüntüleme/lab profilinde başvurunun
--      hekimi dış hekimdir; orada muayene primi kavramı yoktur.
--
--  Kategori adı ile bulunur ("Muayene…"), id sabitlenmez: müşteri kategori
--  ağacını kendi kurar.
-- =====================================================================

-- ============================================ plan var mı (kalem bazında) ===
-- fn_prim_plan_satiri TAM eşleşme arar (pay, tahsilat türü, belge türü);
--   burada sorulan soru daha genel: "bu hekime bu kalem için Yapan planı
--   TANIMLI MI". Pay/tahsilat ayrıntısı tahsilat anında belli olur - rol
--   yazılırken bilinmiyor, o yüzden kapsamın yalnız SABİT parçası bakılır.
create or replace function public.fn_prim_rol_plani_var(
    p_rol smallint, p_taraf_id integer, p_hizmet_id integer,
    p_kurum_id integer, p_sube_id integer, p_tarih date)
returns boolean language sql stable as $$
    select exists (
        select 1
          from public.prim_plani p
          join public.prim_plani_satir s on s.plan_id = p.id
         where coalesce(p.durum, 1) = 1
           and p.rol = p_rol
           and p.baslangic <= p_tarih
           and (p.bitis is null or p.bitis >= p_tarih)
           -- Plan KİŞİYE bağlanmışsa yalnız o kişiler (375).
           and (not exists (select 1 from public.prim_plani_taraf t
                             where t.plan_id = p.id)
                or exists (select 1 from public.prim_plani_taraf t
                            where t.plan_id = p.id and t.taraf_id = p_taraf_id))
           and (coalesce(p.odeyen_kurum_id, 0) = 0 or p.odeyen_kurum_id = p_kurum_id)
           and (coalesce(p.sube_id, 0) = 0 or p.sube_id = p_sube_id)
           -- Kapsam: 1 = tüm kalemler, 2 = kategori (alt dallar dahil, 558),
           --   3 = tek hizmet.
           and (s.tip = 1
                or (s.tip = 2 and coalesce(s.kalem_turu, 0) in (0, 2)
                    and s.hedef_id in (select z.id from public.fn_kategori_ust_zinciri(
                                              (select h.kategori from public.hizmet h
                                                where h.id = p_hizmet_id)) z))
                or (s.tip = 3 and coalesce(s.kalem_turu, 0) in (0, 2)
                    and s.hedef_id = p_hizmet_id)));
$$;

comment on function public.fn_prim_rol_plani_var(smallint, integer, integer,
                                                 integer, integer, date) is
  'Bu kişiye bu kalem için o rolde prim planı tanımlı mı (584).';

-- ============================================== başvurudan Yapan rolü ===
create or replace function public.fn_basvuru_yapan_rolu(p_belge_id integer)
returns integer language plpgsql as $$
declare
    b        record;
    s        record;
    r        record;
    v_dis    smallint;
    v_sayac  integer := 0;
begin
    select bl.id, bl.sube_id, bl.belge_tarihi::date as tarih,
           bb.personel_id, bb.odeyen_kurum_id
      into b
      from public.belge bl
      join public.belge_basvuru bb on bb.id = bl.id
     where bl.id = p_belge_id;

    if not found then return 0; end if;

    -- DIŞ HEKİM: yalnız "Gönderen" rolünde prim alabilir (361) - otomatik
    --   Yapan yazmak tetiği patlatır, kalem hiç kaydedilemezdi.
    select coalesce(p.dis_hekim, 0) into v_dis
      from public.taraf_personel p where p.id = b.personel_id;

    for s in
        select bs.id, bs.hizmet_id
          from public.belge_satir bs
          join public.hizmet h on h.id = bs.hizmet_id
         where bs.belge_id = p_belge_id
           and exists (select 1
                         from public.fn_kategori_ust_zinciri(h.kategori) z
                         join public.kategori k on k.id = z.id
                        where public.fn_ara_metin(k.ad) like 'muayene%')
    loop
        -- ELLE GİRİLEN ROL YÖNETİLMEZ.
        if exists (select 1 from public.belge_satir_rol e
                    where e.belge_satir_id = s.id and e.rol = 4 and e.kaynak = 1) then
            continue;
        end if;

        -- Hekim değişti / kalktı: eski otomatik satır gider.
        delete from public.belge_satir_rol bsr
         where bsr.belge_satir_id = s.id and bsr.rol = 4 and bsr.kaynak = 2
           and (b.personel_id is null or bsr.taraf_id <> b.personel_id);

        if b.personel_id is null or coalesce(v_dis, 0) = 1 then
            continue;
        end if;

        -- PLAN YOKSA ROL DE YOK.
        if not public.fn_prim_rol_plani_var(4::smallint, b.personel_id, s.hizmet_id,
                                            b.odeyen_kurum_id, b.sube_id, b.tarih) then
            continue;
        end if;

        insert into public.belge_satir_rol (belge_satir_id, rol, taraf_id, pay_yuzde, kaynak)
        values (s.id, 4, b.personel_id, 100, 2)
        on conflict (belge_satir_id, rol, taraf_id) do nothing;

        v_sayac := v_sayac + 1;

        -- Rol değişti: kalemin AÇIK primleri yeniden üretilir (326 deseni).
        for r in select d.id from public.kasa_islem_dagitim d
                  where d.belge_satir_id = s.id
        loop
            perform public.fn_prim_uret(r.id);
        end loop;
    end loop;

    return v_sayac;
end $$;

-- ===================================================== tetikler ===
-- Kalem eklenince/hizmeti değişince o belgenin muayene kalemleri tazelenir.
create or replace function public.tg_basvuru_yapan_satir()
returns trigger language plpgsql as $$
begin
    if new.hizmet_id is not null then
        perform public.fn_basvuru_yapan_rolu(new.belge_id);
    end if;
    return null;
end $$;

drop trigger if exists tr_basvuru_yapan_satir on public.belge_satir;
create trigger tr_basvuru_yapan_satir
    after insert or update of hizmet_id on public.belge_satir
    for each row execute function public.tg_basvuru_yapan_satir();

-- Başvurunun hekimi değişince tüm muayene kalemleri yeni hekime geçer.
create or replace function public.tg_basvuru_yapan_hekim()
returns trigger language plpgsql as $$
begin
    perform public.fn_basvuru_yapan_rolu(new.id);
    return null;
end $$;

drop trigger if exists tr_basvuru_yapan_hekim on public.belge_basvuru;
create trigger tr_basvuru_yapan_hekim
    after insert or update of personel_id on public.belge_basvuru
    for each row execute function public.tg_basvuru_yapan_hekim();
