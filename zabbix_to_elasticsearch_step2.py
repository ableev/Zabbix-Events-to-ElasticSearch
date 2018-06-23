#!/usr/bin/env python
# coding: utf-8

import requests
import json
import sys
import MySQLdb

zabbix_server = "zabbix1.local"
support_database = "zabbix_support"
support_table = "zabbix_to_elasticsearch"


def main():

    args = sys.argv

    db_connect = MySQLdb.connect(host="localhost", database=support_database)
    db_connect.autocommit(True)
    db_cursor = db_connect.cursor(MySQLdb.cursors.DictCursor)

    if "events" in args:

        q_get_events = "SELECT *, UNIX_TIMESTAMP(started) AS started_ts FROM {0} " \
                       "WHERE is_e_done = 0".format(support_table)

        db_cursor.execute(q_get_events)
        events = db_cursor.fetchall()

        for event in events:
            data_event = {
                "hostname": event["hostname"],
                "trigger": event["triggerdescription"],
                "severity": event["severity"],
                "nseverity": event["nseverity"],
                "ts": event["started_ts"],
                "triggerid": event["triggerid"],
                "eventid": event["eventid"],
                "status": "PROBLEM",
                "zabbix_server": zabbix_server
            }
            #print(data_event)
            result_event = requests.put("http://monitoring.mlan:9200/zabbix_events/event/" + str(event["eventid"]) +
                                        "?pretty",
                                        data=json.dumps(data_event), headers={'Content-type': 'application/json'})
            print(result_event.content)
            if result_event.status_code in (200, 201):
                q_mark_as_done = "UPDATE {0} SET is_e_done = 1 WHERE eventid = {1}"\
                    .format(support_table, event["eventid"])
                db_cursor.execute(q_mark_as_done)
            else:
                print(result_event.status_code)
                sys.exit(1)
            print "---"

    if "history" in args:

        q_get_history = "SELECT *, UNIX_TIMESTAMP(started) AS started_ts, UNIX_TIMESTAMP(finished) AS finished_ts, " \
                        "finished-started AS duration " \
                        "FROM {0} " \
                        "WHERE eventrecoveryid IS NOT NULL " \
                        "AND is_er_done = 0".format(support_table)
        history = db_cursor.execute(q_get_history)

        for event in history:
            data_history = {
                "hostname": event["hostname"],
                "trigger": event["triggerdescription"],
                "severity": event["severity"],
                "nseverity": event["nseverity"],
                "started": event["started_ts"],
                "finished": event["finished_ts"],
                "duration": event["duration"],
                "triggerid": event["triggerid"],
                "eventid": event["eventid"],
                "eventrecoveryid": event["eventrecoveryid"],
                "zabbix_server": zabbix_server
            }
            #print(data_history)
            result1 = requests.put("http://monitoring.mlan:9200/zabbix_history/event/" + str(event["eventid"]) + "?pretty",
                                   data=json.dumps(data_history), headers={'Content-type': 'application/json'})
            #print(result1.content)

            data_event = {
                "hostname": event["hostname"],
                "trigger": event["triggerdescription"],
                "severity": event["severity"],
                "nseverity": event["nseverity"],
                "ts": event["finished_ts"],
                "triggerid": event["triggerid"],
                "eventid": event["eventrecoveryid"],
                "status": "OK",
                "zabbix_server": zabbix_server
            }
            #print(data_event)
            result2 = requests.put("http://monitoring.mlan:9200/zabbix_events/event/" + str(event["eventrecoveryid"]) +
                                   "?pretty",
                                   data=json.dumps(data_event), headers={'Content-type': 'application/json'})
            print(result2.content)
            if result1.status_code in (200, 201) and result2.status_code in (200, 201):
                q_mark_as_done = "UPDATE {0} SET is_er_done = 1 WHERE eventid = {1}"\
                    .format(support_table, event["eventid"])
                res = db_cursor.execute(q_mark_as_done)
            else:
                print(result1.status_code, result2.status_code)
                sys.exit(1)
            print "---"

        q_delete_useless = "DELETE FROM {0} WHERE is_er_done = 1".format(support_table)
        res = db_cursor.execute(q_delete_useless)


if __name__ == "__main__":
    main()
