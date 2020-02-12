``` sql

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

```
