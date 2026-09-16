-- 710: DİŞ MUAYENESİ GENEL MUAYENE OLMADAN (kullanıcı: "genel muayene
-- kullanılmıyorsa dental anamnez nereden girilecek").
--
-- `dis_muayene.muayene_id` zorunluydu: diş kurulumunda genel muayene açılmadan
-- odontogram başlığından dental anamnez / bruksizm / sigara yazılamıyordu
-- ("muayeneId boş bırakılamaz"). Bağ isteğe bağlı olur; muayeneden gelen satır
-- yine bağını taşır, odontogramdan yazılan satır muayenesizdir. Tekil indeks
-- (`ux_dis_muayene_muayene`) NULL'ları saymaz, birden çok muayenesiz satır olur.
alter table public.dis_muayene alter column muayene_id drop not null;
