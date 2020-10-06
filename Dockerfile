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

FROM opensuse/leap:15.2@sha256:7a6c8562ddbc367e20b08538b0ac6c57fc400a6edece39b8495afeaaa9cea58a AS staging
RUN zypper refresh
RUN zypper --non-interactive install \
        git-core \
        go1.14 \
        make

ARG KUBECTL_VERSION
ENV KUBECTL_VERSION=${KUBECTL_VERSION}
WORKDIR /build
RUN git clone --depth=1 --branch="${KUBECTL_VERSION}" https://github.com/kubernetes/kubernetes.git
WORKDIR /build/kubernetes
RUN make kubectl

FROM scratch
COPY --from=staging /build/kubernetes/_output/local/bin/linux/amd64/kubectl /kubectl
ENTRYPOINT ["/kubectl"]
