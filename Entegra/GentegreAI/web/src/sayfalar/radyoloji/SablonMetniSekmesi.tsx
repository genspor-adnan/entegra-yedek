import { useEffect, useState } from 'react';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import { BicimAracCubugu, BicimliAlan, duzdenHtml, metinEkle } from '../../bilesenler/BicimliMetin';
import { guvenli, mesaj, onay } from '../../bilesenler/mesaj';
import { c } from '../../dil/ceviri';
import { BAKANLIK_PARCALARI, TEK_BOLUM, bakanligaBol, bakanlikIskeleti, teke, type SablonBolumu } from './sablonBolme';

/**
 * ŞABLON METNİ SEKMESİ (1216, mockup Ekranlar/Radyoloji/radyoloji_sablon_karti_v3.html).
 *
 * Şablonun bölümleri BİÇİMLİ düzenlenir - rapor ekranındaki editör (font, renk, tablo, resim) + yer tutucu menüsü.
 * Tek bölüm = Tek A4 (eski HBYS şablonları böyle); çok bölüm = Bölümlü, her bölümün Bakanlık parçası seçilir
 * (Teleradyoloji OBX-5: ^1 Teknik · ^2 Karşılaştırma · ^3 Bulgular · ^4 Sonuç ve Öneriler). Tek → Bölümlü
 * kalın başlıklardan bölünür (sablonBolme); Bölümlü → Tek başlıklarla birleşir.
 *
 * Kayıt kendi düğmesiyle, kendi ucundan (POST /api/radyoloji/sablon/{id}/bolumler - HTML sunucuda beyaz listeyle
 * temizlenir). Kartta kaydedilmemiş değişiklik varsa önce o yazılır; sonra kart tazelenir (Bölümler gridi
 * ve Önizleme yeni hali gösterir).
 */

const YER_TUTUCULAR: [string, string][] = [
  ['{istem.on_tani}', 'Ön tanı'],
  ['{istem.klinik_bilgi}', 'Klinik bilgi / şikâyet'],
  ['{hasta.yas}', 'Hasta yaşı'],
  ['{hasta.cinsiyet}', 'Hasta cinsiyeti'],
];

const bosMu = (html: string) => html.replace(/<(?!img|table)[^>]+>/g, '').replace(/&nbsp;/g, ' ').trim() === '';

export function SablonMetniSekmesi({ id, salt, kartiKaydet, kartiTazele }: {
  id: number; salt: boolean; kartiKaydet(): Promise<boolean>; kartiTazele(): void;
}) {
  const [bolumler, setBolumler] = useState<SablonBolumu[] | null>(null);
  const [kirli, setKirli] = useState(false);
  const [hata, setHata] = useState<string | null>(null);
  const [yerAcik, setYerAcik] = useState(false);

  useEffect(() => {
    let iptal = false;
    setBolumler(null); setKirli(false);
    api.radSablonBolumleri(id).then(y => {
      if (iptal) return;
      setBolumler(y.bolumler.map(b => ({
        baslik: b.baslik, html: b.html ?? duzdenHtml(b.metin), bakanlikParca: Number(b.bakanlikParca ?? 0),
        zorunlu: Number(b.zorunlu) === 1, yazdir: Number(b.yazdir ?? 1) !== 0,
      })));
    }).catch(e => { if (!iptal) setHata(hataMetni(e)) });
    return () => { iptal = true };
  }, [id]);

  if (hata) return <div className="hata-kutusu">{hata}</div>;
  if (!bolumler) return <div className="sonuk" style={{ padding: 16 }}>{c('yükleniyor')}…</div>;

  // Bölümsüz şablon tek A4 olarak açılır (kaydedilince "Rapor" bölümü olur).
  const liste = bolumler.length > 0 ? bolumler : [teke([])];
  const tek = liste.length === 1;
  const degis = (yeni: SablonBolumu[]) => { setBolumler(yeni); setKirli(true) };
  const guncelle = (i: number, p: Partial<SablonBolumu>) => degis(liste.map((b, j) => (j === i ? { ...b, ...p } : b)));

  const kaydet = () => void guvenli(async () => {
    if (!(await kartiKaydet())) return;
    await api.radSablonBolumleriYaz(id, liste.map(b => ({ ...b, baslik: b.baslik.trim() || TEK_BOLUM })));
    setKirli(false);
    mesaj(c('Şablon metni kaydedildi.'));
    kartiTazele();
  });
  const bol = () => void guvenli(async () => {
    const yeni = bakanligaBol(liste[0].html);
    const dolu = yeni.filter(b => !bosMu(b.html)).map(b => b.baslik).join(', ') || c('hiçbiri');
    if (!(await onay(`${c('Metin kalın başlıklarından Bakanlık bölümlerine bölünsün mü?')}\n${c('Dolu çıkan')}: ${dolu}.\n`
      + c('Başlığı tanınmayan kısım Bulgular\'a gider. Kaydetmeden önce kontrol edin.')))) return;
    degis(yeni);
  });
  const birlestir = () => void guvenli(async () => {
    if (!(await onay(c('Bölümler başlıklarıyla tek A4 metne birleşsin mi? Bakanlık parçası bilgisi kalkar.')))) return;
    degis([teke(liste)]);
  });
  const tasi = (i: number, y: number) => {
    const j = i + y; if (j < 0 || j >= liste.length) return;
    const yeni = [...liste]; [yeni[i], yeni[j]] = [yeni[j], yeni[i]]; degis(yeni);
  };
  const sil = (i: number) => void guvenli(async () => {
    if (!bosMu(liste[i].html) && !(await onay(`"${liste[i].baslik}" ${c('bölümü metniyle birlikte silinsin mi?')}`))) return;
    degis(liste.filter((_, j) => j !== i));
  });
  const eksikParca = BAKANLIK_PARCALARI.filter(p => !liste.some(b => b.bakanlikParca === p.parca));

  return (
    <div className="rt-sekme sm-sekme">
      <div className="rt-arac">
        <b>{tek ? c('Tek A4 metin') : `${c('Bölümlü')} · ${liste.length}`}</b>
        {!tek && eksikParca.length > 0 && (
          <span className="rozet uyari" title={c('Bakanlık profili açık kurumda rapor onayı bu parçalar olmadan geçmez')}>
            {c('Eksik Bakanlık parçası')}: {eksikParca.map(p => p.ad).join(', ')}</span>)}
        <span className="ck-bosluk" />
        {!salt && tek && <button type="button" className="d" onClick={bol}
          title={c('TEKNİK / KARŞILAŞTIRMA / BULGULAR / SONUÇ başlıklarından Bakanlık bölümlerine')}>☰ {c('Başlıklardan böl')}</button>}
        {!salt && !tek && eksikParca.length > 0 && <button type="button" className="d" onClick={() => degis(bakanlikIskeleti(liste))}>
          🏛 {c('Bakanlık iskeletini kur')}</button>}
        {!salt && !tek && <button type="button" className="d" onClick={birlestir}>▯ {c('Teke birleştir')}</button>}
        {!salt && !tek && <button type="button" className="d" onClick={() => degis([...liste,
          { baslik: c('Yeni bölüm'), html: '', bakanlikParca: 0, zorunlu: false, yazdir: true }])}>＋ {c('Bölüm')}</button>}
        {!salt && <button type="button" className="d bir" disabled={!kirli} onClick={kaydet}>💾 {c('Metni kaydet')}</button>}
      </div>

      <div className="sm-arac">
        <BicimAracCubugu pasif={salt} />
        <span className="sm-yer">
          <button type="button" className="d" disabled={salt} onMouseDown={e => { e.preventDefault(); setYerAcik(a => !a) }}>
            {'{ }'} {c('Yer tutucu')} ▾</button>
          {yerAcik && (
            <div className="sm-yer-menu" onMouseLeave={() => setYerAcik(false)}>
              {YER_TUTUCULAR.map(([k, ad]) => (
                <button type="button" key={k} onMouseDown={e => { e.preventDefault(); setYerAcik(false); metinEkle(k) }}>
                  {c(ad)} <code>{k}</code></button>))}
            </div>)}
        </span>
      </div>

      {tek ? (
        <BicimliAlan className="rad-a4" html={liste[0].html} salt={salt}
                     onDegis={h => degis([{ ...liste[0], html: h }])} />
      ) : liste.map((b, i) => (
        <div className="sm-bolum" key={i}>
          <div className="sm-bolum-bas">
            <input value={b.baslik} disabled={salt} maxLength={60} onChange={e => guncelle(i, { baslik: e.target.value })} />
            <select value={b.bakanlikParca} disabled={salt} title={c('Bakanlık rapor parçası')}
                    onChange={e => guncelle(i, { bakanlikParca: Number(e.target.value) })}>
              <option value={0}>{c('Bakanlık parçası yok')}</option>
              {BAKANLIK_PARCALARI.map(p => <option key={p.parca} value={p.parca}>^{p.parca} {c(p.ad)}</option>)}
            </select>
            <label><input type="checkbox" checked={b.zorunlu} disabled={salt} onChange={e => guncelle(i, { zorunlu: e.target.checked })} /> {c('Zorunlu')}</label>
            <label><input type="checkbox" checked={b.yazdir} disabled={salt} onChange={e => guncelle(i, { yazdir: e.target.checked })} /> {c('Yazdır')}</label>
            <span className="ck-bosluk" />
            {!salt && <>
              <button type="button" className="d" title={c('Yukarı')} onClick={() => tasi(i, -1)}>↑</button>
              <button type="button" className="d" title={c('Aşağı')} onClick={() => tasi(i, 1)}>↓</button>
              <button type="button" className="d" title={c('Sil')} onClick={() => sil(i)}>✕</button>
            </>}
          </div>
          <BicimliAlan className={`rad-bolum-metin${b.bakanlikParca === 3 ? ' uzun' : ''}`} html={b.html} salt={salt}
                       onDegis={h => guncelle(i, { html: h })} />
        </div>
      ))}
      <div className="tl-bilgi" style={{ marginTop: 8 }}>
        {c('Bakanlık Teleradyoloji raporu dört parça ister: ^1 Teknik · ^2 Karşılaştırma · ^3 Bulgular (zorunlu, en az 50 karakter) · ^4 Sonuç ve Öneriler (zorunlu). Klinik bilgi parça değildir, istemle gider.')}
      </div>
    </div>
  );
}
