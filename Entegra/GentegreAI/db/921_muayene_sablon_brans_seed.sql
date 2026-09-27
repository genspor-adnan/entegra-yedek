-- 921 — Genel branşlar için HAZIR fizik muayene şablonları (kurum düzeyi,
-- sube_id=0). Kullanıcı: "genel branşlar için hazır şablonlar ekle." Idempotent:
-- şablon kodu yoksa eklenir; alanları (kod bazlı) yoksa eklenir. Müşteri
-- şablonu düzenlemişse dokunulmaz.
-- tip: 1 Metin · 2 Sayı · 3 Seçenekli · 4 Evet/Hayır · 5 Vücut Şeması.

do $$
declare
  v jsonb := $j$[
    {"kod":"dahiliye","ad":"Dahiliye Genel","alanlar":[
      {"kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Genel durum iyi, bilinç açık, koopere"},
      {"kod":"basboyun","ad":"Baş-Boyun","tip":1,"normal":"Doğal, LAP yok"},
      {"kod":"kvs","ad":"Kardiyovasküler","tip":1,"normal":"S1 S2 ritmik, üfürüm yok","zorunlu":1},
      {"kod":"solunum","ad":"Solunum","tip":1,"normal":"Solunum sesleri doğal","zorunlu":1},
      {"kod":"batin","ad":"Batın","tip":1,"normal":"Rahat, defans-rebound yok, organomegali yok"},
      {"kod":"ekstremite","ad":"Ekstremite","tip":1,"normal":"Ödem yok, nabızlar açık"},
      {"kod":"noro","ad":"Nörolojik","tip":1,"normal":"Kaba nörolojik defisit yok"},
      {"kod":"odem","ad":"Ödem","tip":3,"secenekler":["yok","+1","+2","+3"],"normal":"yok"},
      {"kod":"vas","ad":"Ağrı (VAS)","tip":2,"birim":"0-10"}
    ]},
    {"kod":"aile","ad":"Aile Hekimliği (Genel)","alanlar":[
      {"kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"kod":"basboyun","ad":"Baş-Boyun","tip":1,"normal":"Doğal"},
      {"kod":"kvs","ad":"Kardiyovasküler","tip":1,"normal":"S1 S2 ritmik, üfürüm yok"},
      {"kod":"solunum","ad":"Solunum","tip":1,"normal":"Solunum sesleri doğal"},
      {"kod":"batin","ad":"Batın","tip":1,"normal":"Rahat, defans yok"},
      {"kod":"ekstremite","ad":"Ekstremite","tip":1,"normal":"Ödem yok"},
      {"kod":"cilt","ad":"Cilt","tip":1,"normal":"Doğal"}
    ]},
    {"kod":"kardiyoloji","ad":"Kardiyoloji","alanlar":[
      {"kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"kod":"kvs","ad":"Kardiyovasküler","tip":1,"normal":"S1 S2 ritmik, ek ses/üfürüm yok","zorunlu":1},
      {"kod":"solunum","ad":"Solunum","tip":1,"normal":"Bazallerde ral yok"},
      {"kod":"batin","ad":"Batın","tip":1,"normal":"Hepatomegali yok"},
      {"kod":"ekstremite","ad":"Ekstremite / ödem","tip":3,"secenekler":["yok","+1","+2","+3"],"normal":"yok"},
      {"kod":"juguler","ad":"Juguler venöz dolgunluk","tip":4,"normal":"yok"},
      {"kod":"nyha","ad":"NYHA sınıfı","tip":3,"secenekler":["I","II","III","IV"]},
      {"kod":"vas","ad":"Göğüs ağrısı (VAS)","tip":2,"birim":"0-10"}
    ]},
    {"kod":"gogus","ad":"Göğüs Hastalıkları","alanlar":[
      {"kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"kod":"solunum","ad":"Solunum sistemi","tip":1,"normal":"Bilateral eşit, ral-ronküs yok","zorunlu":1},
      {"kod":"kvs","ad":"Kardiyovasküler","tip":1,"normal":"S1 S2 ritmik"},
      {"kod":"spo2","ad":"SpO₂","tip":2,"birim":"%"},
      {"kod":"dispne","ad":"Dispne (mMRC)","tip":3,"secenekler":["0","1","2","3","4"]},
      {"kod":"oksuruk","ad":"Öksürük / balgam","tip":1,"normal":"yok"}
    ]},
    {"kod":"noroloji","ad":"Nöroloji","alanlar":[
      {"kod":"bilinc","ad":"Bilinç / oryantasyon","tip":1,"normal":"Açık, oryante, koopere"},
      {"kod":"kranial","ad":"Kranial sinirler","tip":1,"normal":"Doğal"},
      {"kod":"motor","ad":"Motor","tip":1,"normal":"Kas gücü 5/5, tonus doğal"},
      {"kod":"duyu","ad":"Duyu","tip":1,"normal":"Doğal"},
      {"kod":"refleks","ad":"Refleksler","tip":1,"normal":"Normoaktif, patolojik refleks yok"},
      {"kod":"serebellar","ad":"Serebellar / koordinasyon","tip":1,"normal":"Doğal"},
      {"kod":"gks","ad":"Glasgow Koma Skalası","tip":2,"birim":"3-15"}
    ]},
    {"kod":"ortopedi","ad":"Ortopedi","alanlar":[
      {"kod":"genel","ad":"Genel görünüm / yürüyüş","tip":1,"normal":"Doğal"},
      {"kod":"inspeksiyon","ad":"İnspeksiyon","tip":1,"normal":"Deformite / şişlik yok"},
      {"kod":"palpasyon","ad":"Palpasyon / hassasiyet","tip":1,"normal":"Hassasiyet yok"},
      {"kod":"rom","ad":"Eklem hareket açıklığı","tip":1,"normal":"Tam ve ağrısız"},
      {"kod":"norovaskuler","ad":"Nörovasküler","tip":1,"normal":"Distal nabız-duyu-motor açık"},
      {"kod":"taraf","ad":"Etkilenen taraf/bölge","tip":1}
    ]},
    {"kod":"dermatoloji","ad":"Dermatoloji — Lezyon","alanlar":[
      {"kod":"genel","ad":"Genel deri muayenesi","tip":1,"normal":"Doğal"},
      {"kod":"lezyontip","ad":"Primer lezyon","tip":3,"secenekler":["makül","papül","plak","nodül","vezikül","bül","püstül","ürtiker"]},
      {"kod":"lokalizasyon","ad":"Lokalizasyon","tip":1},
      {"kod":"dagilim","ad":"Dağılım","tip":3,"secenekler":["lokalize","yaygın","simetrik","dermatomal","güneş gören"]},
      {"kod":"vucutsema","ad":"Vücut şeması","tip":5},
      {"kod":"kasinti","ad":"Kaşıntı","tip":4,"normal":"yok"}
    ]},
    {"kod":"kbb","ad":"KBB","alanlar":[
      {"kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"kod":"kulak","ad":"Kulak (otoskopi)","tip":1,"normal":"Dış kulak yolu açık, zar intakt","taraf":1},
      {"kod":"burun","ad":"Burun (rinoskopi)","tip":1,"normal":"Septum orta hatta, mukoza doğal"},
      {"kod":"bogaz","ad":"Orofarenks","tip":1,"normal":"Hiperemi yok, tonsiller doğal"},
      {"kod":"boyun","ad":"Boyun / LAP","tip":1,"normal":"LAP yok, tiroid doğal"}
    ]},
    {"kod":"uroloji","ad":"Üroloji","alanlar":[
      {"kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"kod":"batin","ad":"Batın","tip":1,"normal":"Rahat, globe vezikal yok"},
      {"kod":"kvah","ad":"Kostovertebral açı hassasiyeti","tip":3,"secenekler":["yok","sağ","sol","bilateral"],"normal":"yok"},
      {"kod":"genitouriner","ad":"Genitoüriner","tip":1,"normal":"Doğal"},
      {"kod":"rektal","ad":"Rektal (prostat)","tip":1,"normal":"Prostat doğal, kıvamı elastik"}
    ]},
    {"kod":"kadindogum","ad":"Kadın Doğum","alanlar":[
      {"kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Doğal"},
      {"kod":"batin","ad":"Batın","tip":1,"normal":"Rahat, hassasiyet yok"},
      {"kod":"pelvik","ad":"Pelvik muayene","tip":1,"normal":"Dış genital doğal"},
      {"kod":"spekulum","ad":"Spekulum","tip":1,"normal":"Serviks doğal, akıntı yok"},
      {"kod":"bimanuel","ad":"Bimanuel","tip":1,"normal":"Uterus-adneks doğal, hassasiyet yok"}
    ]},
    {"kod":"pediatri","ad":"Pediatri — Genel","alanlar":[
      {"kod":"genel","ad":"Genel görünüm","tip":1,"normal":"Aktif, iyi görünümlü"},
      {"kod":"buyume","ad":"Büyüme (persentil)","tip":1},
      {"kod":"basboyun","ad":"Baş-Boyun (fontanel)","tip":1,"normal":"Fontanel normal bombelikte"},
      {"kod":"kvs","ad":"Kardiyovasküler","tip":1,"normal":"S1 S2 ritmik, üfürüm yok"},
      {"kod":"solunum","ad":"Solunum","tip":1,"normal":"Doğal, retraksiyon yok"},
      {"kod":"batin","ad":"Batın","tip":1,"normal":"Rahat, organomegali yok"},
      {"kod":"noromotor","ad":"Nöromotor gelişim","tip":1,"normal":"Yaşına uygun"},
      {"kod":"asi","ad":"Aşı durumu","tip":3,"secenekler":["tam","eksik","bilinmiyor"]}
    ]},
    {"kod":"psikiyatri","ad":"Psikiyatri","alanlar":[
      {"kod":"gorunum","ad":"Genel görünüm / davranış","tip":1,"normal":"Bakımlı, işbirliği yeterli"},
      {"kod":"bilinc","ad":"Bilinç / oryantasyon","tip":1,"normal":"Açık, oryante"},
      {"kod":"duygudurum","ad":"Duygudurum / afekt","tip":1,"normal":"Ötimik, uyumlu"},
      {"kod":"dusunce","ad":"Düşünce içerik/akış","tip":1,"normal":"Doğal, sanrı yok"},
      {"kod":"algi","ad":"Algı","tip":1,"normal":"Varsanı yok"},
      {"kod":"icgoru","ad":"İçgörü / yargılama","tip":1,"normal":"Korunmuş"}
    ]}
  ]$j$;
  s jsonb; a jsonb; sid integer; sr smallint;
begin
  for s in select jsonb_array_elements(v) loop
    select id into sid from public.muayene_sablon where kod = s->>'kod' and sube_id = 0;
    if sid is null then
      insert into public.muayene_sablon (kod, ad, tur, aciklama, sira, durum, sube_id)
        values (s->>'kod', s->>'ad', 1, '', 0, 1, 0)
        returning id into sid;
    end if;
    sr := 0;
    for a in select jsonb_array_elements(s->'alanlar') loop
      sr := sr + 1;
      if not exists (select 1 from public.muayene_sablon_alan where sablon_id = sid and kod = a->>'kod') then
        insert into public.muayene_sablon_alan
          (sablon_id, grup, kod, ad, tip, secenekler, birim, normal_metni, taraf_sorulur, zorunlu, sira)
        values (sid, '', a->>'kod', a->>'ad', coalesce((a->>'tip')::smallint, 1),
                a->'secenekler', coalesce(a->>'birim', ''), coalesce(a->>'normal', ''),
                coalesce((a->>'taraf')::smallint, 0), coalesce((a->>'zorunlu')::smallint, 0), sr);
      end if;
    end loop;
  end loop;
end $$;
