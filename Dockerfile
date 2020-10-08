# Copyright 2020 SUSE
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

ARG FINAL_IMAGE_BASE=registry.suse.com/suse/sle15:15.2.8.2.763@sha256:ec381220e66096967e4babb4c3703fd68e4466943984b63770ac3b82e75c1830

FROM opensuse/tumbleweed AS staging

RUN zypper refresh
RUN zypper --non-interactive install \
      git-core \
      make \
      python3-yq

WORKDIR /build/kubernetes
ARG KUBECTL_VERSION
ENV KUBECTL_VERSION=${KUBECTL_VERSION}
RUN git clone \
      --depth=1 \
      --branch="${KUBECTL_VERSION}" \
      https://github.com/kubernetes/kubernetes.git /build/kubernetes

RUN yq -r \
      '.dependencies[] | select(.name | startswith("golang")) | .version' \
      "build/dependencies.yaml" \
      | awk 'match($0, /^([0-9]+\.[0-9]+).*$/, version) { print version[1] }' \
      | xargs --replace='{}' zypper --non-interactive install 'go{}'

RUN make kubectl

FROM $FINAL_IMAGE_BASE
COPY --from=staging /build/kubernetes/_output/local/bin/linux/amd64/kubectl /usr/local/bin/kubectl
ENTRYPOINT ["/usr/local/bin/kubectl"]
