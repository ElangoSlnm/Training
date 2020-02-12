``` sql

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
LIMIT 1
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
    '((\\+|00)(\\d{1,3})[\\s-]?)?(\\d{10})|((\\+|00)(\\d{1,3})[\\s-]?)+(\\d{3} )+(\\d{4} )+(\\d{3})'
) AS phno_list
MERGE(email:Email{email:email_list[0][0]})
MERGE(phno:Phno{phno:phno_list[0][0]})
MERGE(text:Text{text:textResult})
MERGE(email)-[:HAS_TEXT]->(text)
MERGE(email)-[:HAS_PHNO]->(phno)

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
    '((\\+|00)(\\d{1,3})[\\s-]?)?(\\d{10})|((\\+|00)(\\d{1,3})[\\s-]?)+(\\d{3} )+(\\d{4} )+(\\d{3})'
) AS phno_list
MERGE(email:Email{email:email_list[0][0]})
MERGE(phno:Phno{phno:phno_list[0][0]})
MERGE(text:Text{text:textResult})
MERGE(email)-[:HAS_TEXT]->(text)
MERGE(email)-[:HAS_PHNO]->(phno)

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/skill.csv' AS result
MERGE(skill:Skill{skill:result.skill})

MATCH(e:Email)-[:HAS_TEXT]->(text)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]->(t:Tag)
WITH e, text, a, s, t
MATCH(sk:Skill)
WHERE toLower(sk.skill) = toLower(t.value)
MERGE(e)-[:HAS_SKILL]->(sk)



MATCH (e1:Email {email: 'elango.slnm@gmail.com'})-[:HAS_SKILL]->(skill)
WITH e1, collect(id(skill)) AS e1skill
MATCH (e2:Email {email: "aravind5107@gmail.com"})-[:HAS_SKILL]->(skill)
WITH e1, e1skill, e2, collect(id(skill)) AS e2skill
RETURN e1.email AS from,
       e2.email AS to,
       algo.similarity.jaccard(e1skill, e2skill) AS similarity


MATCH (e1:Email {email: 'elango.slnm@gmail.com'})-[:HAS_TEXT]->(text)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]->(t:Tag)
WITH e1, collect(id(t)) AS e1Tag
MATCH (e2:Email {email: "maransasi@gmail.com"})-[:HAS_TEXT]->(text)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]->(t:Tag)
WITH e1, e1Tag, e2, collect(id(t)) AS e2Tag
RETURN e1.email AS from,
       e2.email AS to,
       algo.similarity.jaccard(e1Tag, e2Tag) AS similarity


MATCH (e1:Email {email: 'maransasi@gmail.com'})-[:HAS_SKILL]->(skill)
WITH e1, collect(id(skill)) AS e1Skill
MATCH (e2:Email{email: 'gangadherchinta@gmail.com'})-[:HAS_SKILL]->(skill) WHERE e1 <> e2
WITH e1, e1Skill, e2, collect(id(skill)) AS e2Skill
RETURN e1.email AS from,
       e2.email AS to,
       algo.similarity.jaccard(e1Skill, e2Skill) AS similarity
ORDER BY similarity DESC


MATCH (e:Email)-[:HAS_SKILL]->(s:Skill)
WITH {item:id(e), categories: collect(id(s))} as userData
WITH collect(userData) as data
CALL algo.similarity.jaccard.stream(data, {topK: 1, similarityCutoff: 0.0})
YIELD item1, item2, count1, count2, intersection, similarity
RETURN algo.asNode(item1).email AS from, algo.asNode(item2).email AS to, intersection, similarity
ORDER BY similarity DESC

```
