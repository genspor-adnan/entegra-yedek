# -*- coding: utf-8 -*-
"""Koyu temada `.grp>h4` grup basligi acik gradyanla kaliyordu.

`body.koyu h5, .kutu h4, .panel>h3, .grph` icin koyu kural vardi ama
`.grp>h4` icin yoktu; computed backgroundColor saydam gorundugu icin
gozden kacmis — arka plani `background-image` (linear-gradient) tasiyor,
o da koyu temada olduğu gibi kaliyordu.

Isaretli blok, yeniden calistirilabilir.
"""
import io, glob, os, sys

IM = '/* === GN-KOYU-GRPBAS: grup basligi koyu tema === */'
SON = '/* === GN-KOYU-GRPBAS son === */'

BLOK = IM + '''
body.koyu .grp>h4{background:linear-gradient(#26313f,#1f2836)!important;
  color:#a8c0d8!important;border-bottom-color:#2c3542!important}
body.koyu .grp{background:#1b222c!important;border-color:#2c3542!important}
body.koyu .grp .tag{background:#2c3a4b!important;color:#9fc0e0!important}
body.koyu .imgbox{background:linear-gradient(135deg,#222b37,#1b232d)!important;
  border-color:#3b4a5c!important;color:#7f8fa1!important}
body.koyu .imgthumbs .t{border-color:#33404f!important}
''' + SON


def uygula(yol):
    s = io.open(yol, encoding='utf-8').read()
    if '.grp>h4{' not in s:
        return 'grp yok'
    if IM in s:
        b = s.index(IM); e = s.index(SON, b) + len(SON)
        while b > 0 and s[b - 1] == '\n': b -= 1
        while e < len(s) and s[e] == '\n': e += 1
        s = s[:b] + '\n' + s[e:]

    # koyu tema blogunun icine, son </style>'dan once
    ank = 'body.koyu h5,body.koyu .kutu h4'
    if ank not in s:
        return 'koyu blogu yok'
    i = s.index('</style>', s.index(ank))
    yeni = s[:i] + BLOK + '\n' + s[i:]
    if yeni == s:
        return 'degismedi'
    io.open(yol, 'w', encoding='utf-8').write(yeni)
    return 'tamam'


if __name__ == '__main__':
    kok = sys.argv[1] if len(sys.argv) > 1 else os.path.dirname(os.path.abspath(__file__))
    say = {}
    for f in sorted(glob.glob(os.path.join(kok, '*.html'))):
        d = uygula(f)
        say[d] = say.get(d, 0) + 1
    for k, v in sorted(say.items()):
        print('%-16s %d' % (k, v))
