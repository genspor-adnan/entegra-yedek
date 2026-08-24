-- ============================================================================
--  Gentegre AI — PLAN HAREKETLERI CARI EKSTRESINDEN CIKARILIR
--  113_plan_satirlari_ekstre_disi.sql
--
--  Tahsilat/Odeme/Avans PLANI (kasa_islem_turu 61/71/63) hareketleri cari
--  ekstresinde gorunuyor ama BAKIYEYE GIRMIYORDU (bakiye_dahil = 0). Sonuc:
--  ekstrede borc toplami ile kapanis bakiyesi TUTMUYORDU - ornek BIMED carisi,
--  TL grubunda borc toplami 545.126,41 iken bakiye 545.126,01 (aradaki fark
--  bes plan satiri). Kullanici karari: planlar ekstreden cikar.
--
--  Plan bir NIYETTIR, gerceklesmis bir hareket degil: tahsil edildiginde YENI
--  bir baslik acilir (plan_islem_id ile plana baglanir), plan satiri oldugu
--  yerde kalir. Ekstre gerceklesmis hareketlerin dokumudur; niyet satirlari
--  toplamlari kirletiyor ve "bu para tahsil edilmis" izlenimi veriyordu.
--
--  Planlar KAYBOLMAZ: hareketleri "Kasa Hareketleri" (mali-hareket) listesinde
--  ve kendi baslik listesinde (kasa-islem, plan cipi) durur; vade takibi icin
--  ayri bir vade listesi planlanmistir.
--
--  Kaldirma yolu (istenirse): ayni satirlarda cari_ekstre = 1 yapmak yeterli.
-- ============================================================================
\set ON_ERROR_STOP on

do $$
declare v_tur integer; v_satir integer;
begin
    select count(*) into v_satir
      from public.mali_hareket m
      join public.kasa_islem_turu t on t.kod = m.tur
     where t.grup = 'plan' and t.cari_ekstre = 1 and m.hesap_turu = 'C';

    update public.kasa_islem_turu
       set cari_ekstre = 0
     where grup = 'plan' and cari_ekstre = 1;

    get diagnostics v_tur = row_count;
    raise notice '113 tamam: % plan turu ekstre disi birakildi, % cari hareket satiri listeden cikti',
                 v_tur, v_satir;
end $$;
