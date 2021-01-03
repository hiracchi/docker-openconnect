FROM hiracchi/ubuntu-ja:arm64-latest

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
  org.label-schema.vcs-ref=$VCS_REF \
  org.label-schema.vcs-url="https://github.com/hiracchi/docker-ubuntu-ja" \
  org.label-schema.version=$VERSION

ARG ROOT_PASSWORD

# -----------------------------------------------------------------------------
# base settings
# -----------------------------------------------------------------------------
RUN set -x && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  openconnect openssh-server \
  && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# -----------------------------------------------------------------------------
# sshd
# -----------------------------------------------------------------------------
RUN set -x && \
  mkdir /var/run/sshd && \
  echo 'root:'${ROOT_PASSWORD} | chpasswd && \
  sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
  sed -i 's/#PasswordAuthetication/PasswordAuthetication/' /etc/ssh/sshd_config 

# SSH login fix. Otherwise user is kicked off after login
RUN set -x && \
  sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd


# -----------------------------------------------------------------------------
# ssh key
# -----------------------------------------------------------------------------
USER ${USER_NAME}
RUN set -x && \
  ssh-keygen -m PEM -t rsa -b 1024 -C "${USER_NAME}@localhost" -N "" -f ${HOME}/.ssh/id_rsa && \
  cat ${HOME}/.ssh/id_rsa.pub >> ${HOME}/.ssh/authorized_keys

USER root
RUN set -x && \
  chown -R "${USER_NAME}:${GROUP_NAME}" /home/${USER_NAME} && \
  ls -al /home/${USER_NAME} && \
  cp "/home/${USER_NAME}/.ssh/id_rsa" ${HOME}/ssh-user.pem

# -----------------------------------------------------------------------------
# entrypoint
# -----------------------------------------------------------------------------
USER root
COPY scripts/* /usr/local/bin/

WORKDIR /home/${USER_NAME}
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sudo", "/usr/sbin/sshd", "-D"]
