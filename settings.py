# Django settings for gridpak project.
import os
from django.conf.global_settings import *

#==============================================================================
# General project settings
#==============================================================================

SITE_ID = 1

DEBUG = True
TEMPLATE_DEBUG = DEBUG

ADMINS = (
    ('Erskine Design', 'dev@erskinedesign.com'),
)
MANAGERS = ADMINS

SECRET_KEY = '+$-=gzrupi%hh81d8jdbq153xekw_rh)g&hurp4d^zhj_sta81'

ROOT_URLCONF = 'gridpak.urls'

CURDIR = os.path.dirname(__file__)

#==============================================================================
# Localisation settings
#==============================================================================

# Local time zone for this installation. Choices can be found here:
# http://en.wikipedia.org/wiki/List_of_tz_zones_by_name
TIME_ZONE = 'Europe/London'
LANGUAGE_CODE = 'en-gb'
USE_I19N = True
USE_L10N = True

#==============================================================================
# Media settings
#==============================================================================

ADMIN_MEDIA_PREFIX = '/static/admin/'

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
)

MEDIA_ROOT = CURDIR + '/media/'
MEDIA_URL = '/media/'
STATIC_ROOT = CURDIR + '/static_collected/'
STATIC_URL = '/static/'

STATICFILES_DIRS = (
    CURDIR + '/static/',
)

#==============================================================================
# Template settings
#==============================================================================

TEMPLATE_LOADERS = (
    'django.template.loaders.filesystem.Loader',
    'django.template.loaders.app_directories.Loader',
)

TEMPLATE_CONTEXT_PROCESSORS = (
    'django.contrib.auth.context_processors.auth',
    'django.core.context_processors.debug',
    'django.core.context_processors.i18n',
    'django.core.context_processors.media',
    'django.core.context_processors.request',
    'django.contrib.messages.context_processors.messages',
    'django.core.context_processors.static',
)

TEMPLATE_DIRS = (
    CURDIR + '/templates/',
)

#==============================================================================
# Middleware settings
#==============================================================================

MIDDLEWARE_CLASSES = (
    'django.middleware.common.CommonMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'debug_toolbar.middleware.DebugToolbarMiddleware',
)

#==============================================================================
# Base logging config
#==============================================================================

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '%(levelname)s %(asctime)s %(module)s %(process)d %(thread)d %(message)s'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        },
    },
    'handlers': {
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'simple'
        },
        'mail_admins': {
            'level': 'ERROR',
            'class': 'django.utils.log.AdminEmailHandler'
        }
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'ERROR',
            'propagate': True,
        },
    }
}

#==============================================================================
# Application settings
#==============================================================================

INSTALLED_APPS = (
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.sites',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django.contrib.admin',
    # Third-party apps
    'south',
    'debug_toolbar',
    # Project-specific apps
)

# For the debug toolbar
INTERNAL_IPS = (
    '127.0.0.1',
)

DEBUG_TOOLBAR_CONFIG = {
    'INTERCEPT_REDIRECTS': False,
}

# Do not edit below this line
try:
    from local_settings import *
except:
    pass
