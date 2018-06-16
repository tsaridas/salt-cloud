highstate_run:
  local.state.apply:
    - tgt: {{ data['id'] }}

copy_pillar:
  local.state.apply:
    - tgt: salt-master
