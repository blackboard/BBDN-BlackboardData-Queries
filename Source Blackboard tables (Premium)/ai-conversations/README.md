# AI Conversations Data Structure

This folder contains queries for extracting and analyzing AI conversation data from Blackboard Learn. AI Conversations (also known as AI Chat questions) are interactive assessments where students engage with AI-powered chatbots configured with specific roles and personas.

## Overview

### Data Structure

AI Conversation data in Blackboard is stored across multiple tables with a hierarchical structure:

```
QTI_ASI_DATA (Assessment/Question Definition)
├── Main Assessment (bbmd_assessment_subtype = 'AiConversation')
│   ├── Section (parent_pk1 → Main Assessment)
│   │   └── Individual Questions (parent_pk1 → Section)
│   
QTI_RESULT_DATA (Student Responses)
├── Assessment Results
│   ├── Section Results  
│   │   └── Question Results (contains conversation messages)
```

### Key Tables

**QTI_ASI_DATA**: Stores assessment and question definitions
- `bbmd_assessment_subtype = 'AiConversation'` identifies AI conversation assessments
- `bbmd_questiontype = 21` identifies AI Chat question type
- Contains XML data with bot configuration (name, role, question type)
- Has hierarchical parent-child relationships for assessments → sections → questions

**QTI_RESULT_DATA**: Stores student responses and conversation data
- Contains XML data with actual conversation messages
- Messages formatted as: `<message_source>,<uuid>,<timestamp_ms>,<additional_data>,<message_content>`
- Message types include: `Student`, `Bot`, `KeyPoint`
- Hierarchical structure matches QTI_ASI_DATA

**Related Tables**:
- `COURSE_MAIN`: Course information
- `ATTEMPT`: Student attempt records
- `GRADEBOOK_GRADE`/`GRADEBOOK_MAIN`: Grading information
- `COURSE_USERS`: Links courses to users
- `USERS`: Student/user information

### XML Data Structure

AI conversation data is stored as XML in the `data` column. Key elements:

**QTI_ASI_DATA XML**:
- `<itemproc_extension>` → Contains bot configuration
  - `<chatQuestionType>`: Type of conversation (e.g., "RolePlay", "Questioning")
  - `<botName>`: Name of the AI bot
  - `<botRole>`: Role/persona of the bot
  - `<botAcademicLevel>`: Academic level setting
- `<presentation>` → Contains question text and prompts
  - `<flow class="QUESTION_BLOCK">` → Question content area
    - `<mat_formattedtext>`: HTML-formatted question text

**QTI_RESULT_DATA XML**:
- `<response_value>`: Contains comma-separated conversation messages
  - Format: `Source,UUID,Timestamp,Data,Message`
  - Sources: `Student`, `Bot`, `KeyPoint`
- `<formatted_text>`: Reflection answers (for reflection questions)

### Message Format

Conversation messages in `QTI_RESULT_DATA` are stored as CSV-like strings:
```
<response_value>Student,uuid-here,1234567890,additional-data,Hello, how are you?</response_value>
<response_value>Bot,uuid-here,1234567891,additional-data,I'm doing well, thank you!</response_value>
```

## Example Queries

The queries in this folder serve as an example of querying AI Conversation data.

### [get-all-conversation-data](get-all-conversation-data/query.sql)
Returns the complete conversation history between students and AI bots, including all messages exchanged.

**Returns**: Individual conversation messages with timestamps, student information, bot configuration, grades, and attempt status. Filters for actual `Student` and `Bot` messages only.

**Use Case**: Analyzing conversation patterns, reviewing student-bot interactions, extracting conversation transcripts.

---

### [get-all-ai-assessments](get-all-ai-assessments/query.sql)
Retrieves all AI conversation assessments with their hierarchical structure (assessment → section → question).

**Returns**: Assessment metadata including section details, question information, conversation messages, bot configuration, and organizational structure.

**Use Case**: Understanding the full structure of AI assessments, analyzing how assessments are organized.

---

### [get-ai-assessment-questions](get-ai-assessment-questions/query.sql)
Extracts the actual question prompts/text from AI conversation assessments.

**Returns**: The formatted question text that students see when starting an AI conversation, linked to assessment and section identifiers.

**Use Case**: Reviewing what questions are being asked, analyzing question design, documenting assessment content.

---

### [get-ai-assessment-reflection](get-ai-assessment-reflection/query.sql)
Retrieves student reflection responses that may be included after AI conversations.

**Returns**: Student-written reflection text from questions that include a reflection component (contains `<formatted_text>` in responses).

**Use Case**: Analyzing student reflections on their AI interactions, assessing metacognitive responses.

---

### [get-conversation-types](get-conversation-types/query.sql)
Lists all AI conversation questions with their configuration types.

**Returns**: Question identifiers with `chat_question_type` (e.g., "RolePlay", "Questioning"), title, description, and AI generation flag.

**Use Case**: Categorizing conversations by type, identifying patterns in conversation design.

---

### [get-keypoints-for-conversations](get-keypoints-for-conversations/query.sql)
Extracts key points highlighted during AI conversations.

**Returns**: Messages marked as `KeyPoint` entries, which are important concepts or insights identified during conversations.

**Use Case**: Analyzing learning objectives, tracking key concepts covered, evaluating conversation effectiveness.

---

### [get-title-of-conversations](get-title-of-conversations/query.sql)
Simple query to retrieve titles and descriptions of all AI conversation questions.

**Returns**: Question title, description, primary key, and creation timestamp.

**Use Case**: Creating an inventory of AI conversations, cataloging available conversations.

---

### [number-of-ai-assessements-per-course](number-of-ai-assessements-per-course/query.sql)
Counts how many AI conversation assessments exist in each course.

**Returns**: Course name, course ID, and count of AI conversations per course.

**Use Case**: Reporting on AI conversation adoption across courses, identifying heavy users of AI conversations.

---

### [number-of-questions-per-user](number-of-questions-per-user/query.sql)
Counts how many messages each student sent in their AI conversations for a specific course.

**Returns**: Student information with count of messages sent.

**Parameters**: Requires `{coursepk}` to be set to a specific course primary key.

**Use Case**: Measuring student engagement with AI conversations, identifying active vs. passive participants.

---

### [join-learn-ai-data-to-cdm-lms](join-learn-ai-data-to-cdm-lms/query.sql)
Demonstrates how to join AI conversation data from the LEARN schema to the CDM_LMS schema.

**Returns**: AI conversation questions with chat type, title, description, and full course details from the CDM_LMS.COURSE table.

**Key Feature**: Shows the pattern for joining raw LEARN tables to CDM_LMS tables using `source_id` as the join key (e.g., `CDM_LMS.COURSE.source_id = LEARN.QTI_ASI_DATA.crsmain_pk1`).

**Use Case**: Enriching AI conversation data with standardized course information from the Canonical Data Model, integrating LEARN and CDM_LMS data sources.

---



## Common Patterns

### Working with XML Data
Most queries used to pull out AI conversation data will need to parse XML using Snowflake's XML functions:
```sql
TRY_CAST(PARSE_XML(IFF(CHECK_XML(data) IS NULL, data, NULL)) AS VARIANT)
XMLGET(xml_obj, 'element_name'):"$"::STRING
```

### Flattening Conversation Messages
Conversations are extracted using `LATERAL FLATTEN`:
```sql
LATERAL FLATTEN(input => qrd_obj:"$") f
LATERAL FLATTEN(input => f.value:"$") r
WHERE STARTSWITH(r.value, '<response_value')
```

### Parsing Message Components
Messages are parsed using string functions:
```sql
SPLIT_PART(raw_message, ',', 1) AS message_source  -- Student/Bot/KeyPoint
SPLIT_PART(raw_message, ',', 3) AS timestamp_ms    -- Timestamp
REGEXP_REPLACE(raw_message, '^[^,]+,[^,]+,[^,]+,[^,]+,', '') AS message_content
```

### Hierarchical Table Joins
AI assessments require joining through the hierarchy:
```sql
FROM LEARN.QTI_ASI_DATA qad  -- Main assessment
LEFT JOIN LEARN.QTI_ASI_DATA section_qad ON section_qad.parent_pk1 = qad.pk1
LEFT JOIN LEARN.QTI_ASI_DATA assess_qad ON assess_qad.parent_pk1 = section_qad.pk1
LEFT JOIN LEARN.QTI_RESULT_DATA qrd ON qrd.qti_asi_data_pk1 = assess_qad.pk1
```

## Notes

- AI Conversations are identified by `bbmd_assessment_subtype = 'AiConversation'` or `bbmd_questiontype = 21`
- Message timestamps are in milliseconds and need conversion: `TO_TIMESTAMP(timestamp_ms / 1000)`
- Not all conversations have reflections or keypoints
- The `ai_state` field indicates whether the question was AI-generated
- XML parsing requires error handling due to potential malformed XML
