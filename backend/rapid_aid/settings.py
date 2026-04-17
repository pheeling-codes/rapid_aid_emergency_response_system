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
    # Fallback to fiona wheels if OSGeo4W isn't perfectly configured
    fiona_libs = BASE_DIR / '.venv' / 'Lib' / 'site-packages' / 'fiona.libs'
    
    osgeo4w_paths = [
        r"C:\OSGeo4W64",
        r"C:\OSGeo4W",
    ]
    osgeo_path = next((p for p in osgeo4w_paths if os.path.exists(p)), None)
    
    if fiona_libs.exists():
        # Fiona installed via pip
        os.environ['PATH'] = str(fiona_libs) + ';' + os.environ.get('PATH', '')
        gdal_dlls = glob.glob(str(fiona_libs / "gdal*.dll"))
        if gdal_dlls:
            GDAL_LIBRARY_PATH = gdal_dlls[0]
        geos_dlls = glob.glob(str(fiona_libs / "geos_c*.dll"))
        if geos_dlls:
            GEOS_LIBRARY_PATH = geos_dlls[0]

    elif osgeo_path and os.path.exists(os.path.join(osgeo_path, 'bin')):
        # Traditional OSGeo4W
        bin_path = os.path.join(osgeo_path, 'bin')
        os.environ['PATH'] = bin_path + ';' + os.environ.get('PATH', '')
        os.environ['PROJ_LIB'] = os.path.join(osgeo_path, 'share', 'proj')
        
        gdal_dlls = glob.glob(os.path.join(bin_path, "gdal*.dll"))
        if gdal_dlls:
            GDAL_LIBRARY_PATH = gdal_dlls[0]
        geos_dlls = glob.glob(os.path.join(bin_path, "geos_c*.dll"))
        if geos_dlls:
            GEOS_LIBRARY_PATH = geos_dlls[0]

# Database Setup (PostGIS via dj-database-url)
DATABASES = {
    'default': dj_database_url.config(
        default=config('DATABASE_URL'),
        conn_max_age=600,
        ssl_require=True,
        engine='django.contrib.gis.db.backends.postgis'
    )
}
# Supabase requires SSL, so we set ssl_require=True and ensure engine is postgis.

# Channels Redis Layer
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            "hosts": [config('REDIS_URL', default='redis://127.0.0.1:6379/0')],
        },
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
}

# Simple JWT Config
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'SIGNING_KEY': config('SECRET_KEY', default='django-insecure-development-key'),
    'AUTH_HEADER_TYPES': ('Bearer',),
}

# CORS configuration
CORS_ALLOWED_ORIGINS = config('CORS_ALLOWED_ORIGINS', default='http://localhost:3000').split(',')
