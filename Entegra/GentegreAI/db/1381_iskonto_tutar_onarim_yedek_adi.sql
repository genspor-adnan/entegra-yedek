-- =============================================================================
--  1381 - İSKONTO TUTAR ONARIMI: YEDEK TABLOSU UYGULAMA ROLÜNE AÇIK AD + İŞARETİ SIFIRLA
--
--  Yayın 18.11.2026 (görüntüleme): API sunucuda kısıtlı uygulama rolüyle (<db>_uyg) bağlanır ve yayın betiği
--  `_yedek_*` tablolarını bu role BİLEREK kapatır (uygulama-rolu.sql, kod inceleme 30.10.2026 K82). 1378'in
--  `_yedek_iskonto_tutar_1378` tablosuna onarımın yedek yazması "permission denied" ile düştü, onarım yapılamadı ama
--  "bir kez çalıştı" işareti yazıldı (görüntüleme başvuru 4056 düzeltilmeden kaldı).
--
--  Tablo uygulamanın iş tablosudur (onarımın kendi yedeği), göç yedeği değil: `iskonto_tutar_onarim_yedek` adını alır
--  - her yayında verilen "bütün tablolarda select / insert ..." hakkı ona da gelir. Hatalı yazılmış işaret silinir:
--  onarım bir sonraki açılışta yeniden çalışır (idempotent - yalnız hesabı tutmayan satıra dokunur). Kod artık
--  işareti yalnız hatasız turda yazar. İdempotent.
-- =============================================================================
begin;
do $$ begin
  if to_regclass('public._yedek_iskonto_tutar_1378') is not null
     and to_regclass('public.iskonto_tutar_onarim_yedek') is null then
    alter table public._yedek_iskonto_tutar_1378 rename to iskonto_tutar_onarim_yedek;
  end if;
end $$;
create table if not exists public.iskonto_tutar_onarim_yedek (
    id               bigserial primary key,
    tarih            timestamptz not null default now(),
    talep_id         integer not null,
    belge_id         integer not null,
    belge_satir_id   integer not null,
    eski_tutar       numeric,
    eski_tutar_kdvli numeric,
    eski_doviz_tutari numeric,
    eski_dagilim     jsonb,
    eski_genel_toplam numeric
);
comment on table public.iskonto_tutar_onarim_yedek is
  '1378/1381: IskontoTutarOnarici dokunmadan önceki satır / dağılım / dip toplam (iskonto kararı tutarı yenilemiyordu)';
delete from public.referans where anahtar = 'sistem.iskonto_tutar_onarim_1378';
commit;
