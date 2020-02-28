# BBDN-BlackboardData-Queries

The following format for contributes are as follows:

## Example: Get User By User Id
/get-user-by-user-id
- variables.json
- query.sql
- output.json
- README.md



## Example of SQL File with Variables
SQL files can have variables in the query. When retrieving query file, ensure that you check the variables.json file first for any variables to inject into the query:

```py

@app.route('/queries/<query_name>', methods=['GET'])
@login_required
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
