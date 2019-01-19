egeneralov.gitlab
=========

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
  - **enabled**: if true - **enable integration
  - **providers**: inspect https://docs.gitlab.com/ce/integration/omniauth.html

```json
    {
      "name": "bitbucket",
      "app_id": "",
      "app_secret": "",
      "url": "https://bitbucket.org/"
    }
```

- **backup**:
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


Example playbook
----------------


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
        omniauth:
          enabled: false
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


License
-------

MIT
