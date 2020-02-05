from pdfminer.pdfinterp import PDFResourceManager, PDFPageInterpreter
from pdfminer.converter import TextConverter
from pdfminer.layout import LAParams
from pdfminer.pdfpage import PDFPage
from io import StringIO
import docx
import spacy
import re
from spacy.matcher import Matcher
import csv
from os import listdir
from os.path import isfile, join
nlp = spacy.load('en_core_web_sm')

def pdf_to_text(path):
    rsrcmgr = PDFResourceManager()
    retstr = StringIO()
    codec = 'utf-8'
    laparams = LAParams()
    device = TextConverter(rsrcmgr, retstr, codec=codec, laparams=laparams)
    fp = open(path, 'rb')
    interpreter = PDFPageInterpreter(rsrcmgr, device)
    password = ""
    maxpages = 0
    caching = True
    pagenos=set()

    for page in PDFPage.get_pages(fp, pagenos, maxpages=maxpages, password=password,caching=caching, check_extractable=True):
        interpreter.process_page(page)

    text = retstr.getvalue()

    fp.close()
    device.close()
    retstr.close()
    return text
    
def docx_to_text(path):
    text = textract.process(path)
    return str(text)
    
def extract_mobile_number(text):
    phone = re.findall(re.compile(r'(\d{2}[-\.\s]??\d{3}[-\.\s]??\d{3}[-\.\s]??\d{4}|\d{3}[-\.\s]??\d{3}[-\.\s]??\d{4}|\(\d{3}\)\s*\d{3}[-\.\s]??\d{4}\d{2}[-\.\s]??\d{3}[-\.\s]??\d{3}[-\.\s]??\d{4}|\d{3}[-\.\s]??\d{4}[-\.\s]??\d{3})'), text.replace('\n', '|'))
    if phone:
        number = ''.join(phone[0].replace(' ', ''))
        if len(number) > 10:
            return '+' + number
        else:
            return number
            
def extract_email(text):
    email = re.findall(r'[\w\.-]+@[\w\.-]+', text)
    if email:
        try:
            return email[0].split()[0].strip(';')
        except IndexError:
            return None
            
def extract_skills(text):
    texts = nlp(text)
    with open('techskill.csv', 'r') as f:
        reader = csv.reader(f)
        skill_list = next(reader)
    skills = []
    for text in texts:
        if text.text.strip().lower() in skill_list:
            skills.append(text.text.strip().lower())
    return list(set(skills))
    
persons = []
def parse_cv(path):
    parsed_cv_list = []
    for _file in listdir(path):
        if isfile(join(path, _file)):
            if _file.split('.')[-1].lower() == 'pdf':
                parsed_cv_list.append(pdf_to_txt(path+'/'+_file))
            else:
                parsed_cv_list.append(docx_to_text(path+'/'+_file))

    for parsed_cv in parsed_cv_list:
            email = extract_email(parsed_cv)
            mobile_no = extract_mobile_number(parsed_cv)
            skill = extract_skills(parsed_cv)
            persons.append([email, mobile_no, skill]) 
            
    with open('resume.csv', 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['id', 'email', 'phno', 'skill'])
        i=1
        for person in persons:
            writer.writerow([i,person[0], person[1], ','.join(person[2])])
            i+=1

parse_cv(r'C:\Users\Elango\Documents\resume')    
        
       
