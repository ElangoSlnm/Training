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
PS D:\NLP\NER> py test.py
Apple 0 5 ORG
U.K. 27 31 GPE
$1 billion 44 54 MONEY
PS D:\NLP\NER> 
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

Noun phrases: ['S. Elango\n \nPhone', 'Email', 'Career Objective', 'I', 'myself', 'a challenging environment', 'the \nexpectations', 'my superiors', 'my service', 'the \ncompany', 'an\nd', 'my skills', 'the \ndesire', 'new technologies', 'Education \n \n \nCourses', 'Institution \n \nBoard/University \n \nYear', 'MCA', 'Technology', 'Coimbatore', 'Anna University', '6 CGPA', 'BBA', '(CA', 'Rathnavel Subramaniam', 'College Arts', 'Science', 'College', 'Bharathiar University', '2015 \n \n62.8%', 'HSC \n \nSLNM Hr', 'Sec', 'School', 'Coimbatore', 'State Board', '68%', 'SSLC \n \nSLNM Hr', 'Sec', 'School', 'Coimbatore', 'State Board', '71.2%', 'Projects', 'Product name', 'Assignment and Exit survey', 'Description', 'Android application', 'information', 'an \nindividual student', 'they', 'marks', 'attendance', 'feedbacks', 'courses', 'lectures', 'Technology', 'Android\n \n \nLanguages \n \nJava', 'XML', 'Php', 'jQuery', 'HTML', 'CSS', 'JSON']
Verbs: ['enroll', 'challenge', 'will', 'work', 'provide', 'develop', 'have', 'learn', 'pass', 'provide', 'can', 'see', 'provide']

S. Elango PERSON 0 3
Year DATE 79 80
641 CARDINAL 98 99
014 CARDINAL 99 100
2019 DATE 105 106
6 CARDINAL 113 114
Sulur NORP 133 134
641402 DATE 137 138
Bharathiar University ORG 140 142
62.8% PERCENT 145 147
641 058 CARDINAL 162 164
2012 CARDINAL 169 170
68% PERCENT 171 173
SSLC ORG 174 175
641 058 CARDINAL 189 191
2010 CARDINAL 196 197
71.2% PERCENT 198 200
Exit ORG 211 212
XML ORG 252 253
Php GPE 254 255
jQuery ORG 256 257
JSON ORG 262 263

```
