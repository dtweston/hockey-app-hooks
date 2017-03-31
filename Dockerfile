FROM ibmcom/swift-ubuntu
ADD . /root/hockey-app-hooks
WORKDIR /root/hockey-app-hooks
RUN swift build --configuration release
EXPOSE 8080
ENTRYPOINT [".build/release/HockeyAppApp"]
