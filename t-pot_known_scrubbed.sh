#! /bin/bash
# this script finds 
curl -s -XGET "http://192.168.18.44:64298/logstash-*/_search?pretty=true" -H 'Content-Type: application/json' -d'
{
  "aggs": {
    "2": {
      "terms": {
        "field": "src_ip.keyword",
        "order": {
          "_count": "desc"
        },
        "size": 100
      }
    }
  },
  "size": 0,
  "fields": [
    {
      "field": "@timestamp",
      "format": "date_time"
    },
    {
      "field": "end_time",
      "format": "date_time"
    },
    {
      "field": "flow.start",
      "format": "date_time"
    },
    {
      "field": "start_time",
      "format": "date_time"
    },
    {
      "field": "timestamp",
      "format": "date_time"
    },
    {
      "field": "tls.notafter",
      "format": "date_time"
    },
    {
      "field": "tls.notbefore",
      "format": "date_time"
    }
  ],
  "script_fields": {},
  "stored_fields": [
    "*"
  ],
  "runtime_mappings": {},
  "_source": {
    "excludes": []
  },
  "query": {
    "bool": {
      "must": [
        {
          "query_string": {
            "query": "*",
            "analyze_wildcard": true,
            "time_zone": "America/Denver"
          }
        },
        {
          "query_string": {
            "query": "type:\"Adbhoney\" OR type:\"Ciscoasa\" OR type:\"CitrixHoneypot\" OR type:\"ConPot\" OR type:\"Cowrie\" OR type:\"Dicompot\" OR type:\"Dionaea\" OR type:\"ElasticPot\" OR type:\"Glutton\" OR type:\"Heralding\" OR type:\"Honeypy\" OR type:\"Honeysap\" OR type:\"Honeytrap\" OR type:\"Ipphoney\" OR type:\"Mailoney\" OR type:\"Medpot\" OR type:\"Rdpy\" OR type:\"Tanner\"",
            "analyze_wildcard": true,
            "time_zone": "America/Denver"
          }
        }
      ],
      "filter": [
        {
          "match_phrase": {
            "ip_rep.keyword": "known attacker"
          }
        },
        {
          "range": {
            "@timestamp": {
              "from": "now-1m",
              "to": null,
              "include_lower": true,
              "include_upper": true,
              "boost": 1
              }
            }
      }
    ],
      "should": [],
      "must_not": []
    }
  }
}' > known.json
grep 'key' ./known.json| sed -e 's/^.*"key" : "//' -e 's/",//' | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4
rm known.json
