import sys
import urllib2
import json
import argparse
import base64


class VotrCouchDBInitializer(object):
    def __init__(self, path=None, username=None, password=None):
        self.path = path
        self.username = username
        self.password = password
        self.result = None

    def exists(self):
        try:
            response = urllib2.urlopen(self.path)
            response_dict = json.loads(response.read())
            success = response_dict['couchdb']
            return True
        except urllib2.URLError, e:
            self.result = {'changed': False,
                           'comment': "Unable to connect to CouchDB: "
                                      "{0}".format(e)}
            return False
        except urllib2.HTTPError, e:
            self.result = {'changed': False,
                           'comment': "Error connecting to CouchDB: "
                                      "{0}".format(e)}
            return False
        except urllib2.KeyError, e:
            self.result = {'changed': False,
                           'comment': "Unknown response from CouchDB: {0}"
                                      .format(e)}
            return False
        except urllib2.Exception, e:
            self.result = {'changed': False,
                           'comment': "Unknown error connecting to "
                                      "CouchDB: {0}".format(e)}
            return False

    def user_exists(self):
        try:
            response = urllib2.urlopen("{0}/_config/admins/{1}"
                                       .format(self.path, self.username))
            response_dict = json.loads(response.read())
            if response_dict.get('error', None):
                return False
            else:
                return True
        except urllib2.HTTPError, e:
            return False
        except Exception, e:
                self.result = {'changed': False,
                               'comment': "Votr CouchDB user already exists."}
                return True

    def create_user(self):
        opener = urllib2.build_opener(urllib2.HTTPHandler)
        request = urllib2.Request("{0}/_config/admins/{1}"
                                  .format(self.path, self.username),
                                  data='"{0}"'.format(self.password))
        request.get_method = lambda: 'PUT'
        try:
            url = opener.open(request)
            self.result = {'changed': True,
                           'comment': "Votr user created."}
            return True
        except Exception, e:
            self.result = {'changed': False,
                           'comment': "Error creating user."}
            return False

    def database_exists(self):
        try:
            response = urllib2.urlopen("{0}/database".format(self.path))
            response_dict = json.loads(response.read())
            if response_dict.get('error', None):
                return False
            else:
                self.result = {'changed': False,
                               'comment': "Votr CouchDB database "
                                          "already exists."}
                return True
        except urllib2.HTTPError, e:
            return False

    def create_database(self):
        opener = urllib2.build_opener(urllib2.HTTPHandler)
        request = urllib2.Request("{0}/database"
                                  .format(self.path))
        request.get_method = lambda: 'PUT'
        base64_string = base64.encodestring("{0}:{1}"
                                            .format(self.username,
                                                    self.password)) \
            .replace('\n', '')
        request.add_header("Authorization", "Basic {0}".format(base64_string))
        try:
            url = opener.open(request)
            self.result = {'changed': True,
                           'comment': "Votr database created."}
            return True
        except Exception, e:
            self.result = {'changed': False,
                           'comment': "Error creating database."}
            print Exception, e
            return False

# Parser configuration
parser = argparse.ArgumentParser(description="Votr Database Initializer for "
                                             "Salt.",
                                 epilog="Written by Rob Spectre.  Votr "
                                        "written by Carter Rabasa.")
parser.add_argument('path',
                    help="Path to CouchDB interface.")
parser.add_argument('-u', '--username',
                    help="Username for CouchDB admin user you wish to create.")
parser.add_argument('-p', '--password',
                    help="Password for CouchDB admin user you wish to create.")

if __name__ == "__main__":
    couchdb = VotrCouchDBInitializer()
    parser.parse_args(namespace=couchdb)

    if couchdb.exists():
        if couchdb.user_exists():
            pass
        else:
            couchdb.create_user()

        if couchdb.database_exists():
            pass
        else:
            couchdb.create_database()

    sys.stdout.write(json.dumps(couchdb.result))
