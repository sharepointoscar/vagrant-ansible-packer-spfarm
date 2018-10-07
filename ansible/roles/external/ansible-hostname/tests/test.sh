#!/bin/bash

echo
echo ansible-playbook -i test_default.ini test_default.yml -vvvvv --diff
echo
ansible-playbook -i test_default.ini test_default.yml -vvvvv --diff

echo
echo ansible-playbook -i test_level.ini test_level1.yml -vvvvv --diff
echo
ansible-playbook -i test_level.ini test_level1.yml -vvvvv --diff

echo
echo ansible-playbook -i test_level.ini test_level3.yml -vvvvv --diff
echo
ansible-playbook -i test_level.ini test_level3.yml -vvvvv --diff

