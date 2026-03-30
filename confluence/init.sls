
{% set default_sources = {'module' : 'confluence', 'defaults' : True, 'pillar' : True, 'grains' : ['os_family']} %}
{% from "./defaults/load_config.jinja" import config as confluence with context %}

{% if confluence.use is defined -%}

{% if confluence.use | to_bool -%}

confluence_installation:
  pkg.installed:
    - sources: {{ confluence.package_list|json }}
  
{{ confluence.install_path }}/bin/user.sh:
  file.managed:
    - contents: |
        CONF_USER="{{ confluence.user_name }}"

        export CONF_USER
    - user: {{ confluence.user_name }}
    - group: {{ confluence.user_name }}
    - mode: 755

{% if confluence.configuration is defined -%}

{{ confluence.confluence_home }}/confluence.cfg.xml:
  file.managed:
    - source: salt://confluence/generic-xml-template.jinja
    - template: jinja
    - context: 
        root_element: {{ confluence["confluence.cfg"]|json }}
    - user: {{ confluence.user_name }}
    - group: {{ confluence.user_name }}
    - mode: 640
    - require:
      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running

{% endif -%}

{% if confluence.keystore_file is defined -%}
  
{{ confluence.install_path }}/conf/ssl_keystore.pkcs12:
  file.managed:
    - source: {{ confluence.keystore_file }}
    - user: {{ confluence.user_name }}
    - group: {{ confluence.user_name }}
    - mode: 640

{% endif -%}

#confluence_running:  
#  service.running:
#    - name: {{ confluence.service_name }}
#    - enable: True
#    - require:
#      - confluence_installation

{%- else -%}

confluence_stopped:  
  service.dead:
    - name: {{ confluence.service_name }}
    - enable: False

confluence_removal:
  pkg.removed:
    - pkgs: {{ confluence.package_list.values()|json }}
    - require:
      - service: {{ confluence.service_name }}

{%- endif %}

{%- endif %}