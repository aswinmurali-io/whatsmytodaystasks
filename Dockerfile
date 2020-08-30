FROM ubuntu

COPY . /app

RUN apt-get update && apt-get install -y wget git && rm -rf /var/lib/apt/lists
RUN git clone https://github.com/flutter/flutter.git
RUN export PATH="$PATH:`pwd`/flutter/bin"
RUN flutter precache
RUN flutter doctor
RUN cd app

CMD flutter run -d linux
