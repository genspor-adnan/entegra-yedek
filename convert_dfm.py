#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
DFM dosyasını binary'den text'e çevirir ve ADO->FireDAC dönüşümü yapar
"""

import sys
import re

def binary_to_text_dfm(input_file, output_file):
    try:
        with open(input_file, 'rb') as f:
            content = f.read()
        
        # Check if binary (starts with TPF0)
        if content[:4] == b'TPF0':
            print(f"Binary DFM detected: {input_file}")
            # Binary format - decode as latin-1 to preserve bytes
            text_content = content.decode('latin-1', errors='replace')
        else:
            print(f"Text DFM detected: {input_file}")
            text_content = content.decode('utf-8', errors='replace')
        
        # Convert binary markers to readable text
        # TPF0 header'ı kaldır ve object ile başla
        if text_content.startswith('TPF0'):
            text_content = text_content[4:]  # Remove TPF0 header
            
        # Replace common binary markers
        replacements = [
            ('TADOQuery', 'TFDQuery'),
            ('TADOTable', 'TFDTable'),
            ('TADOCommand', 'TFDCommand'),
            ('TADOConnection', 'TFDConnection'),
            ('TADOStoredProc', 'TFDStoredProc'),
            ('TADODataSet', 'TFDMemTable'),
        ]
        
        for old, new in replacements:
            text_content = text_content.replace(old, new)
        
        # Remove ADO-specific properties
        lines = text_content.split('\n')
        filtered_lines = []
        
        for line in lines:
            # Remove problematic properties
            if any(prop in line for prop in [
                'CursorType', 'LockType', 'CommandTimeout', 
                'OnRecordsetCreate', 'ConnectionName'
            ]):
                continue
            # Keep Connection but remove if it's ConnectionName
            if 'ConnectionName' in line:
                line = line.replace('ConnectionName', 'Connection')
            filtered_lines.append(line)
        
        final_content = '\n'.join(filtered_lines)
        
        # Ensure proper text format
        # Add object declaration if missing
        if not final_content.strip().startswith('object'):
            # Try to find the form object
            match = re.search(r'(TDokumDlg|T\w+)', final_content)
            if match:
                form_name = match.group(1)
                # Find first occurrence and wrap with object
                final_content = f'object {form_name}: {form_name}\n' + final_content
        
        with open(output_file, 'w', encoding='utf-8') as f:
            f.write(final_content)
        
        print(f"Converted: {output_file}")
        return True
        
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: convert_dfm.py <input.dfm> <output.dfm>")
        sys.exit(1)
    
    success = binary_to_text_dfm(sys.argv[1], sys.argv[2])
    sys.exit(0 if success else 1)
