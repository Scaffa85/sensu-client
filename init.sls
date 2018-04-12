sensu_repo:
  pkgrepo.managed:
    - humanname: sensu-main
    - baseurl: 'http://repositories.sensuapp.org/yum/el/7/x86_64/'
    - gpgcheck: 0

gcc_c++:
  pkg.installed:
    - name: gcc-c++

sensu_core:
  pkg.installed:
    - name: sensu
    - require:
      - sensu_repo

/etc/sensu/conf.d/client.json:
  file.managed:
    - source: salt://sensu-client/files/client.json.jinja
    - template: jinja
    - mode: 644

/etc/sensu/conf.d/rabbitmq.json:
  file.managed:
    - source: salt://sensu-client/files/rabbitmq.json.jinja
    - template: jinja
    - mode: 644

/etc/sensu/conf.d/transport.json:
   file.managed:
     - source: salt://sensu-client/files/transport.json

{%- for check in salt['pillar.get']('sensu_default_checks')  %}
{{check}}:
  gem.installed:
    - user: sensu
    - gem_bin: /opt/sensu/embedded/bin/gem
{%-endfor %}

sensu_client:
  service.running:
    - order: last
    - name: sensu-client
    - enable: True
    - watch:
      - file: /etc/sensu/conf.d/rabbitmq.json
      - file: /etc/sensu/conf.d/client.json
      - file: /etc/sensu/conf.d/transport.json


