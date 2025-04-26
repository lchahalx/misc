#!/usr/bin/env python3
import sys
import re
from docx import Document

def extract_text(docx_path):
    document = Document(docx_path)
    full_text = []
    for para in document.paragraphs:
        full_text.append(para.text)
    return "\n".join(full_text)

def find_special_characters(text):
    return set(re.findall(r'[^\w\s]', text))

def main():
    if len(sys.argv) != 2:
        print("Usage: python inspect_chars.py <path_to_docx_file>")
        sys.exit(1)

    docx_file = sys.argv[1]
    try:
        text_content = extract_text(docx_file)
        special_chars = find_special_characters(text_content)
        
        if special_chars:
            print(f"Special characters found: {special_chars}")
        else:
            print("No special characters found.")
    except Exception as e:
        print(f"Error processing file: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
