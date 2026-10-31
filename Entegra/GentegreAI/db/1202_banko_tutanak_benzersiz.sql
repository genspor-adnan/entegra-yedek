-- ============================================================================
--  1202 — Banko oturumu: tutanak numarası benzersiz
--
--  Kod inceleme raporu 30.10.2026 K14: `TutanakNoAsync` tutanak numarasını
--  `max + 1` ile üretiyordu; iki eş zamanlı kapanış aynı numarayı alabiliyordu.
--  Uygulama tarafı artık transaction ömürlü danışma kilidi
--  (`pg_advisory_xact_lock(hashtext('banko_tutanak'))`) ile sıralıyor; bu
--  dosya KALICI güvenceyi koyar: `banko_oturum.tutanak_no` dolu olduğu yerde
--  kısmi benzersiz indeks (boş '' = henüz tutanak kesilmemiş, kısıta girmez).
--
--  İDEMPOTENT ve VERİ DEĞİŞTİRMEZ: tabloda zaten tekrarlı tutanak varsa indeks
--  OLUŞTURULMAZ (hata vermez), çakışan satırlar aşağıdaki SELECT ile listelenir;
--  onlar elle (yetkili kişi hangisinin doğru olduğuna karar vererek) düzeltilir
--  ve dosya yeniden çalıştırılır.
-- ============================================================================
\set ON_ERROR_STOP on
begin;

do $$
declare
    v_cakisan int;
begin
    select count(*) into v_cakisan
      from (select o.tutanak_no
              from public.banko_oturum o
             where o.tutanak_no <> ''
             group by o.tutanak_no
            having count(*) > 1) x;

    if v_cakisan > 0 then
        raise notice '1202: % tekrarlı tutanak_no var; banko_oturum_tutanak_ux OLUŞTURULMADI. Çakışanlar aşağıdaki listede - düzeltip dosyayı yeniden çalıştırın.', v_cakisan;
    else
        create unique index if not exists banko_oturum_tutanak_ux
            on public.banko_oturum (tutanak_no)
         where tutanak_no <> '';
        comment on index public.banko_oturum_tutanak_ux is
          '1202 (K14): tutanak no dolu olduğu yerde benzersiz; '''' (kesilmemiş) kısıta girmez.';
    end if;
end $$;

-- Çakışan tutanaklar (varsa) - YALNIZ BİLGİ, hiçbir satır değiştirilmez.
select o.tutanak_no, count(*) as adet,
       string_agg(o.id::text, ', ' order by o.id) as oturumlar
  from public.banko_oturum o
 where o.tutanak_no <> ''
 group by o.tutanak_no
having count(*) > 1
 order by o.tutanak_no;

commit;
