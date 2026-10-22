-- =============================================================================
--  1149  DELPHI AKTARIMI - EK MODÜLLERİN TOPLU ÇAĞRISI  (db/araclar/aktar_ek.ps1)
--
--  stg tabloları (1143) dolduktan sonra ek modülleri BAĞIMLILIK SIRASIYLA
--  aktarır: önce kişiler (kullanıcı / personel / ilgili kişi - görev sorumlusu,
--  döküman sahibi bunlara bağlanır), sonra hesap planı, demirbaş, çek/senet,
--  teklif, görev/aktivite, döküman/ek, e-Belge (döküman bağları görevlere,
--  e-Belge faturalara bağlanır). Her modül kendi kurtarma noktasında: biri hata
--  verirse geri alınır, hata metni sonuçta görünür, diğerleri yine aktarılır.
--  Tekrar çalıştırmak güvenli (her modül idempotent).
-- =============================================================================

begin;

create or replace function public.fn_aktar_ek()
returns jsonb language plpgsql as $$
declare
    v_sonuc jsonb := '{}';
    v_m text;
    v_r jsonb;
begin
    perform set_config('gentegre.aktarim', '1', true);
    foreach v_m in array array['kisi', 'hesap_plani', 'demirbas', 'cek', 'teklif', 'gorev', 'dokuman', 'ebelge'] loop
        begin
            execute format('select public.fn_aktar_ek_%s()', v_m) into v_r;
            v_sonuc := v_sonuc || jsonb_build_object(v_m, v_r);
        exception when others then
            v_sonuc := v_sonuc || jsonb_build_object(v_m, jsonb_build_object('hata', sqlerrm));
        end;
    end loop;
    return v_sonuc;
end $$;

comment on function public.fn_aktar_ek() is
    '1149: Delphi ek modülleri (stg, 1143) sırayla aktarır - kişi, hesap planı, demirbaş, çek, teklif, görev, döküman, e-Belge. Modül hatası diğerlerini durdurmaz.';

commit;
