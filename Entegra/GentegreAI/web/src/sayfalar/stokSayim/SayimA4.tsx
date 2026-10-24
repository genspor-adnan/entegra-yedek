import type { StokSayimSatiri, StokSayimYaniti } from '../../api/uclar/stok';
import { tarihSaat } from '../../bilesenler/bicim';
import { IcmalAntet } from '../../bilesenler/cikti/IcmalAntet';

/**
 * A4 SAYIM LİSTESİ (kullanıcı 24.10.2026: "icmaldeki yazdırma / önizle / kaydet
 * gibi olsun") - CiktiMenusu'nün içinde yaşar. Ekrandaki süzgeçle aynı satırlar,
 * gösterim sınırı yok. Sayılmayan satırda Sayılan / Fark boş kalır: açık sayımda
 * rafta elle doldurulacak sayım çizelgesi olarak da basılır.
 */
export function SayimA4({ v, satirlar, suzgecAdi, kapsamAdi, antet, duzenleyen }: {
  v: StokSayimYaniti; satirlar: StokSayimSatiri[]; suzgecAdi: string; kapsamAdi: string;
  antet: Record<string, unknown> | null; duzenleyen: string;
}) {
  const b = v.baslik;
  const sayi = (n: number) => n.toLocaleString('tr-TR', { maximumFractionDigits: 3 });
  const tl = (n: number) => n.toLocaleString('tr-TR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const ayYil = (t: string | null) => t ? new Date(t).toLocaleDateString('tr-TR', { month: '2-digit', year: 'numeric' }) : '';
  let sistemT = 0, sayilanT = 0, farkTl = 0, sayilan = 0;
  for (const s of satirlar) {
    sistemT += s.sistem;
    if (s.sayilan == null) continue;
    sayilan++; sayilanT += s.sayilan; farkTl += (s.sayilan - s.sistem) * s.birimMaliyet;
  }
  return (
    <div className="hi-a4 ss-a4">
      <IcmalAntet antet={antet} duzenleyen={duzenleyen} />
      <h3>STOK SAYIM LİSTESİ</h3>
      <div className="a4-hasta">
        <span>Sayım No: <b>{b.sayimNo}</b> · {b.durum === 0 ? 'Açık' : 'Kapandı'}</span>
        <span>Depo: <b>{b.depoAdi}</b></span>
        <span>Sayım tarihi: {tarihSaat(b.sayimTarihi)}</span>
        <span>Kapsam: {kapsamAdi}{suzgecAdi ? ` · ${suzgecAdi}` : ''}</span>
        {b.aciklama && <span>Açıklama: {b.aciklama}</span>}
        <span>Kalem: {sayi(satirlar.length)} · sayılan {sayi(sayilan)}</span>
      </div>
      <table className="a4-t ss-a4t">
        <thead><tr><th>#</th><th>Stok Kodu</th><th>Stok Adı</th><th>Birim</th><th>Lot</th><th>SKT</th>
          <th>Sistem</th><th>Sayılan</th><th>Fark</th></tr></thead>
        <tbody>
          {satirlar.map((s, i) => {
            const f = s.sayilan == null ? null : s.sayilan - s.sistem;
            return (
              <tr key={s.id}><td>{i + 1}</td><td>{s.stokKodu}</td><td>{s.stokAdi}</td><td>{s.birim}</td><td>{s.lot}</td>
                <td>{ayYil(s.skt)}</td><td>{sayi(s.sistem)}</td><td>{s.sayilan == null ? '' : sayi(s.sayilan)}</td>
                <td>{f ? `${f > 0 ? '+' : ''}${sayi(f)}` : ''}</td></tr>
            );
          })}
        </tbody>
      </table>
      <table className="a4-toplam"><tbody>
        <tr><td>Sistem toplamı</td><td>{sayi(sistemT)}</td></tr>
        <tr><td>Sayılan toplamı</td><td>{sayi(sayilanT)}</td></tr>
        <tr className="kalan ki-kalan"><td>FARK TUTARI (maliyet)</td><td>{tl(farkTl)} ₺</td></tr>
      </tbody></table>
      <p className="a4-not">Sistem miktarı sayımın açıldığı andaki depo bakiyesidir. Sayılmayan kaleme dokunulmaz;
        farklar Sayım Fazlası giriş fişine ve Sayım Eksiği çıkış fişine yazılır.</p>
      <div className="a4-imza"><div>Sayımı Yapan<br />Ad Soyad · İmza</div><div>Kontrol Eden<br />Ad Soyad · İmza</div></div>
    </div>
  );
}

export const SAYIM_A4_STILI = `
.ss-cikti { padding:0; }
.a4-t.ss-a4t th:nth-child(1) { width:4%; } .a4-t.ss-a4t th:nth-child(2) { width:13%; } .a4-t.ss-a4t th:nth-child(3) { width:31%; }
.a4-t.ss-a4t th:nth-child(4) { width:7%; } .a4-t.ss-a4t th:nth-child(5) { width:12%; } .a4-t.ss-a4t th:nth-child(6) { width:8%; }
.a4-t.ss-a4t th:nth-child(-n+6), .a4-t.ss-a4t td:nth-child(-n+6) { text-align:left; }
.a4-t.ss-a4t td:nth-child(8) { min-height:14px; }
/* Uzun liste birden çok sayfaya taşar: ortak icmal kuralındaki position:fixed her sayfaya ilk sayfayı basar. */
@media print { .hi-a4.ss-a4 { position:absolute; } .a4-t.ss-a4t thead { display:table-header-group; } .a4-t.ss-a4t tr { break-inside:avoid; } }
`;
