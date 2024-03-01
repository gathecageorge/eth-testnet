import requests
import sys
import json

username = sys.argv[1]
response = { 'username': username, 'key': '', 'found': "0" }

web = requests.get('https://github.com/' + response['username'] + '.keys')
if(web.status_code == 200):
  keys = web.text.split("\n")

  response['key'] = keys[0].strip()
  response['found'] = "1"

print(json.dumps(response))
