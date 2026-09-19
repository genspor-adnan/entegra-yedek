import { useCallback, useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { api } from '../../api/istemci';
import { hataMetni } from '../../api/sozlesme';
import type { GeriAramaYaniti, KampanyaKisiSatiri, KampanyaSatiri } from '../../api/uclar/cagri';
import { useOturum } from '../../kimlik/OturumBaglami';
import { guvenli, mesaj, metinSor, onay, secimSor } from '../../bilesenler/mesaj';

/**
 * GİDEN ARAMA · KAMPANYA `/cagri-giden` (Çağrı Merkezi 839) — mockup
 * Ekranlar/CagriMerkezi/cagri_giden_kampanya.html. Sekmeler: geri arama
 * listesi (söz + kaçan + kampanya adımı, tıkla-ara), kampanyalar, kampanya
 * kartı (adımlar + kişiler + üret / çalıştır / durdur), mesaj şablonları.
 */
type Sekme = 'liste' | 'kampanya' | 'kart' | 'sablon';
type Suzgec = 'bugun' | 'gecikmis' | 'benim' | 'tumu';
const KISI_DURUM: Record<number, string> = { 1: 'sari', 2: 'mavi', 3: 'kir', 4: 'ok', 5: 'ok', 6: 'kir', 7: 'pas' };
const SABLONLAR = [
  { kod: 'cagri.randevu_hatirlatma', kanal: 'WhatsApp / SMS', degisken: '{{ad}} {{tarih}} {{bolum}} {{kurum}}', ne: 'Randevu hatırlatma kampanyası 1. adımı' },
  { kod: 'cagri.sonuc_hazir', kanal: 'WhatsApp / SMS', degisken: '{{ad}} {{tetkik}} {{baglanti}}', ne: 'Sonuç hazır kampanyası' },
  { kod: 'cagri.odeme_linki', kanal: 'SMS', degisken: '{{ad}} {{tutar}} {{baglanti}}', ne: 'Operatör hızlı işlemi / tahsilat kampanyası' },
  { kod: 'cagri.anket', kanal: 'SMS', degisken: '{{ad}} {{baglanti}}', ne: 'Memnuniyet anketi (form motoru bağlantısı)' },
  { kod: 'cagri.geri_arama', kanal: 'SMS', degisken: '{{ad}} {{saat}}', ne: 'Geri arama planlanınca' },
  { kod: 'cagri.yol_tarifi', kanal: 'WhatsApp', degisken: '{{adres}} {{konum}}', ne: 'Operatör hızlı işlemi' },
];

export function CagriGiden() {
  const git = useNavigate();
  const [sorgu, setSorgu] = useSearchParams();
  const { yetki } = useOturum();
  const [sekme, setSekme] = useState<Sekme>(sorgu.get('kampanya') ? 'kart' : 'liste');
  const [suzgec, setSuzgec] = useState<Suzgec>('bugun');
  const [g, setG] = useState<GeriAramaYaniti | null>(null);
  const [kampanyalar, setKampanyalar] = useState<KampanyaSatiri[]>([]);
  const [kampanyaId, setKampanyaId] = useState(Number(sorgu.get('kampanya') ?? 0));
  const [kart, setKart] = useState<{ kampanya: KampanyaSatiri; kisiler: KampanyaKisiSatiri[] } | null>(null);
  const [hata, setHata] = useState<string | null>(null);

  const yukle = useCallback(async () => {
    try { setG(await api.cagriGeriArama(suzgec)); setKampanyalar(await api.cagriKampanyalar()); setHata(null) } catch (h) { setHata(hataMetni(h)) }
  }, [suzgec]);
  useEffect(() => { void yukle() }, [yukle]);
  useEffect(() => {
    if (!kampanyaId) { setKart(null); return }
    api.cagriKampanya(kampanyaId).then(setKart).catch(h => setHata(hataMetni(h)));
    setSorgu(s => { s.set('kampanya', String(kampanyaId)); return s }, { replace: true });
  }, [kampanyaId, setSorgu]);

  const ara = async (tel: string, tarafId?: number | null, kisiId?: number | null) => {
    await guvenli(async () => { const y = await api.cagriBaslat({ kanal: 1, yon: 2, arayanNo: tel, tarafId: tarafId ?? null, kampanyaKisiId: kisiId ?? null }); git(`/cagri-pano?cagri=${y.id}`) });
  };
  const tamam = async (cagriId: number) => { if (!await onay('Geri arama yapıldı olarak işaretlensin mi?')) return; await guvenli(async () => { await api.cagriGeriAramaTamam(cagriId); await yukle() }) };
  const kisiSonuc = async (k: KampanyaKisiSatiri) => {
    const d = await secimSor(`${k.ad} — sonuç`, [{ kod: '5', ad: '✅ Onayladı' }, { kod: '4', ad: '✔ Tamamlandı' }, { kod: '3', ad: '📵 Ulaşılamadı' }, { kod: '6', ad: '❌ İptal etti' }, { kod: '7', ad: '🚫 Vazgeçildi' }]); if (!d) return;
    const n = await metinSor('Sonuç notu', '', 'Not'); if (n === null) return;
    await guvenli(async () => { await api.cagriKisiSonuc(k.id, { durum: Number(d), sonuc: n }); setKart(await api.cagriKampanya(kampanyaId)); await yukle() });
  };
  const uret = async () => { await guvenli(async () => { const y = await api.cagriKampanyaUret(kampanyaId); mesaj(y.not_ || `${y.eklenen} kişi eklendi, ${y.atlanan} atlandı.`); setKart(await api.cagriKampanya(kampanyaId)); await yukle() }) };
  const calistir = async () => {
    if (!await onay('Kampanya çalıştırılsın mı? Bekleyen kişilere 1. adım mesajı bildirim kuyruğuna alınır.')) return;
    await guvenli(async () => { const y = await api.cagriKampanyaCalistir(kampanyaId); mesaj(y.dogrudanArama ? 'Kişiler geri arama listesinde.' : `${y.gonderilen} mesaj kuyruğa alındı${y.hata ? `, ${y.hata} hata` : ''}.`); setKart(await api.cagriKampanya(kampanyaId)); await yukle() });
  };
  const durdur = async () => { if (!await onay('Kampanya durdurulsun mu?')) return; await guvenli(async () => { await api.cagriKampanyaDurdur(kampanyaId); setKart(await api.cagriKampanya(kampanyaId)); await yukle() }) };

  const zaman = (d?: string | null) => d ? new Date(d).toLocaleString('tr-TR', { dateStyle: 'short', timeStyle: 'short' }) : '—';
  const oz = g?.ozet;
  const p = kart?.kampanya;
  return (
    <div className="fm-sayfa">
      <div className="sayfabas"><div className="basrow"><h1>📤 Giden Aramalar · Kampanyalar</h1><span className="yol">Çağrı Merkezi › Giden Arama · {new Date().toLocaleDateString('tr-TR')}</span>
        <div className="sag">
          {yetki('cagri.kampanya', 'ekle') && <button className="d bir" onClick={() => git('/cagri-kampanya/yeni?geri=%2Fcagri-giden')}>＋ Kampanya</button>}
          <button className="d" onClick={() => git('/cagri-pano')}>🎧 Operatör panosu</button>
          <button className="d" onClick={() => void yukle()}>⟳ Yenile</button>
        </div></div></div>
      {hata && <div className="hata-kutusu">{hata}</div>}
      {oz && <div className="fm-kpis">
        <div className="fm-kpi"><div className="b">Aranacak (bugün)</div><div className={`d${oz.aranacak ? ' sari' : ''}`}>{oz.aranacak}</div></div>
        <div className="fm-kpi"><div className="b">Arandı</div><div className="d ok">{oz.arandi}</div></div>
        <div className="fm-kpi"><div className="b">Ulaşılamadı</div><div className={`d${oz.ulasilamadi ? ' kir' : ''}`}>{oz.ulasilamadi}</div></div>
        <div className="fm-kpi"><div className="b">Geri arama sözü (bugün)</div><div className="d">{oz.soz}</div></div>
        <div className="fm-kpi"><div className="b">Kaçan (bugün)</div><div className={`d${oz.kacan ? ' kir' : ''}`}>{oz.kacan}</div></div>
      </div>}
      <div className="ka-sekmeler" style={{ padding: '0 0 8px' }}>
        {(['liste', 'kampanya', 'kart', 'sablon'] as Sekme[]).map(s => <div key={s} className={`ka-sekme${sekme === s ? ' on' : ''}`} onClick={() => setSekme(s)}>{{ liste: '↩ Geri Arama Listesi', kampanya: '📣 Kampanyalar', kart: `🗂 Kampanya Kartı${p ? ` — ${p.ad}` : ''}`, sablon: '💬 Mesaj Şablonları' }[s]}</div>)}
      </div>
      {sekme === 'liste' && (
        <section className="fm-bolum">
          <div className="fm-doldur-arac">{(['bugun', 'gecikmis', 'benim', 'tumu'] as Suzgec[]).map(s => <button key={s} className={`d${suzgec === s ? ' bir' : ''}`} onClick={() => setSuzgec(s)}>{{ bugun: 'Bugün', gecikmis: 'Gecikmiş', benim: 'Benim', tumu: 'Tümü' }[s]}</button>)}
            <span className="sp sonuk">Kaynak: geri arama sözü · kaçan çağrı · kampanya adımı</span></div>
          <table className="fm-tablo"><thead><tr><th>Zaman</th><th>Kişi</th><th>Telefon</th><th>Kaynak</th><th>Konu / Not</th><th>Agent</th><th /></tr></thead>
            <tbody>{(g?.satirlar ?? []).map((s, i) => <tr key={i} className={s.gecikmis ? 'cg-gecikmis' : ''}>
              <td>{zaman(s.zaman)}{s.gecikmis ? <span className="rz kir" style={{ marginLeft: 4 }}>gecikmiş</span> : null}</td>
              <td><b>{s.ad || 'Tanınmıyor'}</b></td><td>{s.telefon}</td><td>{s.kaynakAdi}</td><td>{s.konu}{s.notu ? <span className="sonuk"> · {s.notu}</span> : null}</td><td>{s.agentAdi || '—'}</td>
              <td style={{ whiteSpace: 'nowrap' }}>
                {yetki('cagri.kayit', 'ekle') && <button className="d mini bir" onClick={() => void ara(s.telefon, s.tarafId, s.kisiId)}>📞 Ara</button>}
                {s.kaynak !== 'kampanya' && s.cagriId && yetki('cagri.giden', 'degistir') && <button className="d mini" onClick={() => void tamam(s.cagriId!)}>✔ Tamam</button>}
                {s.kaynak === 'kampanya' && s.kampanyaId && <button className="d mini" onClick={() => { setKampanyaId(s.kampanyaId!); setSekme('kart') }}>🗂 Kampanya</button>}
                {s.cagriId && <button className="d mini" onClick={() => git(`/cagri/${s.cagriId}?geri=%2Fcagri-giden`)}>📞 Kart</button>}
              </td></tr>)}
              {!g?.satirlar.length && <tr><td colSpan={7} className="sonuk">Bu süzgeçte aranacak kişi yok.</td></tr>}</tbody></table>
        </section>
      )}
      {sekme === 'kampanya' && (
        <section className="fm-bolum">
          <table className="fm-tablo"><thead><tr><th>Kampanya</th><th>Tür</th><th>Kaynak</th><th>1. adım</th><th>2. adım</th><th className="fm-sag">Hedef</th><th className="fm-sag">Ulaşılan</th><th className="fm-sag">Başarılı</th><th className="fm-sag">Bekleyen</th><th>Durum</th><th /></tr></thead>
            <tbody>{kampanyalar.map(k => <tr key={k.id} className={k.id === kampanyaId ? 'sec' : ''} onClick={() => setKampanyaId(k.id)} onDoubleClick={() => setSekme('kart')}>
              <td><b>{k.ad}</b></td><td>{k.tur_adi}</td><td>{k.kaynak}</td><td>{k.sablon_kodu ? `💬 ${k.sablon_kodu}` : '📞 doğrudan arama'}</td><td>{k.kuyruk_adi || '—'}</td>
              <td className="fm-sag">{k.hedef}</td><td className="fm-sag">{k.ulasilan}</td><td className="fm-sag">{k.basarili}</td><td className="fm-sag">{k.bekleyen}</td>
              <td><span className={`rz ${k.durum === 1 ? 'ok' : k.durum === 0 ? 'pas' : k.durum === 2 ? 'sari' : ''}`}>{k.durum_adi}</span></td>
              <td><button className="d mini" onClick={e => { e.stopPropagation(); setKampanyaId(k.id); setSekme('kart') }}>Aç</button></td></tr>)}
              {!kampanyalar.length && <tr><td colSpan={11} className="sonuk">Kampanya yok — "＋ Kampanya" ile açın (kaynak: yarınki randevular, sonuç hazır, vadesi geçen, İSG periyodik, serbest).</td></tr>}</tbody></table>
        </section>
      )}
      {sekme === 'kart' && (p ? (
        <>
          <section className="fm-bolum">
            <div className="fm-doldur-arac">
              <b>{p.ad}</b> <span className={`rz ${p.durum === 1 ? 'ok' : p.durum === 0 ? 'pas' : 'sari'}`}>{p.durum_adi}</span>
              <span className="sp" />
              {yetki('cagri.kampanya', 'degistir') && <><button className="d" onClick={() => void uret()}>🔄 Listeyi üret</button>
                {p.durum !== 1 ? <button className="d bir" onClick={() => void calistir()}>▶ Çalıştır</button> : <button className="d" onClick={() => void durdur()}>⏸ Durdur</button>}
                <button className="d" onClick={() => git(`/cagri-kampanya/${p.id}?geri=${encodeURIComponent(`/cagri-giden?kampanya=${p.id}`)}`)}>✎ Düzenle / kişi ekle</button></>}
            </div>
            <div className="isg-frm">
              <Al lb="Tür" v={p.tur_adi} /><Al lb="Kaynak listesi" v={`${p.kaynak}${p.parametre ? ` (${p.parametre})` : ''}`} /><Al lb="Zamanlama" v={p.zamanlama || '—'} /><Al lb="Başlama / bitiş" v={`${p.baslama ? new Date(p.baslama).toLocaleDateString('tr-TR') : '—'} → ${p.bitis ? new Date(p.bitis).toLocaleDateString('tr-TR') : '—'}`} />
              <Al lb="1. adım" v={p.sablon_kodu ? `💬 ${p.sablon_kodu}` : '📞 doğrudan arama listesi'} /><Al lb="2. adım" v={`${p.kuyruk_adi || '—'} · mesaja cevap yoksa ${p.ikinci_adim_dk} dk sonra`} /><Al lb="Deneme" v={`${p.deneme} × ${p.deneme_ara_dk} dk ara`} />
              <Al lb="Sayılar" v={`hedef ${p.hedef} · ulaşılan ${p.ulasilan} · başarılı ${p.basarili} · bekleyen ${p.bekleyen}`} />
            </div>
          </section>
          <section className="fm-bolum"><h3 className="fm-bolum-bas">Kişiler ({kart!.kisiler.length})</h3>
            <table className="fm-tablo"><thead><tr><th>Kişi</th><th>Telefon</th><th>Özet</th><th>Durum</th><th className="fm-sag">Deneme</th><th>Son deneme</th><th>Sonuç</th><th /></tr></thead>
              <tbody>{kart!.kisiler.map(k => <tr key={k.id}><td><b>{k.ad}</b></td><td>{k.telefon}</td><td>{k.ozet}</td>
                <td><span className={`rz ${KISI_DURUM[k.durum] ?? ''}`}>{k.durum_adi}</span>{k.aranacak ? <span className="rz sari" style={{ marginLeft: 4 }}>aranacak</span> : null}</td>
                <td className="fm-sag">{k.deneme}</td><td>{zaman(k.son_deneme)}</td><td>{k.sonuc}</td>
                <td style={{ whiteSpace: 'nowrap' }}>
                  {yetki('cagri.kayit', 'ekle') && k.durum < 4 && <button className="d mini bir" onClick={() => void ara(k.telefon, k.taraf_id, k.id)}>📞 Ara</button>}
                  {yetki('cagri.giden', 'degistir') && <button className="d mini" onClick={() => void kisiSonuc(k)}>✔ Sonuç</button>}
                  {k.cagri_id && <button className="d mini" onClick={() => git(`/cagri/${k.cagri_id}?geri=${encodeURIComponent(`/cagri-giden?kampanya=${p.id}`)}`)}>Kart</button>}
                </td></tr>)}
                {!kart!.kisiler.length && <tr><td colSpan={8} className="sonuk">Kişi yok — "Listeyi üret" kaynaktan doldurur; serbest listede kartın Kişiler detayından eklenir.</td></tr>}</tbody></table>
          </section>
        </>
      ) : <div className="fm-bolum sonuk">Kampanyalar sekmesinden bir kampanya seçin.</div>)}
      {sekme === 'sablon' && (
        <section className="fm-bolum">
          <table className="fm-tablo"><thead><tr><th>Şablon kodu</th><th>Kanal</th><th>Değişkenler</th><th>Kullanım</th></tr></thead>
            <tbody>{SABLONLAR.map(s => <tr key={s.kod}><td><code>{s.kod}</code></td><td>{s.kanal}</td><td><code>{s.degisken}</code></td><td>{s.ne}</td></tr>)}</tbody></table>
          <div className="sonuk" style={{ fontSize: 11, marginTop: 6 }}>Metinler Ayarlar › Bildirim şablonları'ndan düzenlenir; WhatsApp şablonları Meta onayı gerektirir (24 saat penceresi dışında yalnız onaylı şablon gider). Arama izni olmayan kişi kampanyaya girmez.</div>
        </section>
      )}
    </div>
  );
}

function Al({ lb, v }: { lb: string; v: React.ReactNode }) { return <div className="al"><span className="lb">{lb}</span><span className="inp ro">{v}</span></div> }
