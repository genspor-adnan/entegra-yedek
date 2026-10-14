-- =============================================================================
--  1098  MUAYENE - "KENDİME NOT" (hekimin hastaya dair özel notu)
--
--  Mockup Ekranlar/Muayene/muayene_karti_v7.html, kullanıcı kararı 14.10.2026:
--  "Kendime Not sadece doktorun göreceği özel bilgi olarak kalacak."
--
--  ANAHTAR (kullanıcı, hasta): not muayeneye değil HEKİM-HASTA çiftine bağlı -
--  hekim aynı hastanın sonraki muayenelerinde notunu yine görür. Muayeneye
--  bağlansaydı her yeni muayenede not boş açılır, "bir dahakine sor" işe yaramazdı.
--
--  GİZLİLİK: satırı yalnız yazan kullanıcı okur (uç kullanıcıyı oturumdan alır,
--  istekten almaz). Not epikrize, rapora, çıktıya, e-Nabız'a ve YZ bağlamına
--  GİRMEZ; islem_log'a içerik yazılmaz.
-- =============================================================================

create table if not exists public.hekim_ozel_not (
    kullanici_id      integer     not null references public.taraf_kullanici (id) on delete cascade,
    hasta_id          integer     not null references public.taraf (id) on delete cascade,
    metin             text        not null default '',
    degistirme_tarihi timestamptz not null default now(),
    constraint pk_hekim_ozel_not primary key (kullanici_id, hasta_id)
);

comment on table public.hekim_ozel_not is
    'Hekimin hastaya dair özel notu (1098): yalnız yazan kullanıcı görür; epikriz/rapor/e-Nabız/YZ''ye girmez.';
