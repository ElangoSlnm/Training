```sql
CREATE CONSTRAINT ON (n:AnnotatedText) ASSERT n.id IS UNIQUE;
CREATE CONSTRAINT ON (n:Tag) ASSERT n.id IS UNIQUE;
CREATE CONSTRAINT ON (n:Sentence) ASSERT n.id IS UNIQUE;
CREATE INDEX ON :Tag(value); 

CALL ga.nlp.config.setDefaultLanguage('en')

CALL ga.nlp.processor.addPipeline({textProcessor: 'com.graphaware.nlp.processor.stanford.StanfordTextProcessor', name: 'customStopWords', processingSteps: {tokenize: true, ner: true, dependency: false}, stopWords: '+,result, all, during', 
threadNumber: 20})

CALL ga.nlp.processor.pipeline.default('customStopWords')

CALL ga.nlp.utils.walkdir("C:/Users/Elango/Documents/resume/", ".pdf")
YIELD filePath
WITH filePath
CALL ga.nlp.parser.pdf("file:///"+filePath) 
YIELD number, paragraphs
WITH filePath, apoc.text.join(paragraphs, ' ') AS paraText
WITH filePath, COLLECT(paraText) AS paraList
WITH filePath, apoc.text.join(paraList, ' ') AS textResult
WITH filePath, textResult,
apoc.text.regexGroups(
    textResult,
    '[A-Za-z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}'
) AS email_list,
apoc.text.regexGroups(
    textResult,
    '((\\+|00)(\\d{1,3})[\\s-]?)?(\\d{10})|((\\+|00)(\\d{1,3})[\\s-]?)?+(\\d{3} )+(-)?+(\\d{4} )+(-)?+(\\d{3} )|((\\+|00)(\\d{1,3} )[\\s-]?)?+(\\d{5} )+(-)?+(\\d{5} )|((\\+|00)(\\d{1,3})[\\s-]?)?+(-)?+(\\d{4} )+(-)?+(\\d{3} )+(-)?+(\\d{3} )'
) AS phno_list
MERGE(resume:Resume{path:filePath ,email:email_list[0][0], phno:phno_list[0][0], text:textResult})

CALL ga.nlp.utils.walkdir("C:/Users/Elango/Documents/resume/", ".docx")
YIELD filePath
WITH filePath
CALL ga.nlp.parser.word("file:///"+filePath) 
YIELD number, paragraphs
WITH filePath, apoc.text.join(paragraphs, ' ') AS paraText
WITH filePath, COLLECT(paraText) AS paraList
WITH filePath, apoc.text.join(paraList, ' ') AS textResult
WITH filePath, textResult,
apoc.text.regexGroups(
    textResult,
    '[A-Za-z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}'
) AS email_list,
apoc.text.regexGroups(
    textResult,
    '((\\+|00)(\\d{1,3})[\\s-]?)?(\\d{10})|((\\+|00)(\\d{1,3})[\\s-]?)?+(\\d{3} )+(-)?+(\\d{4} )+(-)?+(\\d{3} )|((\\+|00)(\\d{1,3} )[\\s-]?)?+(\\d{5} )+(-)?+(\\d{5} )|((\\+|00)(\\d{1,3})[\\s-]?)?+(-)?+(\\d{4} )+(-)?+(\\d{3} )+(-)?+(\\d{3} )'
) AS phno_list
MERGE(resume:Resume{path:filePath ,email:email_list[0][0], phno:phno_list[0][0], text:textResult})

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/skill.csv' AS result
MERGE(skill:Skill{skill:result.skill})

MATCH (n:Resume)
CALL ga.nlp.annotate({text: n.text, id: id(n)})
YIELD result
MERGE (n)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN result

MATCH(n:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]->(t:Tag)
WITH n, a, s, t
MATCH(sk:Skill)
WHERE toLower(sk.skill) = toLower(t.value)
MERGE(n)-[:HAS_SKILL]->(sk)
```
