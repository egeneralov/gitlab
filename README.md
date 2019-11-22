egeneralov.gitlab
=================

Provision gitlab-ce installation with LDAP, omniauth and s3 backup integration.

Requirements
------------

Debian-based machine. Tested on stretch, installation "on-premise" and DigitalOcean template.

Role Variables
--------------

All fields are required and have default value.

- **domain**: like `gitlab.egeneralov.tk`
- **email**: for let's encrypt notifications
- **root_password**: string, more 8 chars
- **runners_token**: string, 21 chars


- **ldap**:
  - **enabled**: if `true` - enable integration
  - **host**: ldap dns name, like `ldap.egeneralov.tk`
  - **port**: `389` or (ssl) `636`
  - **uid**: id attribute, like `uid`
  - **bind_dn**: like `uid=gitlabro,cn=users,cn=compat,dc=egeneralov,dc=tk`
  - **password**: bind_dn user password
  - **encryption**: `plain, simple_tls or start_tls`
  - **verify_certificates**: `true` or `false`
  - **ca_file**: path `/etc/ipa/ca.crt`
  - **active_directory**: `true` or `false`
  - **allow_username_or_email_login**: `true` or `false`
  - **block_auto_created_users**: `true` or `false`
  - **base**: base dn, like `dc=egeneralov,dc=tk`
  - **user_filter**: just `(objectClass=inetorgperson)` or restrict to group like `(&(uid=%u)(memberOf=gitlab,cn=groups,cn=accounts,dc=egeneralov,dc=tk))`


- **omniauth**:
  - **enabled**: if true - enable integration
  - **providers**: inspect https://docs.gitlab.com/ce/integration/omniauth.html

```json
    {
      "name": "bitbucket",
      "app_id": "",
      "app_secret": "",
      "url": "https://bitbucket.org/"
    }
```

- **backup**: setup auto-backups to S3
  - **enabled**: if true - enable integration
  - **bucket**: name of DigitalOcean space

```json
    {
      "provider": "AWS",
      "region": "ams3",
      "aws_access_key_id": "",
      "aws_secret_access_key": "",
      "endpoint": "https://ams3.digitaloceanspaces.com"
    }
```

- **restore**: restore your gitlab from backup file
  - **enabled**: if `true` - proceed restore action
  - **force**: if `true` - proceed restore action if backup file already present on remote host
  - **from**: path to `_gitlab_backup.tar` file
  - **secrets**: path to `gitlab-secrets.json`, if lost - database secrets will be cleaned



Example playbook
----------------

#### Just install

    - hosts: gitlab
      vars:
        domain: gitlab.shared
        email: noc@gitlab.com
        root_password: Ru65oNWUzJQ17yh7YwzE
        runners_token: Ru65oNWUzJQ17yh7YwzE
      roles:
        - egeneralov.gitlab

#### Restore from backup

[![asciicast](https://asciinema.org/a/TqAA1J1lDVi7ub1xxdjFJ35TU.svg)](https://asciinema.org/a/TqAA1J1lDVi7ub1xxdjFJ35TU)

    - hosts: gitlab
      vars:
        domain: gitlab.shared
        email: noc@gitlab.com
        root_password: Ru65oNWUzJQ17yh7YwzE
        runners_token: Ru65oNWUzJQ17yh7YwzE
        gitlab_version: 11.3.4-ce.0
        restore:
          enabled: yes
          from: 1551970455_2019_03_07_11.3.4_gitlab_backup.tar
          secrets: gitlab-secrets.json
          force: no
      roles:
        - egeneralov.gitlab

#### Example with ldap and auto-backup to digital ocean s3

    - hosts: gitlab
      vars:
        domain: gitlab.company.tld
        email: noc@company.tld
        root_password: Ru65oNWUzJQ17yh7YwzE
        runners_token: Ru65oNWUzJQ17yh7YwzE
        ldap:
          enabled: true
          host: ldap.company.tld
          bind_dn: 'uid=gitlabro,cn=users,cn=compat,dc=company,dc=tld'
          password: 'Ru65oNWUzJQ17yh7YwzE'
          encryption: 'plain'
          base: 'dc=company,dc=tld'
          user_filter: '(objectClass=inetorgperson)'
        backup:
          enabled: true
          bucket: "gitlab-company-tld-backup-space"
          upload_connection: {
              "provider": "AWS",
              "region": "ams3",
              "aws_access_key_id": "digitaloceanspaces",
              "aws_secret_access_key": "Ru65oNWUzJQ17yh7YwzE",
              "endpoint": "https://ams3.digitaloceanspaces.com"
            }
      roles:
        - egeneralov.gitlab


Example ssl client auth setup
-----------------------------

Run the following playbook

    - hosts: gitlab
      vars:
        domain: gitlab.{{ ansible_default_ipv4.address }}.xip.io
        registry_host: registry.{{ ansible_default_ipv4.address }}.xip.io
        email: eduard@generalov.net
        root_password: Ru65oNWUzJQ17yh7YwzE
        runners_token: Ru65oNWUzJQ17yh7YwzE
        
        nginx:
          enable: false
        
        custom_nginx:
          ssl:
            provider: selfsigned
            base_subj: "/C=NL/ST={{ domain }}/L={{ domain }}/O={{ domain }}/OU={{ domain }}"
            # specify list of users for auto-certificate setup. Insecure way.
            users:
              - egeneralov
      roles:
        - egeneralov.gitlab

And you can generate client certificates (manualy) like that (Insecure way):

    cd /etc/gitlab/ssl/
    USER=egeneralov
    openssl genrsa -out $USER.key 2048
    openssl req -new -key $USER.key -out $USER.csr -subj "/C=NL/ST=Zuid Holland/L=Rotterdam/O=Sparkling Network/OU=IT Department/CN=$USER"
    openssl x509 -req -in $USER.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $USER.crt -days 365
    openssl pkcs12 -export -out $USER.pfx -inkey $USER.key -in $USER.crt -certfile ca.crt

Secure way:

- customer must generate .key via `openssl genrsa -out $USER.key 2048`
- customer must generate .csr via `openssl req -new -key $USER.key -out $USER.csr -subj "/C=NL/ST=Zuid Holland/L=Rotterdam/O=Sparkling Network/OU=IT Department/CN=$USER"`
- obtain a .csr from your customer
- you copy .csr to `/etc/gitlab/ssl` on gitlab server
- sign .crt via `openssl x509 -req -in $USER.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out $USER.crt -days 365`
- send .crt and ca.crt to your customer
- your customer must generate his .pfx file via `openssl pkcs12 -export -out $USER.pfx -inkey $USER.key -in $USER.crt -certfile ca.crt`

License
-------

MIT
