# CSRF Verification Failed
During first login, you may receive a CSRF verification error. This is caused by the Django CMS, which verifies requests based on the Referer HTTP header.

To fix the issue, add your domain via the following config line in */opt/seafile/data/seafile/conf/seahub_settings.py*:

`CSRF_TRUSTED_ORIGINS = ["https://${SEAFILE_SERVER_HOSTNAME}"]`