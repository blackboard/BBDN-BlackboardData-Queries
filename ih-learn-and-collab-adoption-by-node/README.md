# Blackboard Learn and Blackboard Collaborate adoption by node (using Institutional Hierarchy data)

This query was created by Steve Bailey and shared on the Blackboard Community Site as part of a blog post focused on deepening adoption insights using Institutional Hierarchy and Course Terms in Blackboard Data. You can read the full blog post here: https://community.blackboard.com/blogs/8/465


Here's a quick summary of the columns you'll see in results of this query:

## Categories:

- **Term_year** - the year of the start date for the term, so if a term start date is 2019-09-01 then the term year would be 2019.
- **Term** - the name of the term as it appears in Blackboard Learn, or "No Term" for courses not associated to terms.
- **Hierarchy_node** - the name of the hierarchy node, or "No Node" for courses not associated to nodes.
- **Hierarchy_path** - the entire branch of the hierarchy tree for the current node.

## Measures: for each combination of term and node…

- **Course_count** - the number of courses associated
- **Learn_storage_mb** - the total file size of all files attached to items in courses associated, in megabytes
- **Classic_course_count** - the number of courses using the Original Experience of Learn
- **Ultra_course_count** - the number of courses using the Ultra Experience of Learn
- **Ultra_adoption_percent** - the percentage of courses using Ultra Experience (formatted as a decimal, e.g. 25% is 0.25)
- **Grades_course_count** - the number of courses using the grade center
- **Grades_adoption** - the percentage of courses using the grade center (formatted as a decimal)
- **Avg_assessments_per_course** - the average number of grade center columns with a grade in courses
- **Collab_course_count** - the number of courses with a Collaborate course room
- **Collab_adoption_percent** - the percentage of courses linked to Collaborate (formatted as a decimal)
- **Total_collab_sessions** - the number of Collaborate sessions linked to courses
- **Total_collab_minutes** - the number of minutes spent in Collaborate sessions linked to courses
- **Total_collab_users** - the number of users (instructors and students) attending Collaborate sessions linked to courses
**Collab_storage_mb** - the total storage size of all recordings from Collaborate sessions linked to courses


Note that this query will only show those nodes associated to courses, but parent nodes will be visible within the Hierarchy_path column. This query illustrates the added value you get from reporting when you populate the Institutional Hierarchy and Course Terms tables in Blackboard Learn. 