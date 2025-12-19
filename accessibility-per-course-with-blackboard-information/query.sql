-- The goal of this query is to connect Ally and Blackboard data
-- This query returns the accesibility score of courses and information of courses from Blakcboard including course ID and instructors
SELECT

    ROUND(a_cs.numeric_score, 2) AS Course_AX_Score,

-- Course information from Blackboard
    lms_c.name AS Course_Name,
    lms_c.course_number AS course_ID,
    lms_c.id AS course_Identifier,
    lms_c.design_mode AS Design_mode,
    
-- List of all instructors in the course first name + last name + (user id)
    LISTAGG(lms_p.first_name || ' ' || lms_p.last_name ||'(' || lms_p.stage:"user_id"::STRING ||')' , ', ') 
        WITHIN GROUP (ORDER BY lms_p.last_name, lms_p.first_name) AS Instructors,

-- Information from Ally
    a_t.name AS a_t_name,
    a_cs.course_id AS a_cs_course_id,
    a_d.name AS d_name,
   
    
FROM CDM_ALY.course_score a_cs

-- Joins with ally tables

JOIN CDM_ALY.course a_c
    ON a_c.id = a_cs.course_id
    
left JOIN CDM_ALY.term a_t
    ON a_c.term_id = a_t.id

left JOIN CDM_ALY.course_department a_cd
    ON a_cd.course_ID=a_c.ID

left JOIN CDM_ALY.department a_d
    ON a_d.id=a_cd.department_id

left join cdm_map.course map_c
    ON map_c.aly_course_id = a_c.id

        
-- Join between ally and Blackboard tables
        
left join cdm_lms.course lms_c
    ON lms_c.id = map_c.lms_course_id

-- Joins with Blackboard tables

left join cdm_lms.person_course lms_pc
   ON lms_c.id= lms_pc.course_id

left join cdm_lms.person lms_p
   ON lms_p.id= lms_pc.person_id
   AND lms_pc.act_as_instructor_ind = TRUE

-- Grouped to get 1 row per course
group by 
lms_c.id,
lms_c.course_number, 
lms_c.name, lms_c.design_mode, 
a_t.name, 
a_cs.course_id, 
a_cs.numeric_score, 
a_d.name

;
