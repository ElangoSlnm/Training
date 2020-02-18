//Graphaware procedures
CALL dbms.procedures() YIELD name, signature, description
WHERE name =~ 'ga.nlp.*'
RETURN name, signature, description ORDER BY name asc;

//Apoc procedures
CALL dbms.procedures() YIELD name, signature, description
WHERE name =~ 'apoc.*'
RETURN name, signature, description ORDER BY name asc;


//Define which language you will use in this database :
    CALL ga.nlp.config.setDefaultLanguage('en')

//CREATE Pipeline
CALL ga.nlp.processor.addPipeline({textProcessor: 'com.graphaware.nlp.processor.stanford.StanfordTextProcessor', name: 'NER', processingSteps: {tokenize: true, ner: true, dependency: false}, stopWords: '+,result, all, during', 
threadNumber: 60});

//Pipeline Components

=> Sentence Segmentation
=> Tokenization
=> StopWords Removal
=> Stemming
=> Part Of Speech Tagging
=> Named Entity Recognition


//set default pipeline
CALL ga.nlp.processor.pipeline.default('NER')
//Get pipelines

CALL ga.nlp.processor.getPipelines()

//Creating indexes
CREATE CONSTRAINT ON (n:AnnotatedText) ASSERT n.id IS UNIQUE;
CREATE CONSTRAINT ON (n:Tag) ASSERT n.id IS UNIQUE;
CREATE CONSTRAINT ON (n:Sentence) ASSERT n.id IS UNIQUE;
CREATE INDEX ON :Tag(value); 

// load resume data from pdf
CALL ga.nlp.utils.walkdir("/home/aneeshk/Downloads/kyc", ".pdf")
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
    textResult,'\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*'
) AS phno_list
MERGE(resume:Resume{path:filePath ,email:coalesce(email_list[0][0],''), phno:coalesce(phno_list[0][0],''), text:textResult})


// load resume data from docx
CALL ga.nlp.utils.walkdir("/home/aneeshk/Downloads/kyc", ".docx")
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
    textResult,'\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*'
) AS phno_list
MERGE(resume:Resume{path:filePath ,email:coalesce(email_list[0][0],''), phno:coalesce(phno_list[0][0],''), text:textResult})


// load skills

CREATE INDEX ON :Skill(skill)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/skill.csv' AS result
MERGE(skill:Skill{skill:result.skill})

//load cities,states
CREATE INDEX ON :City(name)
CREATE INDEX ON :State(name)
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/new4j_cv_grap/Cities.csv' AS row
MERGE(c:City{name:trim(row.City)})
MERGE(s:State{name:trim(row.State)})
MERGE(c)-[r:BELONGS_TO]->(s)

//load college,university,state,district
CREATE INDEX ON :State(name)
CREATE INDEX ON :College(name)
CREATE INDEX ON :District(name)
CREATE INDEX ON :University(name)

USING PERIODIC COMMIT 1000
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/new4j_cv_grap/Colleges.csv' AS row
MERGE (u:University{name:coalesce(row.`University Name`,'')})
MERGE (d:District{name:coalesce(row.`District Name`,'')})
MERGE (c:College{name:coalesce(row.`College Name`,'')})
MERGE (s:State{name:coalesce(row.`State Name`,'')})
MERGE (d)-[:BELONGS_TO]->(s)
MERGE (c)-[:IS_IN]-(d)
MERGE (c)-[:AFFILIATED_TO]->(u)

//load oganization info
CREATE INDEX ON :Company(name);
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/new4j_cv_grap/Companies.csv' AS result
MERGE(company:Company{name:result.name})

//perform text information extraction
MATCH (r:Resume)
CALL ga.nlp.annotate({text: r.text, id: id(r)})
YIELD result
MERGE (r)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN result


// mapping resume to skills
MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]-(s:Sentence)-[:HAS_TAG]->(t:Tag)
MATCH(sk:Skill)
WITH r,sk,t.value as value
UNWIND (split(toLower(value),',')) as tag
WITH r,sk,tag
WHERE sk.skill=tag 
MERGE(r)-[:HAS_SKILL]->(sk)
MERGE(r)-[:RELATED_TO]->(sk)
// Created 8584 relationships, completed after 436284 ms.



//mapping resume to location
MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]-(t:Tag)
WHERE 'LOCATION' in t.ne
WITH r,t.value as value
MATCH(c:City)
WHERE toLower(c.name)=~ toLower(value)
MERGE(r)-[:IS_FROM]->(c)
MERGE(r)-[:RELATED_TO]->(c)

//mapping resume to location
MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]-(t:Tag)
WHERE 'LOCATION' in t.ne
WITH r,t.value as value
MATCH(d:District)
WHERE toLower(d.name)=~ toLower(value)
MERGE(r)-[:IS_FROM]->(d)
MERGE(r)-[:RELATED_TO]->(d)


//creating person nodes and rel

CREATE INDEX ON :Person(name);

MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]-(t:Tag)
WHERE 'PERSON' in t.ne
WITH r,t.value as value
Match(c:City)
MATCH(sk:Skill)
WHERE (toLower(value) CONTAINS toLower(sk.skill)) and not (toLower(value) CONTAINS toLower(c.name))

MERGE(p:Person{name:value})
MERGE(p)-[:HAS_RESUME]->(r)
MERGE(p)-[:RELATED_TO]->(r)

MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]-(t:Tag)
WHERE 'ORGANIZATION' in t.ne
WITH r,t.value as value
MATCH(c:Company)
WHERE toLower(c.name)= toLower(value)
MERGE(r)-[:HAS_WORKED_IN]->(c)


```

"""MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)
Match(c:College)
WHERE toLower(s.text) CONTAINS toLower(c.name)
RETURN c.name
MERGE(r)-[:STUDIED_IN]->(c)
MERGE(r)-[:RELATED_TO]->(c)
"""

// Finding similarity
//Limit on the number of scores per node. The K largest results are returned.

CALL algo.nodeSimilarity('Resume|Skill|City|District|Company', 'RELATED_TO', {
  direction: 'OUTGOING',
  write:true,
  topK: 1000,
  similarityCutoff:0.6,
  concurrency:6,
  writeRelationshipType:"IS_SIMILAR_TO"

})
YIELD nodesCompared, relationships, write, writeRelationshipType, writeProperty, p1, p50, p99, p100;
