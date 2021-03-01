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

FROM opensuse/tumbleweed AS base_compiler

RUN zypper refresh
RUN zypper --non-interactive install \
      jq \
      curl \
      catatonit

FROM base_compiler AS staging_kubectl
ARG KUBECTL_VERSION
ENV KUBECTL_VERSION=${KUBECTL_VERSION}

WORKDIR /build
RUN curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl"
RUN curl -LO "https://dl.k8s.io/$KUBECTL_VERSION/bin/linux/amd64/kubectl.sha256"
RUN echo "$(<kubectl.sha256) kubectl" | sha256sum --check

FROM $FINAL_IMAGE_BASE
COPY --from=base_compiler /usr/bin/jq /usr/local/bin/jq
COPY --from=base_compiler /usr/bin/catatonit /usr/local/bin/catatonit
COPY --from=staging_kubectl /build/kubectl /usr/local/bin/kubectl
ENTRYPOINT ["/usr/local/bin/catatonit", "--", "/usr/local/bin/kubectl"]
