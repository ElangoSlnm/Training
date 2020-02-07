```sql

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/cv_text.csv' AS resume
MERGE(email:Email {email:resume.email})
MERGE(text:Text {text:resume.text})
MERGE(email)-[:RESUME]->(text)

CREATE CONSTRAINT ON (n:AnnotatedText) ASSERT n.id IS UNIQUE;
CREATE CONSTRAINT ON (n:Tag) ASSERT n.id IS UNIQUE;
CREATE CONSTRAINT ON (n:Sentence) ASSERT n.id IS UNIQUE;
CREATE INDEX ON :Tag(value);

CALL ga.nlp.createSchema()

CALL dbms.procedures() YIELD name, signature, description
WHERE name =~ 'ga.nlp.*'
RETURN name, signature, description ORDER BY name asc;

CALL ga.nlp.processor.addPipeline({textProcessor: 'com.graphaware.nlp.processor.stanford.StanfordTextProcessor', name: 'customStopWords', processingSteps: {tokenize: true, ner: true, dependency: false}, stopWords: '+,result, all, during', 
threadNumber: 20})

CALL ga.nlp.processor.pipeline.default('customStopWords)

MATCH(email)-[:RESUME]->(text) WHERE email.email = "elango.slnm@gmail.com" RETURN email, text

MATCH (n:text)
CALL ga.nlp.annotate({text: text.text, id: id(text)})
YIELD result
MERGE (n)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN result
```
