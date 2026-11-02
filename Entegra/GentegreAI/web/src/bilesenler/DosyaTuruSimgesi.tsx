/**
 * DOSYA TÜRÜ SİMGESİ (kullanıcı 02.11.2026: "resim doküman sekmesinde şekilleri dokümanın türüne göre ver.. word
 * doküman ise onun logosu görünsün"): emoji yerine türün tanıdık rengi ve harfiyle kâğıt simgesi - Word mavi W,
 * Excel yeşil X, PowerPoint turuncu P, PDF kırmızı, metin gri, arşiv sarı. Marka logosu değil, türü anlatan rozet.
 */
export interface DosyaTuru { etiket: string; renk: string; zemin: string }

export function dosyaTuru(contentType: string, ad = ''): DosyaTuru {
  const t = (contentType || '').toLowerCase();
  const uzanti = (ad.split('.').pop() ?? '').toLowerCase();
  const var_ = (...k: string[]) => k.some(x => t.includes(x));
  if (t === 'application/pdf' || uzanti === 'pdf') return { etiket: 'PDF', renk: '#d93025', zemin: '#fbe9e7' };
  if (var_('word', 'msword') || ['doc', 'docx', 'rtf', 'odt'].includes(uzanti))
    return { etiket: 'W', renk: '#2b579a', zemin: '#e8eef8' };
  if (var_('excel', 'spreadsheet') || ['xls', 'xlsx', 'csv', 'ods'].includes(uzanti))
    return { etiket: 'X', renk: '#217346', zemin: '#e6f2ea' };
  if (var_('powerpoint', 'presentation') || ['ppt', 'pptx', 'odp'].includes(uzanti))
    return { etiket: 'P', renk: '#d24726', zemin: '#fbeae5' };
  if (var_('zip', 'rar', '7z', 'compressed') || ['zip', 'rar', '7z'].includes(uzanti))
    return { etiket: 'ZIP', renk: '#b7791f', zemin: '#fdf3e1' };
  if (t.startsWith('text/') || ['txt', 'xml', 'json', 'log'].includes(uzanti))
    return { etiket: 'TXT', renk: '#5f6b7a', zemin: '#eef1f5' };
  if (t.startsWith('image/')) return { etiket: 'IMG', renk: '#2f6db3', zemin: '#e8f0fa' };
  if (t.startsWith('video/')) return { etiket: '▶', renk: '#7b3fb3', zemin: '#f1e9f8' };
  if (t.startsWith('audio/')) return { etiket: '♪', renk: '#7b3fb3', zemin: '#f1e9f8' };
  return { etiket: '?', renk: '#6b7a8b', zemin: '#eef1f5' };
}

export function DosyaTuruSimgesi({ contentType, ad, boyut = 46 }: { contentType: string; ad?: string; boyut?: number }) {
  const d = dosyaTuru(contentType, ad);
  const kucukYazi = d.etiket.length > 1;
  return (
    <svg width={boyut} height={boyut * 1.2} viewBox="0 0 40 48" role="img" aria-label={d.etiket}>
      {/* kâğıt + kıvrık köşe */}
      <path d="M4 2h22l10 10v32a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2z" fill="#fff" stroke="#c3ccd6" strokeWidth="1.5" />
      <path d="M26 2v8a2 2 0 0 0 2 2h8" fill="#eef2f6" stroke="#c3ccd6" strokeWidth="1.5" />
      {/* tür rozeti */}
      <rect x="0" y="22" width={kucukYazi ? 30 : 22} height="17" rx="2.5" fill={d.renk} />
      <text x={kucukYazi ? 15 : 11} y="34.5" textAnchor="middle" fontFamily="Segoe UI, Arial, sans-serif"
            fontWeight="700" fontSize={kucukYazi ? 10 : 13} fill="#fff">{d.etiket}</text>
      {/* satır çizgileri */}
      <path d="M26 26h6M26 30h6M26 34h6M8 41h24" stroke="#d5dbe3" strokeWidth="1.5" strokeLinecap="round" />
    </svg>
  );
}
