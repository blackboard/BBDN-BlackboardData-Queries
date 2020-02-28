# BBDN-BlackboardData-Queries

The following format for contributes are as follows:

## Example: Get User By User Id
/get-user-by-user-id
- variables.json
- query.sql
- output.json
- README.md



## Example of SQL File with Tokens
SQL files can have tokens ({token}) in the query. When retrieving query file, ensure that you check the top of the file for tokens

```
-- TOKEN:tokenName:dataType
```

Example:

```
-- TOKEN:year:number
```

In which ever mannor you see fit, enure that you collect all tokens and then replace the tokens with the correct values:


```
    ... sql code
    and year = {year}

```


At this time of writing, it is recomended that you do not put spaces inbetween the token name and that they are to be treated as camelCase and case sensitive. They may be a more defined and offical syntax later but nothing at this point in time. This is releated to: [Issue #244](https://github.com/snowflakedb/snowflake-connector-python/issues/244)