import spacy
from spacy.lang.en import English
nlp = English()
import re
nlp.add_pipe(nlp.create_pipe('sentencizer'))
nlp_lg = spacy.load("en_core_web_lg")

with open(r'D:\NLP\cv_parse\ashutosh.txt', 'r') as reader:
    doc_text = reader.read()

regex = re.compile(r'[\r\t\x0c]')
raw_text = regex.sub(' ', doc_text)
doc = nlp(raw_text)
sentences = [sent.string.strip() for sent in doc.sents if re.search('Experience|[ADFJMNOS]\w* [\d]{4}|[ADFJMNOS]\w*-[\d]{4}', str(sent), re.I)]

experience_list = []
for sent_ in sentences:
    for sent in sent_.split('.'):
        experience = []
        date = []
        org = []
        for ents in nlp_lg(sent.replace('\n',' ').replace('-', ' ').replace('   ',' ').replace('  ', ' ').replace('\t', ' ')).ents:
            if ents.label_ == 'DATE' and re.search('[ADFJMNOS]\w* [\d]{4}|year|mont|date', str(ents.text), re.I):
                date.append(ents.text)
            elif ents.label_ == 'ORG':
                org.append(ents.text)
        if len(date)>0 and len(org) >0:
            experience.append(' - '.join(date))
            experience.append(', '.join(org))
        if len(experience)>0:
            experience_list.append(experience)

print(experience_list)
