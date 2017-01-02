FROM ubuntu:16.04
MAINTAINER Tim Scott <tscott8706@gmail.com>
ARG password=password

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

RUN apt-get update && apt-get install -y --no-install-recommends \
net-tools openssh-server supervisor vim \
# For desktop, VNC, and RDP
firefox gnome-core vnc4server xfce4 xfonts-base xrdp

RUN echo 'root:$password' | chpasswd

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# SSH
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN mkdir /var/run/sshd
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
EXPOSE 22

# VNC
RUN password=$password && \
printf "$password\n$password" > /tmp/file && \
vncpasswd < /tmp/file > /tmp/vncpasswd.1 2> /tmp/vncpasswd.2
COPY xstartup $HOME/.vnc/xstartup
RUN chmod 755 $HOME/.vnc/xstartup
EXPOSE 5901

# RDP
#RUN xrdp-keygen xrdp
EXPOSE 3389

# Run multiple commands using supervisord.  See supervisord.conf.
CMD ["/usr/bin/supervisord","-n"]
