from pathlib import Path
from decouple import config
import dj_database_url
from datetime import timedelta

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = config('SECRET_KEY', default='django-insecure-development-key')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = config('DEBUG', default=True, cast=bool)

ALLOWED_HOSTS = config('ALLOWED_HOSTS', default='localhost,127.0.0.1').split(',')

# Application definition
INSTALLED_APPS = [
    'daphne', # ASGI server (must be before django.contrib.staticfiles)
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # GeoDjango
    'django.contrib.gis',

    # Third-party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'django_filters',
    'channels',

    # Local apps
    'accounts.apps.AccountsConfig',
    'incidents.apps.IncidentsConfig',
    'notifications.apps.NotificationsConfig',
    'dispatcher.apps.DispatcherConfig',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'rapid_aid.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

import os
import glob

# Use Daphne for ASGI
ASGI_APPLICATION = 'rapid_aid.asgi.application'
WSGI_APPLICATION = 'rapid_aid.wsgi.application'

# ── GeoDjango Windows Configuration ──────────────────────────
if os.name == 'nt':
    import glob
    _site_packages = BASE_DIR / '.venv' / 'Lib' / 'site-packages'

    # 1) Try GEOS from shapely.libs (bundled wheel, always present on Windows)
    shapely_libs = _site_packages / 'shapely.libs'
    if shapely_libs.exists():
        geos_dlls = glob.glob(str(shapely_libs / 'geos_c*.dll'))
        if geos_dlls:
            GEOS_LIBRARY_PATH = geos_dlls[0]
        os.environ['PATH'] = str(shapely_libs) + ';' + os.environ.get('PATH', '')

    # 2) Try GDAL from pyproj.libs (pyproj wheel bundles proj/gdal on Windows)
    pyproj_libs = _site_packages / 'pyproj.libs'
    if pyproj_libs.exists():
        gdal_dlls = glob.glob(str(pyproj_libs / 'gdal*.dll'))
        if gdal_dlls:
            GDAL_LIBRARY_PATH = gdal_dlls[0]
        os.environ['PATH'] = str(pyproj_libs) + ';' + os.environ.get('PATH', '')

    # 3) Try OSGeo4W as final fallback
    if 'GDAL_LIBRARY_PATH' not in dir():
        for osgeo_path in [r'C:\OSGeo4W64', r'C:\OSGeo4W']:
            if os.path.exists(osgeo_path):
                bin_path = os.path.join(osgeo_path, 'bin')
                os.environ['PATH'] = bin_path + ';' + os.environ.get('PATH', '')
                os.environ['PROJ_LIB'] = os.path.join(osgeo_path, 'share', 'proj')
                gdal_dlls = glob.glob(os.path.join(bin_path, 'gdal*.dll'))
                if gdal_dlls:
                    GDAL_LIBRARY_PATH = gdal_dlls[0]
                geos_dlls = glob.glob(os.path.join(bin_path, 'geos_c*.dll'))
                if geos_dlls:
                    GEOS_LIBRARY_PATH = geos_dlls[0]
                break

# Database Setup (PostGIS via dj-database-url)
# Detect if GDAL is available to pick the right backend
_gdal_available = 'GDAL_LIBRARY_PATH' in dir() or os.environ.get('GDAL_LIBRARY_PATH')
if not _gdal_available:
    # Try to load GDAL to see if it's on the system PATH
    import ctypes
    for _gdal_name in ['gdal308', 'gdal307', 'gdal306', 'gdal305', 'gdal304', 'gdal303', 'gdal302', 'gdal301', 'gdal300', 'gdal']:
        try:
            ctypes.cdll.LoadLibrary(_gdal_name)
            _gdal_available = True
            break
        except OSError:
            pass

_db_engine = 'django.contrib.gis.db.backends.postgis' if _gdal_available else 'django.db.backends.postgresql'

if not _gdal_available:
    # Remove GeoDjango app when GDAL is unavailable (local Windows dev without OSGeo4W)
    import warnings
    warnings.warn(
        "GDAL not found — using plain PostgreSQL backend. GeoDjango spatial features disabled. "
        "Install OSGeo4W or GDAL to enable full spatial support.",
        RuntimeWarning
    )
    INSTALLED_APPS = [app for app in INSTALLED_APPS if app != 'django.contrib.gis']

DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL'),
        conn_max_age=600,
        ssl_require=True,
        engine=_db_engine,
    )
}
# Supabase requires SSL, so we set ssl_require=True and ensure engine is postgis.


# Channels Layer — prefers Redis, falls back to InMemory for local dev without Redis
_REDIS_URL = config('REDIS_URL', default='')
if _REDIS_URL:
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': 'channels_redis.core.RedisChannelLayer',
            'CONFIG': {
                "hosts": [_REDIS_URL],
            },
        },
    }
else:
    # No REDIS_URL set (or empty): use in-memory layer for local dev
    CHANNEL_LAYERS = {
        'default': {
            'BACKEND': 'channels.layers.InMemoryChannelLayer',
        },
    }

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# Custom User Model
AUTH_USER_MODEL = 'accounts.CustomUser'

# Django Rest Framework
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.IsAuthenticated',
    ],
    'DEFAULT_FILTER_BACKENDS': ['django_filters.rest_framework.DjangoFilterBackend'],
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
        'rest_framework.throttling.ScopedRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day',
        'password_reset': '5/minute',
    }
}

# Simple JWT Config
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'SIGNING_KEY': config('SECRET_KEY', default='django-insecure-development-key'),
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# CORS configuration
# In DEBUG mode: allow all origins so Flutter dev ports (random) work seamlessly
if DEBUG:
    CORS_ALLOW_ALL_ORIGINS = True
else:
    CORS_ALLOWED_ORIGINS = config('CORS_ALLOWED_ORIGINS', default='http://localhost:3000').split(',')

# Email Configuration
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'
