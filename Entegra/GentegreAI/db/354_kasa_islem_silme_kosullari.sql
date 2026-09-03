-- ============================================================================
--  354 - TAHSILAT/ODEME SILME KOSULLARI
--
--  Kullanici: "tahsilat silemedim.. dönüşüm hiç yoksa silebilmem lazım".
--
--  076'daki koruma "durum >= 2 (gerçekleşti) ise silinemez" diyordu. Tahsilat
--  kaydedilir kaydedilmez durum 2 oldugu icin, yanlis girilen bir POS/nakit
--  tahsilati HIC silinemiyor, yalnizca iptal edilebiliyordu - basvuru daha
--  hicbir belgeye donusmemisken bile.
--
--  Yeni kural: gerceklesmis islem de SILINEBILIR; silmeyi engelleyen sey
--  isleme BAGLANMIS IZLER'dir:
--    * muhasebe fisi yazilmis          (fis kaydi degistirilemez)
--    * islem iptal edilmis / ters kaydi var (iptal kaydi islemin izidir)
--    * tahsilattan ONAYLI ya da ODENMIS prim uretilmis (hakedis_satir.durum >= 3)
--    * tahsilatin belgesi fis/fatura/tahakkuka DONUSMUS
--    * cek/senet ya da kredi taksiti bagli (kiymet portfoyde izleniyor)
--    * baska bir islem bunu PLAN olarak gosteriyor
--  Hicbiri yoksa silme serbesttir: mali_hareket ve kasa_islem_dagitim
--  (dolayisiyla taslak/kesin prim satirlari) zincirleme silinir.
--
--  Silmeden sonra satirlarin tahsil edilen tutari yeniden hesaplanir - eskiden
--  bunu yalnizca UPDATE tetigi yapiyordu, DELETE yolunda sayaclar eski kaliyordu.
-- ============================================================================

create or replace function public.fn_kasa_islem_silme_koruma()
returns trigger
language plpgsql
as $$
declare
    v_fis  record;
begin
    -- Prim: taslak (1) ve kesin (2) satirlar tahsilatla birlikte silinir;
    --   onayli (3) ve odenmis (4) satir hakedise girmistir, dokunulmaz.
    if exists (select 1
                 from public.hakedis_satir h
                 join public.kasa_islem_dagitim d on d.id = h.dagitim_id
                where d.kasa_islem_id = old.id and h.durum >= 3) then
        raise exception 'Bu tahsilattan onaylanmış/ödenmiş prim üretilmiş; işlem silinemez - İptal kullanın (işlem %).',
              old.id using errcode = 'GK422';
    end if;

    -- Belge donusmusse tahsilat o zincirin parcasidir: once turetilen belge silinir.
    if old.belge_id is not null
       and exists (select 1
                     from public.belge_satir hs
                     join public.belge_satir ks
                       on ks.id = hs.kaynak_id and hs.kaynak_tur = 30
                    where ks.belge_id = old.belge_id) then
        raise exception 'Bu tahsilatın belgesi fiş/faturaya dönüştürülmüş; önce türetilen belgeyi silin ya da tahsilatı İptal edin (işlem %).',
              old.id using errcode = 'GK422';
    end if;

    if exists (select 1 from public.cek_senet_hareket where kasa_islem_id = old.id)
       or exists (select 1 from public.cek_senet where giris_kasa_islem_id = old.id) then
        raise exception 'Çek/senet hareketi olan işlem silinemez; kıymet portföyde izleniyor (işlem %).',
              old.id using errcode = 'GK422';
    end if;

    if exists (select 1 from public.kredi_taksit where kasa_islem_id = old.id) then
        raise exception 'Kredi taksitine bağlı işlem silinemez (işlem %).',
              old.id using errcode = 'GK422';
    end if;

    if exists (select 1 from public.kasa_islem where plan_islem_id = old.id) then
        raise exception 'Bu işlem başka bir işlemin planı; önce gerçekleşen işlemi silin (işlem %).',
              old.id using errcode = 'GK422';
    end if;

    -- MUHASEBE FISI: kasa isleminden TURER, kendi basina bir kayit degildir.
    --   Fis disa aktarilmamis, ters fisle iptal edilmemis ve donemi kilitsizse
    --   islemle birlikte silinir (asagida). Aksi halde silme engellenir.
    if old.muhasebe_fis_id is not null then
        select f.durum, f.disa_aktarim_durum,
               coalesce((select d.kilitli from public.muhasebe_donem d
                          where d.id = f.donem_id), 0) as donem_kilitli
          into v_fis
          from public.muhasebe_fis f
         where f.id = old.muhasebe_fis_id;

        if v_fis.durum is not null and v_fis.durum <> 1 then
            raise exception 'İşlemin muhasebe fişi ters fişle iptal edilmiş; işlem silinemez (işlem %).',
                  old.id using errcode = 'GK422';
        end if;
        if coalesce(v_fis.disa_aktarim_durum, 0) <> 0 then
            raise exception 'İşlemin muhasebe fişi dışa aktarılmış; işlem silinemez - İptal kullanın (işlem %).',
                  old.id using errcode = 'GK422';
        end if;
        if coalesce(v_fis.donem_kilitli, 0) <> 0 then
            raise exception 'İşlemin muhasebe fişi KİLİTLİ döneme ait; işlem silinemez (işlem %).',
                  old.id using errcode = 'GK422';
        end if;
    end if;

    if old.durum = 3 or old.iptal_islem_id is not null then
        raise exception 'İptal edilmiş işlem silinemez; iptal kaydı işlemin izidir (işlem %).',
              old.id using errcode = 'GK422';
    end if;


    return old;
end $$;

comment on function public.fn_kasa_islem_silme_koruma() is
  'Kasa islemi silme kosullari (354): gerceklesmis islem de silinebilir; '
  'disa aktarilmis/iptal edilmis ya da kilitli donemdeki muhasebe fisi, iptal kaydi, '
  'onayli-odenmis prim, belge donusumu, cek-senet, kredi taksiti ya da plan bagi '
  'varsa engellenir. Engel yoksa turemis muhasebe fisi de birlikte silinir.';

-- ============================================================ tazeleme ======
-- Dagitim satiri silinince (kasa islemi silindiginde zincirleme gelir) belge
-- satirinin tahsil edilen tutari yeniden hesaplanir; aksi halde "tahsil edilen"
-- silinen tahsilati saymaya devam ediyordu.
create or replace function public.tg_kasa_dagitim_sil_tazele()
returns trigger
language plpgsql
as $$
begin
    perform public.fn_belge_satir_tahsil_tazele(old.belge_satir_id);
    return null;
end $$;

drop trigger if exists tr_kasa_dagitim_sil_tazele on public.kasa_islem_dagitim;
create trigger tr_kasa_dagitim_sil_tazele after delete on public.kasa_islem_dagitim
    for each row execute function public.tg_kasa_dagitim_sil_tazele();

-- ===================================================== turemis fisin silinmesi =
-- Muhasebe fisi BEFORE DELETE'te silinemez: kasa_islem.muhasebe_fis_id FK'si
-- (RESTRICT) satir hala dururken fise dokunmayi engelliyor
-- ("violates foreign key constraint fk_kasa_islem_fis"). Uygunluk kontrolu
-- BEFORE'da yapilir, fisin kendisi islem silindikten SONRA silinir - yoksa
-- kasa islemi gider, fisi yetim kalirdi.
create or replace function public.tg_kasa_islem_sil_fis()
returns trigger
language plpgsql
as $$
begin
    if old.muhasebe_fis_id is not null then
        delete from public.muhasebe_fis where id = old.muhasebe_fis_id;
    end if;
    return null;
end $$;

drop trigger if exists tr_kasa_islem_sil_fis on public.kasa_islem;
create trigger tr_kasa_islem_sil_fis after delete on public.kasa_islem
    for each row execute function public.tg_kasa_islem_sil_fis();
