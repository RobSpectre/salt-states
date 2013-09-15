DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': "{{ pillar['sentry']['dbname'] }}",
        'USER': "{{ pillar['sentry']['dbuser'] }}",
        'PASSWORD': "{{ pillar['sentry']['dbpassword'] }}",
        'HOST': "{{ pillar['sentry']['dbhost'] }}",
        'PORT': '5432',
        'OPTIONS': {
            'autocommit': True,
        }
    }
}

SENTRY_URL_PREFIX = 'http://sentry.brooklynhacker.com'

SENTRY_KEY = "{{ pillar['sentry']['key'] }}"

SENTRY_WEB_HOST = '0.0.0.0'
SENTRY_WEB_PORT = 9000
SENTRY_WEB_OPTIONS = {
    'workers': 3,
    'secure_scheme_headers': {'X-FORWARDED-PROTO': 'https'},
}
