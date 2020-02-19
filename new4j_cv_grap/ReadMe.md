``` cql
// Create NLP Schema
CALL ga.nlp.createSchema()

// Set Defaule Language 
CALL ga.nlp.config.setDefaultLanguage('en')

// Create Pipeline
CALL ga.nlp.processor.addPipeline(
    {
        textProcessor: 'com.graphaware.nlp.processor.stanford.StanfordTextProcessor', 
        name: 'NER', 
        processingSteps: {
            tokenize: true, 
            ner: true, 
            dependency: false,
            coref: true,
            relations: true
        }, 
        stopWords: '+,result, all, during', 
        threadNumber: 20
    }
);

// Set default Pipeline
CALL ga.nlp.processor.pipeline.default('NER')

// Get Pipelines
CALL ga.nlp.processor.getPipelines()

// Extract Text from Pdf files
CALL ga.nlp.utils.walkdir("C:/Users/Elango/Music/resume", ".pdf")
YIELD filePath
WITH filePath
CALL ga.nlp.parser.pdf("file:///"+filePath) 
YIELD number, paragraphs
WITH filePath, apoc.text.join(paragraphs, ' ') AS paraText
WITH filePath, COLLECT(paraText) AS paraList
WITH filePath, apoc.text.join(paraList, ' ') AS textResult
MERGE(resume:Resume{path:filePath})
SET resume.text=textResult

// Extract Text from Docx files
CALL ga.nlp.utils.walkdir("C:/Users/Elango/Music/resume", ".docx")
YIELD filePath
WITH filePath
CALL ga.nlp.parser.word("file:///"+filePath) 
YIELD number, paragraphs
WITH filePath, apoc.text.join(paragraphs, ' ') AS paraText
WITH filePath, COLLECT(paraText) AS paraList
WITH filePath, apoc.text.join(paraList, ' ') AS textResult
MERGE(resume:Resume{path:filePath})
SET resume.text=textResult


// Extract Email and Phno using APOC Procedure
MATCH(r:Resume)
WITH r,
apoc.text.regexGroups(
    r.text,
    '[A-Za-z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}'
) AS email_list,
apoc.text.regexGroups(
    r.text,'\\s*(?:\\+?(\\d{1,3}))?[-. (]*(\\d{3})[-. )]*(\\d{3})[-. ]*(\\d{4})(?: *x(\\d+))?\\s*'
) AS phno_list
set r.email=coalesce(email_list[0][0],''), r.phno=coalesce(phno_list[0][0],'')

// Perform GraphAware NLP process
MATCH (r:Resume)
CALL ga.nlp.annotate({text: r.text, id: id(r)})
YIELD result
MERGE (r)-[:HAS_ANNOTATED_TEXT]->(result)
RETURN result

// Create Skill Index
CREATE INDEX ON :Skill(skill)

// Load Skill  
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/skill.csv' AS result
MERGE(skill:Skill{skill:result.skill})

// Create City, State Indexs
CREATE INDEX ON :City(name)
CREATE INDEX ON :State(name)

// Load Cities and States 
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/new4j_cv_grap/Cities.csv' AS row
MERGE(c:City{name:trim(row.City)})
MERGE(s:State{name:trim(row.State)})
MERGE(c)-[r:BELONGS_TO]->(s)

// Create Comapany Indexs
CREATE INDEX ON :Company(name);

// Load Companies Info 
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/new4j_cv_grap/Companies.csv' AS result
MERGE(company:Company{name:result.name})

// Mapping Resume to Organization
MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]-(t:Tag)
WHERE 'ORGANIZATION' in t.ne
WITH r,t.value as value
MATCH(c:Company)
WHERE toLower(c.name)= toLower(value)
MERGE(r)-[:HAS_WORKED_IN]->(c)

// Mapping Resume to Skill 
MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]-(s:Sentence)-[:HAS_TAG]->(t:Tag)
MATCH(sk:Skill)
WITH r,sk,t.value as value
UNWIND (split(toLower(value),',')) as tag
WITH r,sk,tag
WHERE sk.skill=tag 
MERGE(r)-[:HAS_SKILL]->(sk)

// Mapping Resume to Location 
MATCH(r:Resume)-[:HAS_ANNOTATED_TEXT]->(a:AnnotatedText)-[:CONTAINS_SENTENCE]->(s:Sentence)-[:HAS_TAG]-(t:Tag)
WHERE 'LOCATION' in t.ne
WITH r,t.value as value
MATCH(c:City)
WHERE toLower(c.name)=~ toLower(value)
MERGE(r)-[:IS_FROM]->(c)
```
