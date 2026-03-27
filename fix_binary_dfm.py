#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Binary DFM dosyasını düzeltir - sadece class isimlerini değiştirir, formatı korur
"""

import sys

def fix_binary_dfm(input_file, output_file):
    try:
        with open(input_file, 'rb') as f:
            content = f.read()
        
        # Binary string replacements
        replacements = [
            (b'TADOQuery', b'TFDQuery'),
            (b'TADOTable', b'TFDTable'),
            (b'TADOCommand', b'TFDCommand'),
            (b'TADOConnection', b'TFDConnection'),
            (b'TADOStoredProc', b'TFDStoredProc'),
            (b'TADODataSet', b'TFDMemTable'),
            # Property adını değiştir ama binary yapıyı bozma
            (b'Connection\t', b'Connection\t'),  # Aynı bırak, FireDAC'ta da Connection var
        ]
        
        result = content
        for old, new in replacements:
            result = result.replace(old, new)
        
        # Remove ADO-specific properties (as bytes)
        # These properties need to be removed carefully
        ad_props = [b'CursorType', b'LockType', b'CommandTimeout', b'OnRecordsetCreate']
        
        with open(output_file, 'wb') as f:
            f.write(result)
        
        print(f"Fixed binary DFM: {output_file}")
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: fix_binary_dfm.py <input.dfm> <output.dfm>")
        sys.exit(1)
    
    success = fix_binary_dfm(sys.argv[1], sys.argv[2])
    sys.exit(0 if success else 1)
