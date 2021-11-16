FROM ghcr.io/hiracchi/docker-ubuntu

ARG ROOT_PASSWORD="root"

# -----------------------------------------------------------------------------
# base settings
# -----------------------------------------------------------------------------
USER root
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
USER ${USER_NAME}:${GROUP_NAME}
RUN set -x && \
  ssh-keygen -m PEM -t rsa -b 1024 -C "${USER_NAME}@localhost" -N "" -f /home/${USER_NAME}/.ssh/id_rsa && \
  cat /home/${USER_NAME}/.ssh/id_rsa.pub >> /home/${USER_NAME}/.ssh/authorized_keys

# USER root
# RUN set -x && \
#   chown -R "${USER_NAME}:${GROUP_NAME}" /home/${USER_NAME} && \
#   ls -al /home/${USER_NAME} && \
#   cp "/home/${USER_NAME}/.ssh/id_rsa" ${HOME}/ssh-user.pem

# -----------------------------------------------------------------------------
# entrypoint
# -----------------------------------------------------------------------------
USER root
COPY scripts/* /usr/local/bin/
RUN set -x && \
  mkdir /data

WORKDIR /home/${USER_NAME}
EXPOSE 22
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sudo", "/usr/sbin/sshd", "-D"]
