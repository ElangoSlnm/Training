## Parse CV

```sh
py cv_parse.py D:\NLP\NER\praveen.pdf
```

``` py
from spacy.matcher import Matcher
import numpy as np
import PyPDF2
import spacy
import json
import sys
import csv
import re

def extract_text_from_cv(path):
    doc_pdf = open(path, 'rb')
    pdfReader = PyPDF2.PdfFileReader(doc_pdf)
    doc_text = ''.join(pdfReader.getPage(page_num).extractText().replace('\n','') for page_num in  range(pdfReader.getNumPages()))
    return doc_text

def extract_name(text):
    nlp = spacy.load('en_core_web_sm')
    matcher = Matcher(nlp.vocab)
    nlp_text = nlp(text)
    pattern = [{'POS': "PROPN"}, {'POS': "PROPN"}]
    matcher.add('NAME', None, pattern)
    matches = matcher(nlp_text)
    
    for match_id, start, end in matches:
        span = nlp_text[start:end]
        return span.text

def extract_mobile_number(text):
    phone = re.findall(re.compile(r'(?:(?:\+?([1-9]|[0-9][0-9]|[0-9][0-9][0-9])\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([0-9][1-9]|[0-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?'), text)
    if phone:
        number = ''.join(phone[0])
        if len(number) > 10:
            return '+' + number
        else:
            return number\
        
def extract_email(text):
    email = re.findall(r'[\w\.-]+@[\w\.-]+', text)
    if email:
        try:
            return email[0].split()[0].strip(';')
        except IndexError:
            return None

def extract_skills(text):
    with open('techskill.csv', 'r') as f:
        reader = csv.reader(f)
        skill_list = next(reader)
    skills = []
    for word in re.split(',| ',text):
        if word.lower() in skill_list:
            skills.append(word.rstrip(','))
    return list(set(skills))

def main(argv):
    doc_text = extract_text_from_cv(argv[0])
    print(doc_text)
    json_data = {}
    json_data['name'] = extract_name(doc_text)
    json_data['phone number'] = extract_mobile_number(doc_text)
    json_data['email id'] = extract_email(doc_text)
    json_data['skills'] = extract_skills(doc_text)
    print(json.dumps(json_data, ensure_ascii=False, indent=4))
    with open('data.json', 'w', encoding='utf-8') as f:
        json.dump(json_data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main(sys.argv[1:])

```

### Output

```json
{
    "name": "Praveen P",
    "phone number": "+91887048308",
    "email id": "ppraveen996@gmail.com",
    "skills": [
        "JAVA",
        "C++",
        "P",
        "Visual",
        "C"
    ]
}
```