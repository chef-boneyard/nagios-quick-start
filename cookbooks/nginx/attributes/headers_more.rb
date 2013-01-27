#
# Cookbook Name:: nginx
# Attributes:: headers_more
#
# Author:: Lucas Jandrew (<ljandrew@riotgames.com>)
#
# Copyright 2012, Riot Games
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default['nginx']['headers_more']['source_url'] = 'https://github.com/agentzh/headers-more-nginx-module/tarball/v0.17'
default['nginx']['headers_more']['source_checksum'] = '5c556903763c58db0dd01606fdbba5f8'
