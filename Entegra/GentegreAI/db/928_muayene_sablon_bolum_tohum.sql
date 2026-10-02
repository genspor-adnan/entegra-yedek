-- =====================================================================
--  928_muayene_sablon_bolum_tohum.sql
--  GENEL BÖLÜMLER İÇİN ŞABLONLAR (kullanıcı: "genel bölümler için şablonlar
--  ve kartlarını da ekle listeye"; liste bölüm ve doktora göre - 927).
--
--  1) BAĞLAMA: 921'in branş şablonları bölümsüz kurulmuştu. Kodu bir bölümün
--     SKRS koduna AÇIKÇA karşılık gelen şablon o bölüme bağlanır - YALNIZ
--     bölümü VE doktoru boşsa (kurum sonradan bağlamışsa dokunulmaz). Bölüm
--     kurulumda yoksa şablon bölümsüz (Genel) kalır.
--  2) YENİ ŞABLONLAR: şablonu olmayan genel bölümler + bölümsüz genel anamnez
--     ve sistem sorgusu. Kod yoksa eklenir; alan kod bazlı yoksa eklenir.
--  3) VARSAYILAN (⭐): bölümde varsayılan YOKSA bu dosyanın o bölüme bağladığı
--     fizik muayene şablonu varsayılan olur. Kurumun seçtiği varsayılan
--     değişmez.
--  tip: 1 Metin · 2 Sayı · 3 Seçenekli · 4 Evet/Hayır · 5 Vücut Şeması.
-- =====================================================================
\set ON_ERROR_STOP on

do $$
declare
  -- 921 şablon kodu -> bölüm SKRS kodu
  bag jsonb := '{"dahiliye":"157","aile":"106","kardiyoloji":"163","gogus":"150",
                 "noroloji":"168","ortopedi":"171","dermatoloji":"136","kbb":"165",
                 "uroloji":"196","kadindogum":"161","pediatri":"132","psikiyatri":"181"}';
  v jsonb := $j$[
    {"kod":"acil","ad":"Acil — Hızlı Değerlendirme","bolum":"101","tur":1,"alanlar":[
      {"grup":"Genel","kod":"genel","ad":"Genel durum","tip":3,"secenekler":["iyi","orta","kötü"],"normal":"iyi","zorunlu":1},
      {"grup":"Genel","kod":"gks","ad":"Glasgow Koma Skalası","tip":2,"birim":"3-15","zorunlu":1},
      {"grup":"ABC","kod":"havayolu","ad":"Hava yolu","tip":1,"normal":"Açık"},
      {"grup":"ABC","kod":"solunum","ad":"Solunum","tip":1,"normal":"Solunum sesleri bilateral eşit, ek ses yok"},
      {"grup":"ABC","kod":"dolasim","ad":"Dolaşım","tip":1,"normal":"Periferik nabızlar açık, kapiller dolum < 2 sn"},
      {"grup":"Sistem","kod":"kvs","ad":"Kardiyovasküler","tip":1,"normal":"S1 S2 ritmik, üfürüm yok"},
      {"grup":"Sistem","kod":"batin","ad":"Batın","tip":1,"normal":"Rahat, defans-rebound yok"},
      {"grup":"Sistem","kod":"noro","ad":"Nörolojik","tip":1,"normal":"Lateralizan bulgu yok, pupiller izokorik"},
      {"grup":"Travma","kod":"travma","ad":"Travma bulgusu","tip":4,"normal":"yok"},
      {"grup":"Travma","kod":"lokal","ad":"Lokal muayene","tip":1,"taraf":1},
      {"grup":"Genel","kod":"vas","ad":"Ağrı (VAS)","tip":2,"birim":"0-10"}
    ]},
    {"kod":"goz","ad":"Göz — Rutin Muayene","bolum":"151","tur":1,"alanlar":[
      {"grup":"Görme","kod":"gorme","ad":"Görme keskinliği","tip":1,"taraf":1,"zorunlu":1},
      {"grup":"Görme","kod":"gib","ad":"Göz içi basıncı","tip":2,"birim":"mmHg","taraf":1},
      {"grup":"Ön segment","kod":"kapak","ad":"Kapak / konjonktiva","tip":1,"normal":"Doğal","taraf":1},
      {"grup":"Ön segment","kod":"kornea","ad":"Kornea","tip":1,"normal":"Saydam","taraf":1},
      {"grup":"Ön segment","kod":"onkamara","ad":"Ön kamara","tip":1,"normal":"Derin, reaksiyon yok","taraf":1},
      {"grup":"Ön segment","kod":"lens","ad":"Lens","tip":3,"secenekler":["saydam","katarakt","psödofak","afak"],"normal":"saydam","taraf":1},
      {"grup":"Fundus","kod":"fundus","ad":"Fundus","tip":1,"normal":"Optik disk sınırları net, makula doğal","taraf":1},
      {"grup":"Motilite","kod":"motilite","ad":"Göz hareketleri","tip":1,"normal":"Her yöne serbest"}
    ]},
    {"kod":"genelcerrahi","ad":"Genel Cerrahi","bolum":"147","tur":1,"alanlar":[
      {"grup":"Genel","kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Genel durum iyi"},
      {"grup":"Batın","kod":"inspeksiyon","ad":"İnspeksiyon","tip":1,"normal":"Distansiyon yok, skar yok"},
      {"grup":"Batın","kod":"palpasyon","ad":"Palpasyon","tip":1,"normal":"Hassasiyet yok, defans-rebound yok","zorunlu":1},
      {"grup":"Batın","kod":"kitle","ad":"Kitle / organomegali","tip":4,"normal":"yok"},
      {"grup":"Batın","kod":"bagirsak","ad":"Bağırsak sesleri","tip":3,"secenekler":["normoaktif","hipoaktif","hiperaktif","yok"],"normal":"normoaktif"},
      {"grup":"Fıtık","kod":"herni","ad":"Herni muayenesi","tip":1,"normal":"Fıtık saptanmadı","taraf":1},
      {"grup":"Rektal","kod":"rektal","ad":"Rektal tuşe","tip":1},
      {"grup":"Meme","kod":"meme","ad":"Meme / aksilla","tip":1,"normal":"Kitle yok, aksiller LAP yok","taraf":1}
    ]},
    {"kod":"endokrin","ad":"Endokrin ve Metabolizma","bolum":"139","tur":1,"alanlar":[
      {"grup":"Genel","kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"grup":"Genel","kod":"bki","ad":"Bel çevresi","tip":2,"birim":"cm"},
      {"grup":"Tiroid","kod":"tiroid","ad":"Tiroid","tip":1,"normal":"Palpabl değil, nodül yok","zorunlu":1},
      {"grup":"Tiroid","kod":"ekzoftalmi","ad":"Ekzoftalmi","tip":4,"normal":"yok"},
      {"grup":"Diyabet","kod":"ayak","ad":"Diyabetik ayak","tip":1,"normal":"Yara yok, duyu korunmuş","taraf":1},
      {"grup":"Diyabet","kod":"monofilaman","ad":"Monofilaman testi","tip":3,"secenekler":["normal","azalmış","kayıp"],"normal":"normal","taraf":1},
      {"grup":"Cilt","kod":"akantozis","ad":"Akantozis nigrikans","tip":4,"normal":"yok"},
      {"grup":"Cilt","kod":"hirsutizm","ad":"Hirsutizm","tip":4,"normal":"yok"}
    ]},
    {"kod":"gastro","ad":"Gastroenteroloji","bolum":"144","tur":1,"alanlar":[
      {"grup":"Genel","kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"grup":"Genel","kod":"sarilik","ad":"Sarılık (ikter)","tip":4,"normal":"yok"},
      {"grup":"Batın","kod":"palpasyon","ad":"Batın palpasyonu","tip":1,"normal":"Rahat, hassasiyet yok","zorunlu":1},
      {"grup":"Batın","kod":"hepatomegali","ad":"Hepatomegali","tip":4,"normal":"yok"},
      {"grup":"Batın","kod":"splenomegali","ad":"Splenomegali","tip":4,"normal":"yok"},
      {"grup":"Batın","kod":"asit","ad":"Asit","tip":3,"secenekler":["yok","hafif","belirgin"],"normal":"yok"},
      {"grup":"Rektal","kod":"rektal","ad":"Rektal tuşe","tip":1}
    ]},
    {"kod":"nefroloji","ad":"Nefroloji","bolum":"166","tur":1,"alanlar":[
      {"grup":"Genel","kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"grup":"Sıvı","kod":"odem","ad":"Ödem","tip":3,"secenekler":["yok","+1","+2","+3"],"normal":"yok","zorunlu":1},
      {"grup":"Sıvı","kod":"hidrasyon","ad":"Hidrasyon","tip":3,"secenekler":["normal","dehidrate","hipervolemik"],"normal":"normal"},
      {"grup":"Sistem","kod":"kvs","ad":"Kardiyovasküler","tip":1,"normal":"S1 S2 ritmik, frotman yok"},
      {"grup":"Sistem","kod":"solunum","ad":"Solunum","tip":1,"normal":"Bazallerde ral yok"},
      {"grup":"Diyaliz","kod":"avf","ad":"AV fistül / kateter","tip":1,"taraf":1},
      {"grup":"Sistem","kod":"kvah","ad":"Kostovertebral açı hassasiyeti","tip":4,"normal":"yok","taraf":1}
    ]},
    {"kod":"ftr","ad":"Fiziksel Tıp ve Rehabilitasyon","bolum":"142","tur":1,"alanlar":[
      {"grup":"Genel","kod":"postur","ad":"Postür / yürüyüş","tip":1,"normal":"Doğal"},
      {"grup":"Eklem","kod":"eha","ad":"Eklem hareket açıklığı","tip":1,"normal":"Tam ve ağrısız","taraf":1,"zorunlu":1},
      {"grup":"Kas","kod":"kasgucu","ad":"Kas gücü","tip":3,"secenekler":["5/5","4/5","3/5","2/5","1/5","0/5"],"normal":"5/5","taraf":1},
      {"grup":"Nörolojik","kod":"dtr","ad":"Derin tendon refleksleri","tip":1,"normal":"Normoaktif","taraf":1},
      {"grup":"Nörolojik","kod":"duyu","ad":"Duyu muayenesi","tip":1,"normal":"Doğal","taraf":1},
      {"grup":"Özel testler","kod":"slr","ad":"Düz bacak kaldırma (SLR)","tip":3,"secenekler":["negatif","pozitif"],"normal":"negatif","taraf":1},
      {"grup":"Genel","kod":"vas","ad":"Ağrı (VAS)","tip":2,"birim":"0-10"}
    ]},
    {"kod":"anestezi","ad":"Anestezi — Preoperatif Değerlendirme","bolum":"109","tur":1,"alanlar":[
      {"grup":"Risk","kod":"asa","ad":"ASA sınıfı","tip":3,"secenekler":["I","II","III","IV","V"],"zorunlu":1},
      {"grup":"Hava yolu","kod":"mallampati","ad":"Mallampati","tip":3,"secenekler":["1","2","3","4"],"zorunlu":1},
      {"grup":"Hava yolu","kod":"agizaciklik","ad":"Ağız açıklığı","tip":2,"birim":"cm"},
      {"grup":"Hava yolu","kod":"boyun","ad":"Boyun hareketleri","tip":1,"normal":"Serbest"},
      {"grup":"Sistem","kod":"kvs","ad":"Kardiyovasküler","tip":1,"normal":"S1 S2 ritmik, üfürüm yok"},
      {"grup":"Sistem","kod":"solunum","ad":"Solunum","tip":1,"normal":"Solunum sesleri doğal"},
      {"grup":"Risk","kod":"aclik","ad":"Açlık süresi","tip":2,"birim":"saat"},
      {"grup":"Risk","kod":"antikoagulan","ad":"Antikoagülan kullanımı","tip":4,"normal":"yok"}
    ]},
    {"kod":"anamnez-genel","ad":"Genel Anamnez","bolum":null,"tur":2,"alanlar":[
      {"grup":"Öykü","kod":"sikayet","ad":"Başvuru şikâyeti","tip":1,"zorunlu":1},
      {"grup":"Öykü","kod":"sure","ad":"Şikâyet süresi","tip":1},
      {"grup":"Öykü","kod":"ozgecmis","ad":"Özgeçmiş","tip":1,"normal":"Özellik yok"},
      {"grup":"Öykü","kod":"soygecmis","ad":"Soygeçmiş","tip":1,"normal":"Özellik yok"},
      {"grup":"Alışkanlık","kod":"sigara","ad":"Sigara","tip":3,"secenekler":["içmiyor","içiyor","bırakmış"],"normal":"içmiyor"},
      {"grup":"Alışkanlık","kod":"alkol","ad":"Alkol","tip":3,"secenekler":["kullanmıyor","sosyal","düzenli"],"normal":"kullanmıyor"},
      {"grup":"İlaç","kod":"ilac","ad":"Kullandığı ilaçlar","tip":1,"normal":"Yok"}
    ]},
    {"kod":"sistemsorgu-genel","ad":"Genel Sistem Sorgusu","bolum":null,"tur":3,"alanlar":[
      {"grup":"Genel","kod":"genel","ad":"Ateş / kilo kaybı / halsizlik","tip":1,"normal":"Yok"},
      {"grup":"KVS","kod":"kvs","ad":"Göğüs ağrısı / çarpıntı","tip":1,"normal":"Yok"},
      {"grup":"Solunum","kod":"solunum","ad":"Öksürük / nefes darlığı","tip":1,"normal":"Yok"},
      {"grup":"GİS","kod":"gis","ad":"Bulantı / kusma / dışkılama","tip":1,"normal":"Yok, dışkılama olağan"},
      {"grup":"GÜS","kod":"gus","ad":"İdrar yakınması","tip":1,"normal":"Yok"},
      {"grup":"Nörolojik","kod":"noro","ad":"Baş ağrısı / baş dönmesi","tip":1,"normal":"Yok"},
      {"grup":"Kas-iskelet","kod":"kasiskelet","ad":"Eklem / kas ağrısı","tip":1,"normal":"Yok"}
    ]}
  ]$j$;
  k text; skrs text; bid integer; s jsonb; a jsonb; sid integer; sr smallint; bagli integer := 0; eklenen integer := 0;
begin
  -- 1) Bölümsüz ve doktorsuz 921 şablonlarını bölüme bağla.
  for k, skrs in select key, value #>> '{}' from jsonb_each(bag) loop
    select id into bid from public.departman where kod = skrs limit 1;
    if bid is null then continue; end if;
    update public.muayene_sablon set bolum_id = bid
     where kod = k and bolum_id is null and hekim_id is null;
    if found then bagli := bagli + 1; end if;
  end loop;

  -- 2) Yeni şablonlar.
  for s in select jsonb_array_elements(v) loop
    bid := null;
    if s->>'bolum' is not null then
      select id into bid from public.departman where kod = s->>'bolum' limit 1;
    end if;
    select id into sid from public.muayene_sablon where kod = s->>'kod';
    if sid is null then
      insert into public.muayene_sablon (kod, ad, tur, aciklama, sira, durum, sube_id, bolum_id)
        values (s->>'kod', s->>'ad', (s->>'tur')::smallint, '', 0, 1, 0, bid)
        returning id into sid;
      eklenen := eklenen + 1;
    end if;
    sr := 0;
    for a in select jsonb_array_elements(s->'alanlar') loop
      sr := sr + 1;
      if not exists (select 1 from public.muayene_sablon_alan where sablon_id = sid and kod = a->>'kod') then
        insert into public.muayene_sablon_alan
          (sablon_id, grup, kod, ad, tip, secenekler, birim, normal_metni, taraf_sorulur, zorunlu, sira)
        values (sid, coalesce(a->>'grup', ''), a->>'kod', a->>'ad', coalesce((a->>'tip')::smallint, 1),
                a->'secenekler', coalesce(a->>'birim', ''), coalesce(a->>'normal', ''),
                coalesce((a->>'taraf')::smallint, 0), coalesce((a->>'zorunlu')::smallint, 0), sr * 10);
      end if;
    end loop;
  end loop;

  -- 3) Varsayılanı olmayan bölümde bu dosyanın fizik muayene şablonu ⭐ olur.
  update public.muayene_sablon s set varsayilan = 1
   where s.tur = 1 and s.durum = 1 and s.hekim_id is null and s.bolum_id is not null and s.varsayilan = 0
     and s.kod in (select jsonb_object_keys(bag)
                   union select x->>'kod' from jsonb_array_elements(v) x)
     and not exists (select 1 from public.muayene_sablon o
                      where o.bolum_id = s.bolum_id and o.varsayilan = 1 and o.durum = 1 and o.hekim_id is null)
     and s.id = (select min(o2.id) from public.muayene_sablon o2
                  where o2.bolum_id = s.bolum_id and o2.tur = 1 and o2.durum = 1 and o2.hekim_id is null
                    and o2.kod in (select jsonb_object_keys(bag) union select x->>'kod' from jsonb_array_elements(v) x));

  raise notice '928: % sablon bolume baglandi, % yeni sablon eklendi', bagli, eklenen;
end $$;
