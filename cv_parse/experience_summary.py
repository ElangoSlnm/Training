# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%
import spacy
from spacy.lang.en import English
nlp = English()
nlp.add_pipe(nlp.create_pipe('sentencizer'))
import re


# %%
with open(r'D:\NLP\cv_parse\content.txt', 'r') as reader:
    doc_text = reader.read()


# %%
nlp_mdl = spacy.load("en_core_web_lg")


# %%
regex = re.compile(r'[\n\r\t\x0c]')
raw_text = regex.sub(' ', doc_text)
doc = nlp(raw_text)
sentences = [sent.string.strip() for sent in doc.sents if re.search('Experience|[\d]{1,2}/[\d]{1,2}/[\d]{4}|[\d]{1,2}-[\d]{1,2}-[\d]{2}|[ADFJMNOS]\w* [\d]{4}', str(sent), re.I)]


# %%
print(sentences)


# %%
experience = []
for sent in sentences:
    for ents in nlp_mdl(sent).ents:
        print(ents.text, ents.label_)
    # doc = nlp(sentences)

