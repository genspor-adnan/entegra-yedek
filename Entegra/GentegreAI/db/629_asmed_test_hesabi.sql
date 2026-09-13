-- =====================================================================
--  629_asmed_test_hesabi.sql
--  ANADOLU SİGORTA / ASMED TEST HESABI — iskelet.
--
--  Adapter (430) ve sağlayıcı kaydı hazırdı ama hesap yoktu: provizyon
--  istendiğinde "Bu kurum için sigorta entegrasyon hesabı tanımlı değil"
--  ile düşüyordu. Bu göç bağlantı kaydını ve kurum eşleşmesini kurar.
--
--  KİMLİK BİLGİLERİ BURADA YOK. Kullanıcı adı, parola ve client_secret
--  göçe yazılmaz - göç dosyası dağıtılan bir şeydir ve her kurulumun
--  kendi hesabı vardır. Değerler kurulumda Entegrasyon ekranından girilir;
--  geliştirme makinesinde test bilgileri ayrıca yüklenir
--  (`Sigorta/Asmed/Web Servisler.txt`).
-- =====================================================================

insert into public.entegrasyon_hesap
       (kod, ad, url, test_url, test_mi, aktif, kullanici_adi, sifre,
        uygulama_kodu, kurum_kodu, ayarlar)
values ('ASMED', 'Anadolu Sigorta (ASMED)',
        'https://api.anadolusigorta.com.tr/api/agency',
        'https://apitest.anadolusigorta.com.tr/api/agency',
        1, 1, '', '', '', '', '{}'::jsonb)
on conflict do nothing;

-- Sağlayıcı aktif olmalı: kapalı sağlayıcı uçlarda hiç görünmez.
-- DURUM 0 = AKTİF, 1 = PASİF (430). Ters yazmak hesabı sessizce kapatır:
--   `HesapCozAsync` `durum = 0` süzer ve "Bu kurum için sigorta entegrasyon
--   hesabı tanımlı değil" der - kimlik bilgileri doğru olsa bile.
update public.sigorta_saglayici set durum = 0 where kod = 'ANADOLU_ASMED';

do $$
declare v_saglayici smallint; v_hesap integer; v_kurum integer;
begin
    select id into v_saglayici from public.sigorta_saglayici where kod = 'ANADOLU_ASMED';
    select id into v_hesap from public.entegrasyon_hesap where kod = 'ASMED' limit 1;

    -- ÖSS kurumu (tur 2) ile eşleşme: hangi kurumun hastası için ASMED'e
    --   sorulacağını bu bağ söyler. Kurum yoksa bağ kurulmaz - test
    --   kurulumunda kurum kartından seçilir.
    select t.id into v_kurum
      from public.taraf t join public.taraf_kurum k on k.id = t.id
     where k.tur = 2 and t.unvan ilike '%anadolu%' limit 1;

    if v_kurum is null or v_hesap is null then
        raise notice '629: ASMED hesabi kuruldu, kurum eslesmesi ELLE yapilacak '
                   '(Anadolu Sigorta kurumu bulunamadi).';
        return;
    end if;

    insert into public.sigorta_hesap
           (saglayici_id, kurum_id, hesap_id, sube_id, varsayilan, durum, aciklama)
    values (v_saglayici, v_kurum, v_hesap, null, 1, 0, 'ASMED test')
    on conflict do nothing;
    raise notice '629 tamam: ASMED hesabi kurum % ile eslesti', v_kurum;
end $$;
