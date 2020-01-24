# Document NER
### NER (Name Entity Regonition) is a process of extracting information from unstructured text into pre-defined categories.

## NER Platforms
### spaCy is a open source python library for Natural Language Process.

## spaCy Named Entities
### spaCy can recognize various types of named entities in given document.

## Types:
##### PERSON, NORP, FAC, ORG, GPE, LOC, PRODUCT, EVENT, WORK_OF_ART, LAW, LANGUAGE, DATE, TIME, PERCENT, MONEY, QUANTITY, ORDINAL, CARDINAL .

### Example

```py

import spacy

nlp = spacy.load("en_core_web_sm")
doc = nlp("Apple is looking at buying U.K. startup for $1 billion")

for ent in doc.ents:
    print(ent.text, ent.start_char, ent.end_char, ent.label_)

```

### Output

```
py sample.py
Apple 0 5 ORG
U.K. 27 31 GPE
$1 billion 44 54 MONEY
```

### Example1

``` py

import spacy
import PyPDF2 

# Load English tokenizer, tagger, parser, NER and word vectors
nlp = spacy.load("en_core_web_sm")

doc_text = open(r"D:\NLP\NER\elango.pdf", 'rb')
pdfReader = PyPDF2.PdfFileReader(doc_text) 

doc = nlp(pdfReader.getPage(0).extractText())

print("Noun phrases:", [chunk.text for chunk in doc.noun_chunks])
print("Verbs:", [token.lemma_ for token in doc if token.pos_ == "VERB"])

for entity in doc.ents:
    print(entity.text, entity.label_, entity.start, entity.end)
```

### Output:
```
PS D:\NLP\NER> py sample.py

Noun phrases: ['S. Elango', 'Phone', 'Email', 'Career Objective', 'I', 'myself', 'a challenging environment', 'the \nexpectations', 'my superiors', 'my service', 'the \ncompany', 'an\nd', 'my skills', 'the \ndesire', 'new technologies', 'Education \n \n \nCourses', 'Institution \n \nBoard/University', 'Year', 'Aggregate', 'MCA \n \nCoimbatore Institute of \n \nTechnology', 'Coimbatore', 'Anna University', 'CGPA', 'BBA', '(CA', 'Rathnavel Subramaniam', 'College Arts & Science \n \nCollege', 'Sulur', 'Bharathiar University', '62.8%', 'HSC \n \nSLNM Hr', 'Sec', 'School', 'Coimbatore', 'State Board', '68%', 'SSLC \n \nSLNM Hr', 'Sec', 'School', 'Coimbatore', 'State Board', '71.2%', 'Product name', 'Student portal', 'Assignment and Exit survey', 'Description', 'Android application', 'Student portal', 'information', 'an \nindividual student', 'they', 'marks', 'attendance', 'feedbacks', 'courses', 'lectures', 'Technology', 'Android\n \n \nLanguages', 'Java', 'XML', 'Php', 'jQuery', 'HTML', 'CSS', 'JSON']
Verbs: ['enroll', 'will', 'work', 'provide', 'develop', 'have', 'learn', 'pass', 'pursue', 'project', 'provide', 'can', 'see', 'provide']
S. Elango PERSON 0 2
MCA

Coimbatore Institute of Technology ORG 85 92
Coimbatore GPE 94 96
2019 DATE 105 107
7.2 CARDINAL 111 112
BBA ORG 117 118
Sulur GPE 133 134
Bharathiar University ORG 140 142
2015 DATE 143 144
62.8% PERCENT 145 147
HSC ORG 148 149
SLNM Hr ORG 150 152
Sec ORG 153 154
Coimbatore GPE 158 159
State Board ORG 166 168
2012 DATE 169 170
68% PERCENT 171 173
Coimbatore GPE 185 186
State Board ORG 193 195
2010 DATE 196 197
71.2% PERCENT 198 200
Exit ORG 211 212
Student ORG 219 220
XML ORG 252 253
Php GPE 254 255
jQuery ORG 256 257
HTML ORG 258 259
CSS ORG 260 261
JSON ORG 262 263


