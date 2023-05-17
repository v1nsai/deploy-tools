#!/bin/env python
import yaml
import re

'''Writes key and cert bundles to secret spec yaml'''

with open('auth/cert-bundle.pem', 'r') as cert_bundle:
    with open('auth/key-bundle.pem', 'r') as key_bundle:
        secret = {
            'apiVersion': 'v1',
            'kind': 'Secret',
            'metadata': {
                'name': 'wp-tls-secret'
            },
            'type': 'kubernetes.io/tls',
            'data': {
                'key-bundle.pem': key_bundle.read().strip(),
                'cert-bundle.pem': cert_bundle.read().strip(),
                'httpd.conf': '''|
                    # generated 2023-05-14, Mozilla Guideline v5.6, Apache 2.4.41, OpenSSL 1.1.1k, modern configuration
                    # https://ssl-config.mozilla.org/#server=apache&version=2.4.41&config=modern&openssl=1.1.1k&guideline=5.6

                    # this configuration requires mod_ssl, mod_socache_shmcb, mod_rewrite, and mod_headers
                    <VirtualHost *:80>
                        RewriteEngine On
                        RewriteCond %{REQUEST_URI} !^/\.well\-known/acme\-challenge/
                        RewriteRule ^(.*)$ https://%{HTTP_HOST}$1 [R=301,L]
                    </VirtualHost>

                    <VirtualHost *:443>
                        SSLEngine on
                        SSLCertificateFile      /etc/apache/cert-bundle.pem
                        SSLCertificateKeyFile   /etc/apache/key-bundle.pem

                        # enable HTTP/2, if available
                        Protocols h2 http/1.1

                        # HTTP Strict Transport Security (mod_headers is required) (63072000 seconds)
                        Header always set Strict-Transport-Security "max-age=63072000"
                    </VirtualHost>

                    # modern configuration
                    SSLProtocol             all -SSLv3 -TLSv1 -TLSv1.1 -TLSv1.2
                    SSLHonorCipherOrder     off
                    SSLSessionTickets       off

                    SSLUseStapling On
                    SSLStaplingCache "shmcb:logs/ssl_stapling(32768)"
                    '''
                }
            }
        
        with open('wordpress/wp2-tls-secret.yaml', 'w') as file:
            s = yaml.dump(secret, ).replace('\n\n', '\n')
            # s = s.replace(r'\n', '\n')
            s = s.replace(': "', ': |\n\t\t')
            s = s.replace(": '", ': |\n\t\t')
            print(s)
            file.write(s)


