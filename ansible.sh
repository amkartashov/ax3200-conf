#!/bin/bash

command -v ansible >/dev/null \
&& command -v python >/dev/null \
|| {
  echo === installing ansible

  sudo add-apt-repository --yes --update ppa:ansible/ansible

  sudo apt install -y \
    ansible \
    python-is-python3 \
    python3-venv \
    python3-pip \
    && echo === installing prereqs: Ok.
}

echo === preparing python venv

python3 -m venv .ansible-env \
  --system-site-packages \
	--symlinks
source .ansible-env/bin/activate
pip3 install -r ansible.requirements

echo === add ansible collections

ansible-galaxy install --role-file requirements.yml

echo === run playbook

ansible-playbook playbook.yaml "$@"

echo === done.

exit 0
