#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""DFM dosyasını text formatına çevirip ADO->FireDAC dönüşümü yapar"""

import sys
import struct

def convert_dfm(input_file, output_file):
    with open(input_file, 'rb') as f:
        content = f.read()
    
    # Check if binary (starts with specific signature)
    is_binary = content[:4] == b'TPF0'
    
    if is_binary:
        print(f"Binary DFM detected: {input_file}")
        # Try to read as text after TPF0 header
        try:
            # Skip binary header and try UTF-8 decode
            text_content = content[4:].decode('utf-8', errors='ignore')
        except:
            text_content = content.decode('utf-8', errors='ignore')
    else:
        text_content = content.decode('utf-8', errors='ignore')
    
    # Replace ADO components with FireDAC
    replacements = [
        (b'TADOQuery', b'TFDQuery'),
        (b'TADOTable', b'TFDTable'),
        (b'TADOCommand', b'TFDCommand'),
        (b'TADOConnection', b'TFDConnection'),
        (b'TADOStoredProc', b'TFDStoredProc'),
        (b'TADODataSet', b'TFDMemTable'),
        (b'Connection\t', b'ConnectionName\t'),
    ]
    
    result = content if is_binary else content
    
    # Do replacements on bytes
    for old, new in replacements:
        result = result.replace(old, new)
    
    # Remove ADO-specific properties (as text)
    import re
    text_result = result.decode('utf-8', errors='ignore')
    
    # Remove lines with CursorType, LockType, CommandTimeout, OnRecordsetCreate
    lines = text_result.split('\n')
    filtered_lines = []
    for line in lines:
        if not any(prop in line for prop in ['CursorType', 'LockType', 'CommandTimeout', 'OnRecordsetCreate']):
            filtered_lines.append(line)
    
    final_result = '\n'.join(filtered_lines)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write(final_result)
    
    print(f"Converted: {output_file}")

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: fix_dfm.py <input.dfm> <output.dfm>")
        sys.exit(1)
    
    convert_dfm(sys.argv[1], sys.argv[2])
