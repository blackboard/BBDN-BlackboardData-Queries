

; with my_courses as
(
    select id from cdm_lms.course where Course_Number like '2020.spring.%'

),
courses as
(
select 
  --  t.id as Term_Surr_Key,
  --  t.Source_ID as Term_PK1,
  --  t.name as Term_Name,
  --  t.Start_Date as Term_Start,
  --  t.End_Date as Term_End,   
    c.id as Course_Surr_Key,
    c.source_id as Course_PK1,
    C.Course_Number as Learn_Course_ID,    
    C.Name as Course_Name,
    --C.Start_Date as Course_Start,
    C.End_Date as Course_End,
    C.Available_Ind as Avail_Flag,
    C.Available_to_Students_Ind as Avail_To_Students_Flag,
    case when c.design_mode_source_code = 'U' then 'Ultra' else 'Classic' end as Ultra_Flag   
from 
    cdm_lms.course c        
   -- left join
   --     cdm_lms.term t
   --     on  c.term_id = t.id
where
    --Modify the following date criterion to suit operational needs
    --Course_Start between '2019-12-21' and sysdate()
    --C.Course_Number like '2020.spring.%'
     c.row_deleted_time is null
),

enrollment as
--all students enrolled in any of the above courses, according to person_course table
(
 select
    --distinct
    pc.id as Person_Course_ID,
    p.id as Student_Surr_Key,
    p.source_id as Student_PK1,
    p.last_name as Student_Last_Name,
    p.first_name as Student_First_Name,
    p.email as Student_Email,
   -- c.Term_Name,
   -- c.Term_Start,
    c.Course_Surr_Key,
    c.Course_PK1,
    c.Learn_Course_ID,    
    c.Course_Name
    --c.Course_Start
 from
    courses c
    inner join
        CDM_LMS.Person_Course pc
        on  pc.course_id = c.Course_Surr_Key and
            pc.Course_Role = 'S'
    inner join 
        CDM_LMS.Person P
        on P.ID = PC.Person_ID     
),


student_course_activity as
 (
 select
    e.Student_Surr_Key,
    e.Student_PK1,
    e.Student_Last_Name,
    e.Student_First_Name,
    e.Student_Email,
   -- e.Term_Name,
   -- e.Term_Start,
    e.Course_Surr_Key,
    e.Course_PK1,
    e.Learn_Course_ID,    
    e.Course_Name,
    --e.Course_Start,
    count(ca.id) as Student_Login_Count,
    date_trunc('minute',max(ca.LAST_ACCESSED_TIME)) as Student_Last_Access,
    round(sum(ca.duration_sum/3600),2) as Student_Course_Activity_Hours,
    sum(ca.Interaction_Cnt) as Student_Course_Interaction_Count
 from
    enrollment e
    left join
        CDM_LMS.Course_Activity ca
        on  ca.person_id = e.Student_Surr_Key and
            ca.course_id = e.Course_Surr_Key
  group by
    e.Student_Surr_Key,
    e.Student_PK1,
    e.Student_Last_Name,
    e.Student_First_Name,
    e.Student_Email,
    --e.Term_Name,
    --e.Term_Start,
    e.Course_Surr_Key,
    e.Course_PK1,
    e.Learn_Course_ID,    
    e.Course_Name
   -- e.Course_Start
 ),
 
 collab_room as
 (
 select
    cr.lms_course_id as Course_Surr_Key,
    count(distinct cr.clb_room_id) as Course_Collab_Room_Count,
    count(s.id) as Collab_Session_Count
 from
    cdm_map.course_room cr
    left join
        cdm_clb.session s
        on   s.room_id = cr.clb_room_id
 group by
    cr.lms_course_id
 ),
 
 
 collab_attend as
 (
 select
   cr.lms_course_id as Course_Surr_Key,
   a.person_id as collab_person_surr_key,
   mp.lms_person_id as learn_person_surr_key,
   round(sum(a.duration/3600),2) as Student_Course_Collab_Attendance_Hours
 from
    cdm_map.course_room cr
    inner join
        cdm_clb.session s
        on   s.room_id = cr.clb_room_id
    inner join
        cdm_clb.attendance a
        on  a.session_id = s.id
    inner join
        cdm_map.person  mp
        on  mp.clb_person_id = a.person_id

 group by
   cr.lms_course_id,
   --cr.clb_room_id,
   a.person_id,
   mp.lms_person_id
 ),
 
student_course_activity_with_collab as 
(
select  
    sca.Student_Surr_Key,
    sca.Student_PK1,
    sca.Student_Last_Name,
    sca.Student_First_Name,
    sca.Student_Email,
    --sca.Term_Name,
    --sca.Term_Start,
    sca.Course_Surr_Key,
    sca.Learn_Course_ID,    
    sca.Course_Name,
    --sca.Course_Start,
    sca.Student_Login_Count,
    sca.Student_Last_Access,
    sca.Student_Course_Activity_Hours,
    sca.Student_Course_Interaction_Count,
    case when cr.Course_Collab_Room_Count > 0 then 'Has Collab Room(s)' else 'No Collab Rooms' end as Course_Collab_Flag,
    ca.Student_Course_Collab_Attendance_Hours
from 
    student_course_activity sca
    left join
        collab_room cr
        on  cr.Course_Surr_Key = sca.Course_Surr_Key         
    left join
        collab_attend ca
        on  ca.Course_Surr_Key = sca.Course_Surr_Key and
            ca.learn_person_surr_key = sca.Student_Surr_Key
),

student_course_avg as
 (
 select
   
    (select count(*) from enrollment where Course_Surr_Key = c.Course_Surr_Key) as c,
    c.Course_Surr_Key,
    c.Course_PK1,
    c.Learn_Course_ID,    
    c.Course_Name,
    --e.Course_Start,
    case when c > 0 then round(count(ca.id) / c,0) else 0 end as Avg_Other_Students_Login_Count,
    date_trunc('minute',max(ca.LAST_ACCESSED_TIME))  as Max_Last_Access_Per_Course,
    date_trunc('minute',min(ca.LAST_ACCESSED_TIME))  as Min_Last_Access_Per_Course,

    case when c > 0 then round(sum(ca.duration_sum/3600)/c,2) else 0 end as Avg_Other_Students_Course_Activity_Hours,
    case when c > 0 then round(sum(ca.Interaction_Cnt)/c,0) else 0 end as Avg_Other_Students_Course_Interaction_Count
 from
    courses c
    left join
        CDM_LMS.Course_Activity ca
        on  
            ca.course_id = c.Course_Surr_Key
  group by
    c,
    c.Course_Surr_Key,
    c.Course_PK1,
    c.Learn_Course_ID,    
    c.Course_Name
   -- e.Course_Start
 ),
 
 student_grade as
 (
 select
    e.Student_Surr_Key,
    e.Course_Surr_Key,
    round(g.normalized_score*100,0) as total_grade_prct
   from
    enrollment e
    left join CDM_LMS.grade g
    on  g.person_course_id = e.Person_Course_ID 
        inner join cdm_lms.gradebook lgb
                on g.gradebook_id = lgb.id
        where lgb.final_grade_ind = 1
        and g.row_deleted_time is null
        
 )

     
    
 
select  
    scac.Student_PK1,
    scac.Student_Last_Name,
    scac.Student_First_Name,
    scac.Student_Email,
    --scac.Term_Name,
    --scac.Term_Start,
    --scac.Course_Start,
    scac.Learn_Course_ID,    
    scac.Course_Name,
   
    sg.total_grade_prct,
          
    scac.Student_Login_Count,
    scac.Student_Last_Access,
    scac.Student_Course_Activity_Hours,
    scac.Student_Course_Interaction_Count,
    scac.Course_Collab_Flag,
    scac.Student_Course_Collab_Attendance_Hours,
    stav.Avg_Other_Students_Login_Count,
    stav.Max_Last_Access_Per_Course,
    stav.Min_Last_Access_Per_Course,
    stav.Avg_Other_Students_Course_Activity_Hours,
    stav.Avg_Other_Students_Course_Interaction_Count
from 
    student_course_activity_with_collab scac
    inner join my_courses my on my.id = scac.Course_Surr_Key
    left join student_course_avg stav
    on     scac.Course_Surr_Key = stav.Course_Surr_Key
     left join student_grade sg
    on     scac.Course_Surr_Key = sg.Course_Surr_Key and scac.Student_Surr_Key = sg.Student_Surr_Key

    
order by
    scac.Student_Last_Name,
    scac.Student_First_Name,
   -- scac.Student_PK1
   -- scac.Term_Start,
   -- scac.Course_Name
   Learn_Course_ID



    
