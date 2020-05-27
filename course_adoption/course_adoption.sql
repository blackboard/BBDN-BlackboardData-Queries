
; with courses as
 (
select 
    --t.id as Term_Surr_Key,
    --t.Source_ID as Term_PK1,
    --t.name as Term_Name,
    --t.Start_Date as Term_Start,
    --t.End_Date as Term_End,   
    c.id as Course_Surr_Key,
    --c.source_id as Course_PK1,
    C.Course_Number as Course_ID,    
    C.Name as Course_Name,
    --C.Start_Date as Course_Start,
    --C.End_Date as Course_End,
    C.Available_Ind as Avail_Flag,
    C.Available_to_Students_Ind as Avail_To_Students_Flag,
    --case when c.design_mode_source_code = 'U' then 'Ultra' else 'Classic' end as Ultra_Flag,
    case when gb.course_id is null then 'No Gradebook' else 'Has Gradebook' end as Gradebook_Flag,
    ifnull(Gradebook_Item_Count,0) as Gradebook_Item_Count,
    ifnull(pcc.Instr_Count, 0) as Instructor_Count,
   
    count(ci.id) as Total_Item_Count,
    sum(Case when ci.Item_Group = 'A' then 1 else 0 end) as Assessment_Count,
    sum(Case when ci.Item_Group = 'C' then 1 else 0 end) as Content_Count,
    sum(Case When ci.Item_Group = 'T' then 1 else 0 end) as Tool_Count,

    case 
        when  max(case when ci.Item_Type_source_code like '%assign%'then 1 else 0 end) = 1 then 'Has Assignments'
        else 'No Assignments'
    end        
        as Assignment_Ind,
    
    case 
        when  max(case  when ci.Item_Type_source_code like '%syll%' then 1 else 0 end)  = 1 then 'Has Syllabus'
        else 'No Syllabus'
    end        
        as Syllabus_Ind,
        
    case when count(ci.id) = 0 then 'Empty' else 'Nonempty' end as EmptyShellFlag

from 
    cdm_lms.course c        
    left join
        cdm_lms.term t
        on  c.term_id = t.id
    left join
        (select 
            pca.course_id,
            count(*) as Instr_Count
         from  CDM_LMS.Person_Course pca
         where pca.Course_Role = 'I'
         group by pca.course_id
        ) as pcc
        on  pcc.course_id = c.id
  
    left join
        CDM_LMS.Course_Item ci
        on  ci.course_id = c.id

    left join
        (select course_id, 
                count(*) as Gradebook_Item_Count
         from  CDM_LMS.gradebook
        group by course_id) as gb
         on gb.course_id = c.id

where
    --Course_Start >= '2019-12-21'   --Adjust this date to meet needs
    and c.row_deleted_time is null -- filter out deleted courses

    c.course_number like '2020.spring.%'
group by 
    t.id,
    t.Source_ID,
    t.name,
    t.Start_Date,
    t.End_Date,   
    c.id,
    c.source_id,
    C.Course_Number,    
    C.Name,
    C.Start_Date,
    C.End_Date,
    C.Available_Ind,
    C.Available_to_Students_Ind,
    c.design_mode_source_code,
    gb.course_id,
    gb.Gradebook_Item_Count,
    pcc.Instr_Count
 ),
 
 instructor_activity as
 (
 select
    c.Course_Surr_Key,
    pc.Person_ID as Instructor_Surr_Key,
    p.Source_ID as Instructor_PK1,
    concat(p.last_name, ', ', p.first_name) as Instructor_Name,
    p.email as Instructor_Email,   
    count(ca.id) as Instructor_Login_Count,
    date_trunc('minute', max(ca.LAST_ACCESSED_TIME)) as Instructor_Last_Access,
    round(sum(ca.duration_sum/3600),2) as Instructor_Course_Activity_Hours
 from
   courses c
   left join
        CDM_LMS.Person_Course pc
        on  pc.course_id = c.Course_Surr_Key and
            pc.Course_Role = 'I'
   left join CDM_LMS.Person P
        on P.ID = PC.Person_ID      
   left join
       CDM_LMS.COURSE_ACTIVITY ca
       on   ca.person_id =  pc.Person_ID and
            ca.course_id =  c.Course_Surr_Key
  group by
    c.Course_Surr_Key,
    pc.Person_ID,
    p.Source_ID,
    concat(p.last_name, ', ', p.first_name),
    p.email
 ),
 
 student_activity as
 (
 select
    c.Course_Surr_Key,
    count(distinct pc.id) as Student_Count,
    count(distinct ca.person_Id) as Active_Student_Count,
    count(ca.id) as Total_Student_Login_Count,
    date_trunc('minute',max(ca.LAST_ACCESSED_TIME)) as Student_Last_Access,
    round(sum(ca.duration_sum/3600),0) as Student_Course_Activity_Hours
 from
    courses c
    left join
        CDM_LMS.Person_Course pc
        on  pc.course_id = c.Course_Surr_Key and
            pc.Course_Role = 'S'
    left join 
        CDM_LMS.Person P
        on P.ID = PC.Person_ID     
    left join
        CDM_LMS.Course_Activity ca
        on  ca.person_course_id = pc.id 
  group by
    c.Course_Surr_Key
 ),
 
 course_rooms as
 (
 select
    cr.lms_course_id,
    ifnull(count(r.id), 0) as collab_room_count
 from 
    cdm_map.course_room cr
    inner join
        cdm_clb.room r
        on  r.id = cr.clb_room_id
 where
    cr.lms_course_id is not null
 group by
    cr.lms_course_id
 ),
 
 sess as
 (
 select
   cr.lms_course_id,
   count(s.id) as collab_session_count,
   round(sum(s.session_duration)/3600,2) as total_collab_room_use_hours,
   round(sum(s.attended_duration/3600),2) as total_collab_room_attended_hours
 from
    cdm_map.course_room cr
    inner join
        cdm_clb.session s
        on   s.room_id = cr.clb_room_id
 group by
   cr.lms_course_id
 ),
 
 attend as
 (
 select
   cr.lms_course_id,
   count(distinct a.person_id) as collab_participant_count,
   round(sum(a.duration/3600),2) as total_collab_attendee_hours
 from
    cdm_map.course_room cr
    inner join
        cdm_clb.session s
        on   s.room_id = cr.clb_room_id
     left join
        cdm_clb.attendance a
        on  a.session_id = s.id
 group by
   cr.lms_course_id
 ),
 
 collab_summary as
 (
 select
    cr.lms_course_id,
    cr.collab_room_count,
    s.collab_session_count,
    s.total_collab_room_use_hours,
    s.total_collab_room_attended_hours, 
    a.collab_participant_count,
    a.total_collab_attendee_hours
 from
    course_rooms cr
    left join
        sess s
        on  s.lms_course_id = cr.lms_course_id
    left join
        attend a
        on  a.lms_course_id = cr.lms_course_id
 )
 
select 
    -- courses.Term_PK1,
    -- courses.Term_Name,
    -- courses.Term_Start,
    -- courses.Term_End,   
    -- courses.Course_PK1,
     courses.Course_ID,    
     courses.Course_Name,
    -- courses.Course_Start,
    -- courses.Course_End,
     courses.Avail_Flag,
     courses.Avail_To_Students_Flag,
    -- courses.Ultra_Flag,
     courses.Gradebook_Flag,
     courses.Gradebook_Item_Count,

     courses.Total_Item_Count,
     courses.Assessment_Count,
     courses.Content_Count,
     courses.Tool_Count,

     courses.Assignment_Ind,  
     courses.Syllabus_Ind,
     courses.EmptyShellFlag,

     courses.Instructor_Count,
     
     ia.Instructor_PK1,
     ia.Instructor_Name,
     ia.Instructor_Email,     
     ia.Instructor_Login_Count,
     ia.Instructor_Last_Access,
     ia.Instructor_Course_Activity_Hours,
     sa.Student_Count,
     sa.Active_Student_Count,
     sa.Total_Student_Login_Count,
     sa.Student_Last_Access,
     sa.Student_Course_Activity_Hours,
    
    case when sa.Active_Student_Count >  0 
         then round(sa.Total_Student_Login_Count / sa.Active_Student_Count, 2)
         else null
    end as Avg_Logins_Per_Active_Student,
    
    case when sa.Active_Student_Count >  0 
         then round(sa.Student_Course_Activity_Hours / sa.Active_Student_Count, 2)
         else null
    end as Avg_Course_Hours_Per_Active_Student,
    
    collab_summary.collab_room_count,
    collab_summary.collab_session_count,
    collab_summary.total_collab_room_use_hours,
    collab_summary.total_collab_room_attended_hours, 
    collab_summary.collab_participant_count,
    collab_summary.total_collab_attendee_hours
from 
    courses 
    left join
        instructor_activity ia
        on  ia.Course_Surr_Key = courses.Course_Surr_Key 
    left join
        student_activity sa
        on  sa.Course_Surr_Key = courses.Course_Surr_Key 
    left join
        collab_summary
        on  collab_summary.lms_course_id = courses.Course_Surr_Key
      
order by 
    --courses.Course_Start,
    courses.Course_Name,
    ia.Instructor_Name
