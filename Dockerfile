FROM gourao/goubuntu

COPY examples/nfsclient-sync /usr/local/bin/pvctest

CMD ["/usr/local/bin/pvctest"]
