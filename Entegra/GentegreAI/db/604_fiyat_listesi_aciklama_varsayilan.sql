-- =====================================================================
--  604_fiyat_listesi_aciklama_varsayilan.sql
--  `fiyat_listesi.aciklama` BOS BIRAKILABILSIN (not null default '').
--
--  Kolon NOT NULL ama VARSAYILANSIZ kalmis: aciklama yazmadan liste acan her
--  insert 23502 ile patliyordu. Semanin geri kalaninda desen su:
--
--      aciklama varchar(300) not null default ''::character varying
--
--  (kurum_sozlesme, taraf_hasta_kurum, kampanya ... hepsi boyle). Aciklama
--  istege bagli bir alandir - zorunlu olan "null olmamasi", "yazilmis olmasi"
--  degil.
--
--  NASIL ORTAYA CIKTI: api/tests/Gentegre.Testler icindeki 46 test bu satirda
--  düşüyordu (`DagilimAkisTestleri`, `SutBedeliTestleri` ve onlarla ayni
--  olguyu paylasan sinifllar). Test kurulumu aciklama gondermiyordu - ki
--  gondermek ZORUNDA da degil; kusur semada.
--
--  `ad` bilerek varsayilansiz KALIYOR: adsiz fiyat listesi anlamsizdir, orada
--  hatanin cikmasi dogru. `baslangic`/`bitis` de oyle - 541 donemi BILEREK
--  zorunlu kildi ("başlama-bitiş alanları zorunlu olsun"), varsayilan vermek o
--  karari sessizce geri alirdi.
-- =====================================================================

-- Once mevcut null'lar (kolon NOT NULL oldugu icin olmamali, yine de guvenli).
update public.fiyat_listesi set aciklama = '' where aciklama is null;

alter table public.fiyat_listesi
  alter column aciklama set default ''::character varying;

do $$
declare v_var boolean;
begin
    select column_default is not null into v_var
      from information_schema.columns
     where table_name = 'fiyat_listesi' and column_name = 'aciklama';
    raise notice '604 tamam: fiyat_listesi.aciklama varsayilani kuruldu mu -> %', v_var;
end $$;
