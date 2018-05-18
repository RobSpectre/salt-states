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
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'

{% if admins %}
ADMINS = [
{% for admin in admins %}
    ('{{ admin.name }}', '{{ admin.email_address }}'),
{% endfor %}
]
{% endif %}

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
            'filename': '/opt/garfield/log/garfield_application_error.log'
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

STATIC_ROOT = "/opt/garfield/static"

{% if twilio %}
TWILIO_ACCOUNT_SID = "{{ twilio.account_sid }}"
TWILIO_AUTH_TOKEN = "{{ twilio.auth_token }}"
TWILIO_PHONE_NUMBER = "+{{ twilio.phone_number }}"
TWILIO_APP_SID = "{{ twilio.app_sid }}"
TELLFINDER_API_KEY = "{{ tellfinder.api_key }}"
{% endif %}

GARFIELD_NUMBER_OF_DETERRENTS = 3
GARFIELD_DETERRENT_INTERVAL = 172800
