import re

def extract_components(dfm_path, components_to_extract, output_path):
    with open(dfm_path, 'r', encoding='utf-8', errors='ignore') as f:
        lines = f.readlines()

    extracted_content = []
    remaining_content = []
    
    current_object_lines = []
    extracting = False
    object_depth = 0
    
    # Regex to identify object start: "  object Name: Type"
    # We assume top level objects in DataModule are indented by 2 spaces
    obj_start_pattern = re.compile(r'^\s{2}object\s+([a-zA-Z0-9_]+):')
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        # Check if this is a top-level object start
        match = obj_start_pattern.match(line)
        if match and object_depth == 0:
            name = match.group(1)
            if name in components_to_extract:
                extracting = True
                current_object_lines = [line]
                object_depth = 1
                i += 1
                continue
        
        if extracting:
            current_object_lines.append(line)
            # Check for nested objects
            if re.match(r'^\s*object\s+', line): # Any indentation
                object_depth += 1
            elif re.match(r'^\s*end\s*$', line) or re.match(r'^\s*end$', line):
                object_depth -= 1
            
            if object_depth == 0:
                # Finished extracting this object
                extracted_content.extend(current_object_lines)
                extracting = False
                current_object_lines = []
        else:
            remaining_content.append(line)
            
        i += 1

    with open(output_path, 'w', encoding='utf-8') as f:
        f.writelines(extracted_content)
        
    # We won't overwrite the original file yet, just return the extracted part
    return len(extracted_content)

components = [
    "cxStilTanimlari",
    "cxEditRepository1",
    "cxEditRepository2",
    "cxStyleRepository3",
    "PngImageListTicari",
    "KlasorResimleri",
    "cxImageList1",
    "cxImageList2"
]

extract_components('c:/Entegra/Entegra/Utablo.dfm', components, 'c:/Entegra/Entegra/extracted_components.txt')
