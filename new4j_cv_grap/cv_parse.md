``` sql
CALL ga.nlp.utils.walkdir("C:/Users/Elango/Documents/resume/", ".pdf")
YIELD filePath
WITH filePath
CALL ga.nlp.parser.pdf("file:///"+filePath) 
YIELD number, paragraphs
WITH filePath AS filePath1, apoc.text.join(paragraphs, ' ') AS paraText
WITH filePath1 AS filePath2, COLLECT(paraText) AS paraList
WITH filePath2 AS filePath3, apoc.text.join(paraList, ' ') AS textResult
WITH filePath3 AS filePath4, textResult AS text, apoc.text.regexGroups(
    textResult,
    '[A-Za-z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}'
) AS email,
apoc.text.regexGroups(
    textResult,
    '((\\+|00)(\\d{1,3})[\\s-]?)?(\\d{10})|((\\+|00)(\\d{1,3})[\\s-]?)+(\\d{3} )+(\\d{4} )+(\\d{3})'
) AS phno
RETURN email[0][0], phno[0][0], text
```
