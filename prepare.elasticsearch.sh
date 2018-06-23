URL="elasticsearch.local:9200"

curl -XPUT "${URL}/zabbix_events?pretty" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "event": {
      "properties": {
        "zabbix_server": {"type": "text"},
        "hostname": { "type": "text"},
        "trigger": {"type": "text"},
        "triggerid": {"type": "long"},
        "ts":  { "type": "date", "format": "epoch_second"},
        "severity": { "type": "text"},
        "nseverity": {"type": "integer"},
        "eventid": {"type": "long"},
        "status": {"type": "text"}
      }
    }
  }
}'

curl -XPUT "${URL}/zabbix_history?pretty" -H 'Content-Type: application/json' -d'
{
  "mappings": {
    "event": {
      "properties": {
      "zabbix_server": {"type": "text"},
        "hostname": { "type": "text"},
        "trigger": {"type": "text"},
        "triggerid": {"type": "long"},
        "eventid": {"type": "long"},
        "eventrecoveryid": {"type": "long"},
        "duration": {"type": "integer"},
        "started":  { "type": "date", "format": "epoch_second"},
        "finished": {"type": "date", "format": "epoch_second"},
        "severity": { "type": "text"},
        "nseverity": {"type": "integer"}
      }
    }
  }
}'