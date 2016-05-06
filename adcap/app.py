DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': '{{ db_name }}',
        'USER': '{{ db_user }}',
        'PASSWORD': '{{ db_password }}',
        'HOST': 'localhost',
        'PORT': '',
    }
}

CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': '127.0.0.1:6379',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

WAGTAILSEARCH_BACKENDS = {
    'default': {
        'BACKEND': 'wagtail.wagtailsearch.backends.elasticsearch.ElasticSearch',
        'INDEX': "{{ grains['elasticsearch']['cluster'] }}",
    },
}

DEBUG = False

SECRET_KEY = '{{ cookie_key }}'
NEVERCACHE_KEY = "{{ never_cache_key }}"

ALLOWED_HOSTS = "*"

EMAIL_HOST_USER = '{{ email_user }}'
EMAIL_USE_TLS = True
EMAIL_HOST = '{{ email_host }}'
EMAIL_HOST_PASSWORD = '{{ email_password }}'
EMAIL_PORT = 587
EMAIL_FAIL_SILENTLY = False

WAGTAILADMIN_NOTIFICATION_USE_HTML = True
WAGTAILADMIN_NOTIFICATION_FROM_EMAIL = 'hello@adcap.biz'
TAGGIT_CASE_INSENSITIVE = True
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

ADMINS = [('Admins', 'hello@adcap.biz')]

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
         'require_debug_false': {
             '()': 'django.utils.log.RequireDebugFalse'
         }
     },
    'handlers': {
        # Include the default Django email handler for errors
        # This is what you'd get without configuring logging at all.
        'mail_admins': {
            'class': 'django.utils.log.AdminEmailHandler',
            'level': 'ERROR',
            'filters': ['require_debug_false'],
             # But the emails are plain text by default - HTML is nicer
            'include_html': True,
        },
        # Log to a text file that can be rotated by logrotate
        'logfile': {
            'class': 'logging.handlers.WatchedFileHandler',
            'filename': '/opt/adcap.biz/log/adcap.biz_application_error.log'
        },
    },
    'loggers': {
        # Again, default Django configuration to email unhandled exceptions
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
        # Might as well log any errors anywhere else in Django
        'django': {
            'handlers': ['logfile'],
            'level': 'ERROR',
            'propagate': False,
        },
        # Your own app - this assumes all your logger names start with "myapp."
        'home': {
            'handlers': ['logfile'],
            'level': 'DEBUG', # Or maybe INFO or WARNING
            'propagate': False
        },
    },
}
