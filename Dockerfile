FROM gourao/goubuntu

COPY ./lib/.libs/* /usr/local/lib/
COPY ./examples/.libs/nfsclient-sync /usr/local/bin/.libs/nfsclient-sync
COPY examples/pvctest /usr/local/bin/pvctest

ENV LD_LIBRARY_PATH=/usr/local/lib

CMD ["/usr/local/bin/pvctest"]
