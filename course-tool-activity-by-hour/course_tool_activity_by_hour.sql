/*
This query used for basic aggregations in the legacy public view . Granularity is on login level.

Details on the columns in this table can be found below:
--course_tool_id: Foreign key that references the primary key of the CDM_LMS.COURSE_TOOL table
--course_id: Foreign key that references the primary key of the CDM_LMS.COURSE table
--tool_id: Foreign key that references the primary key of the CDM_LMS.TOOL table
--person_id: Foreign key that references the primary key of the CDM_LMS.PERSON table
--person_course_id: Foreign key that references the primary key of the CDM_LMS.PERSON_COURSE table
--activity_time: Date and time an activity was performed on the course tool
--course_name: Name of the course
--tool_name: Name of the tool
--person_course_role: Name of the role of a person in the course
--course_role_desc:  Description of the role of a person in the course
--course_available_ind: Shows if the course is available
--tool_available_ind: Shows if the tool is available in the course
--person_available_ind: Shows if the person is available
--activity_duration_sum: Length of time a person spent in the course in seconds
--course_source_id: Primary key of the course
--tool_source_id: Primary key of the source system
--row_overwritten_time: Date and time the record was overwritten in the table
*/

with daily_activity as (
	select
		a.person_id,
		a.course_id,
		a.tool_id,
		a.accessed_time as activity_time,
		a.duration_sum
	from
		cdm_lms.activity a
	where
		a.course_id is not null
		and a.tool_id is not null

	union

	select
		a.person_id,
		ct.course_id,
		ct.tool_id,
		a.accessed_time as activity_time,
		a.duration_sum
	from
		cdm_lms.activity a
		inner join cdm_lms.course_item ci
			on ci.id = a.course_item_id
		inner join cdm_lms.course_tool ct
			on ct.id = ci.course_tool_id
	where
		a.course_item_id is not null
)
select 
	ct.id as course_tool_id,
	c.id as course_id,
	t.id as tool_id,
	p.id as person_id,
	pc.id as person_course_id,
	a.activity_time as activity_time,
	c.name as course_name,
	t.name as tool_name,
	nvl (pc.course_role_source_desc, 'Unknown') as person_course_role,
	nvl (pc.course_role_desc,'Unknown') as course_role_desc,
	nvl(c.available_ind, 0) as course_available_ind,
	nvl(ct.available_ind,0) as tool_available_ind,
	p.available_ind as person_available_ind,
	nvl(a.duration_sum, 0) as activity_duration_sum,
	ct.course_source_id as course_source_id,
	ct.tool_source_id as tool_source_id
from
	cdm_lms.course_tool ct
	inner join cdm_lms.course c
		on c.id = ct.course_id
	inner join cdm_lms.tool t
		on t.id = ct.tool_id
	left outer join daily_activity a
		on a.course_id = ct.course_id
		and a.tool_id = ct.tool_id
	left outer join cdm_lms.person p
		on p.id = a.person_id
	left outer join cdm_lms.person_course pc
		on pc.person_id = a.person_id
		and pc.course_id = a.course_id
;
