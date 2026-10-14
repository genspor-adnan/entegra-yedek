-- =============================================================================
--  1101  YZ KONTÖR - "epikriz" özelliği (muayene epikrizi › YZ ile düzenle)
--
--  Mockup Ekranlar/Muayene/muayene_karti_v7.html: epikriz taslağı karttan
--  ÜCRETSİZ derlenir; hekim isterse metni modele akıcı hâle getirtir - bu adım
--  kontörlüdür ve diğer YZ özellikleri gibi kurumda ayrı açılıp kapanır
--  (YZ Kontör › Ayarlar). Varsayılan açık: tani/tetkik/ilac ile aynı.
-- =============================================================================

alter table public.ai_kontor
    add column if not exists oz_epikriz smallint not null default 1;

comment on column public.ai_kontor.oz_epikriz is
    'Muayene epikrizi YZ ile düzenle özelliği açık mı (1101).';
