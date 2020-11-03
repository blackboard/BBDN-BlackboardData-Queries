# BBDN-BlackboardData-Queries

The following format for contributes are as follows:

## Example: Get User By User Id
/get-user-by-user-id
- variables.json
- query.sql
- output.json
- README.md



## Example of SQL File with Variables
SQL files can have variables in the query. When retrieving query file, ensure that you check the variables.json file first for any variables to inject into the query.

An example of a variables.json file, is as follows:

```json
{
    "variables": {
        "date": "2017-08-01"
    }
}
```
In this example, you would be looking for the variable `{date}` in your sql file, and it would be replaced with the variable in the variables.json file. So your sql would look like this:

```sql
select
    mcd.canon_desc as design_mode,
    ifnull(count(distinct lc.id),0) as course_count,
    ifnull(count(distinct case when course_role = 'I' then lpc.person_id else null end),0) as distinct_instructors,
    ifnull(count(distinct case when course_role = 'S' then lpc.person_id else null end),0) as distinct_students
from cdm_lms.course lc
left join cdm_lms.person_course lpc
    on lpc.course_id = lc.id
left join cdm_meta.canon_definition mcd
    on mcd.name = 'DESIGN_MODE'
    and mcd.source_domain = 'LMS'
    and mcd.canon_code = lc.design_mode
where lc.created_time > '{date}' 
group by 
    mcd.canon_desc
order by
    mcd.canon_desc
```

In order to call this programatically, you would use something similar to this example, written in Python:

```py

def query_by_name(query_name):
    varibles = requests.get(RAW_VARS_URL.replace('{query_name}', query_name)).json()['variables']
    query = requests.get(RAW_SQL_URL.replace('{query_name}', query_name)).text

    # ensure that if there are vars, then inject them into the query
    for key, value in varibles.items():
        print(key, value)
        query = query.replace('{' + key + '}', str(value))

    return jsonify({
        'query': query
    })

```

For an example on how to use these queries with Python, check out [BBDN-BlackboardData-Python](https://github.com/blackboard/BBDN-BlackboardData-Python).
