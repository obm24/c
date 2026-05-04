import re

with open(r'c:\Codes\Flutter\TnT\lib\features\dashboard_screens.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if line.startswith('// ======') or line.startswith('// ------'):
        print(f"{i}: {lines[i+1].strip() if i+1 < len(lines) else ''}")
