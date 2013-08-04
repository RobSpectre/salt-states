import sys
import urllib2
import json
from distutils.version import StrictVersion

result = {}

response = None
try:
    response = urllib2.urlopen('https://pypi.python.org/pypi/pip/json')
except URLError, e:
    result = {'changed': False,
              'comment': "Unable to connect to PyPi: %s" % e}
except HTTPError, e:
    result = {'changed': False,
              'comment': "Error connecting to PyPi: %s" % e}
except Exception, e:
    result = {'changed': False,
              'comment': "Unknown error connecting to PyPi: %s" % e}
   
cheese_shop_response = None
try:
    cheese_shop_response = json.loads(response.read())
except Exception, e:
    result = {'changed': False,
              'comment': "Error parsing result from PyPi: %s" % e}

if json:
    import pip
    try:
        current_version = pip.__version__
    except AttributeError:
        current_version = '1.0'

    latest_version = None
    try:
        latest_version = cheese_shop_response['info']['version']
    except KeyError, e:
        result = {'changed': False,
                  'comment': "Could not find Pip version from PyPi: %s" % e}

    if latest_version:
        if StrictVersion(latest_version) > StrictVersion(current_version):
            result = {'changed': True,
                      'comment': "Current version of pip (%s) is outdated. " \
                              "State should upgrade to %s." % (current_version,
                                  latest_version)}
        else:
            result = {'changed': False,
                      'comment': "Pip is at latest version (%s)." %
                        current_version}

if not result:
    result = {'changed': False,
              'comment': "Information on pip version could not be obtained."}

sys.stdout.write(json.dumps(result))
