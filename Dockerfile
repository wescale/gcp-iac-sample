FROM bugy/script-server:1.14.0

ADD https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip terraform.zip
RUN apt-get update \
    && apt-get -y install unzip curl gnupg jq \
    && echo "deb http://packages.cloud.google.com/apt cloud-sdk-stretch main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && apt-get -y install google-cloud-sdk \
    && unzip terraform.zip \
    && rm terraform.zip \
    && curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl \
    && chmod +x ./kubectl \
    && mv terraform /usr/local/bin/terraform \
    && mv kubectl /usr/local/bin/kubectl

COPY ci-cd/conf.json /app/conf/conf.json
COPY ci-cd/runners /app/conf/runners/
COPY iac /app/scripts/
COPY plateform /app/plateform/

VOLUME /secret/google-sa
ENV GOOGLE_SA_PATH /secret/google-sa/google.json
ENV GOOGLE_SA sa@google.com
ENV GOOGLE_APPLICATION_CREDENTIALS $GOOGLE_SA_PATH

RUN pip install -r /app/scripts/requirements.txt

COPY start.sh /app/start.sh

EXPOSE 8080
CMD ["./start.sh"]
