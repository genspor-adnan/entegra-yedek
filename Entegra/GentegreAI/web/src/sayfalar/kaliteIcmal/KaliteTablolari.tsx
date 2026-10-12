import { Fragment, useRef, useState, type MouseEvent } from 'react';
import type { KaliteGostergesi, KaliteIcmali } from '../../api/uclar/kaliteIcmal';
import { secimUygula } from '../../bilesenler/listeSecimi';
import { tarihKisa } from '../hasta/icmal/icmalOrtak';
import { durumRozeti, hedefMetni, oranRozeti, soruDegerlendirme, sonucMetni, trend } from './kaliteIcmalOrtak';

/** Kalite / SKS icmalinin sekme tabloları. Rakamlar sunucudan gelir. */

const tire = (n: number | null | undefined) => (n ? String(n) : '—');
const yz = (n: number | null | undefined) => sonucMetni(n, '%');
const zaman = (t: string) => new Date(t).toLocaleString('tr-TR', { day: '2-digit', month: '2-digit', hour: '2-digit', minute: '2-digit' });
const sayi = (n: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: 2 });

function Bos({ n, metin }: { n: number; metin: string }) {
  return <tr><td colSpan={n} className="bos">{metin}</td></tr>;
}

/** GÖSTERGELER - tık tek, Ctrl / Shift çoklu; ▸ bölüm / meslek kırılımı; seçilenler A4'e girer. */
export function GostergeTablosu({ liste, secili, setSecili }: { liste: KaliteGostergesi[]; secili: string[]; setSecili(x: string[]): void }) {
  const son = useRef<string | null>(null);
  const [acik, setAcik] = useState<string[]>([]);
  const tikla = (kod: string, e: MouseEvent) => {
    e.stopPropagation();
    if (e.shiftKey) window.getSelection()?.removeAllRanges();
    setSecili(secimUygula(secili, kod, liste.map(g => g.kod), son.current, { ctrl: e.ctrlKey || e.metaKey, shift: e.shiftKey }));
    if (!e.shiftKey) son.current = kod;
  };
  const ac = (kod: string, e: MouseEvent) => { e.stopPropagation(); setAcik(a => a.includes(kod) ? a.filter(x => x !== kod) : [...a, kod]) };
  const hepsi = liste.length > 0 && liste.every(g => secili.includes(g.kod));
  const say = (k: string) => liste.filter(g => g.kaynak === k).length;
  return (
    <>
      <table className="hi-tablo">
        <thead><tr>
          <th style={{ width: 28 }}><input type="checkbox" checked={hepsi} onChange={() => setSecili(hepsi ? [] : liste.map(g => g.kod))} /></th>
          <th>Kod</th><th>Gösterge</th><th>Kaynak</th><th className="sag">Hedef</th><th className="sag">Pay / Payda</th><th className="sag">Dönem</th>
          <th className="sag">Önceki</th><th>Trend</th><th>Durum</th></tr></thead>
        <tbody>
          {liste.length === 0 && <Bos n={10} metin="Bu sette gösterge yok." />}
          {liste.map(g => {
            const sec = secili.includes(g.kod); const d = durumRozeti(g.durum); const tr = trend(g.sonuc, g.onceki, g.yon, g.birim);
            return (
              <Fragment key={g.kod}>
                <tr className={'ac' + (sec ? ' sec' : '')} onClick={e => tikla(g.kod, e)} title={g.not || 'Tıkla: yalnız bu · Ctrl: ekle / çıkar · Shift: aralık'}>
                  <td><input type="checkbox" checked={sec} readOnly onClick={e => tikla(g.kod, e)} /></td>
                  <td>{g.kirilim.length > 0 && <a className="ki-lnk" onClick={e => ac(g.kod, e)}>{acik.includes(g.kod) ? '▾' : '▸'}</a>} <b>{g.kod}</b></td>
                  <td>{g.ad}{g.not && <div className="ki-soluk">{g.not}</div>}</td>
                  <td><span className={'bo-rz ' + (g.kaynak === 'SKS' ? 'mor' : 'pas')}>{g.kaynak}</span></td>
                  <td className="sag">{hedefMetni(g.yon, g.hedef, g.birim)}</td>
                  <td className="sag">{g.durum === 'kaynakyok' ? '—' : `${sayi(g.pay)} / ${sayi(g.payda)}`}</td>
                  <td className={'sag' + (g.durum === 'disi' ? ' kir' : '')}><b>{sonucMetni(g.sonuc, g.birim)}</b></td>
                  <td className="sag">{sonucMetni(g.onceki, g.birim)}</td>
                  <td>{tr ? <span className={'kl-tr ' + tr.yon}>{tr.ok} {tr.fark}</span> : '—'}</td>
                  <td><span className={'bo-rz ' + d.renk}>{d.ad}</span></td>
                </tr>
                {acik.includes(g.kod) && g.kirilim.map(k => (
                  <tr key={g.kod + k.ad} className="lb-alt"><td /><td /><td>{k.ad}</td><td colSpan={2} />
                    <td className="sag">{sayi(k.pay)} / {sayi(k.payda)} {k.birim}</td><td className="sag">{sonucMetni(k.sonuc, g.birim)}</td><td colSpan={3} /></tr>
                ))}
              </Fragment>
            );
          })}
          {liste.length > 0 && (
            <tr className="top"><td /><td colSpan={5}>Toplam · {liste.length} gösterge ({say('SKS')} SKS · {say('Klinik')} klinik)</td>
              <td colSpan={2} className="sag">{liste.filter(g => g.durum === 'hedefte').length} hedefte</td>
              <td colSpan={2}>{liste.filter(g => g.durum === 'disi').length} hedef dışı</td></tr>
          )}
        </tbody>
      </table>
      <div className="ki-not">Gösterge = pay / payda (dönem). Klinik göstergeler Klinik Kalite dönem sonuçlarından aynen okunur (dönemi kapsayan periyot,
        trend = önceki periyot); yalnız ölçülenler listelenir. SKS göstergeleri kayıtlardan hesaplanır, trend önceki dönemle; renk hedef yönüne göre
        (iyileşme yeşil). "Kaynak yok" = bu göstergenin kaydı sistemde tutulmuyor (kalite modülü kurulunca dolar).</div>
    </>
  );
}

export function BildirimTablosu({ v }: { v: KaliteIcmali }) {
  const k = v.bildirimKaynaklari;
  const t = k.reduce((a, x) => ({ b: a.b + x.bildirim, h: a.h + x.hedefte, as: a.as + x.asan, ty: a.ty + x.teyit, y: a.y + x.yukseltme }),
    { b: 0, h: 0, as: 0, ty: 0, y: 0 });
  return (
    <>
      <div className="lb-bas">Kaynağa Göre <span className="ki-soluk">süre = sonuç onayı / rapor onayı → hekime bildirim · hedef ayardan
        (kalite.panik_hedef_dk, kalite.kritik_hedef_dk)</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Kaynak</th><th className="sag">Hedef</th><th className="sag">Bildirim</th><th className="sag">Hedefte</th><th className="sag">Aşan</th>
          <th className="sag">Hedefte Oranı</th><th className="sag">Ort. Süre</th><th className="sag">En Uzun</th><th className="sag">Teyit</th>
          <th className="sag">Yükseltme</th></tr></thead>
        <tbody>
          {k.map(x => (
            <tr key={x.kaynak}><td>{x.kaynak}</td><td className="sag">{x.hedefDk} dk</td><td className="sag">{x.bildirim}</td><td className="sag">{tire(x.hedefte)}</td>
              <td className={'sag' + (x.asan ? ' kir' : '')}>{tire(x.asan)}</td><td className="sag">{yz(x.oran)}</td>
              <td className="sag">{x.ortSure != null ? `${x.ortSure} dk` : '—'}</td><td className="sag">{x.enUzun != null ? `${x.enUzun} dk` : '—'}</td>
              <td className="sag">{tire(x.teyit)}</td><td className="sag">{tire(x.yukseltme)}</td></tr>
          ))}
          <tr className="top"><td colSpan={2}>Toplam</td><td className="sag">{t.b}</td><td className="sag">{t.h}</td><td className="sag">{t.as}</td>
            <td className="sag">{yz(v.ozet.bildirimOran)}</td><td className="sag">{v.ozet.ortSure != null ? `${v.ozet.ortSure} dk` : '—'}</td><td />
            <td className="sag">{t.ty}</td><td className="sag">{t.y}</td></tr>
        </tbody>
      </table>
      <div className="lb-bas">Bildirimler <span className="ki-soluk">hedefe göre en geç olanlar üstte · hasta adı yok, Protokol No ile</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Zaman</th><th>Protokol No</th><th>Kaynak</th><th>Tetkik / Bulgu</th><th>Değer</th><th>Bölüm</th><th>Bildirilen</th>
          <th>Kanal</th><th className="sag">Süre</th><th className="sag">Hedef</th><th>Teyit</th></tr></thead>
        <tbody>
          {v.bildirimler.length === 0 && <Bos n={11} metin="Bu dönemde kritik / panik bildirim yok." />}
          {v.bildirimler.map((b, i) => (
            <tr key={i}><td>{zaman(b.zaman)}</td><td>{b.protokolNo || '—'}</td>
              <td><span className={'bo-rz ' + (b.kaynak === 'Lab' ? 'mavi' : 'mor')}>{b.kaynak}</span></td><td>{b.tetkik}</td><td>{b.deger || '—'}</td>
              <td>{b.bolum || '—'}</td><td>{b.bildirilen || '—'}</td><td>{b.kanal}</td>
              <td className={'sag' + (b.asti ? ' kir' : '')}>{b.sureDk != null ? `${b.sureDk} dk` : 'onay yok'}</td><td className="sag">{b.hedefDk} dk</td>
              <td><span className={'bo-rz ' + (b.teyit ? 'ok' : 'sari')}>{b.teyit ? 'Geri okundu' : 'Teyit yok'}</span>
                {b.yukseltme && <span className="bo-rz kir lb-k">yükseltildi</span>}</td></tr>
          ))}
        </tbody>
      </table>
    </>
  );
}

export function GrsTablosu({ v }: { v: KaliteIcmali }) {
  const n = v.zararAdlari.length;
  const sut = Array.from({ length: n }, (_, i) => v.grsMatris.reduce((a, m) => a + (m.duzey[i] ?? 0), 0));
  return (
    <>
      <div className="lb-bas">Olay Türü × Zarar Düzeyi <span className="ki-soluk">Güvenlik Raporlama Sistemi bildirim formu (grs_olay)</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Olay Türü</th>{v.zararAdlari.map(z => <th key={z} className="sag">{z}</th>)}<th className="sag">Toplam</th></tr></thead>
        <tbody>
          {v.grsMatris.length === 0 && <Bos n={n + 2} metin="Bu dönemde GRS olay bildirimi yok." />}
          {v.grsMatris.map(m => (
            <tr key={m.tur}><td>{m.tur}</td>{m.duzey.map((x, i) => <td key={i} className={'sag' + (x && i >= 3 && i <= 4 ? ' kir' : '')}>{tire(x)}</td>)}
              <td className="sag"><b>{m.toplam}</b></td></tr>
          ))}
          {v.grsMatris.length > 0 && (
            <tr className="top"><td>Toplam · {v.grsMatris.length} tür</td>{sut.map((x, i) => <td key={i} className="sag">{x}</td>)}
              <td className="sag">{v.ozet.grs}</td></tr>
          )}
        </tbody>
      </table>
      <div className="lb-bas">Olay Bildirimleri <span className="ki-soluk">bildiren anonim olabilir · hasta bilgisi bu listede yok</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Olay No</th><th>Tarih</th><th>Tür</th><th>Birim</th><th>Zarar</th><th>Bildiren</th><th>Kök Neden / Durum</th></tr></thead>
        <tbody>
          {v.grsOlaylar.length === 0 && <Bos n={7} metin="Bu dönemde GRS olay bildirimi yok." />}
          {v.grsOlaylar.map(o => (
            <tr key={o.no}><td>{o.no}</td><td>{tarihKisa(o.tarih)}</td><td>{o.tur}</td><td>{o.birim || '—'}</td>
              <td><span className={'bo-rz ' + (o.duzey >= 3 && o.duzey <= 4 ? 'kir' : o.duzey === 2 ? 'sari' : 'pas')}>{o.zarar}</span></td>
              <td>{o.anonim ? 'Anonim' : 'Adlı'}</td><td className="ki-soluk">takip kaydı yok</td></tr>
          ))}
        </tbody>
      </table>
      <div className="ki-not">Olayın kapanması, kök neden analizi ve DÖF bağı için takip kaydı henüz yok; kalite modülü (olay takibi, DÖF) kurulunca
        bu sütun ve SKS.GR1 dolar. Ciddi zarar / ölüm kırmızıdır.</div>
    </>
  );
}

export function GuvenlikTablosu({ v }: { v: KaliteIcmali }) {
  const s = v.servisler;
  const t = s.reduce((a, x) => ({ y: a.y + x.yatan, hg: a.hg + x.hastaGun, it: a.it + x.itakiYuksek, d: a.d + x.dusme, br: a.br + x.bradenRiskli, g: a.g + x.gelisen }),
    { y: 0, hg: 0, it: 0, d: 0, br: 0, g: 0 });
  const elT = v.elMeslek.reduce((a, x) => ({ f: a.f + x.firsat, u: a.u + x.uyulan }), { f: 0, u: 0 });
  return (
    <>
      <div className="lb-bas">Servis Bazında Düşme ve Bası Yarası <span className="ki-soluk">riskli = İtaki II ≥ 5 / Braden ≤ 12 · hasta-gün yatışlardan ·
        düşme = GRS bildirimi</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Servis</th><th className="sag">Yatan</th><th className="sag">Hasta-Gün</th><th className="sag">İtaki Yüksek</th><th className="sag">Düşme</th>
          <th className="sag">‰ Hasta-Gün</th><th className="sag">Braden Riskli</th><th className="sag">Gelişen Bası Yarası</th><th className="sag">Oran</th></tr></thead>
        <tbody>
          {s.length === 0 && <Bos n={9} metin="Bu dönemde yatış yok." />}
          {s.map(x => (
            <tr key={x.servis}><td>{x.servis}</td><td className="sag">{x.yatan}</td><td className="sag">{x.hastaGun}</td><td className="sag">{tire(x.itakiYuksek)}</td>
              <td className={'sag' + (x.dusme ? ' kir' : '')}>{tire(x.dusme)}</td><td className="sag">{sonucMetni(x.dusmeBinde, '‰')}</td>
              <td className="sag">{tire(x.bradenRiskli)}</td><td className={'sag' + (x.gelisen ? ' kir' : '')}>{tire(x.gelisen)}</td>
              <td className="sag">{yz(x.basiOran)}</td></tr>
          ))}
          {s.length > 0 && (
            <tr className="top"><td>Toplam · {s.length} servis</td><td className="sag">{t.y}</td><td className="sag">{t.hg}</td><td className="sag">{t.it}</td>
              <td className="sag">{t.d}</td><td className="sag">{sonucMetni(v.ozet.dusmeBinde, '‰')}</td><td className="sag">{t.br}</td>
              <td className="sag">{t.g}</td><td className="sag">{yz(v.ozet.basiOran)}</td></tr>
          )}
        </tbody>
      </table>
      {v.ozet.eslesmeyenDusme > 0 && <div className="ki-not">{v.ozet.eslesmeyenDusme} düşme bildiriminin birimi bir servisle eşleşmedi; toplama girer, servis satırına girmez.</div>}
      <div className="lb-kalite">
        <div>
          <div className="lb-bas">El Hijyeni · Meslek Grubu <span className="ki-soluk">gözlem formu (el_hijyeni) · hedef %85</span></div>
          <table className="hi-tablo">
            <thead><tr><th>Meslek</th><th className="sag">Fırsat</th><th className="sag">Uyulan</th><th className="sag">Uyum</th><th>Durum</th></tr></thead>
            <tbody>
              {v.elMeslek.length === 0 && <Bos n={5} metin="Bu dönemde el hijyeni gözlemi yok." />}
              {v.elMeslek.map(x => { const r = oranRozeti(x.oran, 85); return (
                <tr key={x.ad}><td>{x.ad}</td><td className="sag">{x.firsat}</td><td className="sag">{x.uyulan}</td><td className="sag">{yz(x.oran)}</td>
                  <td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>) })}
              {v.elMeslek.length > 0 && <tr className="top"><td>Toplam · {v.elMeslek.length} meslek grubu</td><td className="sag">{elT.f}</td>
                <td className="sag">{elT.u}</td><td className="sag">{yz(v.ozet.elOran)}</td><td /></tr>}
            </tbody>
          </table>
        </div>
        <div>
          <div className="lb-bas">El Hijyeni · 5 Endikasyon</div>
          <table className="hi-tablo">
            <thead><tr><th>Endikasyon</th><th className="sag">Fırsat</th><th className="sag">Uyulan</th><th className="sag">Oran</th></tr></thead>
            <tbody>
              {v.elEndikasyon.length === 0 && <Bos n={4} metin="—" />}
              {v.elEndikasyon.map(x => (
                <tr key={x.ad}><td>{x.ad}</td><td className="sag">{x.firsat}</td><td className="sag">{x.uyulan}</td><td className="sag">{yz(x.oran)}</td></tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}

export function MemnuniyetTablosu({ v }: { v: KaliteIcmali }) {
  const m = v.memnuniyetBirim;
  const t = m.reduce((a, x) => ({ g: a.g + x.gonderilen, d: a.d + x.dolduran, mm: a.mm + x.memnun }), { g: 0, d: 0, mm: 0 });
  return (
    <>
      <div className="lb-bas">Birim Bazında Memnuniyet <span className="ki-soluk">anket = form motoru (memnuniyet) · memnun = ortalama 4-5 puan</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Birim</th><th className="sag">Gönderilen</th><th className="sag">Dolduran</th><th className="sag">Yanıt</th><th className="sag">Ort. Puan</th>
          <th className="sag">Memnun</th><th className="sag">Memnuniyet</th><th className="sag">Şikâyet</th></tr></thead>
        <tbody>
          {m.length === 0 && <Bos n={8} metin="Bu dönemde memnuniyet anketi yok." />}
          {m.map(x => (
            <tr key={x.birim}><td>{x.birim}</td><td className="sag">{x.gonderilen}</td><td className="sag">{x.dolduran}</td><td className="sag">{yz(x.yanit)}</td>
              <td className="sag">{x.ortPuan != null ? x.ortPuan.toFixed(2).replace('.', ',') : '—'}</td><td className="sag">{x.memnun}</td>
              <td className={'sag' + (x.oran != null && x.oran < 85 ? ' kir' : '')}>{yz(x.oran)}</td><td className="sag ki-soluk">—</td></tr>
          ))}
          {m.length > 0 && (
            <tr className="top"><td>Toplam · {m.length} birim</td><td className="sag">{t.g}</td><td className="sag">{t.d}</td>
              <td className="sag">{yz(t.g ? 100 * t.d / t.g : null)}</td>
              <td className="sag">{v.ozet.ortPuan != null ? v.ozet.ortPuan.toFixed(2).replace('.', ',') : '—'}</td><td className="sag">{t.mm}</td>
              <td className="sag">{yz(v.ozet.memnuniyetOran)}</td><td /></tr>
          )}
        </tbody>
      </table>
      <div className="lb-bas">Soru Başlıkları <span className="ki-soluk">bütün anketlerin soru ortalaması (1-5)</span></div>
      <table className="hi-tablo">
        <thead><tr><th>Soru</th><th className="sag">Cevap</th><th className="sag">Puan Ortalama</th><th>Değerlendirme</th></tr></thead>
        <tbody>
          {v.memnuniyetSorular.map(s => { const r = soruDegerlendirme(s.ortalama); return (
            <tr key={s.soru}><td>{s.soru}</td><td className="sag">{tire(s.cevap)}</td>
              <td className="sag">{s.ortalama != null ? s.ortalama.toFixed(2).replace('.', ',') : '—'}</td><td><span className={'bo-rz ' + r.renk}>{r.ad}</span></td></tr>) })}
        </tbody>
      </table>
      <div className="ki-not">Şikâyet kaydı sistemde henüz tutulmuyor (kalite modülü kurulunca dolar).</div>
    </>
  );
}
