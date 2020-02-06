```sql
LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/person.csv' AS person
MERGE(id:Id{id:person.id})
MERGE(email:Email{email:person.email})
MERGE(phno:Phno{phno:person.phno})
MERGE(email)-[:HAVE_PHNO]->(phno)

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/skill.csv' AS skill
MERGE(sid:Sid{sid:skill.id})
MERGE(skil:Skill{skill:skill.skill})

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/person_skill.csv' AS person_skill
MERGE(pid:Pid{pid:person_skill.id})
MERGE(pemail:Pemail{pemail:person_skill.email})
MERGE(pskill:Pskill{pskill:person_skill.skill})
MERGE(pemail)-[:HAVE_SKILL]->(pskill)

MATCH(pemail {pemail:"elango.slnm@gmail.com"})-[:HAVE_SKILL]->(pskill) RETURN pskill
MATCH(pskill {pskill:"java"})<-[:HAVE_SKILL]-(pemail) RETURN pemail

LOAD CSV WITH HEADERS FROM 'https://raw.githubusercontent.com/ElangoSlnm/Training/master/cv_parse/cv_text.csv' AS resume
MERGE(email:Email {email:resume.email})
MERGE(text:Text {text:resume.text})
MERGE(email)-[:RESUME]->(text)


MATCH(email)-[:RESUME]->(text) WHERE email.email = "elango.slnm@gmail.com" RETURN email, text
```