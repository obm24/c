import re

with open(r'c:\Codes\Flutter\TnT\lib\core\custom_controls.dart', 'r', encoding='utf-8') as f:
    content = f.read()

def process_list(regex_pattern):
    match = re.search(regex_pattern, content, re.DOTALL)
    items_str = match.group(1)
    items = [line.strip().strip("',") for line in items_str.split('\n') if line.strip()]
    
    new_items = []
    desc_dict = {}
    
    for item in items:
        if ': ' in item:
            title, desc = item.split(': ', 1)
            new_items.append(title)
            desc_dict[title] = desc
        else:
            new_items.append(item)
            
    return items_str, new_items, desc_dict

injuries_str, new_injuries, inj_desc = process_list(r'  static final List<String> commonInjuries = \[(.*?)\];')
conditions_str, new_conditions, cond_desc = process_list(r'  static final List<String> commonConditions = \[(.*?)\];')

all_desc = {}
all_desc.update(inj_desc)
all_desc.update(cond_desc)

new_injuries_str = ',\n'.join(f"    '{inj}'" for inj in new_injuries)
new_conditions_str = ',\n'.join(f"    '{cond}'" for cond in new_conditions)

new_content = content.replace(injuries_str, '\n' + new_injuries_str + '\n  ')
new_content = new_content.replace(conditions_str, '\n' + new_conditions_str + '\n  ')

extra_desc_entries = []
for k, v in all_desc.items():
    v = v.replace("'", "\\'")
    extra_desc_entries.append(f"      '{k}':\n          '{v}',")

new_desc_str = '\n'.join(extra_desc_entries) + '\n\n'
injection_point = new_content.find('      // Thorough FNDDS Medical Injury Descriptions\n')
new_content = new_content[:injection_point] + new_desc_str + new_content[injection_point:]

with open(r'c:\Codes\Flutter\TnT\lib\core\custom_controls.dart', 'w', encoding='utf-8') as f:
    f.write(new_content)