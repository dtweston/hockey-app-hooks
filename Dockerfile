FROM perfectlysoft/ubuntu1510
RUN /usr/src/Perfect-Ubuntu/install_swift.sh --sure
RUN git clone https://github.int.yammer.com/dweston/hockey-app-hooks /usr/src/hockey-app-hooks
WORKDIR /usr/src/hockey-app-hooks
RUN swift build
CMD .build/debug/hooks --port 80
