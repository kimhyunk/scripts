#!/bin/bash
#
# maas-support-info - Gather support information for the machine
#
# Copyright (C) 2012-2020 Canonical
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# --- Start MAAS 1.0 script metadata ---
# name: 60-maaas-test.sh
# title: install infininband driver
# description: install infininband driver
# script_type: commissioning
# parallel: any
# timeout: 00:05:00
# --- End MAAS 1.0 script metadata ---

sudo yum update

#curl -fsSL https://get.docker.com -o get-docker.sh
#sudo sh get-docker.sh
#
#sudo gpasswd -a ${USER} docker
#sudo systemctl enable docker
#sudo service docker restart
