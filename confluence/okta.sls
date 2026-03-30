
{%- set default_sources = {'module' : 'confluence', 'defaults' : True, 'pillar' : True, 'grains' : ['os_family']} %}
{%- from "./defaults/load_config.jinja" import config as confluence with context -%}

{%- set default_sources = {'module' : ['confluence', 'okta'], 'defaults' : True, 'pillar' : True, 'grains' : ['os_family']} %}
{%- from "./defaults/load_config.jinja" import config as okta with context -%}

{% if okta.use is defined -%}

{% if okta.use | to_bool -%}

{% if okta.configuration is defined -%}

{{ confluence.install_path }}/conf/okta-config-confluence.xml:
  file.managed:
    - contents: |
        {{ okta.configuration | indent(8) }}
    - user: {{ confluence.user_name }}
    - group: {{ confluence.user_name }}
    - mode: 640
#    - require:
#      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running
      
{% endif -%}

{{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml->login.url:
  xml.value_present:
    - name: {{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml
    - xpath: ./parameters/init-param[param-name='login.url']/param-value
    - value: {{ okta.login_url }}
#    - require:
#      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running
    
{{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml->logout.url:
  xml.value_present:
    - name: {{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml
    - xpath: ./parameters/init-param[param-name='logout.url']/param-value
    - value: {{ okta.logout_url }}
#    - require:
#      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running
    
#{{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml->remove_authenticators:
#  xml.value_absent:
#    - name: {{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml
#    - xpath: ./authenticator
#    - exceptions:
#        - ./authenticator[@class='com.atlassian.confluence.authenticator.okta.OktaConfluenceAuthenticator30']
#    - require:
#      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running

{{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml->okta_authenticator:
  xml.value_present:
    - name: {{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml
    - xpath: ./authenticator[@class='com.atlassian.confluence.authenticator.okta.OktaConfluenceAuthenticator30']/init-param[param-name='okta.config.file']/param-value
    - value: {{ confluence.install_path }}/conf/okta-config-confluence.xml
#    - require:
#      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running
        

#{{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml->login-url-strategy:
#  xml.value_present:
#    - name: {{ confluence.install_path }}/confluence/WEB-INF/classes/seraph-config.xml
#    - xpath: ./login-url-strategy[@class='com.atlassian.confluence.authenticator.okta.OktaConfluenceLoginUrlStrategy']
#    - value: ""
#    - require:
#      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running

{{ confluence.install_path }}/confluence/okta_acs.jsp:
  file.managed:
    - contents: |
        {{ okta.okta_acs_jsp | indent(8) }}
    - user: {{ confluence.user_name }}
    - group: {{ confluence.user_name }}
    - mode: 640
#    - require:
#      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running

{% set okta_confluence_jar = okta.okta_confluence_jar_url.split('/')[-1] %}
{{ confluence.install_path }}/confluence/WEB-INF/lib/{{ okta_confluence_jar }}:
  file.managed:
    - source: {{ okta.okta_confluence_jar_url }}
{%- if okta.okta_confluence_jar_hash is defined %}
    - source_hash: {{ okta.okta_confluence_jar_hash }}
{%- endif %}
    - skip_verify: true
    - user: {{ confluence.user_name }}
    - group: {{ confluence.user_name }}
    - mode: 640
#    - require:
#      - confluence_installation
#    - require_in:
#      - confluence_running
#    - watch_in:
#      - confluence_running

{%- else -%}

#remove Okta stuff

{%- endif %}

{%- endif %}