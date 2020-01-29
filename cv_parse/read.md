## Parse CV

```sh
py cv_parse.py D:\NLP\NER\praveen.pdf
```

``` py
from pdfminer.converter import TextConverter
from pdfminer.pdfinterp import PDFPageInterpreter
from pdfminer.pdfinterp import PDFResourceManager
from pdfminer.layout import LAParams
from pdfminer.pdfpage import PDFPage
from spacy.matcher import Matcher
import PyPDF2
import spacy
import nltk
import json
import sys
import csv
import re
import io

def extract_text_from_pdf(pdf_path):
    with open(pdf_path, 'rb') as fh:
        # iterate over all pages of PDF document
        for page in PDFPage.get_pages(fh, caching=True, check_extractable=True):
            # creating a resoure manager
            resource_manager = PDFResourceManager()
            # create a file handle
            fake_file_handle = io.StringIO()
            # creating a text converter object
            converter = TextConverter(resource_manager, fake_file_handle, codec='utf-8', laparams=LAParams())
            # creating a page interpreter
            page_interpreter = PDFPageInterpreter( resource_manager, converter)
            # process current page
            page_interpreter.process_page(page)
            # extract text
            text = fake_file_handle.getvalue()
            yield text
            # close open handles
            converter.close()
            fake_file_handle.close()

def extract_text_from_cv(path):
    doc_text = ''
    with open(path, 'rb') as f:
        doc_pdf = f
        pdfReader = PyPDF2.PdfFileReader(doc_pdf)
        doc_text += ''.join(pdfReader.getPage(
            page_num).extractText() for page_num in  range(pdfReader.getNumPages()))
    return doc_text

def extract_name(text):
    nlp = spacy.load('en_core_web_sm')
    matcher = Matcher(nlp.vocab)
    nlp_text = nlp(text.strip())
#     print([ (token.text, token.pos_) for token in nlp_text]) # -debugging 
    pattern = [{'POS': {"IN": ["PROPN", "ADJ"]}},
               {'POS':"SPACE", 'OP':"?" }, 
               {'POS': "PROPN"}]
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

def extract_experience(text):
    experience = list()
    lines = [el.strip() for el in text.split('\n') if len(el)>0]

    for sen in lines[:]:
        if re.search('Experience', sen, re.I):
            sen_tokenised = nltk.word_tokenize(sen)
            tagged = nltk.pos_tag(sen_tokenised)
            entities = nltk.chunk.ne_chunk(tagged)
            for subtree in entities.subtrees():
                leaves = subtree.leaves()
                for idx, _ in enumerate(leaves):
                    if idx < len(subtree.leaves())-1:
                        if leaves[idx][1] == 'CD' and leaves[idx+1][1] in ['NN', 'NNS']:
                            experience.append(' '.join([leaves[idx][0], leaves[idx+1][0]]))

    return ' and '.join(experience)    

def main(argv):
    doc_text = ''
    for page in extract_text_from_pdf(argv[1]):
        doc_text += ' ' + page
    json_data = {}
    json_data['name'] = extract_name(doc_text)
    json_data['phone'] = extract_mobile_number(doc_text)
    json_data['email'] = extract_email(doc_text)
    json_data['skills'] = extract_skills(doc_text)
    json_data['experience'] = extract_experience(doc_text)
    print(json.dumps(json_data, ensure_ascii=False, indent=4))
    with open('data.json', 'w', encoding='utf-8') as f:
        json.dump(json_data, f, ensure_ascii=False, indent=4)

if __name__ == "__main__":
    main(sys.argv)

```

### Output

```json
{
    "name": "Anurekha K",
    "phone": "+917092460496",
    "email": "anupriya.0730@gmail.com",
    "skills": [
        "C++",
        "java",
        "Java",
        "Pycharm",
        "MySQL",
        "C",
        "money",
        "Visual",
        "Python",
        "python",
        "algorithms",
        "Spyder",
        "MATLAB",
        "Algorithms"
    ],
    "experience": "2 year and 2 months"
}
```
