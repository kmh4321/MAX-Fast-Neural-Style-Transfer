#
# Copyright 2018-2019 IBM Corp. All Rights Reserved.
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
#

FROM codait/max-base:v1.1.3

# Upgrade packages to meet security criteria
RUN apt-get update && apt-get upgrade -y && rm -rf /var/lib/apt/lists/*

ARG model_bucket=https://max.cdn.appdomain.cloud/max-fast-neural-style-transfer/1.0.1
ARG model_file=assets.tar.gz

WORKDIR /workspace

RUN wget -nv --show-progress --progress=bar:force:noscroll ${model_bucket}/${model_file} --output-document=assets/${model_file} && \
  tar -x -C assets/ -f assets/${model_file} -v && rm assets/${model_file}

# Conda is the preferred way to install Pytorch, but the Anaconda install pulls
# in non-OSS libraries with customized license terms, specifically CUDA and MKL.
#RUN conda update -n base conda
#RUN conda install -y pytorch-cpu torchvision -c pytorch

# pip install pytorch to avoid dependencies on MKL or CUDA
COPY requirements.txt /workspace
RUN pip install -r requirements.txt

COPY . /workspace

# check file integrity
RUN sha512sum -c sha512sums.txt

EXPOSE 5000

CMD python app.py
