-- ============================================================================
--  Gentegre AI — ONAYLI (KİLİTLİ) SATIR DEĞİŞTİRİLEMEZ VE SİLİNEMEZ
--  681_iskonto_kilit_koruma.sql
--
--  Kullanıcı: "kilitlenmiş satırların silme/değişme yapılamaması lazım."
--
--  673'te kilit yalnız ÜÇ alanı koruyordu: iskonto, iskonto2, birim fiyat.
--  Oysa onay bir TUTARA verilir - aynı satırın ADEDİNİ 1'den 5'e çıkarmak ya da
--  satırı silip yenisini eklemek, onaylanan indirimi başka bir tutara taşır.
--  Yetkilinin gördüğü rakam ile tahsil edilen rakam ayrışır ve denetim izi
--  (iskonto_talep_satir) artık var olmayan bir satırı gösterir.
--
--  Koruma tutarı belirleyen HER alanı kapsar; açıklama/teslim tarihi gibi
--  tutara dokunmayan alanlar serbest kalır - onay bir fiyat kararıdır, satırın
--  notunu düzeltmeyi yasaklamak gereksiz sertlik olurdu.
--
--  SİLME: tek satırın silinmesi engellenir, BELGENİN tamamen silinmesi değil.
--  Ayrım `pg_trigger_depth()` ile: doğrudan DELETE'te derinlik 1, belge
--  silindiğinde FK cascade zinciri içinden gelindiği için daha derindir.
--  Belgeyi silmeyi de yasaklamak, yanlış açılmış bir başvuruyu sistemde
--  sonsuza dek bırakırdı.
-- ============================================================================
\set ON_ERROR_STOP on

create or replace function public.tg_belge_satir_iskonto_kilit()
returns trigger language plpgsql as $$
begin
    if coalesce(old.iskonto_kilit, 0) = 1
       and coalesce(new.iskonto_kilit, 0) = 1
       and (coalesce(new.iskonto, 0)     is distinct from coalesce(old.iskonto, 0)
         or coalesce(new.iskonto2, 0)    is distinct from coalesce(old.iskonto2, 0)
         or coalesce(new.birim_fiyat, 0) is distinct from coalesce(old.birim_fiyat, 0)
         -- 681: tutarı belirleyen öteki alanlar da kilitli.
         or coalesce(new.adet, 0)        is distinct from coalesce(old.adet, 0)
         or coalesce(new.miktar, 0)      is distinct from coalesce(old.miktar, 0)
         or coalesce(new.kdv, 0)         is distinct from coalesce(old.kdv, 0)
         or coalesce(new.hizmet_id, 0)   is distinct from coalesce(old.hizmet_id, 0)
         or coalesce(new.stok_id, 0)     is distinct from coalesce(old.stok_id, 0))
    then
        raise exception 'Bu satırın iskontosu onaylanmıştır, değiştirilemez. '
                        'Değişiklik için yeni bir iskonto onayı alın.'
              using errcode = 'GK422';
    end if;
    return new;
end $$;

create or replace function public.tg_belge_satir_kilit_silme()
returns trigger language plpgsql as $$
begin
    -- Belge silinirken (FK cascade) satır da gider: orada durdurmak yanlış
    --   açılmış bir başvuruyu silinemez yapardı.
    if pg_trigger_depth() > 1 then
        return old;
    end if;
    if coalesce(old.iskonto_kilit, 0) = 1 then
        raise exception 'Bu satırın iskontosu onaylanmıştır, silinemez. '
                        'Önce iskonto onayını kaldırın.'
              using errcode = 'GK422';
    end if;
    return old;
end $$;

drop trigger if exists tr_belge_satir_kilit_silme on public.belge_satir;
create trigger tr_belge_satir_kilit_silme
    before delete on public.belge_satir
    for each row execute function public.tg_belge_satir_kilit_silme();

comment on function public.tg_belge_satir_kilit_silme is
  'Onayli (iskonto_kilit) satirin tek basina silinmesini engeller (681).';

do $$
begin
    raise notice '681 tamam: kilitli satir degistirilemez/silinemez.';
end $$;
