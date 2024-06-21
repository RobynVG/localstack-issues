# Graphql Queries break with Fragments

The issue can be reproduced with the following graphql call after running run.sh

```
curl -X POST \
  -H "Content-Type: application/json" \
  -H "x-api-key: <your_appsync_api_key>" \
  --data '{ "query": "{ data { ...dataFields } } fragment dataFields on Data { a b c } " }' \
  http://localhost:4566/graphql/demo
```

Which will return:

`{"data": {}, "errors": [{"message": "'FragmentSpreadNode' object has no attribute 'selection_set'", "locations": [{"line": 1, "column": 3}], "path": ["data"], "errorType": "AttributeError"}]}`

The query can be modified so that AppSync does not return an error by moving the fragment definition before the query definition as follows:

--data '{ "query": "fragment dataFields on Data { a b c } { data { ...dataFields } } " }'
